
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
library(ymd)
library(forager)
library(fuimus)
```

## The Lifecycle of a Claim

``` r
(x <- mock_claims(15000))
#> # A tibble: 15,000 × 10
#>    claimid payer     charges balance date_ser…¹ date_rel…² date_sub…³ date_acc…⁴
#>    <chr>   <fct>       <dbl>   <dbl> <date>     <date>     <date>     <date>    
#>  1 00008   Oscar       420.    420.  2024-05-26 2024-06-02 2024-06-05 2024-06-12
#>  2 00108   Omaha       152.    152.  2024-05-26 2024-05-30 2024-06-02 2024-06-07
#>  3 00299   Molina       26.     26.  2024-05-26 2024-06-04 2024-06-10 2024-06-17
#>  4 00390   Highmark     93.      0   2024-05-26 2024-06-12 2024-06-17 2024-06-25
#>  5 00415   Medicare     63.      0   2024-05-26 2024-05-31 2024-06-10 2024-06-16
#>  6 00431   GuideWell   127.      0   2024-05-26 2024-06-01 2024-06-01 2024-06-10
#>  7 00445   Wellcare      4.3     4.3 2024-05-26 2024-06-02 2024-06-08 2024-06-12
#>  8 00451   Cigna       120.      0   2024-05-26 2024-05-28 2024-05-30 2024-06-05
#>  9 00531   Lincoln …   224.      0   2024-05-26 2024-05-31 2024-06-02 2024-06-07
#> 10 00568   GuideWell   166.    166.  2024-05-26 2024-06-09 2024-06-17 2024-06-26
#> # ℹ 14,990 more rows
#> # ℹ abbreviated names: ¹​date_service, ²​date_release, ³​date_submission,
#> #   ⁴​date_acceptance
#> # ℹ 2 more variables: date_adjudication <date>, date_reconciliation <date>
```

<br>

``` r
(x <- prep_claims(x))
#> # A tibble: 15,000 × 13
#>    claimid payer         charges balance date_service aging_bin   dar days_rel…¹
#>    <chr>   <fct>           <dbl>   <dbl> <date>       <fct>     <dbl>      <dbl>
#>  1 00001   Medicaid         401.      0  2024-03-29   0-30         17          1
#>  2 00002   New York Life    171.      0  2024-04-14   0-30         22          2
#>  3 00003   Centene           60.     60. 2024-03-02   0-30         17          1
#>  4 00004   Centene          183.    183. 2024-05-16   0-30         21          2
#>  5 00005   Cigna            314.      0  2024-03-09   31-60        32          5
#>  6 00006   UnitedHealth      50.      0  2024-03-21   0-30         30          5
#>  7 00007   Equitable        243.      0  2024-04-06   0-30         24          5
#>  8 00008   Oscar            420.    420. 2024-05-26   31-60        33          7
#>  9 00009   Lincoln Nat'l     79.     79. 2024-04-10   31-60        38         10
#> 10 00010   Medicaid          32.     32. 2024-04-30   31-60        35         13
#> # ℹ 14,990 more rows
#> # ℹ abbreviated name: ¹​days_release
#> # ℹ 5 more variables: days_submission <dbl>, days_acceptance <dbl>,
#> #   days_adjudication <dbl>, days_reconciliation <dbl>, dates <list>
```

<br>

``` r
summarise_claims(x) |> 
  glimpse()
#> Rows: 1
#> Columns: 9
#> $ n_claims            <int> 15000
#> $ gross_charges       <dbl> 2009316
#> $ ending_ar           <dbl> 1329560
#> $ mean_release        <dbl> 7.9998
#> $ mean_submission     <dbl> 3.023933
#> $ mean_acceptance     <dbl> 7.507067
#> $ mean_adjudication   <dbl> 14.98853
#> $ mean_reconciliation <dbl> 2.208127
#> $ mean_dar            <dbl> 34.262
```

``` r
x |> 
  group_by(
    year = year(date_service),
    month = month(date_service),
    payer
  ) |>
  summarise_claims() |> 
  arrange(payer) |>
  select(year, month, payer, n_claims, ending_ar, mean_dar)
#> # A tibble: 81 × 6
#>     year month payer         n_claims ending_ar mean_dar
#>    <int> <int> <fct>            <int>     <dbl>    <dbl>
#>  1  2024     3 Medicaid           210    16083.      34.
#>  2  2024     4 Medicaid           191    17277.      34.
#>  3  2024     5 Medicaid           158    14752.      34.
#>  4  2024     3 New York Life      217    19324.      34.
#>  5  2024     4 New York Life      192    17413.      34.
#>  6  2024     5 New York Life      180    15011.      34.
#>  7  2024     3 Centene            185    16104.      34.
#>  8  2024     4 Centene            201    14927.      35.
#>  9  2024     5 Centene            158    13403.      35.
#> 10  2024     3 Cigna              205    17912.      34.
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
  summarise_claims() |> 
  arrange(payer) |>
  select(year, qtr, payer, n_claims, ending_ar, mean_dar)
#> Error in `group_by()`:
#> ℹ In argument: `year = get_year(date_service)`.
#> Caused by error in `get_year()`:
#> ! could not find function "get_year"
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
#> Error in date_build(2024, 1:12): could not find function "date_build"
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
#> Error in date_build(2024, 1:12): could not find function "date_build"
```

## Code of Conduct

Please note that the `forager` project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/forager/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: <https://dictionary.cambridge.org/dictionary/english/forager>

[^2]: Me.
