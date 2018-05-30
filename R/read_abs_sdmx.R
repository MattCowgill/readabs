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
#' @examples
#' \dontrun{
#' read_abs_sdmx("http://stat.data.abs.gov.au/restsdmx/sdmx.ashx/GetData/ABS_REGIONAL_ASGS/PENSION_2+BANKRUPT_2.AUS.0.A/all?startTime=2013&endTime=2013")
#'}


read_abs_sdmx <- function(url) {
  url <- url
  dataset <- rsdmx::readSDMX(url)
  abs_data <- as.data.frame(dataset)
  return(abs_data)
}
