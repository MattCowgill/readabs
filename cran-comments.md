## Test environments

* local OS X install, R 3.5.0
* ubuntu 12.04 (on travis-ci), R 3.5.0
* win-builder (devel and release)


## R CMD check results
There were no ERRORs or WARNINGs. 

There were 2 NOTEs:

* checking Rd line widths ... NOTE
Rd file 'read_abs_data.Rd':
  \examples lines wider than 100 characters:
     read_abs_data(path=system.file("extdata","5206002_expenditure_volume_measures.xls",  package = "readabs", mustWork = TRUE), sheet=2)

Rd file 'read_abs_metadata.Rd':
  \examples lines wider than 100 characters:
     read_abs_metadata(path=system.file("extdata", "5206002_expenditure_volume_measures.xls",  package = "readabs", mustWork = TRUE), sheet= ... [TRUNCATED]

Rd file 'read_abs_sdmx.Rd':
  \examples lines wider than 100 characters:
     read_abs_sdmx("http://stat.data.abs.gov.au/restsdmx/sdmx.ashx/GetData/ABS_REGIONAL_ASGS/PENSION_2+BANKRUPT_2.AUS.0.A/all?startTime=2013 ... [TRUNCATED]

These lines will be truncated in the PDF manual.


*  First submission.





