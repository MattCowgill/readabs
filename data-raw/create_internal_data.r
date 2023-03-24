# Create internal data objects
devtools::load_all()
library(dplyr)
library(purrr)

# User agent for all download.file() / read_html()
readabs_user_agent <- "readabs R package - https://mattcowgill.github.io/readabs/index.html"
readabs_header <- c("User-Agent" = readabs_user_agent)

# Create old AWE/AWOTE data objects for read_awe() / read_awote() convenience functions -----

source(file.path("data-raw", "create_awe_objects.R"))


# Lookup table for data cube functions ------
abs_lookup_table <- scrape_abs_catalogues()

data_last_updated <- Sys.Date()

# Save
usethis::use_data(abs_lookup_table, data_last_updated,
  awe_old,
  readabs_user_agent,
  readabs_header,
  overwrite = TRUE, internal = TRUE
)
