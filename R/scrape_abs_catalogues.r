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

  # scrape the main page
  abs_stats_page <- xml2::read_html("https://www.abs.gov.au/statistics",
                                    user_agent = readabs_user_agent)

  main_page_data <- dplyr::tibble(
    heading = abs_stats_page %>% rvest::html_nodes(".field--type-ds h3") %>% rvest::html_text() %>% stringi::stri_trim_both(),
    url_suffix = abs_stats_page %>% rvest::html_nodes(".card") %>% rvest::html_attr("href") %>% stringi::stri_trim_both()
  )

  # scrape each page

  scrape_sub_page <- function(sub_page_url_suffix) {
    main_page_heading <- main_page_data$heading[main_page_data$url_suffix == sub_page_url_suffix]


    sub_page <- xml2::read_html(glue::glue("https://www.abs.gov.au{sub_page_url_suffix}"),
                                user_agent = readabs_user_agent)

    sub_page_data <- dplyr::tibble(
      heading = main_page_heading,
      sub_heading = sub_page %>% rvest::html_nodes(".abs-layout-title") %>% rvest::html_text() %>% stringi::stri_trim_both(),
      catalogue = sub_page %>% rvest::html_nodes("#content .card") %>% rvest::html_attr("href") %>%
        stringi::stri_replace_all_fixed(sub_page_url_suffix, "") %>%
        stringi::stri_replace_all_regex("/[^/]*$", "") %>%
        stringi::stri_replace_all_fixed("/", ""),
      url = glue::glue("https://www.abs.gov.au{sub_page_url_suffix}/{catalogue}/latest-release")
    )
  }


  new_abs_lookup_table <- purrr::map_dfr(main_page_data$url_suffix, scrape_sub_page)

  return(new_abs_lookup_table)
}
