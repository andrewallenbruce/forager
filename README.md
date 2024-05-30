
<!-- README.md is generated from README.Rmd. Please edit that file -->

# forager <a href="https://andrewallenbruce.github.io/forager/"><img src="man/figures/logo.svg" align="right" height="200"/></a>

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
[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://choosealicense.com/licenses/mit/)
[![code
size](https://img.shields.io/github/languages/code-size/andrewallenbruce/forager.svg)](https://github.com/andrewallenbruce/forager)
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

    * <b>Provider Lag</b>:    Date of Service - Date of Release
    * <b>Billing Lag</b>:     Date of Release - Date of Submission
    * <b>Acceptance Lag</b>:  Date of Submission - Date of Acceptance
    * <b>Payment Lag</b>:     Date of Acceptance - Date of Adjudication
    * <b>Days in AR</b>:      Date of Release - Date of Adjudication*

<br>

``` r
x <- forager::generate_data(1500)
x
#> # A tibble: 1,500 × 10
#>    claimid payer    charges balance date_service date_release date_submission
#>    <fct>   <fct>      <dbl>   <dbl> <date>       <date>       <date>         
#>  1 0005    Cigna      265.      0   2024-05-15   2024-05-20   2024-05-22     
#>  2 0031    UHC         25.8    25.8 2024-05-15   2024-05-15   2024-05-15     
#>  3 0053    Cigna       85.6    85.6 2024-05-15   2024-05-20   2024-05-24     
#>  4 0127    Humana      21.5     0   2024-05-15   2024-05-21   2024-05-23     
#>  5 0366    Cigna       43.1    43.1 2024-05-15   2024-05-24   2024-05-24     
#>  6 0370    BCBS        80.9    80.9 2024-05-15   2024-05-26   2024-06-01     
#>  7 0496    Medicare    64.4    64.4 2024-05-15   2024-05-19   2024-05-19     
#>  8 0564    Anthem      14.2    14.2 2024-05-15   2024-05-20   2024-05-23     
#>  9 0591    Humana      52.2    52.2 2024-05-15   2024-05-21   2024-05-22     
#> 10 0733    Centene    121.    121.  2024-05-15   2024-05-31   2024-06-05     
#> 11 0774    Cigna       74.6    74.6 2024-05-15   2024-05-24   2024-05-28     
#> 12 0841    BCBS        31.2     0   2024-05-15   2024-05-17   2024-05-18     
#> 13 0981    Anthem      36.2    36.2 2024-05-15   2024-05-23   2024-05-23     
#> 14 1039    UHC        345.    345.  2024-05-15   2024-05-22   2024-05-27     
#> 15 1050    Medicare    92.4    92.4 2024-05-15   2024-05-26   2024-06-05     
#> 16 1148    Medicaid    53.4     0   2024-05-15   2024-05-25   2024-05-27     
#> 17 1395    Cigna      458.    458.  2024-05-15   2024-06-05   2024-06-09     
#> 18 1419    UHC        312.    312.  2024-05-15   2024-05-25   2024-05-28     
#> 19 1453    Cigna      134.      0   2024-05-15   2024-05-30   2024-06-04     
#> 20 0068    Humana      59.8    59.8 2024-05-14   2024-05-18   2024-05-22     
#> # ℹ 1,480 more rows
#> # ℹ 3 more variables: date_acceptance <date>, date_adjudication <date>,
#> #   date_reconciliation <date>
```

<br>

``` r
x_pvt <- x |> 
  select(claimid:date_reconciliation) |> 
  pivot_longer(
    cols      = starts_with("date"), 
    names_to  = "date_type", 
    values_to = "date") |> 
  mutate(
    date_lag = lead(date) - date,
    date_lag = lag(date_lag, order_by = date),
    date_type = stringr::str_to_sentence(
      str_remove_all(date_type, "date_")),
    date_type = fct_relevel(
      date_type, 
      "Service", 
      "Release",
      "Submission", 
      "Acceptance", 
      "Adjudication", 
      "Reconciliation"), 
    .by = claimid)

x_pvt
#> # A tibble: 9,000 × 7
#>    claimid payer charges balance date_type      date       date_lag
#>    <fct>   <fct>   <dbl>   <dbl> <fct>          <date>     <drtn>  
#>  1 0005    Cigna   265.      0   Service        2024-05-15 NA days 
#>  2 0005    Cigna   265.      0   Release        2024-05-20  5 days 
#>  3 0005    Cigna   265.      0   Submission     2024-05-22  2 days 
#>  4 0005    Cigna   265.      0   Acceptance     2024-05-30  8 days 
#>  5 0005    Cigna   265.      0   Adjudication   2024-07-02 33 days 
#>  6 0005    Cigna   265.      0   Reconciliation 2024-07-02  0 days 
#>  7 0031    UHC      25.8    25.8 Service        2024-05-15 NA days 
#>  8 0031    UHC      25.8    25.8 Release        2024-05-15  0 days 
#>  9 0031    UHC      25.8    25.8 Submission     2024-05-15  0 days 
#> 10 0031    UHC      25.8    25.8 Acceptance     2024-05-29 14 days 
#> # ℹ 8,990 more rows
```

<br>

``` r
x |> 
  group_by(
    year = get_year(date_service),
    month = date_month_factor(date_service)) |> 
  summarise(
    Claims = n(), 
    Balance = sum(balance, na.rm = TRUE),
    Release = as.numeric(mean((date_release - date_service), na.rm = TRUE)), 
    Submission = as.numeric(mean((date_submission - date_release), na.rm = TRUE)),
    Acceptance = as.numeric(mean((date_acceptance - date_submission), na.rm = TRUE)),
    Adjudication  = as.numeric(mean((date_adjudication - date_acceptance), na.rm = TRUE)),
    Reconciliation = as.numeric(mean((date_reconciliation - date_adjudication), na.rm = TRUE)),
    Average_DAR = as.numeric(mean((date_reconciliation - date_service), na.rm = TRUE)), 
    .groups = "drop")
#> # A tibble: 4 × 10
#>    year month    Claims Balance Release Submission Acceptance Adjudication
#>   <int> <ord>     <int>   <dbl>   <dbl>      <dbl>      <dbl>        <dbl>
#> 1  2024 February    195  17437.    8.01       3.16       13.0         75.1
#> 2  2024 March       518  49572.    8.12       3.16       12.5         73.4
#> 3  2024 April       530  49209.    7.95       3.02       12.6         75.4
#> 4  2024 May         257  23824.    7.93       3.16       12.4         74.5
#> # ℹ 2 more variables: Reconciliation <dbl>, Average_DAR <dbl>
```

<br>

``` r
x |> 
  group_by(
    year  = get_year(date_service),
    nqtr = quarter(date_service)) |> 
  summarise(
    Claims = n(), 
    Balance = sum(balance, na.rm = TRUE),
    Release = as.numeric(mean((date_release - date_service), na.rm = TRUE)), 
    Submission = as.numeric(mean((date_submission - date_release), na.rm = TRUE)),
    Acceptance = as.numeric(mean((date_acceptance - date_submission), na.rm = TRUE)),
    Adjudication  = as.numeric(mean((date_adjudication - date_acceptance), na.rm = TRUE)),
    Reconciliation = as.numeric(mean((date_reconciliation - date_adjudication), na.rm = TRUE)),
    Average_DAR = as.numeric(mean((date_reconciliation - date_service), na.rm = TRUE)), 
    .groups = "drop")
#> # A tibble: 2 × 10
#>    year  nqtr Claims Balance Release Submission Acceptance Adjudication
#>   <int> <int>  <int>   <dbl>   <dbl>      <dbl>      <dbl>        <dbl>
#> 1  2024     1    713  67009.    8.09       3.16       12.6         73.9
#> 2  2024     2    787  73033.    7.95       3.06       12.5         75.1
#> # ℹ 2 more variables: Reconciliation <dbl>, Average_DAR <dbl>
```

## Aging Calculation

``` r
x |> 
  mutate(days_in_ar = as.numeric((date_reconciliation - date_service))) |> 
  bin_aging(days_in_ar, bin_type = "chop") |> 
  group_by(aging_bin) |> 
  summarise(
    n_claims = n(),
    balance = roundup(sum(balance, na.rm = TRUE)), 
    .groups = "drop")
#> # A tibble: 7 × 3
#>   aging_bin  n_claims balance
#>   <fct>         <int>   <dbl>
#> 1 (30, 60]         39      0 
#> 2 (60, 90]        129      0 
#> 3 (90, 120]       147      0 
#> 4 (120, 150]      105      0 
#> 5 (150, 180]       21      0 
#> 6 (180, 210]        1      0 
#> 7 <NA>           1058 140042.
```

``` r

x |> 
  mutate(days_in_ar = as.numeric((date_reconciliation - date_service))) |> 
  bin_aging(days_in_ar, bin_type = "case") |> 
  group_by(aging_bin) |> 
  summarise(
    n_claims = n(),
    balance = roundup(sum(balance, na.rm = TRUE)), 
    .groups = "drop")
#> # A tibble: 5 × 3
#>   aging_bin n_claims balance
#>   <fct>        <int>   <dbl>
#> 1 31-60           39      0 
#> 2 61-90          129      0 
#> 3 91-120         147      0 
#> 4 121+           127      0 
#> 5 <NA>          1058 140042.
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
#> # A tibble: 12 × 27
#>    date          gct   earb  nmon mon   month      nqtr  yqtr dqtr   year  ymon
#>    <date>      <int>  <int> <dbl> <ord> <ord>     <int> <dbl> <chr> <dbl> <dbl>
#>  1 2024-01-01 249588 289611     1 Jan   January       1 2024. 1Q24   2024 2024.
#>  2 2024-02-01 249478 290606     2 Feb   February      1 2024. 1Q24   2024 2024.
#>  3 2024-03-01 250528 290108     3 Mar   March         1 2024. 1Q24   2024 2024.
#>  4 2024-04-01 250502 290315     4 Apr   April         2 2024. 2Q24   2024 2024.
#>  5 2024-05-01 249248 288934     5 May   May           2 2024. 2Q24   2024 2024.
#>  6 2024-06-01 250733 289835     6 Jun   June          2 2024. 2Q24   2024 2024.
#>  7 2024-07-01 249966 290830     7 Jul   July          3 2024. 3Q24   2024 2024.
#>  8 2024-08-01 249868 289768     8 Aug   August        3 2024. 3Q24   2024 2024.
#>  9 2024-09-01 249620 289403     9 Sep   September     3 2024. 3Q24   2024 2024.
#> 10 2024-10-01 249388 290610    10 Oct   October       4 2024. 4Q24   2024 2024.
#> 11 2024-11-01 250213 289555    11 Nov   November      4 2024. 4Q24   2024 2024.
#> 12 2024-12-01 250364 289094    12 Dec   December      4 2024. 4Q24   2024 2024.
#> # ℹ 16 more variables: myear <chr>, nhalf <int>, yhalf <dbl>, dhalf <chr>,
#> #   ndip <int>, adc <dbl>, dar <dbl>, dar_pass <lgl>, dar_diff <dbl>,
#> #   ratio_actual <dbl>, ratio_ideal <dbl>, ratio_diff <dbl>, earb_target <dbl>,
#> #   earb_dec_abs <dbl>, earb_dec_pct <dbl>, earb_gct_diff <int>
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
#> # A tibble: 4 × 18
#>   date         earb  nmon  nqtr month    gct  ndip   adc   dar dar_pass dar_diff
#>   <date>      <int> <dbl> <int> <ord>  <int> <int> <dbl> <dbl> <lgl>       <dbl>
#> 1 2024-03-01 285303     3     1 March 750838    91 8251.  34.6 TRUE      -0.422 
#> 2 2024-06-01 286436     6     2 June  750307    91 8245.  34.7 TRUE      -0.260 
#> 3 2024-09-01 284659     9     3 Sept… 750146    92 8154.  34.9 TRUE      -0.0886
#> 4 2024-12-01 285243    12     4 Dece… 749404    92 8146.  35.0 FALSE      0.0176
#> # ℹ 7 more variables: ratio_actual <dbl>, ratio_ideal <dbl>, ratio_diff <dbl>,
#> #   earb_target <dbl>, earb_dec_abs <dbl>, earb_dec_pct <dbl>,
#> #   earb_gct_diff <int>
```

## Code of Conduct

Please note that the `forager` project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/forager/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: <https://dictionary.cambridge.org/dictionary/english/forager>

[^2]: Me.
