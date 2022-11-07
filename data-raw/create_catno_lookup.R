library(rvest)
library(dplyr)

tsd_url <- "https://www.abs.gov.au/websitedbs/D3310114.nsf/home/Time+Series+Directory+-+URL+formula+instructions+for+access+to+Time+Series+Metadata"

tsd_url |>
  read_html() |>
  html_element("#middle > tbody > tr > td > div > div > table:nth-child(157) > tbody")

cat_lookup <- tsd_url |>
  read_html() |>
  html_elements("table") |>
  purrr::pluck(3) |>
  html_table(header = T) |>
  rename(topic = Topic,
         cat_no = starts_with("Catalogue"))

joined <- search_catalogues("")  |>
  left_join(cat_lookup,
            by = c("sub_heading" = "topic"))

cat_lookup |>
  filter(!cat_no %in% joined$cat_no)
