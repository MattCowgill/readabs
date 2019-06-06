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

test_that("Local file can be tidied without metadata",{

  no_meta <- read_abs_local(filenames = local_filename, path = local_path, metadata = FALSE)
  expect_is(no_meta, "data.frame")


})



test_that("tidy_abs_list() gives appropriate errors",{
  expect_error(tidy_abs_list(data.frame(x = 1)))

  expect_error(tidy_abs_list(c(1, 2)))

})

test_that("tidy_abs() gives appropriate errors",{
  expect_error(tidy_abs(df = c(1, 2)))

  expect_error(tidy_abs(data.frame(x = 1)))

  expect_error(tidy_abs(df = data.frame(x = 1, y = 2), metadata = 1))

  expect_error(tidy_abs(df = data.frame(x = c(1:10), y = c(1:10))))

})

test_that("Local file can be read",{
  lfs_21 <- read_abs_local(filenames = local_filename, path = local_path)

  expect_equal(length(colnames(lfs_21)), 12)
  expect_is(lfs_21$date, "Date")
  expect_is(lfs_21$value, "numeric")
  expect_equal(as.character(lfs_21[1,1]), "6202021")
})


test_that("read_abs_local() returns appropriate errors and messages",{
  expect_error(read_abs_local(filenames = NULL, path = NULL))

  expect_error(read_abs_local(filenames = 1), path = "../testdata")

  expect_error(read_abs_local(path = "../empty"))

  expect_error(read_abs_local(filenames = local_filename, path = local_path,
                              metadata = "a"))

})

context("Test xml scraping")

wpi_url <- "http://ausstats.abs.gov.au/servlet/TSSearchServlet?catno=6345.0&pg=1&ttitle=1"

check_abs_site <- function() {
  if(is.null(curl::nslookup("abs.gov.au", error = FALSE))){
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

            wpi_1 <- read_abs("6345.0", tables = "7a")

            expect_is(wpi_1, "data.frame")

            expect_equal(length(colnames(wpi_1)), 12)

            expect_gt(nrow(wpi_1), 1)
          })

test_that("read_abs() gets a whole catalogue number",
          {
            skip_on_cran()

            check_abs_site()

            wpi_all <- read_abs("6345.0")

            expect_is(wpi_all, "data.frame")

            expect_equal(length(wpi_all), 12)

            expect_gt(nrow(wpi_all), 55000)
          })

test_that("read_abs() works when retain_files = FALSE",
          {
            skip_on_cran()

            check_abs_site()

            wpi_7 <- read_abs("6345.0", tables = "7a", retain_files = FALSE)

            expect_is(wpi_7, "data.frame")

          })

test_that("read_abs() works with series ID(s)", {

  skip_on_cran()

  check_abs_site()

  cpi_1 <- read_abs(series_id = "A2325846C")

  cpi_2 <- read_abs(series_id = c("A2325846C", "A2325841T"))

  expect_is(cpi_1, "data.frame")

  expect_is(cpi_2, "data.frame")

  expect_length(cpi_1, 12)

  expect_length(cpi_2, 12)

})

test_that("deprecated get_abs() function gives a warning message",
          {
            expect_warning(get_abs())

          })


test_that("Old read_abs_sdmx function works",{

          skip_on_cran()

          check_abs_site()

          sdmx_url <- url <- "http://stat.data.abs.gov.au/restsdmx/sdmx.ashx/GetData/ABS_REGIONAL_ASGS/PENSION_2+BANKRUPT_2.AUS.0.A/all?startTime=2013&endTime=2013"

          sdmx_result <- read_abs_sdmx(sdmx_url)

          expect_true(is.data.frame(sdmx_result))

})


test_that("read_abs() returns appropriate errors and messages when given invalid input",{

  expect_error(read_abs(cat_no = NULL))

  expect_error(read_abs("6202.0", 1, retain_files = NULL))

  expect_message(read_abs("6345", 1))

  expect_message(read_abs("6345.0"))

  expect_error(read_abs(cat_no = "6345.0", metadata = 1))

  skip_on_cran()
  check_abs_site()
  expect_message(read_abs("6345.0", "7a"))

})

test_that("read_abs() works with 'table 01' as well as 'table 1' filename structures",{

  skip_on_cran()

  check_abs_site()

  const_df <- read_abs("8755.0", 1)

  expect_is(const_df, "data.frame")

  expect_equal(length(colnames(const_df)), 12)

})

test_that("read_abs() returns an error when requesting non-existing cat_no",{

  skip_on_cran()

  check_abs_site()

  expect_error(read_abs("9999.0"))

})


test_that("Old read_abs_data() function imports a spreadsheet",{

  filepath <- paste0(local_path, "/", local_filename)

  expect_message(read_abs_data(filepath, "Data1"))

  local_file <- read_abs_data(filepath, "Data1")

  expect_is(local_file, "data.frame")

  expect_equal(length(colnames(local_file)), 3)

})

test_that("Old read_abs_metadata() function imports a spreadsheet",{

  filepath <- paste0(local_path, "/", local_filename)

  expect_message(read_abs_metadata(filepath, "Data1"))

  local_file <- read_abs_metadata(filepath, "Data1")

  expect_is(local_file, "data.frame")

  expect_equal(length(colnames(local_file)), 9)

})


test_that("read_cpi() function downloads CPI index numbers",{
  skip_on_cran()

  check_abs_site()

  cpi <- read_cpi()

  expect_is(cpi, "data.frame")

  expect_equal(length(cpi), 2)

  expect_is(cpi$date, "Date")

  expect_is(cpi$cpi, "numeric")

})

test_that("read_cpi() returns appropriate errors",{

  expect_error(read_cpi(retain_files = NULL))

  expect_error(read_cpi(show_progress_bars = NULL))

  expect_error(read_cpi(retain_files = TRUE, path = 1))

})

test_that("separate_series() performs as expected",{

 motor_vehicles <- read_abs("9314.0") %>% separate_series()

 expect_equal(14, length(motor_vehicles))

 expect_equal(9, length(unique(motor_vehicles$series_1)))

})

