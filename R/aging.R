#' Apply 30-Day Aging Bins
#'
#' @template args-df-default
#'
#' @template args-date-col
#'
#' @param bin_type `<chr>` string specifying the bin type; one of "chop", "cut" or "ivs"
#'
#' @template returns-default
#'
#' @examples
#' binned <- bin_aging(
#'   df = load_ex("aging_ex"),
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
bin_aging <- function(df, date, bin_type = "chop") {

  df <- df |>
    dplyr::mutate(
      dar = clock::date_count_between(
        {{ date }},
        lubridate::today(),
        "day"))

  if (bin_type == "chop") {

  df <- df |>
    dplyr::mutate(
      aging_bin = santoku::chop_width(
        dar,
        30,
        start = 0,
        left = FALSE,
        close_end = FALSE
      )
    )
  }

  # if (bin_type == "ivs") {
  #   start <- seq(0, 120, 30)
  #   end <- start + 30
  #   end[5] <- 1000
  #
  #   df <- df |>
  #     dplyr::mutate(
  #       aging_bin = ivs::iv(start, end)
  #     )
  # }

  return(df)
}
