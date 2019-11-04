local_path <- "../testdata"
local_filename <- "6202021.xls"

check_abs_site <- function() {
  if(is.null(curl::nslookup("abs.gov.au", error = FALSE))){
    skip("ABS Time Series Directory not available")
  }
}

test_that("separate_series() performs as expected",{

  skip_on_cran()

  check_abs_site()

  motor_vehicles_raw <- read_abs("9314.0", retain_files = FALSE, path = tempdir())

  motor_vehicles <- suppressMessages(separate_series(motor_vehicles_raw))

  expect_equal(14, length(motor_vehicles))

  expect_equal(9, length(unique(motor_vehicles$series_1)))

  expect_true(all.equal(motor_vehicles$series, motor_vehicles_raw$series))

})

test_that("separate_series(remove_nas = TRUE) removes NAs", {

  lfs_21 <- read_abs_local(filename = local_filename,
                           path = local_path)

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

  expect_is(suppressWarnings(separate_series(awote)),
            "tbl_df")

  expect_is(suppressWarnings(separate_series(awote, remove_totals = TRUE)),
            "tbl_df")

  expect_is(suppressWarnings(separate_series(awote, remove_nas = TRUE)),
            "tbl_df")

  expect_is(suppressWarnings(separate_series(awote, remove_totals = TRUE, remove_nas = TRUE)),
            "tbl_df")

})
