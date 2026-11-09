# Get all the files defined by a catalogue

This function takes a catalogue of ERA5 data (typically obtained from
[`era5()`](https://eliocamp.github.io/gadiera5/reference/era5.md) and
filtered with
[`set_date_range()`](https://eliocamp.github.io/gadiera5/reference/set_date_range.md))
and returns the corresponding file paths on gadi's filesystem.

## Usage

``` r
get_files(catalogue, version = "best")
```

## Arguments

- catalogue:

  A data.table containing ERA5 catalogue information. Typically obtained
  by subsetting the output of
  [`era5()`](https://eliocamp.github.io/gadiera5/reference/era5.md) and
  applying
  [`set_date_range()`](https://eliocamp.github.io/gadiera5/reference/set_date_range.md).

- version:

  A string with the version to use. The default ("best"), chooses ERA5.1
  over ERA5 when the latter has available files. This [mainly affects
  variables in the stratosphere and upper troposphere between 2000 and
  2006](https://www.ecmwf.int/en/elibrary/81149-global-stratospheric-temperature-bias-and-other-stratospheric-aspects-era5-and).
  To restrict search to a particular version, use "era5" or "era5.1".

## Value

A data.table with columns:

- `variable`: The ERA5 variable name

- `aggregation`: The temporal aggregation (e.g., "monthly", "hourly")

- `range_start`: Start date of the requested range

- `range_end`: End date of the requested range

- `range_id`: ID of the date rang (it will be added if `catalogue`
  doesn't have one)

- `files`: A list column containing character vectors of file paths for
  each combination of variable, aggregation, and date range. Files that
  don't exist will be `NA`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get catalogue and filter for specific variable and dates
catalogue <- era5() |>
  subset(variable == "v") |>
  set_date_range(c("1999-01-01", "2000-12-31")) |>
  get_files()
} # }
```
