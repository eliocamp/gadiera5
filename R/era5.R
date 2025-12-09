#' Return ERA5 catalogue
#'
#' @export
era5 <- function() {
  rt52 <- file.exists(era5_root)

  if (!rt52) {
    if (!on_gadi()) {
      cli::cli_abort(
        "Cannot find era5 root folder. The gadiera5 package is designed to work on gadi."
      )
    }

    if (!rt52_member()) {
      cli::cli_abort(
        c(
          "Cannot find era5 root folder.",
          i = "Make sure you are a member of the rt52 by going to https://my.nci.org.au/mancini/project/rt52"
        )
      )
    }

    cli::cli_abort(
      c(
        "Cannot find era5 root folder.",
        i = "If you are running this from the pbs queue, make sure add #PBS -l storage=gdata/rt52 to your script."
      )
    )
  }

  available
}

#' Get all the files defined by a caralogue
#'
#'
#' @export
get_files <- function(catalogue) {
  catalogue <- data.table::copy(catalogue)

  catalogue[, let(
    source = "*",
    level_short = levels_short[rev_names(levels)[level]]
  )]

  dates <- catalogue[,
    .(date_start = dates_from_range(c(range_start, range_end))),
    by = .(range_start, range_end)
  ]

  catalogue <- catalogue[
    dates,
    on = c("range_start", "range_end"),
    allow.cartesian = TRUE
  ]

  catalogue[, let(
    date_end = "*",
    year = data.table::year(date_start),
    date_start = format(date_start, "%Y%m%d")
  )]

  catalogue$file <- glue::glue_data(catalogue, template_file)
  catalogue$glob <- glue::glue_data(
    catalogue,
    file.path(era5_root, template_dir)
  )

  catalogue[, file := glob_file(glob)]

  catalogue[,
    .(files = as_list_of_files(file)),
    by = .(variable, aggregation, range_start, range_end)
  ]
}

glob_file <- function(globs) {
  vapply(
    globs,
    \(glob) {
      file <- Sys.glob(glob)
      if (length(file) > 1) {
        stop("more than one file")
      }
      if (length(file) < 1) {
        file <- NA_character_
      }
      file
    },
    character(1)
  )
}

get_variable_range <- function(var, agg) {
  ranges <- date_range(variable_files(var, agg))
  c(min(ranges[[1]]), max(ranges[[2]]))
}

zeropad2 <- function(x) {
  formatC(x, width = 2, flag = "0")
}

dates_from_range <- function(range) {
  first <- paste(
    data.table::year(range[1]),
    zeropad2(data.table::month(range[1])),
    "01",
    sep = "-"
  )

  dates <- seq(as.Date(first), range[2], "month")

  dates
}

variable_files <- function(var, agg, dates) {
  metadata <- available[variable == var & aggregation == agg]
  metadata
  metadata$year <- data.table::year(dates)
  metadata$file <- "*"

  file.path(era5_root, glue::glue_data(metadata, template_dir)) |>
    Sys.glob()
}

.datatable.aware <- TRUE
