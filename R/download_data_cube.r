#' Experimental helper function to download ABS data cubes that are not compatible with read_abs.
#'
#' @description
#' `r lifecycle::badge("experimental")`
#' \code{download_abs_data_cube()} downloads the latest ABS data cubes based on the catalogue name (from the website url) and cube.
#' The function downloads the file to disk.
#'
#' Unlike \code{read_abs()}, this function doesn't import or tidy the data.
#' Convenience functions are provided to import and tidy key data cubes; see
#' \code{?read_payrolls()} and \code{?read_lfs_grossflows()}.
#'
#' @param catalogue_string ABS catalogue name as a string from the ABS website.
#' For example, Labour Force, Australia, Detailed is "labour-force-australia-detailed".
#' The possible catalogues can be obtained using the helper function \code{show_available_catalogues()};
#' or search these catalogues using \code{search_catalogues()},
#'
#' @param cube character. A character string that is either the complete filename or (uniquely) in the filename of the data cube you want to
#' download, e.g. "EQ09". The available filenames can be obtained using the helper function \code{get_available_files()}
#'
#' @param path Local directory in which downloaded files should be stored. By default, `path`
#'  takes the value set in the environment variable "R_READABS_PATH".
#'  If this variable is not set, any files downloaded
#'  will be stored in a temporary directory (\code{tempdir()}).
#'  See \code{Details} below for  more information.
#'
#' @examples
#' \dontrun{
#' download_abs_data_cube(
#'   catalogue_string = "labour-force-australia-detailed",
#'   cube = "EQ09"
#' )
#' }
#'
#' @details `download_abs_data_cube()` downloads an Excel spreadsheet from the ABS.
#'
#' The file need to be saved somewhere on your disk.
#' This local directory can be controlled using the `path` argument to
#' `read_abs()`. If the `path` argument is not set, `read_abs()` will store
#' the files in a directory set in the "R_READABS_PATH" environment variable.
#' If this variable isn't set, files will be saved in a temporary directory.
#'
#' To check the value of the "R_READABS_PATH" variable, run
#' \code{Sys.getenv("R_READABS_PATH")}. You can set the value of this variable
#' for a single session using \code{Sys.setenv(R_READABS_PATH = <path>)}.
#' If you would like to change this variable for all future R sessions, edit
#' your `.Renviron` file and add \code{R_READABS_PATH = <path>} line.
#' The easiest way to edit this file is using \code{usethis::edit_r_environ()}.
#'
#' The filepath is returned invisibly which enables piping to \code{unzip()} or \code{readxl::read_excel}.
#'
#' @importFrom dplyr %>%
#' @importFrom glue glue
#' @importFrom dplyr filter pull slice
#' @importFrom rvest html_nodes html_attr html_text
#' @importFrom httr GET
#'
#' @export
#' @family data cube functions
#'
download_abs_data_cube <- function(catalogue_string,
                                   cube,
                                   path = Sys.getenv("R_READABS_PATH", unset = tempdir())) {
  # check if path is valid
  if (!dir.exists(path)) {
    stop("path does not exist. Please create a folder.")
  }

  check_abs_connection()

  available_cubes <- get_available_files(catalogue_string)

  cube <- if_else(cube == "MRM1",
                  "MRM1|MRM%201",
                  cube)

  file_download_url <- available_cubes %>%
    dplyr::filter(grepl(cube, file, ignore.case = TRUE)) %>%
    dplyr::slice(1) %>% # this gets the first result which is typically the .xlsx file rather than the zip
    dplyr::pull(url)


  # Check that there is a match

  if (length(file_download_url) == 0) {
    stop(glue("No matching cube. Please check against ABS website at {download_url}."))
  }

  # build file path

  filename <- basename(file_download_url)

  filepath <- file.path(path, filename)

  # download file

  dl_file(
    file_download_url,
    filepath
  )

  message("File downloaded in ", filepath)

  return(invisible(filepath))
}

read_lfs_mrm_table <- function(file, sheet, variable_name) {
  df <- file |>
    readxl::read_excel(
      sheet = sheet,
      skip = 4
    ) |>
    tidyr::pivot_longer(!tidyr::matches("SA4"), names_to = "date", values_to = "value") |>
    dplyr::mutate(date = as.numeric(.data$date)) |>
    dplyr::filter(!is.na({{variable_name}})) |>
    dplyr::mutate(SA4_code = substr(.data$SA4, 1, 3)) |>
    dplyr::mutate(SA4_name = substr(.data$SA4, 5, nchar(.data$SA4))) |>
    dplyr::mutate(
      variable = variable_name,
      date = as.Date(.data$date, origin = "1899-12-30")
    )
  df[, c("SA4_code", "SA4_name", "variable", "date", "value")]
}

read_lfs_mrm <- function(file) {
  bind_rows(
    read_lfs_mrm_table(file, "Table 1", "employed_persons_000s"),
    read_lfs_mrm_table(file, "Table 2", "unemployed_persons_000s"),
    read_lfs_mrm_table(file, "Table 3", "nilf_persons_000s"),
    read_lfs_mrm_table(file, "Table 4", "emp_to_pop_ratio"),
    read_lfs_mrm_table(file, "Table 5", "unemployment_rate"),
    read_lfs_mrm_table(file, "Table 6", "participation_rate")
  )
}

#' Convenience function to download and tidy data cubes from
#' ABS Labour Force, Australia, Detailed.
#' @param cube character. A character string that is either the complete filename
#' or (uniquely) in the filename of the data cube you want to download. Use
#' `get_available_lfs_cubes()` to see a dataframe of options.
#' @param path Local directory in which downloaded files should be stored.
#' @return A tibble with the data from the data cube. Columns names are
#' tidied and dates are converted to Date class.
#' @examples
#' read_lfs_datacube("EQ02")
#' @export
read_lfs_datacube <- function(cube,
                              path = Sys.getenv("R_READABS_PATH", unset = tempdir())) {
  options(timeout = 180)
  file <- download_abs_data_cube(
    catalogue_string = "labour-force-australia-detailed",
    cube = cube,
    path = path
  )

  if (cube == "MRM" || cube == "MRM1") {
    df <- read_lfs_mrm(file)
  } else {
    df <- file |>
      readxl::read_excel(
        sheet = "Data 1",
        skip = 3
      ) |>
      rename(date = 1) %>%
      mutate(date = as.Date(date))

    colnames(df) <- tolower(colnames(df))
    colnames(df) <- gsub(" |-|:", "_", colnames(df))
    colnames(df) <- gsub("\\(|\\)|\\'", "", colnames(df))
  }

  df
}

#' Show the available Labour Force, Australia, detailed data cubes that can be
#' downloaded
#' @export
#' @details Intended to be used with \code{read_lfs_datacube()}. Call
#' \code{read_lfs_datacube()} interactively, find the table of interest
#' (eg. "LM1"), then use `read_lfs_datacube()`.
#' @examples
#'
#' get_available_lfs_cubes()
#'
get_available_lfs_cubes <- function() {
  all_files <- get_available_files("labour-force-australia-detailed")

  all_files %>%
    dplyr::filter(
      substr(file, 1, 1) != "6",
      !grepl("zip", file)
    )
}
