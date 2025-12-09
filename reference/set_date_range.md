# Set a date range for an ERA5 catalogue

Adds date range columns to an ERA5 catalogue for filtering data files by
temporal extent. This function is typically used after
[`era5()`](https://eliocamp.github.io/gadiera5/reference/era5.md) and
before
[`get_files()`](https://eliocamp.github.io/gadiera5/reference/get_files.md)
to specify the desired time period for data retrieval.

## Usage

``` r
set_date_range(catalogue, range)
```

## Arguments

- catalogue:

  A data.table containing ERA5 catalogue information, typically obtained
  from
  [`era5()`](https://eliocamp.github.io/gadiera5/reference/era5.md).

- range:

  A date range specification. Can be provided in multiple formats:

  - A Date object or POSIXct/POSIXlt datetime object (length 2 vector
    for start and end)

  - A character vector with ISO format dates:
    `c("2020-01-01", "2020-12-31")`

  - A character vector with year only: `c("2020", "2021")`
    (automatically expands to full year)

  - A character vector with year-month: `c("2020-01", "2020-06")`
    (expands to first/last day of month)

## Value

A copy of the input catalogue with two additional columns:

- `range_start`: Start date of the requested range (Date class)

- `range_end`: End date of the requested range (Date class)

## Examples

``` r
if (FALSE) { # \dontrun{
# Set date range with full dates
catalogue <- era5() |>
  set_date_range(c("2020-01-01", "2020-12-31"))

# Set date range with years only
catalogue <- era5() |>
  set_date_range(c("2020", "2021"))

# Set date range with year-month
catalogue <- era5() |>
  set_date_range(c("2020-06", "2020-08"))

# Use Date objects
catalogue <- era5() |>
  set_date_range(c(as.Date("2020-01-01"), as.Date("2020-12-31")))
} # }
```
