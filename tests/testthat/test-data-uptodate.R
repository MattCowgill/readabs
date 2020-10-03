
test_that("Lookup table down download_data_cube() is up to date", {
  skip_if_offline()

  check_abs_connection()

  updated_lookup_table <- scrape_abs_catalogues()

  expect_identical(updated_lookup_table, abs_lookup_table)

})

test_that("Data has been updated within last 90 days", {

  todays_date <- Sys.Date()

  expect_lt(todays_date - data_last_updated, 90)
})
