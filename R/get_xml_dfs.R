#' @param urls vector of URLs pointing to XML files
#' @return a tibble
#' @noRd
#' @importFrom dplyr filter select "%>%"

get_xml_dfs <- function(urls) {

  xml_files <- tempfile(pattern = as.character(seq_along(urls)),
                        fileext = ".xml")

  purrr::walk2(urls, xml_files,
               ~dl_file(url = .x,
                        destfile = .y))

  xml_to_df <- function(file) {
    xml_series <- file %>%
      xml2::read_xml() %>%
      xml2::xml_find_all("//Series")

    child_list <- xml_series %>%
      purrr::map(xml2::xml_children)

    xml_names <- child_list %>%
      purrr::pluck(1) %>%
      xml2::xml_name(xml_series)

    child_list %>%
      purrr::map(xml2::xml_text) %>%
      purrr::map_dfr(.f = ~purrr::set_names(.x, xml_names))
  }

  purrr::map_dfr(xml_files, xml_to_df)

}
