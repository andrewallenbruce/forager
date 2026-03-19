#' Apply 30-Day Aging Bins
#'
#' @template args-df-default
#' @param ndays `<dbl>` column of counts of days elapsed to bin by
#' @param bin_type `<chr>` string specifying the bin type; one of "chop", "cut" or "ivs"
#' @template returns-default
#' @examples
#' mock_claims(1000) |>
#'   dplyr::mutate(
#'     dar = dplyr::if_else(
#'       !is.na(date_rec),
#'       as.integer(date_rec - date_srv),
#'       as.integer(date_adj - date_srv)
#'     )
#'   ) |>
#'   bin_aging(dar, "chop") |>
#'   dplyr::summarise(
#'     n_claims = dplyr::n(),
#'     balance = sum(balance, na.rm = TRUE),
#'     .by = c(aging_bin)
#'   )
#'
#' mock_claims(100)[c(
#'   "date_srv",
#'   "charges",
#'   "payer"
#' )] |>
#'   days_between(date_srv) |>
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
#' @autoglobal
#' @export
bin_aging <- function(df, ndays, bin_type = c("case", "chop")) {
  switch(
    match.arg(bin_type),
    chop = dplyr::mutate(
      df,
      aging_bin = santoku::chop_width(
        x = {{ ndays }},
        width = 30L,
        start = 0,
        left = FALSE,
        close_end = FALSE
      )
    ),
    case = dplyr::mutate(
      df,
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
  )
}

#' Calculate Number of Days Between Two Dates
#'
#' @template args-df-default
#' @param from `[character]` column of start dates
#' @param to `[character]` column of end dates
#' @template returns-default
#' @examples
#' mock_claims(100)[c("date_srv", "charges", "payer")] |>
#'   days_between(date_srv)
#' @autoglobal
#' @export
days_between <- function(df, from, to = NULL) {
  if (is.null(to)) {
    return(.add_class(dplyr::mutate(
      df,
      days_elapsed = clock::date_count_between(
        {{ from }},
        clock::date_today(""),
        "day"
      )
    )))
  }
  .add_class(dplyr::mutate(
    df,
    days_elapsed = clock::date_count_between({{ from }}, {{ to }}, "day")
  ))
}
