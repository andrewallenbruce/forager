
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
x <- forager::generate_data(15000)
x |> head(n = 10)
#> # A tibble: 10 × 5
#>    claim_id   payer        ins_class balance    dates           
#>    <variable> <chr>        <chr>     <variable> <list>          
#>  1 00001      Medicare     Primary   147.28843  <tibble [1 × 5]>
#>  2 00002      Anthem       Secondary 334.23977  <tibble [1 × 5]>
#>  3 00003      BCBS         Secondary 250.32610  <tibble [1 × 5]>
#>  4 00004      Medicare     Primary   165.52817  <tibble [1 × 5]>
#>  5 00005      Humana       Primary   188.52557  <tibble [1 × 5]>
#>  6 00006      Medicare     Primary    38.95510  <tibble [1 × 5]>
#>  7 00007      Medicaid     Primary    75.20807  <tibble [1 × 5]>
#>  8 00008      Centene      Secondary  76.08480  <tibble [1 × 5]>
#>  9 00009      UnitedHealth Primary    74.54573  <tibble [1 × 5]>
#> 10 00010      Medicare     Secondary 193.73707  <tibble [1 × 5]>
```

<br>

``` r
x |> tidyr::unnest(dates) |> head(n = 10) |> gluedown::md_table()
#> |claim_id |payer        |ins_class |   balance|date_of_service |date_of_release |date_of_submission |date_of_acceptance |date_of_adjudication |
#> |:--------|:------------|:---------|---------:|:---------------|:---------------|:------------------|:------------------|:--------------------|
#> |00001    |Medicare     |Primary   | 147.28843|2020-09-18      |2020-09-20      |2020-09-21         |2020-09-24         |2020-10-25           |
#> |00002    |Anthem       |Secondary | 334.23977|2020-05-18      |2020-06-01      |2020-06-05         |2020-06-10         |2020-07-11           |
#> |00003    |BCBS         |Secondary | 250.32610|2020-10-18      |2020-10-30      |2020-11-03         |2020-11-04         |2020-12-07           |
#> |00004    |Medicare     |Primary   | 165.52817|2020-04-18      |2020-04-27      |2020-04-29         |2020-05-01         |2020-06-01           |
#> |00005    |Humana       |Primary   | 188.52557|2020-07-18      |2020-08-02      |2020-08-04         |2020-08-08         |2020-09-06           |
#> |00006    |Medicare     |Primary   |  38.95510|2020-06-18      |2020-06-26      |2020-06-28         |2020-07-02         |2020-07-29           |
#> |00007    |Medicaid     |Primary   |  75.20807|2020-12-18      |2020-12-28      |2020-12-31         |2021-01-03         |2021-02-02           |
#> |00008    |Centene      |Secondary |  76.08480|2020-01-18      |2020-01-27      |2020-01-31         |2020-01-31         |2020-03-03           |
#> |00009    |UnitedHealth |Primary   |  74.54573|2020-12-18      |2020-12-29      |2020-12-31         |2021-01-02         |2021-02-03           |
#> |00010    |Medicare     |Secondary | 193.73707|2020-06-18      |2020-06-21      |2020-06-25         |2020-06-27         |2020-07-30           |
```

<br>

``` r
x |> tidyr::unnest(dates) |> 
  count_days(date_of_service, date_of_release, provider_lag) |> 
  count_days(date_of_release, date_of_submission, billing_lag) |> 
  count_days(date_of_submission, date_of_acceptance, processing_lag) |> 
  count_days(date_of_submission, date_of_adjudication, payer_lag) |> 
  count_days(date_of_release, date_of_adjudication, days_in_ar) |> 
  dplyr::group_by(month = clock::date_month_factor(date_of_service)) |> 
  dplyr::summarise(
       no_of_claims = dplyr::n(),
       balance_total = sum(balance),
       avg_prov_lag = round(mean(provider_lag), 2),
                      avg_bill_lag = round(mean(billing_lag), 2),
                      avg_accept_lag = round(mean(processing_lag), 2),
                      avg_pay_lag = round(mean(payer_lag), 2),
                      avg_dar = round(mean(days_in_ar), 2), .groups = "drop") |> 
  gluedown::md_table()
```

| month     | no_of_claims | balance_total | avg_prov_lag | avg_bill_lag | avg_accept_lag | avg_pay_lag | avg_dar |
|:----------|-------------:|--------------:|-------------:|-------------:|---------------:|------------:|--------:|
| January   |         1240 |      168147.4 |        11.16 |         2.24 |           3.12 |       33.20 |   35.44 |
| February  |         1267 |      168314.2 |        11.05 |         2.37 |           3.17 |       33.14 |   35.51 |
| March     |         1224 |      157528.1 |        11.01 |         2.38 |           3.15 |       33.14 |   35.52 |
| April     |         1240 |      164739.2 |        10.81 |         2.39 |           2.99 |       32.87 |   35.25 |
| May       |         1246 |      164501.2 |        11.07 |         2.32 |           3.11 |       32.93 |   35.26 |
| June      |         1220 |      159582.2 |        10.95 |         2.30 |           3.20 |       33.20 |   35.50 |
| July      |         1274 |      165617.5 |        10.75 |         2.47 |           3.05 |       33.10 |   35.58 |
| August    |         1274 |      169146.3 |        11.10 |         2.36 |           3.14 |       33.23 |   35.58 |
| September |         1237 |      162958.8 |        11.07 |         2.36 |           3.17 |       33.13 |   35.50 |
| October   |         1253 |      174743.6 |        10.91 |         2.33 |           3.09 |       33.08 |   35.40 |
| November  |         1287 |      175561.7 |        10.89 |         2.32 |           3.10 |       33.06 |   35.38 |
| December  |         1238 |      166038.7 |        10.81 |         2.34 |           3.06 |       33.06 |   35.40 |

## Aging Calculation

``` r
x |> 
  tidyr::unnest(dates) |> 
  forager::count_days(date_of_release, 
                         date_of_adjudication, 
                         days_in_ar) |> 
  dplyr::group_by(payer, 
                  aging_bucket = cut(days_in_ar, 
                                     breaks = seq(0, 500, 30))) |> 
  dplyr::summarise(no_of_claims = dplyr::n(),
                   balance_total = sum(balance), .groups = "drop") |> 
  gluedown::md_table()
```

| payer        | aging_bucket | no_of_claims | balance_total |
|:-------------|:-------------|-------------:|--------------:|
| Anthem       | (0,30\]      |          175 |      23667.81 |
| Anthem       | (30,60\]     |         1688 |     222892.07 |
| BCBS         | (0,30\]      |          185 |      24424.52 |
| BCBS         | (30,60\]     |         1708 |     221720.28 |
| Centene      | (0,30\]      |          179 |      23496.26 |
| Centene      | (30,60\]     |         1684 |     232993.66 |
| Cigna        | (0,30\]      |          186 |      24285.49 |
| Cigna        | (30,60\]     |         1728 |     233376.75 |
| Humana       | (0,30\]      |          184 |      26789.08 |
| Humana       | (30,60\]     |         1697 |     227599.51 |
| Medicaid     | (0,30\]      |          195 |      26440.40 |
| Medicaid     | (30,60\]     |         1669 |     225010.54 |
| Medicare     | (0,30\]      |          168 |      23226.05 |
| Medicare     | (30,60\]     |         1703 |     222655.55 |
| UnitedHealth | (0,30\]      |          183 |      23459.61 |
| UnitedHealth | (30,60\]     |         1668 |     214841.29 |

## Days in AR Monthly Calculation

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
| 2022-01-01 | January   |    1 |   31 | 365000.1 | 182768.8 | 412096.9 | -229328.11 | -125.47445 | 11774.197 | 15.52282 | TRUE | 0.5007362 | 1.129032 | -0.6282960 |
| 2022-02-01 | February  |    2 |   28 | 169097.5 | 169634.1 | 211371.8 |  -41737.68 |  -24.60453 |  6039.195 | 28.08887 | TRUE | 1.0031738 | 1.250000 | -0.2468262 |
| 2022-03-01 | March     |    3 |   31 | 297730.2 | 179346.0 | 336147.0 | -156801.03 |  -87.42936 |  9604.200 | 18.67370 | TRUE | 0.6023775 | 1.129032 | -0.5266548 |
| 2022-04-01 | April     |    4 |   30 | 365005.0 | 182775.5 | 425839.2 | -243063.69 | -132.98486 | 12166.833 | 15.02244 | TRUE | 0.5007479 | 1.166667 | -0.6659188 |
| 2022-05-01 | May       |    5 |   31 | 169093.6 | 169632.1 | 190912.1 |  -21280.01 |  -12.54480 |  5454.631 | 31.09873 | TRUE | 1.0031847 | 1.129032 | -0.1258475 |
| 2022-06-01 | June      |    6 |   30 | 297734.5 | 179346.7 | 347357.0 | -168010.25 |  -93.67903 |  9924.484 | 18.07114 | TRUE | 0.6023712 | 1.166667 | -0.5642955 |
| 2022-07-01 | July      |    7 |   31 | 365000.7 | 182771.8 | 412097.6 | -229325.77 | -125.47106 | 11774.218 | 15.52306 | TRUE | 0.5007438 | 1.129032 | -0.6282885 |
| 2022-08-01 | August    |    8 |   31 | 169098.8 | 169633.3 | 190918.0 |  -21284.65 |  -12.54745 |  5454.799 | 31.09800 | TRUE | 1.0031611 | 1.129032 | -0.1258711 |
| 2022-09-01 | September |    9 |   30 | 297729.5 | 179347.3 | 347351.1 | -168003.85 |  -93.67516 |  9924.318 | 18.07150 | TRUE | 0.6023832 | 1.166667 | -0.5642835 |
| 2022-10-01 | October   |   10 |   31 | 365003.8 | 182771.5 | 412101.0 | -229329.52 | -125.47336 | 11774.315 | 15.52290 | TRUE | 0.5007387 | 1.129032 | -0.6282936 |
| 2022-11-01 | November  |   11 |   30 | 169093.5 | 169631.7 | 197275.7 |  -27644.04 |  -16.29651 |  5636.449 | 30.09549 | TRUE | 1.0031829 | 1.166667 | -0.1634838 |
| 2022-12-01 | December  |   12 |   31 | 297728.0 | 179353.1 | 336144.5 | -156791.33 |  -87.42045 |  9604.128 | 18.67459 | TRUE | 0.6024061 | 1.129032 | -0.5266261 |

<br>

## Days in AR Quarterly Calculation

``` r
y |> forager::dar_qtr(date, gct, earb, 35) |> 
     gluedown::md_table()
```

| date       | nqtr | ndip |  gct_qtr |     earb | earb_trg |   earb_dc | earb_pct |     adc |   dar | pass | actual | ideal | radiff |
|:-----------|-----:|-----:|---------:|---------:|---------:|----------:|---------:|--------:|------:|:-----|-------:|------:|-------:|
| 2022-03-01 |    1 |   90 | 831827.8 | 179346.0 | 323488.6 | -144142.6 |   -80.37 | 9242.53 | 19.40 | TRUE |   0.22 |  0.39 |  -0.17 |
| 2022-06-01 |    2 |   91 | 831833.1 | 179346.7 | 319935.8 | -140589.1 |   -78.39 | 9141.02 | 19.62 | TRUE |   0.22 |  0.38 |  -0.16 |
| 2022-09-01 |    3 |   92 | 831829.1 | 179347.3 | 316456.7 | -137109.4 |   -76.45 | 9041.62 | 19.84 | TRUE |   0.22 |  0.38 |  -0.16 |
| 2022-12-01 |    4 |   92 | 831825.2 | 179353.1 | 316455.2 | -137102.1 |   -76.44 | 9041.58 | 19.84 | TRUE |   0.22 |  0.38 |  -0.16 |

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
