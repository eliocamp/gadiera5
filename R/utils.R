on_gadi <- function() {
  hostname <- system("hostname", intern = TRUE)
  endsWith(hostname, "gadi.nci.org.au")
}


rt52_member <- function() {
  status <- suppressWarnings(system(
    "nci_account -P rt52",
    ignore.stderr = TRUE,
    intern = TRUE
  )) |>
    attr("status")
  status == 0
}


rev_names <- function(x) {
  stats::setNames(names(x), x)
}


as_list_of_files <- function(files) {
  files <- list(files)
  class(files) <- "list_of_files"
  files
}


#' @exportS3Method data.table::format_col
format_col.list_of_files <- function(x, ...) {
  glue::glue("<{lengths(x)} files>")
}
