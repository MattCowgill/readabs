#' Get tidy data from ABS' API
#'
#' This function returns a tidy \code{tibble} of data queried from the
#' \href{https://explore.data.abs.gov.au/}{ABS' API}. See the vignette for a
#' detailed guide on how to use this to get monthly labour force data or
#' download the last decade of Data by Region at SA2.
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
#' @param batch_mode (logical; default = \code{FALSE}) Set to \code{TRUE} when
#'   iterating over a vector of URLs. It will return an empty \code{tibble} if
#'   the URL doesn't return any data. \code{check} needs to be \code{TRUE}.
#'   Still questioning the best way to implement this.
#'
#' @return (\code{tibble}) Returns a tidy \code{tibble} containing the ABS data
#'   you queried. Each \code{tibble} returns a column \code{value} along with a
#'   series of other columns for the metadata (suffixed \code{_code},
#'   \code{_name}, and \code{_notes}). Some metadata returns just one suffixed
#'   column, others two, and others three (eg querying labour force data returns
#'   \code{sex_code} and \code{sex_name}, but \code{age_code}, \code{age_name}
#'   and \code{age_notes}. Generally, the \code{_code} column shows the encoded
#'   value (eg \code{sex_code} might show a value of \code{3}), the \code{_name}
#'   shows a human interpretable translation of \code{_code} (eg \code{sex_name}
#'   would show \code{Persons}), and \code{_notes} is a bit of a mixed bag.
#'   Sometimes it's missing, sometimes it's the same as \code{_name}, and
#'   sometimes it's useful context.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Labour force data query URL, taken from ABS API site
#' lf_url <- "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M9.3.1599.30+10+20.AUS.M?startPeriod=2021-01&dimensionAtObservation=AllDimensions"
#'
#' lf <- read_abs_api(lf_url)
#' }
read_abs_api <- function(
  query_url,
  structure_url = NULL,
  verbose = TRUE,
  check = TRUE,
  batch_mode = FALSE) {

  # Check suggested packages
  purrr::walk(c("rsdmx", "urltools"),
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
    if (batch_mode & !ok) {
      if (verbose) {
        message("No data there but moving forward because of `batch_mode`.")
      }
      return(dplyr::tibble())
    }
    if (!ok) {
      stop(attr(ok, "msg"),
           call. = FALSE)
    }


  }

  # Get data
  if (verbose) {
    # res_content <- httr::content(res)
    # desc <- res_content$structure$name
    glue::glue("Querying the raw data...") %>%
      message()
  }



  raw_dat <- dplyr::as_tibble(rsdmx::readSDMX(query_url))

  structure_url <- structure_url %||% guess_structure_url(query_url)
  if (verbose) {
    message("Querying the data dictionary and matching it to the raw data...")
  }

  # Tidy data
  tidy_api_data(
    .data = raw_dat,
    structure_url = structure_url
  ) %>%
    dplyr::as_tibble()
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
