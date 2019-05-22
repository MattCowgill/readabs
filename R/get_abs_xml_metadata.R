
#' @importFrom XML xmlParse xmlToList xmlToDataFrame
#' @importFrom utils download.file
#' @import dplyr

# given a catalogue number, download the catalogue metadata via XML, then find
# unique filenames in the latest release and return those

get_abs_xml_metadata <- function(url, release_dates = "latest") {

  if(!release_dates %in% c("latest", "all")){
    stop("`release_dates` argument in get_abs_xml_metadata() must be either 'latest' or 'all'")
  }

  if(!is.character(url)){
    stop("`url` argument to get_abs_xml_metadata() must be a string.")
  }


  ProductReleaseDate=TableOrder=text=cat_no=NULL

  # Download the first page of metadata
  first_url <- paste0(url,
                      "&pg=1")

  # Some ABS Time Series in the directory start with a leading zero, as in
  # Table 01 rather than Table 1; the 0 needs to be included. Here we first test
  # for a readable XML file using the table number supplied (eg. "1"); if that
  # doesn't work then we try with a leading zero ("01"). If that fails, it's an error.

  first_page_location <- file.path(tempdir(), "temp_readabs_xml.xml")

  utils::download.file(first_url, first_page_location, quiet = TRUE)

  first_page <- XML::xmlParse(first_page_location)

  first_page_list <- XML::xmlToList(first_page)

  first_url_works <- ifelse(!is.null(first_page_list), TRUE, FALSE)

  if(!first_url_works){
    if(!grepl("ttitle", first_url)) { # this is the case when tables == "all"
      stop(paste0("Cannot find valid entry for cat_no ", cat_no, " in the ABS Time Series Directory. Check that the cat. no. is correct, and that it contains time series spreadsheets (not data cubes)."))
    }

    # now try prepending a 0 on the ttitle

    first_url <- gsub("ttitle=", "ttitle=0", first_url)

    utils::download.file(first_url, first_page_location, quiet = TRUE)

    first_page <- XML::xmlParse(first_page_location)

    first_page_list <- XML::xmlToList(first_page)

    first_url_works <- ifelse(!is.null(first_page_list), TRUE, FALSE)

    if(first_url_works){
      url <- gsub("ttitle=", "ttitle=0", url)

    } else {
      stop(paste0("Cannot find valid entry for cat_no ", cat_no, " in the ABS Time Series Directory"))
    }

  }


  if(is.null(first_page_list$NumPages)){
    tot_pages <- 1
  } else {
    tot_pages <- as.numeric(first_page_list$NumPages)
  }

  if(!is.numeric(tot_pages)){
    stop("Can't tell how many pages of XML match your query in get_abs_xml_metadata()")
  }

  all_pages <- sort(seq(as.numeric(tot_pages):1), decreasing = TRUE)

  # Extract the date on the first page of the metadata (it'll be the oldest in the directory)
  first_page_df <- XML::xmlToDataFrame(first_page, stringsAsFactors = FALSE)

  max_date <- max(as.Date(first_page_df$ProductReleaseDate, format = "%d/%m/%Y"),
                  na.rm = TRUE)

  # create list of URLs of XML metadata to scrape
  full_urls <- paste0(url, "&pg=", all_pages)

  # if release_dates = "all" then we get all pages of metadata;
  # if release_dates = "latest" then we begin at the last page of metadata
  # and loop backwards through each page, extracting each page as a data frame,
  # until the release date of the data is not the maximum date, then stop

  i <- 1
  current <- TRUE
  xml_dfs <- list()
  while(current == TRUE){

    xml_df <- get_xml_df(url = full_urls[i])

    xml_dfs[[i]] <- xml_df


    if(release_dates == "latest"){
      date_in_df <- max(as.Date(xml_df$ProductReleaseDate, format = "%d/%m/%Y"),
                        na.rm = TRUE)

      if(date_in_df >= max_date){
        max_date <- date_in_df
        i <- i + 1
      } else {
        current <- FALSE
      }
    }

    if(release_dates == "all"){
      i <- i + 1
    }

    if(i > tot_pages){
      current <- FALSE
    }


  } # end while loop

  xml_dfs <- dplyr::bind_rows(xml_dfs)

  xml_dfs <- xml_dfs %>%
    dplyr::mutate_at(c("ProductReleaseDate", "SeriesStart", "SeriesEnd"),
                     as.Date, format = "%d/%m/%Y")

  if(release_dates == "latest"){
    xml_dfs <- xml_dfs %>%
      dplyr::filter(ProductReleaseDate == max(ProductReleaseDate))
  }

  xml_dfs <- xml_dfs %>%
    dplyr::mutate(TableOrder = as.numeric(TableOrder)) %>%
    dplyr::arrange(TableOrder)

  xml_dfs

}



