test_that("read_lfs_grossflows() downloads and imports LFS cube GM1", {

  skip_if_offline()
  skip_on_cran()

  prev_option <- getOption("timeout")
  options("timeout" = 120)
  gf_cur <- read_lfs_grossflows()
  gf_prev <- read_lfs_grossflows(weights = "previous")

  options("timeout" = prev_option)

  # Current should still be the default
  expect_identical(unique(gf_cur$weights),
                   "current month")

  # Pass minimal tests
  expect_true(check_lfs_grossflows(gf_cur))
  expect_true(check_lfs_grossflows(gf_prev))

  expect_gt(nrow(gf_cur), 1000000)
  expect_false(identical(gf_cur, gf_prev))
  expect_false(any(is.na(gf_cur$persons)))
  expect_equal(min(gf_cur$persons), 0)
  expect_true(max(gf_cur$persons) > min(gf_cur$persons))
})
