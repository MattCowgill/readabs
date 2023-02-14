#' @importFrom rlang .data .env
#' @import dplyr
#' @noRd
#' @param url URL for an XML file in the ABS Time Series Directory
# given a catalogue number, download the catalogue metadata via XML, then find
# unique filenames in the latest release and return those

get_abs_xml_metadata <- function(url) {
  if (!is.character(url)) {
    stop("`url` argument to get_abs_xml_metadata() must be a string.")
  }

  first_page_df <- get_first_xml_page(url)

  num_pages <- get_numpages(url)

  xml_dfs <- dplyr::tibble()

  # If there's more than one page of XML corresponding to request, get all of them
  if (num_pages > 1) {
    all_pages <- 2:num_pages
    # create list of URLs of XML metadata to scrape
    full_urls <- paste0(url, "&pg=", all_pages)
    xml_dfs <- get_xml_dfs(full_urls)
  }

  xml_dfs <- dplyr::bind_rows(first_page_df, xml_dfs)

  xml_dfs <- xml_dfs %>%
    dplyr::mutate(ProductIssue = as.Date(paste0("01 ", .data$ProductIssue),
      format = "%d %b %Y"
    )) %>%
    dplyr::mutate_at(c("ProductReleaseDate", "SeriesStart", "SeriesEnd"),
      as.Date,
      format = "%d/%m/%Y"
    )

  xml_dfs <- xml_dfs %>%
    dplyr::group_by(.data$TableTitle) %>%
    dplyr::filter(.data$ProductReleaseDate == max(.data$ProductReleaseDate)) %>%
    dplyr::ungroup()

  xml_dfs <- dplyr::mutate(xml_dfs, TableOrder = as.numeric(.data$TableOrder))
  xml_dfs <- dplyr::arrange(xml_dfs, .data$TableOrder)

  xml_dfs
}

get_numpages <- function(url) {
  temp_xml <- tempfile(fileext = ".xml")

  dl_file(
    url = url,
    destfile = temp_xml
  )

  out <- temp_xml %>%
    xml2::read_xml() %>%
    xml2::xml_find_all(xpath = "//NumPages") %>%
    xml2::xml_double()

  if (length(out) == 0) {
    return(1)
  } else {
    return(out)
  }
}

get_first_xml_page <- function(url) {
  get_specific_xml_page(url = url,
                        page = 1)
}

get_last_xml_page <- function(url) {
  num_pages <- get_numpages(url)
  get_specific_xml_page(url = url,
                        page = num_pages)
}

get_specific_xml_page <- function(url, page) {

  if (length(page) > 0) {
    first_url <- paste0(
      url,
      "&pg=",
      page
    )
  } else {
    first_url <- url
  }

  # Some tables in the ABS TSD start with a leading zero, as in
  # Table 01 rather than Table 1; the 0 needs to be included. Here we first test
  # for a readable XML file using the table number supplied (eg. "1"); if that
  # doesn't work then we try with a leading zero ("01").

  safely_get_xml_dfs <- purrr::safely(get_xml_dfs)
  first_page <- safely_get_xml_dfs(first_url)

  first_url_works <- if (!is.null(first_page$result)) {
    TRUE
  } else {
    FALSE
  }

  if (!first_url_works) {
    if (!grepl("ttitle", first_url)) { # this is the case when tables == "all"
      stop(paste0(
        "Cannot find valid entry",
        " in the ABS Time Series Directory.",
        "Check that the cat. no. is correct, and that it contains ",
        "time series spreadsheets (not data cubes)."
      ))
    }

    # now try prepending a 0 on the ttitle

    first_url <- gsub("ttitle=", "ttitle=0", first_url)

    first_page <- safely_get_xml_dfs(first_url)

    first_url_works <- if (!is.null(first_page$result)) {
      TRUE
    } else {
      FALSE
    }

    if (first_url_works) {
      url <- gsub("ttitle=", "ttitle=0", url)
    } else {
      stop(
        "Cannot find valid entry for requested data",
        "in the ABS Time Series Directory"
      )
    }
  }

  first_page <- first_page$result
  first_page
}
