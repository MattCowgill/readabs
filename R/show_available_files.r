#' Helper function to show the files available in a particular catalogue number.
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' To be used in conjunction with \code{download_abs_data_cube()}.
#'
#' This function lists the possible files that are available in a catalogue.
#' The filename (or an unambiguous part of the filename) must be specified
#' as a string as an argument to \code{download_abs_data_cube}.
#'
#' @param catalogue_string character string specifying the catalogue,
#' e.g. "labour-force-australia-detailed".
#' You can use \code{show_available_catalogues()} see all the possible catalogues,
#' or \code{search_catalogues()} to find catalogues that contain a given string.
#'
#' @param refresh logical; `FALSE` by default. If `FALSE`, an internal table
#' of the available ABS catalogues is used. If `TRUE`, this table is refreshed
#' from the ABS website.
#'
#' @details `get_available_files()` is an alias for `show_available_files()`.
#'
#' @return A tibble containing the title of the file, the filename and the complete url.
#'
#' @examples
#' \dontrun{
#' show_available_files("labour-force-australia-detailed")
#' }
#'
#' @importFrom glue glue
#' @importFrom dplyr  %>% filter pull slice tibble
#' @importFrom rvest html_nodes html_attr html_text
#' @importFrom rlang .data
#'
#' @export
#' @family data cube functions

show_available_files <- function(catalogue_string, refresh = FALSE) {
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
  tryCatch(
    {
      temp_page_location <- file.path(tempdir(), "temp_readabs.html")
      dl_file(
        url = download_url,
        destfile = temp_page_location
      )
    },
    error = function(cond) {
      message(paste("URL does not seem to exist:", download_url))
      message("Here's the original error message:")
      message(cond)
      # Choose a return value in case of error
      return(NA)
    }
  )

  download_page <- xml2::read_html(temp_page_location)

  # Find the url for the download

  urls <- download_page %>%
    rvest::html_nodes(".file a") %>%
    rvest::html_attr("href")

  urls <- ifelse(stringi::stri_sub(urls, 2L, 11L) == "statistics",
    paste0("https://www.abs.gov.au", urls),
    urls
  )

  labels <- download_page %>%
    rvest::html_nodes(".file-description-link-left, .abs-data-download-left") %>%
    rvest::html_text()

  # fix for some inconsistent CSS on ABS website
  if (length(labels) != length(urls)) {
    labels <- download_page %>%
      rvest::html_nodes("h4") %>%
      rvest::html_text()
  }

  # fix for anything that doesn't fit the above patterns

  if (length(labels) != length(urls)) {
    labels <- rep(NA, length(urls))
  }


  available_downloads <- dplyr::tibble(
    url = urls,
    label = labels
  ) %>%
    mutate(file = stringi::stri_extract_first_regex(url, "[^/]*$")) %>%
    select("label", "file", "url")

  return(available_downloads)
}

#' @rdname show_available_files
#' @family data cube functions
#' @export

get_available_files <- function(catalogue_string, refresh = FALSE) {
  show_available_files(
    catalogue_string = catalogue_string,
    refresh = refresh
  )
}
