test_that("read_abs_url() behaves as expected", {
  skip_on_cran()
  skip_if_offline()
  check_abs_connection()

  my_url <- "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&136401500301.xls&1364.0.15.003&Time%20Series%20Spreadsheet&4E7EEA9838FD6744CA2579340011C2D1&0&Jun%20Qtr%202011&26.10.2011&Latest"

  # Test it works with a single URL
  expect_s3_class(read_abs_url(my_url),
                  "tbl_df")

  # Test the file exists in the expected location after download
  my_path <- file.path(tempdir(), "read_abs_local_test_dir")

  rm(list = list.files(path = my_path))

  read_abs_url(my_url, path = my_path)

  expect_true(file.exists(file.path(my_path, "136401500301.xls")))

  # Test multiple URLs work
  multiple_urls <- read_abs_url(c("https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&136401500301.xls&1364.0.15.003&Time%20Series%20Spreadsheet&4E7EEA9838FD6744CA2579340011C2D1&0&Jun%20Qtr%202011&26.10.2011&Latest",
                 "https://www.abs.gov.au/statistics/labour/employment-and-unemployment/labour-force-australia/aug-2022/6202001.xlsx"))


  expect_s3_class(multiple_urls, "tbl_df")
  expect_gt(nrow(multiple_urls), 60000)

})
