#' Get date of most recent observation(s) in ABS time series
#'
#' This function returns the most recent observation date for a specified ABS
#' time series catalogue number (as a whole), individual tables, or series IDs.
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
#' @details Where the individual time series in your request
#' have multiple dates, only the most recent will be returned.
#'
#' @return Date vector of length one. Date corresponds to the most recent
#' observation date for any of the time series in the table(s) requested.
#' observation date for any of the time series in the table(s) requested.
#'
#' @examples
#' \dontrun{
#'
#' # Check a whole catalogue number; return the latest release date for any
#' # time series in the number
#'
#' check_latest_date("6345.0")
#'
#' # Return latest release date for a table within a catalogue number  - note
#' # the function will return the release date
#' # of the most-recently-updated series within the tables
#' check_latest_date("6345.0", tables = 1)
#'
#' # Or for multiple tables - note the function will return the release date
#' # of the most-recently-updated series within the tables
#' check_latest_date("6345.0", tables = c("1", "5a"))
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

  xml_list <- purrr::map(xml_urls, get_first_xml_page)

  xml_df <- xml_list %>%
    purrr::map(xml2::xml_find_all,
               xpath = "//Series") %>%
    purrr::map_dfr(xml2::as_list) %>%
    tidyr::unnest(cols = dplyr::everything() )

  # Extract the date on the first page of the metadata
  # (it'll be the oldest in the directory)

  max_date <- as.Date(xml_df$SeriesEnd,
                      format = "%d/%m/%Y") %>%
                    max()

  max_date

}
