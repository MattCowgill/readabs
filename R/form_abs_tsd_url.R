# Function to create URL(s) to search the ABS Time Series Directory
# given an ABS catalogue number or a series ID

form_abs_tsd_url <- function(cat_no = NULL,
                             tables = "all",
                             series_id = NULL) {

  if (is.null(cat_no) & is.null(series_id)) {
    stop("Must specify either `cat_no` or `series_id`")
  }

  # create the url to search for in the Time Series Directory
  base_url <- "https://ausstats.abs.gov.au/servlet/TSSearchServlet?newsite=true&"

  if (!is.null(series_id)) {
    if (!is.character(series_id)) {
      stop("If you specify `series_id`, it must be a string.")
    }

    xml_urls <- paste0(base_url, "sid=", series_id)

  } else {

    if (tables[1] == "all") {
      tables_url <- ""
    } else {
      tables_url <- paste0("&ttitle=", tables)
    }

    xml_urls <- paste0(base_url,
                       "catno=", cat_no,
                       tables_url)

  }


  xml_urls

}
