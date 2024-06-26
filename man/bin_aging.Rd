% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/aging.R
\name{bin_aging}
\alias{bin_aging}
\title{Apply 30-Day Aging Bins}
\usage{
bin_aging(df, ndays, bin_type = c("case", "chop"))
}
\arguments{
\item{df}{\verb{<data.frame>} or \verb{<tibble>}}

\item{ndays}{\verb{<dbl>} column of counts of days elapsed to bin by}

\item{bin_type}{\verb{<chr>} string specifying the bin type; one of "chop", "cut" or "ivs"}
}
\value{
a \link[tibble:tibble-package]{tibble}
}
\description{
Apply 30-Day Aging Bins
}
\examples{
mock_claims(100) |>
  dplyr::mutate(
    dar = dplyr::if_else(
      !is.na(date_reconciliation),
      as.numeric((date_reconciliation - date_service)),
      as.numeric((date_adjudication - date_service))
    )
  ) |>
    bin_aging(dar, "chop") |>
    dplyr::summarise(
      n_claims = dplyr::n(),
      balance = sum(balance, na.rm = TRUE),
      .by = c(aging_bin))

mock_claims(10)[c(
  "date_service",
  "charges",
  "payer")] |>
  days_between(date_service) |>
  bin_aging(days_elapsed)

load_ex("aging_ex") |>
  dplyr::select(dos, charges, ins_name) |>
  days_between(dos) |>
  bin_aging(days_elapsed) |>
  dplyr::arrange(aging_bin) |>
  dplyr::group_by(
    year = clock::get_year(dos),
    month = clock::date_month_factor(dos),
  ) |>
  janitor::tabyl(ins_name, aging_bin, year)

}
