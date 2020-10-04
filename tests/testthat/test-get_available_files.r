test_that("get_available_files() works", {
  skip_if_offline()
  skip_on_cran()
  check_abs_connection()

  cats <- show_available_catalogues()

  safely_get_available_files <- purrr::safely(get_available_files)

  results <- map(cats, safely_get_available_files)

  results <- setNames(results, cats)

  results <- purrr::transpose(results)

  errors <- purrr::compact(results$error)

  error_names <- names(errors)

  expect_equal(length(error_names), 0)

})
