test_that("tidy_awe() returns tidied data frame", {
  skip_if_offline()
  skip_on_cran()

  temp_loc <- tempfile(fileext = ".xls")

  download.file(url = "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&6302002.xls&6302.0&Time%20Series%20Spreadsheet&5379E96E39273CF5CA25761000199DDA&0&May%202009&13.08.2009&Latest",
                destfile = temp_loc)

  awe <- readxl::read_excel(temp_loc,
                            sheet = "Data1")

  awe <- tidy_abs(awe)

  tidied_awe <- tidy_awe(awe)

  expect_is(tidied_awe, "data.frame")
  expect_equal(nrow(tidied_awe), 927)
  expect_true(all(
    c("date", "sex", "wage_measure", "value") %in% names(tidied_awe)
                   ))
  expect_false(any(is.na(tidied_awe$value)))
})

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
  expect_gt(max(no_params$value, na.rm = T) /
              min(no_params$value, na.rm = T),
            4.5)

  params_df <- expand.grid(sex = c("persons", "males", "females"),
              wage_measure = c("awote", "ftawe", "awe"),
              stringsAsFactors = FALSE)

  sex_wage_meas <- purrr::map2(
    .x = params_df$sex,
    .y = params_df$wage_measure,
    .f = ~read_awe(wage_measure = .y, sex = .x))

  sex_wage_meas

  purrr::map(sex_wage_meas,
      ~expect_is(.x, "tbl_df"))

  purrr::map(sex_wage_meas,
             ~expect_identical(names(.x),
                               c("date", "sex", "wage_measure", "value")))

  expect_identical(unique(read_awe(sector = "public")$crosstab),
                   "public")

  expect_identical(unique(read_awe(sector = "private")$crosstab),
                   "private")


  expect_gt(nrow(read_awe()), nrow(read_awe(na.rm = TRUE)))
})
