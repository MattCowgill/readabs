test_that("chunk_query_url works", {
  qu <- "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M1+M2+M3+M4+M5+M6+M9+M12+M13+M14+M15+M16.3.1599.20+30.AUS.M?startPeriod=2020&endPeriod=2022&dimensionAtObservation=AllDimensions"
  qus <- chunk_query_url(qu, n=2)

  # Hard-coded expectation
  expectation <- c("https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M1+M2.3.1599.20+30.AUS.M?startPeriod=2020&endPeriod=2020&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M3+M4.3.1599.20+30.AUS.M?startPeriod=2020&endPeriod=2020&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M5+M6.3.1599.20+30.AUS.M?startPeriod=2020&endPeriod=2020&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M9+M12.3.1599.20+30.AUS.M?startPeriod=2020&endPeriod=2020&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M13+M14.3.1599.20+30.AUS.M?startPeriod=2020&endPeriod=2020&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M15+M16.3.1599.20+30.AUS.M?startPeriod=2020&endPeriod=2020&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M1+M2.3.1599.20+30.AUS.M?startPeriod=2021&endPeriod=2021&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M3+M4.3.1599.20+30.AUS.M?startPeriod=2021&endPeriod=2021&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M5+M6.3.1599.20+30.AUS.M?startPeriod=2021&endPeriod=2021&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M9+M12.3.1599.20+30.AUS.M?startPeriod=2021&endPeriod=2021&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M13+M14.3.1599.20+30.AUS.M?startPeriod=2021&endPeriod=2021&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M15+M16.3.1599.20+30.AUS.M?startPeriod=2021&endPeriod=2021&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M1+M2.3.1599.20+30.AUS.M?startPeriod=2022&endPeriod=2022&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M3+M4.3.1599.20+30.AUS.M?startPeriod=2022&endPeriod=2022&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M5+M6.3.1599.20+30.AUS.M?startPeriod=2022&endPeriod=2022&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M9+M12.3.1599.20+30.AUS.M?startPeriod=2022&endPeriod=2022&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M13+M14.3.1599.20+30.AUS.M?startPeriod=2022&endPeriod=2022&dimensionAtObservation=AllDimensions",
                   "https://api.data.abs.gov.au/data/ABS,LF,1.0.0/M15+M16.3.1599.20+30.AUS.M?startPeriod=2022&endPeriod=2022&dimensionAtObservation=AllDimensions")

  expect_equal(qus, expectation)

})
