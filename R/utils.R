#' Slightly faster version of str_squish
#' @param string A string to squish
#' @keywords internal
fast_str_squish <- function(string) {
  stringi::stri_trim_both(gsub("\\s+", " ", string, perl = TRUE))
}
