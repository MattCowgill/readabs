local_path <- "../testdata"
local_filename <- "6202021.xls"

check_abs_site <- function() {
  if (is.null(curl::nslookup("abs.gov.au", error = FALSE))) {
    skip("ABS Time Series Directory not available")
  }
}

test_that("separate_series() performs as expected", {
  skip_on_cran()

  check_abs_site()

  wpi_raw <- read_abs("6345.0",
    tables = "1",
    check_local = FALSE,
    retain_files = FALSE,
    path = tempdir()
  )

  wpi <- suppressWarnings(separate_series(wpi_raw))

  expect_equal(17, length(wpi))

  expect_equal(5, length(unique(wpi$series_1)))

  expect_true(all.equal(wpi$series, wpi_raw$series))
})

test_that("separate_series(remove_nas = TRUE) removes NAs", {
  lfs_21 <- read_abs_local(
    filename = local_filename,
    path = local_path
  )

  lfs_21_sep <- suppressWarnings(separate_series(lfs_21))

  non_nas <- lfs_21_sep %>%
    filter(!is.na(series_1) & !is.na(series_2)) %>%
    nrow()

  nas <- lfs_21_sep %>%
    filter(is.na(series_1) | is.na(series_2)) %>%
    nrow()

  expect_warning(separate_series(lfs_21))

  expect_message(separate_series(lfs_21, remove_nas = TRUE))

  expect_equal(nrow(separate_series(lfs_21, remove_nas = TRUE)), non_nas)

  expect_equal(nas + non_nas, nrow(lfs_21_sep))
})


test_that("separate_series works with remove_totals and remove_nas both TRUE", {
  skip_on_cran()

  check_abs_site()

  awote <- read_abs("6302.0", "10G", retain_files = FALSE, path = tempdir())

  expect_is(
    suppressWarnings(separate_series(awote)),
    "tbl_df"
  )

  expect_is(
    suppressWarnings(separate_series(awote, remove_totals = TRUE)),
    "tbl_df"
  )

  expect_is(
    suppressWarnings(separate_series(awote, remove_nas = TRUE)),
    "tbl_df"
  )

  expect_is(
    suppressWarnings(separate_series(awote, remove_totals = TRUE, remove_nas = TRUE)),
    "tbl_df"
  )
})
