## Functions to read ABS SDMX URLs
## Zoe Meers
## The United States Studies Centre

#' Extracts ABS XML-formatted data using the exported XML link at http://www.abs.gov.au/
#'
#' @param url URL weblink.
#'
#' @return data frame
#' @export
#'
#' @description Access the sdmx URLs at http://www.abs.gov.au/ausstats/abs@.nsf/Lookup/1407.0.55.002Main+Features4User+Guide
#'
#' @examples
#' \donttest{
#' read_abs_sdmx(url)
#'}


read_abs_sdmx <- function(url) {
  url <- url
  dataset <- rsdmx::readSDMX(url)
  abs_data <- as.data.frame(dataset)
  return(abs_data)
}
