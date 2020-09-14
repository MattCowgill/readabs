#' Experimental helper function to download ABS data cubes that are not compatible with read_abs.
#'
#' \code{download_abs_data_cube()} downloads ABS data cubes based on the catalogue number and cube.
#' The function downloads the file to disk.
#' In comparison to \code{read_abs()} this function doesn't tidy the data.
#'
#' @param cat_no ABS catalogue number, as a string, including the extension.
#' For example, Labour Force, Australia, Detailed, Quarterly is "6291.0.55.003".
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
#' @param latest logical. If `TRUE` (the default), the function tries to find the latest release.
#'
#' @param date character. If `latest` is set to `FALSE` the function will attempt to download the
#' files on the page specified by that date.
#' The format of the date should match the format on the human readable ABS website,
#' e.g. "Feb 2020" for Catalogue Number 6291.0.55.003.
#'
#' @examples
#'
#' \dontrun{download_abs_data_cube(cat_no = "6291.0.55.003",
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
download_abs_data_cube <- function(cat_no,
                                   cube,
                                   path = Sys.getenv("R_READABS_PATH", unset = tempdir()),
                                   latest = TRUE,
                                   date = NULL) {


  if(latest == FALSE & is.null(date)) {stop("latest is false and date is NULL. Please supply a value for date.")}

  #check if path is valid
  if(!dir.exists(path)){stop("path does not exist. Please create a folder.")}


  #Download the page showing all the releases for that catalogue number
  releases_url <- glue::glue("https://www.abs.gov.au/AUSSTATS/abs@.nsf/second+level+view?ReadForm&prodno={cat_no}&&tabname=Past%20Future%20Issues")

  releases_page <- xml2::read_html(releases_url)

  #Parse table of all releases
  releases_table <- tibble::tibble(release = releases_page %>%  rvest::html_nodes("#mainpane a") %>% rvest::html_text(),
                                   url_suffix = releases_page %>%  rvest::html_nodes("#mainpane a") %>% rvest::html_attr("href"))

  #Get the page for the latest data
  if(latest == TRUE){
    date <- releases_table %>%
      dplyr::filter(grepl("(Latest)", .data$release)) %>%
      dplyr::pull(.data$release) %>%
      stringr::str_remove(" \\(Latest\\)") %>%
      stringr::str_extract("Week ending \\d+\\s{1}\\w+ \\d+$|(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?).*") %>%
      stringr::str_replace_all(" ", "%20")
  }

  # If latest is not true then format the date
  if(latest != TRUE){
    date <-  stringr::str_replace_all(date, " ", "%20")

  }

  #find download page
  download_url <- glue::glue("https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/{cat_no}{date}?OpenDocument")

  #Try to download the page
  download_page <- tryCatch(
    xml2::read_html(download_url),
    error=function(cond) {
      message(paste("URL does not seem to exist:", download_url))
      if(!is.null(date)){message("Check that date is formatted correctly.")}
      message("Here's the original error message:")
      message(cond)
      # Choose a return value in case of error
      return(NA)}
  )

  #Find the url for the download
  download_url_suffix <- tibble::tibble(url = download_page %>% rvest::html_nodes("a") %>% rvest::html_attr("href")) %>%
    dplyr::filter(grepl(tolower(cube), url)) %>%
    dplyr::slice(1) %>% #this gets the first result which is typically the .xlsx file rather than the zip
    dplyr::pull(url)

  #Checkt that there is a match

  if(length(download_url_suffix) == 0) {stop("No matching cube. Please check against ABS website.")}


  #==================download file======================
  file_url <- glue::glue("https://www.abs.gov.au{download_url_suffix}")

  download_object <- httr::GET(file_url)

  #save file path to disk

  filename <- basename(download_object$url)

  filepath <- file.path(path, filename)

  writeBin(httr::content(download_object, "raw"), filepath)

  message("File downloaded in ", filepath)

  return(invisible(filepath))

}
