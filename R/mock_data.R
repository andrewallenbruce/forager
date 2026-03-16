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
mock_claims <- function(
  rows = 100,
  payers = payer_names(),
  count_days = FALSE,
  ...
) {
  random_id <- \(n) {
    ids <- sprintf(paste0("%0", nchar(n), "d"), seq_len(n))
    sample(x = ids)
  }

  df <- fastplyr::new_tbl(
    claimid = random_id(n = rows),
    payer = cheapr::as_factor(sample(payers, size = rows, replace = TRUE)),
    charges = round(stats::rgamma(rows, 2) * 20000, digits = 2) / 300,
    age = sample(x = 15:89, size = rows, replace = TRUE),
    date_service = clock::date_today("") - age,
    date_release = date_service + floor(stats::rnorm(rows, mean = 9L)),
    date_submission = date_release + stats::rpois(rows, 1:5),
    date_acceptance = date_submission + stats::rpois(rows, 5:10),
    date_adjudication = date_acceptance + stats::rpois(rows, 10:20),
    date_reconciliation = date_adjudication + stats::rpois(rows, 1:5)
  ) |>
    collapse::mtt(
      age = NULL,
      balance = charges,
      balance = cheapr::if_else_(
        date_adjudication == date_reconciliation,
        0L,
        balance
      ),
      date_reconciliation = cheapr::if_else_(
        lubridate::year(date_service) == max(lubridate::year(date_service)) &
          balance > 0L &
          seq_along(date_reconciliation) %in%
            sample(1:rows, size = (75 * rows / 100)),
        NA,
        date_reconciliation
      ),
      balance = cheapr::if_else_(
        !cheapr::is_na(date_reconciliation),
        0L,
        balance
      )
    ) |>
    collapse::roworder(-date_service)

  if (count_days) {
    df <- df |>
      collapse::mtt(
        days_release = as.integer(date_release - date_service),
        days_submission = as.integer(date_submission - date_release),
        days_acceptance = as.integer(date_acceptance - date_submission),
        days_adjudication = as.integer(date_adjudication - date_acceptance),
        days_reconciliation = as.integer(
          date_reconciliation - date_adjudication
        ),
        days_in_ar = cheapr::if_else_(
          cheapr::is_na(date_reconciliation),
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
        ordered = TRUE
      ))
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
        invalid = "previous"
      ),
      times = 5
    ),
    month = clock::date_month_factor(date),
    payer = payers,
    aging_bin = vctrs::vec_rep(
      c("0-30", "31-60", "61-90", "91-120", "121+"),
      times = 12
    )
  ) |>
    dplyr::group_by(month) |>
    dplyr::mutate(
      aging_prop = vctrs::vec_rep(
        wakefield::probs(5),
        times = 1
      )
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
    "Elevance",
    "HCSC",
    "UHC",
    "Centene",
    "Aetna",
    "Humana",
    "Cigna",
    "Molina",
    "GuideWell",
    "Highmark",
    "BCBS",
    "Bright",
    "Oscar",
    "Wellcare",
    "Omaha",
    "Athene",
    "American",
    "Mass Mutual",
    "New York Life",
    "Lincoln",
    "Equitable",
    "Allianz"
  )
}
