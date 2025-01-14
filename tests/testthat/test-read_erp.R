test_that("read_erp() works", {
  x <- read_erp()

  expect_is(x, "tbl_df")
  expect_length(x, 5)
  expect_gt(nrow(x), 40000)
  expect_is(x$date, "Date")
  expect_is(x$state, "character")
  expect_is(x$sex, "character")
  expect_is(x$erp, "numeric")
  expect_is(x$age, "integer")
  expect_equal(length(unique(x$state)), 9)
  expect_equal(unique(x$sex), "Persons")
  expect_equal(unique(x$age), 0:100)
})

test_that("tidy_erp() works with all permutations of parameters", {
  raw_erp <- read_abs("3101.0")

  test_tidy_erp <- function(age_range,
                            sex,
                            erp_raw = raw_erp) {
    x <- tidy_erp(erp_raw,
                  age_range,
                  sex)

    expect_is(x, "tbl_df")
    expect_length(x, 5)
    expect_equal(sort(unique(x$age)), sort(age_range))
    expect_equal(sort(unique(x$sex)), sort(sex))
  }

  test_tidy_erp(1:10, "Male")
  test_tidy_erp(15, "Female")
  test_tidy_erp(c(10, 50, 90), "Persons")
  test_tidy_erp(0:100,
                c("Male", "Female", "Persons"))
  test_tidy_erp(1,
                c("Female", "Male"))

})
