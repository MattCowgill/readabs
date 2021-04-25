devtools::load_all()
library(dplyr)
library(purrr)
library(tidyr)

abs_6202_raw <- read_abs("6202.0")

# Some series IDs appear in multiple tables (eg. state totals are in state-level
# tables and comparison tables). Within each series ID, we want to retain the
# series that has the most characters (like "Employed total, persons, Victoria"
# rather than "Employed total, persons" within the Victoria table).

abs_6202 <- abs_6202_raw %>%
  group_by(series_id) %>%
  filter(nchar(series) == max(nchar(series))) %>%
  ungroup()


abs_split <- abs_6202 %>%
  split(.$series_id) %>%
  map(~suppressWarnings(separate_series(.x)))

identify_category <- function(x) {
  coll <- function(...) {
    paste(..., collapse = "", sep = "|")
  }

  states <- coll("New South Wales", "Victoria", "Queensland", "South Australia",
                  "Western Australia", "Tasmania", "Australian Capital Territory",
                  "Northern Territory")

  sex <- coll("Males", "Females", "Persons")

  indicator <- coll("Participation", "Unemploy", "Underemploy",
                     "Employ", "Ratio", "Rate", "Labour force",
                    "Civilian", "Hours")

  education <- coll("attending")

  age <- coll("years", "age")

  market_nonmarket <- coll("market", "agriculture", "training")

  any_grepl_ig <- function(pattern, x, ...) {
    any(grepl(pattern = pattern, x = x, ignore.case = TRUE, ...))
  }

  case_when(any_grepl_ig(states, x) ~ "state",
            any_grepl_ig(sex, x) ~ "sex" ,
            any_grepl_ig(indicator, x) ~ "indicator",
            any_grepl_ig(education, x) ~ "education",
            any_grepl_ig(age, x) ~ "age",
            any_grepl_ig(market_nonmarket, x) ~ "market_nonmarket"
            )
}

long <- abs_split %>%
  bind_rows() %>%
  group_by(series_id) %>%
  select(starts_with("series"), -series_type) %>%
  pivot_longer(
    names_to = "sub_series", values_to = "value",
               cols = !any_of(c("series_id", "series"))) %>%
  distinct()

long <- long %>%
  group_by(sub_series, series_id) %>%
  mutate(category = identify_category(value)) %>%
  ungroup() %>%
  select(-sub_series) %>%
  filter(!is.na(category))

wide <- long %>%
  pivot_wider(names_from = category,
              values_from = value)

wide %>%
  filter(grepl("Unemployment", indicator))

find_lfs <- function()



