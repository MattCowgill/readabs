library(readabs)

local_path <- "../testdata"
local_filename <- "6202021.xls"

test_that("Local file can be read and is in expected form", {
  lfs_21 <- extract_abs_sheets(local_filename, path = local_path)
  lfs_21_df <- lfs_21[[1]]

  expect_is(lfs_21, "list")
  expect_is(lfs_21_df, "data.frame")
  expect_is(lfs_21_df, "tbl")

  expect_equal(as.character(lfs_21_df[1, 1]), "Unit")
  expect_equal(as.character(lfs_21_df[10, 1]), "31017")
})

test_that("Local file can be tidied and looks how we expect", {
  lfs_21 <- extract_abs_sheets(local_filename, path = local_path)
  lfs_21_tidy <- tidy_abs_list(lfs_21)

  expect_length(lfs_21_tidy, 12)
  expect_is(lfs_21_tidy$date, "Date")
  expect_is(lfs_21_tidy$value, "numeric")
  expect_equal(as.character(lfs_21_tidy[1, 1]), "6202021")
})

test_that("Local file can be tidied without metadata", {
  no_meta <- read_abs_local(filenames = local_filename, path = local_path, metadata = FALSE)

  expect_is(no_meta, "data.frame")
  expect_length(no_meta, 6)
})



test_that("tidy_abs_list() gives appropriate errors", {
  expect_error(tidy_abs_list(data.frame(x = 1)))

  expect_error(tidy_abs_list(c(1, 2)))
})

test_that("tidy_abs() gives appropriate errors", {
  expect_error(tidy_abs(df = c(1, 2)))

  expect_error(tidy_abs(data.frame(x = 1)))

  expect_error(tidy_abs(df = data.frame(x = 1, y = 2), metadata = 1))

  expect_error(tidy_abs(df = data.frame(x = c(1:10), y = c(1:10))))
})

test_that("Local file can be read", {
  lfs_21 <- read_abs_local(filenames = local_filename, path = local_path)

  expect_length(lfs_21, 12)
  expect_is(lfs_21$date, "Date")
  expect_is(lfs_21$value, "numeric")
  expect_equal(as.character(lfs_21[1, 1]), "6202021")
  expect_gt(nrow(lfs_21), 951)
})


test_that("read_abs_local() returns appropriate errors and messages", {
  expect_error(read_abs_local(filenames = NULL, path = NULL))

  expect_error(read_abs_local(filenames = 1), path = "../testdata")

  expect_error(read_abs_local(path = "../empty"))

  expect_error(read_abs_local(
    filenames = local_filename, path = local_path,
    metadata = "a"
  ))
})
