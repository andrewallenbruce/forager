source(here::here("data-raw", "pins_functions.R"))
library(tidyverse)
library(clock)

healthr <- healthyR.data::healthyR_data |>
  reframe(
    pid = mrn,
    dos = as_date(visit_end_date_time),
    dos = add_years(dos, 4, invalid = "previous"),
    balance = total_amount_due,
    closed = if_else(balance == 0, TRUE, FALSE),
    dos = case_when(
      year(dos) < 2015 & !closed ~ add_years(dos, 8, invalid = "previous"),
      year(dos) < 2016 & !closed ~ add_years(dos, 7, invalid = "previous"),
      year(dos) < 2017 & !closed ~ add_years(dos, 6, invalid = "previous"),
      year(dos) < 2018 & !closed ~ add_years(dos, 5, invalid = "previous"),
      year(dos) < 2019 & !closed ~ add_years(dos, 4, invalid = "previous"),
      year(dos) < 2020 & !closed ~ add_years(dos, 3, invalid = "previous"),
      year(dos) < 2021 & !closed ~ add_years(dos, 2, invalid = "previous"),
      dos >= date_today("") ~ add_years(dos, -1, invalid = "previous"),
      .default = dos
    ),
    charges = total_charge_amount,
    adjustment = total_adjustment_amount,
    payment = total_payment_amount,
    payer = payer_grouping,
    payer = case_match(
      payer,
        "Medicare A" ~ "Medicare Part A",
        "Medicaid HMO" ~ "Anthem",
        "Medicare B" ~ "Medicare Part B",
        "Medicare HMO" ~ "Aetna",
        "HMO" ~ "Humana",
        "Self Pay" ~ "Patient",
        "Compensation" ~ "Worker's Comp",
        "Exchange Plans" ~ "Medicare Advantage",
        c("No Fault", "?") ~ "Commercial",
      .default = payer
    ),
    payer = as_factor(payer),
  ) |>
  arrange(pid) |>
  group_by(pid) |>
  mutate(visit = row_number(),
         .after = pid
         ) |>
  ungroup() |>
  arrange(dos) |>
  select(
    pid,
    visit,
    dos,
    payer,
    charges,
    adjustment,
    payment,
    balance,
    closed
    )

pin_update(
  healthr,
  name = "healthyr",
  title = "HealthyR Example",
  description = "HealthyR Example"
)


healthr |>
  filter(closed) |>
  group_by(year = year(dos)) |>
  summarise(n = n())

# Oldest open accounts:
# 2021: 2,384
# 2022: 14,600
# 2023: 6,122
# 2024: 1,102
# Total: 24,208
healthr |>
  filter(!closed) |>
  group_by(year = year(dos)) |>
  summarise(n = n())


# Try to add close date to closed accounts
healthr |>
  mutate(
    date_recon = if_else(closed, add_months(dos, 3, invalid = "previous"), NA),
    date_recon = case_when(date_recon >= date_today("") ~ add_years(dos, -1, invalid = "previous")),
    days_in_ar = if_else(closed, as.integer(date_recon - dos), NA)
  ) |>
  fuimus::count_days(
    start = dos,
    end = today,
    name = "days"
  ) |>
  arrange(desc(dos)) |>
  filter(closed == FALSE) |>
  group_by(year = year(dos)) |>
  count(payer) |>
  print(n = 200)
