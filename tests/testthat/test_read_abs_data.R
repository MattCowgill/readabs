library(readabs)
library(testthat)
library(dplyr)
data_path <- "../testdata/5206002_expenditure_volume_measures.xls"
result <- read_abs_data(data_path, sheet = 2)
test_that("Check that the resulting output contains three headers", {
  expect_equal(colnames(result), c("Date", "series", "value"))
})


test_that("Check that the Date column contains date values", {
  expect_true(inherits(result$Date, "Date"))
})


metadata_result <- read_abs_metadata(data_path, sheet=3)
test_that("Check that the Series End and Series Start columns contains date values", {
  expect_true(inherits(metadata_result$`Series Start`, "Date"))
  expect_true(inherits(metadata_result$`Series End`, "Date"))
})



url <- "http://stat.data.abs.gov.au/restsdmx/sdmx.ashx/GetData/ABS_REGIONAL_ASGS/PENSION_2+BANKRUPT_2.AUS.0.A/all?startTime=2013&endTime=2013"

sdmx_result <- read_abs_sdmx(url)
test_that("Check that the resulting output is a data frame", {
  expect_true(is.data.frame(sdmx_result))
})







