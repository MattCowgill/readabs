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

test_that("Local file can be read",{
  lfs_21 <- read_abs_local(local_filename, path = local_path)

  expect_equal(length(colnames(lfs_21)), 12)
  expect_is(lfs_21$date, "Date")
  expect_is(lfs_21$value, "numeric")
  expect_equal(as.character(lfs_21[1,1]), "6202021")
})

context("Test xml scraping")

wpi_url <- "http://ausstats.abs.gov.au/servlet/TSSearchServlet?catno=6345.0&pg=1&ttitle=1"

check_abs_site <- function() {
  if(!RCurl::url.exists("http://ausstats.abs.gov.au")){
    skip("ABS Time Series Directory not available")
  }
}

test_that("WPI XML page is a data.frame with expected column names",
          {
        skip_on_cran()

        check_abs_site()

        wpi_1_xml <- get_xml_df(wpi_url)

        expect_is(wpi_1_xml, "data.frame")
        expect_equal(colnames(wpi_1_xml)[1], "ProductNumber")
          })

test_that("read_abs() downloads, imports, and tidies a data frame",
          {
            skip_on_cran()

            check_abs_site()

            wpi_1 <- read_abs("6345.0", tables = 1)

            expect_is(wpi_1, "data.frame")

            expect_equal(length(colnames(wpi_1)), 12)

            expect_gt(nrow(wpi_1), 1)
          })


test_that("Old read_abs_sdmx function works",{

          skip_on_cran()

          sdmx_url <- url <- "http://stat.data.abs.gov.au/restsdmx/sdmx.ashx/GetData/ABS_REGIONAL_ASGS/PENSION_2+BANKRUPT_2.AUS.0.A/all?startTime=2013&endTime=2013"

          sdmx_result <- read_abs_sdmx(sdmx_url)

          expect_true(is.data.frame(sdmx_result))

})
