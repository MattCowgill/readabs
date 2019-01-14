
#' @importFrom XML xmlParse xmlToDataFrame
#' @importFrom dplyr filter select "%>%"

get_xml_df <- function(cat_no, table, metadata_page){

  text=NULL

  if(table == "all"){
    tables_url <- ""
  } else {
    tables_url <- paste0("&ttitle=", table)
  }

  base_url <- "http://ausstats.abs.gov.au/servlet/TSSearchServlet?catno="

  url <- paste0(base_url, cat_no, "&pg=", metadata_page, tables_url)

  safe_parse <- purrr::safely(XML::xmlParse)

  xml_page <- safe_parse(file = url)

  if(is.null(xml_page$error)){
    xml_page <- xml_page$result
  } else {
    stop(paste0("Error: the following URL does not contain valid ABS metadata:\n",
                url))
  }

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
