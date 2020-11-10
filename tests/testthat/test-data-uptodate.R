
test_that("Lookup table down download_data_cube() is up to date", {
  skip_if_offline()
  skip_on_cran()
  check_abs_connection()

  updated_lookup_table <- scrape_abs_catalogues()

  expect_equal(
    dplyr::arrange(updated_lookup_table, url),
    dplyr::arrange(abs_lookup_table, url)
  )
})

test_that("Data has been updated within last 120 days", {
  skip_on_cran()

  todays_date <- Sys.Date()

  expect_lt(todays_date - data_last_updated, 120)
})
