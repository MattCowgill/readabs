## ---- echo = FALSE-------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.path = "doc/figures/VIGNETTE-",
  out.width = "50%"
)

## ----load-package--------------------------------------------------------
library(readabs)

## ----download-data-------------------------------------------------------
demog <- read_abs("3101.0")

## ----erp-line------------------------------------------------------------
library(tidyverse)

demog %>%
  filter(series == "Estimated Resident Population (ERP) ;  Australia ;") %>%
  ggplot(aes(x = date, y = value)) +
  geom_line() +
  theme_minimal() +
  labs(title = "There's more of us than there used to be",
       subtitle = "Estimated resident population of Australia over time (thousands)",
       caption = "Source: ABS 3101.0") +
  theme(axis.title = element_blank() )

## ----erp-byage-bar-------------------------------------------------------
age_distrib <- demog %>%
  filter(grepl("Estimated Resident Population ;  Persons ;", series),
         # In this case we only want to retain rows where the series contains a digit
         str_detect(series, "\\d"),
         # We only want the latest date
         date == max(date),
         # We only want data from table 59, which refers to the whole country
         table_no == "3101059") %>% 
  mutate(age = parse_number(series)) 

age_distrib %>% ggplot(aes(x = age, y = value)) +
  geom_col(col = "white") +
  theme_minimal() +
  scale_y_continuous(labels = scales::number) +
  labs(title = "People in their 30s rule Australia",
       subtitle = paste0("Distribution of Australian residents by age, ",
                         lubridate::year(age_distrib$date[1])),
       caption = "Source: ABS 3101.0") +
  theme(axis.title = element_blank() )
  

## ----erp-babies-line-----------------------------------------------------
demog %>%
  filter(series_id == "A2158920J") %>%
  ggplot(aes(x = date, y = value)) +
  geom_line() +
  theme_minimal() +
  labs(title = "Hello little babies!",
       subtitle = "Estimated resident population of 0 year old males over time",
       caption = "Source: ABS 3101.0") +
    theme(axis.title = element_blank() )


## ----lfs_1---------------------------------------------------------------

lfs_1 <- read_abs("6202.0", tables = 1)

lfs_1 %>%
  filter(series == "Unemployment rate ;  Persons ;") %>%
  ggplot(aes(x = date, y = value, col = series_type)) +
  geom_line() +
  theme_minimal() +
  theme(legend.position = "top") +
  labs(title = "The unemployment rate!",
       subtitle = "Australia's unemployment rate over time (per cent)",
       caption = "Source: ABS 6202.0") 

## ----lfs_1_5-------------------------------------------------------------

lfs_1_5 <- read_abs("6202.0", tables = c(1, 5))


