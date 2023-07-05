#' Download and tidy ABS Job Mobility tables
#'
#' @description Import a tidy tibble of ABS Job Mobility data
#' @param tables Either `"all"` (the default) to import all tables, or a
#' vector of table numbers, such as `1` or `c(2, 4)`.
#' @param path Local directory in which downloaded ABS time series spreadsheets should be stored. By default, 'path' takes the value set in the environment variable "R_READABS_PATH". If this variable is not set, any files downloaded by read_abs() will be stored in a temporary directory (tempdir()).
#' @export
#' @examples
#' \dontrun{
#' # Get all tables from the ABS Job Mobility series
#' read_job_mobility()
#'
#' # Get tables 1 and 2
#' read_job_mobility(c(1, 2))
#' }
#'
read_job_mobility <- function(tables = "all",
                              path = Sys.getenv("R_READABS_PATH",
                                unset = tempdir()
                              )) {
  check_abs_connection()

  raw_job_mob_tbls <- show_available_files("job-mobility")

  job_mob_tbls <- raw_job_mob_tbls %>%
    mutate(base_file_name = tools::file_path_sans_ext(file),
           label = gsub("62230_", "", base_file_name))

  available_tables <- job_mob_tbls %>%
    dplyr::filter(base::substr(.data$label, 1, 5) == "Table")

  if (tables == "all") {
    selected_tables <- available_tables
  } else {
    selected_tables <- available_tables %>%
      dplyr::filter(grepl(
        paste0(tables, collapse = "|"),
        .data$label
      ))
  }

  cubes <- selected_tables$file

  safely_download_cube <-
    purrr::safely(
      .f = download_abs_data_cube
    )

  cube_results <- purrr::map(cubes,
    safely_download_cube,
    catalogue_string = "job-mobility",
    path = path
  )

  cube_results <- purrr::set_names(cube_results, cubes)

  get_result <- function(result_list, name) {
    if (!is.null(result_list$error)) {
      stop("Could not download table ", name)
    }

    result_list$result
  }

  cube_paths <- purrr::map2_chr(
    cube_results,
    cubes,
    get_result
  )


  read_abs_local(filenames = cube_paths)
}
