#' @importFrom purrr walk2

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

    curl::curl_download(
      url = url,
      destfile = filename,
      mode = "wb",
      quiet = !show_progress_bars,
      handle = handle
    )
  }

  handle <- curl::new_handle()
  curl::handle_setheaders(handle,
                          "User-Agent" = readabs_user_agent)

  purrr::walk2(.x = urls,
               .y = filenames,
               .f = dl_file,
               show_progress_bars = show_progress_bars,
               handle = handle)


  return(TRUE)
}
