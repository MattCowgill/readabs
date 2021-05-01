# Create internal data objects
devtools::load_all()
library(dplyr)
library(purrr)

# User agent for all download.file() / read_html()
readabs_user_agent <- "readabs R package - https://mattcowgill.github.io/readabs/index.html"
readabs_header <- c("User-Agent" = readabs_user_agent)

# Create old AWE/AWOTE data objects for read_awe() / read_awote() convenience functions -----

source(file.path("data-raw", "create_awe_objects.R"))

# Lookup table for LFS series IDs -----
# To re-create it from scratch source the `create_lfs_lookup.R` file
# source(file.path("data-raw", "create_lfs_lookup.R"))
lfs_lookup <- readRDS("data-raw/lfs_lookup.rds")

# Lookup table for data cube functions ------
abs_lookup_table <- scrape_abs_catalogues()

data_last_updated <- Sys.Date()

usethis::use_data(abs_lookup_table, data_last_updated,
                  awe_old,
                  lfs_lookup,
                  readabs_user_agent,
                  readabs_header,
  overwrite = TRUE, internal = TRUE
)

