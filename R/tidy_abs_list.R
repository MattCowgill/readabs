#' Tidy multiple dataframes of ABS time series data contained in a list.
#'
#' @param list_of_dfs A list of dataframes containing extracted
#' ABS time series data.
#'
#' @param metadata logical. If `TRUE` (the default), a tidy data frame including
#' ABS metadata (series name, table name, etc.) is included in the output. If
#' `FALSE`, metadata is dropped.
#'
#' @importFrom purrr map_dfr
#' @importFrom tidyr separate
#' @importFrom dplyr "%>%"
#' @export

tidy_abs_list <- function(list_of_dfs, metadata = TRUE) {

  table_no = sheet_no = table_title = NULL

  if (!"list" %in% class(list_of_dfs)) {
    if ("data.frame" %in% class(list_of_dfs)) {
      stop("abs_tidy_list() works with lists of data frames,",
           " not individual data frames. Use abs_tidy() to tidy an",
           " individual data frame that is not contained in a list.")
    }
    stop("The object is not a list of data frames.")
  }

  message("Tidying data from imported ABS spreadsheets")

  # apply abs_tidy to each element of list_of_dfs and combine into 1 df
  # with new column "sheet_id"
  x <- purrr::map(list_of_dfs,
                  tidy_abs,
                  metadata = metadata)

  sheet_ids <- names(list_of_dfs)

  list_of_split_sheet_ids <- stringi::stri_split_fixed(sheet_ids, "=", 3)

  for (i in seq_along(x)) {
    x[[i]]$table_no = list_of_split_sheet_ids[[i]][1]
    x[[i]]$sheet_no = list_of_split_sheet_ids[[i]][2]
    x[[i]]$table_title = list_of_split_sheet_ids[[i]][3]
  }

  x <- bind_rows(x)

  x <- select(x, table_no, sheet_no, table_title, everything())

  x
}
