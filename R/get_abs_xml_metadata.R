
#' @importFrom XML xmlParse xmlToList xmlToDataFrame
#' @import dplyr

# given a catalogue number, download the catalogue metadata via XML, then find
# unique filenames in the latest release and return those

get_abs_xml_metadata <- function(cat_no) {

  ProductReleaseDate=TableOrder=text=NULL

  # Download the first page of metadata for cat_no
  first_url <- paste0("http://ausstats.abs.gov.au/servlet/TSSearchServlet?catno=",
                      cat_no,
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

  all_pages <- sort(seq(as.numeric(tot_pages):1), decreasing = TRUE)

  # Extract the date on the first page of the metadata (it'll be the oldest in the directory)
  first_page_df <- XML::xmlToDataFrame(first_page, stringsAsFactors = FALSE)

  max_date <- max(as.Date(first_page_df$ProductReleaseDate, format = "%d/%m/%Y"),
                  na.rm = TRUE)

  # Begin at the last page of metadata and loop backwards through each page,
  # extracting each page as a data frame,
  # until the release date of the data is not the maximum date, then stop

  i <- 1
  current <- TRUE
  xml_dfs <- list()
  while(current == TRUE){

    xml_df <- get_xml_df(cat_no = cat_no, metadata_page = all_pages[i])

    xml_dfs[[i]] <- xml_df

    date_in_df <- max(as.Date(xml_df$ProductReleaseDate, format = "%d/%m/%Y"),
                      na.rm = TRUE)

    if(date_in_df >= max_date){
      max_date <- date_in_df
      i <- i + 1
    } else {
      current <- FALSE
    }

    if(i > tot_pages){
      current <- FALSE
    }


  } # end while loop - stop when data release date < max date

  xml_dfs <- dplyr::bind_rows(xml_dfs)

  xml_dfs <- xml_dfs %>%
    dplyr::mutate(ProductReleaseDate = as.Date(ProductReleaseDate, format = "%d/%m/%Y")) %>%
    dplyr::filter(ProductReleaseDate == max(ProductReleaseDate))

  xml_dfs <- xml_dfs %>%
    dplyr::mutate(TableOrder = as.numeric(TableOrder)) %>%
    dplyr::arrange(TableOrder)

  xml_dfs

}



