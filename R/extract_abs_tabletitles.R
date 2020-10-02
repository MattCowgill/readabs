# Only used with read_abs_local, where we can't get the titles from
# the Time Series Directory
#' @importFrom readxl read_excel

extract_abs_tabletitles <- function(filename, path) {
  filename <- paste0(path, "/", filename)

  tabletitle <- readxl::read_excel(filename,
    range = "Index!B6:B6",
    col_names = "tabletitle"
  )

  tabletitle <- as.character(tabletitle)

  tabletitle
}
