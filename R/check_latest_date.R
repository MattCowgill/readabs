#' Latest release date of ABS time series
#' This function returns the most recent release date for specified ABS time
#' series catalogue number (as a whole), individual tables, or series IDs.
#'
#' @param cat_no ABS catalogue number, as a string, including the extension.
#' For example, "6202.0".
#'
#' @param tables numeric. Time series tables in `cat_no`` to download and
#' extract. Default is "all", which will read all time series in `cat_no`.
#' Specify `tables` to download and import specific tables(s) -
#' eg. `tables = 1` or `tables = c(1, 5)`.
#'
#' @param series_id (optional) character. Supply an ABS unique time series
#' identifier (such as "A2325807L") to get only that series.
#' This is an alternative to specifying `cat_no`.
#'
#' @details Not all time series in a table, or all tables in a catalogue number,
#' have the same release date. Where the individual time series in your request
#' have multiple release dates, only the most recent will be returned.
#'
#' @return Date vector of length one.
#'
#' @examples
#' \dontrun{
#'
#' # Check a whole catalogue number; return the latest release date for any
#' # time series in the number
#'
#' check_latest_date("6345.0")
#'
#' # Return latest release date for a table within a catalogue number
#' check_latest_date("6345.0", tables = 1)
#'
#' # Or for an individual time series
#' check_latest_date(series_id = "A2713849C")
#' }
#'
#' @export

check_latest_date <- function(cat_no = NULL,
                              tables = "all",
                              series_id = NULL) {

  # check that R has access to the internet
  check_abs_connection()

  # Create URLs to query the ABS Time Series Directory
  xml_urls <- form_abs_tsd_url(
    cat_no = cat_no,
    tables = tables,
    series_id = series_id
  )

  xml_dfs <- purrr::map_dfr(xml_urls,
                            .f = get_abs_xml_metadata
  )

  latest_date <- xml_dfs %>%
    dplyr::filter(ProductReleaseDate == max(ProductReleaseDate)) %>%
    dplyr::pull(ProductReleaseDate) %>%
    unique()

  latest_date


}
