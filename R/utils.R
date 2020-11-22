#' Very slightly faster version of stringr's str_squish()
#' @param string A string to squish (remove whitespace)
#' @keywords internal
fast_str_squish <- function(string) {
  stringi::stri_trim_both(gsub("\\s+", " ", string, perl = TRUE))
}
