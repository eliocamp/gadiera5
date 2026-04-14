# Get the "best" grid

This selects the best grid based on preferring regridded data to the
preferred target grid ("gr") and then any other regridding ("gr1/gr2")
and fall back to native grid "gn" if there's no other choice.

## Usage

``` r
cmip6_best_grid(catalogue)
```

## Arguments

- catalogue:

  A catalogue returned by
  [`cmip6()`](https://eliocamp.github.io/gadiera5/reference/cmip6.md)
