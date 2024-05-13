source(here::here("data-raw", "pins_functions.R"))

library(googlesheets4)
library(tidyverse)
library(janitor)
library(provider)
library(clock)

# Combined Aging Monthly
aging_monthly <- tibble(
  date = c(
    date_build(2023, 12),
    date_build(2024, 1:5)
  ),
  total = c(
    1132783.09,
    942482.25,
    949739.89,
    985444.69,
    888797.41,
    808376.95
  )) |>
  mutate(
    mon = month(date, label = TRUE),
    change_abs = provider:::chg(total),
    change_pct = provider:::pct(total),
  ) |>
  mutate(
    across(
      ends_with("_pct"), ~ .x + 1,
      .names = "{.col}_ror"
    )
  ) |>
  select(
    date,
    mon,
    total,
    change_abs,
    change_pct,
    change_ror = change_pct_ror
  )

pin_update(
  aging_monthly,
  name = "aging_monthly",
  title = "Aging Monthly Example",
  description = "Aging Monthly Example"
)
