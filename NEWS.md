# readabs 0.3.1
* `read_abs()` now checks for internet access and returns a comprehensible error if not present
* New function `read_abs_seriesid()` gets data corresponding to unique ABS time series IDs
* Thanks to @HughParsonage for fixing the vignette index and suggesting other fixes
* ABS API was (silently!) updated to use https rather than http; readabs now works with this
* added a retain_files option (default = FALSE) to read_abs()

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

