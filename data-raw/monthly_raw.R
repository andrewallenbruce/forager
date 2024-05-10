source(here::here("data-raw", "pins_functions.R"))

library(googlesheets4)
library(tidyverse)
library(janitor)

monthly_raw <- dplyr::tibble(
  date = (c(seq(
    as.Date("2024-01-01"),
    by = "month",
    length.out = 12
  ))
  ),
  gross_charges = c(
    325982, 297731.74, 198655.14,
    186047, 123654, 131440.28,
    153991, 156975, 146878.12,
    163799.44, 151410.74, 169094.46
  ),
  ending_ar = c(
    288432.52, 307871.08, 253976.56,
    183684.90, 204227.59, 203460.47,
    182771.32, 169633.64, 179347.72,
    178051.11, 162757.49, 199849.30
  ),
  net_payment = c(
    104181.64, 124548.88, 119445.53,
    71756.18, 50112.23, 65715.41,
    85245.91, 68055.25, 73669.21,
    81422.37, 78436.27, 69030.83
  ),
  adjustments = c(
    170173.76, 153744.3, 133104.13,
    84582.48, 52999.08, 66491.99,
    89434.24, 102057.43, 63494.83,
    83673.68, 88268.09, 62971.82
  ),
  point_of_service = c(
    16012.80, 16304.75, 10844.50,
    1824.07, 6240.95, 7376.63,
    9155.36, 9740.75, 8602.64,
    8599.35, 7348.15, 10461.59
  ),
  avg_days_to_bill = c(
    5.33, 8.08, 6.07,
    3.76, 2.61, 2.77,
    3.43, 3.36, 2.54,
    2.63, 3.26, 3.4
  ),
  patients_encounters = c(
    1568, 1473, 1031,
    553, 713, 723,
    813, 798, 787,
    851, 762, 834
  ),
  patients_unique = c(
    1204, 1162, 758,
    428, 609, 578,
    636, 658, 624,
    702, 565, 670
  ),
  patients_new = c(
    129, 120, 61,
    32, 123, 77,
    93, 76, 65,
    61, 61, 95
  ),
  em_visits = c(
    1184, 1130, 813,
    427, 550, 572,
    599, 615, 597,
    617, 487, 662
  ),
  rvu_total = c(
    1564.5, 1474.35, 995.6,
    517.34, 739.5, 754.64,
    863.41, 835.53, 826.4,
    875.49, 814.78, 911.65
  )
)

# |>
#   dplyr::mutate(
#     earb_abs = ending_ar - dplyr::lag(ending_ar, order_by = date),
#     earb_rel = earb_abs / dplyr::lag(ending_ar, order_by = date),
#     earb_abs = dplyr::coalesce(earb_abs, 0),
#     earb_rel = dplyr::coalesce(earb_rel, 0),
#     earb_rel = janitor::round_half_up(earb_rel, digits = 5)
#   )

pin_update(
  monthly_raw,
  name = "monthly_raw",
  title = "Raw Monthly Data",
  description = "Raw Monthly Data"
)
