
#' @importFrom dplyr filter select "%>%"

get_xml_df <- function(url) {
  text <- NULL

  temp_xml_file <- file.path(tempdir(), "temp_readabs_xml.xml")

  utils::download.file(url,
                       temp_xml_file,
                       quiet = TRUE,
                       cacheOK = FALSE,
                       headers = readabs_header)

  xml_page <- xml2::read_xml(temp_xml_file,
                             encoding = "ISO-8859-1")

  xml_df <- xml_to_df(xml_page)

  if (length(xml_df) == 0) {
    stop(paste0("Couldn't find a valid ABS time series in catalogue number"))
  }

  xml_df
}

xml_to_df <- function(xml) {
  xml_page <- xml2::xml_find_all(xml, "//Series")

  xml_list <- xml2::as_list(xml_page)

  xml_df <- purrr::map(xml_list, dplyr::as_tibble) %>%
    dplyr::bind_rows() %>%
    tidyr::unnest(cols = dplyr::everything())

  xml_df
}
