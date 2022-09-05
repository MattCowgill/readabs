test_that("check_latest_date() returns expected output", {
  skip_on_cran()
  skip_if_offline()
  skip_if_not(check_abs_connection())

  test_latest_date <- function(result) {
    print(class(result))
    expect_is(result, "Date")
    expect_length(result, 1)
    expect_gt(result, Sys.Date() - 180)
  }

  whole_cat <- check_latest_date("6345.0")
  single_table <- check_latest_date("6202.0", tables = 1)
  two_tables <- check_latest_date("6345.0", tables = c("1", "5a"))
  single_series <- check_latest_date(series_id = "A2713849C")

  purrr::map(
    c(
      whole_cat,
      single_table,
      two_tables,
      single_series
    ),
    test_latest_date
  )
})
