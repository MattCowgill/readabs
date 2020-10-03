check_abs_site <- function() {
  if (is.null(curl::nslookup("abs.gov.au", error = FALSE))) {
    skip("ABS Time Series Directory not available")
  }
}

test_that("File is downloaded", {
  # Download latest EQ09

  testthat::skip_on_cran()
  check_abs_site()

  temp_path <- tempdir()

  download_abs_data_cube(
    catalogue_string = "labour-force-australia-detailed-quarterly",
    cube = "EQ09",
    path = temp_path
  )


  # Check file exists
  expect_true(file.exists(file.path(temp_path, "EQ09.xlsx")))


  # Check file can be read
  eq09 <- readxl::read_excel(file.path(temp_path, "EQ09.xlsx"),
    range = "A3",
    col_names = FALSE
  ) %>%
    dplyr::pull()
  expect_equal(TRUE, grepl("Released at 11.30 am", eq09))

  unlink(temp_path)
})
