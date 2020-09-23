get_available_cubes <- function(catalogue_string){


  download_url <- filter(abs_lookup_table,
                         catalogue == catalogue_string) %>%
    pull(url)

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
  available_downloads <- tibble::tibble(label = download_page %>% rvest::html_nodes(".abs-data-download-left") %>% rvest::html_text(),
                                        url = download_page %>% rvest::html_nodes(".file a") %>%  rvest::html_attr("href")) %>%
    mutate(file = str_extract(url, "[^/]*$")) %>%
    select(label, file, url)

  return(available_downloads)

}
