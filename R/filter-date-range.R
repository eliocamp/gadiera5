#| @export
filter_date_range <- function(catalogue, range) {
  range <- parse_range(range)

  catalogue[, c("date_start", "date_end") := date_range(file)]

  if (is.na(range[1])) {
    range[1] <- min(catalogue$date_start)
  }

  if (is.na(range[2])) {
    range[2] <- max(catalogue$date_start)
  }

  catalogue[in_date(range(range), date_start, date_end)] |>
    _[, let(date_start = NULL, date_end = NULL)] |>
    _[]
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
      lubridate::days_in_month()

    x[[2]][[3]] <- days
  }

  x |>
    vapply(\(x) paste0(x, collapse = "-"), character(1)) |>
    as.Date()
}
