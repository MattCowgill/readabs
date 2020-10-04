
abs_lookup_table <- scrape_abs_catalogues()

data_last_updated <- Sys.Date()


usethis::use_data(abs_lookup_table, data_last_updated,
                  overwrite = TRUE, internal = TRUE)

