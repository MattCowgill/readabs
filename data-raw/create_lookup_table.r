
abs_lookup_table <- scrape_abs_catalogues(refresh = FALSE)

usethis::use_data(abs_lookup_table, overwrite = TRUE, internal = FALSE)
