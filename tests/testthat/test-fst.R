check_abs_site <- function() {
  if (is.null(curl::nslookup("abs.gov.au", error = FALSE))) {
    skip("ABS Time Series Directory not available")
  }
}


test_that("read_abs works out of the box", {
  skip_on_cran()
  check_abs_site()
  out6345_init <- read_abs(cat_no = "6345.0")
  skip_if_not(file.exists(catno2fst("6345.0")))
  out6345_next <- read_abs(cat_no = "6345.0")


  expect_equal(out6345_init, out6345_next)

  out6345_A2599619A <- read_abs(cat_no = "6345.0", series_id = "A2599619A")
  expect_equal(out6345_A2599619A, dplyr::filter(out6345_init, series_id == "A2599619A"))

  # warning handling --- must be after out6401_next
  expect_warning(read_abs(cat_no = "6345.0", series_id = "not a real series id"),
                 regexp = "but was not present in the local table and will be ignored",
                 fixed = TRUE)

  expect_warning(read_abs(cat_no = "6345.0", tables = "not all"),
                 regexp = "tables.*will be ignored")



})

test_that("fst-utils", {
  expect_false(fst_available(cat_no = NULL))
  expect_false(fst_available(cat_no = character(2)))
  expect_false(fst_available(cat_no = NA_character_))
  expect_false(fst_available(cat_no = ""))
  tempf.fst <- tempfile(fileext = ".fst")
  writeLines("9999-9", tempf.fst)
  expect_false(fst_available("9999.9", path = dirname(tempf.fst)))
  expect_equal(ext2ext("file.csv", ".txt"), "file.txt")
})




