#' Extract data sheets from an ABS timeseries workbook saved locally as an
#' Excel file.
#'
#' Note that this function will not tidy the data for you.
#' Use `read_abs_local()`to import and tidy data from local ABS time series
#' spreadsheets or `read_abs()` to download, import and tidy ABS time series.
#'
#' @param filename Filename for an ABS time series spreadsheet (as string)
#'
#' @param table_title String giving the full title of the ABS table, such as
#' "Table 1. Employed persons, Australia"
#'
#' @param path Local directory in which an ABS time series is stored. Default is
#' `Sys.getenv("R_READABS_PATH", unset = tempdir())`.
#'
#' @importFrom readxl excel_sheets read_excel
#' @importFrom dplyr filter "%>%"
#' @importFrom purrr map set_names
#' @importFrom tools file_path_sans_ext
#'
#' @export

extract_abs_sheets <- function(filename,
                               table_title = NULL,
                               path = Sys.getenv("R_READABS_PATH",
                                 unset = tempdir()
                               )) {
  filename <- file.path(path, filename)

  sheets <- readxl::excel_sheets(path = filename)
  sheets <- sheets[!sheets %in% c(
    "Index", "Inquiries", "Enquiries",
    "Contents", "Technical note", "Technical notes", "Note", "Notes"
  )]
  sheets <- sheets[!grepl("Table ", sheets, ignore.case = T)]

  if (length(sheets) < 1) {
    stop(sprintf(
      "The Excel workbook %s appears to have no data sheets.",
      filename
    ))
  }

  data_sheets <- purrr::map(
    .x = sheets,
    .f = readxl::read_excel,
    path = filename,
    trim_ws = TRUE,
    .name_repair = "minimal"
  )

  data_sheets <- data_sheets %>%
    purrr::set_names(paste0(
      tools::file_path_sans_ext(basename(filename)), "=",
      sheets, "=",
      table_title
    ))

  data_sheets
}
