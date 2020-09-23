library(tidyverse)
library(glue)
library(rvest)
library(stringr)

#scrape the main page
abs_stats_page <- read_html("https://www.abs.gov.au/statistics")

main_page_data <- tibble::tibble(heading = abs_stats_page %>%
                                   html_nodes("h3") %>% html_text() %>% str_trim(),
                                 url_suffix = abs_stats_page %>% html_nodes(".layout__region--content a") %>% html_attr("href") %>% str_trim()) %>%
  filter(grepl("/statistics", url_suffix)) %>%
  filter(heading != "Key economic indicators")

#scrape each page

scrape_sub_page <- function(sub_page_url_suffix){


  main_page_heading <- main_page_data$heading[main_page_data$url_suffix == sub_page_url_suffix]


  sub_page <- read_html(glue("https://www.abs.gov.au{sub_page_url_suffix}"))

  sub_page_data <- tibble::tibble(heading = main_page_heading,
                                  sub_heading = sub_page %>% html_nodes(".abs-layout-title") %>% html_text() %>% str_trim(),
                                  catalogue = sub_page %>% html_nodes("#content .card") %>% html_attr("href") %>%
                                    str_remove(sub_page_url_suffix) %>%
                                    str_remove("/[^/]*$") %>%
                                    str_remove("/"),
                                  url = glue("https://www.abs.gov.au{sub_page_url_suffix}/{catalogue}/latest-release"))

}


abs_lookup_table <- map_dfr(main_page_data$url_suffix, scrape_sub_page)




usethis::use_data(abs_lookup_table, overwrite = TRUE, internal = TRUE)
