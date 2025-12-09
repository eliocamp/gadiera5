#| @export
era5 <- function() {
  available
}

#| @export
get_files <- function(dt) {
  dt[,
    .(file = variable_files(variable, aggregation)),
    by = .(variable, aggregation)
  ]
}


variable_files <- function(var, agg) {
  metadata <- av[variable == var & aggregation == agg]
  metadata$year <- "*"
  metadata$file <- "*"

  file.path(era_root, glue::glue_data(metadata, template_dir)) |>
    Sys.glob()
}
