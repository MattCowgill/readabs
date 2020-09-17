#' @importFrom utils download.file

download_abs <- function(urls,
                         path,
                         show_progress_bars = TRUE) {

  # create a subdirectory of the working directory with value given by
  # the path argument and define the filename that will be given to the
  # downloaded table
  dir.create(path = path, recursive = TRUE, showWarnings = FALSE)

  filenames <- file.path(path, basename(urls))

  # download the table
  utils::download.file(url = urls,
                mode = "wb",
                quiet = !show_progress_bars,
                destfile = filenames,
                cacheOK = FALSE)
}

