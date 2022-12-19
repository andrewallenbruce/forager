
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
time measurement. - Task $a$ is created at time $t$. - Subtask $a_1$ is
assigned at time $t_1$ to responsible party $x_1$. - Subtask $a_2$ is
assigned at time $t_2$ to responsible party $x_2$. - So on, and so forth
until… - Task $a_i$ is completed at time $t_i$.

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
#>    claim_id   payer    ins_class balance    dates           
#>    <variable> <chr>    <chr>     <variable> <list>          
#>  1 00001      Humana   Secondary  57.72710  <tibble [1 × 5]>
#>  2 00002      Anthem   Secondary 118.55183  <tibble [1 × 5]>
#>  3 00003      Anthem   Secondary 186.56057  <tibble [1 × 5]>
#>  4 00004      Anthem   Primary    88.28117  <tibble [1 × 5]>
#>  5 00005      Medicaid Primary   142.11783  <tibble [1 × 5]>
#>  6 00006      BCBS     Secondary 121.06323  <tibble [1 × 5]>
#>  7 00007      Humana   Primary    45.65637  <tibble [1 × 5]>
#>  8 00008      Humana   Primary   211.97337  <tibble [1 × 5]>
#>  9 00009      Cigna    Secondary 106.63790  <tibble [1 × 5]>
#> 10 00010      Medicare Secondary 411.03690  <tibble [1 × 5]>
```

<br>

``` r
x |> tidyr::unnest(dates) |> 
     head(n = 10) |> 
     gluedown::md_table()
```

| claim_id | payer    | ins_class |   balance | date_of_service | date_of_release | date_of_submission | date_of_acceptance | date_of_adjudication |
|:---------|:---------|:----------|----------:|:----------------|:----------------|:-------------------|:-------------------|:---------------------|
| 00001    | Humana   | Secondary |  57.72710 | 2020-05-18      | 2020-05-26      | 2020-05-31         | 2020-06-02         | 2020-06-28           |
| 00002    | Anthem   | Secondary | 118.55183 | 2020-12-18      | 2020-12-28      | 2021-01-02         | 2021-01-07         | 2021-02-05           |
| 00003    | Anthem   | Secondary | 186.56057 | 2020-10-18      | 2020-10-23      | 2020-10-26         | 2020-10-29         | 2020-11-27           |
| 00004    | Anthem   | Primary   |  88.28117 | 2020-11-18      | 2020-11-29      | 2020-12-03         | 2020-12-04         | 2021-01-02           |
| 00005    | Medicaid | Primary   | 142.11783 | 2020-08-18      | 2020-08-28      | 2020-08-31         | 2020-09-03         | 2020-10-02           |
| 00006    | BCBS     | Secondary | 121.06323 | 2020-04-18      | 2020-04-26      | 2020-04-30         | 2020-05-01         | 2020-05-30           |
| 00007    | Humana   | Primary   |  45.65637 | 2020-05-18      | 2020-05-31      | 2020-06-02         | 2020-06-02         | 2020-06-29           |
| 00008    | Humana   | Primary   | 211.97337 | 2020-03-18      | 2020-03-21      | 2020-03-24         | 2020-03-26         | 2020-04-28           |
| 00009    | Cigna    | Secondary | 106.63790 | 2020-09-18      | 2020-10-01      | 2020-10-03         | 2020-10-04         | 2020-11-02           |
| 00010    | Medicare | Secondary | 411.03690 | 2020-02-18      | 2020-02-24      | 2020-02-26         | 2020-02-26         | 2020-03-26           |

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
| January   |         1250 |      171000.4 |        10.87 |         2.32 |           3.02 |       33.13 |   35.45 |
| February  |         1209 |      160242.5 |        11.11 |         2.35 |           3.11 |       33.01 |   35.37 |
| March     |         1255 |      165428.0 |        10.94 |         2.38 |           3.09 |       33.03 |   35.40 |
| April     |         1273 |      173028.7 |        10.96 |         2.31 |           3.15 |       33.12 |   35.43 |
| May       |         1281 |      168504.3 |        10.91 |         2.35 |           3.06 |       32.99 |   35.34 |
| June      |         1209 |      165268.4 |        10.84 |         2.40 |           3.11 |       33.11 |   35.50 |
| July      |         1303 |      170262.2 |        10.71 |         2.31 |           3.07 |       32.96 |   35.27 |
| August    |         1210 |      161511.9 |        10.95 |         2.27 |           3.05 |       33.11 |   35.38 |
| September |         1291 |      170885.8 |        11.30 |         2.35 |           3.22 |       33.12 |   35.47 |
| October   |         1229 |      159483.2 |        11.09 |         2.35 |           3.07 |       33.11 |   35.46 |
| November  |         1235 |      167641.6 |        10.97 |         2.31 |           3.04 |       33.19 |   35.51 |
| December  |         1255 |      166323.3 |        11.00 |         2.31 |           3.10 |       33.01 |   35.32 |

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
| (0,30\]      |           25 |      3875.296 |
| (30,60\]     |        14891 |   1982482.138 |
| (60,90\]     |           84 |     13222.939 |

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
| 2022-01-01 | January   |    1 |   31 | 365002.6 | 182769.8 | 412099.7 | -229329.93 | -125.47474 | 11774.278 | 15.52280 | TRUE | 0.5007356 | 1.129032 | -0.6282967 |
| 2022-02-01 | February  |    2 |   28 | 169096.7 | 169635.0 | 211370.9 |  -41735.89 |  -24.60334 |  6039.169 | 28.08913 | TRUE | 1.0031834 | 1.250000 | -0.2468166 |
| 2022-03-01 | March     |    3 |   31 | 297736.7 | 179349.1 | 336154.3 | -156805.21 |  -87.43016 |  9604.409 | 18.67362 | TRUE | 0.6023749 | 1.129032 | -0.5266573 |
| 2022-04-01 | April     |    4 |   30 | 364999.9 | 182770.4 | 425833.2 | -243062.80 | -132.98807 | 12166.662 | 15.02223 | TRUE | 0.5007409 | 1.166667 | -0.6659257 |
| 2022-05-01 | May       |    5 |   31 | 169093.4 | 169632.2 | 190911.9 |  -21279.73 |  -12.54463 |  5454.627 | 31.09877 | TRUE | 1.0031863 | 1.129032 | -0.1258460 |
| 2022-06-01 | June      |    6 |   30 | 297735.9 | 179345.4 | 347358.5 | -168013.08 |  -93.68127 |  9924.529 | 18.07093 | TRUE | 0.6023642 | 1.166667 | -0.5643024 |
| 2022-07-01 | July      |    7 |   31 | 364999.2 | 182770.2 | 412095.9 | -229325.66 | -125.47213 | 11774.167 | 15.52298 | TRUE | 0.5007414 | 1.129032 | -0.6282909 |
| 2022-08-01 | August    |    8 |   31 | 169089.1 | 169634.2 | 190907.0 |  -21272.83 |  -12.54042 |  5454.487 | 31.09994 | TRUE | 1.0032238 | 1.129032 | -0.1258084 |
| 2022-09-01 | September |    9 |   30 | 297732.5 | 179346.9 | 347354.6 | -168007.70 |  -93.67749 |  9924.418 | 18.07128 | TRUE | 0.6023760 | 1.166667 | -0.5642907 |
| 2022-10-01 | October   |   10 |   31 | 365001.8 | 182771.2 | 412098.9 | -229327.67 | -125.47255 | 11774.253 | 15.52295 | TRUE | 0.5007404 | 1.129032 | -0.6282918 |
| 2022-11-01 | November  |   11 |   30 | 169093.9 | 169634.7 | 197276.2 |  -27641.55 |  -16.29475 |  5636.464 | 30.09594 | TRUE | 1.0031980 | 1.166667 | -0.1634687 |
| 2022-12-01 | December  |   12 |   31 | 297728.8 | 179340.8 | 336145.4 | -156804.57 |  -87.43385 |  9604.154 | 18.67325 | TRUE | 0.6023631 | 1.129032 | -0.5266692 |

<br>

## Days in AR Quarterly Calculation

``` r
y |> forager::dar_qtr(date, gct, earb, 35) |> 
     gluedown::md_table()
```

| date       | nqtr | ndip |  gct_qtr |     earb | earb_trg |   earb_dc | earb_pct |     adc |   dar | pass | actual | ideal | radiff |
|:-----------|-----:|-----:|---------:|---------:|---------:|----------:|---------:|--------:|------:|:-----|-------:|------:|-------:|
| 2022-03-01 |    1 |   90 | 831836.0 | 179349.1 | 323491.8 | -144142.7 |   -80.37 | 9242.62 | 19.40 | TRUE |   0.22 |  0.39 |  -0.17 |
| 2022-06-01 |    2 |   91 | 831829.2 | 179345.4 | 319934.3 | -140588.9 |   -78.39 | 9140.98 | 19.62 | TRUE |   0.22 |  0.38 |  -0.16 |
| 2022-09-01 |    3 |   92 | 831820.8 | 179346.9 | 316453.6 | -137106.6 |   -76.45 | 9041.53 | 19.84 | TRUE |   0.22 |  0.38 |  -0.16 |
| 2022-12-01 |    4 |   92 | 831824.5 | 179340.8 | 316455.0 | -137114.2 |   -76.45 | 9041.57 | 19.84 | TRUE |   0.22 |  0.38 |  -0.16 |

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
