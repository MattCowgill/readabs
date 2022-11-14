library(dplyr)
library(purrr)

# Source this script from `create_internal_data.R`

#' If a file does not exist locally, download it
#' @param file Filename incl. path
#' @param url URL from which to download the file if it doesn't exist locally
dl_if_not <- function(file, url) {
  if (!file.exists(file)) {
    if (!dir.exists(dirname(file))) {
      dir.create(dirname(file), recursive = TRUE)
    }

    utils::download.file(
      url = url,
      headers = readabs_header,
      destfile = file
    )
  }
}

#' @param filenames vector of 2 filenames excl. path. First element is filename
#'  for AWE file to May 2009; second is file to May 2012.
#' @param urls vector of 2 ABS URLs; first is for AWE file to May 2009;
#' second is file to May 2012.
load_old_awe <- function(table_num,
                         urls) {
  filenames <- paste0(
    c(
      "awe_to_may09_t",
      "awe_to_may12_t"
    ),
    table_num,
    ".xls"
  )

  old_awote_dir <- file.path("data-raw", "old_awe")
  filenames_incl_path <- file.path(old_awote_dir, filenames)

  purrr::walk2(
    .x = filenames_incl_path,
    .y = urls,
    .f = dl_if_not
  )

  list_of_dfs <- purrr::map(
    .x = filenames,
    .f = ~ read_abs_local(
      filenames = .x,
      path = old_awote_dir
    )
  )

  list_of_dfs <- purrr::map(
    .x = list_of_dfs,
    .f = tidy_awe
  )

  list_of_dfs[[1]] <- list_of_dfs[[1]] %>%
    dplyr::filter(!.data$date %in% list_of_dfs[[2]]$date)

  df <- bind_rows(list_of_dfs)

  df
}


urls <- list(
  "2" = c(
    "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&6302002.xls&6302.0&Time%20Series%20Spreadsheet&5379E96E39273CF5CA25761000199DDA&0&May%202009&13.08.2009&Latest",
    "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&6302002.xls&6302.0&Time%20Series%20Spreadsheet&16F1263CC960388CCA257A5B00121514&0&May%202012&16.08.2012&Latest"
  ),
  "5" = c(
    "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&6302005.xls&6302.0&Time%20Series%20Spreadsheet&050F0580F25B65E3CA2576100019ABA5&0&May%202009&13.08.2009&Latest",
    "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&6302005.xls&6302.0&Time%20Series%20Spreadsheet&1E27AEE93FD82D5BCA257A5B00121697&0&May%202012&16.08.2012&Latest"
  ),
  "8" = c(
    "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&6302008.xls&6302.0&Time%20Series%20Spreadsheet&AFD09874D98173D1CA2576100019B97A&0&May%202009&13.08.2009&Latest",
    "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&6302008.xls&6302.0&Time%20Series%20Spreadsheet&42F0D3762EA4B015CA257A5B00121828&0&May%202012&16.08.2012&Latest"
  ),
  "12a" = c(
    "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&63020012a.xls&6302.0&Time%20Series%20Spreadsheet&9CBA3F3531072C68CA257610001A1011&0&May%202009&13.08.2009&Latest",
    "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&63020012a.xls&6302.0&Time%20Series%20Spreadsheet&3995977F136AE267CA257A5B00122365&0&May%202012&16.08.2012&Latest"
  ),
  "12b" = c(
    "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&63020012b.xls&6302.0&Time%20Series%20Spreadsheet&BC330F9D522D37CBCA257610001A146D&0&May%202009&13.08.2009&Latest",
    "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&63020012b.xls&6302.0&Time%20Series%20Spreadsheet&57BAD981956F9A5ACA257A5B001223F1&0&May%202012&16.08.2012&Latest"
  ),
  "12c" = c(
    "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&63020012c.xls&6302.0&Time%20Series%20Spreadsheet&D55540AAEF0F7108CA257610001A192B&0&May%202009&13.08.2009&Latest",
    "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&63020012c.xls&6302.0&Time%20Series%20Spreadsheet&B470FF63181FF706CA257A5B00122482&0&May%202012&16.08.2012&Latest"
  ),
  "12d" = c(
    "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&63020012d.xls&6302.0&Time%20Series%20Spreadsheet&1366F0763440DE6FCA257610001A1D64&0&May%202009&13.08.2009&Latest",
    "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&63020012d.xls&6302.0&Time%20Series%20Spreadsheet&C30CF3491B8A00D6CA257A5B00122516&0&May%202012&16.08.2012&Latest"
  ),
  "12e" = c(
    "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&63020012e.xls&6302.0&Time%20Series%20Spreadsheet&ADD63AF30832FD46CA257610001A225C&0&May%202009&13.08.2009&Latest",
    "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&63020012e.xls&6302.0&Time%20Series%20Spreadsheet&3CEB8E4A42304296CA257A5B001225B4&0&May%202012&16.08.2012&Latest"
  ),
  "12f" = c(
    "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&63020012f.xls&6302.0&Time%20Series%20Spreadsheet&D04EA449744101C8CA257610001A26C1&0&May%202009&13.08.2009&Latest",
    "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&63020012f.xls&6302.0&Time%20Series%20Spreadsheet&3640583B53FBC62FCA257A5B0012264D&0&May%202012&16.08.2012&Latest"
  ),
  "12g" = c(
    "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&63020012g.xls&6302.0&Time%20Series%20Spreadsheet&EDE65E09FE65B9BFCA257610001A2B10&0&May%202009&13.08.2009&Latest",
    "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&63020012g.xls&6302.0&Time%20Series%20Spreadsheet&52059A2FFE4E535CCA257A5B001226E7&0&May%202012&16.08.2012&Latest"
  ),
  "12h" = c(
    "https://www.abs.gov.au/AUSSTATS/ABS@Archive.nsf/log?openagent&63020012h.xls&6302.0&Time%20Series%20Spreadsheet&DD449B1CA7952AE6CA257610001A2FA2&0&May%202009&13.08.2009&Latest",
    "https://www.abs.gov.au/ausstats/meisubs.NSF/log?openagent&63020012h.xls&6302.0&Time%20Series%20Spreadsheet&023408E38EFA4936CA257A5B00122775&0&May%202012&16.08.2012&Latest"
  )
)

awe_old <- map2(
  .x = names(urls),
  .y = urls,
  .f = load_old_awe
)

awe_old <- setNames(awe_old, names(urls))
