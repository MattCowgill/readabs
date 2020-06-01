library(readabs)

local_path <- "../testdata"
local_filename <- "6202021.xls"

check_abs_site <- function() {
  if(is.null(curl::nslookup("abs.gov.au", error = FALSE))){
    skip("ABS Time Series Directory not available")
  }
}

# These functions are deprecated; they date to the pre-0.3.0 version of the package

test_that("Old read_abs_data() function imports a spreadsheet",{

  filepath <- paste0(local_path, "/", local_filename)

  expect_warning(read_abs_data(filepath, "Data1"))

  local_file <- suppressWarnings(read_abs_data(filepath, "Data1"))

  expect_is(local_file, "data.frame")

  expect_equal(length(colnames(local_file)), 3)

})

test_that("Old read_abs_metadata() function imports a spreadsheet",{

  filepath <- paste0(local_path, "/", local_filename)

  expect_warning(read_abs_metadata(filepath, "Data1"))

  local_file <- suppressWarnings(read_abs_metadata(filepath, "Data1"))

  expect_is(local_file, "data.frame")

  expect_equal(length(colnames(local_file)), 9)

})

test_that("Old read_abs_sdmx function works",{

  skip_on_cran()

  check_abs_site()

  sdmx_url <- url <- "http://stat.data.abs.gov.au/restsdmx/sdmx.ashx/GetData/ABS_REGIONAL_ASGS/PENSION_2+BANKRUPT_2.AUS.0.A/all?startTime=2013&endTime=2013"

  sdmx_result <- read_abs_sdmx(sdmx_url)

  expect_true(is.data.frame(sdmx_result))

})

test_that("deprecated get_abs() function gives a warning message",
          {
            expect_warning(get_abs())
          })
