#' Assign a really long URL to a variable
#'
#' The RStudio console can only take string inputs with less than 4087
#' characters. This function gets around this by assigning the last string
#' you copied to a variable.
#'
#' @return An extremely long character string (4087+ chars) in its entirety
#' @export
#'
#' @examples
#' \dontrun{
#' ### Once you have copied the URL, call this function and assign it to a
#' ### variable name, which will be passed through the \code{read_abs_api}
#' ### function:
#'
#' url <- abs_clipboard()
#' read_abs_api(url)
#' }
abs_clipboard <- function() {
  utils::readClipboard()
}
