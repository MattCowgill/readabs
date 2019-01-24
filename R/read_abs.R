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
#' @param tables numeric. Time series tables in `cat_no`` to download and extract. Default is "all",
#' which will read all time series in `cat_no`. Specify `tables` to
#' download and import specific tables(s) - eg. `tables = 1` or `tables = c(1, 5)`.
#'
#' @param path Local directory in which to save downloaded ABS time series
#' spreadsheets. Default is "data/ABS"; this subdirectory of your working
#' directory will be created if it does not exist.
#'
#' @param metadata logical. If `TRUE` (the default), a tidy data frame including
#' ABS metadata (series name, table name, etc.) is included in the output. If
#' `FALSE`, metadata is dropped.
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
#' @importFrom purrr walk walk2 map map_dfr map2
#' @name read_abs
#' @export

read_abs <- function(cat_no = NULL,
                     tables = "all",
                     path = "data/ABS",
                     metadata = TRUE,
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

  if(is.null(tables)){
    message(paste0("`tables` not specified; attempting to fetch all tables from ", cat_no))
  }

  if(!is.logical(metadata)){
    stop("`metadata` argument must be either TRUE or FALSE")
  }

  # create the url to search for in the Time Series Directory

  base_url <- "http://ausstats.abs.gov.au/servlet/TSSearchServlet?catno="

  if(tables[1] == "all"){
    tables_url <- ""
  } else {
    tables_url <- paste0("&ttitle=", tables)
  }

  xml_urls <- paste0(base_url,
                    cat_no,
                    tables_url)

  # find spreadsheet URLs from cat_no in the Time Series Directory
  message(paste0("Finding filenames for tables from ABS catalogue ", cat_no))
  xml_dfs <- purrr::map_dfr(xml_urls,
                            .f = get_abs_xml_metadata,
                            release_dates = "latest")

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
  sheet <- tidy_abs_list(sheets, metadata = metadata)

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
