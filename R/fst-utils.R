#' Internal functions for working with the fst cache
#' @name fst-utils
#' @noRd
#'
#' @param cat_no,tpath As in \code{\link{read_abs}}.
#' @param table A length-one vector.
#'   Either "all" or an integer vector specifying the table within
#'   `cat_no`.  If "all" or `integer(0)`, the filename just reflects the `cat_no`.
#'   Otherwise, the filename will be specific for the `table`. Note that `read_abs`
#'   accepts `length(tables) > 1` but `catno2fst` does not (since it would mean
#'   every combination of `tables` would be cached).
#'
#' @return For `catno2fst` the path to the `fst` file to be saved or read, given
#' `cat_no`, `table`, and `path`.
#'
#' `fst_available` returns `TRUE` if and only if an appropriate `fst` file is
#' available.
#'
#' `ext2ext` changes the extension of the provided file to a file in the same
#' path but with the provided extension.
#'


catno2fst <- function(cat_no,
                      table = integer(0L),
                      path = Sys.getenv("R_READABS_PATH", unset = tempdir())) {
  if (length(table) > 1L) {
    stop("Internal error (catno2fst): length(table) > 1 at this time. Please report.")
  }
  basename.fst <- gsub(".", "-", cat_no, fixed = TRUE)
  if (length(table) == 0L || identical(table, "all")) {
    basename.fst <- paste0(basename.fst, ".fst")
  } else {
    basename.fst <- paste0(basename.fst, sprintf("T%02d", table), ".fst")
  }
  fullname.fst <- file.path(path, "fst", basename.fst)
  hutils::provide.file(fullname.fst,
                       on_failure = stop("`path = ",
                                         normalizePath(path, winslash = "/"),
                                         "`, ",
                                         "but it was not possible to write to this directory."))
}

fst_available <- function(cat_no,
                          table = integer(0L),
                          path = Sys.getenv("R_READABS_PATH",
                                            unset = tempdir())) {
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

  file.fst <- catno2fst(cat_no, table = table, path)

  if (!file.exists(file.fst)) {
    return(FALSE)  # nocov
  }
  # Is the file clearly not an fst file
  # (where "clearly not an fst file" means "empty" or "a directory")?
  file_info <- file.info(file.fst, extra_cols = FALSE)
  if (!file_info[["size"]] || file_info[["isdir"]]) {
    return(FALSE)
  }

  # fst may be damaged/not a real fst file.
  # If it appears to be (i.e. fst metadata returns an error)
  #   return FALSE
  out <- tryCatch(inherits(fst::fst.metadata(file.fst), "fstmetadata"),
                  error = function(e) FALSE,
                  warning = function(e) FALSE)

  out
}

ext2ext <- function(file, new.ext) {
  paste0(tools::file_path_sans_ext(file), new.ext)
}
