library(readabs)
library(RCurl)

context("Test that local file can be loaded and tidied")

local_path <- "../testdata"
local_filename <- "6202021.xls"

test_that("Local file can be read and is in expected form",{
  lfs_21 <- extract_abs_sheets(local_filename, path = local_path)
  lfs_21_df <- lfs_21[[1]]

  expect_is(lfs_21, "list")
  expect_is(lfs_21_df, "data.frame")
  expect_equal(as.character(lfs_21_df[1,1]), "Unit")
  expect_equal(as.character(lfs_21_df[10,1]), "31017")
})

test_that("Local file can be tidied and looks how we expect",{
  lfs_21 <- extract_abs_sheets(local_filename, path = local_path)
  lfs_21_tidy <- tidy_abs_list(lfs_21)

  expect_equal(length(colnames(lfs_21_tidy)), 12)
  expect_is(lfs_21_tidy$date, "Date")
  expect_is(lfs_21_tidy$value, "numeric")
  expect_equal(as.character(lfs_21_tidy[1,1]), "6202021")

})

context("Test xml scraping")

lfs_url <- "http://ausstats.abs.gov.au/servlet/TSSearchServlet?catno=6202.0&pg=1&ttitle=1"

check_abs_site <- function() {
  if(!url.exists("http://ausstats.abs.gov.au")){
    skip("ABS Time Series Directory not available")
  }
}

test_that("Labour force XML page is a data.frame with expected column names",
          {
        check_abs_site()

        lfs_1 <- get_xml_df(lfs_url)

        expect_is(lfs_1, "data.frame")
        expect_equal(colnames(lfs_1)[1], "ProductNumber")
          })

