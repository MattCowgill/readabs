#' This function checks to see if the ABS website is available.
#' If available, it invisbly returns `TRUE`. If unavailable, it will
#' stop with an error.
#' @noRd

check_abs_connection <- function() {
  # Try nslookup. If this fails, try accessing abs.gov.au/robots.txt
  if (is.null(curl::nslookup("abs.gov.au", error = FALSE))) {
    if (isFALSE(test_abs_robots())) {
      stop(
        "R cannot access the ABS website.",
        " `read_abs()` requires access to the ABS site.",
        " Please check your internet connection and security settings."
      )
    }
  }
  invisible(TRUE)
}

#' Function to try accessing abs.gov.au/robots.txt. If this fails, return FALSE
#' @noRd
test_abs_robots <- function() {
  tmp <- tempfile()
  on.exit(unlink(tmp, recursive = TRUE), add = TRUE)
  result <- tryCatch(
    {
      suppressWarnings(utils::download.file(
        "https://www.abs.gov.au/robots.txt",
        destfile = tmp,
        quiet = TRUE,
        headers = c("User-Agent" = readabs_user_agent)
      ))
      file.exists(tmp)
    },
    error = function(e) {
      FALSE
    }
  )
  return(result)
}
