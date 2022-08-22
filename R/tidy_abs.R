#' Tidy ABS time series data.
#'
#' @param df A data frame containing ABS time series data
#' that has been extracted using \code{extract_abs_sheets}.
#'
#' @param metadata logical. If `TRUE` (the default), a tidy data frame
#' including ABS metadata (series name, table name, etc.) is
#' included in the output. If `FALSE`, metadata is dropped.
#'
#' @return data frame (tibble) in long format.
#'
#' @examples
#'
#' # First extract the data from the local spreadsheet
#' \dontrun{
#' wpi <- extract_abs_sheets("634501.xls")
#' }
#'
#' # Then tidy the data extracted from the spreadsheet. Note that
#' # \code{extract_abs_sheets()} returns a list of data frames, so we need to
#' # subset the list.
#' \dontrun{
#' tidy_wpi <- tidy_abs(wpi[[1]])
#' }
#'
#' @importFrom purrr map_chr
#' @import dplyr
#' @importFrom tidyr gather pivot_longer
#' @export

tidy_abs <- function(df, metadata = TRUE) {
  unit <- series <- value <- X__1 <- series_id <- NULL

  if (!"data.frame" %in% class(df)) {
    stop("Object does not appear to be a data frame; it cannot be tidied.")
  }

  # return an error if the df has <= 1 column
  if (ncol(df) <= 1) {
    stop(
      "The data frame appears to have fewer than 2 columns.",
      " This is unexpected from an ABS time series.",
      " Please check the spreadsheet."
    )
  }

  if (!is.logical(metadata)) {
    stop("`metadata` argument to tidy_abs() must be either `TRUE` or `FALSE`.")
  }

  # newer versions of tibble() and readxl() want to either leave the first
  # colname blank or coerce it to something other than X__1
  # so we set it manually
  colnames(df)[1] <- "X__1"

  # return an error if the sheet is not formatted as we expect
  # from an ABS time series

  if (df[9, 1] != "Series ID") {
    stop(
      "The data frame appears not to be formatted as we expect",
      " from an ABS time series. There should be 9 rows of metadata",
      " after the column names (eg. 'Series ID').",
      " Please check the spreadsheet."
    )
  }

  # a bunch of columns have duplicate names which causes problems; temporarily
  # append the series ID to the colname so they're unique

  # new_col_names <- purrr::map_chr(
  #   .x = 2:ncol(df),
  #   .f = ~ paste0(colnames(df)[.], "_", df[9, .])
  # )

  cols <- 2:ncol(df)
  new_col_names <- paste(colnames(df)[cols], df[9, cols], sep = "_")

  colnames(df)[2:ncol(df)] <- new_col_names

  if (isTRUE(metadata)) {
    df <- df %>%
      tidyr::pivot_longer(cols = !one_of("X__1"), names_to = "series") %>%
      filter(!is.na(X__1),
             # This filtering is necessary for cases where the ABS adds notes
             # to the bottom of the data for some reason
             !stringi::stri_detect_fixed(X__1, "Trend Break"),
             !stringi::stri_detect_fixed(X__1, "see")) %>%
      dplyr::group_by(series) %>%
      dplyr::mutate(
        series_type = value[X__1 == "Series Type"],
        data_type = value[X__1 == "Data Type"],
        collection_month = value[X__1 == "Collection Month"],
        frequency = value[X__1 == "Frequency"],
        series_id = value[X__1 == "Series ID"],
        unit = value[X__1 == "Unit"]
      ) %>%
      dplyr::filter(dplyr::row_number() >= 10) %>%
      dplyr::ungroup()

    df <- df %>%
      dplyr::rename(date = X__1) %>%
      dplyr::mutate(
        date = suppressWarnings(as.numeric(date)),
        date = as.Date(date, origin = "1899-12-30"),
        unit = as.character(unit),
        value = as.numeric(value)
      ) %>%
      dplyr::filter(!is.na(date))


    df <- df %>%
      # now remove appended series ID from the end of 'series'
      dplyr::mutate(series = stringi::stri_replace_all_regex(series,
        pattern = "_[^_]+$",
        replacement = ""
      ))
  }

  if (metadata == FALSE) {
    colnames(df) <- df[9, ]
    df <- df[-c(1:9), ]
    colnames(df)[1] <- "date"

    df <- df %>%
      tidyr::gather(
        key = series_id,
        value = value,
        -date
      ) %>%
      dplyr::mutate(
        date = as.Date(as.numeric(date), origin = "1899-12-30"),
        value = as.numeric(value)
      )
  }

  df
}
