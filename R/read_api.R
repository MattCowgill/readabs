# Documentation: https://api.gov.au/assets/APIs/abs/DataAPI.openapi.html#/Get%20Data/GetData
# More documentation: https://www.abs.gov.au/about/data-services/application-programming-interfaces-apis/data-api-user-guide/using-api
# Online data viewer: https://explore.data.abs.gov.au/

#' ABS.Stat API functions
#'
#' @description
#' `r lifecycle::badge("experimental")`
#'
#' These experimental functions provide a minimal interface to the ABS.Stat API.
#'
#' More information on the ABS.Stat API can be found
#' on the [ABS website](https://www.abs.gov.au/about/data-services/application-programming-interfaces-apis/data-api-user-guide/using-api)
#'
#' Note that an ABS.Stat 'dataflow' is like a table. A 'datastructure'
#' contains metadata that describes the variables in the dataflow. To load data
#' from the ABS.Stat API, you need to either:
#'
#'   - Using `read_api_dataflows()` you can get information on the available dataflows
#'   - Using `read_api_datastructure()` you can get metadata relating to a
#'   specific dataflow, including the variables available in each dataflow
#'   - Using `read_api()` you can get the data belonging to a given dataflow.
#'   - Using `read_api_url()` you can get the data for a given query url
#'   generated using the [online data viewer](https://explore.data.abs.gov.au/).
#'
#' @param id A dataflow id. Use `read_api_dataflows()` to obtain a dataframe
#'   listing available dataflows.
#' @param datakey A named list matching filter variables to codes. All variables
#'   with a `position` in the datastructure are filterable. Use
#'   `read_api_datastructure()` to obtain information about the variables in
#'   a dataflow and the values of that variable.
#' @param start_period The start period (used to filter by time). This is
#'   inclusive. The supported formats are:
#'
#'   - `"YYYY"` for annual data (e.g. 2019)
#'   - `"YYYY-S[1-2]"` for semi-annual data (e.g. 2019-S1)
#'   - `"YYYY-Q[1-4]"` for quarterly data (e.g. 2019-Q1)
#'   - `"YYYY-MM[01-12]"` for monthly data (e.g. 2019-01)
#'   - `"YYYY-W[01-53]"` for weekly data (e.g. 2019-W01)
#'   - `"YYYY-MM-DD"` for daily and business data (e.g. 2019-01-01)
#' @param end_period The end period (used to filter on time). This is inclusive.
#'   The supported formats are the same as for `start_period`
#' @param version A version number, if unspecified the latest version of the
#'   dataset is used. Use `read_api_dataflows()` to see
#'   available dataflow versions.
#' @param url A complete query url
#'
#' @details
#' Note that the API enforces a reasonably strict gateway timeout policy. This
#' means that, if you're trying to access a reasonably large dataset, you will
#' need to filter it on the server side using the `datakey`. You might like to
#' review the data manually via the [ABS website](https://explore.data.abs.gov.au/)
#' to figure out what subset of the data you require.
#'
#' Note, furthermore, that the datastructure contains a complete codebook for
#' the variables appearing in the relevant dataflow. Since some variables are
#' shared across multiple dataflows, this means that the datastructure
#' corresponding to a particular `id` may contain values for a given variable
#' which are not in the corresponding dataflow.
#'
#' @return A data.frame
#'
#' @examples
#' \dontrun{
#' # List available dataflows
#' read_api_dataflows()
#'
#' # Say we want the "Estimated resident population, Country of birth"
#' # data flow, with the id ERP_COB. We load the data like this:
#' # Get full data set for a given flow by providing id and start period:
#' read_api("ERP_COB", start_period = 2020)
#'
#' # In some cases, loading a whole dataflow (as above) won't work.
#' # For eg., the `ABS_C16_T10_SA` dataflow is very large,
#' # so the gateway will timeout if we try to collect the full data set
#' try(read_api("ABS_C16_T10_SA"))
#'
#' # We need to filter the dataflow before downlaoding it.
#' # To figure out how to filter it, we get metadata ('datastructure').
#' ds <- read_api_datastructure("ABS_C16_T10_SA")
#'
#' # The `asgs_2016` code for 'Australia' is 0
#' ds[ds$var == "asgs_2016" & ds$label == "Australia", ]
#'
#' # The `sex_abs` code for 'Persons' (i.e. all persons) is 3
#' ds[ds$var == "sex_abs" & ds$label == "Persons", ]
#'
#' # So we have:
#' x <- read_api("ABS_C16_T10_SA", datakey = list(asgs_2016 = 0, sex_abs = 3))
#' unique(x["asgs_2016"]) # Confirming only 'Australia' level records came through
#' unique(x["sex_abs"]) # Confirming only 'Persons' level records came through
#'
#' # Please note however that not all values in the datastructure necessarily
#' # appear in the data. You get 404s in this case
#' ds[ds$var == "regiontype" & ds$label == "Destination Zones", ]
#' try(read_api("ABS_C16_T10_SA", datakey = list(regiontype = "DZN")))
#'
#' # If you already have a query url, then use `read_api_url()`
#' wpi_url <- "https://data.api.abs.gov.au/rest/data/ABS,WPI/all"
#' read_api_url(wpi_url)
#' }
#' @name abs_api
NULL

#' @export
#' @rdname abs_api
read_api_dataflows <- function() {
  check_abs_connection()
  r <- httr::GET(abs_api_url("rest/dataflow/ABS"))
  r <- httr::content(r)
  out <- purrr::map_dfr(r$references, ~ .[c("id", "name", "version")])
  names(out) <- c("id", "name", "version")

  # Not all of them have descriptions
  desc <- purrr::map(r$references, "description")
  desc <- purrr::map_chr(desc, ~ ifelse(is.null(.), "", .))
  out$desc <- desc

  out$version <- numeric_version(out$version)
  out[c("id", "name", "desc", "version")]
}


#' @export
#' @rdname abs_api
read_api <- function(id, datakey = NULL, start_period = NULL, end_period = NULL, version = NULL) {
  check_abs_connection()

  # Fetch datastructure
  datastructure <- read_api_datastructure(id)
  datastructure <- datastructure[!is.na(datastructure$code), ]

  # Build data query
  dataflow <- paste0("ABS,", id)
  if (!is.null(version)) dataflow <- paste(dataflow, version, sep = ",")
  q <- c("startPeriod" = start_period, "endPeriod" = end_period)
  if (!is.null(datakey)) {
    k <- abs_api_match_key(datakey, datastructure)
  } else {
    k <- "all"
  }

  url <- abs_api_url(c("rest", "data", dataflow, k), q)

  # Fetch data
  df <- abs_api_fetch_data(url)
  abs_api_label_data(df, datastructure)
}

#' @export
#' @rdname abs_api
read_api_url <- function(url) {
  check_abs_connection()

  # Fetch datastructure
  id <- abs_api_id_from_url(url)
  datastructure <- read_api_datastructure(id)
  datastructure <- datastructure[!is.na(datastructure$code), ]

  # Fetch data
  df <- abs_api_fetch_data(url)
  abs_api_label_data(df, datastructure)
}


#' @export
#' @rdname abs_api
read_api_datastructure <- function(id) {
  check_abs_connection()

  r <- httr::GET(abs_api_url(c("rest", "dataflow", "ABS", id, "?references=all")), httr::accept_xml())
  httr::stop_for_status(r)
  r <- httr::content(r)

  r <- xml2::as_list(r)

  codelists <- r$Structure$Structures$Codelists
  names(codelists) <- purrr::map_chr(r$Structure$Structures$Codelists, ~ attr(., "id"))
  components <- r$Structure$Structures$DataStructures$DataStructure$DataStructureComponents

  codelists <- purrr::imap_dfr(codelists, function(codelist, nm) {
    desc <- codelist$Name[[1]]
    purrr::map_dfr(codelist, ~ c(local_id = nm, desc = desc, code = attr(., "id"), label = .$Name))
  })
  codelists <- codelists[!is.na(codelists$code), ]

  components <- purrr::imap_dfr(components, function(x, nm) {
    nm <- tolower(gsub("List", "", nm))
    purrr::map_dfr(x, ~ c(
      role = nm,
      var = attr(., "id"),
      local_id = attr(.$LocalRepresentation$Enumeration$Ref, "id"),
      position = attr(., "position")
    ))
  })

  out <- merge(components, codelists, by = "local_id", all.x = TRUE, all.y = TRUE)
  out <- out[order(out$code), ]
  out <- out[order(out$position), setdiff(names(out), "local_id")]
  rownames(out) <- NULL

  out$var <- tolower(out$var)
  dplyr::tibble(out)
}


# Internal ---------------------------------------------------------------------

#' Construct an endpoint url
#'
#' @param path A character vector, parts of the url path to be concatenated
#'   together separated by "/"
#' @param query A named character vector, parts of the query string to be
#'   concatenated together as 'name=value' separated by '&'
#'
#' @return A string
#' @noRd
#' @keywords internal
#'
#' @examples
#'
#' abs_api_url(c("a", "path"), query = c(nulls = NULL, get = "dropped"))
abs_api_url <- function(path, query = NULL) {
  out <- paste0("https://data.api.abs.gov.au/", paste(path, collapse = "/"))
  if (!is.null(query)) {
    query <- paste(names(query), query, sep = "=")
    out <- paste0(out, "?", paste(query, collapse = "&"))
  }

  out
}

#' Extract dataflow id from url string
#'
#' @param url A url string
#'
#' @return A string
#' @noRd
#' @keywords internal
#'
abs_api_id_from_url <- function(url) {
  stopifnot("`url` must be of length 1" = length(url) == 1)
  if (!grepl("^https://data.api.abs.gov.au/rest/data/ABS,", url)) {
    stop("`url` is not an ABS query url. Query urls must match regex: \n\t",
         "'^https://data.api.abs.gov.au/rest/data/ABS,.*'",
         call. = FALSE
    )
  }
  id <- strsplit(url, "/")[[1]][6]
  id <- strsplit(id, ",")[[1]][2]
  id
}

#' Construct a datakey to filter an ABS.Stat dataflow
#'
#' @param datakey A named list matching variables to codes
#' @param datastructure A datastructure retrieved with `read_api_datastructure()`
#'
#' @return A datakey string
#' @noRd
#' @keywords internal
#'
#' @examples
#' z <- read_api_datastructure("ERP_COB")
#' abs_api_match_key(list(SEX = 1:3, REGION = "AUS"), z)
#' abs_api_match_key(list(SEX = 1:10, REGION = "AUS"), z)
#' try(abs_api_match_key(list(SX = 1:3, REGION = "AUS"), z))
#' try(abs_api_match_key(list(UNIT_MEASURE = "AUD", REGION = "AUS"), z))
abs_api_match_key <- function(datakey, datastructure) {
  stopifnot("`datakey` must be a named list" = is.list(datakey))
  stopifnot("`datakey` must be a named list" = length(names(datakey)) == length(datakey))

  bad_vars <- setdiff(names(datakey), datastructure$var)
  if (length(bad_vars) > 0) {
    stop(
      call. = FALSE,
      "Variable(s) `", paste(bad_vars, collapse = "`, `"),
      "` not found. Please review the datastructure with `read_api_datastructure()`"
    )
  }

  key <- purrr::imap_dfr(datakey, function(vals, var) {
    ds <- datastructure[datastructure$var %in% var, ]

    bad_vals <- setdiff(vals, ds$code)
    if (length(bad_vals) > 0) {
      if (length(bad_vals) > 5) bad_vals <- c(bad_vals[1:5], "...")
      warning(
        call. = FALSE,
        "Variable `", var, "` does not contain codes: ",
        paste(bad_vals, collapse = ", ")
      )
    }

    if (anyNA(ds$position)) {
      stop(
        call. = FALSE,
        "Cannot filter on `", var,
        "`. Please review the datastructure with `read_api_datastructure()`"
      )
    }

    ds[ds$code %in% vals, ]
  })


  pos <- unique(datastructure$position)
  pos <- sort(pos)

  key <- purrr::map_chr(pos, function(pos) {
    keyvals <- key[key$position == pos, ]
    paste0(paste(keyvals$code, collapse = "+"), ".")
  })

  paste(key, collapse = "")
}

#' Fetch data
#'
#' @param url An API data endpoint
#'
#' @return A data.frame
#' @noRd
#' @keywords internal
#'
abs_api_fetch_data <- function(url) {
  as_csv <- httr::accept("application/vnd.sdmx.data+csv")
  r <- httr::GET(url, as_csv)
  httr::stop_for_status(r)

  r <- utils::read.csv(
    text = rawToChar(httr::content(r)),
    colClasses = "character"
  )
  r <- r[setdiff(names(r), "DATAFLOW")]
  names(r) <- tolower(names(r))

  r
}

#' Label fetched data using datastructure
#'
#' @param df A data.frame of data fetched with `abs_api_fetch_data`
#' @param datastructure A data.structure fetched with `read_api_datastructure`
#'
#' @return A labelled data.frame
#' @noRd
#' @keywords internal
abs_api_label_data <- function(df, datastructure) {
  df <- purrr::imap_dfc(df, function(x, var_name) {
    codes <- datastructure[datastructure$var == var_name, ]
    if (nrow(codes) == 0) {
      # For columns not in codes attempt to coerce to numeric: obs_value & time_period
      if (can_numeric(x)) {
        return(as.numeric(x))
      } else {
        return(x)
      }
    }
    labs <- codes$code


    names(labs) <- codes$label
    labelled::labelled(
      x = x,
      labels = labs,
      label = unique(codes$desc)
    )
  })

  df
}

#' Can something be safely coerced to numeric?
#'
#' @param x A vector
#'
#' @return `TRUE` or `FALSE`
#' @noRd
#' @keywords internal
can_numeric <- function(x) {
  if (is.numeric(x) || is.logical(x) || is.factor(x)) {
    TRUE
  } else {
    !any(!(x %in% c(NA, "")) & is.na(suppressWarnings(as.numeric(x))))
  }
}
