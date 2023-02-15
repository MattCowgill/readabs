test_that("download_abs() fetches files", {
  skip_on_cran()
  skip_if_offline()
  check_abs_connection()

  xml_urls <- form_abs_tsd_url(
    cat_no = "6202.0",
    tables = c("11", "11a"),
    series_id = NULL
  )

  xml_dfs <- purrr::map_dfr(xml_urls,
    .f = get_abs_xml_metadata
  )

  urls <- unique(xml_dfs$TableURL)

  table_titles <- unique(xml_dfs$TableTitle)

  .path <- tempdir()

  # A single file ---
  download_abs(urls[1], .path, FALSE)

  expect_true(file.exists(file.path(.path, basename(urls[1]))))

  unlink(file.path(.path, basename(urls[1])))

  # Multiple files using purrr::walk()
  purrr::walk(urls,
    download_abs,
    path = .path,
    show_progress_bars = F
  )

  expect_true(all(file.exists(file.path(.path, basename(urls)))))

  unlink(.path)

  # Vectorised download.file ----
  download_abs(urls, .path)

  expect_true(all(file.exists(file.path(.path, basename(urls)))))

  unlink(.path)
})
