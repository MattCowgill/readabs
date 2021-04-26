
#' @importFrom dplyr filter select "%>%"

get_xml_dfs <- function(urls) {

  xml_files <- tempfile(pattern = as.character(seq_along(urls)),
                        fileext = ".xml")

  purrr::walk2(urls, xml_files,
               ~download.file(url = .x, destfile = .y,
                              mode = "wb", quiet = TRUE,
                              cacheOK = FALSE,
                              headers = readabs_header))

  xml_files %>%
    purrr::map(XML::xmlParse) %>%
    purrr::map_dfr(XML::xmlToDataFrame) %>%
    dplyr::as_tibble() %>%
    dplyr::filter(is.na(text)) %>%
    dplyr::select(-text)

}
