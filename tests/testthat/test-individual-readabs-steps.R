
test_that("individual steps of read_abs() work", {
  skip_on_cran()
  skip_if_offline()
  check_abs_connection()

  # Set parameters ---
  cat_no <- "6202.0"
  tables <- c("11", "11a")
  series_id <- NULL
  .path <- tempdir()
  metadata <- TRUE
  show_progress_bars <- FALSE
  retain_files <- FALSE
  check_local <- FALSE


  # Form time series URLS ----
  xml_urls <- form_abs_tsd_url(
    cat_no = cat_no,
    tables = tables,
    series_id = series_id
  )

  expect_length(xml_urls, 2)
  expect_type(xml_urls, "character")

  temp_xml_1 <- tempfile(fileext = ".xml")
  temp_xml_2 <- tempfile(fileext = ".xml")

  purrr::walk2(
    .x = xml_urls,
    .y = c(
      temp_xml_1,
      temp_xml_2
    ),
    .f = utils::download.file,
    headers = readabs_header
  )

  expect_true(file.exists(temp_xml_1))
  expect_true(file.exists(temp_xml_2))

  xml_1 <- xml2::read_xml(temp_xml_1)

  expect_s3_class(xml_1, "xml_document")

  product_title <- xml_1 %>%
    xml2::as_list() %>%
    .$TimeSeriesIndex %>%
    .$Series %>%
    .$ProductTitle %>%
    as.character()

  expect_identical(
    product_title,
    "Labour Force, Australia"
  )

  unlink(temp_xml_1)
  unlink(temp_xml_2)

  # Get XML metadata -----

  xml_dfs <- purrr::map_dfr(xml_urls,
    .f = get_abs_xml_metadata
  )

  expect_s3_class(xml_dfs, "data.frame")

  # Download files ----

  urls <- unique(xml_dfs$TableURL)

  table_titles <- unique(xml_dfs$TableTitle)

  purrr::walk(urls, download_abs,
    path = .path,
    show_progress_bars = show_progress_bars
  )


  expect_true(all(file.exists(file.path(.path, basename(urls)))))


  # Extract data sheets from files -----
  sheets <- purrr::map2(basename(urls),
    table_titles,
    .f = extract_abs_sheets,
    path = .path
  )

  expect_length(sheets, 2)
  expect_type(sheets, "list")
  expect_s3_class(sheets[[1]][[1]], "data.frame")

  # Tidy data sheets ----
  sheets <- unlist(sheets, recursive = FALSE)

  # tidy the sheets
  sheet <- tidy_abs_list(sheets, metadata = metadata)

  expect_length(sheet, 12)
  expect_gt(nrow(sheet), 42923)
  expect_s3_class(sheet, "tbl_df")
})
