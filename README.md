
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

``` r
(x <- mock_claims(15000))
#> # A tibble: 15,000 × 10
#>    claimid    payer  charges balance date_ser…¹ date_rel…² date_sub…³ date_acc…⁴
#>    <variable> <fct>    <dbl>   <dbl> <date>     <date>     <date>     <date>    
#>  1 00025      Medic…    411.      0  2024-05-26 2024-06-07 2024-06-10 2024-06-18
#>  2 00053      New Y…    109.    109. 2024-05-26 2024-05-31 2024-06-02 2024-06-14
#>  3 00111      Athen…    104.    104. 2024-05-26 2024-05-30 2024-05-31 2024-06-04
#>  4 00170      Oscar…    145.      0  2024-05-26 2024-05-28 2024-06-05 2024-06-11
#>  5 00179      Oscar…    219.    219. 2024-05-26 2024-06-11 2024-06-14 2024-06-20
#>  6 00195      Brigh…    139.    139. 2024-05-26 2024-06-13 2024-06-16 2024-06-26
#>  7 00295      Linco…    273.      0  2024-05-26 2024-06-03 2024-06-11 2024-06-20
#>  8 00425      Allia…    109.    109. 2024-05-26 2024-06-01 2024-06-08 2024-06-21
#>  9 00520      BCBS …    154.    154. 2024-05-26 2024-06-10 2024-06-16 2024-06-29
#> 10 00526      Athen…     76.     76. 2024-05-26 2024-05-26 2024-05-28 2024-06-02
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
    date_type = fct_relevel(
      date_type, 
      "service", 
      "release",
      "submission", 
      "acceptance", 
      "adjudication", 
      "reconciliation"), 
    days = as.numeric(lead(date) - date),
    days = lag(days, order_by = date),
    .by = claimid) |> 
  arrange(claimid, date_type)

long
#> # A tibble: 90,000 × 7
#>    claimid    payer             charges balance date_type      date        days
#>    <variable> <fct>               <dbl>   <dbl> <fct>          <date>     <dbl>
#>  1 00001      BCBS Michigan        133.    133. service        2024-03-16    NA
#>  2 00001      BCBS Michigan        133.    133. release        2024-03-17     1
#>  3 00001      BCBS Michigan        133.    133. submission     2024-03-18     1
#>  4 00001      BCBS Michigan        133.    133. acceptance     2024-03-21     3
#>  5 00001      BCBS Michigan        133.    133. adjudication   2024-03-31    10
#>  6 00001      BCBS Michigan        133.    133. reconciliation NA            NA
#>  7 00002      Kaiser Permanente    192.    192. service        2024-05-07    NA
#>  8 00002      Kaiser Permanente    192.    192. release        2024-05-07     0
#>  9 00002      Kaiser Permanente    192.    192. submission     2024-05-10     3
#> 10 00002      Kaiser Permanente    192.    192. acceptance     2024-05-14     4
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
  remove_quiet() |> 
  rowwise() |> 
  mutate(days_in_ar = if_else(
      !is.na(date_reconciliation), 
      as.numeric((date_reconciliation - date_service)),
      as.numeric((date_adjudication - date_service))
  )) |> 
  ungroup() |> 
  nest(dates = c(
    date_release, 
    date_submission, 
    date_acceptance, 
    date_adjudication, 
    date_reconciliation
    )
  ) |>
  bin_aging(days_in_ar)
x
#> # A tibble: 15,000 × 13
#>    claimid    payer    charges balance date_service days_release days_submission
#>    <variable> <fct>      <dbl>   <dbl> <date>              <dbl>           <dbl>
#>  1 00001      BCBS Mi…   133.    133.  2024-03-16              1               1
#>  2 00002      Kaiser …   192.    192.  2024-05-07              0               3
#>  3 00003      Centene    204.    204.  2024-05-23              2               4
#>  4 00004      Equitab…   251.      0   2024-04-08              4               5
#>  5 00005      America…    76.3    76.3 2024-05-21              4               6
#>  6 00006      Athene …   278.    278.  2024-05-14              8               4
#>  7 00007      New Yor…   211.    211.  2024-04-06              5               0
#>  8 00008      Elevanc…   279.    279.  2024-05-03              9               6
#>  9 00009      Medicare   227.    227.  2024-03-04              8               4
#> 10 00010      BCBS Wy…    19.0    19.0 2024-05-23             12               6
#> # ℹ 14,990 more rows
#> # ℹ 6 more variables: days_acceptance <dbl>, days_adjudication <dbl>,
#> #   days_reconciliation <dbl>, days_in_ar <dbl>, dates <list>, aging_bin <fct>
```

``` r
x |> 
  group_by(
    year = year(date_service),
    month = month(date_service),
    payer
  ) |>
  summarise(
    claims             = n(), 
    balance            = sum_na(balance),
    avg_release        = mean_na(days_release), 
    avg_submission     = mean_na(days_submission),
    avg_acceptance     = mean_na(days_acceptance),
    avg_adjudication   = mean_na(days_adjudication),
    avg_reconciliation = mean_na(days_reconciliation),
    avg_days_in_ar     = mean_na(days_in_ar),
    .groups = "drop") |> 
  arrange(payer) |>
  select(year, month, payer, claims, balance, avg_days_in_ar)
#> # A tibble: 81 × 6
#>     year month payer               claims balance avg_days_in_ar
#>    <dbl> <dbl> <fct>                <int>   <dbl>          <dbl>
#>  1  2024     3 BCBS Michigan          196  14852.           35.2
#>  2  2024     4 BCBS Michigan          186  17505.           35.5
#>  3  2024     5 BCBS Michigan          179  15603.           33.9
#>  4  2024     3 Kaiser Permanente      208  17991.           34.7
#>  5  2024     4 Kaiser Permanente      206  18682.           33.2
#>  6  2024     5 Kaiser Permanente      176  15729.           34.3
#>  7  2024     3 Centene                209  19685.           34.2
#>  8  2024     4 Centene                179  16251.           34.4
#>  9  2024     5 Centene                164  16263.           33.4
#> 10  2024     3 Equitable Financial    188  16327.           33.5
#> # ℹ 71 more rows
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
    claims             = n(), 
    balance            = sum_na(balance),
    avg_release        = mean_na(days_release), 
    avg_submission     = mean_na(days_submission),
    avg_acceptance     = mean_na(days_acceptance),
    avg_adjudication   = mean_na(days_adjudication),
    avg_reconciliation = mean_na(days_reconciliation),
    avg_days_in_ar     = mean_na(days_in_ar),
    .groups = "drop") |> 
  arrange(payer) |>
  select(year, qtr, payer, claims, balance, avg_days_in_ar)
#> # A tibble: 54 × 6
#>     year   qtr payer               claims balance avg_days_in_ar
#>    <int> <int> <fct>                <int>   <dbl>          <dbl>
#>  1  2024     1 BCBS Michigan          196  14852.           35.2
#>  2  2024     2 BCBS Michigan          365  33108.           34.8
#>  3  2024     1 Kaiser Permanente      208  17991.           34.7
#>  4  2024     2 Kaiser Permanente      382  34412.           33.7
#>  5  2024     1 Centene                209  19685.           34.2
#>  6  2024     2 Centene                343  32514.           33.9
#>  7  2024     1 Equitable Financial    188  16327.           33.5
#>  8  2024     2 Equitable Financial    353  30909.           33.4
#>  9  2024     1 American General       177  14769.           34.2
#> 10  2024     2 American General       362  33583.           34.6
#> # ℹ 44 more rows
```

## Days in AR Calculation

> Monthly

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
#>  1 2024-01-01 2.5e5 2.9e5    31 8089.    35   36. FALSE           1.1        1.2
#>  2 2024-02-01 2.5e5 2.9e5    29 8624.    35   34. TRUE            1.2        1.2
#>  3 2024-03-01 2.5e5 2.9e5    31 8077.    35   36. FALSE           1.1        1.2
#>  4 2024-04-01 2.5e5 2.9e5    30 8343.    35   35. TRUE            1.2        1.2
#>  5 2024-05-01 2.5e5 2.9e5    31 8067.    35   36. FALSE           1.1        1.2
#>  6 2024-06-01 2.5e5 2.9e5    30 8348.    35   35. TRUE            1.2        1.2
#>  7 2024-07-01 2.5e5 2.9e5    31 8064.    35   36. FALSE           1.1        1.2
#>  8 2024-08-01 2.5e5 2.9e5    31 8039.    35   36. FALSE           1.1        1.2
#>  9 2024-09-01 2.5e5 2.9e5    30 8356.    35   35. TRUE            1.2        1.2
#> 10 2024-10-01 2.5e5 2.9e5    31 8069.    35   36. FALSE           1.1        1.2
#> 11 2024-11-01 2.5e5 2.9e5    30 8322.    35   35. TRUE            1.2        1.2
#> 12 2024-12-01 2.5e5 2.9e5    31 8054.    35   36. FALSE           1.1        1.2
#> # ℹ abbreviated names: ¹​ratio_ideal, ²​ratio_actual
#> # ℹ 5 more variables: ratio_diff <dbl>, earb_target <dbl>, earb_diff <dbl>,
#> #   gct_pct <dbl>, earb_pct <dbl>
```

<br>

> Quarterly

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
#> 1 2024-03-01 284939 7.5e5    91 8231.    35   35. TRUE           0.38       0.38
#> 2 2024-06-01 285814 7.5e5    91 8250.    35   35. TRUE           0.38       0.38
#> 3 2024-09-01 286658 7.5e5    92 8156.    35   35. FALSE          0.38       0.38
#> 4 2024-12-01 285883 7.5e5    92 8156.    35   35. FALSE          0.38       0.38
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
