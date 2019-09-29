
.onLoad <- function(libname = find.package("readabs"), pkgname = "readabs") {
  if (is.na(Sys.getenv("R_READABS_PATH", unset = NA))) {
    packageStartupMessage("Environment variable 'R_READABS_PATH' is unset. ",
                          "Downloaded files will be saved in a temporary directory.\n\n",
                          "You can set 'R_READABS_PATH' at any time. To set it for ",
                          "the rest of this session, use\n\tSys.setenv(R_READABS_PATH = <path>)\n",
                          "Alternatively, you may wish to set the environment variable ",
                          "at a system level, or using your .Renviron file, so that readabs ",
                          "uses the same path every session.")
  }
  invisible(NULL)
}



