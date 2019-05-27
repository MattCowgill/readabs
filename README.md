
<!-- README.md is generated from README.Rmd. Please edit that file -->

# readabs

<!-- badges: start -->

[![Build
Status](https://travis-ci.org/MattCowgill/readabs.svg?branch=master)](https://travis-ci.org/MattCowgill/readabs)
[![codecov
status](https://img.shields.io/codecov/c/github/mattcowgill/readabs.svg)](https://codecov.io/gh/MattCowgill/readabs)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![CRAN
status](https://www.r-pkg.org/badges/version/readabs)](https://cran.r-project.org/package=readabs)
<!-- badges: end -->

## Overview

readabs contains tools to easily download, import, and tidy time series
data from the Australian Bureau of Statistics. This saves you time
manually downloading and tediously tidying time series data and allows
you to spend more time on your analysis.

We’d welcome Github issues containing error reports or feature requests.
Alternatively you can email the package maintainer at mattcowgill at
gmail dot com.

## Installation

Install the latest CRAN version of **readabs** with:

``` r
install.packages("readabs")
```

You can install the developer version of **readabs** from GitHub with:

``` r
# if you don't have devtools installed, first run:
# install.packages("devtools")
devtools::install_github("mattcowgill/readabs")
```

## Usage

There are two key functions in **readabs**. They are:

  - `read_abs()` downloads, imports, and tidies time series data from
    the ABS website.
  - `read_abs_local()` imports and tidies time series data from ABS
    spreadsheets stored on a local drive.

Both functions return a single tidy data frame (tibble) containing long
data.

## Examples

To download all the time series data from an ABS catalogue number to
your disk, and import the data to R as a single tidy data frame, use
`read_abs()`. Here’s an example with the Wage Price Index, catalogue
number 6345.0:

``` r
library(readabs)

all_wpi <- read_abs("6345.0")
#> Finding filenames for tables corresponding to ABS catalogue 6345.0
#> Attempting to download files from catalogue 6345.0, Wage Price Index, Australia
#> Extracting data from downloaded spreadsheets
#> Tidying data from imported ABS spreadsheets

str(all_wpi)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    55347 obs. of  12 variables:
#>  $ table_no        : chr  "634501" "634501" "634501" "634501" ...
#>  $ sheet_no        : chr  "Data1" "Data1" "Data1" "Data1" ...
#>  $ table_title     : chr  "Table 1. Total Hourly Rates of Pay Excluding Bonuses: Sector, Original, Seasonally Adjusted and Trend" "Table 1. Total Hourly Rates of Pay Excluding Bonuses: Sector, Original, Seasonally Adjusted and Trend" "Table 1. Total Hourly Rates of Pay Excluding Bonuses: Sector, Original, Seasonally Adjusted and Trend" "Table 1. Total Hourly Rates of Pay Excluding Bonuses: Sector, Original, Seasonally Adjusted and Trend" ...
#>  $ date            : Date, format: "1997-09-01" "1997-12-01" ...
#>  $ series          : chr  "Quarterly Index ;  Total hourly rates of pay excluding bonuses ;  Australia ;  Private ;  All industries ;" "Quarterly Index ;  Total hourly rates of pay excluding bonuses ;  Australia ;  Private ;  All industries ;" "Quarterly Index ;  Total hourly rates of pay excluding bonuses ;  Australia ;  Private ;  All industries ;" "Quarterly Index ;  Total hourly rates of pay excluding bonuses ;  Australia ;  Private ;  All industries ;" ...
#>  $ value           : num  67.4 67.9 68.5 68.8 69.6 70 70.4 70.8 71.5 71.9 ...
#>  $ series_type     : chr  "Original" "Original" "Original" "Original" ...
#>  $ data_type       : chr  "INDEX" "INDEX" "INDEX" "INDEX" ...
#>  $ collection_month: chr  "3" "3" "3" "3" ...
#>  $ frequency       : chr  "Quarter" "Quarter" "Quarter" "Quarter" ...
#>  $ series_id       : chr  "A2603039T" "A2603039T" "A2603039T" "A2603039T" ...
#>  $ unit            : chr  "Index Numbers" "Index Numbers" "Index Numbers" "Index Numbers" ...
```

Maybe you only want a particular table? Here’s how you get a single
table:

``` r

wpi_t1 <- read_abs("6345.0", tables = 1)
#> Finding filenames for tables corresponding to ABS catalogue 6345.0
#> Attempting to download files from catalogue 6345.0, Wage Price Index, Australia
#> Extracting data from downloaded spreadsheets
#> Tidying data from imported ABS spreadsheets
```

If you want multiple tables, but not the whole catalogue, that’s easy
too:

``` r

wpi_t1_t5 <- read_abs("6345.0", tables = c("1", "5a"))
#> Finding filenames for tables corresponding to ABS catalogue 6345.0
#> Attempting to download files from catalogue 6345.0, Wage Price Index, Australia
#> Extracting data from downloaded spreadsheets
#> Tidying data from imported ABS spreadsheets
```

For more examples, see the readabs vignette (run
`browseVignettes("readabs")`.

## Mentioned in Awesome Official Statistics Software

[![Mentioned in Awesome Official
Statistics](https://awesome.re/mentioned-badge.svg)](http://www.awesomeofficialstatistics.org)

We’re pleased to be included in a [list of
software](https://github.com/SNStatComp/awesome-official-statistics-software)
that can be used to work with official statistics.

## Package history

From version 0.3.0, `readabs` gained new functionality. Pre-0.3.0
functions still work, but `read_abs_data()` is soft-deprecated and the
behaviour of `read_abs_metadata()` has changed. The old version of
`readsabs` is available in the [0.2.9 branch on
Github](https://github.com/MattCowgill/readabs/tree/0.2.9).
