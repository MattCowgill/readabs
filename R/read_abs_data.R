# Function by Jaron Lee, United States Studies Centre

#' Extracts ABS time series data from local Excel spreadsheets and converts to
#' long format.
#'
#' `read_abs_data()` is soft deprecated and will be removed in a future version.
#' Please use `read_abs_local()` to import and tidy locally-stored
#' ABS time series spreadsheets, or `read_abs()` to download, import,
#' and tidy time series spreadsheets from the ABS website.
#'
#' @param path Filepath to Excel spreadsheet.
#' @param sheet Sheet name or number.
#'
#' @return Long-format dataframe
#' @export
#'
read_abs_data <- function(path, sheet) {
  Date = series = value = NULL
  df <- readxl::read_excel(path = path, sheet = sheet)
  dat <- df[-(1:9), ]
  colnames(dat)[1] <- "Date"
  dat$Date <- as.Date(as.integer(dat$`Date`), origin = "1899-12-30")
  dat <- tidyr::gather(dat, `series`, `value`, -`Date`)
  dat$value <- as.numeric(dat$`value`)

  .Deprecated(new = "read_abs_local()",
              old = "read_abs_data()",
              msg = "read_abs_data() is deprecated and will be removed in a future version. Please use read_abs_local().")

  return(dat)
}


#' Extracts ABS series metadata directly from Excel spreadsheets and
#' converts to long-form.
#'
#' @param path Filepath to Excel spreadsheet.
#' @param sheet Sheet name or number.
#'
#' @return Long-form dataframe
#' @export
#'
read_abs_metadata <- function(path, sheet) {
  df <- readxl::read_excel(path = path, sheet = sheet, col_names = FALSE)
  dat <- df[(1:9), ]
  final_dat <- (t(dat[, 2:ncol(dat)]))
  colnames(final_dat) <- t(dat[, 1])
  rownames(final_dat) <- NULL
  final_dat <- as.data.frame(final_dat, stringsAsFactors = FALSE)
  final_dat$`Series Start` <- as.Date(as.integer(final_dat$`Series Start`),
                                      origin = "1899-12-30")
  final_dat$`Series End` <- as.Date(as.integer(final_dat$`Series End`),
                                    origin = "1899-12-30")
  colnames(final_dat)[1] <- "Series"

  .Deprecated(new = "read_abs_local()",
              old = "read_abs_metadata()",
              msg = "read_abs_metadata() is deprecated and will be removed in a future version. Please use read_abs_local()
              to read tidy versions of locally-stored time series spreadsheets, or read_abs() to get them from the ABS website.")


  return(final_dat)
}
