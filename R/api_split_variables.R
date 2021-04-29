#' Split each variable in the API URL data key into batches of 50
#'
#' This function first splits up the variable (dimension) into its values
#' (members), which are separated by plus signs in the data key. The separate
#' values are then grouped into batches of 50 and plus signs are added between
#' each value in each batch.
#'
#' @param var (char) A string representing one of the variables in the key.
#'
#' @return A character vector containing any number of batches with a maximum of
#'   50 values (dimension members) in each batch.
api_split_variables <- function(var) {
  #split up the variable into their separate values
  single_values <- stringr::str_split(var, "\\+") %>%
    unlist()

  #group the single values into batches of 50
  batches <- split(single_values, ceiling(seq_along(single_values)/50)) %>%
    purrr::map_chr(paste0, collapse = "+")
}
