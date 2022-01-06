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
#'  \item{"gccsa_jobs"}{ Payroll jobs by Greater Capital City Statistical
#'  Area (Table 5)}
#'  \item{"sex_age_jobs}{ Payroll jobs by sex and age (Table 8)}
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
                            "empsize_jobs",
                            "gccsa_jobs",
                            "sex_age_jobs"
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
    "empsize_jobs" = "DO007",
    "gccsa_jobs" = "DO005",
    "sex_age_jobs" = "DO008"
  )

  safely_download_cube <- purrr::safely(.f = ~ download_abs_data_cube(
    catalogue_string = "weekly-payroll-jobs-and-wages-australia",
    cube = cube_name,
    path = path
  ))

  cube_path <- safely_download_cube()

  if (!is.null(cube_path$error)) {
    # Attempt to download requested cube from PREVIOUS payrolls release
    # Necessary because (for the time being) not all tables are included
    # in each release

    attempted_prev_payrolls <- download_previous_payrolls(
      cube_name,
      path
    )

    if (is.null(attempted_prev_payrolls$error)) {
      print("Using table from previous payrolls release")
      cube_path <- attempted_prev_payrolls
    } else {
      stop("Could not download ABS payrolls data.")
    }
  }

  cube_path <- cube_path$result

  sheet_name <- switch(series,
    "industry_jobs" = "Payroll jobs index",
    "industry_wages" = "Total wages index",
    "sa4_jobs" = "SA4",
    "sa3_jobs" = "SA3",
    "subindustry_jobs" = "Payroll jobs index-Subdivision",
    "empsize_jobs" = "Employment size",
    "gccsa_jobs" = "GCCSA",
    "sex_age_jobs" = "5 year age groups"
  )

  cube <- read_payrolls_local(
    cube_path = cube_path,
    sheet_name = sheet_name,
    series = series
  )

  cube
}

#' @keywords internal
#' @param cube_path Path + filename (incl. extension) to ABS payrolls data cube
#' @param sheet_name Name of the sheet on the Excel cube to import
#' @param series "wages" or "jobs" (the default)
#' @noRd

read_payrolls_local <- function(cube_path, sheet_name, series = "jobs") {
  sheets_present <- readxl::excel_sheets(cube_path)
  sheets_present <- sheets_present[!sheets_present == "Contents"]

  sheet_to_read <- sheets_present[grepl(sheet_name,
    sheets_present,
    ignore.case = TRUE
  )]

  safely_read_excel <- purrr::safely(read_excel)

  read_attempt <- safely_read_excel(cube_path,
    sheet = sheet_to_read,
    col_types = "text",
    skip = 5
  )

  if (is.null(read_attempt$error)) {
    cube <- read_attempt$result
  } else {
    stop(
      "Could not find a sheet called '", sheet_name, "' in the payrolls ",
      "workbook ", cube_path, ". Sheets present are: ",
      paste0(sheets_present, collapse = ", ")
    )
  }


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
    # Note that some NA values are hardcoded as "N/A" or similar by the ABS
    dplyr::mutate(value = suppressWarnings(as.numeric(.data$value))) %>%
    dplyr::filter(.data$value != "NA")

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


#' This function is temporarily necessary while the readabs maintainer
#' attempts to resolve an issue with the ABS. The ABS as at late March 2021
#' stopped including Table 5 of the Weekly Payrolls release with each new
#' release of the data. This function finds the link from the previous
#' release and attemps to download it. This function will no longer be required
#' if/when the ABS reverts to the previous release arrangements. The function
#' is internal and is called by `read_payrolls()`.
#' @param cube_name eg. DO005 for table 5
#' @param path Directory in which to download payrolls cube
#' @keywords internal
#' @return A list containing two elements: `result` (will contain path + filename
#' to downloaded file if download was successful); and `error` (NULL if file
#' downloaded successfully; character otherwise).
download_previous_payrolls <- function(cube_name,
                                       path) {
  latest_payrolls_url <- "https://www.abs.gov.au/statistics/labour/earnings-and-work-hours/weekly-payroll-jobs-and-wages-australia/latest-release"
  prev_payrolls_css <- "#release-date-section > div.field.field--name-dynamic-block-fieldnode-previous-releases.field--type-ds.field--label-hidden > div > div > ul > li:nth-child(1) > a"

  temp_page_location <- file.path(tempdir(), "temp_readabs.html")
  dl_file(latest_payrolls_url, temp_page_location)

  prev_payrolls_url <- rvest::read_html(temp_page_location) %>%
    rvest::html_element(prev_payrolls_css) %>%
    rvest::html_attr("href")

  prev_payrolls_url <- paste0("https://www.abs.gov.au/", prev_payrolls_url)

  temp_page_location <- file.path(tempdir(), "temp_readabs.html")
  dl_file(prev_payrolls_url, temp_page_location)

  prev_payrolls_page <- rvest::read_html(temp_page_location)

  prev_payrolls_excel_links <- prev_payrolls_page %>%
    rvest::html_elements(".file--x-office-spreadsheet a") %>%
    rvest::html_attr("href")

  table_link <- prev_payrolls_excel_links[grepl(
    cube_name,
    prev_payrolls_excel_links
  )]

  if (length(table_link) == 0) {
    stop("Could not find URL for requested cube in previous payrolls release")
  } else if (length(table_link) > 1) {
    stop("Found multiple patching URLs for the requested cube in previous payrolls release")
  }

  safely_download <- purrr::safely(dl_file)

  full_path <- file.path(path, basename(table_link))

  dl_result <- safely_download(
    url = table_link,
    destfile = full_path,
    mode = "wb"
  )

  out <- list(
    result = NULL,
    error = NULL
  )


  if (is.null(dl_result$error)) {
    out$result <- full_path
  } else {
    out$error <- "Could not download payrolls"
  }

  return(out)
}
