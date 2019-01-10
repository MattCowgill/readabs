
#' @importFrom XML xmlParse xmlToDataFrame
#' @importFrom dplyr filter select "%>%"

get_xml_df <- function(cat_no, metadata_page){

  text=NULL

  base_url <- "http://ausstats.abs.gov.au/servlet/TSSearchServlet?catno="

  url <- paste0(base_url, cat_no, "&pg=", metadata_page)

  xml_page <- XML::xmlParse(file = url)

  xml_df <- XML::xmlToDataFrame(xml_page, stringsAsFactors = FALSE)

  if(length(xml_df) == 0) {
    stop(paste0("Couldn't find an ABS time series with catalogue number ", cat_no))
  }

  # if metadata has > 1 page (almost all do), xml_df will contain a text column;
  # if metadata has 1 page, it won't have a text column. We want to drop it if present.
  if(!is.null(xml_df$text)){
    xml_df <- xml_df %>%
      dplyr::filter(is.na(text)) %>%
      dplyr::select(-text)
  }

  xml_df
}
