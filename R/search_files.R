#' Search for a file within an ABS catalogue
#'
#' @param string String to search for among filenames in a catalogue
#' @param catalogue Name of catalogue
#' @param refresh logical; `FALSE` by default. When `TRUE`, will re-scrape the
#' list of files within the catalogue.
#' @export
#' @examples
#' search_files("GM1", "labour-force-australia")

search_files <- function(string, catalogue, refresh = FALSE) {
  files <- show_available_files(catalogue_string = catalogue,
                                refresh = refresh)

  # Using dplyr::if_any() is fast and clean but requires dplyr >= 1.0.4
  if (getNamespaceVersion("dplyr") > "1.0.4") {
    out <- files %>%
      dplyr::filter(dplyr::if_any(.cols = dplyr::everything(),
                                  ~grepl(string, .x,
                                         perl = TRUE, ignore.case = TRUE)))

  } else {
    matches <- purrr::map_dfr(files,
                              grepl,
                              pattern = string, perl = TRUE, ignore.case = TRUE) %>%
      rowSums()

    out <- dplyr::tibble(sum_true = matches) %>%
      dplyr::bind_cols(files) %>%
      dplyr::filter(.data$sum_true >= 1) %>%
      dplyr::select(-.data$sum_true)
  }

  out <- out %>%
    dplyr::mutate(url = as.character(url)) %>%
    dplyr::pull(file)

  return(out)


}
