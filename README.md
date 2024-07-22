
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

<br>

## :package: Installation

You can install `forager` from [GitHub](https://github.com/) with:

``` r
# install.packages("pak")
pak::pak("andrewallenbruce/forager")
```

## :beginner: Usage

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
```

    #> # A tibble: 15,000 × 10
    #>    claimid payer     charges balance date_ser…¹ date_rel…² date_sub…³ date_acc…⁴
    #>    <chr>   <fct>       <dbl>   <dbl> <date>     <date>     <date>     <date>    
    #>  1 00135   American      90.     90. 2024-07-06 2024-07-21 2024-07-26 2024-08-11
    #>  2 00159   New York…     87.      0  2024-07-06 2024-07-16 2024-07-18 2024-08-03
    #>  3 00180   Medicare     187.    187. 2024-07-06 2024-07-20 2024-07-25 2024-08-06
    #>  4 00195   BCBS WY      174.    174. 2024-07-06 2024-07-22 2024-07-25 2024-08-03
    #>  5 00199   Athene        32.     32. 2024-07-06 2024-07-13 2024-07-17 2024-07-25
    #>  6 00251   BCBS WY      260.    260. 2024-07-06 2024-07-10 2024-07-13 2024-07-23
    #>  7 00369   HCSC         104.    104. 2024-07-06 2024-07-16 2024-07-20 2024-07-28
    #>  8 00373   Athene       144.    144. 2024-07-06 2024-07-19 2024-07-20 2024-07-24
    #>  9 00481   Humana       119.      0  2024-07-06 2024-07-08 2024-07-09 2024-07-14
    #> 10 00522   Molina       102.    102. 2024-07-06 2024-07-19 2024-07-20 2024-07-30
    #> # ℹ 14,990 more rows
    #> # ℹ abbreviated names: ¹​date_service, ²​date_release, ³​date_submission,
    #> #   ⁴​date_acceptance
    #> # ℹ 2 more variables: date_adjudication <date>, date_reconciliation <date>

<br>

``` r
(x <- prep_claims(x))
```

    #> # A tibble: 15,000 × 13
    #>    claimid payer         charges balance date_service aging_bin   dar days_rel…¹
    #>    <chr>   <fct>           <dbl>   <dbl> <date>       <fct>     <dbl>      <dbl>
    #>  1 00001   Humana            87.     87. 2024-06-11   0-30         16          1
    #>  2 00002   Cigna            216.      0  2024-05-12   0-30         29          1
    #>  3 00003   Equitable        140.    140. 2024-06-07   0-30         24          3
    #>  4 00004   Highmark         185.    185. 2024-05-21   0-30         27          3
    #>  5 00005   HCSC              72.     72. 2024-04-27   0-30         29          6
    #>  6 00006   BCBS WY          124.    124. 2024-05-03   31-60        31          7
    #>  7 00007   Athene           230.    230. 2024-04-12   0-30         30          8
    #>  8 00008   New York Life     43.     43. 2024-06-09   31-60        50         12
    #>  9 00009   New York Life    256.    256. 2024-04-20   31-60        34         17
    #> 10 00010   Lincoln Nat'l    236.    236. 2024-05-05   31-60        49         12
    #> # ℹ 14,990 more rows
    #> # ℹ abbreviated name: ¹​days_release
    #> # ℹ 5 more variables: days_submission <dbl>, days_acceptance <dbl>,
    #> #   days_adjudication <dbl>, days_reconciliation <dbl>, dates <list>

<br>

``` r
summarise_claims(x) |> 
  glimpse()
```

    #> Rows: 1
    #> Columns: 9
    #> $ n_claims            <int> 15000
    #> $ gross_charges       <dbl> 1986374
    #> $ ending_ar           <dbl> 1323904
    #> $ mean_release        <dbl> 8.010267
    #> $ mean_submission     <dbl> 3.013267
    #> $ mean_acceptance     <dbl> 7.467933
    #> $ mean_adjudication   <dbl> 15.0508
    #> $ mean_reconciliation <dbl> 2.227745
    #> $ mean_dar            <dbl> 34.28633

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
```

    #> # A tibble: 108 × 6
    #>     year month payer     n_claims ending_ar mean_dar
    #>    <int> <int> <fct>        <int>     <dbl>    <dbl>
    #>  1  2024     4 Humana         131    11829.      35.
    #>  2  2024     5 Humana         197    16190.      34.
    #>  3  2024     6 Humana         209    18879.      34.
    #>  4  2024     7 Humana          39     2893.      33.
    #>  5  2024     4 Cigna          106    10455.      34.
    #>  6  2024     5 Cigna          208    17423.      34.
    #>  7  2024     6 Cigna          190    17407.      33.
    #>  8  2024     7 Cigna           44     3708.      36.
    #>  9  2024     4 Equitable      125    11415.      35.
    #> 10  2024     5 Equitable      202    13414.      35.
    #> # ℹ 98 more rows

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
```

    #> # A tibble: 54 × 6
    #>     year   qtr payer     n_claims ending_ar mean_dar
    #>    <int> <int> <fct>        <int>     <dbl>    <dbl>
    #>  1  2024     2 Humana         537    46899.      34.
    #>  2  2024     3 Humana          39     2893.      33.
    #>  3  2024     2 Cigna          504    45285.      34.
    #>  4  2024     3 Cigna           44     3708.      36.
    #>  5  2024     2 Equitable      519    41301.      35.
    #>  6  2024     3 Equitable       40     2298.      35 
    #>  7  2024     2 Highmark       489    41779.      35.
    #>  8  2024     3 Highmark        29     2757.      34.
    #>  9  2024     2 HCSC           547    52913.      34.
    #> 10  2024     3 HCSC            41     3544.      34.
    #> # ℹ 44 more rows

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
```

    #> # A tibble: 12 × 15
    #>    date         gct  earb  ndip   adc  dart   dar dar_pass ratio_id…¹ ratio_ac…²
    #>    <date>     <int> <int> <int> <dbl> <dbl> <dbl> <lgl>         <dbl>      <dbl>
    #>  1 2024-01-01 2.5e5 2.9e5    31 8021.    35   36. FALSE           1.1        1.2
    #>  2 2024-02-01 2.5e5 2.9e5    29 8604.    35   34. TRUE            1.2        1.2
    #>  3 2024-03-01 2.5e5 2.9e5    31 8066.    35   36. FALSE           1.1        1.2
    #>  4 2024-04-01 2.5e5 2.9e5    30 8339.    35   35. TRUE            1.2        1.2
    #>  5 2024-05-01 2.5e5 2.9e5    31 8047.    35   36. FALSE           1.1        1.2
    #>  6 2024-06-01 2.5e5 2.9e5    30 8329.    35   35. TRUE            1.2        1.2
    #>  7 2024-07-01 2.5e5 2.9e5    31 8099.    35   36. FALSE           1.1        1.2
    #>  8 2024-08-01 2.5e5 2.9e5    31 8061.    35   36. FALSE           1.1        1.2
    #>  9 2024-09-01 2.5e5 2.9e5    30 8302.    35   35. TRUE            1.2        1.2
    #> 10 2024-10-01 2.5e5 2.9e5    31 8049.    35   36. FALSE           1.1        1.2
    #> 11 2024-11-01 2.5e5 2.9e5    30 8313.    35   35. TRUE            1.2        1.2
    #> 12 2024-12-01 2.5e5 2.9e5    31 8054.    35   36. FALSE           1.1        1.2
    #> # ℹ abbreviated names: ¹​ratio_ideal, ²​ratio_actual
    #> # ℹ 5 more variables: ratio_diff <dbl>, earb_target <dbl>, earb_diff <dbl>,
    #> #   gct_pct <dbl>, earb_pct <dbl>

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
```

    #> # A tibble: 4 × 15
    #>   date         earb   gct  ndip   adc  dart   dar dar_pass ratio_id…¹ ratio_ac…²
    #>   <date>      <int> <int> <int> <dbl> <dbl> <dbl> <lgl>         <dbl>      <dbl>
    #> 1 2024-03-01 284676 7.5e5    91 8245.    35   35. TRUE           0.38       0.38
    #> 2 2024-06-01 285645 7.5e5    91 8262.    35   35. TRUE           0.38       0.38
    #> 3 2024-09-01 285768 7.5e5    92 8162.    35   35. FALSE          0.38       0.38
    #> 4 2024-12-01 285689 7.5e5    92 8133.    35   35. FALSE          0.38       0.38
    #> # ℹ abbreviated names: ¹​ratio_ideal, ²​ratio_actual
    #> # ℹ 5 more variables: ratio_diff <dbl>, earb_target <dbl>, earb_diff <dbl>,
    #> #   gct_pct <dbl>, earb_pct <dbl>

------------------------------------------------------------------------

## :balance_scale: Code of Conduct

Please note that the `forager` project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/forager/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

## :classical_building: Governance

This project is primarily maintained by [Andrew
Bruce](https://github.com/andrewallenbruce). Other authors may
occasionally assist with some of these duties.

[^1]: <https://dictionary.cambridge.org/dictionary/english/forager>

[^2]: Me.
