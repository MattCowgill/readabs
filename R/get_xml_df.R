
#' @importFrom XML xmlParse xmlToDataFrame
#' @importFrom utils download.file
#' @importFrom dplyr filter select "%>%"

get_xml_df <- function(url){

  text=NULL

  temp_page_location <- file.path(tempdir(), "temp_readabs_xml.xml")

  utils::download.file(url, temp_page_location, quiet = TRUE)

  safe_parse <- purrr::safely(XML::xmlParse)

  xml_page <- safe_parse(file = temp_page_location)

  if(is.null(xml_page$error)){
    xml_page <- xml_page$result
  } else {
    stop(paste0("Error: the following URL does not contain valid ABS metadata:\n",
                url))
  }

  xml_df <- XML::xmlToDataFrame(xml_page, stringsAsFactors = FALSE)

  if(length(xml_df) == 0) {
    stop(paste0("Couldn't find a valid ABS time series in catalogue number"))
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
