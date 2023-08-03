test_that("read_api helper functions return tibbles with expected structure", {
  skip_on_cran()
  skip_if_offline()
  check_abs_connection()

  res <- read_api_dataflows()
  expect_s3_class(res, "tbl_df")
  expect_named(res, c("id", "name", "desc", "version"))

  res <- read_api_datastructure(sample(res$id, 1)) # Using a random dataflow
  expect_s3_class(res, "tbl_df")
  expect_named(res, c("role", "var", "position", "desc", "code", "label"))
})

test_that("read_api throws expected errors and warnings", {
  skip_on_cran()
  check_abs_connection()

  expect_error(read_api("doesnt_exist"), class = "http_404")
  expect_error(read_api_datastructure("doesnt_exist"), class = "http_404")

  expect_error(
    read_api("ERP_COB", datakey = list(not_a_var = 1), start_period = 2020),
    "Variable\\(s\\) .+ not found"
  )
  expect_error(
    read_api("ERP_COB", datakey = list(unit_measure = "PSNS"), start_period = 2020),
    "Cannot filter on .*"
  )
  expect_warning(
    read_api("ERP_COB", datakey = list(age = -99:-90), start_period = 2020),
    "`age` does not contain codes: -99, -98, -97, -96, -95, \\.\\.\\."
  )

  expect_error(
    read_api_url(c("www.google.com", "www.google.com")),
    "must be of length 1"
  )
  expect_error(
    read_api_url("www.google.com"),
    ".* is not an ABS query ur"
  )
})

test_that("read_api filtering works as expected", {
  skip_on_cran()
  check_abs_connection()

  x <- read_api("ABS_C16_T10_SA", datakey = list(asgs_2016 = 0, sex_abs = 3))
  expect_equal(as.integer(unique(x["asgs_2016"])), 0)
  expect_equal(as.integer(unique(x["sex_abs"])), 3)
})

test_that("url queries work", {
  skip_on_cran()
  check_abs_connection()

  wpi_url <- "https://api.data.abs.gov.au/data/ABS,WPI,1.0.0/1.THRPEB..C+B+TOT..AUS.Q?startPeriod=2020-Q1"
  res <- read_api_url(wpi_url) %>%
    arrange(measure, index, sector, industry, tsest, region, freq, time_period)

  expect_s3_class(res, "tbl_df")
  expect_true(labelled::is.labelled(res$measure))
  expect_length(res, 13)
  expect_gt(nrow(res), 142)
})
