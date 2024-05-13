source(here::here("data-raw", "pins_functions.R"))

library(googlesheets4)
library(tidyverse)
library(janitor)
library(provider)
library(clock)

# Patient Aging Biweekly Report
aging_patient <- tibble(
  date = c(
    date_build(2024, 3, 12),
    date_build(2024, 3, 28),
    date_build(2024, 4, 8),
    date_build(2024, 4, 15),
    date_build(2024, 4, 26),
    date_build(2024, 5, 2)
  ),
  bin_0_30 = c(
    88452.42,
    84384.91,
    56568.36,
    53080.52,
    51767.56,
    49885.46),
  bin_31_60 = c(
    28367.74,
    29028.02,
    28305.13,
    27418.41,
    16049.72,
    17951.76),
  bin_61_90 = c(
    19662.67,
    14178.66,
    12004.71,
    12822.42,
    17589.60,
    12513.82),
  bin_91_120 = c(
    22224.74,
    15808.45,
    11680.13,
    10378.60,
    6307.86,
    8685.47),
  bin_121_plus = c(
    158209.16,
    159144.52,
    148043.08,
    133822.27,
    126928.76,
    125077.03)
) |>
  rowwise() |>
  mutate(total = sum(
    c_across(bin_0_30:bin_121_plus)
  )
) |>
  ungroup()

pin_update(
  aging_patient,
  name = "aging_biweekly",
  title = "Aging Biweekly Example",
  description = "Aging Biweekly Example"
)


aging_patient |>
  transmute(
    date,
    pct_0_30 = bin_0_30 / total,
    pct_31_60 = bin_31_60 / total,
    pct_61_90 = bin_61_90 / total,
    pct_91_120 = bin_91_120 / total,
    pct_121_plus = bin_121_plus / total
  ) |>
  rowwise() |>
  mutate(total = sum(
    c_across(pct_0_30:pct_121_plus)
  )
  ) |>
  ungroup()

# clock::date_count_between(clock::date_parse("2024-03-12"), clock::date_parse("2024-03-28"), "day")
# 16
# clock::date_count_between(clock::date_parse("2024-03-28"), clock::date_parse("2024-04-08"), "day")
# 11
# clock::date_count_between(clock::date_parse("2024-04-08"), clock::date_parse("2024-04-15"), "day")
# 7
# clock::date_count_between(clock::date_parse("2024-04-15"), clock::date_parse("2024-04-26"), "day")
# 11
# clock::date_count_between(clock::date_parse("2024-04-26"), clock::date_parse("2024-05-02"), "day")
# 6
# mean(c(16, 11, 7, 11, 6)) = 10.2
aging_patient |>
  mutate(
    ywd = clock::as_year_week_day(date),
    ywd = factor(ywd, levels = unique(ywd), ordered = TRUE)
  ) |>
  select(-total) |>
  pivot_longer(
    cols = bin_0_30:bin_121_plus,
    names_to = "aging_bin",
    values_to = "amount"
  ) |>
  mutate(
    aging_bin = case_match(
      aging_bin,
      "bin_0_30" ~ "0-30",
      "bin_31_60" ~ "31-60",
      "bin_61_90" ~ "61-90",
      "bin_91_120" ~ "91-120",
      "bin_121_plus" ~ "121+"
    ),
    aging_bin = factor(
      aging_bin,
      levels = c("0-30", "31-60", "61-90", "91-120", "121+"),
      ordered = TRUE)
  )
