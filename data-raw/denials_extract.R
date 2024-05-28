source(here::here("data-raw", "pins_functions.R"))
library(tidyverse)
library(clock)
library(janitor)
library(readxl)

deny_a <- read_xlsx("D:/medical_ins_large_claims/rcm_kit_ar_aging_denials/Denials Data/DenialsExtract_FacilityA.xlsx") |>
  clean_names() |>
  mutate(period = as_date(period),
         admit_date = as_date(admit_date),
         discharge_date = as_date(discharge_date),
         original_bill_date = as_date(original_bill_date),
         denial_date = anytime::anydate(denial_date),
         account_number = NULL,
         source = NULL
         )

deny_b <- read_xlsx("D:/medical_ins_large_claims/rcm_kit_ar_aging_denials/Denials Data/DenialsExtract_FacilityB.xlsx") |>
  clean_names() |>
  mutate(period = as_date(period),
         admit_date = as_date(admit_date),
         discharge_date = as_date(discharge_date),
         original_bill_date = as_date(original_bill_date),
         denial_date = anytime::anydate(denial_date),
         account_number = NULL,
         source = NULL
  )

denials_extract <- bind_rows(
  deny_a,
  deny_b
)

pin_update(
  denials_extract,
  name = "denials_extract",
  title = "Denials Extract",
  description = "Denials Extract"
)
