#' Tidy the raw data returned using the ABS' API
#'
#' This function gets the nested list of raw data returned using the API URL and
#' transforms it into into a tidy tibble based on the structure of the API URL
#' (i.e. whether it follows the old or new structure, as stated in the
#' \code{old_api} parameter).
#'
#' @inheritParams read_abs_api
#' @param query_data (\code{data.frame}) raw data as a \code{data.frame} returned
#'   from the ABS API
#'
#' @return (tibble) Returns a tibble containing the ABS data you queried.
#'
tidy_api_data <- function(query_data,
                          structure_url) {

  # Check suggested packages
  purrr::walk(c("readsdmx", "urltools"),
              requireNamespace,
              quietly = TRUE
  )

  # Clean the query_data names, and add an ID (which is used for joining later)
  query_data <- rlang::set_names(query_data, tolower(names(query_data))) %>%
    dplyr::mutate(row = dplyr::row_number()) %>%
    # Need to rename region to state because the data dictionary uses region
    dplyr::rename("state" = dplyr::contains("region"))

  # The vector of dimensions in the query data
  measures_clean <- colnames(query_data)

  # Suffix the columns with '_code'
  query_data <- query_data %>%
    dplyr::rename_with(.fn = ~ paste0(.x, "_code"))

  # Extract the values and row ids
  values <- query_data %>%
    dplyr::transmute(
      .data$row_code,
      value_code = .data$obsvalue_code
    )




  # Create a long tibble of structure info/metadata
  structure_data <- open_sdmx(structure_url) %>%
    dplyr::select(id = .data$id_description,
                  label = .data$en_description,
                  code = .data$id) %>%
    dplyr::mutate(code = .data$code %>%
                    tolower() %>%
                    stringi::stri_replace_first_fixed(replacement = "", "CL_") %>%
                    stringi::stri_extract_first_regex(
                      stringi::stri_c_list(
                        as.list(measures_clean),
                        collapse = "|"
               )
             ))

  # Helper function to break up a tibble of measure codes & descriptions into a list of tibbles split by measure
  clean_up_data_dict <- function(.data) {
    new_names <- .data$code[[1]] %>%
      paste0(c("_code", "_name"))

    .data %>%
      dplyr::select(-.data$code) %>%
      dplyr::rename_with(~new_names)
  }

  # This is a list of tibbles, each with a dimension code and description
  split_structure_data <- structure_data %>%
    split(~ code) %>%
    purrr::map(clean_up_data_dict) %>%
    purrr::set_names(~ paste0(.x, "_code"))


  # Helper function to join tibble of metadata to query_data
  mini_join <- function(.data,
                        details,
                        var) {
    .data %>%
      dplyr::select(.data$row_code, !!var) %>%
      dplyr::left_join(details) %>%
      dplyr::select(-!!var)
  }

  # Using suppressMessages because of all the different joining_by messages in the
  # reduce
  suppressMessages(
    interim <- purrr::imap(split_structure_data,
                .f = mini_join,
                .data = query_data
    ) %>%
      purrr::reduce(
        dplyr::inner_join,
        by = "row_code"
      ) %>%
      dplyr::inner_join(query_data) %>%
      dplyr::rename(
        value = .data$obsvalue_code,
      ) %>%
      dplyr::select(-.data$row_code))

  # Using `interim` as a way to avoid importing `plyr::.` placeholder
   interim %>%
      dplyr::select(sort(colnames(interim))) %>%
      dplyr::relocate(
        .data$value,
        .before = 1
      ) %>%
      dplyr::mutate(value = as.numeric(.data$value))
}
