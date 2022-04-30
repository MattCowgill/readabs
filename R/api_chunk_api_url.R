
#' Chunk a \code{query_url} into individual years
#'
#' One way to break up a \code{query_url} is by year. This function does that.
#'
#' @inheritParams read_abs_api
#'
#' @return (\code{character} vector) a vector of URLs, one for each year of data
#'   requested.
chunk_span <- function(query_url) {
  start_pat <- "(?<=startPeriod\\=)(\\d+[[:punct:]]*){4,7}(?=&)"
  start <- stringi::stri_extract_first_regex(
    query_url,
    start_pat
  )

  has_months <- nchar(start) > 4

  has_span <- qu_has_span(query_url)

  # If the query_url doesn't have an end period, the API treats it as today.
  # So explicitly add that in
  if (!has_span) {
    this_year <- format(Sys.Date(), "%Y")
    this_month <- format(Sys.Date(), "%m")

    explicit_end <- ifelse(has_months,
      glue::glue("{start}&endPeriod={this_year}-{this_month}"),
      glue::glue("{start}&endPeriod={this_year}")
    )

    query_url <- query_url %>%
      stringi::stri_replace_first_regex(
        start_pat,
        explicit_end
      )
  }

  end_pat <- "(?<=endPeriod\\=)(\\d+[[:punct:]]*){4,7}(?=&)"

  end <- stringi::stri_extract_first_regex(
    query_url,
    end_pat
  )

  # Build a tibble of start and end dates

  # Deal with months

  if (has_months) {
    start_year <- as.numeric(stringi::stri_split_fixed(start, pattern = "-")[[1]][1])
    start_month <- as.numeric(stringi::stri_split_fixed(start, pattern = "-")[[1]][2])
    end_year <- as.numeric(stringi::stri_split_fixed(end, pattern = "-")[[1]][1])
    end_month <- as.numeric(stringi::stri_split_fixed(end, pattern = "-")[[1]][2])

    first_end <- paste(start_year, 12, sep = "-")
    last_start <- paste(end_year, "01", sep = "-")
    mid_starts <- seq(start_year + 1, end_year - 1) %>%
      paste("01", sep = "-")
    mid_ends <- seq(start_year + 1, end_year - 1) %>%
      paste("12", sep = "-")

    new_spans <- dplyr::tibble(
      new_start = c(start, mid_starts, last_start),
      new_end = c(first_end, mid_ends, end)
    ) %>%
      dplyr::distinct()
  } else {
    span <- seq(start, end) %>%
      as.character()

    new_spans <- dplyr::tibble(
      new_start = span,
      new_end = span
    ) %>%
      dplyr::distinct()
  }


  new_spans %>%
    dplyr::mutate(url = query_url %>%
      stringi::stri_replace_first_regex(
        replacement = .data$new_start,
        start_pat
      ) %>%
      stringi::stri_replace_first_regex(
        replacement = .data$new_end,
        end_pat
      )) %>%
    dplyr::pull(.data$url)
}


#' Chunk a \code{query_url} into requests for fewer dimensions
#'
#' One way to break up a \code{query_url} is by requesting fewer dimensions
#' (such as only a few SA2s as a time). This function does that for the
#' dimension with the most levels.
#'
#' @inheritParams read_abs_api
#' @param n (\code{numeric}; default = \code{300}) the number of dimension
#'   levels to request in each URL. Higher means fewer URLs (and thus faster),
#'   but increases the risk of the resulting URLs not being valid. Cursory
#'   testing indicates that more than 400 results in data loss (ie some URLs are
#'   still too big).
#'
#' @return (\code{character} vector) a vector of URLs, one for subgroup of the
#'   largest dimension.
chunk_big_dim <- function(query_url,
                          n = 300) {
  big_dims <- qu_biggest_dimesion(query_url)

  dims <- big_dims %>%
    stringi::stri_split_fixed(pattern = "+") %>%
    unlist()

  new_dims <- split(dims, ceiling(seq_along(dims) / n)) %>%
    purrr::map_chr(paste0,
      collapse = "+"
    )

  new_dims %>%
    purrr::map_chr(stringi::stri_replace_all_fixed,
      str = query_url,
      pattern = big_dims
    )
}


#' Break up a \code{query_url} into chunks, by date and dimension
#'
#' Some URLs provided by the ABS' API are too long to actually work. This
#' function breaks up a \code{query_url} into multiple smaller ones. It does
#' this by looking at the time period the request covers, and separating it into
#' individual years, and by looking at the dimension with the most levels
#' (usually a geography) and creating URLs that only request a smaller number of
#' levels.
#'
#' @inheritParams chunk_big_dim
#' @return (\code{character} vector) a \code{character} vector of URLs for the
#'   ABS API
#' @export
#' @inherit read_abs_api examples
#'
chunk_query_url <- function(query_url, n = 75) {
  requireNamespace("urltools", quietly = TRUE)

  # Return a vector of query URLs split by year
  query_url <- chunk_span(query_url)

  # Iterate over that vector and break into fewer dimension level requests
  purrr::map(query_url,
    chunk_big_dim,
    n = n
  ) %>%
    unlist() %>%
    purrr::set_names(NULL)
}
