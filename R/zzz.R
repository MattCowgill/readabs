.onAttach <- function(libname = find.package("readabs"), pkgname = "readabs") {
  if (is.na(Sys.getenv("R_READABS_PATH", unset = NA))) {
    packageStartupMessage(
      "Environment variable 'R_READABS_PATH' is unset. ",
      "Downloaded files will be saved in a temporary directory.\n",
      "You can set 'R_READABS_PATH' at any time. To set it for ",
      "the rest of this session, use\n\tSys.setenv(R_READABS_PATH = <path>)"
    )
  }
  invisible(NULL)
}
