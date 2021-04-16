
#' @import dplyr

# given a catalogue number, download the catalogue metadata via XML, then find
# unique filenames in the latest release and return those

get_abs_xml_metadata <- function(url) {

  if (!is.character(url)) {
    stop("`url` argument to get_abs_xml_metadata() must be a string.")
  }

  ProductReleaseDate <- TableOrder <- cat_no <- ProductIssue <- NULL

  # Download the first page of metadata
  first_url <- paste0(
    url,
    "&pg=1"
  )

  # Some ABS Time Series in the directory start with a leading zero, as in
  # Table 01 rather than Table 1; the 0 needs to be included. Here we first test
  # for a readable XML file using the table number supplied (eg. "1"); if that
  # doesn't work then we try with a leading zero ("01"). If that fails,
  # it's an error.

  first_page_file <- file.path(tempdir(), "temp_readabs_xml.xml")

  utils::download.file(first_url,
                       first_page_file,
                       quiet = TRUE,
                       cacheOK = FALSE,
                       headers = readabs_header)

  first_page <- xml2::read_xml(first_page_file, encoding = "ISO-8859-1",
                               user_agent = readabs_user_agent)
  first_page_list <- xml2::as_list(first_page)
  first_page_list <- first_page_list[[1]]
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
                         headers = readabs_header)

    first_page <- xml2::read_xml(first_page_file, encoding = "ISO-8859-1",
                                 user_agent = readabs_user_agent)
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


  if (is.null(first_page_list$NumPages)) {
    tot_pages <- 1
  } else {
    tot_pages <- as.numeric(first_page_list$NumPages)
  }

  all_pages <- rev(c(1:tot_pages))

  # Extract the date on the first page of the metadata
  # (it'll be the oldest in the directory)

  max_date <- as.Date(first_page_list$Series$ProductReleaseDate[[1]],
    format = "%d/%m/%Y"
  )

  # create list of URLs of XML metadata to scrape
  full_urls <- paste0(url, "&pg=", all_pages)

  i <- 1
  current <- TRUE
  xml_dfs <- list()
  while (current == TRUE) {
    xml_df <- get_xml_df(url = full_urls[i])

    xml_dfs[[i]] <- xml_df



      date_in_df <- max(as.Date(xml_df$ProductReleaseDate, format = "%d/%m/%Y"),
        na.rm = TRUE
      )

      if (date_in_df >= max_date) {
        max_date <- date_in_df
        i <- i + 1
      } else {
        current <- FALSE
      }



    if (i > tot_pages) {
      current <- FALSE
    }
  } # end while loop

  xml_dfs <- dplyr::bind_rows(xml_dfs)

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
