#' Label read_api data with datastructure metadata
#'
#' Creates additional columns in the data.frame generated from \code{\link{read_api}} corresponding to metadata columns from \code{\link{read_api_datastructure}}.
#'
#' @param read_api_data A data.frame from \code{\link{read_api}}.
#' @param read_api_datastructure_data The corresponding data.frame from \code{\link{read_api_datastructure}}. Dataflow id should be identical to \code{read_api_data}.
#'
#' @examples
#' ## Not run:
#'
#' # Api data downloaded separately
#' abs_api_cpi <- read_api("CPI")
#' abs_api_ds_cpi <- read_api_datastructure("CPI")
#'
#' label_abs_api_data(abs_api_cpi, abs_api_ds_cpi)
#'
#' # Combined functions
#' label_abs_api_data(read_api("CPI"), read_api_datastructure("CPI"))
#'
#' ## End (Not run)

label_abs_api_data <- function(read_api_data, read_api_datastructure_data) {

  # Determine what needs to be labelled
  api_datastructure_vars_list <- read_api_datastructure_data |>
    split(with(read_api_datastructure_data, var)) |>
    names()

  # Re-ordering to make our output be in the same order as the original data when we loop
  api_datastructure_vars_list <- api_datastructure_vars_list[order(match(api_datastructure_vars_list, colnames(read_api_data)))]

  # Function to join the descriptive variables from the variable list to read_api_data
  label_variables <- function(api_data, variable, api_datastructure) {

    # Label our new descriptive columns 'variable_label'
    column_label <- paste0(variable, "_label")

    # Pull out the 'lookup table' for the variable
    datastructure_extract <- subset(api_datastructure, var == variable, select = c("code", "label"))
    # Rename the descriptive column to "variable_label"
    colnames(datastructure_extract)[colnames(datastructure_extract) == "label"] <- column_label

    # Leftjoin the 'lookup table' to api data
    api_data <- api_data |>
      merge(datastructure_extract,
            by.x = variable,
            by.y = "code",
            all.x = T) |>
      # Ensure new "var_label" column sits after the "var" column
      dplyr::relocate(all_of(column_label), .after = all_of(variable))

    return(api_data)
  }

  # Iterate label_variables() for each var and combine
  output_dataframe <- Reduce(
    function(df, var) {
      label_variables(df, var, read_api_datastructure_data)
    },
    # Reversing as the process reverses column order
    rev(api_datastructure_vars_list),
    init = read_api_data
  )

  # Add attribute labels to descriptive columns
  lapply(api_datastructure_vars_list, function(x) {
    labelled_columns <- paste0(x, "_label")
    attr(output_dataframe[[labelled_columns]], "label") <- attr(output_dataframe[[x]], "label")
  })

  return(output_dataframe)
}
