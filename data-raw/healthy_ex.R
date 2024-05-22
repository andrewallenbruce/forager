library(tidyverse)
library(clock)

healthr <- healthyR.data::healthyR_data |>
  reframe(
    pid = mrn,
    dos = as_date(visit_end_date_time),
    visit_end_date_time = NULL,
    payer = payer_grouping,
    charges = total_charge_amount,
    adjustment = total_adjustment_amount,
    payment = total_payment_amount,
    balance = total_amount_due
  ) |>
  #------ If you alter the years, you'll
  # have to redo this visit calculation:
  arrange(pid) |>
  group_by(pid) |>
  mutate(
    visit = row_number(),
    .after = pid
    ) |>
  ungroup() |>
  arrange(dos) |>
  #------ End
  mutate(
    payer = case_match(
      payer,
      # "Blue Cross"
      # "Medicaid"
      # "Commercial"
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
    payer = as_factor(payer))

healthr |>
  mutate(
    dos = add_years(dos, 4, invalid = "previous"),
    closed = if_else(balance == 0, TRUE, FALSE),
    dos = case_when(
      year(dos) < 2015 & !closed ~ add_years(dos, 8, invalid = "previous"),
      year(dos) < 2016 & !closed ~ add_years(dos, 7, invalid = "previous"),
      year(dos) < 2017 & !closed ~ add_years(dos, 6, invalid = "previous"),
      year(dos) < 2018 & !closed ~ add_years(dos, 5, invalid = "previous"),
      year(dos) < 2019 & !closed ~ add_years(dos, 4, invalid = "previous"),
      year(dos) < 2020 & !closed ~ add_years(dos, 3, invalid = "previous"),
      year(dos) < 2021 & !closed ~ add_years(dos, 2, invalid = "previous"),
      dos >= clock::date_today("") ~ add_years(dos, -1, invalid = "previous"),
      .default = dos
    ),
    date_recon = if_else(closed, add_months(dos, 3, invalid = "previous"), NA),
    date_recon = case_when(
      date_recon >= clock::date_today("") ~ add_years(dos, -1, invalid = "previous")),
    days_in_ar = if_else(closed, as.integer(date_recon - dos), NA)
  ) |>
  fuimus::count_days(
    start = dos,
    end = today,
    name = "days"
  ) |>
  dplyr::arrange(dplyr::desc(dos))

  filter(closed == FALSE) |>
  group_by(year = year(dos)) |>
  count(payer) |>
  print(n = 200)

sample(c(30:60), 1)
# if balance == 0, stop counting days

rpois(1, 30:90)
