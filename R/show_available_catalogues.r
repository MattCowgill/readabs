show_available_catalogues <- function(selected_heading = NULL){

  if(!is.null(selected_heading)) {
    available_catalogues <-   filter(abs_lookup_table, heading == selected_heading)
  } else { available_catalogues  <- abs_lookup_table}

  available_catalogues <- pull(available_catalogues, catalogue)

  return(available_catalogues)

}



