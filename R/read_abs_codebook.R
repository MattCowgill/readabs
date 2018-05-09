## Functions to deal with and read ABS codebook
## Zoe Meers
## The United States Studies Centre

#' Extracts ABS-formatted codebook directly from Excel spreadsheets.
#'
#' @param path Filepath to Excel spreadsheet.
#' @param sheet Sheet name or number.
#'
#' @return dataframe
#' @export
#'
#' @examples
#' read_abs_data(path="test.xls", sheet=2)
read_abs_codebook <- function(path, sheet) {
  excel_data <- readxl::read_excel(path = path, sheet = sheet, col_names = FALSE)
  skip_rows <- NULL
  col_skip <- 0
  search_string <- "Released at"
  max_cols_to_search <- 10
  max_rows_to_search <- 10
  while (length(skip_rows) == 0) {
    col_skip <- col_skip + 1
    if (col_skip == max_cols_to_search) break
    skip_rows <- which(stringr::str_detect(excel_data[1:max_rows_to_search, col_skip][[1]], search_string)) - 0
  }
  real_data <- readxl::read_excel(
    path = path,
    sheet = sheet,
    skip = skip_rows
  )
  real_df <- as.data.frame(real_data)
  df <- sjmisc::remove_empty_rows(real_df)
  df <- as.data.frame(df)
  return(df)
}
