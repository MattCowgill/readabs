test_that("read_lfs_datacube", {
  avail_cubes <- get_available_lfs_cubes()
  expect_s3_class(avail_cubes, "tbl_df")
  expect_length(avail_cubes, 3)
  expect_gt(nrow(avail_cubes), 50)

  lm1 <- read_lfs_datacube("LM1")
  expect_s3_class(lm1, "tbl_df")
  expect_length(lm1, 10)
  expect_gt(nrow(lm1), 300000)
})
