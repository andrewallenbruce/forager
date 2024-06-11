
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
#>  1 00008   Oscar        115.    115. 2024-05-26 2024-06-04 2024-06-08 2024-06-14
#>  2 00343   American     284.      0  2024-05-26 2024-06-17 2024-06-19 2024-06-23
#>  3 00389   Wellcare     325.    325. 2024-05-26 2024-06-11 2024-06-19 2024-06-28
#>  4 00473   Medicaid      35.     35. 2024-05-26 2024-06-05 2024-06-08 2024-06-20
#>  5 00604   Humana        50.     50. 2024-05-26 2024-06-03 2024-06-10 2024-06-18
#>  6 01138   Omaha        107.      0  2024-05-26 2024-06-07 2024-06-08 2024-06-15
#>  7 01161   CVS Aetna     27.     27. 2024-05-26 2024-06-01 2024-06-03 2024-06-08
#>  8 01216   Lincoln …     73.     73. 2024-05-26 2024-05-26 2024-05-27 2024-06-07
#>  9 01262   Centene       97.      0  2024-05-26 2024-05-27 2024-05-29 2024-05-31
#> 10 01284   Medicaid      43.     43. 2024-05-26 2024-06-05 2024-06-10 2024-06-21
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
#>  1 00001   Oscar            166.    166. 2024-05-17   0-30         11          0
#>  2 00002   Medicare          23.     23. 2024-04-03   0-30         20          2
#>  3 00003   UnitedHealth     212.    212. 2024-03-27   0-30         18          2
#>  4 00004   GuideWell         84.     84. 2024-05-13   31-60        34          6
#>  5 00005   Lincoln Nat'l    194.    194. 2024-04-03   0-30         29          5
#>  6 00006   HCSC              98.      0  2024-04-04   31-60        34          8
#>  7 00007   Mass Mutual       37.     37. 2024-05-13   31-60        37          7
#>  8 00008   Oscar            115.    115. 2024-05-26   31-60        37          9
#>  9 00009   BCBS MI          190.    190. 2024-04-06   31-60        42         10
#> 10 00010   CVS Aetna         57.     57. 2024-04-10   31-60        40          5
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
#> $ gross_charges       <dbl> 1998810
#> $ ending_ar           <dbl> 1315266
#> $ mean_release        <dbl> 8.0004
#> $ mean_submission     <dbl> 3.01
#> $ mean_acceptance     <dbl> 7.518067
#> $ mean_adjudication   <dbl> 14.9988
#> $ mean_reconciliation <dbl> 2.23959
#> $ mean_dar            <dbl> 34.2838
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
#>     year month payer        n_claims ending_ar mean_dar
#>    <int> <int> <fct>           <int>     <dbl>    <dbl>
#>  1  2024     3 Oscar             195    18188.      34.
#>  2  2024     4 Oscar             181    15630.      34.
#>  3  2024     5 Oscar             148    14025.      34.
#>  4  2024     3 Medicare          186    16966.      34.
#>  5  2024     4 Medicare          208    17676.      34.
#>  6  2024     5 Medicare          157    13925.      36.
#>  7  2024     3 UnitedHealth      179    15377.      33.
#>  8  2024     4 UnitedHealth      182    17476.      34.
#>  9  2024     5 UnitedHealth      156    14550.      34.
#> 10  2024     3 GuideWell         202    19187.      34.
#> # ℹ 71 more rows
```

<br>

``` r
x |> 
  group_by(
    year = year(date_service),
    qtr = quarter(date_service),
    payer
    ) |>
  summarise_claims() |> 
  arrange(payer) |>
  select(year, qtr, payer, n_claims, ending_ar, mean_dar)
#> # A tibble: 54 × 6
#>     year   qtr payer         n_claims ending_ar mean_dar
#>    <int> <int> <fct>            <int>     <dbl>    <dbl>
#>  1  2024     1 Oscar              195    18188.      34.
#>  2  2024     2 Oscar              329    29655.      34.
#>  3  2024     1 Medicare           186    16966.      34.
#>  4  2024     2 Medicare           365    31601.      35.
#>  5  2024     1 UnitedHealth       179    15377.      33.
#>  6  2024     2 UnitedHealth       338    32026.      34.
#>  7  2024     1 GuideWell          202    19187.      34.
#>  8  2024     2 GuideWell          356    31347.      35.
#>  9  2024     1 Lincoln Nat'l      199    17432.      34.
#> 10  2024     2 Lincoln Nat'l      392    36733.      34.
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
#>  1 2024-01-01 2.5e5 2.9e5    31 8080.    35   36. FALSE           1.1        1.2
#>  2 2024-02-01 2.5e5 2.9e5    29 8624.    35   34. TRUE            1.2        1.2
#>  3 2024-03-01 2.5e5 2.9e5    31 8062.    35   36. FALSE           1.1        1.2
#>  4 2024-04-01 2.5e5 2.9e5    30 8320.    35   35. TRUE            1.2        1.2
#>  5 2024-05-01 2.5e5 2.9e5    31 8026.    35   36. FALSE           1.1        1.2
#>  6 2024-06-01 2.5e5 2.9e5    30 8310.    35   35. TRUE            1.2        1.2
#>  7 2024-07-01 2.5e5 2.9e5    31 8053.    35   36. FALSE           1.1        1.2
#>  8 2024-08-01 2.5e5 2.9e5    31 8041.    35   36. FALSE           1.1        1.2
#>  9 2024-09-01 2.5e5 2.9e5    30 8324.    35   35. TRUE            1.2        1.2
#> 10 2024-10-01 2.5e5 2.9e5    31 8084.    35   36. FALSE           1.1        1.2
#> 11 2024-11-01 2.5e5 2.9e5    30 8353.    35   35. TRUE            1.2        1.2
#> 12 2024-12-01 2.5e5 2.9e5    31 8040.    35   36. FALSE           1.1        1.2
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
#> 1 2024-03-01 285562 7.5e5    91 8249.    35   35. TRUE           0.38       0.38
#> 2 2024-06-01 285591 7.5e5    91 8253.    35   35. TRUE           0.38       0.38
#> 3 2024-09-01 285469 7.5e5    92 8149.    35   35. FALSE          0.38       0.38
#> 4 2024-12-01 285639 7.5e5    92 8131.    35   35. FALSE          0.38       0.38
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
