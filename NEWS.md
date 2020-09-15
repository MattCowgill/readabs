# readabs 0.4.3.3
* Minor internal change to prepare readabs for the new ABS website

# readabs 0.4.3.2
* New download_abs_data_cube() function added courtesy of David Diviny

# readabs 0.4.3.1
* Error when using dev version of vctrs package rectified

# readabs 0.4.3
* Alternative method now used to check for internet access when running `read_abs()`; the function now works in a broader range of IT environments
* README and vignette refined

# readabs 0.4.2
* Default path for `read_abs()` is now defined by an environmental variable; thanks to Hugh Parsonage for the idea and implementation.

# readabs 0.4.1
* `separate_series()` function gains a `drop_nas` argument, thanks to Sam Gow for the suggestion.
* Added more unit tests and reorganised tests

# readabs 0.4.0
* New `separate_series()` function thanks to David Diviny, which splits the `series` column of tidied ABS time series into multiple components
* New `read_cpi()` convenience function to get the CPI index numbers
* Files read with `read_abs()` are now stored in a subdirectory of `path` corresponding to the catalogue number
* New `series_id` argument to `read_abs()` allows users to get specific time series using their unique identifiers
* Order of arguments to `read_abs()` have changed slightly, with new `series_id` argument added
* Order of arguments to `read_abs_local()` have changed, new `cat_no` argument added, `filenames` argument works as before, but the argument order has changed
* Fixed file path error when using `read_abs(retain_files = FALSE)` on Windows
* `get_abs()` now deprecated; use `read_abs()` instead (it has identical functionality)

# readabs 0.3.1
* `read_abs()` now checks for internet access and returns a comprehensible error if not present
* New function `read_abs_seriesid()` gets data corresponding to unique ABS time series IDs
* Thanks to @HughParsonage for fixing the vignette index and suggesting other fixes
* ABS API was (silently!) updated to use https rather than http; readabs now works with this
* added a retain_files option (default = TRUE) to read_abs()

# readabs 0.3.0
* Merged with `getabs` package
* New core function (`read_abs()`) to download, import and tidy data in one step
* New function (`read_abs_local()`) to import and tidy locally-stored spreadsheets
* `read_abs_data()` is now soft-deprecated and will be removed in a future release

# readabs 0.2.9
* Matt Cowgill is the new maintainer and author of `readabs`
* Fixed issue (#1) with blank column names that arose from new name repair behaviour in tibble 2.0.0

# readabs 0.2.1 
* Add descriptive information to `read_abs_sdmx()`

# readabs 0.2.0
* Delete `read_abs_codebook()`
* Create vignette and website using pkgdown
* Update documentation and available data

# readabs 0.1.0
* Name change from abs to readabs

