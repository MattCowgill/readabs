library(abs)
data_path <- "../testdata/20800_2011-2016_Microdata.xls"
result <- abs::read_abs_codebook(data_path, sheet = 2)
# test_that("Check that the resulting output contains three headers", {
#   expect_equal(colnames(result), c("Date", "series", "value"))
# })
# 
# 
# test_that("Check that the Date column contains date values", {
#   expect_true(inherits(result$Date, "Date"))
# })
