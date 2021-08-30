#'Get tidy data from ABS
#'
#'This function returns a tidy tibble of flat-view and JSON format data queried
#'using the ABS' API URL. It first identifies whether the URL entered uses the
#'ABS' old or new API URL structure. If the URL is super long, it's also passed
#'through the \code{api_split_url} function, which splits up the large URL into
#'a combination of smaller URLs to increase efficiency. The resulting URL/s
#'is/are then passed through \code{tidy_api_data}, which returns a tidy tibble
#'of your data.
#'
#'@param url (char) The API URL used to query the data you want from the ABS.
#'
#'  Both the ABS.Stat URL structure and the new API URL structure (as outlined
#'  on api.gov.au) are accepted. The following parameters would just need to be
#'  included in the URLs to organise the data in the flat view and JSON format:
#'  dimensionAtObservation=allDimensions (for the ABS.Stat SDMX-JSON API) and
#'  format=jsondata&dimensionAtObservation=AllDimensions (for the new API).
#'
#'  Automatically generate the ABS.Stat URL:
#'  Click on the dataset you want at \url{http://stat.data.abs.gov.au/}. Then
#'  export the data as a "Developer API" and copy and paste the URL under the
#'  "Data query:" heading. The "SDMX-JSON flavour:" should be checked as
#'  "Flat format".
#'
#'  IMPORTANT: If the URL is larger than 4087 characters, the RStudio console
#'  will NOT be able to take the string input. Therefore, first assign your URL
#'  to a variable by using \code{abs_clipboard} (see first example).
#'
#'@return (tibble) Returns a tidy tibble containing the ABS data you queried.
#'@export
#'
#' @examples
#' \dontrun{
#' ### Get tidy dataset from a large URL (4087+ characters):
#' # First copy the URL
#' url <- abs_clipboard()
#' tidy_data <- read_abs_api(url)
#'
#' ### Get tidy ALC dataset using the ABS.Stat structure:
#' old_url <- paste0("http://stat.data.abs.gov.au/sdmx-json/data/ALC/",
#'  "all/ABS?startTime=2010&endTime=2016&detail=DataOnly",
#'   "&dimensionAtObservation=AllDimensions")
#' tidy_data <- read_abs_api(old_url)
#' tidy_data
#'
#' ### Get tidy ALC dataset using the new URL structure:
#' new_url <- paste0("https://api.data.abs.gov.au/data/ALC/",
#'   "all?startPeriod=2010&endPeriod=2016&format=jsondata",
#'   "&dimensionAtObservation=AllDimensions")
#' tidy_data <- read_abs_api(new_url)
#' tidy_data
#' }
read_abs_api <- function(url) {
  chars <- "/sdmx-json/" #only the ABS.Stat URL structure includes this
  old_api <- grepl(chars, url)

  #check for URLs with more than 1000 characters
  long_url <- nchar(url) > 1000

  if (long_url) {
    api_split_url(url, old_api) %>%
      purrr::map_dfr(tidy_api_data, old_api = old_api)
  } else {
    tidy_api_data(url = url, old_api = old_api)
  }
}
