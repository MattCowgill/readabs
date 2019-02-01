#' @importFrom httr http_error HEAD

url_is_excel <- function(url) {
  if (url_http_error <- httr::http_error(url)) {
    stop("The following URL had error code ", url_http_error, ".\n\t",
         url)
  }
  header <- httr::HEAD(url)
  content <- header[["headers"]]["content-type"]
  ## Excel 2007 and after (.xlsx), and
  ## Excel BIFF, e.g. 2003 (.xls)
  content %in% c("application/vnd.openxmlformats-officedocument.spreadsheetml.sheet",
                 "application/vnd.ms-excel")
}

read_abs_seriesid <- function(series_id){

  base_direct_url <- "http://www.ausstats.abs.gov.au/ausstats/meisubs.nsf/GetTimeSeries?OpenAgent&sid="

  url <- paste0(base_direct_url, series_id)

  url_contains_excel <- url_is_excel(url)

  if(url_contains_excel){
    print("yay")
    # download direct url
  } else {
    # go via XML directory
    print("boo")
  }

}
