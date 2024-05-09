#' Apply 30-Day Aging Bins
#'
#' @param df `<data.frame>` or `<tibble>` with a required date column
#'
#' @param date column of `<date>`s
#'
#' @returns a [tibble][tibble::tibble-package]
#'
#' @examples
#' binned <- bin_aging(load_ex(), dos)
#'
#' head(binned)
#'
#' binned |>
#'   dplyr::arrange(aging_bin) |>
#'   dplyr::summarise(
#'   n_claims = dplyr::n(),
#'   balance = sum(charges),
#'   .by = aging_bin)
#'
#' binned |>
#'   dplyr::arrange(aging_bin) |>
#'   dplyr::summarise(
#'   n_claims = dplyr::n(),
#'   balance = sum(charges),
#'   .by = c(aging_bin, ins_name))
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
