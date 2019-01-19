
#' @importFrom XML xmlParse xmlToList xmlToDataFrame
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

  first_page <- XML::xmlParse(file = first_url)

  # Extract the total number of pages in cat_no's metadata
  first_page_list <- XML::xmlToList(first_page)

  # Return an error if the metadata page is empty
  if(is.null(first_page_list)) {
    stop(paste0("Couldn't find an ABS time series with catalogue number ", cat_no))
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
  # if release_dates = "latest" then we
  # begin at the last page of metadata and loop backwards through each page,
  # extracting each page as a data frame,
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



