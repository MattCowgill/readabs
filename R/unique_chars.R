#' Show the unique values of character columns
#'
#' A handy companion function for \code{read_abs_api}. Pass the results of an API
#' call to this and this will show you all the unique levels for all character
#' columns. Useful to inform filtering, plotting, etc.
#'
#' @param .data a \code{tibble}
#'
#' @return a \code{list} where each element is a single column \code{tibble},
#'   referring to a character column of \code{.data}, and contains the unique
#'   values
#' @export
#'
#' @examples
#' \dontrun{
#' new_url <- paste0("https://api.data.abs.gov.au/data/ALC/",
#'   "all?startPeriod=2010&endPeriod=2016&format=jsondata",
#'   "&dimensionAtObservation=AllDimensions")
#'
#' tidy_data <- read_abs_api(new_url)
#' unique_chars(tidy_data)
#' }
unique_chars <- function(.data) {
  .data %>%
    dplyr::select(tidyselect::vars_select_helpers$where(is.character)) %>%
    names() %>%
    purrr::map(~unique(.data[.]))
}
