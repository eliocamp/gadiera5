#' Get ERA5 data catalogue
#'
#' Returns a catalogue of available ERA5 reanalysis data on gadi. The catalogue
#' contains information about all available variables, their temporal aggregations
#' (hourly or monthly), and vertical levels (single-level or pressure-level).
#'
#' @return A data.table with the following columns:
#'   * `variable`: ERA5 variable short name (e.g., "2t" for 2-meter temperature)
#'   * `long_name`: Descriptive name of the variable
#'   * `level`: Vertical level type ("single-levels" or "pressure-levels")
#'   * `aggregation`: Temporal aggregation ("reanalysis" for hourly, "monthly-averaged" for monthly)
#'
#' @details
#' The catalogue can be filtered using standard data.table operations and combined
#' with [set_date_range()] and [get_files()] to retrieve specific data files.
#'
#' @examples
#' \dontrun{
#' # Get full catalogue
#' catalogue <- era5()
#'
#' # Filter for specific variable
#' temp_data <- era5() |>
#'   subset(variable == "2t")
#'
#' # Search for variables using "geopotential"
#' geopotential <- era5() |>
#'   subset(grepl("geopotential", long_name, ignore.case = TRUE))
#'
#' # Filter for monthly single-level data
#' monthly_sfc <- era5() |>
#'   subset(aggregation == "monthly-averaged" & level == "single-levels")
#' }
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

#' Get all the files defined by a catalogue
#'
#' This function takes a catalogue of ERA5 data (typically obtained from [era5()]
#' and filtered with [set_date_range()]) and returns the corresponding file paths
#' on gadi's filesystem.
#'
#' @param catalogue A data.table containing ERA5 catalogue information.
#'   Typically obtained by subsetting the output of [era5()] and applying [set_date_range()].
#'
#' @return A data.table with columns:
#'   * `variable`: The ERA5 variable name
#'   * `aggregation`: The temporal aggregation (e.g., "monthly", "hourly")
#'   * `range_start`: Start date of the requested range
#'   * `range_end`: End date of the requested range
#'   * `files`: A list column containing character vectors of file paths for each
#'     combination of variable, aggregation, and date range. Files that don't exist
#'     will be `NA`.
#'
#' @examples
#' \dontrun{
#' # Get catalogue and filter for specific variable and dates
#' catalogue <- era5() |>
#'   subset(variable == "2t") |>
#'   set_date_range("2020-01-01", "2020-12-31") |>
#'   get_files(catalogue)
#' }
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
