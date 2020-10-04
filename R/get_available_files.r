#' Helper function for \code{download_abs_data_cube} to show the available catalogues.
#'
#' This function lists the possible files that are available in a catalogue.
#' The filename (or an unambiguous part of the filename) must be specified
#' as a string as an argument to \code{download_abs_data_cube}.
#'
#' @param catalogue_string character string specifying the catalogue, e.g. "labour-force-australia-detailed".
#' You can use \code{show_available_catalogues} to find this out.
#' @param refresh logical; `FALSE` by default. If `FALSE`, an internal table
#' of the available ABS catalogues is used. If `TRUE`, this table is refreshed
#' from the ABS website.
#'
#' @return A tibble containing the title of the file, the filename and the complete url.

#'
#' @examples
#' \dontrun{
#' get_available_files("labour-force-australia-detailed")
#' }
#'
#' @importFrom glue glue
#' @importFrom xml2 read_html
#' @importFrom dplyr  %>% filter pull slice
#' @importFrom tibble tibble
#' @importFrom rvest html_nodes html_attr html_text
#' @importFrom stringr str_extract str_replace_all
#' @importFrom rlang .data
#'
#' @export
#'
get_available_files <- function(catalogue_string, refresh = FALSE) {
  if (isFALSE(is.logical(refresh))) {
    stop("`refresh` must be `TRUE` or `FALSE`.")
  }

  if (isFALSE(refresh)) {
    table_to_use <- abs_lookup_table
  } else {
    table_to_use <- scrape_abs_catalogues()
  }

  download_url <- filter(
    table_to_use,
    .data$catalogue == catalogue_string
  ) %>%
    pull(url)

  if (length(download_url) == 0) {
    stop("No matching catalogue. Please check against ABS website.")
  }


  # Try to download the page
  download_page <- tryCatch(
    xml2::read_html(download_url),
    error = function(cond) {
      message(paste("URL does not seem to exist:", download_url))
      message("Here's the original error message:")
      message(cond)
      # Choose a return value in case of error
      return(NA)
    }
  )

  # Find the url for the download
  urls <- download_page %>% rvest::html_nodes(".file a") %>% rvest::html_attr("href")

  labels <- download_page %>% rvest::html_nodes(".abs-data-download-left") %>% rvest::html_text()

  #fix for some inconsistent CSS on ABS website
  if(length(labels) != length(urls)) {labels <- download_page %>% rvest::html_nodes("h4") %>% rvest::html_text()}

  #fix for anything that doesn't fit the above patterns

  if(length(labels) != length(urls)) {labels <- rep(NA, length(urls))}


  available_downloads <- tibble::tibble(url = urls,
                                        label = labels) %>%
    mutate(file = str_extract(url, "[^/]*$")) %>%
    select(.data$label, .data$file, .data$url)

  return(available_downloads)
}
