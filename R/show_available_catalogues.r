#' Helper function for \code{download_abs_data_cube} to show the available catalogues.
#'
#' This function lists the possible catalogues that are available on the ABS website.
#' These catalogues must be specified as a string as an argument to \code{download_abs_data_cube}.
#'
#' @param selected_heading optional character string specifying the heading on the \link{https://www.abs.gov.au/statistics} webpage.
#' e.g. "Earnings and work hours"
#'
#'
#' @examples \dontrun{show_available_catalogues("Earnings and work hours")}
#'
#' @importFrom dplyr %>% pull filter
#'
#' @return a character vector of catalogues.
#'
#' @export
#'
show_available_catalogues <- function(selected_heading = NULL){

  if(!is.null(selected_heading)) {
    available_catalogues <-   filter(abs_lookup_table, heading == selected_heading)
  } else { available_catalogues  <- abs_lookup_table}

  available_catalogues <- pull(available_catalogues, catalogue)

  return(available_catalogues)

}



