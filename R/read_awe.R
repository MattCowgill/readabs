#' @name read_awe
#' @description Convenience function to obtain wage levels from ABS
#' 6302.0, Average Weekly Earnings, Australia.
#' @title read_awe
#' @param wage_measure Character. Must be one of:
#' \itemize{
#'   \item{`awote`}{ Average weekly ordinary time earnings; also known as Full-time adult ordinary time earnings}
#'   \item{`ftawe`}{ Full-time adult total earnings}
#'   \item{`awe`}{ Average weekly total earnings of all employees}
#' }
#' @param sex Character. Must be one of: `persons`, `males`, or `females`.
#' @param na.rm Logical. `FALSE` by default. If `FALSE`, a consistent quarterly
#' series is returned, with `NA` values for quarters in which there is no data.
#' If `TRUE`, only dates with data are included in the returned data frame.
#' @param path See `?read_abs`
#' @param show_progress_bars See `?read_abs`
#' @param check_local See `?read_abs`
#' @details
#' The latest AWE data is available using `read_abs(cat_no = "6302.0", tables = 2)`.
#' However, this time series only goes back to 2012, when the ABS switched
#' from quarterly to biannual collection and release of the AWE data. The
#' `read_awe()` function assembles on time series back to November 1983 quarter;
#' it is quarterly to 2012 and biannual from then. Note that the data
#' returned with this function is consistently quarterly; any quarters for
#' which there are no observations are recorded as `NA` unless `na.rm` = `TRUE`.
#' @return
#' A `tbl_df` with four columns: `date`, `sex`, `wage_measure` and `value`.
#' The data is nominal (ie. not inflation-adjusted).
#'
#' @examples
#' \dontrun{
#' read_awe("awote", "persons")
#' }
#'
#' @export
read_awe <- function(wage_measure = c("awote",
                                      "ftawe",
                                      "awe"),
                     sex = c("persons",
                             "males",
                             "females"),
                     na.rm = FALSE,
                     path = Sys.getenv("R_READABS_PATH", unset = tempdir()),
                     show_progress_bars = FALSE,
                     check_local = FALSE) {

  .wage_measure <- match.arg(wage_measure)
  .sex <- match.arg(sex)
  check_abs_connection()

  awe_latest <- suppressMessages(read_abs(cat_no = "6302.0",
                                          tables = 2,
                                          path = path,
                                          show_progress_bars = show_progress_bars,
                                          check_local = check_local))

  awe_latest <- tidy_awe(df = awe_latest)

  # awe_old is an internal data object created in /data-raw
  awe_old <- awe_old %>%
    dplyr::filter(!.data$date %in% awe_latest$date)

  awe <- dplyr::bind_rows(awe_old, awe_latest)

  awe <- awe %>%
    filter(.data$sex == .sex,
           .data$wage_measure == .wage_measure)

  if (isFALSE(na.rm)) {
    # Pad to ensure data is quarterly
    missing_dates <- expand.grid(month = unique(format(awe$date, "%m")),
                year = unique(format(awe$date, "%Y")),
                day = 15,
                sex = .sex,
                wage_measure = .wage_measure,
                stringsAsFactors = FALSE) %>%
      dplyr::mutate(date = as.Date(paste(.data$year,
                                         .data$month,
                                         .data$day,
                                         sep = "-"))) %>%
      dplyr::filter(!date %in% awe$date &
                      date > min(awe$date) &
                      date < max(awe$date)) %>%
      mutate(value = NA_real_) %>%
      dplyr::select(.data$date, .data$sex, .data$wage_measure, .data$value)

    awe <- missing_dates %>%
      dplyr::bind_rows(awe) %>%
      dplyr::as_tibble()
  } else {
    awe <- awe %>%
      dplyr::filter(!is.na(.data$value))
  }

  awe <- awe %>%
    dplyr::arrange(.data$date)

  awe
}


#' Internal function to tidy a dataframe from ABS 6302
#' @param df Data frame containing table 2 from ABS 6302, imported using `read_abs()`
#' @keywords internal
tidy_awe <- function(df) {

  df <- df %>%
    dplyr::select(.data$series, .data$date, .data$value) %>%
    tidyr::separate(.data$series,
                    into = c("earnings", "sex", "measure"),
                    sep = ";",
                    extra = "merge",
                    fill = "right")

  df$measure <- gsub(";", "", df$measure, fixed = TRUE)
  df$measure <- tolower(df$measure)
  df$measure <- stringr::str_squish(df$measure)

  df$sex <- stringr::str_squish(df$sex)
  df$sex <- tolower(df$sex)

  df <- df %>%
    dplyr::mutate(
      wage_measure = dplyr::case_when(
        measure == "full time adult ordinary time earnings" ~ "awote",
        measure == "full time adult total earnings" ~ "ftawe",
        measure == "total earnings" ~ "awe",
        TRUE ~ NA_character_
      )) %>%
    dplyr::select(.data$date, .data$sex, .data$wage_measure, .data$value)

  df
}
