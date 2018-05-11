## Functions to read ABS SDXM URLs
## Zoe Meers
## The United States Studies Centre

#' Extracts ABS XML-formatted data using the exported XML link at http://www.abs.gov.au/
#'
#' @param url URL weblink.
#'
#' @return Dataframe
#' @export
#'
#' @examples
#' read_abs_sdmx(url="http://stat.data.abs.gov.au/restsdmx/sdmx.ashx/GetData/CPI/1.1+2+3+4+5+6+7+8+50.10001.10.Q/all?startTime=2014-Q1&endTime=2016-Q4")


read_abs_sdmx <- function(url) {
  url <- url
  dataset <- rsdmx::readSDMX(url)
  abs_data <- as.data.frame(dataset)
  abs_data$state <- ifelse(abs_data$REGIONTYPE == "STE" & abs_data$AEC_FED_2017 == 1, "NSW",
    ifelse(abs_data$REGIONTYPE == "STE" & abs_data$AEC_FED_2017 == 2, "VIC",
      ifelse(abs_data$REGIONTYPE == "STE" & abs_data$AEC_FED_2017 == 3, "QLD",
        ifelse(abs_data$REGIONTYPE == "STE" & abs_data$AEC_FED_2017 == 4, "SA",
          ifelse(abs_data$REGIONTYPE == "STE" & abs_data$AEC_FED_2017 == 5, "WA",
            ifelse(abs_data$REGIONTYPE == "STE" & abs_data$AEC_FED_2017 == 6, "TAS",
              ifelse(abs_data$REGIONTYPE == "STE" & abs_data$AEC_FED_2017 == 7, "NT",
                ifelse(abs_data$REGIONTYPE == "STE" & abs_data$AEC_FED_2017 == 8, "ACT", NA)
              )
            )
          )
        )
      )
    )
  )

  return(abs_data)
}
