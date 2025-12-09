era_root <- "/g/data/rt52/era5/"
aggregations <- list(hourly = "reanalysis", monthly = "monthly-averaged")
levels <- list(
  single_level = "single-levels",
  pressure_level = "pressure-levels"
)

template_dir <- "{level}/{aggregation}/{variable}/{year}/{file}"

template_file <- "{variable}_era5_{source}_{level_short}_{date_start}-{date_end}.nc"
