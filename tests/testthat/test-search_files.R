test_that("search_files function", {
  expect_true(exists("search_files")) # Exists in workspace
  expect_error(search_catalogues()) # Raises error without specifying keyword arguments
  expect_error(search_files(TRUE, TRUE, TRUE)) # Returns an error with incorrect argument types

  # Test case 1: Search for "GM1" in "labour-force-australia" catalogue
  expected_output_1 <- c("GM1.xlsx", 'GM1_Historical.xlsx')
  actual_output_1 <- search_files("GM1", "labour-force-australia")
  expect_equal(actual_output_1, expected_output_1)

  # Test case 2: Search for "XYZ" in "labour-force-australia" catalogue
  expected_output_3 <- character(0)
  actual_output_3 <- search_files("XYZ", "labour-force-australia")
  expect_equal(actual_output_3, expected_output_3)
})