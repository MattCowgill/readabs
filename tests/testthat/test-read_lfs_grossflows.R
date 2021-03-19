test_that("read_lfs_grossflows() downloads and imports LFS cube GM1", {

  skip_if_offline()
  skip_on_cran()

  gf_cur <- read_lfs_grossflows()
  gf_prev <- read_lfs_grossflows(weights = "previous")

  # Current should still be the default
  expect_identical(unique(gf_cur$weights),
                   "current month")

  # Pass minimal tests
  expect_true(check_lfs_grossflows(gf_cur))
  expect_true(check_lfs_grossflows(gf_prev))
  expect_gt(nrow(gf_cur), 1000000)

})
