#' Query CMIP6 catalog
#'
#' Query a local CMIP6 catalog database built from CSV catalog files and
#' return catalog rows matching the provided filters as a data.table.
#'
#' @param realm Character filter for the `realm` column (e.g. "atmos").
#' @param frequency Character filter for the `frequency` column (e.g. "mon").
#' @param table_id Character filter for the `table_id` column (e.g. "Amon").
#' @param project_id Character filter for the `project_id` column. Defaults to "CMIP".
#' @param institution_id Character filter for the `institution_id` column.
#' @param source_id Character filter for the `source_id` column.
#' @param experiment_id Character filter for the `experiment_id` column.
#' @param member_id Character filter for the `member_id` column. Defaults to "r1i1p1f1".
#' @param variable_id Character filter for the `variable_id` column (e.g. "tas").
#' @param grid_label Character filter for the `grid_label` column.
#' @param version Character filter for the `version` column.
#'
#' @details The function uses a local SQLite database derived from
#' the CSV catalog files.
#' Database rebuild is moderately slow, but it only needs to be done once unless
#' the original catalogues are updated.
#'
#' @return A `data.table` with rows from the `catalog` table matching the
#' supplied filters. Only non-NULL arguments are used as filters.
#'
#' @examples
#' cmip6(frequency = "mon", variable_id = "tas")
#'
#'
#' @export
cmip6 <- function(
  project_id = "CMIP",
  member_id = "r1i1p1f1",
  realm = NULL,
  frequency = NULL,
  table_id = NULL,
  institution_id = NULL,
  source_id = NULL,
  experiment_id = NULL,
  variable_id = NULL,
  grid_label = NULL,
  version = NULL
) {
  filters <- list(
    realm = realm,
    frequency = frequency,
    table_id = table_id,
    project_id = project_id,
    institution_id = institution_id,
    source_id = source_id,
    experiment_id = experiment_id,
    member_id = member_id,
    variable_id = variable_id,
    grid_label = grid_label,
    version = version
  )

  # Merge: new filters overwrite existing ones, NULLs don't overwrite
  filters <- Filter(Negate(is.null), filters)

  clauses <- mapply(
    function(col, vals) {
      quoted <- paste(sprintf("'%s'", vals), collapse = ", ")
      sprintf("%s IN (%s)", col, quoted)
    },
    names(filters),
    filters
  )
  clauses <- c(clauses, "version LIKE 'v%'")
  where <- paste(clauses, collapse = " AND ")
  sql <- sprintf("SELECT * FROM catalog WHERE %s", where)
  con <- cmip6_catalogue_con()
  on.exit(RSQLite::dbDisconnect(con))
  data.table::setDT(RSQLite::dbGetQuery(con, sql))[]
}

cmip6_db_columns <- c(
  "path",
  "file_type",
  "realm",
  "frequency",
  "table_id",
  "project_id",
  "institution_id",
  "source_id",
  "experiment_id",
  "member_id",
  "variable_id",
  "grid_label",
  "version",
  "time_range"
)

#' Get latest version 
#' 
#' Returns the latest version of each CMIP6 file
#' 
#' @param catalogue A catalogue returned by [cmip6()]
#'  
#' @export 
cmip6_latest <- function(catalogue) {
  cols <- setdiff(colnames(catalogue), c("version", "version2", cmip6_db_columns[c(1, 2)]))
  
  catalogue <- data.table::copy(catalogue)[, version2 := as.numeric(gsub("v", "", version))]
  
  catalogue[, .SD[which.max(version2)], by = c(cols)][, version2 := NULL][]
}

#' Get the "best" grid
#' 
#' This selects the best grid based on preferring regridded
#' data to the preferred target grid ("gr") and then any 
#' other regridding ("gr1/gr2") and fall back to native grid
#' "gn" if there's no other choice. 
#' 
#' @param catalogue A catalogue returned by [cmip6()]
#'  
#' @export 
cmip6_best_grid <- function(catalogue) {
  cols <- setdiff(colnames(catalogue), c("grid_label", cmip6_db_columns[c(1, 2)]))
    
  catalogue[, .SD[which_best_grid(grid_label)], by = c(cols)][]
}

which_best_grid <- function(grids) { 
  if (length(grids) == 1) {
    return(1)
  }

  # If there's a gr, select the lowest value. 
  gr <- grids[grepl("^gr", grids)]
  if (length(gr) > 0) {
    nums <- as.integer(sub("^gr([0-9]*)(.*)", "\\1", gr))
    nums[is.na(nums)] <- 0  
    return(which.min(nums))
  }

  # If there are more than one, at least one of them should be regridded
  # The only case we could be here if it's there's more than one 
  # native grid, which shouldn't happen. 
  cli::cli_inform("Picking first grid")
  return(1)

}

cmip6_catalogues <- c(
  "/g/data/oi10/catalog/v2/esm/cmip6-oi10.csv.gz",
  "/g/data/fs38/catalog/v2/esm/cmip6-fs38.csv.gz"
)

db_path_f <- function() {
  PROJECT <- Sys.getenv("PROJECT")
  USER <- Sys.getenv("USER")
  file.path("/g/data/", PROJECT, USER, "cmip6.sqlite")
}

cmip6_catalogue_con <- function(
  csv_paths = cmip6_catalogues,
  db_path = db_path_f()
) {
  needs_rebuild <- !file.exists(db_path) ||
    max(file.mtime(csv_paths)) > file.mtime(db_path)

  if (needs_rebuild) {
    build_cmip_db(csv_paths, db_path)
  }

  RSQLite::dbConnect(RSQLite::SQLite(), db_path)
}

build_cmip_db <- function(
  csv_paths = cmip6_catalogues,
  db_path = db_path_f()
) {
  cli::cli_inform("Rebuilding catalog database...")
  if (!dir.exists(dirname(db_path))) {
    dir.create(dirname(db_path))
  }

  if (file.exists(db_path)) {
    unlink(db_path)
  }

  con <- RSQLite::dbConnect(RSQLite::SQLite(), db_path)
  on.exit(RSQLite::dbDisconnect(con))

  for (i in seq_along(csv_paths)) {
    cli::cli_inform("Reading {csv_paths[i]}...")
    RSQLite::dbWriteTable(
      con,
      "catalog",
      data.table::fread(csv_paths[i]),
      overwrite = i == 1,
      append = i > 1
    )
  }

  cli::cli_inform("Creating indices")
  for (column in cmip6_db_columns[-c(1, 2)]) {
    RSQLite::dbExecute(
      con,
      sprintf("CREATE INDEX idx_%s ON catalog(%s)", column, column)
    )
  }

  cli::cli_inform("Done.")
}
