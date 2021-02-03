# Create internal data objects
devtools::load_all()
library(dplyr)
library(purrr)

# User agent for all download.file() / read_html() functions
readabs_user_agent <- "readabs R package - https://mattcowgill.github.io/readabs/index.html"

# Old AWE/AWOTE data for read_awe() / read_awote() convenience functions -----
dl_if_not <- function(file, url) {
  if (!file.exists(file)) {
    download.file(url = url,
                  headers = c("User-Agent" = readabs_user_agent),
                  destfile = file)
  }
}

#' @param filenames vector of 2 filenames excl. path. First element is filename
#'  for AWE file to May 2009; second is file to May 2012.
#' @param urls vector of 2 ABS URLs; first is for AWE file to May 2009;
#' second is file to May 2012.

load_old_awe <- function(table_num,
                         urls) {

  filenames <- paste0(c("awe_to_may09_t",
                        "awe_to_may12_t"),
                      table_num,
                      ".xls")

  old_awote_dir <- file.path("data-raw", "old_awote")
  filenames_incl_path <- file.path(old_awote_dir, filenames)

  purrr::walk2(.x = filenames_incl_path,
               .y = urls,
               .f = dl_if_not)

  list_of_dfs <- purrr::map(.x = filenames,
                            .f = ~read_abs_local(filenames = .x,
                                                 path = old_awote_dir))

  list_of_dfs <- purrr::map(.x = list_of_dfs,
                            .f = tidy_awe)

  list_of_dfs[[1]] <- list_of_dfs[[1]] %>%
    dplyr::filter(!.data$date %in% list_of_dfs[[2]]$date)

  df <- bind_rows(list_of_dfs)

  df
}


urls <- list("2" = c("https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&6302002.xls&6302.0&Time%20Series%20Spreadsheet&5379E96E39273CF5CA25761000199DDA&0&May%202009&13.08.2009&Latest",
                     "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&6302002.xls&6302.0&Time%20Series%20Spreadsheet&16F1263CC960388CCA257A5B00121514&0&May%202012&16.08.2012&Latest"),
             "5" = c("https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&6302005.xls&6302.0&Time%20Series%20Spreadsheet&050F0580F25B65E3CA2576100019ABA5&0&May%202009&13.08.2009&Latest",
                     "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&6302005.xls&6302.0&Time%20Series%20Spreadsheet&1E27AEE93FD82D5BCA257A5B00121697&0&May%202012&16.08.2012&Latest"),
             "8" = c("https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&6302008.xls&6302.0&Time%20Series%20Spreadsheet&AFD09874D98173D1CA2576100019B97A&0&May%202009&13.08.2009&Latest",
                     "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&6302008.xls&6302.0&Time%20Series%20Spreadsheet&42F0D3762EA4B015CA257A5B00121828&0&May%202012&16.08.2012&Latest"),
             "12a" = c("https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&63020012a.xls&6302.0&Time%20Series%20Spreadsheet&9CBA3F3531072C68CA257610001A1011&0&May%202009&13.08.2009&Latest",
                       "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&63020012a.xls&6302.0&Time%20Series%20Spreadsheet&3995977F136AE267CA257A5B00122365&0&May%202012&16.08.2012&Latest"))

awe_old <- map2(.x = names(urls),
     .y = urls,
     .f = load_old_awe)

awe_old <- setNames(awe_old, names(urls))



# Lookup table for data cube functions ------
abs_lookup_table <- scrape_abs_catalogues()

data_last_updated <- Sys.Date()

usethis::use_data(abs_lookup_table, data_last_updated,
                  awe_old,
                  readabs_user_agent,
  overwrite = TRUE, internal = TRUE
)
