
<!-- README.md is generated from README.Rmd. Please edit that file -->

# readabs

<!-- badges: start -->

[![Build
Status](https://travis-ci.org/MattCowgill/readabs.svg?branch=master)](https://travis-ci.org/MattCowgill/readabs)
[![lifecycle](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![Project Status: Active – The project has reached a stable, usable
state and is being actively
developed.](https://www.repostatus.org/badges/latest/active.svg)](https://www.repostatus.org/#active)
[![packageversion](https://img.shields.io/badge/Package%20version-0.3.0-orange.svg?style=flat-square)](commits/master)
[![CRAN
status](https://www.r-pkg.org/badges/version/readabs)](https://cran.r-project.org/package=readabs)
<!-- badges: end -->

## Overview

readabs contains tools to easily download, import, and tidy time series
data from the Australian Bureau of Statistics. This saves you time
manually downloading and tediously tidying time series data and allows
you to spend more time on your analysis.

**readabs is changing. The package has merged with
[getabs](https://github.com/mattcowgill/getabs) and readabs has gained
new functionality. Old readabs functions still work, but
read\_abs\_data() is soft-deprecated.**

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
devtools::install_github("mattcowgill/readabs", ref = "dev")
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
`read_abs()`. Here’s an example with the monthly Labour Force survey,
catalogue number 6202.0:

``` r
library(readabs)

all_lfs <- read_abs("6202.0")
#> Finding filenames for tables from ABS catalogue 6202.0
#> Attempting to download files from cat. no. 6202.0, Labour Force, Australia
#> Extracting data from downloaded spreadsheets
#> Tidying data from imported ABS spreadsheets

str(all_lfs)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    1594712 obs. of  12 variables:
#>  $ table_no        : chr  "6202001" "6202001" "6202001" "6202001" ...
#>  $ sheet_no        : chr  "Data1" "Data1" "Data1" "Data1" ...
#>  $ table_title     : chr  "Table 1. Labour force status by Sex, Australia - Trend, Seasonally adjusted and Original" "Table 1. Labour force status by Sex, Australia - Trend, Seasonally adjusted and Original" "Table 1. Labour force status by Sex, Australia - Trend, Seasonally adjusted and Original" "Table 1. Labour force status by Sex, Australia - Trend, Seasonally adjusted and Original" ...
#>  $ date            : Date, format: "1978-02-01" "1978-03-01" ...
#>  $ series          : chr  "Employed total ;  Persons ;" "Employed total ;  Persons ;" "Employed total ;  Persons ;" "Employed total ;  Persons ;" ...
#>  $ value           : num  6008 6015 6022 6027 6031 ...
#>  $ series_type     : chr  "Trend" "Trend" "Trend" "Trend" ...
#>  $ data_type       : chr  "STOCK" "STOCK" "STOCK" "STOCK" ...
#>  $ collection_month: chr  "1" "1" "1" "1" ...
#>  $ frequency       : chr  "Month" "Month" "Month" "Month" ...
#>  $ series_id       : chr  "A84423127L" "A84423127L" "A84423127L" "A84423127L" ...
#>  $ unit            : chr  "000" "000" "000" "000" ...
```

Maybe you only want a particular table? Here’s how you get a single
table:

``` r

lfs_t1 <- read_abs("6202.0", tables = 1)
#> Finding filenames for tables from ABS catalogue 6202.0
#> Attempting to download files from cat. no. 6202.0, Labour Force, Australia
#> Extracting data from downloaded spreadsheets
#> Tidying data from imported ABS spreadsheets
```

If you want multiple tables, but not the whole catalogue, that’s easy
too:

``` r

lfs_t1_t5 <- read_abs("6202.0", tables = c(1, 5))
#> Finding filenames for tables from ABS catalogue 6202.0
#> Attempting to download files from cat. no. 6202.0, Labour Force, Australia
#> Extracting data from downloaded spreadsheets
#> Tidying data from imported ABS spreadsheets
```

For more examples, including
