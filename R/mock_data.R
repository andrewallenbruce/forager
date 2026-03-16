#' Generate mock coding/billing data frame
#' @param rows `<int>` number of rows to generate
#' @param days `<lgl>` add counts of days between events
#' @returns A [tibble][tibble::tibble-package]
#' @examples
#' mock_claims(rows = 100)
#' @autoglobal
#' @export
mock_claims <- function(
  rows = 1000,
  days = FALSE
) {
  x <- fastplyr::new_tbl(
    id = sample(sprintf(paste0("%0", nchar(rows), "d"), seq_len(rows))),
    payer = cheapr::as_factor(sample(
      payer_names(),
      size = rows,
      replace = TRUE
    )),
    charges = round(stats::rgamma(rows, 2) * 20000, digits = 2) / 300,
    date_srv = lubridate::today() -
      lubridate::years(1) -
      sample(x = 15:89, size = rows, replace = TRUE),
    date_rel = date_srv + floor(stats::rnorm(rows, mean = 9L)),
    date_sub = date_rel + stats::rpois(rows, 1:5),
    date_acc = date_sub + stats::rpois(rows, 5:10),
    date_adj = date_acc + stats::rpois(rows, 10:20),
    date_rec = date_adj + stats::rpois(rows, 1:5)
  )

  x <- collapse::mtt(
    x,
    balance = charges,
    balance = cheapr::if_else_(date_adj == date_rec, 0L, balance),
    date_rec = cheapr::if_else_(
      (lubridate::year(date_srv) == collapse::fmax(lubridate::year(date_srv)) &
        balance > 0L &
        seq_along(date_rec) %in% sample(seq_len(rows), (75 * rows / 100))),
      NA,
      date_rec
    ),
    balance = cheapr::if_else_(!cheapr::is_na(date_rec), 0L, balance)
  ) |>
    collapse::roworder(-date_srv)

  if (days) {
    x <- collapse::mtt(
      x,
      days_rel = as.integer(date_rel - date_srv),
      days_sub = as.integer(date_sub - date_rel),
      days_acc = as.integer(date_acc - date_sub),
      days_adj = as.integer(date_adj - date_acc),
      days_rec = as.integer(date_rec - date_adj),
      days_in_ar = cheapr::if_else_(
        cheapr::is_na(date_rec),
        as.integer(date_adj - date_srv),
        as.integer(date_rec - date_srv)
      )
    )
  }
  return(.add_class(x))
}

#' Generate Mock PARBx data
#' @returns A [tibble][tibble::tibble-package]
#' @examples
#' mock_parbx()
#' @autoglobal
#' @export
mock_parbx <- function() {
  fastplyr::new_tbl(
    date = vctrs::vec_rep_each(
      clock::date_build(
        lubridate::year(lubridate::today()) - 1L,
        1:12,
        invalid = "previous"
      ),
      times = 5L
    ),
    month = clock::date_month_factor(date),
    payer = cheapr::as_factor(sample(
      payer_names(),
      size = 60L,
      replace = TRUE
    )),
    bin = cheapr::factor_(
      vctrs::vec_rep(
        c("0-30", "31-60", "61-90", "91-120", "121+"),
        times = 12
      ),
      levels = c("0-30", "31-60", "61-90", "91-120", "121+"),
      order = TRUE
    )
  ) |>
    fastplyr::f_group_by(month) |>
    fastplyr::f_mutate(aging = vctrs::vec_rep(prob(5), times = 1L)) |>
    fastplyr::f_ungroup() |>
    fastplyr::f_arrange(date, month, bin) |>
    .add_class()
  # fastplyr::f_group_by(payer) |>
  # fastplyr::f_summarise(total = collapse::fsum(aging))
}

#' @noRd
prob <- function(x, upper = 1000000L) {
  x <- sample(seq_len(upper), size = x, replace = TRUE)

  x <- x / collapse::fsum(x)

  if (anyNA(x)) {
    stop("`x` is too large, typically performs best at < 4000")
  }
  x
}

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
    "NY Life",
    "Lincoln",
    "Equitable",
    "Allianz"
  )
}
