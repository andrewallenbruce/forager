
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

\[![GitHub R package
version](https://img.shields.io/github/r-package/v/andrewallenbruce/forager?style=flat-square&logo=R&label=Package&color=%23192a38)\]
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
#>    claimid payer    charges balance date_service date_release date_submission
#>    <fct>   <fct>      <dbl>   <dbl> <date>       <date>       <date>         
#>  1 00137   Anthem     177.    177.  2024-05-20   2024-05-23   2024-05-28     
#>  2 00180   Anthem     192.    192.  2024-05-20   2024-06-07   2024-06-15     
#>  3 00376   BCBS        88.9    88.9 2024-05-20   2024-05-20   2024-05-21     
#>  4 00400   Cigna      224.    224.  2024-05-20   2024-05-29   2024-06-04     
#>  5 00490   BCBS       190.    190.  2024-05-20   2024-05-28   2024-06-03     
#>  6 00556   Humana      94.4     0   2024-05-20   2024-05-22   2024-05-22     
#>  7 00577   Humana      61.0    61.0 2024-05-20   2024-05-30   2024-05-31     
#>  8 00616   Medicare   175.    175.  2024-05-20   2024-05-21   2024-05-23     
#>  9 00651   Cigna      256.      0   2024-05-20   2024-05-30   2024-05-31     
#> 10 00815   Cigna      119.      0   2024-05-20   2024-05-26   2024-05-28     
#> 11 00817   Cigna      110.      0   2024-05-20   2024-05-29   2024-05-31     
#> 12 00888   Medicaid    36.9    36.9 2024-05-20   2024-05-21   2024-05-24     
#> 13 00906   Centene     60.4     0   2024-05-20   2024-05-25   2024-05-27     
#> 14 00939   BCBS       249.    249.  2024-05-20   2024-05-26   2024-05-30     
#> 15 00957   Humana     637.      0   2024-05-20   2024-06-04   2024-06-04     
#> 16 01077   UHC         35.4     0   2024-05-20   2024-06-01   2024-06-04     
#> 17 01128   Centene     49.5    49.5 2024-05-20   2024-05-21   2024-05-24     
#> 18 01167   BCBS       285.    285.  2024-05-20   2024-05-31   2024-06-01     
#> 19 01204   BCBS       109.    109.  2024-05-20   2024-05-28   2024-06-02     
#> 20 01282   Humana     250.    250.  2024-05-20   2024-05-30   2024-05-30     
#> # ℹ 14,980 more rows
#> # ℹ 3 more variables: date_acceptance <date>, date_adjudication <date>,
#> #   date_reconciliation <date>
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
#>    claimid payer  charges balance date_type      date        days
#>    <fct>   <fct>    <dbl>   <dbl> <fct>          <date>     <dbl>
#>  1 00137   Anthem    177.    177. service        2024-05-20    NA
#>  2 00137   Anthem    177.    177. release        2024-05-23     3
#>  3 00137   Anthem    177.    177. submission     2024-05-28     5
#>  4 00137   Anthem    177.    177. acceptance     2024-06-04     7
#>  5 00137   Anthem    177.    177. adjudication   2024-06-17    13
#>  6 00137   Anthem    177.    177. reconciliation NA            NA
#>  7 00180   Anthem    192.    192. service        2024-05-20    NA
#>  8 00180   Anthem    192.    192. release        2024-06-07    18
#>  9 00180   Anthem    192.    192. submission     2024-06-15     8
#> 10 00180   Anthem    192.    192. acceptance     2024-06-23     8
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
#>  1 00137   Anthem     177.    177.  2024-05-20   2024-05-23   2024-05-28     
#>  2 00180   Anthem     192.    192.  2024-05-20   2024-06-07   2024-06-15     
#>  3 00376   BCBS        88.9    88.9 2024-05-20   2024-05-20   2024-05-21     
#>  4 00400   Cigna      224.    224.  2024-05-20   2024-05-29   2024-06-04     
#>  5 00490   BCBS       190.    190.  2024-05-20   2024-05-28   2024-06-03     
#>  6 00556   Humana      94.4     0   2024-05-20   2024-05-22   2024-05-22     
#>  7 00577   Humana      61.0    61.0 2024-05-20   2024-05-30   2024-05-31     
#>  8 00616   Medicare   175.    175.  2024-05-20   2024-05-21   2024-05-23     
#>  9 00651   Cigna      256.      0   2024-05-20   2024-05-30   2024-05-31     
#> 10 00815   Cigna      119.      0   2024-05-20   2024-05-26   2024-05-28     
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
#>  1  2024 February Huma…    122  11228.        7.63           3.02           7.89
#>  2  2024 March    Huma…    702  63586.        7.82           2.86           7.41
#>  3  2024 April    Huma…    620  55967.        7.76           2.99           7.55
#>  4  2024 May      Huma…    422  37436.        8.29           2.88           7.51
#>  5  2024 February BCBS     122  12000.        7.75           2.89           7.39
#>  6  2024 March    BCBS     674  61762.        8.01           2.91           7.50
#>  7  2024 April    BCBS     627  56806.        7.72           3.09           7.44
#>  8  2024 May      BCBS     402  36197.        8.15           3.08           7.60
#>  9  2024 February UHC       95   8118.        8.04           3.18           7.38
#> 10  2024 March    UHC      681  64746.        8.05           3.02           7.66
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
#>  1  2024     1 Humana      824  74814.        7.79           2.88           7.48
#>  2  2024     2 Humana     1042  93402.        7.97           2.95           7.53
#>  3  2024     1 BCBS        796  73761.        7.97           2.91           7.48
#>  4  2024     2 BCBS       1029  93003.        7.89           3.08           7.50
#>  5  2024     1 UHC         776  72865.        8.05           3.04           7.62
#>  6  2024     2 UHC        1084  97357.        8.05           3.06           7.52
#>  7  2024     1 Medicare    831  74348.        7.88           2.95           7.43
#>  8  2024     2 Medicare   1150  98295.        7.81           3.06           7.65
#>  9  2024     1 Cigna       790  66635.        8.17           2.9            7.64
#> 10  2024     2 Cigna      1078  92283.        8.14           3.04           7.36
#> 11  2024     1 Centene     768  66969.        8.01           2.99           7.22
#> 12  2024     2 Centene    1083  96715.        7.84           3.00           7.43
#> 13  2024     1 Medicaid    809  71241.        8.30           3.10           7.48
#> 14  2024     2 Medicaid   1071  96348.        8.19           2.92           7.47
#> 15  2024     1 Anthem      795  73446.        8.08           2.88           7.65
#> 16  2024     2 Anthem     1074  91720.        8.16           3.05           7.50
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
#> 1 (0, 30]       5251 476554.
#> 2 (30, 60]      9699 852812.
#> 3 (60, 90]        50   3835.
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
#>  1 0-30      Anthem        598  56212.
#>  2 0-30      BCBS          657  59662.
#>  3 0-30      Humana        655  57631.
#>  4 0-30      Cigna         647  57389.
#>  5 0-30      Medicaid      660  58457.
#>  6 0-30      Centene       647  54513.
#>  7 0-30      Medicare      722  64712.
#>  8 0-30      UHC           665  67978.
#>  9 31-60     Anthem       1263 108131.
#> 10 31-60     Cigna        1210 100940.
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
#>    date          gct   earb  ndip   adc  dart   dar dar_pass ratio_ideal
#>    <date>      <int>  <int> <int> <dbl> <dbl> <dbl> <lgl>          <dbl>
#>  1 2024-01-01 249839 291018    31 8059.    35  36.1 FALSE           1.13
#>  2 2024-02-01 250385 289676    29 8634.    35  33.6 TRUE            1.21
#>  3 2024-03-01 250576 289570    31 8083.    35  35.8 FALSE           1.13
#>  4 2024-04-01 249990 290394    30 8333     35  34.8 TRUE            1.17
#>  5 2024-05-01 249706 290428    31 8055.    35  36.1 FALSE           1.13
#>  6 2024-06-01 249190 290731    30 8306.    35  35.0 FALSE           1.17
#>  7 2024-07-01 249424 289234    31 8046.    35  35.9 FALSE           1.13
#>  8 2024-08-01 250495 290265    31 8080.    35  35.9 FALSE           1.13
#>  9 2024-09-01 250192 290361    30 8340.    35  34.8 TRUE            1.17
#> 10 2024-10-01 250188 289441    31 8071.    35  35.9 FALSE           1.13
#> 11 2024-11-01 250335 289483    30 8344.    35  34.7 TRUE            1.17
#> 12 2024-12-01 250820 289728    31 8091.    35  35.8 FALSE           1.13
#> # ℹ 6 more variables: ratio_actual <dbl>, ratio_diff <dbl>, earb_target <dbl>,
#> #   earb_diff <dbl>, gct_pct <dbl>, earb_pct <dbl>
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
#>   date         earb    gct  ndip   adc  dart   dar dar_pass ratio_ideal
#>   <date>      <int>  <int> <int> <dbl> <dbl> <dbl> <lgl>          <dbl>
#> 1 2024-03-01 286313 750638    91 8249.    35  34.7 TRUE           0.385
#> 2 2024-06-01 285421 751158    91 8254.    35  34.6 TRUE           0.385
#> 3 2024-09-01 284292 751525    92 8169.    35  34.8 TRUE           0.380
#> 4 2024-12-01 285983 750953    92 8163.    35  35.0 FALSE          0.380
#> # ℹ 6 more variables: ratio_actual <dbl>, ratio_diff <dbl>, earb_target <dbl>,
#> #   earb_diff <dbl>, gct_pct <dbl>, earb_pct <dbl>
```

## Code of Conduct

Please note that the `forager` project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/forager/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: <https://dictionary.cambridge.org/dictionary/english/forager>

[^2]: Me.
