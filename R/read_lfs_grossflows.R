#' Convenience function to download and import 'gross flows' data cube
#' from the monthly ABS Labour Force survey.
#'
#' The gross flows data cube (GM1) shows estimates of the number of people who
#' transitioned from one labour force status to another between two months.
#'
#' @param weights either `"current"` or "previous". If `current`, figures will
#' use the current month's Labour Force survey weights; if `previous`, the
#' previous month's weights are used.
#' @param path Local directory in which downloaded files should be stored.
#' By default, 'path' takes the value set in the environment variable
#' "R_READABS_PATH". If this variable is not set, any files downloaded by
#' read_abs() will be stored in a temporary directory (tempdir()).
#' See `Details` in \code{?read_abs} for more information.
#' @return A tibble containing data cube GM1 from the monthly Labour Force survey.
#' @export
#' @examples
#' read_lfs_grossflows()


read_lfs_grossflows <- function(weights = c("current",
                                           "previous"),
                                path = Sys.getenv("R_READABS_PATH",
                                                  unset = tempdir())) {

  weights <- match.arg(weights)

  weight_desc <- switch (weights,
    "current" = "current month",
    "previous" = "previous month"
  )

  gf_file <- download_abs_data_cube(catalogue_string = "labour-force-australia",
                                    cube = "gm1",
                                    path = path)

  sheet_name <- switch (weights,
    "current" = "Data 1",
    "previous" = "Data 2"
  )

  raw_sheet <- readxl::read_xlsx(path = gf_file,
                                 sheet = sheet_name,
                                 skip = 4,
                                 col_names = c("date",
                                               "sex",
                                               "age",
                                               "state",
                                               "lfs_current",
                                               "lfs_previous",
                                               "persons"),
                                 col_types = c("date",
                                               "text",
                                               "text",
                                               "text",
                                               "text",
                                               "text",
                                               "numeric"
                                               ))

  gf <- raw_sheet %>%
    mutate(date = as.Date(date,
                          format = "%Y-%m-%d %H-%M-%S"),
           unit = "000s",
           weights = weight_desc)

  # Run some minimal checks on the data frame to ensure its contents are as
  # expected
  stopifnot(check_lfs_grossflows(gf))

  gf
}

#' Internal function to check if the data frame returned by read_lfs_grossflows()
#' contains expected unique values in key columns
#' @param df data frame containing gross flows data
#' @keywords internal
check_lfs_grossflows <- function(df) {

  names_match <- identical(names(df),
                           c("date",
                             "sex",
                             "age",
                             "state",
                             "lfs_current",
                             "lfs_previous",
                             "persons",
                             "unit",
                             "weights"))

  sex_match <- identical(unique(df$sex),
                         c("Males",
                           "Females"))

  age_match <- identical(unique(df$age),
                         c("15-19 years",
                            "20-24 years",
                            "25-29 years",
                            "30-34 years",
                            "35-39 years",
                            "40-44 years",
                            "45-49 years",
                            "50-54 years",
                            "55-59 years",
                            "60-64 years",
                            "65 years and over"))

  lfs_match <- identical(unique(df$lfs_current),
                         c("Employed full-time",
                            "Employed part-time",
                            "Unemployed",
                            "Not in the labour force (NILF)",
                            "Unmatched in common sample (responded in previous month but not in current)",
                            "Outgoing rotation group"))

  all(names_match,
      sex_match,
      age_match,
      lfs_match)
}
