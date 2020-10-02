#' Download a tidy tibble containing the Consumer Price Index from the ABS
#'
#' \code{read_cpi()} uses the \code{read_abs()} function to download, import,
#' and tidy the Consumer Price Index from the ABS. It returns a tibble
#' containing two columns: the date and the CPI index value that corresponds
#' to that date. This makes joining the CPI to another dataframe easy.
#' \code{read_cpi()} returns the original (ie. not seasonally adjusted)
#' all groups CPI for Australia. If you want the analytical series
#' (eg. seasonally adjusted CPI, or trimmed mean CPI), you can use
#' \code{read_abs()}.
#'
#' @param path character; default is "data/ABS". Only used if
#' retain_files is set to TRUE. Local directory in which to save
#' downloaded ABS time series spreadsheets.
#'
#' @param show_progress_bars logical; TRUE by default. If set to FALSE, progress
#' bars will not be shown when ABS spreadsheets are downloading.
#'
#' @param check_local logical; FALSE by default. See \code{?read_abs}.
#'
#' @param retain_files logical; FALSE by default. When TRUE, the spreadsheets
#' downloaded from the ABS website will be saved in the
#' directory specified with 'path'.
#'
#' @examples
#'
#' # Create a tibble called 'cpi' that contains the CPI index
#' # numbers for each quarter
#' \donttest{
#' cpi <- read_cpi()
#' }
#'
#' # This tibble can now be joined to another to help streamline the process of
#' # deflating nominal values.
#' @importFrom dplyr filter select
#'
#' @export

read_cpi <- function(path = Sys.getenv("R_READABS_PATH", unset = tempdir()),
                     show_progress_bars = TRUE,
                     check_local = FALSE,
                     retain_files = FALSE) {
  if (!is.logical(retain_files)) {
    stop("`retain_files` must be either `TRUE` or `FALSE`.")
  }

  if (!is.logical(show_progress_bars)) {
    stop("`show_progress_bars` must be either `TRUE` or `FALSE`")
  }

  if (retain_files == TRUE & !is.character(path)) {
    stop(
      "If `retain_files` is `TRUE`,",
      " you must specify a valid file path in `path`."
    )
  }

  series <- value <- date <- cpi <- NULL

  cpi_raw <- read_abs(
    cat_no = "6401.0",
    tables = 1,
    retain_files = retain_files,
    check_local = check_local,
    show_progress_bars = show_progress_bars,
    path = path
  )

  x <- cpi_raw %>%
    dplyr::filter(
      series == "Index Numbers ;  All groups CPI ;  Australia ;"
    ) %>%
    dplyr::select(date,
      cpi = value
    )

  x
}
