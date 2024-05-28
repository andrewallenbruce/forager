source(here::here("data-raw", "pins_functions.R"))
library(tidyverse)
library(clock)
library(janitor)
library(readxl)
library(fs)

transaction_a <- fs::dir_map(path = "D:/medical_ins_large_claims/rcm_kit_ar_aging_denials/Transaction Data/Facility A", fun = read_xlsx) |>
  purrr::list_rbind() |>
  clean_names() |>
  mutate(post_date = as_date(post_date),
         facility = "A")

transaction_b <- fs::dir_map(path = "D:/medical_ins_large_claims/rcm_kit_ar_aging_denials/Transaction Data/Facility B", fun = read_xlsx) |>
  purrr::list_rbind() |>
  clean_names() |>
  mutate(post_date = as_date(post_date),
         facility = "B")

transaction_data <- bind_rows(
  transaction_a,
  transaction_b
)

pin_update(
  transaction_data,
  name = "transaction_data",
  title = "Transaction Data",
  description = "Transaction Data"
)
