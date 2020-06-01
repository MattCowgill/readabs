library(tidyverse)
series <- "6291.0.55.003"
cube_string <- "eq09"
path  <- "raw-data"
latest <- TRUE





if(latest == FALSE & is.null(date)) {stop("latest is false and date is NULL. Please supply a value for date.")}


releases_url <- glue::glue("https://www.abs.gov.au/AUSSTATS/abs@.nsf/second+level+view?ReadForm&prodno={series}&&tabname=Past%20Future%20Issues")

releases_page <- xml2::read_html(releases_url)

releases_table <- tibble::tibble(release = releases_page %>%  rvest::html_nodes("#mainpane a") %>% rvest::html_text(),
                                 url_suffix = releases_page %>%  rvest::html_nodes("#mainpane a") %>% rvest::html_attr("href"))

#get the page for the latest data
if(latest == TRUE){
  date <- releases_table %>%
    dplyr::filter(grepl("(Latest)", release)) %>%
    dplyr::pull(release) %>%
    stringr::str_remove(" \\(Latest\\)") %>%
    stringr::str_extract("Week ending \\d+\\s{1}\\w+ \\d+$|(Jan(?:uary)?|Feb(?:ruary)?|Mar(?:ch)?|Apr(?:il)?|May|Jun(?:e)?|Jul(?:y)?|Aug(?:ust)?|Sep(?:tember)?|Oct(?:ober)?|Nov(?:ember)?|Dec(?:ember)?) \\d+$|\\d+$") %>%
    stringr::str_replace_all(" ", "%20")
}

#find download page
download_url <- glue::glue("https://www.abs.gov.au/AUSSTATS/abs@.nsf/DetailsPage/{series}{date}?OpenDocument")
download_page <- xml2::read_html(download_url)


#Find the url for the download
download_url_suffix <- tibble::tibble(url = download_page %>% rvest::html_nodes("a") %>% rvest::html_attr("href")) %>%
  dplyr::filter(grepl(tolower(cube_string), url)) %>%
  dplyr::slice(1) %>% #this gets the first result which is typically the xlsx file rather than the zip
  dplyr::pull(url)

#==================download file======================
file_url <- glue::glue("https://www.abs.gov.au{download_url_suffix}")

download_object <- httr::GET(file_url)

filename <- basename(download_object$url)
filepath <- file.path(path, filename)

writeBin(httr::content(download_object, "raw"), filepath)
