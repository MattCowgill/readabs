% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/check_latest_date.R
\name{check_latest_date}
\alias{check_latest_date}
\title{Get date of most recent observation(s) in ABS time series}
\usage{
check_latest_date(cat_no = NULL, tables = "all", series_id = NULL)
}
\arguments{
\item{cat_no}{ABS catalogue number, as a string, including the extension.
For example, "6202.0".}

\item{tables}{numeric. Time series tables in \verb{cat_no`` to download and extract. Default is "all", which will read all time series in }cat_no\verb{. Specify }tables\verb{to download and import specific tables(s) - eg.}tables = 1\code{or}tables = c(1, 5)`.}

\item{series_id}{(optional) character. Supply an ABS unique time series
identifier (such as "A2325807L") to get only that series.
This is an alternative to specifying \code{cat_no}.}
}
\value{
Date vector of length one. Date corresponds to the most recent
observation date for any of the time series in the table(s) requested.
observation date for any of the time series in the table(s) requested.
}
\description{
This function returns the most recent observation date for a specified ABS
time series catalogue number (as a whole), individual tables, or series IDs.
}
\details{
Where the individual time series in your request
have multiple dates, only the most recent will be returned.
}
\examples{
\dontrun{

# Check a whole catalogue number; return the latest release date for any
# time series in the number

check_latest_date("6345.0")

# Return latest release date for a table within a catalogue number  - note
# the function will return the release date
# of the most-recently-updated series within the tables
check_latest_date("6345.0", tables = 1)

# Or for multiple tables - note the function will return the release date
# of the most-recently-updated series within the tables
check_latest_date("6345.0", tables = c("1", "5a"))

# Or for an individual time series
check_latest_date(series_id = "A2713849C")
}

}
