test_that("tidy_awe() returns tidied data frame", {
  # test_awe_file <- file.path("tests", "testdata", "6302002.xls")
  #
  # awe_url <- utils::URLencode("https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&6302002.xls&6302.0&Time%20Series%20Spreadsheet&5379E96E39273CF5CA25761000199DDA&0&May%202009&13.08.2009&Latest")
  #
  # download.file(url = awe_url,
  #               destfile = test_awe_file)

  awe <- readxl::read_excel(file.path("..", "testdata", "6302002.xls"),
                            sheet = "Data1")

  awe <- tidy_abs(awe)

  tidied_awe <- tidy_awe(awe)

  expect_is(tidied_awe, "data.frame")
  expect_equal(nrow(tidied_awe), 927)
  expect_true(all(
    c("date", "sex", "wage_measure", "value") %in% names(tidied_awe)
                   ))
  expect_false(any(is.na(tidied_awe$value)))
})

test_that("read_awe() returns expected output", {
  skip_if_offline()
  skip_on_cran()

  no_params <- read_awe()

  expect_is(no_params, "tbl_df")
  expect_identical(unique(no_params$sex), "persons")
  expect_identical(unique(no_params$wage_measure), "awote")
  expect_identical(min(no_params$date), as.Date("1983-11-15"))
  expect_gt(max(no_params$date), as.Date("2020-05-14"))
  expect_is(no_params$value, "numeric")
  expect_gt(max(no_params$value, na.rm = T) /
              min(no_params$value, na.rm = T),
            4.5)

  params_df <- expand.grid(sex = c("persons", "males", "females"),
              wage_measure = c("awote", "ftawe", "awe"),
              sector = c("total", "private", "public"),
              state = c("all",
                        "nsw",
                        "vic",
                        "qld",
                        "sa",
                        "wa",
                        "tas",
                        "nt",
                        "act"),
              stringsAsFactors = FALSE)

  params_df <- params_df %>%
    dplyr::filter(sector == "total" | state == "all")


  for (i in seq_len(nrow(params_df))) {

    awe_data <- read_awe(wage_measure = params_df$wage_measure[i],
             sex = params_df$sex[i],
             sector = params_df$sector[i],
             state = params_df$state[i])

    expect_is(awe_data, "tbl_df")

    expect_gt(length(awe_data), 3)

    if (params_df$sector[i] != "total") {
      expect_length(unique(awe_data$sector), 1)
      expect_true(unique(awe_data$sector) != "total")
      expect_true(unique(awe_data$sector) == params_df$sector[i])
      expect_length(awe_data, 5)
      expect_true("sector" %in% names(awe_data))
    }

    if (params_df$state[i] != "all") {
      expect_length(unique(awe_data$state), 1)
      expect_true(unique(awe_data$state) != "all")
      expect_true(unique(awe_data$state) == params_df$state[i])
      expect_length(awe_data, 5)
      expect_true("state" %in% names(awe_data))
    }

  }



  expect_gt(nrow(read_awe()), nrow(read_awe(na.rm = TRUE)))
})
