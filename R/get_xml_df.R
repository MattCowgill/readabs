
#' @importFrom utils download.file
#' @importFrom dplyr filter select "%>%"

get_xml_df <- function(url) {
  text <- NULL

  xml_page <- xml2::read_xml(url, encoding = "ISO-8859-1")

  xml_page <- xml2::xml_find_all(xml_page, "//Series")

  xml_list <- xml2::as_list(xml_page)

  xml_df <- purrr::map(xml_list, dplyr::as_tibble) %>%
    dplyr::bind_rows() %>%
    tidyr::unnest(cols = dplyr::everything())

  if (length(xml_df) == 0) {
    stop(paste0("Couldn't find a valid ABS time series in catalogue number"))
  }

  xml_df
}
