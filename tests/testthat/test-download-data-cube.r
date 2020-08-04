#
# test_that("File is downloaded",{
#   #Download May 2020 EQ09
#
#   temp_path <- tempdir()
#
#   download_abs_data_cube(cat_no = "6291.0.55.003",
#                          cube = "EQ09", date = "May 2020",
#                          path = temp_path)
#
#
#   expect_equal(file.exists(file.path(temp_path, "eq09.zip")), TRUE)
# })
#
#
# test_that("File can be unzipped",{
#
#   temp_path <- tempdir()
#
#   download_abs_data_cube(cat_no = "6291.0.55.003",
#                          cube = "EQ09", date = "May 2020",
#                          path = temp_path)
#
#   unzip(zipfile  = file.path(temp_path, "eq09.zip"), files = "EQ09.xlsx", exdir = temp_path)
#   expect_equal(file.exists(file.path(temp_path, "eq09.xlsx")), TRUE)
# })
#
#
# test_that("File contents are as expected",{
#
#   temp_path <- tempdir()
#
#   download_abs_data_cube(cat_no = "6291.0.55.003",
#                          cube = "EQ09", date = "May 2020",
#                          path = temp_path)
#
#   unzip(zipfile  = file.path(temp_path, "eq09.zip"), files = "EQ09.xlsx", exdir = temp_path)
#
#   eq09 <- readxl::read_excel(file.path(temp_path, "EQ09.xlsx"), range = "A3",
#                      col_names = FALSE) %>%
#     dplyr::pull()
#   expect_equal(eq09, "Released at 11.30 am (Canberra time) 25 June 2020")
# })
#
#
# #Delete downloaded and unzippedfile
# file.remove(file.path(temp_path, "eq09.xlsx"))
# file.remove(file.path(temp_path, "eq09.zip"))
#
