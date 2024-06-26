#' Apply 30-Day Aging Bins
#'
#' @template args-df-default
#'
#' @param ndays `<dbl>` column of counts of days elapsed to bin by
#'
#' @param bin_type `<chr>` string specifying the bin type; one of "chop", "cut" or "ivs"
#'
#' @template returns-default
#'
#' @examples
#' mock_claims(100) |>
#'   dplyr::mutate(
#'     dar = dplyr::if_else(
#'       !is.na(date_reconciliation),
#'       as.numeric((date_reconciliation - date_service)),
#'       as.numeric((date_adjudication - date_service))
#'     )
#'   ) |>
#'     bin_aging(dar, "chop") |>
#'     dplyr::summarise(
#'       n_claims = dplyr::n(),
#'       balance = sum(balance, na.rm = TRUE),
#'       .by = c(aging_bin))
#'
#' mock_claims(10)[c(
#'   "date_service",
#'   "charges",
#'   "payer")] |>
#'   days_between(date_service) |>
#'   bin_aging(days_elapsed)
#'
#' load_ex("aging_ex") |>
#'   dplyr::select(dos, charges, ins_name) |>
#'   days_between(dos) |>
#'   bin_aging(days_elapsed) |>
#'   dplyr::arrange(aging_bin) |>
#'   dplyr::group_by(
#'     year = clock::get_year(dos),
#'     month = clock::date_month_factor(dos),
#'   ) |>
#'   janitor::tabyl(ins_name, aging_bin, year)
#'
#' @autoglobal
#'
#' @export
bin_aging <- function(df, ndays, bin_type = c("case", "chop")) {

  bin_type <- match.arg(bin_type)

  if (bin_type == "chop") {

    df <- df |>
      dplyr::mutate(
        aging_bin = santoku::chop_width(
          {{ ndays }},
          30,
          start = 0,
          left = FALSE,
          close_end = FALSE
        )
      )
  }

  if (bin_type == "case") {

    df <- df |>
      dplyr::mutate(
        aging_bin = dplyr::case_when(
          dplyr::between({{ ndays }}, 0, 30) ~ "0-30",
          dplyr::between({{ ndays }}, 31, 60) ~ "31-60",
          dplyr::between({{ ndays }}, 61, 90) ~ "61-90",
          dplyr::between({{ ndays }}, 91, 120) ~ "91-120",
          {{ ndays }} >= 121 ~ "121+"
        ),
        aging_bin = suppressWarnings(
          forcats::fct_relevel(
            aging_bin,
            c("0-30", "31-60", "61-90", "91-120", "121+"),
            after = Inf
          )
        )
      )
  }
  return(df)
}

#' Calculate Number of Days Between Two Dates
#'
#' @template args-df-default
#'
#' @param from `[character]` column of start dates
#'
#' @param to `[character]` column of end dates
#'
#' @template returns-default
#'
#' @examples
#' mock_claims(10)[c(
#'   "date_service",
#'   "charges",
#'   "payer")] |>
#'   days_between(date_service)
#'
#' @autoglobal
#'
#' @export
days_between <- function(df, from, to = NULL) {

  if (is.null(to)) {

    df |>
      dplyr::mutate(
        days_elapsed = clock::date_count_between(
          {{ from }},
          clock::date_today(""),
          "day")
        ) |>
      .add_class()

  } else {

    df |>
      dplyr::mutate(
        days_elapsed = clock::date_count_between(
          {{ from }},
          {{ to }},
          "day")
        ) |>
      .add_class()
    }
}
