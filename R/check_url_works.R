# Check if R can access a URL (such as 'abs.gov.au') to check internet access
# Note: if you use httr::http_error by itself, it returns an error when
# there's no connection (rather than returning 'FALSE' as desired)

#' @importFrom httr http_error
#' @importFrom purrr safely

check_url_works <- function(url){

  if(!is.character(url)){
    stop("check_url_works() requires a URL as string")
  }

  safe_check <- purrr::safely(httr::http_error)

  url_response <- safe_check(url)

  url_down <- ifelse(!is.null(url_response$error), TRUE,
                               ifelse(url_response$result == TRUE, TRUE, FALSE))

  url_works <- !url_down

  url_works

}
