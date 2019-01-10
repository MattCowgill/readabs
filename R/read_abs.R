#' Download, extract, and tidy ABS time series spreadsheets
#'
#' \code{read_abs()} downloads ABS time series spreadsheets,
#' then extracts the data from those spreadsheets,
#' then tidies the data. The result is a single
#' data frame (tibble) containing tidied data.
#'
#' @param cat_no ABS catalogue number, as a string, including the extension.
#' For example, "6202.0".
#'
#' @param path Local directory in which to save downloaded ABS time series
#' spreadsheets. Default is "data/ABS"; this subdirectory of your working
#' directory will be created if it does not exist.
#'
#' @param show_progress_bars TRUE by default. If set to FALSE, progress bars
#' will not be shown when ABS spreadsheets are downloading.
#'
#' @return A data frame (tibble) containing the tidied data from the ABS time
#' series table(s).
#'
#' @examples
#'
#' # Download and tidy all time series spreadsheets from the Wage Price Index (6345.0)
#'
#' \donttest{wpi <- read_abs("6345.0")}
#'
#' @importFrom purrr walk walk2 map
#' @name read_abs
#' @export

read_abs <- function(cat_no = NULL,
                     path = "data/ABS",
                     show_progress_bars = TRUE){

  if(is.null(cat_no)){
    stop("get_abs() requires an ABS catalogue number, such as '6202.0' or '6401.0'")
  }

  if(class(cat_no) != "character"){
    stop("Please specify cat_no as a character string, eg. '6202.0', not 6202")
  }

  if(nchar(cat_no) < 6){
    stop("Please ensure you include the cat_no extension, eg. '6202.0', not '6202'")
  }

  # find URLs from cat_no
  message(paste0("Finding filenames for tables from ABS catalogue ", cat_no))
  xml_dfs <- get_abs_xml_metadata(cat_no = cat_no)

  urls <- unique(xml_dfs$TableURL)
  urls <- gsub(".test", "", urls)

  table_titles <- unique(xml_dfs$TableTitle)

  # download tables corresponding to URLs
  message(paste0("Attempting to download files from cat. no. ", cat_no, ", ", xml_dfs$ProductTitle[1]))
  purrr::walk(urls, download_abs, path = path, show_progress_bars = show_progress_bars)

  # extract the sheets to a list
  filenames <- base::basename(urls)
  message("Extracting data from downloaded spreadsheets")
  sheets <- purrr::map2(filenames, table_titles,
                       .f = extract_abs_sheets, path = path)

  # remove one 'layer' of the list, so that each sheet is its own element in the list
  sheets <- unlist(sheets, recursive = FALSE)

  # tidy the sheets
  sheet <- tidy_abs_list(sheets)

  sheet

}

#' Download, extract, and tidy ABS time series spreadsheets (soft deprecated)
#'
#' \code{get_abs()} is deprecated. Please use \code{read_abs()} instead. It has identical functionality.
#'
#' @param ... arguments passed to \code{read_abs()}
#'
#' @export

get_abs <- function(...){
  read_abs(...)
  .Deprecated(old = "get_abs()",
              new = "read_abs()",
              msg = "get_abs() is soft deprecated and will be removed in a future update.\nPlease use read_abs() instead.")
}
