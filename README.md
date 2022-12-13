
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `forager` <a href="https://andrewallenbruce.github.io/forager/"><img src="man/figures/logo.svg" align="right" height="200"/></a>

> ***Forager** (noun)*
>
> *A person that goes from place to place searching for things that they
> can eat or use.*[^1]

> ***Ager** (noun)*
>
> *A person that calls from place to place searching for payment before
> insurance can refuse.*[^2]

<br>

<!-- badges: start -->

[![R-CMD-check](https://github.com/andrewallenbruce/forager/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/andrewallenbruce/forager/actions/workflows/R-CMD-check.yaml)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![repo status:
WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://choosealicense.com/licenses/mit/)
[![code
size](https://img.shields.io/github/languages/code-size/andrewallenbruce/forager.svg)](https://github.com/andrewallenbruce/forager)
[![last
commit](https://img.shields.io/github/last-commit/andrewallenbruce/forager.svg)](https://github.com/andrewallenbruce/forager/commits/master)
[![Codecov test
coverage](https://codecov.io/gh/andrewallenbruce/forager/branch/master/graph/badge.svg)](https://app.codecov.io/gh/andrewallenbruce/forager?branch=master)
<!-- badges: end -->

`forager` is a work-in-progress, the goal of which is to become a suite
of integrated analytics tools focused on a comprehensive overview of a
healthcare organization’s operational and financial performance areas.
Build your own rule-based, automated reporting pipeline to monitor:

- Patient Scheduling
- Coding / Billing
- Productivity
- Collections & A/R
- Denial Management

## Installation

You can install the development version of `forager` from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("andrewallenbruce/forager")

# install.packages("remotes")
remotes::install_github("andrewallenbruce/forager")
```

``` r
library(forager)
```

## Usage

Calculate:

- Provider Lag: Days between Date of Service (`dos`) and Date of Release
  (`dor`)
- Billing Lag: Days between Date of Release (`dor`) and Date of
  Submission (`dtos`)
- Acceptance Lag: Days between Date of Submission (`dtos`) and Date of
  Acceptance (`dtoa`)
- Payment Lag: Days between Date of Acceptance (`dtoa`) and Date of
  Adjudication (`dtad`)
- Days in AR: Days between Date of Release (`dor`) and Date of
  Adjudication (`dtad`)

``` r
x <- tibble::tibble(
  dos = seq(clock::date_build(2021, 1, 1), 
  clock::date_build(2021, 12, 31), by = 1),
  dor = dos + round(abs(rnorm(365, 11, 4))),
  prov_lag = clock::date_count_between(dos, dor, "day"),
  dtos = dor + round(abs(rnorm(365, 2, 2))),
  bill_lag = clock::date_count_between(dor, dtos, "day"),
  dtoa = dtos + round(abs(rnorm(365, 3, 2))),
  accept_lag = clock::date_count_between(dtos, dtoa, "day"),
  dtad = dtoa + round(abs(rnorm(365, 30, 3))),
  pay_lag = clock::date_count_between(dtoa, dtad, "day"),
  days_in_ar = clock::date_count_between(dor, dtad, "day"),
)

x |> head(n = 25) |> gluedown::md_table()
```

| dos        | dor        | prov_lag | dtos       | bill_lag | dtoa       | accept_lag | dtad       | pay_lag | days_in_ar |
|:-----------|:-----------|---------:|:-----------|---------:|:-----------|-----------:|:-----------|--------:|-----------:|
| 2021-01-01 | 2021-01-15 |       14 | 2021-01-19 |        4 | 2021-01-23 |          4 | 2021-02-25 |      33 |         41 |
| 2021-01-02 | 2021-01-18 |       16 | 2021-01-18 |        0 | 2021-01-20 |          2 | 2021-02-20 |      31 |         33 |
| 2021-01-03 | 2021-01-20 |       17 | 2021-01-22 |        2 | 2021-01-25 |          3 | 2021-02-16 |      22 |         27 |
| 2021-01-04 | 2021-01-10 |        6 | 2021-01-10 |        0 | 2021-01-11 |          1 | 2021-02-07 |      27 |         28 |
| 2021-01-05 | 2021-01-20 |       15 | 2021-01-26 |        6 | 2021-01-30 |          4 | 2021-03-01 |      30 |         40 |
| 2021-01-06 | 2021-01-17 |       11 | 2021-01-22 |        5 | 2021-01-26 |          4 | 2021-02-20 |      25 |         34 |
| 2021-01-07 | 2021-01-15 |        8 | 2021-01-18 |        3 | 2021-01-22 |          4 | 2021-02-22 |      31 |         38 |
| 2021-01-08 | 2021-01-18 |       10 | 2021-01-20 |        2 | 2021-01-25 |          5 | 2021-02-21 |      27 |         34 |
| 2021-01-09 | 2021-01-21 |       12 | 2021-01-23 |        2 | 2021-01-26 |          3 | 2021-02-21 |      26 |         31 |
| 2021-01-10 | 2021-01-26 |       16 | 2021-01-31 |        5 | 2021-02-05 |          5 | 2021-03-08 |      31 |         41 |
| 2021-01-11 | 2021-02-02 |       22 | 2021-02-07 |        5 | 2021-02-09 |          2 | 2021-03-12 |      31 |         38 |
| 2021-01-12 | 2021-01-14 |        2 | 2021-01-16 |        2 | 2021-01-19 |          3 | 2021-02-14 |      26 |         31 |
| 2021-01-13 | 2021-01-23 |       10 | 2021-01-28 |        5 | 2021-02-01 |          4 | 2021-03-07 |      34 |         43 |
| 2021-01-14 | 2021-01-25 |       11 | 2021-01-25 |        0 | 2021-01-29 |          4 | 2021-02-24 |      26 |         30 |
| 2021-01-15 | 2021-02-04 |       20 | 2021-02-06 |        2 | 2021-02-09 |          3 | 2021-03-15 |      34 |         39 |
| 2021-01-16 | 2021-01-28 |       12 | 2021-02-02 |        5 | 2021-02-03 |          1 | 2021-03-04 |      29 |         35 |
| 2021-01-17 | 2021-01-18 |        1 | 2021-01-22 |        4 | 2021-01-28 |          6 | 2021-02-28 |      31 |         41 |
| 2021-01-18 | 2021-01-26 |        8 | 2021-01-26 |        0 | 2021-01-30 |          4 | 2021-03-05 |      34 |         38 |
| 2021-01-19 | 2021-02-12 |       24 | 2021-02-16 |        4 | 2021-02-19 |          3 | 2021-03-16 |      25 |         32 |
| 2021-01-20 | 2021-02-03 |       14 | 2021-02-07 |        4 | 2021-02-09 |          2 | 2021-03-10 |      29 |         35 |
| 2021-01-21 | 2021-01-29 |        8 | 2021-01-30 |        1 | 2021-02-02 |          3 | 2021-03-03 |      29 |         33 |
| 2021-01-22 | 2021-02-01 |       10 | 2021-02-04 |        3 | 2021-02-06 |          2 | 2021-03-08 |      30 |         35 |
| 2021-01-23 | 2021-01-26 |        3 | 2021-01-30 |        4 | 2021-02-04 |          5 | 2021-03-05 |      29 |         38 |
| 2021-01-24 | 2021-01-31 |        7 | 2021-02-02 |        2 | 2021-02-05 |          3 | 2021-03-01 |      24 |         29 |
| 2021-01-25 | 2021-01-31 |        6 | 2021-02-03 |        3 | 2021-02-06 |          3 | 2021-03-13 |      35 |         41 |

<br>

``` r
x |> dplyr::group_by(month = clock::date_month_factor(dos)) |> 
     dplyr::summarise(avg_prov_lag = round(mean(prov_lag), 2),
                      avg_bill_lag = round(mean(bill_lag), 2),
                      avg_accept_lag = round(mean(accept_lag), 2),
                      avg_pay_lag = round(mean(pay_lag), 2),
                      avg_dar = round(mean(days_in_ar), 2)) |> 
     gluedown::md_table()
```

| month     | avg_prov_lag | avg_bill_lag | avg_accept_lag | avg_pay_lag | avg_dar |
|:----------|-------------:|-------------:|---------------:|------------:|--------:|
| January   |        11.65 |         2.94 |           3.35 |       29.35 |   35.65 |
| February  |        10.54 |         2.39 |           3.18 |       29.82 |   35.39 |
| March     |        11.45 |         2.42 |           3.32 |       29.35 |   35.10 |
| April     |        11.47 |         2.53 |           2.83 |       30.17 |   35.53 |
| May       |        10.48 |         2.23 |           3.03 |       29.23 |   34.48 |
| June      |        11.50 |         2.03 |           3.43 |       31.00 |   36.47 |
| July      |        10.81 |         2.55 |           3.03 |       29.23 |   34.81 |
| August    |        11.32 |         2.55 |           2.94 |       28.97 |   34.45 |
| September |        10.40 |         2.30 |           3.27 |       29.43 |   35.00 |
| October   |        10.71 |         2.06 |           3.23 |       30.19 |   35.48 |
| November  |        11.77 |         2.43 |           3.10 |       29.20 |   34.73 |
| December  |        11.23 |         1.97 |           2.84 |       30.19 |   35.00 |

## Aging Calculation

``` r
x |> dplyr::select(dos, dor, dtad, days_in_ar) |> 
  dplyr::group_by(month = clock::date_month_factor(dos), 
                  aging_bucket = cut(days_in_ar, breaks = seq(0, 500, 30))) |> 
  dplyr::tally(name = "claims") |> 
  gluedown::md_table()
```

| month     | aging_bucket | claims |
|:----------|:-------------|-------:|
| January   | (0,30\]      |      4 |
| January   | (30,60\]     |     27 |
| February  | (0,30\]      |      2 |
| February  | (30,60\]     |     26 |
| March     | (0,30\]      |      3 |
| March     | (30,60\]     |     28 |
| April     | (0,30\]      |      4 |
| April     | (30,60\]     |     26 |
| May       | (0,30\]      |      2 |
| May       | (30,60\]     |     29 |
| June      | (0,30\]      |      3 |
| June      | (30,60\]     |     27 |
| July      | (0,30\]      |      6 |
| July      | (30,60\]     |     25 |
| August    | (0,30\]      |      5 |
| August    | (30,60\]     |     26 |
| September | (0,30\]      |      3 |
| September | (30,60\]     |     27 |
| October   | (0,30\]      |      2 |
| October   | (30,60\]     |     29 |
| November  | (0,30\]      |      4 |
| November  | (30,60\]     |     26 |
| December  | (0,30\]      |      4 |
| December  | (30,60\]     |     27 |

## Average Days in AR Monthly Calculation

``` r
y <- tibble::tibble(
  date = clock::date_build(2022, 1:12),
  gct = abs(rnorm(12, c(365000.567, 169094.46, 297731.74), c(2:3))),
  earb = abs(rnorm(12, c(182771.32, 169633.64, 179347.72), c(2:3))))

y |> 
  forager::dar_month(date, gct, earb, dart = 35) |> 
  gluedown::md_table()
```

| date       | month     | nmon | ndip |      gct |     earb | earb_trg |    earb_dc |   earb_pct |       adc |      dar | pass |    actual |    ideal |     radiff |
|:-----------|:----------|-----:|-----:|---------:|---------:|---------:|-----------:|-----------:|----------:|---------:|:-----|----------:|---------:|-----------:|
| 2022-01-01 | January   |    1 |   31 | 364998.5 | 182767.4 | 412095.1 | -229327.68 | -125.47513 | 11774.146 | 15.52278 | TRUE | 0.5007347 | 1.129032 | -0.6282975 |
| 2022-02-01 | February  |    2 |   28 | 169096.1 | 169635.2 | 211370.2 |  -41734.98 |  -24.60278 |  6039.148 | 28.08926 | TRUE | 1.0031879 | 1.250000 | -0.2468121 |
| 2022-03-01 | March     |    3 |   31 | 297730.2 | 179343.5 | 336147.0 | -156803.57 |  -87.43200 |  9604.201 | 18.67344 | TRUE | 0.6023690 | 1.129032 | -0.5266633 |
| 2022-04-01 | April     |    4 |   30 | 365003.2 | 182771.3 | 425837.1 | -243065.79 | -132.98906 | 12166.773 | 15.02216 | TRUE | 0.5007388 | 1.166667 | -0.6659278 |
| 2022-05-01 | May       |    5 |   31 | 169094.3 | 169635.1 | 190912.9 |  -21277.86 |  -12.54331 |  5454.655 | 31.09914 | TRUE | 1.0031980 | 1.129032 | -0.1258343 |
| 2022-06-01 | June      |    6 |   30 | 297731.9 | 179349.7 | 347353.9 | -168004.21 |  -93.67412 |  9924.396 | 18.07159 | TRUE | 0.6023865 | 1.166667 | -0.5642802 |
| 2022-07-01 | July      |    7 |   31 | 364997.9 | 182769.4 | 412094.5 | -229325.04 | -125.47233 | 11774.127 | 15.52297 | TRUE | 0.5007409 | 1.129032 | -0.6282913 |
| 2022-08-01 | August    |    8 |   31 | 169093.6 | 169633.3 | 190912.1 |  -21278.76 |  -12.54397 |  5454.632 | 31.09896 | TRUE | 1.0031921 | 1.129032 | -0.1258401 |
| 2022-09-01 | September |    9 |   30 | 297728.5 | 179347.6 | 347349.9 | -168002.27 |  -93.67411 |  9924.282 | 18.07159 | TRUE | 0.6023865 | 1.166667 | -0.5642802 |
| 2022-10-01 | October   |   10 |   31 | 365002.3 | 182776.8 | 412099.4 | -229322.55 | -125.46589 | 11774.268 | 15.52341 | TRUE | 0.5007552 | 1.129032 | -0.6282770 |
| 2022-11-01 | November  |   11 |   30 | 169096.6 | 169630.3 | 197279.4 |  -27649.04 |  -16.29958 |  5636.554 | 30.09469 | TRUE | 1.0031563 | 1.166667 | -0.1635103 |
| 2022-12-01 | December  |   12 |   31 | 297733.0 | 179352.7 | 336150.1 | -156797.46 |  -87.42411 |  9604.289 | 18.67423 | TRUE | 0.6023944 | 1.129032 | -0.5266379 |

<br>

### Presentation Examples

<details>
<summary>
Click to View Code for Table
</summary>

``` r
gt_1 <- dar_month_2022 |> 
  dplyr::select(month, gct, earb, earb_trg, dar, pass) |> 
  headliner::add_headline_column(x = earb, y = earb_trg, 
  headline = "{delta_p}% {trend} than Target", 
  trend_phrases = headliner::trend_terms(more = "HIGHER", less = "Lower"), n_decimal = 0) |> 
  gt::gt(rowname_col = "month") |> 
  gt::cols_label(gct = "Gross Charges",
                 earb = "Ending AR",
                 earb_trg = "Target AR",
                 dar = "Days in AR",
                 pass = "Pass",
                 headline = "Ending AR Trend") |> 
  gt::tab_row_group(label = "Q4", rows = c(10:12)) |>
  gt::tab_row_group(label = "Q3", rows = c(7:9)) |>
  gt::tab_row_group(label = "Q2", rows = c(4:6)) |>
  gt::tab_row_group(label = "Q1", rows = c(1:3)) |> 
  gt::fmt_number(columns = dar) |>
  gt::fmt_currency(columns = c(gct, earb, earb_trg)) |>
  gt::tab_style(style = gt::cell_text(font = c(gt::google_font(name = "IBM Plex Mono"),
  gt::default_fonts())), locations = gt::cells_body(columns = c(gct, earb, earb_trg, dar))) |> 
  gt::opt_stylize(style = 6, color = "cyan") |> 
  gt::tab_header(
    title = gt::md("Example **Days in AR Analysis** with the **{forager}** Package"), 
    subtitle = gt::md("**May** saw the *highest* Days in AR of 2022 *(51.2)*. This coincided with the largest <br> month-to-month increase in AR & highest percentage over the AR Target *(46%)*.")) |> 
  gt::opt_all_caps() |> 
  gt::grand_summary_rows(
    columns = c(gct, earb, earb_trg, dar),
    fns = list(Mean = ~mean(., na.rm = TRUE), Median = ~median(., na.rm = TRUE))) |> 
  gt::opt_table_font(font = list(gt::google_font(name = "Roboto"))) |> 
  gt::opt_align_table_header(align = "left")

#gt_1 |> gt::gtsave("gt_1.png", expand = 20)
```

</details>

<img src="man/figures/gt_1.png" style="width:75.0%" />

<details>
<summary>
Click to View Code for Table
</summary>

``` r
# Create df for gt_plt_bar_stack
dar_month_2022_pct <- dar_month_2022 |>
  dplyr::mutate(gct_pct = (gct / (gct + earb) * 100),
         earb_pct = (earb / (gct + earb) * 100)) |>
  dplyr::select(month, gct_pct, earb_pct) |>
  tidyr::pivot_longer(-month, names_to = "measure", values_to = "percentage") |>
  dplyr::group_by(month) |>
  dplyr::summarize(list_data = list(percentage))

# Right join the two data frames
dar_month_2022_join <- dplyr::right_join(dar_month_2022, 
                                         dar_month_2022_pct, 
                                         by = "month")

# Create new copy cols for gt_plt_bullet
dar_month_2022_gt <- dar_month_2022_join |> 
  dplyr::select(month, 
                gct, 
                earb, 
                earb_trg, 
                dar, 
                pass,
                list_data) |>
  dplyr::mutate(target_col = earb, 
                plot_col = earb_trg)

# Create gt table
gt_2 <- dar_month_2022_gt |> 
  gt::gt(rowname_col = "month") |>
  gt::cols_label(
    #month = "Month",
                 gct = "Gross Charges",
                 earb = "Ending AR",
                 earb_trg = "Optimal AR",
                 dar = "Days in AR",
                 pass = "Pass",
                 plot_col = "Optimal AR Threshold") |>
  gt::tab_row_group(label = "Q4", rows = c(10:12)) |>
  gt::tab_row_group(label = "Q3", rows = c(7:9)) |>
  gt::tab_row_group(label = "Q2", rows = c(4:6)) |>
  gt::tab_row_group(label = "Q1", rows = c(1:3)) |> 
  #gt::tab_options(row_group.as_column = TRUE) |> 
  gtExtras::gt_theme_espn() |> 
  gt::fmt_number(columns = dar) |>
  gt::fmt_currency(columns = c(gct, earb, earb_trg)) |>
  #gtExtras::gt_plt_dot(dar, month, palette = c("#2c3e50", "#8ca0aa")) |> 
  gtExtras::gt_plt_bullet(column = plot_col, target = target_col, palette = c("#8ca0aa", "black"), width = 65) |>
  gtExtras::gt_plt_bar_stack(list_data, width = 50, labels = c("Charges (%) ", " AR (%)"), palette = c("#2c3e50", "#8ca0aa")) |>
  gtExtras::gt_badge(pass, palette = c("FALSE" = "#8ca0aa")) |> 
  gt::tab_style(style = gt::cell_text(color = "#2c3e50", weight = "bolder"), locations = gt::cells_body(columns = pass, rows = pass == "FALSE")) |>
  gt::tab_style(style = gt::cell_text(color = "#8ca0aa", weight = "normal"), locations = gt::cells_body(columns = pass, rows = pass == "TRUE")) |> 
  gt::data_color(columns = c(gct, earb, dar), colors = scales::col_numeric(palette = c("#2c3e50", "#8ca0aa") |> as.character(), domain = NULL)) |> 
  gt::tab_footnote(footnote = "Horizontal bar indicates Optimal AR, vertical bar is Actual.", locations = gt::cells_column_labels(columns = plot_col)) |> 
  gt::tab_header(title = gt::md("Example **Days in AR Analysis** with the **{forager}** Package"))

#gt_2 |> gt::gtsave("gt_2.png", expand = 20)
```

</details>

<img src="man/figures/gt_2.png" style="width:75.0%" />

<br>

## Days in AR Quarterly Calculation

``` r
y |> forager::dar_qtr(date, gct, earb, 35) |> 
     gluedown::md_table()
```

| date       | nqtr | ndip |  gct_qtr |     earb | earb_trg |   earb_dc | earb_pct |     adc |   dar | pass | actual | ideal | radiff |
|:-----------|-----:|-----:|---------:|---------:|---------:|----------:|---------:|--------:|------:|:-----|-------:|------:|-------:|
| 2022-03-01 |    1 |   90 | 831824.9 | 179343.5 | 323487.5 | -144144.0 |   -80.37 | 9242.50 | 19.40 | TRUE |   0.22 |  0.39 |  -0.17 |
| 2022-06-01 |    2 |   91 | 831829.4 | 179349.7 | 319934.4 | -140584.7 |   -78.39 | 9140.98 | 19.62 | TRUE |   0.22 |  0.38 |  -0.16 |
| 2022-09-01 |    3 |   92 | 831820.0 | 179347.6 | 316453.2 | -137105.6 |   -76.45 | 9041.52 | 19.84 | TRUE |   0.22 |  0.38 |  -0.16 |
| 2022-12-01 |    4 |   92 | 831831.9 | 179352.7 | 316457.8 | -137105.1 |   -76.44 | 9041.65 | 19.84 | TRUE |   0.22 |  0.38 |  -0.16 |

<br>

<details>
<summary>
Click to View Code for Table
</summary>

``` r
# Create df for gt_plt_bar_stack
dar_qtr_2022_pct <- dar_quarter_2022 |>
  dplyr::mutate(gct_pct = (gct_qtr / (gct_qtr + earb) * 100),
                earb_pct = (earb / (gct_qtr + earb) * 100)) |>
  dplyr::select(nqtr, gct_pct, earb_pct) |>
  tidyr::pivot_longer(-nqtr, 
                      names_to = "measure", 
                      values_to = "percentage") |>
  dplyr::group_by(nqtr) |>
  dplyr::summarize(list_data = list(percentage))

# Right join the two data frames
dar_qtr_2022_join <- dplyr::right_join(
  dar_quarter_2022, 
  dar_qtr_2022_pct, 
  by = "nqtr")

# Create new copy cols for gt_plt_bullet
dar_qtr_2022_gt <- dar_qtr_2022_join |> 
  dplyr::select(nqtr, 
                gct_qtr, 
                earb, 
                earb_trg, 
                dar, 
                pass,
                list_data) |>
  dplyr::mutate(target_col = earb, 
                plot_col = earb_trg)

# Create gt table
gt_qtr_2 <- dar_qtr_2022_gt |> 
  gt::gt(rowname_col = "nqtr") |>
  gt::cols_label(
    #month = "Month",
                 gct_qtr = "Gross Charges",
                 earb = "Ending AR",
                 earb_trg = "Optimal AR",
                 dar = "Days in AR",
                 pass = "Pass",
                 plot_col = "Optimal AR Threshold") |>
  # gt::tab_row_group(label = "Q4", rows = c(10:12)) |>
  # gt::tab_row_group(label = "Q3", rows = c(7:9)) |>
  # gt::tab_row_group(label = "Q2", rows = c(4:6)) |>
  # gt::tab_row_group(label = "Q1", rows = c(1:3)) |> 
  #gt::tab_options(row_group.as_column = TRUE) |> 
  gtExtras::gt_theme_espn() |> 
  gt::fmt_number(columns = dar) |>
  gt::fmt_currency(columns = c(gct_qtr, earb, earb_trg)) |>
  #gtExtras::gt_plt_dot(dar, month, palette = c("#2c3e50", "#8ca0aa")) |> 
  gtExtras::gt_plt_bullet(column = plot_col, target = target_col, palette = c("#8ca0aa", "black"), width = 65) |>
  gtExtras::gt_plt_bar_stack(list_data, width = 50, labels = c("Charges (%) ", " AR (%)"), palette = c("#2c3e50", "#8ca0aa")) |>
  gtExtras::gt_badge(pass, palette = c("FALSE" = "#8ca0aa")) |> 
  gt::tab_style(style = gt::cell_text(color = "#2c3e50", weight = "bolder"), locations = gt::cells_body(columns = pass, rows = pass == "FALSE")) |>
  gt::tab_style(style = gt::cell_text(color = "#8ca0aa", weight = "normal"), locations = gt::cells_body(columns = pass, rows = pass == "TRUE")) |> 
  gt::data_color(columns = c(gct_qtr, earb, dar), colors = scales::col_numeric(palette = c("#2c3e50", "#8ca0aa") |> as.character(), domain = NULL)) |> 
  gt::tab_footnote(footnote = "Horizontal bar indicates Optimal AR, vertical bar is Actual.", locations = gt::cells_column_labels(columns = plot_col)) |> 
  gt::tab_header(title = gt::md("Example **Days in AR Analysis** with the **{forager}** Package"))

#gt_qtr_2 |> gt::gtsave("gt_qtr_2.png", expand = 20)
```

</details>

<img src="man/figures/gt_qtr_2.png" style="width:75.0%" />

## Code of Conduct

Please note that the `forager` project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/forager/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: <https://dictionary.cambridge.org/dictionary/english/forager>

[^2]: Me.
