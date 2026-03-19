#' Generate mock coding/billing data frame
#' @param rows `<int>` number of rows to generate
#' @param days `<lgl>` add counts of days between events
#' @returns A [tibble][tibble::tibble-package]
#' @examples
#' mock_claims(rows = 100)
#' @autoglobal
#' @export
mock_claims <- function(
  rows = 1000L,
  days = FALSE
) {
  x <- fastplyr::new_tbl(
    id = sample(sprintf(paste0("%0", nchar(rows), "d"), seq_len(rows))),
    payer = cheapr::as_factor(sample(
      PAYER_NAMES,
      size = rows,
      replace = TRUE
    )),
    charges = round(stats::rgamma(rows, 2L) * 20000L, digits = 2L) / 300L,
    date_srv = lubridate::today() -
      lubridate::years(1L) -
      sample(x = 15:89, size = rows, replace = TRUE),
    date_rel = date_srv + floor(stats::rnorm(rows, mean = 9L)),
    date_sub = date_rel + stats::rpois(rows, 1:5),
    date_acc = date_sub + stats::rpois(rows, 5:10),
    date_adj = date_acc + stats::rpois(rows, 10:20),
    date_rec = date_adj + stats::rpois(rows, 1:5)
  )

  ymax <- lubridate::year(x$date_srv) ==
    collapse::fmax(lubridate::year(x$date_srv))

  recs <- seq_along(x$date_rec) %in% sample(seq_len(rows), (75L * rows / 100L))

  x <- collapse::mtt(
    x,
    balance = cheapr::if_else_(date_adj == date_rec, 0L, charges),
    date_rec = cheapr::if_else_(ymax & balance > 0L & recs, NA, date_rec),
    balance = cheapr::if_else_(!cheapr::is_na(date_rec), 0L, balance)) |>
    collapse::roworderv("date_srv", decreasing = TRUE)

  if (days) {
    x <- collapse::mtt(
      x,
      days_rel = as.integer(date_rel - date_srv),
      days_sub = as.integer(date_sub - date_rel),
      days_acc = as.integer(date_acc - date_sub),
      days_adj = as.integer(date_adj - date_acc),
      days_rec = as.integer(date_rec - date_adj),
      days_ar = cheapr::if_else_(
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
      PAYER_NAMES,
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
PAYER_NAMES <- c(
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
