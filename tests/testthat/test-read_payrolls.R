test_that("read_payrolls() works", {
  skip_if_offline()
  skip_on_cran()

  check_payrolls <- function(series) {
    print(series)
    df <- read_payrolls(series)
    expect_is(df, "tbl_df")
    expect_is(df$date, "Date")
    expect_is(df$value, "numeric")
    expect_gt(ncol(df), 4)
    expect_gt(nrow(df), 1000)
    expect_false(any(grepl(" ", names(df))))
  }

  purrr::map(
    c(
      "industry_jobs",
      "industry_wages",
      "sa4_jobs",
      "sa3_jobs",
      "subindustry_jobs",
      "empsize_jobs"
    ),
    ~ check_payrolls(.x)
  )
})
