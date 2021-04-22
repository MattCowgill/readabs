
#' @import dplyr
#' @noRd
#' @param url URL for an XML file in the ABS Time Series Directory
# given a catalogue number, download the catalogue metadata via XML, then find
# unique filenames in the latest release and return those

get_abs_xml_metadata <- function(url) {
  if (!is.character(url)) {
    stop("`url` argument to get_abs_xml_metadata() must be a string.")
  }

  ProductReleaseDate <- TableOrder <- cat_no <- ProductIssue <- NULL

  first_page <- get_first_xml_page(url)

  first_page_df <- xml_to_df(first_page)

  first_page_list <- xml2::as_list(first_page)[[1]]

  xml_dfs <- dplyr::tibble()

  # If there's more than one page of XML corresponding to request, get all of them
  if (!is.null(first_page_list$NumPages)) {
    tot_pages <- as.numeric(first_page_list$NumPages)
    all_pages <- seq(2, tot_pages)
    # create list of URLs of XML metadata to scrape
    full_urls <- paste0(url, "&pg=", all_pages)
    xml_dfs <- purrr::map_dfr(full_urls, get_xml_df)
  }

  xml_dfs <- dplyr::bind_rows(first_page_df, xml_dfs)

  xml_dfs <- xml_dfs %>%
    dplyr::mutate(ProductIssue = as.Date(paste0("01 ", ProductIssue),
      format = "%d %b %Y"
    )) %>%
    dplyr::mutate_at(c("ProductReleaseDate", "SeriesStart", "SeriesEnd"),
      as.Date,
      format = "%d/%m/%Y"
    )

  xml_dfs <- xml_dfs %>%
    dplyr::filter(ProductReleaseDate == max(ProductReleaseDate))

  xml_dfs <- dplyr::mutate(xml_dfs, TableOrder = as.numeric(TableOrder))
  xml_dfs <- xml_dfs[order(xml_dfs[, "TableOrder"]), ]

  xml_dfs
}



get_first_xml_page <- function(url) {
  # Download the first page of metadata ------
  first_url <- paste0(
    url,
    "&pg=1"
  )

  # Some tables in the ABS TSD start with a leading zero, as in
  # Table 01 rather than Table 1; the 0 needs to be included. Here we first test
  # for a readable XML file using the table number supplied (eg. "1"); if that
  # doesn't work then we try with a leading zero ("01").

  first_page_file <- file.path(tempdir(), "temp_readabs_xml.xml")

  utils::download.file(first_url,
                       first_page_file,
                       quiet = TRUE,
                       cacheOK = FALSE,
                       headers = readabs_header
  )

  first_page <- xml2::read_xml(first_page_file,
                               encoding = "ISO-8859-1",
                               user_agent = readabs_user_agent
  )
  first_page_list <- xml2::as_list(first_page)[[1]]
  first_url_works <- ifelse(length(first_page_list) > 0,
                            TRUE,
                            FALSE
  )

  if (!first_url_works) {
    if (!grepl("ttitle", first_url)) { # this is the case when tables == "all"
      stop(paste0(
        "Cannot find valid entry for cat_no ", cat_no,
        " in the ABS Time Series Directory.",
        "Check that the cat. no. is correct, and that it contains ",
        "time series spreadsheets (not data cubes)."
      ))
    }

    # now try prepending a 0 on the ttitle

    first_url <- gsub("ttitle=", "ttitle=0", first_url)

    utils::download.file(first_url,
                         first_page_file,
                         quiet = TRUE,
                         cacheOK = FALSE,
                         headers = readabs_header
    )

    first_page <- xml2::read_xml(first_page_file,
                                 encoding = "ISO-8859-1",
                                 user_agent = readabs_user_agent
    )
    first_page_list <- xml2::as_list(first_page)
    first_page_list <- first_page_list[[1]]
    first_url_works <- ifelse(length(first_page_list) > 0,
                              TRUE,
                              FALSE
    )

    if (first_url_works) {
      url <- gsub("ttitle=", "ttitle=0", url)
    } else {
      stop(
        "Cannot find valid entry for requested data",
        "in the ABS Time Series Directory"
      )
    }
  }

  first_page
}