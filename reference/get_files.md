# Get all the files defined by a catalogue

This function takes a catalogue of ERA5 data (typically obtained from
[`era5()`](https://eliocamp.github.io/gadiera5/reference/era5.md) and
filtered with
[`set_date_range()`](https://eliocamp.github.io/gadiera5/reference/set_date_range.md))
and returns the corresponding file paths on gadi's filesystem.

## Usage

``` r
get_files(catalogue)
```

## Arguments

- catalogue:

  A data.table containing ERA5 catalogue information. Typically obtained
  by subsetting the output of
  [`era5()`](https://eliocamp.github.io/gadiera5/reference/era5.md) and
  applying
  [`set_date_range()`](https://eliocamp.github.io/gadiera5/reference/set_date_range.md).

## Value

A data.table with columns:

- `variable`: The ERA5 variable name

- `aggregation`: The temporal aggregation (e.g., "monthly", "hourly")

- `range_start`: Start date of the requested range

- `range_end`: End date of the requested range

- `files`: A list column containing character vectors of file paths for
  each combination of variable, aggregation, and date range. Files that
  don't exist will be `NA`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get catalogue and filter for specific variable and dates
catalogue <- era5() |>
  subset(variable == "2t") |>
  set_date_range("2020-01-01", "2020-12-31") |>
  get_files(catalogue)
} # }
```
