source(here::here("data-raw", "pins_functions.R"))

library(tidyverse)

# CPPM pg. 60 Revenue Projection

dplyr::tribble(
  ~index, ~revenue, ~expense_variable,  ~expense_fixed,
  1L,     350000,   122500,             350000,
  2L,     538500,   188500,             350000,
  3L,     700000,   245000,             350000,
  4L,     850000,   297500,             350000,
) |>
  dplyr::mutate(
    expense_total = expense_variable + expense_fixed,
    profit        = revenue - expense_total
  )

dplyr::tribble(
  ~index, ~revenue, ~expense_fixed,
  1L,     350000,   350000,
  2L,     538500,   350000,
  3L,     700000,   350000,
  4L,     850000,   350000,
) |>
  dplyr::mutate(
    expense_variable = revenue * 0.3500464,
    expense_total    = expense_variable + expense_fixed,
    profit           = revenue - expense_total
  )
