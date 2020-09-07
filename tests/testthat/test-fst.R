check_abs_site <- function() {
  if(is.null(curl::nslookup("abs.gov.au", error = FALSE))){
    skip("ABS Time Series Directory not available")
  }
}


test_that("read_abs works out of the box", {
  skip_on_cran()
  check_abs_site()
  out6401_init <- read_abs(cat_no = "6401.0")
  skip_if_not(file.exists(catno2fst("6401.0")))
  out6401_next <- read_abs(cat_no = "6401.0")

  # Bug in dplyr equal_data_frame()
  expect_equal(as.data.frame(out6401_init),
               as.data.frame(out6401_next))

  # "A2330751J"
  out6401_A2330751J <- read_abs(cat_no = "6401.0", series_id = "A2330751J")
  expect_equal(out6401_A2330751J, dplyr::filter(out6401_init, series_id == "A2330751J"))

  # warning handling --- must be after out6401_next
  expect_warning(read_abs(cat_no = "6401.0", series_id = "not a real series id"),
                 regexp = "but was not present in the local table and will be ignored",
                 fixed = TRUE)



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




