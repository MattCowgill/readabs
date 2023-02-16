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
#' download, e.g. "EQ09". The available filenames can be obtained using the helper function \code{get_available_filenames()}
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
