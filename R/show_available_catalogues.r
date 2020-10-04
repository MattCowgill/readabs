#' Helper function for \code{download_abs_data_cube} to show the available catalogues.
#'
#' This function lists the possible catalogues that are available on the ABS website.
#' These catalogues must be specified as a string as an argument to \code{download_abs_data_cube}.
#'
#' @param selected_heading optional character string specifying the heading on the \href{https://www.abs.gov.au/statistics}{ABS statistics webpage}.
#' e.g. "Earnings and work hours"
#' @param refresh logical; `FALSE` by default. If `FALSE`, an internal table of the available ABS catalogues is used. If `TRUE`, this table is refreshed from the ABS website.
#'
#' @examples
#' show_available_catalogues("Earnings and work hours")
#' @importFrom dplyr %>% pull filter
#' @importFrom rlang .data
#'
#' @return a character vector of catalogues.
#'
#' @export
#'
show_available_catalogues <- function(selected_heading = NULL, refresh = FALSE) {
  if (isFALSE(is.logical(refresh))) {
    stop("`refresh` must be `TRUE` or `FALSE`.")
  }

  if (isFALSE(refresh)) {
    table_to_use <- abs_lookup_table
  } else {
    table_to_use <- scrape_abs_catalogues()
  }

  if (!is.null(selected_heading)) {
    available_catalogues <- filter(table_to_use, .data$heading == selected_heading)
  } else {
    available_catalogues <- table_to_use
  }

  available_catalogues <- pull(available_catalogues, .data$catalogue)

  return(available_catalogues)
}
