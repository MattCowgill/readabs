library(readabs)
library(RCurl)

wpi_url <- "http://ausstats.abs.gov.au/servlet/TSSearchServlet?catno=6345.0&pg=1&ttitle=1"

check_abs_site <- function() {
  if(is.null(curl::nslookup("abs.gov.au", error = FALSE))){
    skip("ABS Time Series Directory not available")
  }
}

test_that("WPI XML page is a data.frame with expected column names",
          {
            skip_on_cran()
            check_abs_site()

            wpi_1_xml <- get_xml_df(wpi_url)

            expect_is(wpi_1_xml, "data.frame")
            expect_equal(colnames(wpi_1_xml)[1], "ProductNumber")
            expect_length(wpi_1_xml, 18)
            expect_gt(nrow(wpi_1_xml), 26)
          })

test_that("read_abs() downloads, imports, and tidies a data frame",
          {
            skip_on_cran()
            check_abs_site()

            wpi_1 <- read_abs("6345.0", tables = "1", retain_files = FALSE,
                              check_local = FALSE, path = tempdir())

            expect_is(wpi_1, "tbl")
            expect_length(wpi_1, 12)
            expect_gt(nrow(wpi_1), 2400)
            expect_is(wpi_1$date, "Date")
            expect_is(wpi_1$series, "character")
            expect_is(wpi_1$value, "numeric")
            expect_lt(Sys.Date() - max(wpi_1$date), 180)
          })

test_that("read_abs() gets a whole catalogue number",
          {
            skip_on_cran()
            check_abs_site()

            motors <- read_abs("9314.0", retain_files = FALSE, check_local = FALSE, path = tempdir())

            expect_is(motors, "tbl")
            expect_length(motors, 12)
            expect_gt(nrow(motors), 34000)
          })

test_that("read_abs() works when retain_files = FALSE",
          {
            skip_on_cran()
            check_abs_site()

            wpi_7 <- read_abs("6345.0", tables = "7a", retain_files = FALSE, check_local = F,
                              path = tempdir())

            expect_is(wpi_7, "tbl")
          })

test_that("read_abs() works with series ID(s)",
          {

            skip_on_cran()
            check_abs_site()

            cpi_2 <- read_abs(series_id = c("A2325846C", "A2325841T"), retain_files = FALSE, check_local = F, path = tempdir())

            expect_is(cpi_2, "tbl")
            expect_length(unique(cpi_2$series), 2)
            expect_match(unique(cpi_2$series)[1], "Index Numbers ;  All groups CPI ;  Canberra ;")
            expect_match(unique(cpi_2$series)[2], "Index Numbers ;  All groups CPI ;  Australia ;")
            expect_length(cpi_2, 12)

          })



test_that("read_abs() returns appropriate errors and messages when given invalid input",{

  skip_on_cran()
  check_abs_site()

  expect_error(read_abs(cat_no = NULL))
  expect_error(read_abs("6202.0", 1, retain_files = NULL, check_local = FALSE))
  expect_error(read_abs(cat_no = "6345.0", metadata = 1, check_local = FALSE))
  expect_error(read_abs(cat_no = "6345.0", series_id = "foo", check_local = FALSE),
               regexp = "either.*cat_no.*series_id")

})

test_that("read_abs() works with 'table 01' as well as 'table 1' filename structures",{

  skip_on_cran()
  check_abs_site()

  const_df <- read_abs("8755.0", 1, retain_files = FALSE, check_local = FALSE, path = tempdir())
  const_df_2 <- read_abs("8755.0", "1", retain_files = FALSE, check_local = FALSE, path = tempdir())

  expect_is(const_df, "data.frame")
  expect_equal(const_df, const_df_2)
  expect_length(const_df, 12)

})

test_that("read_abs() returns an error when requesting non-existing cat_no",{

  skip_on_cran()
  check_abs_site()

  expect_error(read_abs("9999.0"))

})


test_that("read_cpi() function downloads CPI index numbers",{
  skip_on_cran()
  check_abs_site()

  cpi <- read_cpi()

  expect_is(cpi, "tbl")
  expect_length(cpi, 2)
  expect_is(cpi$date, "Date")
  expect_is(cpi$cpi, "numeric")

  # Test ratio of latest to earliest CPI index numbers
  latest_cpi_date <- cpi$date[cpi$date == max(cpi$date)]
  total_cpi_ratio <- cpi$cpi[cpi$date == latest_cpi_date] / cpi$cpi[cpi$date == min(cpi$date)]
  expect_gt(total_cpi_ratio, 30)

  # Test that inflation over the 20 years to Sept 2019 is of the expected value
  inflation_99_to_19 <- cpi$cpi[cpi$date == as.Date("2019-09-01")] /
    cpi$cpi[cpi$date == as.Date("1999-09-01")]
  expect_gt(inflation_99_to_19, 1.675)
  expect_lt(inflation_99_to_19, 1.685)

  # Test that inflation over the most recent year is within expected bounds (0 to 5%)
  date_12m_before_latest <- as.POSIXlt(latest_cpi_date)
  date_12m_before_latest$year <- date_12m_before_latest$year - 1
  date_12m_before_latest <- as.Date(date_12m_before_latest)

  latest_annual_inflation <- (cpi$cpi[cpi$date == latest_cpi_date]/
    cpi$cpi[cpi$date == date_12m_before_latest]) - 1
  expect_gt(latest_annual_inflation, -.005)
  expect_lt(latest_annual_inflation, 0.05)

})

test_that("read_cpi() returns appropriate errors",{

  skip_on_cran()
  check_abs_site()

  expect_error(read_cpi(retain_files = NULL))
  expect_error(read_cpi(show_progress_bars = NULL))
  expect_error(read_cpi(retain_files = TRUE, path = 1))

})

test_that("read_abs() fails when offline", {
  skip_if(curl::has_internet())

  expect_error(read_abs("6202.0", 1),
               regexp = "R cannot access the ABS website.")

})
