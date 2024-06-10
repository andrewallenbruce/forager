#' Generate mock coding/billing data frame
#'
#' @param rows `[integerish]` rows number of rows to generate; default is `100`
#'
#' @param payers `[character]` vector of payer names; default is `payer_names()`
#'
#' @param count_days `[logical]` add columns for days between events; default is `FALSE`
#'
#' @param ... `[dots]` additional arguments
#'
#' @returns A [tibble][tibble::tibble-package]
#'
#' @examples
#' mock_claims(rows = 5)
#'
#' @autoglobal
#'
#' @export
mock_claims <- function(rows = 100, payers = payer_names(), count_days = FALSE, ...) {

  # df$column <- sample(c("A", "B", "C"), nrow(relig_income), replace = TRUE)

  rsmpl <- sample(1:rows, size = (75 * rows / 100))

  df <- dplyr::tibble(
    claimid             = wakefield::id(n = rows),
    payer               = forcats::as_factor(fixtuRes::set_vector(size = rows, set = payers)),
    charges             = as.double(wakefield::income(n = rows, digits = 2) / 300),
    age                 = as.double(wakefield::age(n = rows, x = 15:100)),
    date_service        = clock::date_today("") - age,
    date_release        = date_service + stats::rpois(rows, 1:15),
    date_submission     = date_release + stats::rpois(rows, 1:5),
    date_acceptance     = date_submission + stats::rpois(rows, 5:10),
    date_adjudication   = date_acceptance + stats::rpois(rows, 10:20),
    date_reconciliation = date_adjudication + stats::rpois(rows, 1:5)
  ) |>
    dplyr::mutate(
      age                 = NULL,
      balance             = charges,
      balance             = dplyr::if_else(date_adjudication == date_reconciliation, 0, balance),
      date_reconciliation = dplyr::if_else(lubridate::year(date_service) == max(lubridate::year(date_service)) & balance > 0 & dplyr::row_number(date_reconciliation) %in% rsmpl, NA, date_reconciliation),
      balance             = dplyr::if_else(!is.na(date_reconciliation), 0, balance),
      .after              = charges
    ) |>
    dplyr::arrange(
      dplyr::desc(
        date_service
        )
      )

  if (count_days) {

    df <- df |>
      dplyr::mutate(
        days_release        = as.integer(date_release - date_service),
        days_submission     = as.integer(date_submission - date_release),
        days_acceptance     = as.integer(date_acceptance - date_submission),
        days_adjudication   = as.integer(date_adjudication  - date_acceptance),
        days_reconciliation = as.integer(date_reconciliation  - date_adjudication),
        days_in_ar          = dplyr::if_else(
          is.na(date_reconciliation),
          as.integer(date_adjudication - date_service),
          as.integer(date_reconciliation - date_service)
        )
      )
  }
  return(.add_class(df))
}

#' Generate Mock PARBx data
#'
#' @param payers `[character]` vector of payer names
#'
#' @param ... `[dots]` additional arguments
#'
#' @return A [tibble][tibble::tibble-package]
#'
#' @examples
#' # Every payer name generates 60 rows of data
#' mock_parbx()
#'
#' @autoglobal
#'
#' @export
mock_parbx <- function(payers = payer_names(), ...) {

  purrr::map_dfr(payers, parbx_ex_) |>
    dplyr::mutate(
      aging_bin = suppressWarnings(factor(
        aging_bin,
        levels = c("0-30", "31-60", "61-90", "91-120", "121+"),
        ordered = TRUE)
      )
    ) |>
    .add_class()
}

#' @autoglobal
#'
#' @noRd
parbx_ex_ <- function(payers, ...) {

  dplyr::tibble(
    date = vctrs::vec_rep_each(
      clock::date_build(
        2024,
        1:12,
        invalid = "previous"),
      times = 5),
    month = clock::date_month_factor(date),
    payer = payers,
    aging_bin = vctrs::vec_rep(
      c("0-30", "31-60", "61-90", "91-120", "121+"),
      times = 12)
    ) |>
    dplyr::group_by(month) |>
    dplyr::mutate(
      aging_prop = vctrs::vec_rep(
        wakefield::probs(5),
        times = 1)
      ) |>
    dplyr::ungroup()
}


#' @autoglobal
#'
#' @noRd
payer_names <- function() {
  c(
    "Medicare",
    "Medicaid",
    "Kaiser Permanente",
    "Elevance Health (Anthem)",
    "HCSC (Health Care Service Corp)",
    "UnitedHealth",
    "Centene",
    "CVS Health (Aetna)",
    "Humana",
    "Cigna Health",
    "Molina Healthcare",
    "GuideWell (Florida Blue)",
    "Highmark",
    "BCBS Michigan",
    "University Health Care",
    "BCBS Wyoming",
    "Bright Healthcare of Texas",
    "Oscar Insurance Company",
    "Wellcare, Inc.",
    "Omaha Supplemental",
    "Athene Annuity and Life",
    "American General",
    "Massachusetts Mutual Life",
    "New York Life",
    "Lincoln National",
    "Equitable Financial",
    "Allianz Insurance"
  )
}
