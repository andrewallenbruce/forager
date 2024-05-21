library(googlesheets4)
library(tidyverse)
library(janitor)
library(provider)
library(clock)

pt_aging <- read_sheet("1F2bl8z77yNoorLxp5HerqzJnS7AwaDXxQDJsnzr_0kI", sheet = "PatientAging_20240312") |>
  clean_names() |>
  mutate(
    date_of_birth = as.Date(date_of_birth),
    initial_bill_date = as.Date(initial_bill_date),
    last_bill_date = as.Date(last_bill_date),
    last_patient_payment = as.Date(last_patient_payment),
    date_report = as.Date("2024-03-12"),
    days_bill_last = as.numeric(date_report - last_bill_date),
    days_ptpmt_last = as.numeric(date_report - last_patient_payment)
    ) |>
  unnest_longer(last_payment_amount, indices_include = FALSE) |>
  separate_wider_delim(
    cols = patient_name,
    delim = ", ",
    names = c("last_name", "first_name"),
    too_few = "align_start") |>
  select(
    pid,
    last = last_name,
    first = first_name,
    dob = date_of_birth,
    class,
    date_bill_init = initial_bill_date,
    days_bill_init = average_days,
    date_bill_last = last_bill_date,
    days_bill_last,
    date_ptpmt_last = last_patient_payment,
    days_ptpmt_last,
    ptpmt_last_amt = last_payment_amount,
    prim_ins = primary_insurance,
    prim_cls = primary_ins_class,
    sec_ins = secondary_insurance,,
    sec_cls = secondary_ins_class,,
    age_0_30 = x0_to_30,
    age_31_60 = x31_to_60,
    age_61_90 = x61_to_90,
    age_91_120 = x91_to_120,
    age_121 = x121,
    aging_total = total,
    dis_stm = disabled_statements
  )

bottom_totals <- pt_aging |>
  filter(is.na(pid)) |>
  remove_empty()

bottom_totals |>
  pivot_longer(
    cols = c(age_0_30:age_121),
    names_to = "age_bucket",
    values_to = "count"
  )

pt_aging <- pt_aging |>
  filter(!is.na(pid))


# 4 Encounters: 121+ bucket,
# Patients with disabled statements,
# billed at most ~3 times,
# sitting on aging for around 450 days
# dollar amount = $710.00
pt_aging |>
  filter(dis_stm == "YES") |>
  filter(days_bill_init > 0)

pt_aging |>
  filter(!is.na(age_121), !is.na(date_ptpmt_last)) |>
  arrange(desc(date_ptpmt_last))
