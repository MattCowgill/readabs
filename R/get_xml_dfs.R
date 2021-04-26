
#' @importFrom dplyr filter select "%>%"

get_xml_dfs <- function(urls) {

  xml_pages <- purrr::map(urls,
                          ~xml2::read_xml(file(.x),
                                          encoding = "ISO-8859-1",
                                          headers = readabs_header))

  xml_pages <- purrr::map(xml_pages, xml2::xml_find_all,
                          xpath = "//Series")

  xml_df <- xml_pages %>%
    purrr::map_dfr(xml2::as_list) %>%
    tidyr::unnest(cols = dplyr::everything())

  xml_df
}
