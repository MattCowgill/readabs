
download_abs <- function(urls,
                         path,
                         show_progress_bars = TRUE) {

  # create a subdirectory of the working directory with value given by
  # the path argument and define the filename that will be given to the
  # downloaded table
  if (!dir.exists(path)) {
    dir.create(path = path, recursive = TRUE, showWarnings = FALSE)
  }

  filenames <- file.path(path, basename(urls))

  dl_file <- function(url, filename, show_progress_bars, handle) {
    if (show_progress_bars) {
      message("Downloading ", url)
    }

    utils::download.file(
      url = url,
      destfile = filename,
      mode = "wb",
      quiet = !show_progress_bars,
      headers = readabs_header,
      cacheOK = FALSE
    )
  }

  purrr::walk2(.x = urls,
               .y = filenames,
               .f = dl_file,
               show_progress_bars = show_progress_bars)

  return(TRUE)
}
