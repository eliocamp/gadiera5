source("R/00-globals.R")

files <- "/g/data/rt52/era5/*/*/*/1960/*196001*" |>
  Sys.glob()


get_longname <- (function(file) {
  nc <- ncdf4::nc_open(file)
  on.exit(ncdf4::nc_close(nc))

  nc$var[[1]]$longname
}) |>
  memoise::memoise()

available <- gsub(pattern = era5_root, replacement = "", files) |>
  unglue::unglue_data(template_dir) |>
  data.table::as.data.table() |>
  _[, file := files] |>
  _[aggregation %in% aggregations] |>
  _[!(level == levels$single_level & variable == "z")] |>
  _[, long_name := get_longname(file), by = file] |>
  _[, .(variable, long_name, level, aggregation)]

usethis::use_data(available, internal = TRUE, overwrite = TRUE)
