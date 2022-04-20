
#' Superficial check if a \code{query_url} is reachable
#'
#' Some URLs provided by the ABS' API are actually duds, so it can help to check
#' if they can be reached. This does that by calling \code{httr::GET()},
#' checking the status response, and printing a (hopefully) helpful error
#' message.
#'
#' @param res a HTTP response as returned by \code{httr::GET}
#'
#' @return (\code{logical}) \code{TRUE} if the status code is 200, \code{FALSE}
#'   otherwise (with an error message printed to the console)
#'
qu_ok <- function(res) {

  all_good <- res$status_code == 200

  # Early return if all good
  if (all_good) {
    return(TRUE)
  }

  error_msg <- httr::content(res, as = "text", encoding = "utf8") %>%
    stringi::stri_replace_all_regex(pattern = "<.*?>", replacement = "") %>%
    stringi::stri_replace_all_regex(
      pattern = "\n+",
      replacement = "\n"
    )

  msg <- glue::glue("`query_url` cannot be queried at this time (the ABS might be down or the URL requests too much data).
             The error message from the ABS is:
             {error_msg}
             You could also try running `chunk_query_url(query_url)` and iterating `read_abs_api()` over that list of URLs (this often helps if you get a 500 or 414 error (but not always))).")

  attr(all_good, "msg") <- msg
  all_good
}


#' Check if a \code{query_url} has specified start and end periods
#'
#' This is helpful for chunking up a long \code{query_url} into smaller
#' requests.
#'
#' @inheritParams read_abs_api
#'
#' @return (\code{logical}) \code{TRUE} if \code{query_url} has
#'   \code{startPeriod} and \code{endPeriod}
qu_has_span <- function(query_url) {
  requireNamespace("urltools", quietly = TRUE)
  components <- urltools::url_parse(query_url)

  c("startPeriod", "endPeriod") %>%
    purrr::map_lgl(stringi::stri_detect_fixed,
      str = components$parameter
    ) %>%
    all()
}


#' What is the biggest dimension component in a \code{query_url}?
#'
#' This function returns the biggest dimension (ie the most verbose, so often
#' geography) in a \code{query_url}. This is helpful for chunking up a long
#' \code{query_url} into smaller requests.
#'
#' @inheritParams read_abs_api
#'
#' @return (\code{character}) the longest part of \code{query_url} between two
#'   \code{.}.
qu_biggest_dimesion <- function(query_url) {
  requireNamespace("urltools", quietly = TRUE)
  components <- urltools::url_parse(query_url)
  dims <- components$path %>%
    stringi::stri_replace_first_regex(
      replacement = "",
      "data/ABS(.*)/"
    ) %>%
    stringi::stri_split_fixed(pattern = ".") %>%
    unlist()

  ranks <- dims %>%
    purrr::map_int(nchar) %>%
    order() %>%
    rev()

  dims[ranks[1]]
}
