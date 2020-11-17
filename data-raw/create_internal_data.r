# Create internal data objects
devtools::load_all()
library(dplyr)

# Old AWE/AWOTE data for read_awe() / read_awote() convenience functions -----
dl_if_not <- function(file, url) {
  if (!file.exists(file)) {
    download.file(url = url,
                  destfile = file)
  }
}

dl_if_not(file = file.path("data-raw", "old_awote", "awe_to_may09.xls"),
          url = "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&6302002.xls&6302.0&Time%20Series%20Spreadsheet&5379E96E39273CF5CA25761000199DDA&0&May%202009&13.08.2009&Latest")
dl_if_not(file = file.path("data-raw", "old_awote", "awe_to_may12.xls"),
          url = "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&6302002.xls&6302.0&Time%20Series%20Spreadsheet&16F1263CC960388CCA257A5B00121514&0&May%202012&16.08.2012&Latest")

awe_to_may09 <- read_abs_local(filenames = "awe_to_may09.xls", path = file.path("data-raw", "old_awote"))
awe_to_may12 <- read_abs_local(filenames = "awe_to_may12.xls", path = file.path("data-raw", "old_awote"))

awe_to_may09 <- tidy_awe(awe_to_may09)
awe_to_may12 <- tidy_awe(awe_to_may12)

awe_to_may09 <- awe_to_may09 %>%
  dplyr::filter(!.data$date %in% awe_to_may12$date)

awe_old <- dplyr::bind_rows(awe_to_may09, awe_to_may12)

# Lookup table for data cube functions ------
abs_lookup_table <- scrape_abs_catalogues()

data_last_updated <- Sys.Date()

usethis::use_data(abs_lookup_table, data_last_updated, awe_old,
  overwrite = TRUE, internal = TRUE
)
