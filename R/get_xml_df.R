
#' @importFrom utils download.file
#' @importFrom dplyr filter select "%>%"

get_xml_df <- function(url) {

  text = NULL

  xml_page <- xml2::read_xml(url, encoding = "latin-1")

  xml_page <- xml2::xml_find_all(xml_page, "//Series")

  xml_list <- xml2::as_list(xml_page)

  xml_df <- purrr::map(xml_list, dplyr::as_tibble) %>%
    dplyr::bind_rows() %>%
    tidyr::unnest(cols = dplyr::everything())

  if (length(xml_df) == 0) {
    stop(paste0("Couldn't find a valid ABS time series in catalogue number"))
  }

  # if metadata has > 1 page (almost all do), xml_df will contain a text column;
  # if metadata has 1 page, it won't have a text column.
  # We want to drop it if present.
  # if (!is.null(xml_df$text) ) {
  #   xml_df <- xml_df %>%
  #     dplyr::filter(is.na(text)) %>%
  #     dplyr::select(-text)
  # }

  xml_df
}
