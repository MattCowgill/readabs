#' Splits one large API URL into smaller URLs
#'
#' This function splits up large URLs (URLs with more than 1000 characters) into
#' smaller batches to increase efficiency. It identifies the large variables
#' (dimensions) in the data key (those that have more than 50 values) and
#' divides these up into batches of 50 values. Smaller URLs are
#' then constructed using these batches.
#'
#' @param url (char) The API URL used to query the data you want from the ABS.
#'   Both the ABS.Stat URL structure and the new API URL structure (as outlined
#'   on api.gov.au) are accepted. The following parameters would just need to be
#'   included in the URLs to organise the data in the flat view and JSON format:
#'   dimensionAtObservation=allDimensions (for the ABS.Stat SDMX-JSON API) and
#'   format=jsondata&dimensionAtObservation=AllDimensions (for the new API).
#' @param old_api (boolean) States whether the ABS' API uses the old (ABS.Stat)
#'   or new structure. If \code{old_api} == TRUE, then the API follows the old
#'   structure.
#'
#' @return (character) A character vector with the smaller URLs.
api_split_url <- function(url, old_api) {
  url_structure <- unlist(strsplit(url, "/"))

  if(old_api) {
    key <- url_structure[7]
  } else {
    url_end <- url_structure[6]
    key <- stringr::str_split(url_end, "\\?")[[1]][1]
  }

  #variables = character vector containing the all values (members) of each
  #variable (dimension)
  variables <- stringr::str_split(key, "\\.")[[1]]

  #split all variables in batches of 50
  var_batches <- purrr::map(variables, api_split_variables)

  #get all the different combinations of the batches of variables in the key
  key_elements <- expand.grid(var_batches)

  #extract the stem and end of URLs
  if (old_api) {
    stem <- paste0(url_structure[1], "//", url_structure[3], "/",
                   url_structure[4], "/", url_structure[5], "/",
                   url_structure[6], "/")
    end <- paste0("/", url_structure[8])
  } else {
    stem <- paste0(url_structure[1], "//", url_structure[3], "/",
                   url_structure[4], "/", url_structure[5], "/")
    end <- paste0("?", stringr::str_split(url_end, "\\?")[[1]][2])
  }

  urls <- key_elements %>%
    #make one column consisting of the new smaller keys
    tidyr::unite(key, tidyselect::everything(), sep = ".") %>%
    #add 2 columns, one containing the URL stem and the other containing the URL
    #end
    dplyr::mutate(stem = stem, .before = key) %>%
    dplyr::mutate(end = end, .after = key) %>%
    #combine stem, key and end to make URLs
    tidyr::unite(url, stem, key, end, sep = "") %>%
    dplyr::pull("url")

  message(glue::glue("Breaking your url into {length(urls)} batches. ",
                     "Each batch may take a few seconds to query."))

  return(urls)
}
