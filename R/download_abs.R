#' @importFrom utils download.file

download_abs <- function(url,
                         path,
                         show_progress_bars = TRUE) {

  # create a subdirectory of the working directory with value given by
  # the path argument and define the filename that will be given to the
  # downloaded table
  dir.create(path = path, recursive = TRUE, showWarnings = FALSE)

  filename <- file.path(path, basename(url))

  # download the table
  utils::download.file(url = url,
                mode = "wb",
                quiet = !show_progress_bars,
                destfile = filename,
                cacheOK = FALSE)
}
