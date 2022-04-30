#' Get tidy data from ABS' API
#'
#' This function returns a tidy \code{tibble} of data queried from the
#' \href{https://explore.data.abs.gov.au/}{ABS' API}. If the \code{query_url} is
#' too big the API to work (which happens sometimes), you may need to use this
#' function in conjunction with \code{\link{chunk_query_url}} and vectorisation
#' to query the API (see below for a simple example, with more information in
#' the vignette).
#'
#' See the vignette for a detailed guide on how to use this to get monthly
#' labour force data or download the last decade of Data by Region at SA2.
#'
#' @param query_url (character) the 'Data query' URL from the 'Developer API'
#'   section from the \href{https://explore.data.abs.gov.au/}{ABS' API}. I'm not
#'   sure what the difference between 'Flat' and 'Time series' is, because even
#'   though the URLs are different they return the same data.
#' @param structure_url (character; default = \code{NULL}) the 'Structure query'
#'   URL from the same place. This provides the information for the data
#'   dictionary. If \code{NULL} it will be guessed from \code{query_url}.
#' @param verbose (logical; default = \code{TRUE}) print status update messages?
#' @param check (logical; default = \code{TRUE}) check the URL can be queried?
#'   Some URLs are too long to be queried, so this can provide some advice on
#'   how to deal with them (at the expense of speed).
#'
#' @return (\code{tibble}) Returns a tidy \code{tibble} containing the ABS data
#'   you queried. Each \code{tibble} returns a column \code{value} along with a
#'   series of pairs of other columns for the metadata (ear pair is suffixed
#'   \code{_code} and \code{_name}). The \code{_code} column shows the encoded
#'   value (e.g. \code{sex_code} might show a value of \code{3}), and the
#'   \code{_name} shows a human interpretable translation of \code{_code} (e.g.
#'   \code{sex_name} would show \code{Persons}).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # A simple URL
#'
#' # Labour force data query URL, taken from ABS API site
#' # (In `paste0()` to prevent help docs being truncated)
#' lf_url <- paste0("https://api.data.abs.gov.au/data/ABS,LF,1.0.0/",
#'                  "M9.3.1599.30+10+20.AUS.M?startPeriod=2021-01&",
#'                  "endPeriod=2021-12&dimensionAtObservation=AllDimensions")
#'
#' lf <- read_abs_api(lf_url)
#'
#'
#'
#' # A URL that might need breaking up (note the different start date)
#' # (this URL doesn't actually need breaking up but it is a good example)
#'
#' lf_url2 <- paste0("https://api.data.abs.gov.au/data/ABS,LF,1.0.0/",
#'                   "M9.3.1599.30+10+20.AUS.M?startPeriod=1978-01&",
#'                   "endPeriod=2021-12&dimensionAtObservation=AllDimensions")
#'
#' lf_urls <- chunk_query_url(lf_url2)
#' read_api_safely <- purrr::safely(read_abs_api)
#' lf_raw <- purrr::map(lf_urls, read_api_safely)
#' lf_data <- purrr::map_dfr(lf_raw, "result")
#' }
read_abs_api <- function(
  query_url,
  structure_url = NULL,
  verbose = TRUE,
  check = TRUE) {

  # Check suggested packages
  purrr::walk(c("readsdmx", "urltools"),
              requireNamespace,
              quietly = TRUE)

  # Arg checks
  stopifnot(is.character(query_url))

  # needs to pass the http get res to qu_ok, should speed it up

  if (check) {
    res <- httr::GET(query_url)

    if (verbose) {
      message("Checking the URL is reachable...")
    }

    ok <- qu_ok(res)
    if (!ok) {
      stop(attr(ok, "msg"),
           call. = FALSE)
    }
  }

  # Get data
  if (verbose) {
    glue::glue("Querying the raw data...") %>%
      message()
  }

  query_data <- open_sdmx(query_url)

  structure_url <- structure_url %||% guess_structure_url(query_url)
  if (verbose) {
    message("Querying the data dictionary and matching it to the raw data...")
  }

  # Tidy data
  tidy_api_data(
    query_data = query_data,
    structure_url = structure_url
  )
}



#' Guess the structure URL for the API
#'
#' The structure URL will return information about how certain variables are
#' encoded. This function can guess what it should be, given a query URL.
#'
#' @inheritParams read_abs_api
#'
#' @return (\code{character}) a URL string
guess_structure_url <- function(query_url) {

  # Check suggested packages
  requireNamespace("urltools", quietly = TRUE)

  components <- urltools::url_parse(query_url)
  # take the path, and the bit in between the /, and swap the , for /, and add
  # dataflow
  new_path <- components$path %>%
    stringi::stri_extract_first_regex("(?<=/)(.*)(?=/)") %>%
    stringi::stri_replace_all_fixed(",", "/")
  new_path <- paste0("dataflow/", new_path)

  components$path <- new_path
  components$parameter <- "references=all&detail=referencepartial"

  urltools::url_compose(components)
}



#' Wrapper to download and read an SDMX XML
#'
#' There are two packages to read SDMX APIs in R: \code{readsdmx} and
#' \code{rsdmx}. The former is much faster, but hasn't been updated since 2019
#' and sometimes throws weird errors. The latter is works reliably, but is much,
#' much slower. Anyway, this function tries to improve the stability of the
#' former by handling the download explicitly.
#'
#' @inheritParams read_abs_api
#'
#' @return a \code{tibble}
#'
open_sdmx <- function(query_url) {
  destfile <- tempfile(fileext = ".xml")
  # Need this step because of some weird windows problem that wouldn't open certain API website
  xml2::download_xml(query_url, destfile)
  destfile %>%
    readsdmx::read_sdmx() %>%
    dplyr::as_tibble()
}
