test_that("read_awe() returns expected output", {
  skip_if_offline()
  skip_on_cran()

  no_params <- read_awe()

  expect_is(no_params, "tbl_df")
  expect_identical(unique(no_params$sex), "persons")
  expect_identical(unique(no_params$wage_measure), "awote")
  expect_identical(min(no_params$date), as.Date("1983-11-15"))
  expect_gt(max(no_params$date), as.Date("2020-05-14"))
  expect_is(no_params$value, "numeric")
  expect_gt(max(no_params$value) / min(no_params$value),
            4.5)

  params_df <- expand.grid(sex = c("persons", "males", "females"),
              wage_measure = c("awote", "ftawe", "awe"),
              stringsAsFactors = FALSE)

  purrr::map2(
    .x = params_df$sex,
    .y = params_df$wage_measure,
    .f = ~expect_is(read_awe(wage_measure = .y, sex = .x),
                    "tbl_df")
  )
})
