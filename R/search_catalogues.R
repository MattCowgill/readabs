#' Search for ABS catalogues that match a string
#' @description
#' `r lifecycle::badge("experimental")`
#' Helper function to use with `download_abs_data_cube()`.
#'
#' `download_abs_data_cube()` requires that you specify a `catalogue`.
#' `search_catalogues()` helps you find the catalogue you want, by searching for
#' a given string in the catalogue names, product title, and broad topic.
#'
#' @param string Character. A word or phrase you want to search for, such as "labour" or
#' "union". Not case sensitive.
#' @param refresh Logical. `FALSE` by default. If `TRUE`, will re-scrape the ABS
#' website to ensure that the list of catalogues is up-to-date.
#'
#' @return A data frame (tibble) containing the topic (`heading`), product title
#' (`sub_heading`), catalogue (`catalogue`) and URL (`URL`) of any catalogues
#' that match the provided string.
#' @examples
#'
#' search_catalogues("labour")
#' @export
#' @family data cube functions

search_catalogues <- function(string, refresh = FALSE) {
  stopifnot(!missing(string))

  if (isFALSE(refresh)) {
    df <- abs_lookup_table
  } else {
    df <- scrape_abs_catalogues()
  }

  # Using dplyr::if_any() is fast and clean but requires dplyr >= 1.0.4
  if (getNamespaceVersion("dplyr") > "1.0.4") {
    out <- df %>%
      dplyr::filter(dplyr::if_any(
        .cols = dplyr::everything(),
        ~ grepl(string, .x,
          perl = TRUE, ignore.case = TRUE
        )
      ))
  } else {
    matches <- purrr::map_dfr(df,
      grepl,
      pattern = string, perl = TRUE, ignore.case = TRUE
    ) %>%
      rowSums()

    out <- dplyr::tibble(sum_true = matches) %>%
      dplyr::bind_cols(df) %>%
      dplyr::filter(.data$sum_true >= 1) %>%
      dplyr::select(-"sum_true")
  }

  out <- out %>%
    dplyr::mutate(url = as.character(url))

  return(out)
}
