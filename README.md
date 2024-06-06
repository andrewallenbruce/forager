
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
x <- generate_data(15000)
x
#> # A tibble: 15,000 × 10
#>    claimid payer    charges balance date_serv…¹ date_rel…² date_sub…³ date_acc…⁴
#>    <fct>   <fct>      <dbl>   <dbl> <date>      <date>     <date>     <date>    
#>  1 00021   BCBS        135.      0  2024-05-22  2024-05-27 2024-05-28 2024-06-05
#>  2 00062   Centene      65.     65. 2024-05-22  2024-05-23 2024-05-25 2024-06-01
#>  3 00219   Anthem      196.    196. 2024-05-22  2024-06-09 2024-06-12 2024-06-19
#>  4 00228   BCBS        189.    189. 2024-05-22  2024-05-27 2024-05-29 2024-06-10
#>  5 00549   Anthem      113.    113. 2024-05-22  2024-05-28 2024-06-01 2024-06-17
#>  6 00563   Humana      191.    191. 2024-05-22  2024-06-05 2024-06-05 2024-06-18
#>  7 00589   Medicaid    107.      0  2024-05-22  2024-05-25 2024-05-26 2024-05-29
#>  8 00618   BCBS         31.      0  2024-05-22  2024-05-22 2024-05-25 2024-06-03
#>  9 00627   Humana      231.    231. 2024-05-22  2024-06-11 2024-06-14 2024-06-21
#> 10 00766   Medicaid    139.      0  2024-05-22  2024-05-23 2024-05-24 2024-06-01
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
#>    claimid payer   charges balance date_type      date        days
#>    <fct>   <fct>     <dbl>   <dbl> <fct>          <date>     <dbl>
#>  1 00021   BCBS      135.      0   service        2024-05-22    NA
#>  2 00021   BCBS      135.      0   release        2024-05-27     5
#>  3 00021   BCBS      135.      0   submission     2024-05-28     1
#>  4 00021   BCBS      135.      0   acceptance     2024-06-05     8
#>  5 00021   BCBS      135.      0   adjudication   2024-06-24    19
#>  6 00021   BCBS      135.      0   reconciliation 2024-06-24     0
#>  7 00062   Centene    64.9    64.9 service        2024-05-22    NA
#>  8 00062   Centene    64.9    64.9 release        2024-05-23     1
#>  9 00062   Centene    64.9    64.9 submission     2024-05-25     2
#> 10 00062   Centene    64.9    64.9 acceptance     2024-06-01     7
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
#>    claimid payer    charges balance date_service date_release date_submission
#>    <fct>   <fct>      <dbl>   <dbl> <date>       <date>       <date>         
#>  1 00021   BCBS       135.      0   2024-05-22   2024-05-27   2024-05-28     
#>  2 00062   Centene     64.9    64.9 2024-05-22   2024-05-23   2024-05-25     
#>  3 00219   Anthem     196.    196.  2024-05-22   2024-06-09   2024-06-12     
#>  4 00228   BCBS       189.    189.  2024-05-22   2024-05-27   2024-05-29     
#>  5 00549   Anthem     113.    113.  2024-05-22   2024-05-28   2024-06-01     
#>  6 00563   Humana     191.    191.  2024-05-22   2024-06-05   2024-06-05     
#>  7 00589   Medicaid   107.      0   2024-05-22   2024-05-25   2024-05-26     
#>  8 00618   BCBS        30.8     0   2024-05-22   2024-05-22   2024-05-25     
#>  9 00627   Humana     231.    231.  2024-05-22   2024-06-11   2024-06-14     
#> 10 00766   Medicaid   139.      0   2024-05-22   2024-05-23   2024-05-24     
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
  arrange(payer)
#> # A tibble: 32 × 11
#>     year month    payer claims balance avg_release avg_submission avg_acceptance
#>    <int> <ord>    <fct>  <int>   <dbl>       <dbl>          <dbl>          <dbl>
#>  1  2024 February Medi…     78   7496.        8.59           3.17           7.94
#>  2  2024 March    Medi…    696  62947.        7.94           2.90           7.56
#>  3  2024 April    Medi…    657  60394.        8.18           3.12           7.28
#>  4  2024 May      Medi…    452  43507.        8.04           3.05           7.27
#>  5  2024 February Cigna     64   5721.        8.67           3.41           7.73
#>  6  2024 March    Cigna    630  58367.        8.07           3.11           7.55
#>  7  2024 April    Cigna    629  57344.        8.00           2.99           7.68
#>  8  2024 May      Cigna    488  44116.        7.55           2.92           7.44
#>  9  2024 February Huma…     76   6431.        7.78           3.30           7.99
#> 10  2024 March    Huma…    674  58633.        8.04           2.96           7.65
#> # ℹ 22 more rows
#> # ℹ 3 more variables: avg_adjudication <dbl>, avg_reconciliation <dbl>,
#> #   avg_dar <dbl>
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
  arrange(payer)
#> # A tibble: 16 × 11
#>     year   qtr payer    claims balance avg_release avg_submission avg_acceptance
#>    <int> <int> <fct>     <int>   <dbl>       <dbl>          <dbl>          <dbl>
#>  1  2024     1 Medicare    774  70443.        8.01           2.93           7.60
#>  2  2024     2 Medicare   1109 103900.        8.12           3.09           7.27
#>  3  2024     1 Cigna       694  64088.        8.12           3.14           7.56
#>  4  2024     2 Cigna      1117 101460.        7.80           2.96           7.57
#>  5  2024     1 Humana      750  65063.        8.01           3.00           7.68
#>  6  2024     2 Humana     1120  97784.        8.11           3.02           7.43
#>  7  2024     1 Medicaid    724  66020.        8.02           3.00           7.28
#>  8  2024     2 Medicaid   1121  95469.        7.93           2.98           7.59
#>  9  2024     1 BCBS        744  66094.        7.93           2.99           7.47
#> 10  2024     2 BCBS       1114  96027.        7.92           2.92           7.33
#> 11  2024     1 Centene     719  65663.        8.20           3.12           7.61
#> 12  2024     2 Centene    1099  94090.        8.06           3.10           7.51
#> 13  2024     1 Anthem      773  70821.        8.25           2.95           7.65
#> 14  2024     2 Anthem     1177 103735.        7.87           2.93           7.50
#> 15  2024     1 UHC         784  69643.        8.10           3.18           7.40
#> 16  2024     2 UHC        1181 109391.        7.93           3.00           7.39
#> # ℹ 3 more variables: avg_adjudication <dbl>, avg_reconciliation <dbl>,
#> #   avg_dar <dbl>
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
#> 1 (30, 60]      9674 847373.
#> 2 (0, 30]       5277 488749.
#> 3 (60, 90]        49   3568.
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
#> # A tibble: 24 × 4
#>    aging_bin payer    n_claims balance
#>    <fct>     <fct>       <int>   <dbl>
#>  1 0-30      Centene       609  56531.
#>  2 0-30      Medicaid      632  55602.
#>  3 0-30      BCBS          700  63211.
#>  4 0-30      Cigna         634  59991.
#>  5 0-30      Anthem        673  62800.
#>  6 0-30      UHC           743  68920.
#>  7 0-30      Medicare      652  60728.
#>  8 0-30      Humana        634  60967.
#>  9 31-60     BCBS         1153  98561.
#> 10 31-60     Anthem       1271 111388.
#> # ℹ 14 more rows
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
#>  1 2024-01-01 2.5e5 2.9e5    31 8076.    35   36. FALSE           1.1        1.2
#>  2 2024-02-01 2.5e5 2.9e5    29 8642.    35   34. TRUE            1.2        1.2
#>  3 2024-03-01 2.5e5 2.9e5    31 8105.    35   36. FALSE           1.1        1.2
#>  4 2024-04-01 2.5e5 2.9e5    30 8332.    35   35. TRUE            1.2        1.2
#>  5 2024-05-01 2.5e5 2.9e5    31 8063.    35   36. FALSE           1.1        1.2
#>  6 2024-06-01 2.5e5 2.9e5    30 8344.    35   35. TRUE            1.2        1.2
#>  7 2024-07-01 2.5e5 2.9e5    31 8049.    35   36. FALSE           1.1        1.2
#>  8 2024-08-01 2.5e5 2.9e5    31 8081.    35   36. FALSE           1.1        1.2
#>  9 2024-09-01 2.5e5 2.9e5    30 8331     35   35. TRUE            1.2        1.2
#> 10 2024-10-01 2.5e5 2.9e5    31 8079.    35   36. FALSE           1.1        1.2
#> 11 2024-11-01 2.5e5 2.9e5    30 8342.    35   35. TRUE            1.2        1.2
#> 12 2024-12-01 2.5e5 2.9e5    31 8075.    35   36. FALSE           1.1        1.2
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
#> 1 2024-03-01 285273 7.5e5    91 8242.    35   35. TRUE           0.38       0.38
#> 2 2024-06-01 285893 7.5e5    91 8237.    35   35. TRUE           0.38       0.38
#> 3 2024-09-01 285357 7.5e5    92 8134.    35   35. FALSE          0.38       0.38
#> 4 2024-12-01 284881 7.5e5    92 8153.    35   35. TRUE           0.38       0.38
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
