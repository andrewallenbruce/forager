#' @keywords internal
#'
#' @noRd
parbx_ex <- function() {

  cigna <- dplyr::tibble(
    date = vctrs::vec_rep_each(clock::date_build(2024, 1:12, invalid = "previous"), times = 5),
    month = clock::date_month_factor(date),
    payer = "Cigna",
    aging_bin = vctrs::vec_rep(c("0-30", "31-60", "61-90", "91-120", "121+"), times = 12)) |>
    dplyr::group_by(month) |>
    dplyr::mutate(aging_prop = vctrs::vec_rep(wakefield::probs(5), times = 1)) |>
    dplyr::ungroup()

  humana <- dplyr::tibble(
    date = vctrs::vec_rep_each(clock::date_build(2024, 1:12, invalid = "previous"), times = 5),
    month = clock::date_month_factor(date),
    payer = "Humana",
    aging_bin = vctrs::vec_rep(c("0-30", "31-60", "61-90", "91-120", "121+"), times = 12)) |>
    dplyr::group_by(month) |>
    dplyr::mutate(aging_prop = vctrs::vec_rep(wakefield::probs(5), times = 1)) |>
    dplyr::ungroup()

  uhc <- dplyr::tibble(
    date = vctrs::vec_rep_each(clock::date_build(2024, 1:12, invalid = "previous"), times = 5),
    month = clock::date_month_factor(date),
    payer = "UHC",
    aging_bin = vctrs::vec_rep(c("0-30", "31-60", "61-90", "91-120", "121+"), times = 12)) |>
    dplyr::group_by(month) |>
    dplyr::mutate(aging_prop = vctrs::vec_rep(wakefield::probs(5), times = 1)) |>
    dplyr::ungroup()

  anthem <- dplyr::tibble(
    date = vctrs::vec_rep_each(clock::date_build(2024, 1:12, invalid = "previous"), times = 5),
    month = clock::date_month_factor(date),
    payer = "Anthem",
    aging_bin = vctrs::vec_rep(c("0-30", "31-60", "61-90", "91-120", "121+"), times = 12)) |>
    dplyr::group_by(month) |>
    dplyr::mutate(aging_prop = vctrs::vec_rep(wakefield::probs(5), times = 1)) |>
    dplyr::ungroup()

  bcbcs <- dplyr::tibble(
    date = vctrs::vec_rep_each(clock::date_build(2024, 1:12, invalid = "previous"), times = 5),
    month = clock::date_month_factor(date),
    payer = "BCBS",
    aging_bin = vctrs::vec_rep(c("0-30", "31-60", "61-90", "91-120", "121+"), times = 12)) |>
    dplyr::group_by(month) |>
    dplyr::mutate(aging_prop = vctrs::vec_rep(wakefield::probs(5), times = 1)) |>
    dplyr::ungroup()

  vctrs::vec_rbind(
    cigna,
    humana,
    uhc,
    anthem,
    bcbcs) |>
    dplyr::mutate(
      aging_bin = suppressWarnings(factor(
        aging_bin,
        levels = c("0-30", "31-60", "61-90", "91-120", "121+"),
        ordered = TRUE)
      )
    ) |>
    .add_class()
}
