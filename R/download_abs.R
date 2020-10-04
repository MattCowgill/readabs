#' @importFrom utils download.file
#' @importFrom purrr walk2

download_abs <- function(urls,
                         path,
                         show_progress_bars = TRUE) {

  # create a subdirectory of the working directory with value given by
  # the path argument and define the filename that will be given to the
  # downloaded table
  dir.create(path = path, recursive = TRUE, showWarnings = FALSE)

  filenames <- file.path(path, basename(urls))

  # if libcurl is available we can vectorise urls and destfile to download
  # files simultaneously; if not, we have to iterate
  if (isTRUE(capabilities("libcurl"))) {
    utils::download.file(
      url = urls,
      mode = "wb",
      quiet = !show_progress_bars,
      destfile = filenames,
      method = "libcurl",
      cacheOK = FALSE
    )
  } else {
    purrr::walk2(
      .x = urls,
      .y = filenames,
      .f = utils::download.file,
      mode = "wb",
      quiet = !show_progress_bars,
      cacheOK = FALSE
    )
  }

  return(TRUE)
}
