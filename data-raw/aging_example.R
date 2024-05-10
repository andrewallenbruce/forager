source(here::here("data-raw", "pins_functions.R"))

library(googlesheets4)
library(tidyverse)
library(janitor)

aging <- read_sheet("1Td3_6sYOEVwSOdaWdBeUl8yLUp7ztFu8tesZ6LcLlv4") |>
  clean_names() |>
  mutate(
    dos = make_date(
    year = year(dos) + 2,
    month = month(dos),
    day = day(dos)),
    location = case_match(
      location,
      "Houston" ~ "HOU",
      "Indianapolis" ~ "IND",
      "Jacksonville" ~ "JXX",
      "Tennessee" ~ "TEN"
    )
  ) |>
  select(
    # patient,
    dos,
    charges            = amt,
    ins_name           = payer,
    ins_class          = payer_type,
    referring_provider = referring_phys,
    rendering_provider = provider,
    # office_state       = state,
    practice_location    = location,
  ) |>
  mutate(
    age_days = clock::date_count_between(dos, today(), "day"),
    dos = if_else(age_days < 0, dos - (age_days * -1) - 1, dos),
    age_days = NULL
    )

# A tibble: 2,618 × 7

pin_update(
  aging,
  name = "aging_ex",
  title = "Aging Example No. 1",
  description = "Aging Example No. 1"
)

# [0, 1] means all numbers between 0 and 1 inclusive.
# (0, 1) means all numbers strictly between 0 and 1, not including the endpoints.
# [0, 1) means all numbers between 0 and 1, including 0 but not 1.
# (0, 1] means all numbers between 0 and 1, including 1 but not 0.
# {0} means just the number 0.

binned <- aging |>
  mutate(
    days_in_ar = clock::date_count_between(dos, lubridate::today(), "day"),
    aging_bin = santoku::chop_width(days_in_ar, 30, start = 0, left = FALSE, close_end = FALSE)
    )

binned |>
  dplyr::arrange(aging_bin) |>
  dplyr::summarise(
    n_claims = dplyr::n(),
    balance = sum(charges),
    .by = c(aging_bin, ins_name))


dplyr::tribble(
  ~start, ~end,
  0,     30,
  30,     60,
  60,     90,
  90,    120,
  120,    150,
  150,    180,
  180,    210
) |>
  dplyr::mutate(
    aging_bin = ivs::iv(start, end),
    .keep = "unused"
  )

ranges |>
  dplyr::arrange(start) |>
  dplyr::mutate(range = ivs::iv(start, end), .keep = "unused")


start <- vctrs::vec_c(0, 30, 60, 90, 120, 150, 180, 210)
end <- start + 30

bin_aging(load_ex(), dos)

start <- seq(0, 120, 30)
end <- start + 30
end[5] <- 1000

dplyr::tibble(aging_bin = ivs::iv(start, end))

ivs::iv(120, 1000)
