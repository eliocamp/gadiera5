# Get ERA5 data catalogue

Returns a catalogue of available ERA5 reanalysis data on gadi. The
catalogue contains information about all available variables, their
temporal aggregations (hourly or monthly), and vertical levels
(single-level or pressure-level).

## Usage

``` r
era5()
```

## Value

A data.table with the following columns:

- `variable`: ERA5 variable short name (e.g., "2t" for 2-meter
  temperature)

- `long_name`: Descriptive name of the variable

- `level`: Vertical level type ("single-levels" or "pressure-levels")

- `aggregation`: Temporal aggregation ("reanalysis" for hourly,
  "monthly-averaged" for monthly)

## Details

The catalogue can be filtered using standard data.table operations and
combined with
[`set_date_range()`](https://eliocamp.github.io/gadiera5/reference/set_date_range.md)
and
[`get_files()`](https://eliocamp.github.io/gadiera5/reference/get_files.md)
to retrieve specific data files.

## Examples

``` r
if (FALSE) { # \dontrun{
# Get full catalogue
catalogue <- era5()

# Filter for specific variable
temp_data <- era5() |>
  subset(variable == "2t")

# Search for variables using "geopotential"
geopotential <- era5() |>
  subset(grepl("geopotential", long_name, ignore.case = TRUE))

# Filter for monthly single-level data
monthly_sfc <- era5() |>
  subset(aggregation == "monthly-averaged" & level == "single-levels")
} # }
```
