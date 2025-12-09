#' Set a date range for an ERA5 catalogue
#'
#' Adds date range columns to an ERA5 catalogue for filtering data files by temporal extent.
#' This function is typically used after [era5()] and before [get_files()] to specify the
#' desired time period for data retrieval.
#'
#' @param catalogue A data.table containing ERA5 catalogue information, typically obtained
#'   from [era5()].
#' @param range A date range specification. Can be provided in multiple formats:
#'   * A Date object or POSIXct/POSIXlt datetime object (length 2 vector for start and end)
#'   * A character vector with ISO format dates: `c("2020-01-01", "2020-12-31")`
#'   * A character vector with year only: `c("2020", "2021")` (automatically expands to full year)
#'   * A character vector with year-month: `c("2020-01", "2020-06")` (expands to first/last day of month)
#'
#' @return A copy of the input catalogue with two additional columns:
#'   * `range_start`: Start date of the requested range (Date class)
#'   * `range_end`: End date of the requested range (Date class)
#'
#' @examples
#' \dontrun{
#' # Set date range with full dates
#' catalogue <- era5() |>
#'   set_date_range(c("2020-01-01", "2020-12-31"))
#'
#' # Set date range with years only
#' catalogue <- era5() |>
#'   set_date_range(c("2020", "2021"))
#'
#' # Set date range with year-month
#' catalogue <- era5() |>
#'   set_date_range(c("2020-06", "2020-08"))
#'
#' # Use Date objects
#' catalogue <- era5() |>
#'   set_date_range(c(as.Date("2020-01-01"), as.Date("2020-12-31")))
#' }
#'
#' @export
set_date_range <- function(catalogue, range) {
  catalogue <- data.table::copy(catalogue)

  range <- parse_range(range)
  catalogue[,
    c("range_start", "range_end") := list(rep(range[1], .N), rep(range[2], .N))
  ][]
}

date_range <- function(file) {
  metadata <- unglue::unglue_data(basename(file), template_file)

  list(
    as.Date(metadata$date_start, format = "%Y%m%d"),
    as.Date(metadata$date_end, format = "%Y%m%d")
  )
}

in_date <- function(range, date_start, date_end) {
  # Discard if final date is earlier than earliest range
  # or if the initial date is later than the latest range
  !(date_end < range[1] | date_start > range[2])
}


is_dateish <- function(x) {
  inherits(x, "Date") | inherits(x, "POSIXct") | inherits(x, "POSIXlt")
}

parse_range <- function(x) {
  if (is_dateish(x)) {
    return(x)
  }

  x <- x |>
    as.character() |>
    strsplit("-") |>
    lapply(as.numeric)

  # Support for inputting year
  if (length(x[[1]]) == 1) {
    x[[1]][[2]] <- 1
    x[[1]][[3]] <- 1
  }

  if (length(x[[2]]) == 1) {
    x[[2]][[2]] <- 12
    x[[2]][[3]] <- 31
  }

  # Support for year-month
  if (length(x[[1]]) == 2) {
    x[[1]][[3]] <- 1
  }

  if (length(x[[2]]) == 2) {
    # Need to convert the month into date to correctly
    # account for leap years
    days <- paste0(c(x[[2]], 1), collapse = "-") |>
      as.Date() |>
      days_in_month()

    x[[2]][[3]] <- days
  }

  x |>
    vapply(\(x) paste0(x, collapse = "-"), character(1)) |>
    as.Date()
}

# from lubridate
leap_year <- function(date) {
  if (is.numeric(date)) {
    year <- date
  } else {
    year <- data.table::year(date)
  }
  (year %% 4 == 0) & ((year %% 100 != 0) | (year %% 400 == 0))
}

N_DAYS_IN_MONTHS <- c(
  Jan = 31L,
  Feb = 28L,
  Mar = 31L,
  Apr = 30L,
  May = 31L,
  Jun = 30L,
  Jul = 31L,
  Aug = 31L,
  Sep = 30L,
  Oct = 31L,
  Nov = 30L,
  Dec = 31L
)

days_in_month <- function(x) {
  month_x <- data.table::month(x)
  n_days <- N_DAYS_IN_MONTHS[month_x]
  n_days[month_x == "Feb" & leap_year(x)] <- 29L
  n_days
}
