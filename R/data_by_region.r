#' Get the Data by Region URL
#'
#' This URL is such a pain to get into R, I thought it would be easier to just write a helper function. It reads the 25,000 character Data by Region URL from a text file into R, and allows the user to set the start and end years. By default it will just set to last year.
#'
#' @param start (\code{numeric}; default = \code{NULL})
#' @param end (\code{numeric}; default = \code{NULL})
#'
#' @export
#'
#' @return (\code{character}) a query URL for Data by Region
#'
data_by_region <- function(start = NULL, end = NULL) {
    raw <- system.file(
        file.path("data_by_region", "dbr.txt"),
        package = "readabs"
    ) %>%
        readLines()

    last_year <- format(Sys.Date() - 365, "%Y")
    start <- start %||% last_year
    end <- end %||% last_year
    stopifnot(as.numeric(start) <= as.numeric(end))
    raw %>%
        stringi::stri_replace_first_fixed("THESTART", start) %>%
        stringi::stri_replace_first_fixed("THEEND", end)
}
