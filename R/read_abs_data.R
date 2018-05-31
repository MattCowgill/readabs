## Functions to deal with and read ABS data
## Jaron Lee
## The United States Studies Centre

#' Extracts ABS-formatted data directly from Excel spreadsheets and converts to long format.
#'
#' @param path Filepath to Excel spreadsheet.
#' @param sheet Sheet name or number.
#'
#' @return Long-format dataframe
#' @export
#'
#'
#'
#' @examples
#' \donttest{
#' data <- system.file("extdata","5206002_expenditure_volume_measures.xls", package = "readabs")
#' read_abs_data(path= data, sheet=2)
#'}
#'
#'
#'
read_abs_data <- function(path, sheet) {
  Date = X__1 = series = value = NULL
  df <- readxl::read_excel(path = path, sheet = sheet)
  dat <- df[-(1:9), ]
  dat <- dplyr::rename(dat, `Date` = `X__1`)
  dat$Date <- as.Date(as.integer(dat$`Date`), origin = "1899-12-30")
  dat <- tidyr::gather(dat, `series`, `value`, -`Date`)
  dat$value <- readr::parse_double(dat$`value`)
  return(dat)
}


#' Extracts ABS series metadata directly from Excel spreadsheets and converts to long-form.
#'
#' @param path Filepath to Excel spreadsheet.
#' @param sheet Sheet name or number.
#'
#' @return Long-form dataframe
#' @export
#' @examples
#' \donttest{
#' data <- system.file("extdata","5206002_expenditure_volume_measures.xls", package = "readabs")
#' read_abs_metadata(path= data, sheet=2)
#'}
#'
read_abs_metadata <- function(path, sheet) {
  df <- readxl::read_excel(path = path, sheet = sheet, col_names = FALSE)
  dat <- df[(1:9), ]
  final_dat <- (t(dat[, 2:ncol(dat)]))
  colnames(final_dat) <- t(dat[, 1])
  rownames(final_dat) <- NULL
  final_dat <- as.data.frame(final_dat, stringsAsFactors = FALSE)
  final_dat$`Series Start` <- as.Date(as.integer(final_dat$`Series Start`), origin = "1899-12-30")
  final_dat$`Series End` <- as.Date(as.integer(final_dat$`Series End`), origin = "1899-12-30")
  return(final_dat)
}
