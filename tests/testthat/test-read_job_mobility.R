test_that("read_job_mobility() works as expected", {
  skip_on_cran()
  skip_if_offline()
  check_abs_connection()

  test_mobility_df <- function(df) {
    expect_length(df, 12)
    expect_gt(nrow(df), 0)
    expect_identical(
      names(df),
      c(
        "table_no",
        "sheet_no",
        "table_title",
        "date",
        "series",
        "value",
        "series_type",
        "data_type",
        "collection_month",
        "frequency",
        "series_id",
        "unit"
      )
    )
    expect_is(df$value, "numeric")
    expect_is(df$date, "Date")
  }

  test_mobility_df(read_job_mobility(1))
  test_mobility_df(read_job_mobility())
})
