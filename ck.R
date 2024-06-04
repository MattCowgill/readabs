
test <- readabs::read_api(
  id="AUSTRALIAN_INDUSTRY",
  datakey=list(measure="INDUSTRY",
               industry=c("01", "02", "12"),
               basis="1",
               region="AUS",
               freq="A"),
  start_period="2023")

source("R/check_abs_connection.R")
source("R/read_api.R")

aschar <- read_api(
  id="AUSTRALIAN_INDUSTRY",
  datakey=list(measure="INDUSTRY",
               industry=c("01", "02", "12"),
               basis="1",
               region="AUS",
               freq="A"),
  start_period="2023")

url <- "https://api.data.abs.gov.au/data/ABS,AUSTRALIAN_INDUSTRY/INDUSTRY.01+02+12.1.AUS.A.?startPeriod=2023"

df <- abs_api_fetch_data(url)
