#' @name read_awe
#' @description Convenience function to obtain wage levels from ABS
#' 6302.0, Average Weekly Earnings, Australia.
#' @title read_awe
#' @param wage_measure Character of length 1. Must be one of:
#' \describe{
#'   \item{`awote`}{ Average weekly ordinary time earnings; also known as Full-time adult ordinary time earnings}
#'   \item{`ftawe`}{ Full-time adult total earnings}
#'   \item{`awe`}{ Average weekly total earnings of all employees}
#' }
#' @param sex Character of length 1. Must be one of: `persons`, `males`, or `females`.
#' @param sector Character of length 1. Must be one of: `total`, `private`, or
#' `public`. Note that you cannot get sector-by-state data; if `state` is not
#' `all` then `sector` must be `total`.
#' @param state Character of length 1. Must be one of: `all`, `nsw`, `vic`, `qld`,
#' `sa`, `wa`, `nt`, or `act`. Note that you cannot get sector-by-state data;
#' if `sector` is not `total` then `state` must be `all`.
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
#' The data is nominal and seasonally adjusted.
#'
#' @examples
#' \dontrun{
#' read_awe("awote", "persons")
#' }
#'
#' @export
read_awe <- function(wage_measure = c(
                       "awote",
                       "ftawe",
                       "awe"
                     ),
                     sex = c(
                       "persons",
                       "males",
                       "females"
                     ),
                     sector = c(
                       "total",
                       "private",
                       "public"
                     ),
                     state = c(
                       "all",
                       "nsw",
                       "vic",
                       "qld",
                       "sa",
                       "wa",
                       "tas",
                       "nt",
                       "act"
                     ),
                     na.rm = FALSE,
                     path = Sys.getenv("R_READABS_PATH", unset = tempdir()),
                     show_progress_bars = FALSE,
                     check_local = FALSE) {
  .wage_measure <- match.arg(wage_measure)
  .sex <- match.arg(sex)
  .sector <- match.arg(sector)
  .state <- match.arg(state)

  check_abs_connection()

  if (.sector != "total" &
    .state != "all") {
    stop(
      'You cannot get sector-by-state data. Either set sector to "total"',
      ' or state to "all".'
    )
  }

  if (.state == "all") {
    tables <- switch(.sector,
      "total" = "2",
      "private" = "5",
      "public" = "8"
    )

    if (.sector == "total") {
      crosstab_name <- ""
    } else {
      crosstab_name <- "sector"
    }
  } else {
    tables <- switch(.state,
      "nsw" = "12a",
      "vic" = "12b",
      "qld" = "12c",
      "sa" = "12d",
      "wa" = "12e",
      "tas" = "12f",
      "nt" = "12g",
      "act" = "12h"
    )

    crosstab_name <- "state"
  }

  awe_latest <- suppressMessages(read_abs(
    cat_no = "6302.0",
    tables = tables,
    path = path,
    show_progress_bars = show_progress_bars,
    check_local = check_local
  ))

  awe_latest <- tidy_awe(df = awe_latest)

  # awe_old is an internal data object created in /data-raw
  awe_old_table <- bind_rows(awe_old[tables])

  awe_old_table <- awe_old_table %>%
    dplyr::filter(!.data$date %in% awe_latest$date)

  awe <- dplyr::bind_rows(awe_old_table, awe_latest)

  awe <- awe %>%
    filter(
      .data$sex == .sex,
      .data$wage_measure == .wage_measure
    )

  if (isFALSE(na.rm)) {
    # Pad to ensure data is quarterly
    missing_dates <- expand.grid(
      month = unique(format(awe$date, "%m")),
      year = unique(format(awe$date, "%Y")),
      day = 15,
      sex = .sex,
      wage_measure = .wage_measure,
      stringsAsFactors = FALSE
    ) %>%
      dplyr::mutate(date = as.Date(paste(.data$year,
        .data$month,
        .data$day,
        sep = "-"
      ))) %>%
      dplyr::filter(!date %in% awe$date &
        date > min(awe$date) &
        date < max(awe$date)) %>%
      mutate(value = NA_real_) %>%
      dplyr::select(dplyr::any_of(c("date", "sex", "wage_measure", "value", "crosstab")))

    if (!is.null(awe[["crosstab"]])) {
      missing_dates$crosstab <- unique(awe$crosstab)
    }

    awe <- missing_dates %>%
      dplyr::bind_rows(awe) %>%
      dplyr::as_tibble()
  } else {
    awe <- awe %>%
      dplyr::filter(!is.na(.data$value))
  }

  names(awe)[names(awe) == "crosstab"] <- crosstab_name

  if (!is.null(awe[["state"]])) {
    awe <- awe %>%
      dplyr::mutate(state = dplyr::case_when(
        state == "new south wales" ~ "nsw",
        state == "victoria" ~ "vic",
        state == "queensland" ~ "qld",
        state == "south australia" ~ "sa",
        state == "western australia" ~ "wa",
        state == "tasmania" ~ "tas",
        state == "northern territory" ~ "nt",
        state == "australian capital territory" ~ "act"
      ))
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
    dplyr::select("series", "date", "value")

  df <- df %>%
    dplyr::mutate(
      series = fast_str_squish(.data$series),
      series = stringi::stri_replace_all_fixed(.data$series, " ;", ";")
    )

  # Usually the cross tab (eg. state, sector) is at the end of the series string;
  # For fun, sometimes the ABS puts it as the second element!
  df <- df %>%
    tidyr::separate(.data$series,
      into = c("earnse_crosstab1", "series"),
      sep = "(?=Males|Females|Persons;)",
      extra = "merge",
      fill = "right"
    )

  df <- df %>%
    tidyr::separate(.data$earnse_crosstab1,
      into = c("earnse", "crosstab1"),
      sep = ";",
      extra = "merge",
      fill = "right"
    )

  df <- df %>%
    tidyr::separate(.data$series,
      into = c(
        "sex_measure",
        "crosstab2"
      ),
      sep = "earnings;",
      extra = "merge",
      fill = "right"
    )

  df <- df %>%
    dplyr::mutate(
      crosstab = paste0(.data$crosstab1, .data$crosstab2),
      crosstab = fast_str_squish(.data$crosstab),
      crosstab = dplyr::if_else(.data$crosstab == "",
        NA_character_,
        .data$crosstab
      )
    )

  df <- df %>%
    mutate(crosstab = stringi::stri_replace_all_fixed(.data$crosstab, " sector", ""))

  df <- df %>%
    # Drop the crosstab column if it's full of NAs
    dplyr::select_if(~ all(!is.na(.))) %>%
    dplyr::select(-"crosstab1", -"crosstab2")

  df <- df %>%
    tidyr::separate(.data$sex_measure,
      into = c("sex", "measure"),
      sep = ";",
      extra = "merge",
      fill = "right"
    )

  fix_col <- function(col) {
    col <- gsub(";", "", col, fixed = TRUE)
    col <- tolower(col)
    col <- fast_str_squish(col)
    col
  }

  df <- df %>%
    dplyr::mutate(dplyr::across(
      dplyr::any_of(c("earnse", "sex", "measure", "crosstab")),
      fix_col
    ))

  # Some sheets contain standard errors of estimates; we want to drop these
  df <- df %>%
    dplyr::filter(.data$earnse == "earnings") %>%
    dplyr::select(-"earnse")

  df <- df %>%
    dplyr::mutate(
      wage_measure = dplyr::case_when(
        .data$measure == "full time adult ordinary time" ~ "awote",
        .data$measure == "full time adult total" ~ "ftawe",
        .data$measure == "total" ~ "awe",
        TRUE ~ NA_character_
      )
    )

  df <- df %>%
    dplyr::select(dplyr::any_of(c("date", "sex", "wage_measure", "value", "crosstab")))

  df
}
