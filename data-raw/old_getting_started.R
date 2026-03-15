---
  title: "Getting started"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Getting started}
%\VignetteEngine{knitr::rmarkdown}
%\VignetteEncoding{UTF-8}
---

  ```{r setup, include = FALSE}
knitr::opts_chunk$set(
  collapse  = FALSE,
  echo      = TRUE,
  message   = FALSE,
  warning   = FALSE,
  error     = TRUE,
  comment   = "#>",
  dpi       = 600,
  out.width = "100%"
)
options(scipen = 999)

library(forager)
library(dplyr)
library(tidyr)
library(gt)
library(gtExtras)
library(ggplot2)
library(ggrepel)
library(scales)
```

## Introduction

The `forager` package is a collection of functions that are useful for healthcare revenue cycle analysis.

## Days in Accounts Receivable

```{r}
dar_ex()
```



```{r}
dar_mon <- avg_dar(
  df     = dar_ex(),
  date   = date,
  gct    = gross_charges,
  earb   = ending_ar,
  dart   = 35,
  by = "month"
)

dar_mon
```



```{r}
dar_mon |>
  gt(rowname_col = "date") |>
  fmt_currency(
    columns = c(
      gct,
      earb,
      adc,
      earb_target,
      earb_diff
    )) |>
  fmt_percent(
    columns = c(
      gct_pct,
      earb_pct
    )) |>
  fmt_number(
    columns = c(
      dar,
      dart,
      ratio_actual,
      ratio_ideal,
      ratio_diff
    )) |>
  cols_label(
    date = "Month",
    gct = "Gross Charges",
    earb = "Ending AR",
    adc = "ADC",
    dar_pass = "",
    dar = "DAR"
  ) |>
  opt_stylize()
```


```{r eval=FALSE}
avg_dar(
  df     = dar_ex(),
  date   = date,
  gct    = gross_charges,
  earb   = ending_ar,
  dart   = 39,
  by = "quarter"
) |>
  gt(rowname_col = "nqtr") |>
  fmt_currency(
    columns = c(
      gross_charges,
      ending_ar,
      adc,
      ending_ar_target,
      ending_ar_dec_abs,
      earb_gct_diff
    )
  ) |>
  fmt_percent(columns = c(ending_ar_dec_pct)) |>
  fmt_number(columns = c(dar, dar_diff, ratio_actual, ratio_ideal, ratio_diff)) |>
  cols_move_to_start(
    c(
      nqtr,
      gross_charges,
      ending_ar,
      earb_gct_diff,
      adc,
      dar_pass,
      dar,
      dar_diff,
      ratio_actual,
      ratio_ideal,
      ratio_diff,
      ending_ar_target,
      ending_ar_dec_abs,
      ending_ar_dec_pct
    )
  ) |>
  cols_label(
    gross_charges = "Gross Charges",
    ending_ar = "Ending AR",
    adc = "ADC",
    dar_pass = "",
    dar = "DAR",
    ratio_diff = "AR/GC Diff",
    ending_ar_dec_abs = "AR Decrease Needed",
    ending_ar_dec_pct = "%",
    earb_gct_diff = "AR - GC"
  ) |>
  opt_stylize()
```

## Aging Bins

```{r}
binned <- load_ex("aging_ex") |>
  select(dos:ins_name) |>
  days_between(dos) |>
  bin_aging(days_elapsed)

binned
```

```{r}
binned |>
  arrange(aging_bin) |>
  summarise(n_claims = n(),
            balance = sum(charges),
            .by = aging_bin) |>
  mutate(pct_claims = n_claims / sum(n_claims),
         pct_balance = balance / sum(balance)) |>
  gt(rowname_col = "aging_bin") |>
  fmt_percent(columns = pct_claims:pct_balance, decimals = 0) |>
  fmt_currency(columns = balance, decimals = 0) |>
  fmt_number(columns = n_claims, decimals = 0) |>
  opt_stylize() |>
  cols_label(n_claims = "Claims", balance = "Charges") |>
  cols_move_to_start(c(n_claims, pct_claims, balance, pct_balance)) |>
  cols_merge(c(n_claims, pct_claims), pattern = "{1} ({2})") |>
  cols_merge(c(balance, pct_balance), pattern = "{1} ({2})") |>
  tab_header(title = "Aging Report", ) |>
  tab_options(heading.align = "left",
              quarto.disable_processing = TRUE,
              table.font.size = px(18),
              table.width = pct(75))
```


```{r}
binned |>
  arrange(aging_bin, ins_name) |>
  summarise(
    n_claims = n(),
    balance = sum(charges),
    .by = c(aging_bin, ins_name)
  ) |>
  mutate(pct_claims = n_claims / sum(n_claims),
         pct_balance = balance / sum(balance)) |>
  gt(groupname_col = "aging_bin",
     rowname_col = "ins_name",
     row_group_as_column = TRUE) |>
  fmt_percent(columns = pct_claims:pct_balance) |>
  fmt_currency(columns = balance, decimals = 0) |>
  fmt_number(columns = n_claims, decimals = 0) |>
  cols_label(n_claims = "Claims", balance = "Charges") |>
  cols_merge(c(n_claims, pct_claims), pattern = "{1} ({2})") |>
  cols_merge(c(balance, pct_balance), pattern = "{1} ({2})") |>
  gtExtras::gt_theme_nytimes()
```
