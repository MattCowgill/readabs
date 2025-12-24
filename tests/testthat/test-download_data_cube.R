test_that("read_lfs_datacube", {
  skip_on_cran()
  avail_cubes <- get_available_lfs_cubes()
  expect_s3_class(avail_cubes, "tbl_df")
  expect_length(avail_cubes, 3)
  expect_gt(nrow(avail_cubes), 1)

  lm1 <- read_lfs_datacube("LM1")
  expect_s3_class(lm1, "tbl_df")
  expect_length(lm1, 10)
  expect_gt(nrow(lm1), 300000)
})

# Test for MRM, which has a different format, and therefore parsing logic
test_that("read_lfs_datacube - MRM", {
  mrm1 <- read_lfs_datacube("MRM1")
  expect_s3_class(mrm1, "tbl_df")
  expect_gt(nrow(mrm1), 30000)
})
