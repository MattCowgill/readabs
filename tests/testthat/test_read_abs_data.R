library(readabs)
data_path <- "../testdata/5206002_expenditure_volume_measures.xls"
result <- readabs::read_abs_data(data_path, sheet = 2)
test_that("Check that the resulting output contains three headers", {
  expect_equal(colnames(result), c("Date", "series", "value"))
})


test_that("Check that the Date column contains date values", {
  expect_true(inherits(result$Date, "Date"))
})


md_result <- readabs::read_abs_metadata(data_path, sheet = 2)
test_that("Check that the Date column contains date values", {
  expect_true(inherits(c(result$`Series Start`, "Date"),
                       results$`Series End`))
})


