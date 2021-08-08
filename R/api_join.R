#' A special ABS join for the API
#'
#' This function renames the id column to the variable/dimension name for a data
#' frame in the dimensions list from \code{tidy_api_data}. It also adds a column
#' to the data frame, which contains all the row numbers.
#'
#' @param .x (data.frame) A data frame in the dimensions list from
#'   \code{tidy_api_data}.
#' @param col (column) The column from the dataset tibble from
#'   \code{tidy_api_data} that corresponds to the data frame used.
#' @param dataset (tibble) The dataset tibble from \code{tidy_api_data}, which
#'   has integers as the variable values/dimension members.
#'
api_join <- function(.x, col, dataset) {
  .x <- .x %>%
    tibble::rowid_to_column() %>%
    dplyr::select({{ col }} := .data$rowid,
                  .data$name)


  dplyr::left_join(dataset, .x) %>%
    dplyr::select(-col) %>%
    dplyr::select({{ col }} := .data$name,
                  .data$value) %>%
    tibble::rowid_to_column() %>%
    tibble::as_tibble()
}
