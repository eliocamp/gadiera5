
<!-- README.md is generated from README.Rmd. Please edit that file -->

# gadiera5

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/gadiera5)](https://CRAN.R-project.org/package=gadiera5)
<!-- badges: end -->

The goal of gadiera5 is to list ERA5 files stored in on gadi.

## Installation

You can install the development version of gadiera5 like so:

``` r
pak::pak("eliocamp/gadiera5")
```

## Example

The `era5()` function is the main entry point. It returns a data.table
with information of all available variables and their aggregation level,
as well as a description. This data.table can then be filtered and
subsetted as usual.

``` r
library(gadiera5)

(temp_2metres <- era5() |>
  _[variable == "2t" & aggregation == "monthly-averaged"])
#>    variable           long_name         level      aggregation
#>      <char>              <char>        <char>           <char>
#> 1:       2t 2 metre temperature single-levels monthly-averaged
```

The `set_date_range()` function sets the dates of dates of interest. The
range can be specified as full dates but setting year-month or just year
is also supported.

``` r
temp_2metres |>
  set_date_range(c("2020-01-03", "2022-03-15"))
#>    variable           long_name         level      aggregation range_start
#>      <char>              <char>        <char>           <char>      <Date>
#> 1:       2t 2 metre temperature single-levels monthly-averaged  2020-01-03
#>     range_end
#>        <Date>
#> 1: 2022-03-15
```

``` r
temp_2metres |>
  set_date_range(c("2020-01", "2022-03"))
#>    variable           long_name         level      aggregation range_start
#>      <char>              <char>        <char>           <char>      <Date>
#> 1:       2t 2 metre temperature single-levels monthly-averaged  2020-01-01
#>     range_end
#>        <Date>
#> 1: 2022-03-31
```

``` r
(temp_2metres <- temp_2metres |>
  set_date_range(c(2020, 2022)))
#>    variable           long_name         level      aggregation range_start
#>      <char>              <char>        <char>           <char>      <Date>
#> 1:       2t 2 metre temperature single-levels monthly-averaged  2020-01-01
#>     range_end
#>        <Date>
#> 1: 2022-12-31
```

Finally, use `get_files()` to retrieve all the files. The return is a
data.table with a list column called `files`.

``` r
temp_2metres |>
  get_files()
#>    variable      aggregation range_start  range_end           files
#>      <char>           <char>      <Date>     <Date> <list_of_files>
#> 1:       2t monthly-averaged  2020-01-01 2022-12-31      <36 files>
```
