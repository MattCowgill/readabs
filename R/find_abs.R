# Function still under development

#' Find ABS time series of interest
#'
#' \code{find_abs()} looks in the ABS Time Series Directory for series
#' that match search terms you provide.
#'
#' @param cat_no ABS catalogue number, such as "6202.0".
#'
#' @param cat_desc Description of an ABS product, such as "Labour Force". If `cat_no` isn't
#' specified, `cat_desc` must be specified. If `cat_no` is specified, `cat_desc` is ignored.
#'
#' @param find String(s) to search for, such as "unemployment" or c("unemployed", "males", "New South Wales")
#'
#' @return A data frame containing information about time series that match your search term(s).
#'
#' @examples
#'
#' \donttest{
#'  wpi <- find_abs(cat_no = "6345.0", find = c("private", "New South Wales", "excluding bonuses"))
#'
#' }
#'
#' @import dplyr
#' @name find_abs
#'
#' @export

find_abs <- function(cat_no = NULL, cat_desc = NULL, find = NULL){

  Description=TableTitle=SeriesID=ProductNumber=ProductTitle=SeriesStart=SeriesEnd=ProductURL=NULL
  ProductReleaseDate=Desc_Table=NULL

  if(is.null(find)){
    stop("You haven't supplied a value to `find`. You need to tell find_abs() what to search for.")
  }

  find <- tolower(find)

  if(is.null(cat_no) & is.null(cat_desc)){
    stop("You must specify either `cat_no` or `cat_desc` to tell find_abs() where to look.")
  }

  if(!is.null(cat_no) & !is.null(cat_desc)){
    message("You've specified both `cat_no` and `cat_desc`. find_abs() will ignore the value given to `cat_desc` and look in `cat_no`")
  }

  # Download XML from ABS Time Series Directory
  base_url <- "http://ausstats.abs.gov.au/servlet/TSSearchServlet?"

  param_url <- ifelse(!is.null(cat_no),
                      paste0("catno=", cat_no),
                      paste0("ptitle=", cat_desc))

  url <- paste0(base_url, param_url)

  xml_dfs <- get_abs_xml_metadata(url = url, release_dates = "all")

  # Only want one row per unique ID, the latest
  xml_dfs <- xml_dfs %>%
    dplyr::group_by(SeriesID) %>%
    dplyr::filter(ProductReleaseDate == max(ProductReleaseDate)) %>%
    dplyr::ungroup()

  # Filter, leaving rows where all elements of `find` are included in 'Description' and/or 'TableTitle'

  # from https://stackoverflow.com/questions/45374799/is-it-possible-to-use-an-and-operator-in-grepl?noredirect=1&lq=1
  regex_to_find <- paste0("(?=.*", find, ")", collapse = "")

  xml_dfs <- xml_dfs %>%
    dplyr::mutate(Desc_Table = tolower(paste(Description, TableTitle, sep = " "))) %>%
    dplyr::filter(grepl(regex_to_find, Desc_Table, perl = TRUE)) %>%
    dplyr::select(ProductNumber, ProductTitle, TableTitle, Description, SeriesID, SeriesStart, SeriesEnd)

  xml_dfs

}

