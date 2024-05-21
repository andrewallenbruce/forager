healthr <- healthyR.data::healthyR_data |>
  mutate(
    date_of_service = as_date(visit_end_date_time),
    visit_end_date_time = NULL
  ) |>
  select(
    patient_id = mrn,
    date_of_service,
    payer = payer_grouping,
    charges = total_charge_amount,
    adjustment = total_adjustment_amount,
    payment = total_payment_amount,
    balance = total_amount_due
  ) |>
  arrange(patient_id) |>
  group_by(patient_id) |>
  mutate(visit = row_number(),
         .after = patient_id) |>
  ungroup() |>
  arrange(date_of_service) |>
  mutate(
    payer = case_match(
      payer,
      "Medicare A" ~ "Medicare Part A",
      "Medicaid HMO" ~ "Anthem",
      # "Blue Cross"
      "Medicare B" ~ "Medicare Part B",
      "Medicare HMO" ~ "Aetna",
      "HMO" ~ "Humana",
      # "Medicaid"
      # "Commercial"
      "Self Pay" ~ "Patient",
      "Compensation" ~ "Worker's Comp",
      "Exchange Plans" ~ "Medicare Advantage",
      c("No Fault", "?") ~ "Commercial",
      .default = payer
    ),
    payer = forcats::as_factor(payer))

healthr |>
  mutate(
    date_of_service = add_years(date_of_service, 4, invalid = "previous"),
    closed = if_else(balance == 0, TRUE, FALSE),
    date_of_service = case_when(
      year(date_of_service) < 2015 & !closed ~ add_years(date_of_service, 8, invalid = "previous"),
      year(date_of_service) < 2016 & !closed ~ add_years(date_of_service, 7, invalid = "previous"),
      year(date_of_service) < 2017 & !closed ~ add_years(date_of_service, 6, invalid = "previous"),
      year(date_of_service) < 2018 & !closed ~ add_years(date_of_service, 5, invalid = "previous"),
      year(date_of_service) < 2019 & !closed ~ add_years(date_of_service, 4, invalid = "previous"),
      year(date_of_service) < 2020 & !closed ~ add_years(date_of_service, 3, invalid = "previous"),
      year(date_of_service) < 2021 & !closed ~ add_years(date_of_service, 2, invalid = "previous"),
      TRUE ~ date_of_service
    ),
    date_of_reconciliation = if_else(closed, add_months(date_of_service, 3, invalid = "previous"), NA_Date_),
    days_in_ar = if_else(closed, as.integer(date_of_reconciliation - date_of_service), NA_integer_),
    today = clock::date_today("")
         ) |>
  count_days(start = date_of_service, end = today, name = "days") |>
  filter(closed == FALSE) |>
  group_by(year = year(date_of_service)) |>
  count(payer) |>
  print(n = 200)

sample(c(30:60), 1)
# if balance == 0, stop counting days

rpois(1, 30:90)
