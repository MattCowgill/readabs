#' Download a tidy tibble containing the Consumer Price Index from the ABS
#'
#' \code{read_cpi()} uses the \code{read_abs()} function to download, import,
#' and tidy the quarterly Consumer Price Index from the ABS. It returns a tibble
#' containing two columns: the date and the CPI index value that corresponds
#' to that date. This makes joining the CPI to another dataframe easy.
#' \code{read_cpi()} returns the original (ie. not seasonally adjusted)
#' all groups CPI for Australia. If you want the analytical series
#' (eg. seasonally adjusted CPI, or trimmed mean CPI) or monthly series, you can use
#' \code{read_abs()}.
#'
#' By default, `read_abs()` retrieves the quarterly CPI. It can use the
#' `frequency` argument to change to monthly.
#'
#' @param path character; default is "data/ABS". Only used if
#' retain_files is set to TRUE. Local directory in which to save
#' downloaded ABS time series spreadsheets.
#' @param frequency Either `"quarterly"` (the default) or `"monthly"`.
#' @param ... Arguments passed to `read_abs()`. See `?read_abs` for details.
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

read_cpi <- function(frequency = c("quarterly", "monthly"),
                     path = Sys.getenv("R_READABS_PATH", unset = tempdir()),
                     ...) {

  frequency <- match.arg(frequency)

  cpi_series_id <- switch (frequency,
    "quarterly" = "A2325846C",
    "monthly" = "A130393720C"
  )


  cpi_raw <- read_abs_series(
    series_id = cpi_series_id,
    ...
  )

  series_name <- unique(cpi_raw$series)

  stopifnot(series_name == "Index Numbers ;  All groups CPI ;  Australia ;")

  x <- cpi_raw %>%
    dplyr::select("date",
      "cpi" = "value"
    )

  x
}
