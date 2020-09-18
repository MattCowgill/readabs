
check_abs_site <- function() {
  if(is.null(curl::nslookup("abs.gov.au", error = FALSE))){
    skip("ABS Time Series Directory not available")
  }
}

# Set parameters ---
cat_no = "6202.0"
tables = c("11", "11a")
series_id = NULL
.path = tempdir()
metadata = TRUE
show_progress_bars = FALSE
retain_files = FALSE
check_local = FALSE


# Form time series URLS ----
xml_urls <- form_abs_tsd_url(cat_no = cat_no,
                             tables = tables,
                             series_id = series_id)

test_that("xml urls are well formed",{
  check_abs_site()
  skip_on_cran()

  expect_length(xml_urls, 2)
  expect_type(xml_urls, "character")

  skip_on_cran()

  url_results <- RCurl::url.exists(xml_urls)

  expect_true(all(url_results))
})

# Get XML metadata -----

xml_dfs <- purrr::map_dfr(xml_urls,
                          .f = get_abs_xml_metadata,
                          issue = "latest")

test_that("get_abs_xml_metadata() gets XML", {
  check_abs_site()
  skip_on_cran()

  expect_s3_class(xml_dfs, "data.frame")
})

# Download files ----

urls <- unique(xml_dfs$TableURL)

table_titles <- unique(xml_dfs$TableTitle)

purrr::walk(urls, download_abs, path = .path,
            show_progress_bars = show_progress_bars)


test_that("files downloaded", {
  check_abs_site()
  skip_on_cran()

  expect_true(all(file.exists(file.path(.path, basename(urls)))))
})

# Extract data sheets from files -----
sheets <- purrr::map2(basename(urls), table_titles,
                      .f = extract_abs_sheets, path = .path)

test_that("extracted sheets look correct", {
  check_abs_site()
  skip_on_cran()

  expect_length(sheets, 2)
  expect_type(sheets, "list")
  expect_s3_class(sheets[[1]][[1]], "data.frame")
})

# Tidy data sheets ----
sheets <- unlist(sheets, recursive = FALSE)

# tidy the sheets
sheet <- tidy_abs_list(sheets, metadata = metadata)

test_that("tidied data sheets look correct", {
  check_abs_site()
  skip_on_cran()
  expect_length(sheet, 12)
  expect_gt(nrow(sheet), 42923)
  expect_s3_class(sheet, "tbl_df")
})

