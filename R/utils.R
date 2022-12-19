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
  x <- tibble::tibble(
    claim_id = wakefield::id(n = rows),
    date_of_service = wakefield::date_stamp(n = rows,
                      start = lubridate::today() - lubridate::dyears(2),
                      random = TRUE),
    payer = fixtuRes::set_vector(rows,
            set = c("Medicare", "Medicaid", "Cigna", "Humana",
                    "UnitedHealth", "Anthem", "BCBS", "Centene")),
    ins_class = fixtuRes::set_vector(rows, set = c("Primary", "Secondary")),
    balance = wakefield::income(n = rows, digits = 2) / 300) |>
    dplyr::mutate(date_of_service = lubridate::as_date(date_of_service),
    date_of_release = date_of_service + round(abs(rnorm(length(date_of_service), 11, 4))),
    date_of_submission = date_of_release + round(abs(rnorm(length(date_of_release), 2, 2))),
    date_of_acceptance = date_of_submission + round(abs(rnorm(length(date_of_submission), 3, 2))),
    date_of_adjudication = date_of_acceptance + round(abs(rnorm(length(date_of_acceptance), 30, 3))))

  x |> tidyr::nest(dates = tidyr::contains("date"))
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
#' tidyr::unnest(dates) |>
#' count_days(date_of_service, date_of_release, provider_lag)
count_days <- function(df, start, end, name) {
  df |>
    dplyr::mutate({{ name }} := clock::date_count_between({{ start }},
                                {{ end }}, "day"), .after = {{ end }})
}

#' Calculate Number of Days Between Two Dates
#'
#' @note This calculation includes the end date in the sum (see example)
#'
#' @param df data frame containing date columns
#' @param start column containing date(s) prior to end_date column
#' @param end column containing date(s) after start_date column
#' @param colname desired column name of output; default is "age"
#' @return A [tibble][tibble::tibble-package] with a named column
#'    containing the calculated number of days.
#'
#' @examples
#' date_ex <- tibble::tibble(x = seq.Date(as.Date("2021-01-01"),
#'                           by = "month", length.out = 3),
#'                           y = seq.Date(as.Date("2022-01-01"),
#'                           by = "month", length.out = 3))
#'
#' age_days(df = date_ex,
#'          start = x,
#'          end = y)
#'
#' date_ex |>
#' age_days(x,
#'          y,
#'          colname = "days_between_x_y")
#'
#' date_ex |>
#' age_days(start = x,
#' end = lubridate::today(),
#' colname = "days_since_x")
#'
#' date_ex |>
#' age_days(x, y, "days_between_x_y") |>
#' age_days(x, lubridate::today(), "days_since_x") |>
#' age_days(y, lubridate::today(), colname = "days_since_y")
#' @autoglobal
#' @keyword internal
#' @export
age_days <- function(df,
                     start,
                     end,
                     colname = "age") {

  stopifnot(inherits(df, "data.frame"))

  results <- df |>
    dplyr::mutate(start = as.Date({{ start }}, "%yyyy-%mm-%dd", tz = "EST"),
                  end = as.Date({{ end }}, "%yyyy-%mm-%dd", tz = "EST")) |>
    dplyr::mutate("{colname}" := ((as.numeric(lubridate::days(end) - lubridate::days(start), "hours") / 24) + 1)) |>
    dplyr::select(!c(end, start))

  return(results)
}
