library(googlesheets4)
library(tidyverse)
library(janitor)
library(clock)

remove_quiet <- function(df) {
  janitor::remove_empty(
    df,
    which = c("rows", "cols"))
}

pt_aging <- read_sheet(
  "1F2bl8z77yNoorLxp5HerqzJnS7AwaDXxQDJsnzr_0kI",
  sheet = "PatientAging_20240312"
  ) |>
  clean_names() |>
  filter(!is.na(pid)) |>
  mutate(
    pid                  = str_remove_all(pid, "REP"),
    pid                  = fuimus::pad_number(pid),
    date_of_birth        = as.Date(date_of_birth),
    initial_bill_date    = as.Date(initial_bill_date),
    last_bill_date       = as.Date(last_bill_date),
    last_patient_payment = as.Date(last_patient_payment),
    date_report          = as.Date("2024-03-12"),
    days_bill_last       = as.integer(date_report - last_bill_date),
    days_pay_last        = as.integer(date_report - last_patient_payment),
    disabled_statements  = if_else(disabled_statements == "YES", TRUE, FALSE)
    ) |>
  unnest_longer(
    last_payment_amount,
    indices_include = FALSE
    ) |>
  separate_wider_delim(
    cols    = patient_name,
    delim   = ", ",
    names   = c("last_name", "first_name"),
    too_few = "align_start"
    ) |>
  select(
    pid,
    class_pid       = class,
    dob             = date_of_birth,
    date_bill_first = initial_bill_date,
    date_bill_last  = last_bill_date,
    date_pay_last   = last_patient_payment,
    days_bill_first = average_days,
    days_bill_last,
    days_pay_last,
    amt_pay_last    = last_payment_amount,
    ins_prim        = primary_insurance,
    class_prim      = primary_ins_class,
    ins_sec         = secondary_insurance,,
    class_sec       = secondary_ins_class,,
    bin_0_30        = x0_to_30,
    bin_31_60       = x31_to_60,
    bin_61_90       = x61_to_90,
    bin_91_120      = x91_to_120,
    bin_121         = x121,
    aging_total     = total,
    disabled_statements
  )

pin_update(
  pt_aging,
  name = "patient_aging",
  title = "Patient Aging Example",
  description = "Patient Aging Example"
)



# bottom_totals <- pt_aging |>
#   filter(is.na(pid)) |>
#   remove_empty()

# bottom_totals |>
#   pivot_longer(
#     cols = c(age_0_30:age_121),
#     names_to = "age_bucket",
#     values_to = "count"
#   )

# pt_aging <- pt_aging |>
#   filter(!is.na(pid))


# 4 Encounters: 121+ bucket,
# Patients with disabled statements,
# billed at most ~3 times,
# sitting on aging for around 450 days
# dollar amount = $710.00
pt_aging |>
  filter(disabled_statements) |>
  filter(days_bill_first > 0) |>
  remove_quiet()

pt_aging |>
  filter(!is.na(bin_121), !is.na(date_pay_last)) |>
  arrange(desc(date_pay_last)) |>
  remove_quiet()
