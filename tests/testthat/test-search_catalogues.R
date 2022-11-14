test_that("search_catalogues() returns appropriate output", {
  expect_error(search_catalogues())

  lab <- search_catalogues("labour")
  lab_cap <- search_catalogues("LABOUR")
  lab_norefresh <- search_catalogues("labour", refresh = FALSE)

  expect_identical(lab, lab_norefresh)
  expect_identical(lab, lab_cap)
  expect_is(lab, "tbl")
  expect_length(lab, 4)
  expect_gt(nrow(lab), 20)
  expect_true(all(purrr::map_lgl(lab, ~ inherits(.x, "character"))))

  expect_true(nrow(search_catalogues("foobar")) == 0)
})

test_that("search_catalogues() refreshes table when requested", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not(check_abs_connection())

  ref <- search_catalogues("price", refresh = TRUE)

  expect_is(ref, "tbl")
  expect_length(ref, 4)
  expect_gt(nrow(ref), 4)
})
