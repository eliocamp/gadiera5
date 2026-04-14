# Quick filters

Quick filters

## Usage

``` r
cmip6_latest(catalogue)

cmip6_best_grid(catalogue)
```

## Arguments

- catalogue:

  A catalogue returned by
  [`cmip6()`](https://eliocamp.github.io/gadiera5/reference/cmip6.md)

## Details

`cmip6_latest()` reutrns the latest version of each file.
`cmip6_best_grid()` returns the "best" grid based on preferring data
regridded to the preferred target grid ("gr") and then any other
regridding ("gr1/gr2") and fall back to native grid "gn" if there's no
other choice.

These functions ignore the `grid_label` and `version` columns
respectively. If there are multiple versions with different grids each,
`cmip6_latest()` will return the latest version irrespective of grid and
`cmip6_best_grid()` will return the best grid irrespective of version.
This means that the this functions are *not* conmutative.
