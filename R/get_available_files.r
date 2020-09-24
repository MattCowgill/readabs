#' Helper function for \code{download_abs_data_cube} to show the available catalogues.
#'
#' This function lists the possible files that are available in a catalogue.
#' The filename (or an unambiguous part of the filename) must be specified
#' as a string as an argument to \code{download_abs_data_cube}.
#'
#' @param catalogue_string character string specifying the catalogue, e.g. "labour-force-australia-detailed".
#' You can use \code{show_available_catalogues} to find this out.
#'
#' @return A tibble containing the title of the file, the filename and the complete url.

#'
#' @examples \dontrun{get_available_files("labour-force-australia-detailed")}.
#'
#' This function could also be used with functions from the \code{purrr} package to download multiple files.
#'
#'
#' \dontrun{get_available_files("weekly-payroll-jobs-and-wages-australia") %>%
#'              pull(file) %>%
#'              walk(download_abs_data_cube, catalogue_string = "weekly-payroll-jobs-and-wages-australia")}
#'
#'
#' @importFrom glue glue
#' @importFrom xml2 read_html
#' @importFrom dplyr  %>% filter pull slice
#' @importFrom tibble tibble
#' @importFrom rvest html_nodes html_attr html_text
#' @importFrom stringr str_extract str_replace_all
#'
#'
#' @export
#'
get_available_files <- function(catalogue_string){


  download_url <- filter(abs_lookup_table,
                         catalogue == catalogue_string) %>%
    pull(url)

  if(length(download_url) == 0) {stop(glue("No matching catalogue. Please check against ABS website."))}


  #Try to download the page
  download_page <- tryCatch(
    xml2::read_html(download_url),
    error=function(cond) {
      message(paste("URL does not seem to exist:", download_url))
      message("Here's the original error message:")
      message(cond)
      # Choose a return value in case of error
      return(NA)}
  )

  #Find the url for the download
  available_downloads <- tibble::tibble(label = download_page %>% rvest::html_nodes(".abs-data-download-left") %>% rvest::html_text(),
                                        url = download_page %>% rvest::html_nodes(".file a") %>%  rvest::html_attr("href")) %>%
    mutate(file = str_extract(url, "[^/]*$")) %>%
    select(label, file, url)

  return(available_downloads)

}
