# Documentation: https://api.gov.au/assets/APIs/abs/DataAPI.openapi.html#/Get%20Data/GetData

#' ABS API
#'
#' These functions provide a minimal interface to the ABS API.
#'
#'   - Using `abs_dataflows()` you can get information on the dataflows available
#'   - Using `abs_datastructure()` you can get metadata relating to a specific dataflow
#'   - Using `abs_data()` you can get the data belonging to a given dataflow.
#'
#' Note that the API enforces a reasonably strict gateway timeout policy. This
#' means that, if you're trying to access a reasonably large dataset, you will
#' need to filter it on the server side using the `datakey`.
#'
#' More information can be found on the [ABS website](https://www.abs.gov.au/about/data-services/application-programming-interfaces-apis/data-api-user-guide/using-api)
#'
#' @param id A dataflow id, see `abs_dataflows()` for available dataflows.
#' @param datakey A named list matching filter variables to codes. All variables
#'   with a `position` in the datastructure are filterable. See
#'   `abs_datastructure()` for information.
#' @param start_period The start period (used to filter on time). This is
#'   inclusive. The supported formats are:
#'
#'   - YYYY for annual data (e.g. 2019)
#'   - YYYY-S[1-2] for semi-annual data (e.g. 2019-S1)
#'   - YYYY-Q[1-4] for quarterly data (e.g. 2019-Q1)
#'   - YYYY-MM[01-12] for monthly data (e.g. 2019-01)
#'   - YYYY-W[01-53] for weekly data (e.g. 2019-W01)
#'   - YYYY-MM-DD for daily and business data (e.g. 2019-01-01)
#' @param end_period The end period (used to filter on time). This is inclusive.
#'   The supported formats are the same as for `start_period`
#' @param version A version number, if unspecified the latest version of the
#'   dataset is used. See `abs_dataflows()` for available dataflow versions.
#'
#' @return A data.frame
#'
#' @examples
#'
#' # List available flows
#' abs_dataflows()
#'
#' # Get full data set for a given flow by providing id and start period:
#' abs_data("ERP_COB", start_period = 2020)
#'
#' # The `ABS_C16_T10_SA` dataflow is very large, so the gateway will timeout if we
#' # try to collect the full data set
#' try(abs_data("ABS_C16_T10_SA"))
#'
#' # We need to go for a subset using a datakey, which will be a dot-delimited
#' # query string. To figure out how to build the datakey, we get metadata
#' x <- abs_datastructure("ABS_C16_T10_SA")
#'
#' # The `ASGS_2016` dimension is at position 5 and `ASGS_2016=0` is the code for
#' # 'Australia'
#' x[x$var=="ASGS_2016" & x$label == "Australia", ]
#'
#' # The `SEX_ABS` dimension is at position 1 and `SEX_ABS=3` is the code for
#' # 'Persons' (i.e. all persons)
#' x[x$var=="SEX_ABS" & x$label == "Persons", ]
#'
#' # So we build a datakey putting 3 in the first and 0 in the fifth position to get filtered data
#' y <- abs_data("ABS_C16_T10_SA", datakey = list(ASGS_2016 = 0, SEX_ABS= 3))
#' unique(y["ASGS_2016"]) # Confirming only 'Australia' level records came through
#' unique(y["SEX_ABS"]) # Confirming only 'Australia' level records came through
#'
#' @name abs_api
NULL

#' @export
#' @rdname abs_api
abs_dataflows <- function() {
  r <- httr::GET(abs_api_url("dataflow/ABS"))
  r <- httr::content(r)
  out <- purrr::map_dfr(r$references, ~.[c("id", "name", "version")])
  names(out) <- c("id", "name", "version")

  # Not all of them have descriptions
  desc <- purrr::map(r$references, "description")
  desc <- purrr::map_chr(desc, ~ifelse(is.null(.), "", .))
  out$desc <- desc

  out[c("id", "name", "desc", "version")]
}


#' @export
#' @rdname abs_api
abs_data <- function(id, datakey = NULL, start_period = NULL, end_period = NULL, version = NULL) {
  # Fetch datastructure
  datastructure <- abs_datastructure(id)
  datastructure <- datastructure[!is.na(datastructure$code), ]

  # Build data query
  dataflow <- paste0("ABS,", id)
  if (!is.null(version)) dataflow <- paste(dataflow, version, sep=",")
  q <- c("startPeriod" = start_period, "endPeriod" = end_period)
  if (!is.null(datakey)) {
    k <- abs_api_match_key(datakey, datastructure)
  } else {
    k <- "all"
  }
  url <- abs_api_url(c("data", dataflow, k), q)

  # Fetch data
  as_csv <- httr::accept("application/vnd.sdmx.data+csv")
  r <- httr::GET(url, as_csv)
  if (httr::status_code(r) %in% 404 && !is.null(datakey)) {
    url <- abs_api_url(c("data", dataflow, "all"), q)
    r <- httr::GET(url, as_csv)
    warning(call.=FALSE, paste(
      "The query could not be executed with the provided `datakey`.",
      "This is usually because one or more values provided do not appear in the data.",
      "\n\n Retrying with `datakey=NULL`",
      "Please check your data carefully!"
    ))
  }
  httr::stop_for_status(r)
  r <- resp_as_df(r)

  # Label values
  r <- purrr::imap_dfc(r, function(x, var_name) {
    codes <- datastructure[datastructure$var == var_name, ]
    if (nrow(codes)==0) return(x)
    labs <- codes$code

    # Match class avoiding data loss
    if (can_numeric(x) && can_numeric(labs)) {
      x <- as.numeric(x)
      labs <- as.numeric(labs)
    } else {
      x <- as.character(x)
      labs <- as.character(labs)
    }

    names(labs) <- codes$label
    labelled::labelled(x, labs, unique(codes$desc))
  })

  r[setdiff(names(r), "DATAFLOW")]
}

#' @export
#' @rdname abs_api
abs_datastructure <- function(id) {
  r <- httr::GET(abs_api_url(c("datastructure", "ABS", id, "?references=codelist")), httr::accept_xml())
  httr::stop_for_status(r)
  r <- httr::content(r)

  r <-  xml2::as_list(r)

  codelists <- r$Structure$Structures$Codelists
  names(codelists) <- purrr::map_chr(r$Structure$Structures$Codelists, ~attr(., "id"))
  components <-  r$Structure$Structures$DataStructures$DataStructure$DataStructureComponents

  codelists <- purrr::imap_dfr(codelists, function(codelist, nm) {
    desc <- codelist$Name[[1]]
    purrr::map_dfr(codelist, ~c(local_id = nm, desc = desc, code = attr(., "id"), label = .$Name))
  })
  codelists <- codelists[!is.na(codelists$code), ]

  components <- purrr::imap_dfr(components, function(x, nm) {
    nm <- tolower(gsub("List", "", nm))
    purrr::map_dfr(x, ~c(
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

  out
}


# Internal ---------------------------------------------------------------------

#' Convert an httr response containing a csv into a df
#'
#' @param r An httr response
#'
#' @return A data.frame
#' @noRd
#' @keywords internal
#'
resp_as_df <- function(r) {
  r <- utils::read.csv(text = rawToChar(httr::content(r)))
  r
}

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
  out <- paste0("https://api.data.abs.gov.au/", paste(path, collapse = "/"))
  if(!is.null(query)) {
    query <- paste(names(query), query, sep = "=")
    out <- paste0(out, "?", paste(query, collapse = "&"))
  }

  out
}


#' Construct a datakey
#'
#' @param datakey A named list matching variables to codes
#' @param datastructure A datastructure retrieved with `abs_datastructure()`
#'
#' @return A datakey string
#' @noRd
#' @keywords internal
#'
#' @examples
#' z <- abs_datastructure("ERP_COB")
#' abs_api_match_key(list(SEX=1:3, REGION="AUS"), z)
#' abs_api_match_key(list(SEX=1:10, REGION="AUS"), z)
#' try(abs_api_match_key(list(SX=1:3, REGION="AUS"), z))
#' try(abs_api_match_key(list(UNIT_MEASURE="AUD", REGION="AUS"), z))
abs_api_match_key <- function(datakey, datastructure) {
  stopifnot("`datakey` must be a named list" = is.list(datakey))
  stopifnot("`datakey` must be a named list" = length(names(datakey))==length(datakey))

  bad_vars <- setdiff(names(datakey), datastructure$var)
  if (length(bad_vars) > 0) {
    stop(call. = FALSE,
         "Variable(s) `", paste(bad_vars, collapse = "`, `"),
         "` not found. Please review the datastructure with `abs_datastructure()`"
    )
  }

  key <- purrr::imap_dfr(datakey, function(vals, var) {
    ds <- datastructure[datastructure$var %in% var, ]

    bad_vals <- setdiff(vals, ds$code)
    if (length(bad_vals) > 0) {
      if (length(bad_vals)>5) bad_vals <- c(bad_vals[1:5], "...")
      warning(call. = FALSE,
              "Variable `", var, "` does not contain codes: ",
              paste(bad_vals, collapse=", ")
      )
    }

    if (any(is.na(ds$position))) {
      stop(call. = FALSE,
           "Cannot filter on `", var,
           "`. Please review the datastructure with `abs_datastructure()`"
      )
    }

    ds[ds$code %in% vals, ]
  })


  pos <- unique(datastructure$position)
  pos <- sort(pos[!is.na(pos)])

  key <- purrr::map_chr(pos, function(pos) {
    keyvals <- key[key$position == pos, ]
    paste0(paste(keyvals$code, collapse = "+"), ".")
  })

  paste(key, collapse = "")
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

