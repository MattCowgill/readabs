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
#' @importFrom rvest html_nodes html_attr html_text
#' @importFrom purrr map_dfr
#' @importFrom rlang .data
#'

scrape_abs_catalogues <- function() {

  # Scrape the main ABS statistics page
  stats_page_file <- tempfile(fileext = ".html")
  dl_file(
    url = "https://www.abs.gov.au/statistics",
    destfile = stats_page_file
  )

  abs_stats_page <- xml2::read_html(stats_page_file)

  abs_stats_page_cards <- abs_stats_page %>%
    rvest::html_nodes(".layout__region--content .card")

  headings <- abs_stats_page_cards %>%
    rvest::html_elements("h3") %>%
    rvest::html_text() %>%
    stringi::stri_trim_both()

  url_suffixes <- abs_stats_page_cards %>%
    rvest::html_attr("href") %>%
    stringi::stri_trim_both()

  main_page_data <- dplyr::tibble(
    heading = .env$headings,
    url_suffix = .env$url_suffixes
  )

  # scrape each page

  scrape_sub_page <- function(heading, sub_page_url_suffix) {
    sub_page_file <- tempfile(fileext = ".html")
    dl_file(
      url = glue::glue("https://www.abs.gov.au{sub_page_url_suffix}"),
      destfile = sub_page_file
    )

    sub_page <- xml2::read_html(sub_page_file)

    abs_cards <- sub_page %>%
      rvest::html_elements(".clearfix .card")

    sub_heading <- abs_cards %>%
      rvest::html_elements(".abs-layout-title") %>%
      rvest::html_text() %>%
      stringi::stri_trim_both()

    catalogue <- abs_cards %>%
      rvest::html_attr("href") %>%
      stringi::stri_replace_all_fixed(sub_page_url_suffix, "") %>%
      stringi::stri_replace_all_regex("/[^/]*$", "") %>%
      stringi::stri_replace_all_fixed("/", "")

    sub_page_data <- dplyr::tibble(
      heading = heading,
      sub_heading = sub_heading,
      catalogue = catalogue,
      url = glue::glue("https://www.abs.gov.au{sub_page_url_suffix}/{catalogue}/latest-release")
    )
  }


  new_abs_lookup_table <- purrr::map2_dfr(
    .x = main_page_data$heading,
    .y = main_page_data$url_suffix,
    scrape_sub_page
  )

  new_abs_lookup_table %>%
    filter(.data$catalogue != "")
}
