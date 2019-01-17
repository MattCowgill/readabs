#' Read and tidy locally-saved ABS time series spreadsheet(s)
#'
#' If you need to download and tidy time series data from the ABS, use \code{read_abs()}.
#' \code{read_abs_local()} imports and tidies data from ABS time series spreadsheets that
#' are already saved to your local drive.
#'
#' Unlike \code{read_abs()}, the `table_title` column in the data frame
#' returned by \code{read_abs_local()} is blank. If you require `table_title`,
#' please use \code{read_abs()} instead.
#'
#' @param filenames character vector of at least one filename of a locally-stored
#' ABS time series spreadsheet. For example, "6202001.xls" or c("6202001.xls", "6202005.xls").
#' If `filenames` is blank, `read_abs_local()` will attempt to read all .xls files in
#' the directory specified with `path`. Please note that the directory should
#' be specified with `path`.
#'
#' @param path path to local directory containing ABS time series file(s).
#' Default is "data/ABS". If nothing is specified in `filenames`,
#' `read_abs_local()` will attempt to read all .xls files in the directory specified with `path`.
#'
#' @param metadata logical. If `TRUE` (the default), a tidy data frame including
#' ABS metadata (series name, table name, etc.) is included in the output. If
#' `FALSE`, metadata is dropped.
#'
#' @examples
#'
#'  # Load and tidy two specified files from the "data/ABS" subdirectory
#'  # of your working directory
#'
#'  \donttest{lfs <- read_abs_local(c("6202001.xls", "6202005.xls"))}
#'
#'
#' @export
#'

read_abs_local <- function(filenames = NULL,
                           path = "data/ABS",
                           metadata = TRUE){
  if(is.null(filenames) & is.null(path)){
    stop("You must specify a value to filenames and/or path.")
  }

  if(!is.null(filenames) & class(filenames) != "character") {
    stop("if a value is given to `filenames`, it must be specified as a character vector, such as '6202001.xls' or c('6202001.xls', '6202005.xls')")
  }

  if(is.null(path)){
    warning(paste0("`path` not specified.\nLooking for ABS time series files in ", getwd()))
  }

  if(is.null(filenames)){
    message(paste0("`filenames` not specified. ",
                   "Looking for ABS time series files in '",
                   path,
                   "' and attempting to read all files.\nSpecify `filenames` if you do not wish to attempt to import all .xls files in ",
                   path))

    # Get a list of all filenames in path, as `filenames` is null

    filenames <- list.files(path = path, pattern = "\\.xls$")

    if(length(filenames) == 0) {
      stop(paste0("Could not find any .xls files in path: '", path, "'"))
    }

  }

  if(!is.logical(metadata)){
    stop("`metadata` argument must be either TRUE or FALSE")
  }

  # Create filenames for local ABS time series files

  filenames <- base::basename(filenames)

  # Import data from local spreadsheet(s) to a list
  message("Extracting data from locally-saved spreadsheets")
  sheets <- purrr::map(filenames, extract_abs_sheets, path = path)

  # remove one 'layer' of the list, so that each sheet is its own element in the list
  sheets <- unlist(sheets, recursive = FALSE)

  # tidy the sheets
  sheet <- tidy_abs_list(sheets, metadata = metadata)

  if(metadata){
  message("\nNote: table_title column in your data frame is blank. Please use read_abs() if you need table_title.")
  }
  sheet

}
