#' Experimental helper function to download ABS data cubes that are not compatible with read_abs.
#'
#' \code{download_abs_data_cube()} downloads the latest ABS data cubes based on the catalogue name (from the new website url) and cube.
#' The function downloads the file to disk.
#' In comparison to \code{read_abs()} this function doesn't tidy the data.
#'
#' @param catalogue_string ABS catalogue name as a string from the new website.
#' For example, Labour Force, Australia, Detailed is "labour-force-australia-detailed".
#'
#' @param cube character. A character string that is in the filename of the data cube you want to
#' download, e.g. "EQ09".
#'
#' @param path Local directory in which downloaded files should be stored. By default, `path`
#'  takes the value set in the #' environment variable "R_READABS_PATH".
#'  If this variable is not set, #' any files downloaded by read_abs()
#'  will be stored in a temporary directory #' (\code{tempdir()}).
#'  See \code{Details} below for #' more information.
#'
#'
#' @examples
#'
#' \dontrun{download_abs_data_cube(catalogue_string = "labour-force-australia-detailed",
#'                                         cube = "EQ09")}
#'
#' @details `download_abs_data_cube()` downloads a file from the ABS containing a data cube.
#' These files need to be saved somewhere on your disk.
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
#' The filepath is returned invisibly which enables piping to \code{unzip()} or \code{reaxl::read_excel}.
#'
#' @importFrom dplyr %>%
#' @importFrom glue glue
#' @importFrom xml2 read_html
#' @importFrom dplyr filter pull slice
#' @importFrom tibble tibble
#' @importFrom rvest html_nodes html_attr html_text
#' @importFrom stringr str_remove str_extract str_replace_all
#' @importFrom httr GET
#'
#' @export
#'
#'
download_abs_data_cube <- function(catalogue_string,
                                   cube,
                                   path = Sys.getenv("R_READABS_PATH", unset = tempdir())) {

  #check if path is valid
  if(!dir.exists(path)){stop("path does not exist. Please create a folder.")}


  download_lookup_table <- filter(abs_lookup_table,
                         catalogue == catalogue_string)

  download_url <- pull(download_lookup_table, url)

  if(length(download_url) == 0) {stop(glue("No matching catalogue. Please check against ABS website."))}


  #Try to download the page
  download_page <- tryCatch(
    xml2::read_html(download_url),
    error=function(cond) {
      message(paste("URL does not seem to exist:", download_url))
      message("Here's the original error message:")
      message(cond)
      # Choose a return value in case of error
      return(NA)}
  )

  #Find the url for the download
  file_download_url <- tibble::tibble(url = download_page %>% rvest::html_nodes("a") %>% rvest::html_attr("href")) %>%
    dplyr::filter(grepl(cube, url, ignore.case = TRUE)) %>%
    dplyr::slice(1) %>% #this gets the first result which is typically the .xlsx file rather than the zip
    dplyr::pull(url)


  #Check that there is a match

  if(length(file_download_url) == 0) {stop(glue("No matching cube. Please check against ABS website at {download_url}."))}


  #==================download file======================
  download_object <- httr::GET(file_download_url)

  #save file path to disk

  filename <- basename(download_object$url)

  filepath <- file.path(path, filename)

  writeBin(httr::content(download_object, "raw"), filepath)

  message("File downloaded in ", filepath)

  return(invisible(filepath))

}
