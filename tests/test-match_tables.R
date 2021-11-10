test_match_tables <- function(cat_no, tables) {
  url <- form_abs_tsd_url(cat_no, tables)
  xml_df <- purrr::map_dfr(url, get_abs_xml_metadata)
  matching <- match_tables(xml_df$TableTitle, tables)
  unique(xml_df$TableTitle[matching])
}

testthat::test_that("match_tables() returns only requested tables", {
  t1 <- test_match_tables("5368.0", "1")
  expect_length(t1, 1)
  expect_true(grepl("TABLE 1.", t1))

  t2 <- test_match_tables("5368.0", c("1", "2"))
  expect_length(t2, 2)
  expect_true(all(
    grepl("TABLE 1.|TABLE 2.", t2)
  ))

  t3 <- test_match_tables("5368.0", c("1", "12a"))

})
