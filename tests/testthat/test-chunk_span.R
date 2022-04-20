test_that("chunk_span works", {
  good_years <- "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M9.3.1599.30+10+20.AUS.M?startPeriod=2010&endPeriod=2022&dimensionAtObservation=AllDimensions"
  bad_years <- "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M9.3.1599.30+10+20.AUS.M?startPeriod=2021&endPeriod=2021&dimensionAtObservation=AllDimensions"

  good_months <- "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M9.3.1599.30+10+20.AUS.M?startPeriod=2010-01&endPeriod=2022-12&dimensionAtObservation=AllDimensions"

  bad_months <- "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M9.3.1599.30+10+20.AUS.M?startPeriod=2010-02&endPeriod=2022-05&dimensionAtObservation=AllDimensions"

  no_end <- "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M9.3.1599.30+10+20.AUS.M?startPeriod=2015-02&dimensionAtObservation=AllDimensions"

  chunks <- c(
    good_years,
    bad_years,
    good_months,
    bad_months,
    no_end
  ) %>%
    purrr::map(chunk_span)

  # Test characters
  chunks %>%
    purrr::walk(expect_type, type = "character")

  # Test lengths

  last_length <- as.numeric(format(Sys.Date(), "%Y")) - 2015 + 1

  chunks %>%
    purrr::walk2(
      .y = c(13, 1, 13, 13, last_length),
      expect_length
    )
})
