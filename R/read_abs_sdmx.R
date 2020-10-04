# Function by Zoe Meers, United States Studies Centre

#' Extracts ABS XML-formatted data using the SDMX API
#'
#' @param url URL weblink.
#'
#' @return data frame
#' @importFrom rsdmx readSDMX
#' @export
#'
#' @description Access the sdmx URLs at
#' 'http://www.abs.gov.au/ausstats/abs@.nsf/Lookup/1407.0.55.002Main+Features4User+Guide'
#'
#' @examples
#' \dontrun{
#' url <- paste0(
#'   "http://stat.data.abs.gov.au/restsdmx/sdmx.ashx/GetData/LF/",
#'   "0.2+3+4+11+13+6+15+14+10.3+1+2.1519+1599.10+20+30.M/",
#'   "all?startTime=2017-12&endTime=2018-11"
#' )
#' lfs <- read_abs_sdmx(url)
#' lfs
#' }
#'
read_abs_sdmx <- function(url) {
  url <- url
  dataset <- rsdmx::readSDMX(url)
  abs_data <- as.data.frame(dataset)
  return(abs_data)
}
