#' Download and tidy ABS payroll jobs and wages data
#'
#' Import a tidy tibble of ABS Weekly Payrolls data.
#'
#' @details The ABS 'Weekly Payroll Jobs and Wages in Australia' dataset
#' is very useful to analysts of the Australian labour market.
#' It draws upon data collected
#' by the Australian Taxation Office as part of its Single-Touch Payroll
#' initiative and supplements the monthly Labour Force Survey. Unfortunately,
#' the data as published by the ABS (1) is not in a standard time series
#' spreadsheet; and (2) is messy in various ways that make it hard to
#' read in R. This convenience function uses `download_abs_data_cube()` to
#' import the payrolls data, and then tidies it up.
#'
#' @param series Character. Must be one of:
#' \itemize{
#'  \item{"industry_jobs"}{ Payroll jobs by industry division, state, sex, and age
#'  group (Table 4)}
#'  \item{"industry_wages"}{ Total wages by industry division, state, sex, and age
#'  group (Table 4)}
#'  \item{"sa4_jobs"}{ Payroll jobs by statistical area 4 (SA4) and state (Table 5)}
#'  \item{"sa3_jobs}{ Payroll jobs by statistical area 4 (SA4), statistical
#'  area 3 (SA3), and state (Table 5)}
#'  \item{"subindustry_jobs"}{ Payroll jobs by industry sub-division and
#'  industry division (Table 6)}
#'  \item{"empsize_jobs"}{ Payroll jobs by size of employer (number of
#'  employees) and state (Table 7)}
#' }
#' The default is "industry_jobs".
#' @return A tidy (long) `tbl_df`. The number of columns differs based on the `series`.
#'
#' @examples
#' \dontrun{
#' # Fetch payroll jobs by industry and state (the default, "industry_jobs")
#' read_payrolls()
#'
#' # Payroll jobs by employer size
#' read_payrolls("empsize_jobs")
#' }
#'
#' @param path Local directory in which downloaded ABS time series
#' spreadsheets should be stored. By default, `path` takes the value set in the
#' environment variable "R_READABS_PATH". If this variable is not set,
#' any files downloaded by read_abs()  will be stored in a temporary directory
#' (\code{tempdir()}).
#'
#' @importFrom rlang .data
#' @export

read_payrolls <- function(series = c(
                            "industry_jobs",
                            "industry_wages",
                            "sa4_jobs",
                            "sa3_jobs",
                            "subindustry_jobs",
                            "empsize_jobs"
                          ),
                          path = Sys.getenv("R_READABS_PATH",
                            unset = tempdir()
                          )) {
  check_abs_connection()

  series <- match.arg(series)

  cube_name <- switch(series,
    "industry_jobs" = "DO004",
    "industry_wages" = "DO004",
    "sa4_jobs" = "DO005",
    "sa3_jobs" = "DO005",
    "subindustry_jobs" = "DO006",
    "empsize_jobs" = "DO007"
  )

  safely_download_cube <- purrr::safely(.f = ~ download_abs_data_cube(
    catalogue_string = "weekly-payroll-jobs-and-wages-australia",
    cube = cube_name,
    path = path
  ))

  cube_path <- safely_download_cube()

  if (!is.null(cube_path$error)) {
    stop("Could not download ABS payrolls data.")
  }

  cube_path <- cube_path$result

  sheet_name <- switch(series,
    "industry_jobs" = "Payroll jobs index",
    "industry_wages" = "Total wages index",
    "sa4_jobs" = "Payroll jobs index-SA4",
    "sa3_jobs" = "Payroll jobs index-SA3",
    "subindustry_jobs" = "Payroll jobs index-Subdivision",
    "empsize_jobs" = "Employment Size"
  )

  cube <- readxl::read_excel(cube_path,
    sheet = sheet_name,
    col_types = "text",
    skip = 5
  )

  to_snake <- function(x) {
    x <- gsub(" ", "_", x)
    tolower(x)
  }

  cube <- cube %>%
    dplyr::rename_with(.fn = ~ dplyr::case_when(
      .x == "State or Territory" ~ "state",
      .x == "Industry division" ~ "industry",
      .x == "Sub-division" ~ "industry_subdivision",
      .x == "Employment size" ~ "emp_size",
      .x == "Sex" ~ "sex",
      .x == "Age group" ~ "age",
      .x == "Statistical Area 4" ~ "sa4",
      .x == "Statistical Area 3" ~ "sa3",
      TRUE ~ to_snake(.x)
    ))

  cube <- cube[!is.na(cube[[1]]), ]

  cube <- cube %>%
    tidyr::pivot_longer(
      cols = dplyr::starts_with("4"),
      names_to = "date",
      values_to = "value"
    )

  cube <- cube %>%
    dplyr::filter(.data$value != "NA") %>%
    dplyr::mutate(value = as.numeric(.data$value))

  cube <- cube %>%
    dplyr::mutate(date = as.Date(as.numeric(.data$date), origin = "1899-12-30"))

  cube <- cube %>%
    dplyr::mutate_if(
      .predicate = is.character,
      .funs = gsub,
      pattern = ".*\\. ",
      replacement = "",
      perl = TRUE
    )

  if (grepl("wages", series)) {
    cube$series <- "wages"
  } else {
    cube$series <- "jobs"
  }

  cube
}
