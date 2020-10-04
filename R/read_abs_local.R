#' Read and tidy locally-saved ABS time series spreadsheet(s)
#'
#' If you need to download and tidy time series data from the ABS,
#' use \code{read_abs()}. \code{read_abs_local()} imports and tidies data
#' from ABS time series spreadsheets that are already saved to your local drive.
#'
#' Unlike \code{read_abs()}, the `table_title` column in the data frame
#' returned by \code{read_abs_local()} is blank. If you require `table_title`,
#' please use \code{read_abs()} instead.
#'
#' @param cat_no character; a single catalogue number such as "6202.0".
#' When `cat_no` is specified, all local files in `path` corresponding to
#' the specified catalogue number will be imported.
#' For example, if you run `read_abs_local("6202.0")`, it will look in
#' "data/ABS/6202.0" and attempt to load any .xls files in that location.
#' If `cat_no`` is specified, `filenames` will be ignored.
#'
#' @param filenames character vector of at least one filename of a
#' locally-stored ABS time series spreadsheet. For example, "6202001.xls" or
#' c("6202001.xls", "6202005.xls"). Ignored if a value is supplied to `cat_no`.
#' If `filenames` is blank and `cat_no` is blank, `read_abs_local()` will
#' attempt to read all .xls files in the directory specified with `path`.
#'
#' @param path path to local directory containing ABS time series file(s).
#' Default is `Sys.getenv("R_READABS_PATH", unset = tempdir())`.
#'  If nothing is specified in `filenames` or `cat_no`,
#' `read_abs_local()` will attempt to read all .xls files in the directory
#' specified with `path`.
#'
#' @param use_fst logical. If `TRUE` (the default) then, if an `fst` file of the
#' tidy data frame has already been saved in `path`, it is read immediately.
#'
#' @param metadata logical. If `TRUE` (the default), a tidy data frame including
#' ABS metadata (series name, table name, etc.) is included in the output. If
#' `FALSE`, metadata is dropped.
#'
#' @examples
#'
#' # Load and tidy two specified files from the "data/ABS" subdirectory
#' # of your working directory
#' \dontrun{
#' lfs <- read_abs_local(c("6202001.xls", "6202005.xls"))
#' }
#'
#' @export
#'

read_abs_local <- function(cat_no = NULL,
                           filenames = NULL,
                           path = Sys.getenv("R_READABS_PATH",
                             unset = tempdir()
                           ),
                           use_fst = TRUE,
                           metadata = TRUE) {

  # Error catching
  if (is.null(filenames) && is.null(path)) {
    stop("You must specify a value to filenames and/or path.")
  }

  if (!is.null(filenames) && !is.character(filenames)) {
    stop("if a value is given to `filenames`, it must be specified as a character vector, such as '6202001.xls' or c('6202001.xls', '6202005.xls')")
  }

  if (is.null(path)) {
    warning(paste0(
      "`path` not specified.",
      "\nLooking for ABS time series files in ",
      getwd()
    ))
  }

  if (!is.null(cat_no) && !is.character(cat_no)) {
    stop("If `cat_no` is specified, it must be a string such as '6202.0'")
  }

  if (!is.logical(metadata) || length(metadata) != 1L || is.na(metadata)) {
    stop("`metadata` argument must be either TRUE or FALSE")
  }

  # Retrieve cache if available
  if (is.null(filenames) && isTRUE(use_fst) && fst_available(cat_no, path)) {
    out <- fst::read_fst(path = catno2fst(cat_no = cat_no, path = path))
    return(tibble::as_tibble(out))
  }

  # If catalogue number is specifid, that takes precedence
  if (!is.null(cat_no)) {
    path <- file.path(path, cat_no)

    filenames <- list.files(path = path, pattern = "\\.xls$")

    if (length(filenames) == 0) {
      stop(paste0("Could not find any .xls files in path: '", path, "'"))
    }

    # If cat_no isn't specified and filenames isn't specified,
    # get all files in path
  } else if (is.null(filenames)) {
    message(paste0(
      "`filenames` and `cat_no` not specified. ",
      "Looking for ABS time series files in '",
      path,
      "' and attempting to read all files.",
      "\nSpecify `cat_no` or filenames` if you do not wish to",
      " attempt to import all .xls files in ",
      path
    ))

    # Get a list of all filenames in path, as `filenames` is null

    filenames <- list.files(path = path, pattern = "\\.xls$")

    if (length(filenames) == 0) {
      stop(paste0("Could not find any .xls files in path: '", path, "'"))
    }
  }

  # Create filenames for local ABS time series files

  filenames <- base::basename(filenames)

  # Import data from local spreadsheet(s) to a list
  message("Extracting data from locally-saved spreadsheets")
  # first extract table titles from the time series spreadsheet index
  table_titles <- purrr::map(filenames, extract_abs_tabletitles, path = path)
  # then read in the data
  sheets <- purrr::map2(filenames, table_titles,
    .f = extract_abs_sheets, path = path
  )

  # remove one 'layer' of the list,
  # so that each sheet is its own element in the list
  sheets <- unlist(sheets, recursive = FALSE)

  # tidy the sheets
  sheet <- tidy_abs_list(sheets, metadata = metadata)

  sheet
}
