#' Tidy the raw data returned using the ABS' API
#'
#' This function gets the nested list of raw data returned using the API URL and
#' transforms it into into a tidy tibble based on the structure of the API URL
#' (i.e. whether it follows the old or new structure, as stated in the
#' \code{old_api} parameter).
#'
#' @param old_api (boolean) States whether the ABS' API uses the old (ABS.Stat)
#'   or new structure. If \code{old_api} == TRUE, then the API follows the old
#'   structure.
#' @param url (char) The API URL used to query the data you want from the ABS.
#'
#' @return (tibble) Returns a tibble containing the ABS data you queried.
#'
tidy_api_data <- function(url, old_api) {

  # Gets very nested list of raw data from ABS.
  data_raw <- jsonlite::fromJSON(url)

  # observations = A tibble with 2 columns: key (char) and value (num).
  # key = A character consisting of integers separated by a colon (e.g.
  # "0:3:2:1..."). The number of integers equals the number of dimensions the
  # dataset has (i.e. region, year etc). The position of each integer tells us
  # the dimension name and the value of each integer tells us the dimension
  # member (these are found using the dimensions list below).
  # value = The observation value.
  observations <- data_raw %>%
    purrr::when(old_api == FALSE ~ purrr::pluck(., "data"),
                old_api == TRUE ~ .) %>%
    purrr::pluck("dataSets", "observations") %>%
    tidyr::pivot_longer(cols = tidyselect::everything(), names_to = "key")  %>%
    dplyr::rowwise() %>% dplyr::mutate(value = .data$value[[1]]) %>%
    dplyr::ungroup()

  # column_headers = A vector containing all variable names.
  column_headers <- data_raw %>%
    purrr::when(old_api == FALSE ~ purrr::pluck(., "data", "structure",
                                                "dimensions", "observation",
                                                "names")[[1]],
                old_api == TRUE ~ purrr::pluck(., "structure", "dimensions",
                                               "observation", "name"))

  # dimensions = A list of data frames with each data frame containing all
  # members (values) for a particular dimension (variable).
  dimensions <- data_raw %>%
    purrr::when(old_api == FALSE ~ purrr::pluck(., "data"),
                old_api == TRUE ~ .) %>%
    purrr::pluck("structure", "dimensions", "observation", "values") %>%
    purrr::set_names(column_headers)

  # dataset = A tibble, which has a column for each dimension (variable) and a
  # column for the observation value. The key corresponding to each observation
  # in the observations tibble is split among the columns so each column
  # has one integer. (Each integer corresponds to the position of the dimension
  # member as found in the dimensions list.)
  dataset <- observations %>%
    tidyr::separate(col = .data$key, into = column_headers, sep = ":") %>%
    dplyr::mutate(dplyr::across(.cols = tidyselect::vars_select_helpers$where(is.character),
                                function(x)
                                  as.numeric(x) + 1)) #add 1 to each integer to remove indices of 0

  # Replaces all integers with the name of the dimension member.
  suppressMessages(dimensions %>%
                     purrr::imap(api_join,
                                 dataset = dataset) %>%
                     purrr::reduce(dplyr::left_join) %>%
                     dplyr::select(-.data$rowid) %>%
                     dplyr::relocate(.data$value, .after = tidyselect::last_col()) %>%
                     janitor::clean_names())
}
