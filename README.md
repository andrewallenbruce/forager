
<!-- README.md is generated from README.Rmd. Please edit that file -->

# forager <a href="#"><img src="man/figures/logo.svg" align="right" width="25%" min-width="120px"/></a>

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

![GitHub R package
version](https://img.shields.io/github/r-package/v/andrewallenbruce/forager?style=flat-square&logo=R&label=Package&color=%23192a38)
[![R-CMD-check](https://github.com/andrewallenbruce/forager/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/andrewallenbruce/forager/actions/workflows/R-CMD-check.yaml)
[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://choosealicense.com/licenses/mit/)
[![Code
Size](https://img.shields.io/github/languages/code-size/andrewallenbruce/forager.svg)](https://github.com/andrewallenbruce/forager)
[![last
commit](https://img.shields.io/github/last-commit/andrewallenbruce/forager.svg)](https://github.com/andrewallenbruce/forager/commits/master)
[![Codecov test
coverage](https://codecov.io/gh/andrewallenbruce/forager/branch/master/graph/badge.svg)](https://app.codecov.io/gh/andrewallenbruce/forager?branch=master)

<!-- badges: end -->

## Installation

You can install the development version of `forager` from
[GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("andrewallenbruce/forager")
```

``` r
library(tidyverse)
library(clock)
library(forager)
library(fuimus)
```

## The Lifecycle of a Claim

- <b>Provider Lag</b>: Date of Service - Date of Release
- <b>Billing Lag</b>: Date of Release - Date of Submission
- <b>Acceptance Lag</b>: Date of Submission - Date of Acceptance
- <b>Payment Lag</b>: Date of Acceptance - Date of Adjudication
- <b>Days in AR</b>: Date of Release - Date of Adjudication

<br>

``` r
x <- mock_claims(15000)
x
#> # A tibble: 15,000 × 10
#>    claimid payer     charges balance date_ser…¹ date_rel…² date_sub…³ date_acc…⁴
#>    <fct>   <fct>       <dbl>   <dbl> <date>     <date>     <date>     <date>    
#>  1 00021   Kaiser P…    139.      0  2024-05-24 2024-06-01 2024-06-03 2024-06-10
#>  2 00191   Medicaid     108.    108. 2024-05-24 2024-06-02 2024-06-02 2024-06-15
#>  3 00278   Medicaid     152.    152. 2024-05-24 2024-06-06 2024-06-08 2024-06-16
#>  4 00304   Cigna He…     93.      0  2024-05-24 2024-05-25 2024-05-31 2024-06-08
#>  5 00363   Athene A…     49.     49. 2024-05-24 2024-05-26 2024-05-28 2024-06-01
#>  6 00400   Medicare     160.    160. 2024-05-24 2024-06-06 2024-06-13 2024-06-18
#>  7 00544   CVS Heal…    104.    104. 2024-05-24 2024-05-29 2024-06-01 2024-06-18
#>  8 00614   Elevance…     96.     96. 2024-05-24 2024-06-12 2024-06-16 2024-06-21
#>  9 00795   Omaha Su…    159.      0  2024-05-24 2024-06-10 2024-06-14 2024-06-27
#> 10 00798   New York…     54.     54. 2024-05-24 2024-05-28 2024-05-31 2024-06-13
#> # ℹ 14,990 more rows
#> # ℹ abbreviated names: ¹​date_service, ²​date_release, ³​date_submission,
#> #   ⁴​date_acceptance
#> # ℹ 2 more variables: date_adjudication <date>, date_reconciliation <date>
```

<br>

``` r
long <- x |> 
  pivot_longer(
    cols      = starts_with("date"), 
    names_to  = "date_type", 
    names_prefix = "date_",
    values_to = "date") |> 
  mutate(
    days = as.numeric(lead(date) - date),
    days = lag(days, order_by = date),
    date_type = fct_relevel(
      date_type, 
      "service", 
      "release",
      "submission", 
      "acceptance", 
      "adjudication", 
      "reconciliation"), 
    .by = claimid)

long
#> # A tibble: 90,000 × 7
#>    claimid payer             charges balance date_type      date        days
#>    <fct>   <fct>               <dbl>   <dbl> <fct>          <date>     <dbl>
#>  1 00021   Kaiser Permanente    139.      0  service        2024-05-24    NA
#>  2 00021   Kaiser Permanente    139.      0  release        2024-06-01     8
#>  3 00021   Kaiser Permanente    139.      0  submission     2024-06-03     2
#>  4 00021   Kaiser Permanente    139.      0  acceptance     2024-06-10     7
#>  5 00021   Kaiser Permanente    139.      0  adjudication   2024-07-01    21
#>  6 00021   Kaiser Permanente    139.      0  reconciliation 2024-07-01     0
#>  7 00191   Medicaid             108.    108. service        2024-05-24    NA
#>  8 00191   Medicaid             108.    108. release        2024-06-02     9
#>  9 00191   Medicaid             108.    108. submission     2024-06-02     0
#> 10 00191   Medicaid             108.    108. acceptance     2024-06-15    13
#> # ℹ 89,990 more rows
```

<br>

``` r
x <- long |> 
  pivot_wider(
    names_from = date_type,
    names_glue = "{.value}_{date_type}",
    values_from = c(date, days)
  ) |> 
  janitor::remove_empty("cols") |> 
  rowwise() |> 
  mutate(days_in_ar = as.numeric(diff(c(date_service, date_adjudication)))) |> 
  ungroup()
x
#> # A tibble: 15,000 × 16
#>    claimid payer       charges balance date_service date_release date_submission
#>    <fct>   <fct>         <dbl>   <dbl> <date>       <date>       <date>         
#>  1 00021   Kaiser Per…   139.      0   2024-05-24   2024-06-01   2024-06-03     
#>  2 00191   Medicaid      108.    108.  2024-05-24   2024-06-02   2024-06-02     
#>  3 00278   Medicaid      152.    152.  2024-05-24   2024-06-06   2024-06-08     
#>  4 00304   Cigna Heal…    93.0     0   2024-05-24   2024-05-25   2024-05-31     
#>  5 00363   Athene Ann…    48.6    48.6 2024-05-24   2024-05-26   2024-05-28     
#>  6 00400   Medicare      160.    160.  2024-05-24   2024-06-06   2024-06-13     
#>  7 00544   CVS Health…   104.    104.  2024-05-24   2024-05-29   2024-06-01     
#>  8 00614   Elevance H…    95.5    95.5 2024-05-24   2024-06-12   2024-06-16     
#>  9 00795   Omaha Supp…   159.      0   2024-05-24   2024-06-10   2024-06-14     
#> 10 00798   New York L…    53.6    53.6 2024-05-24   2024-05-28   2024-05-31     
#> # ℹ 14,990 more rows
#> # ℹ 9 more variables: date_acceptance <date>, date_adjudication <date>,
#> #   date_reconciliation <date>, days_release <dbl>, days_submission <dbl>,
#> #   days_acceptance <dbl>, days_adjudication <dbl>, days_reconciliation <dbl>,
#> #   days_in_ar <dbl>
```

``` r
x |> 
  group_by(
    year = get_year(date_service),
    month = date_month_factor(date_service),
    payer
    ) |>
  summarise(
    claims = n(), 
    balance = sum(balance, na.rm = TRUE),
    avg_release = mean(days_release, na.rm = TRUE), 
    avg_submission = mean(days_submission, na.rm = TRUE),
    avg_acceptance = mean(days_acceptance, na.rm = TRUE),
    avg_adjudication  = mean(days_adjudication, na.rm = TRUE),
    avg_reconciliation = mean(days_reconciliation, na.rm = TRUE),
    avg_dar = mean(days_in_ar, na.rm = TRUE),
    .groups = "drop") |> 
  arrange(payer) |>
  select(year, month, payer, claims, balance, avg_dar)
#> # A tibble: 108 × 6
#>     year month    payer                           claims balance avg_dar
#>    <int> <ord>    <fct>                            <int>   <dbl>   <dbl>
#>  1  2024 February HCSC (Health Care Service Corp)      7    786.    34  
#>  2  2024 March    HCSC (Health Care Service Corp)    230  20011.    33.6
#>  3  2024 April    HCSC (Health Care Service Corp)    191  15769.    32.3
#>  4  2024 May      HCSC (Health Care Service Corp)    178  16935.    33.1
#>  5  2024 February BCBS Wyoming                         8    340.    30.2
#>  6  2024 March    BCBS Wyoming                       199  14814.    33.5
#>  7  2024 April    BCBS Wyoming                       188  18413.    33.7
#>  8  2024 May      BCBS Wyoming                       153  13511.    34.3
#>  9  2024 February BCBS Michigan                        4    288.    25.5
#> 10  2024 March    BCBS Michigan                      180  16736.    33.7
#> # ℹ 98 more rows
```

<br>

``` r
x |> 
  group_by(
    year = get_year(date_service),
    qtr = quarter(date_service),
    payer
    ) |>
  summarise(
    claims = n(), 
    balance = sum(balance, na.rm = TRUE),
    avg_release = mean(days_release, na.rm = TRUE), 
    avg_submission = mean(days_submission, na.rm = TRUE),
    avg_acceptance = mean(days_acceptance, na.rm = TRUE),
    avg_adjudication  = mean(days_adjudication, na.rm = TRUE),
    avg_reconciliation = mean(days_reconciliation, na.rm = TRUE),
    avg_dar = mean(days_in_ar, na.rm = TRUE),
    .groups = "drop") |> 
  arrange(payer) |>
  select(year, qtr, payer, claims, balance, avg_dar)
#> # A tibble: 54 × 6
#>     year   qtr payer                           claims balance avg_dar
#>    <int> <int> <fct>                            <int>   <dbl>   <dbl>
#>  1  2024     1 HCSC (Health Care Service Corp)    237  20797.    33.6
#>  2  2024     2 HCSC (Health Care Service Corp)    369  32704.    32.7
#>  3  2024     1 BCBS Wyoming                       207  15154.    33.4
#>  4  2024     2 BCBS Wyoming                       341  31924.    33.9
#>  5  2024     1 BCBS Michigan                      184  17024.    33.5
#>  6  2024     2 BCBS Michigan                      368  29544.    33.2
#>  7  2024     1 CVS Health (Aetna)                 218  18961.    33.2
#>  8  2024     2 CVS Health (Aetna)                 345  30575.    33.6
#>  9  2024     1 Medicare                           213  18524.    33.5
#> 10  2024     2 Medicare                           328  28980.    34.0
#> # ℹ 44 more rows
```

## Aging Calculation

``` r
x |> 
  mutate(
    dar = if_else(
      !is.na(date_reconciliation), 
      as.numeric((date_reconciliation - date_service)),
      as.numeric((date_adjudication - date_service))
  )
    ) |> 
  bin_aging(dar, "chop") |> 
  summarise(
    n_claims = n(),
    balance = sum(balance, na.rm = TRUE),
    .by = c(aging_bin))
#> # A tibble: 3 × 3
#>   aging_bin n_claims balance
#>   <fct>        <int>   <dbl>
#> 1 (30, 60]      9693 847440.
#> 2 (0, 30]       5259 463659.
#> 3 (60, 90]        48   1954.
```

``` r
x |> 
  mutate(
    dar = if_else(
      !is.na(date_reconciliation), 
      as.numeric((date_reconciliation - date_service)),
      as.numeric((date_adjudication - date_service))
  )
    ) |> 
  bin_aging(dar, "case") |> 
  summarise(
    n_claims = n(),
    balance = sum(balance, na.rm = TRUE),
    .by = c(aging_bin, payer)) |> 
  arrange(aging_bin)
#> # A tibble: 76 × 4
#>    aging_bin payer                      n_claims balance
#>    <fct>     <fct>                         <int>   <dbl>
#>  1 0-30      Athene Annuity and Life         189  17343.
#>  2 0-30      Bright Healthcare of Texas      201  18791.
#>  3 0-30      New York Life                   190  18184.
#>  4 0-30      Centene                         217  19313.
#>  5 0-30      Wellcare, Inc.                  212  18382.
#>  6 0-30      Omaha Supplemental              196  17718.
#>  7 0-30      BCBS Michigan                   207  18160.
#>  8 0-30      BCBS Wyoming                    179  14417.
#>  9 0-30      Molina Healthcare               200  17125.
#> 10 0-30      Medicare                        186  17489.
#> # ℹ 66 more rows
```

## Days in AR Monthly Calculation

``` r
tibble(
  date = date_build(2024, 1:12),
  gct  = rpois(12, 250000:400000),
  earb = rpois(12, 290000:400000)
  ) |> 
  avg_dar(
    date, 
    gct, 
    earb, 
    dart = 35,
    by = "month")
#> # A tibble: 12 × 15
#>    date         gct  earb  ndip   adc  dart   dar dar_pass ratio_id…¹ ratio_ac…²
#>    <date>     <int> <int> <int> <dbl> <dbl> <dbl> <lgl>         <dbl>      <dbl>
#>  1 2024-01-01 2.5e5 2.9e5    31 8070.    35   36. FALSE           1.1        1.2
#>  2 2024-02-01 2.5e5 2.9e5    29 8620.    35   34. TRUE            1.2        1.2
#>  3 2024-03-01 2.5e5 2.9e5    31 8054.    35   36. FALSE           1.1        1.2
#>  4 2024-04-01 2.5e5 2.9e5    30 8306.    35   35. TRUE            1.2        1.2
#>  5 2024-05-01 2.5e5 2.9e5    31 8076.    35   36. FALSE           1.1        1.2
#>  6 2024-06-01 2.5e5 2.9e5    30 8322.    35   35. TRUE            1.2        1.2
#>  7 2024-07-01 2.5e5 2.9e5    31 8092.    35   36. FALSE           1.1        1.2
#>  8 2024-08-01 2.5e5 2.9e5    31 8070.    35   36. FALSE           1.1        1.2
#>  9 2024-09-01 2.5e5 2.9e5    30 8336.    35   35. TRUE            1.2        1.2
#> 10 2024-10-01 2.5e5 2.9e5    31 8081.    35   36. FALSE           1.1        1.2
#> 11 2024-11-01 2.5e5 2.9e5    30 8336.    35   35. TRUE            1.2        1.2
#> 12 2024-12-01 2.5e5 2.9e5    31 8070.    35   36. FALSE           1.1        1.2
#> # ℹ abbreviated names: ¹​ratio_ideal, ²​ratio_actual
#> # ℹ 5 more variables: ratio_diff <dbl>, earb_target <dbl>, earb_diff <dbl>,
#> #   gct_pct <dbl>, earb_pct <dbl>
```

<br>

## Days in AR Quarterly Calculation

``` r
tibble(
  date = date_build(2024, 1:12),
  gct  = rpois(12, 250000:400000),
  earb = rpois(12, 285500:400000)
  ) |> 
  avg_dar(
    date, 
    gct, 
    earb, 
    dart = 35,
    by = "quarter")
#> # A tibble: 4 × 15
#>   date         earb   gct  ndip   adc  dart   dar dar_pass ratio_id…¹ ratio_ac…²
#>   <date>      <int> <int> <int> <dbl> <dbl> <dbl> <lgl>         <dbl>      <dbl>
#> 1 2024-03-01 286310 7.5e5    91 8230.    35   35. TRUE           0.38       0.38
#> 2 2024-06-01 285787 7.5e5    91 8233.    35   35. TRUE           0.38       0.38
#> 3 2024-09-01 285832 7.5e5    92 8150.    35   35. FALSE          0.38       0.38
#> 4 2024-12-01 284381 7.5e5    92 8167.    35   35. TRUE           0.38       0.38
#> # ℹ abbreviated names: ¹​ratio_ideal, ²​ratio_actual
#> # ℹ 5 more variables: ratio_diff <dbl>, earb_target <dbl>, earb_diff <dbl>,
#> #   gct_pct <dbl>, earb_pct <dbl>
```

## Code of Conduct

Please note that the `forager` project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/forager/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: <https://dictionary.cambridge.org/dictionary/english/forager>

[^2]: Me.
