source(here::here("data-raw", "pins_functions.R"))

library(googlesheets4)
library(tidyverse)
library(janitor)

# https://docs.google.com/spreadsheets/d/1braeEyikhzCMGc9IfNhnBGqqKOTVSU7J/edit#gid=976015322
# Charges * % Paid * (1 - % AR > 120 Days Old)


# https://docs.google.com/spreadsheets/d/1Td3_6sYOEVwSOdaWdBeUl8yLUp7ztFu8tesZ6LcLlv4/edit#gid=0
dplyr::tribble(
  ~date,        ~gross_charges, ~net_payment, ~pct_ar_gt_120_days,
  "2022-01-01", 180000,         77400,         0.21,
  "2022-02-01", 210000,         77700,         0.17,
  "2022-03-01", 177000,         95000,         0.15,
  "2022-04-01", 195000,         97000,         0.01
) |>
  dplyr::mutate(
    date = lubridate::ymd(date),
    pct_ar_lte_120_days = 1 - pct_ar_gt_120_days,
    pct_paid = net_payment / gross_charges,
    net_pred = (gross_charges * pct_paid) * pct_ar_lte_120_days,
    net_lag = dplyr::lag(net_payment, order_by = date))

net_pred <- function(gct_prev,
                     gct_pres,
                     net_prev,
                     parbx_pres) {

  # What percentage of last month's charges paid
  net_pct <- net_prev/gct_prev

  # What percentage of last month's AR is <= 120 days
  parbx_opp <- 1 - parbx_pres

  # Net prediction
  net_pred <- (gct_pres * net_pct) * parbx_opp

  return(net_pred)

}

net_pred(gct_prev = 180000,
         gct_pres = 210000,
         net_prev = 77400,
         parbx_pres = 0.21)



# Needs to be lagged to the next month
dplyr::tibble(
  date = lubridate::ymd("2024-01-01") + months(0:3),
  gross_charges = as.numeric(c(180000, 210000, 177000, 195000)),
  net_payment = as.numeric(c(77400, 77700, 95000, 97000)),
  parbx120 = as.numeric(c(0.21, 0.17, 0.15, 0.1))
)

net_pred_month <- function(df, gct, net, parbx) {

  stopifnot(inherits(df, "data.frame"))

  results <- df |> dplyr::mutate(net_pct = {{ net }} / {{ gct }},
                                 parbx_rev = 1 - {{ parbx }}
  )

  # Net prediction
  net_pred <- (gct_pres * pct_paid) * parbx_opp

  return(net_pred)

}

# Start with Gross Charges
# What percentage of AR is paid each month?
# What percentage of AR > 120 days (parb_120) was actually paid?
# What percentage of each AR bin would you expect to be paid?
load_ex("monthly_raw") |>
  dplyr::select(
    date,
    gct = gross_charges,
    earb = ending_ar,
    net = net_payment,
  ) |>
  dplyr::mutate(
    gct_cum = cumsum(gct),
    earb_next = earb + lag(gct),
    .after = earb
  )
