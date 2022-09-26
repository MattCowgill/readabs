
local_path <- "../testdata"
local_filename <- "6202021.xls"


# These functions are deprecated; they date to the pre-0.3.0 version of the package

test_that("Old read_abs_data() function imports a spreadsheet", {
  filepath <- paste0(local_path, "/", local_filename)

  expect_warning(read_abs_data(filepath, "Data1"))

  local_file <- suppressWarnings(read_abs_data(filepath, "Data1"))

  expect_is(local_file, "data.frame")

  expect_equal(length(colnames(local_file)), 3)
})

test_that("Old read_abs_metadata() function imports a spreadsheet", {
  filepath <- paste0(local_path, "/", local_filename)

  expect_warning(read_abs_metadata(filepath, "Data1"))

  local_file <- suppressWarnings(read_abs_metadata(filepath, "Data1"))

  expect_is(local_file, "data.frame")

  expect_equal(length(colnames(local_file)), 9)
})
