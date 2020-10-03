#' Helper function for \code{download_abs_data_cube} to scrape the available catalogues from the ABS website.
#'
#' This function downloads a new version of the lookup table used by \code{show_available_catalogues}.
#'
#' @return A tibble containing the catalogues and how they are organised on the ABS website.
#'
#'
#' @importFrom glue glue
#' @importFrom xml2 read_html
#' @importFrom dplyr  %>% filter pull slice
#' @importFrom tibble tibble
#' @importFrom rvest html_nodes html_attr html_text
#' @importFrom stringr str_trim str_remove
#' @importFrom purrr map_dfr
#' @importFrom rlang .data
#'

scrape_abs_catalogues <- function() {

  # scrape the main page
  abs_stats_page <- xml2::read_html("https://www.abs.gov.au/statistics")

  main_page_data <- tibble::tibble(
    heading = abs_stats_page %>%
      rvest::html_nodes("h3") %>% rvest::html_text() %>% stringr::str_trim(),
    url_suffix = abs_stats_page %>% rvest::html_nodes(".layout__region--content a") %>% rvest::html_attr("href") %>% stringr::str_trim()
  ) %>%
    filter(grepl("/statistics", .data$url_suffix)) %>%
    filter(.data$heading != "Key economic indicators")

  # scrape each page

  scrape_sub_page <- function(sub_page_url_suffix) {
    main_page_heading <- main_page_data$heading[main_page_data$url_suffix == sub_page_url_suffix]


    sub_page <- xml2::read_html(glue::glue("https://www.abs.gov.au{sub_page_url_suffix}"))

    sub_page_data <- tibble::tibble(
      heading = main_page_heading,
      sub_heading = sub_page %>% rvest::html_nodes(".abs-layout-title") %>% rvest::html_text() %>% str_trim(),
      catalogue = sub_page %>% rvest::html_nodes("#content .card") %>% rvest::html_attr("href") %>%
        stringr::str_remove(sub_page_url_suffix) %>%
        stringr::str_remove("/[^/]*$") %>%
        stringr::str_remove("/"),
      url = glue::glue("https://www.abs.gov.au{sub_page_url_suffix}/{catalogue}/latest-release")
    )
  }


  new_abs_lookup_table <- purrr::map_dfr(main_page_data$url_suffix, scrape_sub_page)

  return(new_abs_lookup_table)
}
