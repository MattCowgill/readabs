test_that("show_available_catalogues() returns expected vector", {

  cats <- show_available_catalogues()

  expect_type(cats, "character")
  expect_gt(length(cats), 200)
  expect_equal(sort(cats), sort(abs_lookup_table$catalogue))

  filtered_cats <- show_available_catalogues(selected_heading = "Price indexes and inflation")

  expect_type(filtered_cats, "character")
  expect_gt(length(filtered_cats), 5)

})

test_that("show_available_catalogues(refresh = TRUE) returns tibble", {

  skip_on_cran()
  skip_if_offline()
  check_abs_connection()

  cats <- show_available_catalogues(refresh = TRUE)

  expect_type(cats, "character")
  expect_gt(length(cats), 200)
  expect_equal(sort(cats),
               sort(abs_lookup_table$catalogue))
})
