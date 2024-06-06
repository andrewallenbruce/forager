#' Generate Mock PARBx data
#' @param payer `[character]` vector of payer names
#' @param ... `[dots]` additional arguments
#' @return A [tibble][tibble::tibble-package]
#'
#' @keywords internal
#'
#' @examples
#' # Every name generates 60 rows of data
#' parbx_ex(
#'   c("Cigna", "BCBS", "Anthem",
#'     "Humana", "UHC", "Medicare",
#'     "Coventry", "Medicaid", "Centene",
#'     "CVSHealth"))
#'
#' @autoglobal
#' @export
parbx_ex <- function(payer, ...) {

  purrr::map_dfr(payer, parbx_ex_) |>
    dplyr::mutate(
      aging_bin = suppressWarnings(factor(
        aging_bin,
        levels = c("0-30", "31-60", "61-90", "91-120", "121+"),
        ordered = TRUE)
      )
    ) |>
    .add_class()
}

#' @keywords internal
#'
#' @noRd
parbx_ex_ <- function(payer, ...) {

  dplyr::tibble(
    date = vctrs::vec_rep_each(clock::date_build(2024, 1:12, invalid = "previous"), times = 5),
    month = clock::date_month_factor(date),
    payer = payer,
    aging_bin = vctrs::vec_rep(c("0-30", "31-60", "61-90", "91-120", "121+"), times = 12)) |>
    dplyr::group_by(month) |>
    dplyr::mutate(aging_prop = vctrs::vec_rep(wakefield::probs(5), times = 1)) |>
    dplyr::ungroup()
}
