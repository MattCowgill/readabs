test_match_tables <- function(cat_no, tables) {
  url <- form_abs_tsd_url(cat_no, tables)
  xml_df <- purrr::map_dfr(url, get_abs_xml_metadata)
  matching <- match_tables(xml_df$TableTitle, tables)
  unique(xml_df$TableTitle[matching])
}

test_that("match_tables() returns only requested tables", {

  t1 <- test_match_tables("5368.0", "1")
  expect_length(t1, 1)
  expect_true(grepl("TABLE 1.", t1))

  t2 <- test_match_tables("5368.0", c("1", "2"))
  expect_length(t2, 2)
  expect_true(all(
    grepl("TABLE 1.|TABLE 2.", t2)
  ))

  t3 <- test_match_tables("5368.0", c("1", "12a"))
  expect_length(t3, 2)

  t4 <- test_match_tables("6401.0", "1")
  expect_length(t4, 1)

  t5 <- test_match_tables("6401.0", "2")
  expect_length(t5, 1)
  expect_identical(t5, t4) # Tables 1 and 2 are combined in 6401.0

  t6 <- test_match_tables("6291.0.55.001", c("1", "24b"))
  expect_length(t6, 2)

  t7 <- test_match_tables("6202.0",
                          c("1", "4", "10a", "11", "11a", "12", "12a", "21"))
  expect_length(t7, 8)
})
