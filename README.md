
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

## Foundation: Time Measurement

Everything in a Healthcare RCM workflow is built upon the bedrock of
time measurement.

- Task $a$ is created at time $t$.
- Subtask $a_1$ is assigned at time $t_1$ to responsible party $x_1$.
- Subtask $a_2$ is assigned at time $t_2$ to responsible party $x_2$.
- So on, and so forth until…
- Task $a_i$ is completed at time $t_i$.

Measuring the amount of time between each step becomes crucial in
identifying workflow issues.

### Example: The Lifecycle of a Claim

- **Provider Lag**: Days between *Date of Service* and *Date of Release*
- **Billing Lag**: Days between *Date of Release* and *Date of
  Submission*
- **Acceptance Lag**: Days between *Date of Submission* and *Date of
  Acceptance*
- **Payment Lag**: Days between *Date of Acceptance* and *Date of
  Adjudication*
- **Days in AR**: Days between *Date of Release* and *Date of
  Adjudication*

<br>

``` r
x <- forager::generate_data(15000)
x |> head(n = 10)
#> # A tibble: 10 × 5
#>    claim_id   payer        ins_class balance    dates           
#>    <variable> <chr>        <chr>     <variable> <list>          
#>  1 00001      Medicaid     Secondary 152.85747  <tibble [1 × 5]>
#>  2 00002      UnitedHealth Secondary  36.05447  <tibble [1 × 5]>
#>  3 00003      Centene      Secondary  90.33910  <tibble [1 × 5]>
#>  4 00004      UnitedHealth Secondary  51.64573  <tibble [1 × 5]>
#>  5 00005      Medicaid     Secondary 154.65047  <tibble [1 × 5]>
#>  6 00006      Humana       Secondary 132.19150  <tibble [1 × 5]>
#>  7 00007      Centene      Primary    77.79067  <tibble [1 × 5]>
#>  8 00008      Humana       Secondary 139.89570  <tibble [1 × 5]>
#>  9 00009      Anthem       Primary    71.28777  <tibble [1 × 5]>
#> 10 00010      Centene      Secondary 141.13423  <tibble [1 × 5]>
```

<br>

``` r
x |> tidyr::unnest(dates) |> 
     tidyr::pivot_longer(cols = tidyr::starts_with("date"), 
                         names_to = "date_type", 
                         values_to = "date") |> 
                         head(n = 10) |> 
                         gluedown::md_table()
```

| claim_id | payer        | ins_class |   balance | date_type            | date       |
|:---------|:-------------|:----------|----------:|:---------------------|:-----------|
| 00001    | Medicaid     | Secondary | 152.85747 | date_of_service      | 2020-09-19 |
| 00001    | Medicaid     | Secondary | 152.85747 | date_of_release      | 2020-09-30 |
| 00001    | Medicaid     | Secondary | 152.85747 | date_of_submission   | 2020-10-02 |
| 00001    | Medicaid     | Secondary | 152.85747 | date_of_acceptance   | 2020-10-05 |
| 00001    | Medicaid     | Secondary | 152.85747 | date_of_adjudication | 2020-11-09 |
| 00002    | UnitedHealth | Secondary |  36.05447 | date_of_service      | 2020-07-19 |
| 00002    | UnitedHealth | Secondary |  36.05447 | date_of_release      | 2020-08-02 |
| 00002    | UnitedHealth | Secondary |  36.05447 | date_of_submission   | 2020-08-04 |
| 00002    | UnitedHealth | Secondary |  36.05447 | date_of_acceptance   | 2020-08-04 |
| 00002    | UnitedHealth | Secondary |  36.05447 | date_of_adjudication | 2020-09-09 |

<br>

``` r
x |> tidyr::unnest(dates) |> 
  count_days(date_of_service, date_of_release, provider_lag) |> 
  count_days(date_of_release, date_of_submission, billing_lag) |> 
  count_days(date_of_submission, date_of_acceptance, processing_lag) |> 
  count_days(date_of_submission, date_of_adjudication, payer_lag) |> 
  count_days(date_of_release, date_of_adjudication, days_in_ar) |> 
  dplyr::group_by(month = clock::date_month_factor(date_of_service)) |> 
  dplyr::summarise(no_of_claims = dplyr::n(), 
                   balance_total = sum(balance),
                   avg_prov_lag = round(mean(provider_lag), 2), 
                   avg_bill_lag = round(mean(billing_lag), 2),
                   avg_accept_lag = round(mean(processing_lag), 2),
                   avg_pay_lag = round(mean(payer_lag), 2),
                   avg_days_in_ar = round(mean(days_in_ar), 2), .groups = "drop") |> 
  gluedown::md_table()
```

| month     | no_of_claims | balance_total | avg_prov_lag | avg_bill_lag | avg_accept_lag | avg_pay_lag | avg_days_in_ar |
|:----------|-------------:|--------------:|-------------:|-------------:|---------------:|------------:|---------------:|
| January   |         1277 |      174559.7 |        10.79 |         2.20 |           3.05 |       33.18 |          35.37 |
| February  |         1263 |      171249.5 |        11.22 |         2.32 |           3.11 |       33.01 |          35.34 |
| March     |         1225 |      156436.5 |        11.05 |         2.31 |           3.14 |       33.05 |          35.36 |
| April     |         1257 |      168064.5 |        11.11 |         2.39 |           3.08 |       33.19 |          35.58 |
| May       |         1281 |      167327.5 |        11.22 |         2.31 |           3.09 |       33.20 |          35.51 |
| June      |         1251 |      163328.0 |        10.84 |         2.28 |           3.20 |       33.26 |          35.54 |
| July      |         1238 |      166397.6 |        10.92 |         2.31 |           3.06 |       33.17 |          35.47 |
| August    |         1239 |      162255.0 |        10.82 |         2.32 |           3.09 |       33.10 |          35.41 |
| September |         1281 |      173373.6 |        10.99 |         2.22 |           3.12 |       33.09 |          35.31 |
| October   |         1200 |      160917.7 |        11.12 |         2.28 |           3.09 |       33.25 |          35.53 |
| November  |         1236 |      165392.2 |        11.00 |         2.35 |           3.16 |       33.16 |          35.51 |
| December  |         1252 |      167007.3 |        10.92 |         2.39 |           3.11 |       33.21 |          35.60 |

<br>

``` r
x |> tidyr::unnest(dates) |> 
  count_days(date_of_service, date_of_release, provider_lag) |> 
  count_days(date_of_release, date_of_submission, billing_lag) |> 
  count_days(date_of_submission, date_of_acceptance, processing_lag) |> 
  count_days(date_of_submission, date_of_adjudication, payer_lag) |> 
  count_days(date_of_release, date_of_adjudication, days_in_ar) |> 
  dplyr::group_by(qtr = lubridate::quarter(date_of_service)) |> 
  dplyr::summarise(no_of_claims = dplyr::n(), balance_total = sum(balance), avg_prov_lag = round(mean(provider_lag), 2), avg_bill_lag = round(mean(billing_lag), 2),
                   avg_accept_lag = round(mean(processing_lag), 2),
                      avg_pay_lag = round(mean(payer_lag), 2),
                      avg_days_in_ar = round(mean(days_in_ar), 2), .groups = "drop") |> 
  gluedown::md_table()
```

| qtr | no_of_claims | balance_total | avg_prov_lag | avg_bill_lag | avg_accept_lag | avg_pay_lag | avg_days_in_ar |
|----:|-------------:|--------------:|-------------:|-------------:|---------------:|------------:|---------------:|
|   1 |         3765 |      502245.7 |        11.02 |         2.28 |           3.10 |       33.08 |          35.36 |
|   2 |         3789 |      498720.0 |        11.06 |         2.33 |           3.12 |       33.22 |          35.54 |
|   3 |         3758 |      502026.2 |        10.91 |         2.28 |           3.09 |       33.12 |          35.40 |
|   4 |         3688 |      493317.2 |        11.01 |         2.34 |           3.12 |       33.21 |          35.55 |

## Aging Calculation

``` r
x |> 
  tidyr::unnest(dates) |> 
  forager:::count_days(date_of_service, date_of_adjudication, days_in_ar) |> 
  dplyr::group_by(aging_bucket = cut(days_in_ar, breaks = seq(0, 500, by = 30))) |> 
  dplyr::summarise(no_of_claims = dplyr::n(),
                   balance_total = sum(balance), .groups = "drop") |> 
  gluedown::md_table()
```

| aging_bucket | no_of_claims | balance_total |
|:-------------|-------------:|--------------:|
| (0,30\]      |           19 |      2776.459 |
| (30,60\]     |        14899 |   1984261.643 |
| (60,90\]     |           82 |      9271.023 |

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
| 2022-01-01 | January   |    1 |   31 | 365000.5 | 182770.0 | 412097.3 | -229327.35 | -125.47319 | 11774.210 | 15.52291 | TRUE | 0.5007390 | 1.129032 | -0.6282932 |
| 2022-02-01 | February  |    2 |   28 | 169090.8 | 169632.9 | 211363.5 |  -41730.61 |  -24.60054 |  6038.958 | 28.08977 | TRUE | 1.0032060 | 1.250000 | -0.2467940 |
| 2022-03-01 | March     |    3 |   31 | 297734.2 | 179348.2 | 336151.6 | -156803.34 |  -87.42955 |  9604.330 | 18.67368 | TRUE | 0.6023769 | 1.129032 | -0.5266554 |
| 2022-04-01 | April     |    4 |   30 | 364997.1 | 182774.3 | 425829.9 | -243055.66 | -132.98132 | 12166.570 | 15.02266 | TRUE | 0.5007554 | 1.166667 | -0.6659112 |
| 2022-05-01 | May       |    5 |   31 | 169096.5 | 169633.6 | 190915.4 |  -21281.81 |  -12.54576 |  5454.725 | 31.09846 | TRUE | 1.0031762 | 1.129032 | -0.1258560 |
| 2022-06-01 | June      |    6 |   30 | 297726.8 | 179345.0 | 347347.9 | -168002.94 |  -93.67584 |  9924.227 | 18.07143 | TRUE | 0.6023811 | 1.166667 | -0.5642856 |
| 2022-07-01 | July      |    7 |   31 | 365002.2 | 182771.0 | 412099.3 | -229328.24 | -125.47298 | 11774.264 | 15.52292 | TRUE | 0.5007395 | 1.129032 | -0.6282928 |
| 2022-08-01 | August    |    8 |   31 | 169092.2 | 169627.4 | 190910.6 |  -21283.18 |  -12.54702 |  5454.588 | 31.09811 | TRUE | 1.0031650 | 1.129032 | -0.1258673 |
| 2022-09-01 | September |    9 |   30 | 297729.7 | 179344.1 | 347351.3 | -168007.25 |  -93.67872 |  9924.324 | 18.07116 | TRUE | 0.6023722 | 1.166667 | -0.5642945 |
| 2022-10-01 | October   |   10 |   31 | 364999.9 | 182773.2 | 412096.7 | -229323.51 | -125.46892 | 11774.191 | 15.52320 | TRUE | 0.5007485 | 1.129032 | -0.6282837 |
| 2022-11-01 | November  |   11 |   30 | 169094.4 | 169636.7 | 197276.8 |  -27640.12 |  -16.29372 |  5636.479 | 30.09621 | TRUE | 1.0032069 | 1.166667 | -0.1634597 |
| 2022-12-01 | December  |   12 |   31 | 297725.8 | 179346.6 | 336142.0 | -156795.39 |  -87.42591 |  9604.057 | 18.67405 | TRUE | 0.6023886 | 1.129032 | -0.5266437 |

<br>

## Days in AR Quarterly Calculation

``` r
y |> forager::dar_qtr(date, gct, earb, 35) |> 
     gluedown::md_table()
```

| date       | nqtr | ndip |  gct_qtr |     earb | earb_trg |   earb_dc | earb_pct |     adc |   dar | pass | actual | ideal | radiff |
|:-----------|-----:|-----:|---------:|---------:|---------:|----------:|---------:|--------:|------:|:-----|-------:|------:|-------:|
| 2022-03-01 |    1 |   90 | 831825.6 | 179348.2 | 323487.7 | -144139.5 |   -80.37 | 9242.51 | 19.40 | TRUE |   0.22 |  0.39 |  -0.17 |
| 2022-06-01 |    2 |   91 | 831820.4 | 179345.0 | 319930.9 | -140585.9 |   -78.39 | 9140.88 | 19.62 | TRUE |   0.22 |  0.38 |  -0.16 |
| 2022-09-01 |    3 |   92 | 831824.2 | 179344.1 | 316454.8 | -137110.7 |   -76.45 | 9041.57 | 19.84 | TRUE |   0.22 |  0.38 |  -0.16 |
| 2022-12-01 |    4 |   92 | 831820.1 | 179346.6 | 316453.3 | -137106.7 |   -76.45 | 9041.52 | 19.84 | TRUE |   0.22 |  0.38 |  -0.16 |

<br>

### Presentation Examples

<img src="man/figures/gt_1.png" style="width:75.0%" />

<br>

<img src="man/figures/gt_2.png" style="width:75.0%" />

<br>

<img src="man/figures/gt_qtr_2.png" style="width:75.0%" />

## Code of Conduct

Please note that the `forager` project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/forager/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: <https://dictionary.cambridge.org/dictionary/english/forager>

[^2]: Me.
