#' Tidy multiple dataframes of ABS time series data contained in a list.
#'
#' @param list_of_dfs A list of dataframes containing extracted ABS time series data.
#'
#'
#' @importFrom purrr map_dfr
#' @importFrom tidyr separate
#' @importFrom dplyr "%>%"
#' @export

tidy_abs_list <- function(list_of_dfs) {

  sheet_id=NULL

  if(!"list" %in% class(list_of_dfs)){
    if("data.frame" %in% class(list_of_dfs)){
      stop("abs_tidy_list() works with lists of data frames, not individual data frames. Use abs_tidy() to tidy an individual data frame that is not contained in a list.")
    }
    stop("The object is not a list of data frames.")
  }

  message("Tidying data from imported ABS spreadsheets")

  # apply abs_tidy to each element of list_of_dfs and combine into 1 df
  # with new column "sheet_id"
  x <- purrr::map_dfr(list_of_dfs, tidy_abs, .id = "sheet_id") %>%
    # split the sheet_id column into table_no and sheet_no
    tidyr::separate(col = sheet_id, into = c("table_no", "sheet_no", "table_title"), sep = "=",
                    extra = "merge", fill = "right")

  x
}
