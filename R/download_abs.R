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

  purrr::walk2(
    .x = urls,
    .y = filenames,
    .f = dl_file,
    quiet = !show_progress_bars
  )

  return(TRUE)
}

dl_file <- function(url, destfile, quiet = TRUE) {
  suppressWarnings(
    utils::download.file(
      url = url,
      destfile = destfile,
      mode = "wb",
      quiet = quiet,
      headers = readabs_header,
      cacheOK = FALSE
    )
  )
}

safely_download_abs <- purrr::safely(download_abs)
