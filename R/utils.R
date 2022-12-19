#' Generate mock coding/billing data frame
#'
#' @param rows number of rows to generate; default is 100
#' @return A [tibble][tibble::tibble-package]
#' @autoglobal
#' @keyword internal
#' @export
#' @examples
#' generate_data(rows = 5)
generate_data <- function(rows = 100){
  tibble::tibble(
    claim_id = wakefield::id(n = rows),
    date_of_service = wakefield::date_stamp(n = rows,
                      start = lubridate::today() - lubridate::dyears(1),
                      random = TRUE),
    payer = fixtuRes::set_vector(rows,
                                 set = c("Medicare", "Medicaid", "Cigna",
                                         "Humana", "UnitedHealth", "Anthem",
                                         "BCBS", "Centene")),
    ins_class = fixtuRes::set_vector(rows, set = c("Primary", "Secondary")),
    balance = wakefield::income(n = rows, digits = 2) / 300) |>
    dplyr::mutate(date_of_service = lubridate::as_date(date_of_service),
    date_of_release = date_of_service + round(abs(rnorm(length(date_of_service), 11, 4))),
    date_of_submission = date_of_release + round(abs(rnorm(length(date_of_service), 2, 2))),
    date_of_acceptance = date_of_submission + round(abs(rnorm(length(date_of_service), 3, 2))),
    date_of_adjudication = date_of_acceptance + round(abs(rnorm(length(date_of_service), 30, 3))))
}

#' Count days between two dates
#'
#' @param df data frame
#' @param start date column
#' @param end date column
#' @param name name of output column
#' @return A [tibble][tibble::tibble-package]
#' @autoglobal
#' @keyword internal
#' @export
#' @examples
#' generate_data(rows = 5) |>
#' count_days(date_of_service, date_of_release, provider_lag)
count_days <- function(df, start, end, name) {
  df |>
    dplyr::mutate({{ name }} := clock::date_count_between({{ start }},
                                {{ end }}, "day"), .after = {{ end }})
}
