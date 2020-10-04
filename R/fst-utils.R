#' Internal functions for working with the fst cache
#' @name fst-utils
#' @noRd
#'
#' @param cat_no,path As in \code{\link{read_abs}}.
#'
#' @return For `catno2fst` the path to the `fst` file to be saved or read, given
#' `cat_no` and `path`.
#'
#' `fst_available` returns `TRUE` if and only if an appropriate `fst` file is
#' available.
#'
#' `ext2ext` changes the extension of the provided file to a file in the same
#' path but with the provided extension.
#'


catno2fst <- function(cat_no,
                      path = Sys.getenv("R_READABS_PATH", unset = tempdir())) {
  hutils::provide.file(file.path(
    path,
    "fst",
    paste0(
      gsub(".", "-", cat_no, fixed = TRUE),
      ".fst"
    )
  ),
  on_failure = stop(
    "`path = ", normalizePath(path,
      winslash = "/"
    ),
    "`, ",
    "but it was not possible to write to this directory."
  )
  )
}

fst_available <- function(cat_no,
                          path = Sys.getenv("R_READABS_PATH",
                            unset = tempdir()
                          )) {
  if (!requireNamespace("fst", quietly = TRUE) ||
    !dir.exists(path)) {
    return(FALSE)
  }

  if (!is.character(cat_no) ||
    length(cat_no) != 1L ||
    anyNA(cat_no) ||
    nchar(cat_no) < 6L) {
    return(FALSE)
  }

  file.fst <- catno2fst(cat_no, path)

  if (!file.exists(file.fst)) {
    return(FALSE) # nocov
  }

  # fst may be damaged. If it appears to be (i.e. fst metadata returns an error)
  #   return FALSE


  out <- tryCatch(inherits(fst::fst.metadata(file.fst), "fstmetadata"),
    error = function(e) FALSE,
    warning = function(e) FALSE
  )

  out
}

ext2ext <- function(file, new.ext) {
  paste0(tools::file_path_sans_ext(file), new.ext)
}
