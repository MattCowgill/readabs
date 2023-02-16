
<!-- README.md is generated from README.Rmd. Please edit that file -->

# readabs <img src="man/figures/logo.png" align="right" height="139" />

<!-- badges: start -->

[![R build
status](https://github.com/mattcowgill/readabs/workflows/R-CMD-check/badge.svg)](https://github.com/mattcowgill/readabs/actions)
[![codecov
status](https://img.shields.io/codecov/c/github/mattcowgill/readabs.svg)](https://app.codecov.io/gh/MattCowgill/readabs)
[![CRAN
status](https://www.r-pkg.org/badges/version/readabs)](https://cran.r-project.org/package=readabs)
[![Lifecycle:
stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html)
<!-- badges: end -->

## Overview

{readabs} helps you easily download, import, and tidy data from the
Australian Bureau of Statistics within R. This saves you time manually
downloading and tediously tidying data and allows you to spend more time
on your analysis.

## Installing {readabs}

Install the latest CRAN version of {readabs} with:

``` r
install.packages("readabs")
```

You can install the development version of {readabs} from GitHub with:

``` r
# if you don't have devtools installed, first run:
# install.packages("devtools")
devtools::install_github("mattcowgill/readabs")
```

## Using {readabs}

The ABS releases data in many different formats, through many different
dissemination channels.

The {readabs} contains functions for working with three different types
of ABS data:

- `read_abs()` and related functions downloads, imports, and tidies ABS
  time series data.
- `download_abs_data_cube()` and related functions find and download ABS
  data cubes, which are spreadsheets on the ABS website that are not in
  the standard time series format.
- `read_api()` and related functions find, filter, and import data from
  the [ABS.Stat](https://explore.data.abs.gov.au) API.

### ABS time series data

A key function in {readabs} is `read_abs()`, which downloads, imports,
and tidies time series data from the ABS website. **Note that
`read_abs()` only works with spreadsheets in the standard ABS time
series format.**

First we’ll load {readabs} and the {tidyverse}:

``` r
library(readabs)
#> Environment variable 'R_READABS_PATH' is unset. Downloaded files will be saved in a temporary directory.
#> You can set 'R_READABS_PATH' at any time. To set it for the rest of this session, use
#>  Sys.setenv(R_READABS_PATH = <path>)
library(tidyverse)
#> ── Attaching core tidyverse packages ─────────────────── tidyverse 1.3.2.9000 ──
#> ✔ dplyr     1.1.0          ✔ readr     2.1.3     
#> ✔ forcats   1.0.0          ✔ stringr   1.5.0     
#> ✔ ggplot2   3.4.0.9000     ✔ tibble    3.1.8     
#> ✔ lubridate 1.9.1          ✔ tidyr     1.3.0     
#> ✔ purrr     1.0.1
#> ── Conflicts ────────────────────────────────────────── tidyverse_conflicts() ──
#> ✖ dplyr::filter() masks stats::filter()
#> ✖ dplyr::lag()    masks stats::lag()
#> ℹ Use the ]8;;http://conflicted.r-lib.org/conflicted package]8;; to force all conflicts to become errors
```

Now we’ll create one data frame that contains all the time series data
from the Wage Price Index, catalogue number 6345.0:

``` r
all_wpi <- read_abs("6345.0")
#> Finding URLs for tables corresponding to ABS catalogue 6345.0
#> Attempting to download files from catalogue 6345.0, Wage Price Index, Australia
#> Extracting data from downloaded spreadsheets
#> Tidying data from imported ABS spreadsheets
```

This is what it looks like:

``` r
str(all_wpi)
#> tibble [64,493 × 12] (S3: tbl_df/tbl/data.frame)
#>  $ table_no        : chr [1:64493] "634501" "634501" "634501" "634501" ...
#>  $ sheet_no        : chr [1:64493] "Data1" "Data1" "Data1" "Data1" ...
#>  $ table_title     : chr [1:64493] "Table 1. Total Hourly Rates of Pay Excluding Bonuses: Sector, Original, Seasonally Adjusted and Trend" "Table 1. Total Hourly Rates of Pay Excluding Bonuses: Sector, Original, Seasonally Adjusted and Trend" "Table 1. Total Hourly Rates of Pay Excluding Bonuses: Sector, Original, Seasonally Adjusted and Trend" "Table 1. Total Hourly Rates of Pay Excluding Bonuses: Sector, Original, Seasonally Adjusted and Trend" ...
#>  $ date            : Date[1:64493], format: "1997-09-01" "1997-09-01" ...
#>  $ series          : chr [1:64493] "Quarterly Index ;  Total hourly rates of pay excluding bonuses ;  Australia ;  Private ;  All industries ;" "Quarterly Index ;  Total hourly rates of pay excluding bonuses ;  Australia ;  Public ;  All industries ;" "Quarterly Index ;  Total hourly rates of pay excluding bonuses ;  Australia ;  Private and Public ;  All industries ;" "Quarterly Index ;  Total hourly rates of pay excluding bonuses ;  Australia ;  Private ;  All industries ;" ...
#>  $ value           : num [1:64493] 67.4 64.7 66.7 67.3 64.8 66.6 67.3 64.8 66.7 NA ...
#>  $ series_type     : chr [1:64493] "Original" "Original" "Original" "Seasonally Adjusted" ...
#>  $ data_type       : chr [1:64493] "INDEX" "INDEX" "INDEX" "INDEX" ...
#>  $ collection_month: chr [1:64493] "3" "3" "3" "3" ...
#>  $ frequency       : chr [1:64493] "Quarter" "Quarter" "Quarter" "Quarter" ...
#>  $ series_id       : chr [1:64493] "A2603039T" "A2603989W" "A2603609J" "A2713846W" ...
#>  $ unit            : chr [1:64493] "Index Numbers" "Index Numbers" "Index Numbers" "Index Numbers" ...
```

It only takes you a few lines of code to make a graph from your data:

``` r
all_wpi %>%
  filter(
    series == "Percentage Change From Corresponding Quarter of Previous Year ;  Australia ;  Total hourly rates of pay excluding bonuses ;  Private and Public ;  All industries ;",
    !is.na(value)
  ) %>%
  ggplot(aes(x = date, y = value, col = series_type)) +
  geom_line() +
  theme_minimal() +
  labs(y = "Annual wage growth (per cent)")
```

<img src="man/figures/README-all-in-one-example-1.png" width="672" />

In the example above we downloaded all the time series from a catalogue
number. This will often be overkill. If you know the data you need is in
a particular table, you can just get that table like this:

``` r
wpi_t1 <- read_abs("6345.0", tables = 1)
#> Warning in read_abs("6345.0", tables = 1): `tables` was providedyet
#> `check_local = TRUE` and fst files are available so `tables` will be ignored.
```

If you want multiple tables, but not the whole catalogue, that’s easy
too:

``` r
wpi_t1_t5 <- read_abs("6345.0", tables = c("1", "5a"))
#> Warning in read_abs("6345.0", tables = c("1", "5a")): `tables` was providedyet
#> `check_local = TRUE` and fst files are available so `tables` will be ignored.
```

For more examples, please see the vignette on working with time series
data (run `browseVignettes("readabs")`).

Some other functions that may come in handy when working with ABS time
series data:

- `read_abs_local()` imports and tidies time series data from ABS
  spreadsheets stored on a local drive. Thanks to Hugh Parsonage for
  contributing to this functionality.
- `separate_series()` splits the `series` column of a tidied ABS time
  series spreadsheet into multiple columns, reducing the manual
  wrangling that’s needed to work with the data. Thanks to David Diviny
  for writing this function.

#### Convenience functions for loading time series data

There are several functions that load specific ABS time series data:

- `read_cpi()` imports the Consumer Price Index numbers as a two-column
  tibble: `date` and `cpi`. This is useful for joining to other series
  to adjust data for changes in consumer prices.
- `read_awe()` returns a long time series of Average Weekly Earnings
  data.
- `read_job_mobility()` downloads, imports and tidies tables from the
  ABS Job Mobility dataset.

### ABS data cubes

The ABS (generally) releases time series data in a standard format,
which allows `read_abs()` to download, import and tidy it (see above).
But not all ABS data is time series data - the ABS also releases data as
‘data cubes’. These are all formatted in their own, unique way.

Unfortunately, because data cubes are all formatted in their own way,
there is no one function that can import tidy data cubes for you in the
same way that `read_abs()` works with all time series. But `{readabs}`
still has functions that can help. Thanks to David Diviny for writing
these functions.

The `download_abs_data_cube()` function can download an ABS data cube
for you. It works with any data cube on the ABS website. To use this
function, we need two things: a `catalogue_string` (the short name of
the release) and `cube`, a (unique fragment of) the filename within the
catalogue you wish to download.

For example, let’s say you wanted to download table 4 from *Weekly
Payroll Jobs and Wages in Australia*. We can find the catalogue name
like this:

``` r
search_catalogues("payroll")
#> # A tibble: 2 × 4
#>   heading sub_heading                                         catalogue    url  
#>   <chr>   <chr>                                               <chr>        <chr>
#> 1 Jobs    Weekly Payroll Jobs and Wages in Australia          weekly-payr… http…
#> 2 Jobs    Weekly Payroll Jobs and Wages in Australia, Interim weekly-payr… http…
```

Now we know that the string `"weekly-payroll-jobs-and-wages-australia"`
is the `catalogue_string` for this release. We can now see what files
are available to download from this catalogue:

``` r
show_available_files("weekly-payroll-jobs-and-wages-australia")
#> # A tibble: 8 × 3
#>   label                                                              file  url  
#>   <chr>                                                              <chr> <chr>
#> 1 Table 20: Payroll jobs - characteristics distributionsContains se… 6160… http…
#> 2 Table 4: Payroll jobs and wages indexes                            6160… http…
#> 3 Table 5: Sub-state - Payroll jobs indexes                          6160… http…
#> 4 Table 6: Industry subdivision - Payroll jobs indexes               6160… http…
#> 5 Table 7: Employer characteristics - Payroll jobs index             6160… http…
#> 6 Table 8: Jobholder characteristics - Payroll jobs index            6160… http…
#> 7 Table 9: Sector - Payroll jobs index                               6160… http…
#> 8 All data cubes                                                     6160… http…
```

We want Table 4, which has the filename `6160055001_DO004.xlsx`.

We can download the file as follows:

``` r
payrolls_t4_path <- download_abs_data_cube("weekly-payroll-jobs-and-wages-australia", "004")
#> File downloaded in /var/folders/4v/f518hjbj00b64c7j75n4k_jc0000gq/T//RtmpPpukIE/6160055001_DO004.xlsx

payrolls_t4_path
#> [1] "/var/folders/4v/f518hjbj00b64c7j75n4k_jc0000gq/T//RtmpPpukIE/6160055001_DO004.xlsx"
```

The `download_abs_data_cube()` function downloads the file and returns
the full file path to the saved file. You can then pipe that in to
another function:

``` r
payrolls_t4_path %>%
  readxl::read_excel(
    sheet = "Payroll jobs index",
    skip = 5
  )
#> # A tibble: 4,322 × 154
#>    State…¹ Indus…² Sex   Age g…³ `43834` `43841` `43848` `43855` `43862` `43869`
#>    <chr>   <chr>   <chr> <chr>   <chr>   <chr>   <chr>   <chr>   <chr>   <chr>  
#>  1 0. Aus… 0. All… 0. P… 0. All… 92.77   95.19   96.73   97.56   98.09   98.7   
#>  2 0. Aus… 0. All… 0. P… 1. 15-… 92.34   94.99   97.17   98.95   98.53   100.06 
#>  3 0. Aus… 0. All… 0. P… 2. 20-… 92.49   95.29   97.27   98.07   98.2    98.65  
#>  4 0. Aus… 0. All… 0. P… 3. 30-… 93.32   95.67   97.04   97.71   98.2    98.67  
#>  5 0. Aus… 0. All… 0. P… 4. 40-… 93.09   95.3    96.62   97.4    98.05   98.7   
#>  6 0. Aus… 0. All… 0. P… 5. 50-… 93.03   95.33   96.69   97.45   98.17   98.76  
#>  7 0. Aus… 0. All… 0. P… 6. 60-… 91.36   93.58   94.86   95.72   97.31   98.05  
#>  8 0. Aus… 0. All… 0. P… 7. 70 … 87.75   90.1    91.34   92.67   95.68   96.88  
#>  9 0. Aus… 0. All… 1. M… 0. All… 92.64   95.65   97.39   98.12   98.44   98.87  
#> 10 0. Aus… 0. All… 1. M… 1. 15-… 91.43   94.94   97.17   98.93   98.37   99.94  
#> # … with 4,312 more rows, 144 more variables: `43876` <chr>, `43883` <chr>,
#> #   `43890` <chr>, `43897` <chr>, `43904` <chr>, `43911` <chr>, `43918` <chr>,
#> #   `43925` <chr>, `43932` <chr>, `43939` <chr>, `43946` <chr>, `43953` <chr>,
#> #   `43960` <chr>, `43967` <chr>, `43974` <chr>, `43981` <chr>, `43988` <chr>,
#> #   `43995` <chr>, `44002` <chr>, `44009` <chr>, `44016` <chr>, `44023` <chr>,
#> #   `44030` <chr>, `44037` <chr>, `44044` <chr>, `44051` <chr>, `44058` <chr>,
#> #   `44065` <chr>, `44072` <chr>, `44079` <chr>, `44086` <chr>, …
```

#### Convenience functions for data cubes

As it happens, if you want the ABS Weekly Payrolls data, you don’t need
to use `download_abs_data_cube()` directly. Instead, there is a
convenience function available that downloads, imports, and tidies the
data for you:

``` r
read_payrolls()
#> File downloaded in /var/folders/4v/f518hjbj00b64c7j75n4k_jc0000gq/T//RtmpPpukIE/6160055001_DO004.xlsx
#> # A tibble: 129,300 × 7
#>    state     industry       sex     age      date       value series
#>    <chr>     <chr>          <chr>   <chr>    <date>     <dbl> <chr> 
#>  1 Australia All industries Persons All ages 2020-01-04  92.8 jobs  
#>  2 Australia All industries Persons All ages 2020-01-11  95.2 jobs  
#>  3 Australia All industries Persons All ages 2020-01-18  96.7 jobs  
#>  4 Australia All industries Persons All ages 2020-01-25  97.6 jobs  
#>  5 Australia All industries Persons All ages 2020-02-01  98.1 jobs  
#>  6 Australia All industries Persons All ages 2020-02-08  98.7 jobs  
#>  7 Australia All industries Persons All ages 2020-02-15  99.2 jobs  
#>  8 Australia All industries Persons All ages 2020-02-22  99.5 jobs  
#>  9 Australia All industries Persons All ages 2020-02-29  99.5 jobs  
#> 10 Australia All industries Persons All ages 2020-03-07  99.9 jobs  
#> # … with 129,290 more rows
```

There is also a convenience function available for data cube GM1 from
the monthly Labour Force data, which contains labour force gross flows:

``` r
read_lfs_grossflows()
#> File downloaded in /var/folders/4v/f518hjbj00b64c7j75n4k_jc0000gq/T//RtmpPpukIE/GM1.xlsx
#> # A tibble: 1,032,009 × 9
#>    date       sex   age         state      lfs_c…¹ lfs_p…² persons unit  weights
#>    <date>     <chr> <chr>       <chr>      <chr>   <chr>     <dbl> <chr> <chr>  
#>  1 2003-01-01 Males 15-19 years New South… Employ… Employ…  34.4   000s  curren…
#>  2 2003-01-01 Males 15-19 years New South… Employ… Employ…   4.36  000s  curren…
#>  3 2003-01-01 Males 15-19 years New South… Employ… Unempl…   0.298 000s  curren…
#>  4 2003-01-01 Males 15-19 years New South… Employ… Not in…   3.37  000s  curren…
#>  5 2003-01-01 Males 15-19 years New South… Employ… Unmatc…   3.36  000s  curren…
#>  6 2003-01-01 Males 15-19 years New South… Employ… Incomi…   3.52  000s  curren…
#>  7 2003-01-01 Males 15-19 years New South… Employ… Employ…   3.68  000s  curren…
#>  8 2003-01-01 Males 15-19 years New South… Employ… Employ…  37.5   000s  curren…
#>  9 2003-01-01 Males 15-19 years New South… Employ… Unempl…   3.20  000s  curren…
#> 10 2003-01-01 Males 15-19 years New South… Employ… Not in…   4.76  000s  curren…
#> # … with 1,031,999 more rows, and abbreviated variable names ¹​lfs_current,
#> #   ²​lfs_previous
```

### Finding and loading data from the ABS.Stat API

The ABS has created a new site to access its data, called the ABS Data
Explorer, also known as ABS.Stat. As at early 2023, this site is in Beta
mode. The site provides an API.

The {readabs} package includes functions to query the ABS.Stat API.
Thank you to Kinto Behr for writing these functions. The functions are:

- `read_api_dataflows()` lists available dataflows (roughly equivalent
  to ‘tables’)
- `read_api_datastructure()` lists variables within a particular
  dataflow and the levels of those variables, which you can use to
  filter the data server-side in an API query
- `read_api()` downloads data from the ABS.Stat API.

Let’s list available dataflows:

``` r
flows <- read_api_dataflows()
```

Say from this I am interested in the first dataflow, the projected
population of Aboriginal and Torres Strait Islander Australians. The id
for this dataflow is `"ABORIGINAL_POP_PROJ"`, which I can use to
download the data.

In this case, I could download the entire dataflow with:

``` r
read_api("ABORIGINAL_POP_PROJ")
#> # A tibble: 72,144 × 11
#>    measure             sex_abs age       asgs_…¹ proj_…² frequ…³ time_…⁴ obs_v…⁵
#>    <chr+lbl>           <dbl+l> <chr+lbl> <dbl+l> <dbl+l> <chr+l>   <int>   <int>
#>  1 POP_PROJ [Projecte… 3 [Per… A04 [0 -… 1 [New… 3 [Ser… A [Ann…    2016   32068
#>  2 POP_PROJ [Projecte… 3 [Per… A04 [0 -… 1 [New… 3 [Ser… A [Ann…    2017   32056
#>  3 POP_PROJ [Projecte… 3 [Per… A04 [0 -… 1 [New… 3 [Ser… A [Ann…    2018   32180
#>  4 POP_PROJ [Projecte… 3 [Per… A04 [0 -… 1 [New… 3 [Ser… A [Ann…    2019   32617
#>  5 POP_PROJ [Projecte… 3 [Per… A04 [0 -… 1 [New… 3 [Ser… A [Ann…    2020   32992
#>  6 POP_PROJ [Projecte… 3 [Per… A04 [0 -… 1 [New… 3 [Ser… A [Ann…    2021   33341
#>  7 POP_PROJ [Projecte… 3 [Per… A04 [0 -… 1 [New… 3 [Ser… A [Ann…    2022   33933
#>  8 POP_PROJ [Projecte… 3 [Per… A04 [0 -… 1 [New… 3 [Ser… A [Ann…    2023   34496
#>  9 POP_PROJ [Projecte… 3 [Per… A04 [0 -… 1 [New… 3 [Ser… A [Ann…    2024   35027
#> 10 POP_PROJ [Projecte… 3 [Per… A04 [0 -… 1 [New… 3 [Ser… A [Ann…    2025   35523
#> # … with 72,134 more rows, 3 more variables: unit_measure <chr+lbl>,
#> #   obs_status <chr+lbl>, obs_comment <lgl>, and abbreviated variable names
#> #   ¹​asgs_2011, ²​proj_series, ³​frequency, ⁴​time_period, ⁵​obs_value
```

Let’s say I’m only interested in the population projections for males,
not females or all persons. In that case, I can filter the data on the
ABS server before downloading my query. I can use
`read_api_datastructure()` to help with this.

``` r
read_api_datastructure("ABORIGINAL_POP_PROJ")
#> # A tibble: 332 × 6
#>    role      var     position desc    code     label               
#>    <chr>     <chr>   <chr>    <chr>   <chr>    <chr>               
#>  1 dimension measure 1        Measure POP_PROJ Projected population
#>  2 dimension sex_abs 2        Sex     1        Males               
#>  3 dimension sex_abs 2        Sex     2        Females             
#>  4 dimension sex_abs 2        Sex     3        Persons             
#>  5 dimension age     3        Age     0        0                   
#>  6 dimension age     3        Age     0014     0 - 14              
#>  7 dimension age     3        Age     0015     0 - 15              
#>  8 dimension age     3        Age     0104     1 - 4               
#>  9 dimension age     3        Age     0514     5 - 14              
#> 10 dimension age     3        Age     1        1                   
#> # … with 322 more rows
```

From this, I can see that there’s a variable (`var`) called `sex_abs`,
which can take the value `1`, `2`, or `3`, corresponding to `Males`,
`Females` and `Persons`. If I only want to data for Males, I can obtain
this by supplying a datakey:

``` r
read_api("ABORIGINAL_POP_PROJ", datakey = list(sex_abs = 1))
#> # A tibble: 24,048 × 11
#>    measure             sex_abs age       asgs_…¹ proj_…² frequ…³ time_…⁴ obs_v…⁵
#>    <chr+lbl>           <dbl+l> <chr+lbl> <dbl+l> <dbl+l> <chr+l>   <int>   <int>
#>  1 POP_PROJ [Projecte… 1 [Mal… A04 [0 -… 1 [New… 7 [Ser… A [Ann…    2016   16675
#>  2 POP_PROJ [Projecte… 1 [Mal… A04 [0 -… 1 [New… 7 [Ser… A [Ann…    2017   16656
#>  3 POP_PROJ [Projecte… 1 [Mal… A04 [0 -… 1 [New… 7 [Ser… A [Ann…    2018   16661
#>  4 POP_PROJ [Projecte… 1 [Mal… A04 [0 -… 1 [New… 7 [Ser… A [Ann…    2019   16887
#>  5 POP_PROJ [Projecte… 1 [Mal… A04 [0 -… 1 [New… 7 [Ser… A [Ann…    2020   17183
#>  6 POP_PROJ [Projecte… 1 [Mal… A04 [0 -… 1 [New… 7 [Ser… A [Ann…    2021   17534
#>  7 POP_PROJ [Projecte… 1 [Mal… A04 [0 -… 1 [New… 7 [Ser… A [Ann…    2022   18023
#>  8 POP_PROJ [Projecte… 1 [Mal… A04 [0 -… 1 [New… 7 [Ser… A [Ann…    2023   18516
#>  9 POP_PROJ [Projecte… 1 [Mal… A04 [0 -… 1 [New… 7 [Ser… A [Ann…    2024   19001
#> 10 POP_PROJ [Projecte… 1 [Mal… A04 [0 -… 1 [New… 7 [Ser… A [Ann…    2025   19483
#> # … with 24,038 more rows, 3 more variables: unit_measure <chr+lbl>,
#> #   obs_status <chr+lbl>, obs_comment <lgl>, and abbreviated variable names
#> #   ¹​asgs_2011, ²​proj_series, ³​frequency, ⁴​time_period, ⁵​obs_value
```

Note that in some cases, querying the API without filtering the data
will return an error, as the table will be too big. In this case, you
will need to supply a datakey that reduces the size of the data.

## Bug reports and feedback

GitHub issues containing error reports or feature requests are welcome.
Please try to make a [reprex](https://reprex.tidyverse.org) (a minimal,
reproducible example) if possible.

Alternatively you can email the package maintainer at mattcowgill at
gmail dot com.

## Disclaimer

The `{readabs}` package is not associated with the Australian Bureau of
Statistics. All data is provided subject to any restrictions and
licensing arrangements noted on the ABS website.

## Awesome Official Statistics Software

[![Mentioned in Awesome Official
Statistics](https://awesome.re/mentioned-badge.svg)](https://github.com/SNStatComp/awesome-official-statistics-software)

We’re pleased to be included in a [list of
software](https://github.com/SNStatComp/awesome-official-statistics-software)
that can be used to work with official statistics.
