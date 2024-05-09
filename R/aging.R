#' Apply 30-Day Aging Bins
#'
#' @param df `<data.frame>` or `<tibble>` with a required date column
#'
#' @param date column of `<date>`s
#'
#' @returns a [tibble][tibble::tibble-package]
#'
#' @examples
#' binned <- bin_aging(
#'   df = load_ex(),
#'   date = dos
#' ) |>
#'   dplyr::select(
#'     dos:ins_class,
#'     dar:aging_bin
#'   )
#'
#' head(binned)
#'
#' binned |>
#'   dplyr::arrange(aging_bin) |>
#'   dplyr::summarise(n_claims = dplyr::n(),
#'                    balance = sum(charges),
#'                    .by = aging_bin) |>
#'   dplyr::mutate(
#'     tot_claims = sum(n_claims),
#'     tot_balance = sum(balance),
#'     pct_claims = n_claims / tot_claims,
#'     pct_balance = balance / tot_balance) |>
#'   print(n = 50)
#'
#' binned |>
#'   dplyr::arrange(aging_bin, ins_name) |>
#'   dplyr::summarise(
#'     n_claims = dplyr::n(),
#'     balance = sum(charges),
#'     .by = c(aging_bin, ins_name)
#'   ) |>
#'   dplyr::mutate(
#'     tot_claims = sum(n_claims),
#'     tot_balance = sum(balance),
#'     pct_claims = n_claims / tot_claims,
#'     pct_balance = balance / tot_balance) |>
#'   print(n = 50)
#'
#' binned |>
#'   dplyr::arrange(ins_name, aging_bin) |>
#'   dplyr::summarise(
#'     n_claims = dplyr::n(),
#'     balance = sum(charges),
#'     .by = c(aging_bin, ins_name)
#'   ) |>
#'   dplyr::mutate(
#'     tot_claims = sum(n_claims),
#'     tot_balance = sum(balance),
#'     pct_claims = n_claims / tot_claims,
#'     pct_balance = balance / tot_balance,
#'     .by = ins_name) |>
#'   print(n = 50)
#'
#' @autoglobal
#'
#' @export
bin_aging <- function(df, date) {

  df |>
    dplyr::mutate(
      dar = clock::date_count_between(
        {{ date }},
        lubridate::today(),
        "day"),
      aging_bin = santoku::chop_width(
        dar,
        30,
        start = 0,
        left = FALSE,
        close_end = FALSE
      )
    )
}
