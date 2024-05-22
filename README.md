
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
x <- forager::generate_data(1500)

mean(x$days_in_ar, na.rm = TRUE)
#> [1] 101.8013
```

<br>

``` r
x_pvt <- x |> 
  select(clm_id:date_recon) |> 
  pivot_longer(
    cols      = starts_with("date"), 
    names_to  = "date_type", 
    values_to = "date") |> 
  mutate(date_lag = lead(date) - date,
         date_lag = lag(date_lag, order_by = date),
         date_type = str_remove_all(date_type, "date_"),
         date_type = case_match(
           date_type,
           "srvc" ~ "Service",
           "rlse" ~ "Release",
           "submit" ~ "Submission",
           "accept" ~ "Acceptance",
           "adjud" ~ "Adjudication",
           "recon" ~ "Reconciliation"),
         date_type = fct_relevel(
           date_type, 
           "Service", 
           "Release", 
           "Submission", 
           "Acceptance", 
           "Adjudication", 
           "Reconciliation"), 
         .by = clm_id)

x_pvt
#> # A tibble: 9,000 × 7
#>    clm_id payer  charges balance date_type      date       date_lag
#>    <fct>  <fct>    <dbl>   <dbl> <fct>          <date>     <drtn>  
#>  1 0030   Cigna     107.    107. Service        2023-05-21 NA days 
#>  2 0030   Cigna     107.    107. Release        2023-06-06 16 days 
#>  3 0030   Cigna     107.    107. Submission     2023-06-10  4 days 
#>  4 0030   Cigna     107.    107. Acceptance     2023-06-22 12 days 
#>  5 0030   Cigna     107.    107. Adjudication   2023-09-02 72 days 
#>  6 0030   Cigna     107.    107. Reconciliation NA         NA days 
#>  7 0046   Anthem    181.    181. Service        2023-05-21 NA days 
#>  8 0046   Anthem    181.    181. Release        2023-05-24  3 days 
#>  9 0046   Anthem    181.    181. Submission     2023-05-28  4 days 
#> 10 0046   Anthem    181.    181. Acceptance     2023-06-15 18 days 
#> # ℹ 8,990 more rows
```

<br>

``` r
x |> 
  group_by(
    year  = get_year(date_srvc),
    month = date_month_factor(date_srvc)) |> 
  summarise(
    n_claims    = n(), 
    balance     = sum(balance, na.rm = TRUE),
    days_rlse   = mean(days_rlse, na.rm = TRUE), 
    days_submit = mean(days_submit, na.rm = TRUE),
    days_accept = mean(days_accept, na.rm = TRUE),
    days_adjud  = mean(days_adjud, na.rm = TRUE),
    days_recon  = mean(days_recon, na.rm = TRUE),
    days_in_ar  = mean(days_in_ar, na.rm = TRUE), 
    .groups = "drop")
#> # A tibble: 12 × 10
#>     year month     n_claims balance days_rlse days_submit days_accept days_adjud
#>    <int> <ord>        <int>   <dbl>     <dbl>       <dbl>       <dbl>      <dbl>
#>  1  2022 June           120      0       8.06        3.06        12.8       74.0
#>  2  2022 July           136      0       8.77        3.12        12.5       73.3
#>  3  2022 August         127      0       8.08        2.96        13.0       75.2
#>  4  2022 September      131      0       8.07        3.11        13         73.5
#>  5  2022 October        124      0       7.60        2.75        12.6       74.5
#>  6  2022 November       114      0       7.86        3.07        11.9       71.7
#>  7  2022 December       142      0       7.84        3.04        12.2       77.0
#>  8  2023 January        124  10815.      7.78        2.63        12.4       73.7
#>  9  2023 February       122  12522.      7.98        2.99        12.5       77.1
#> 10  2023 March          139  13533.      7.90        2.78        11.8       74.2
#> 11  2023 April          123  14256.      7.98        2.98        12.9       76.8
#> 12  2023 May             98  10116.      8.33        3.03        12.2       72.3
#> # ℹ 2 more variables: days_recon <dbl>, days_in_ar <dbl>
```

<br>

``` r
x |> 
  group_by(
    year  = get_year(date_srvc),
    nqtr = quarter(date_srvc)) |> 
  summarise(
    n_claims    = n(), 
    balance     = sum(balance, na.rm = TRUE),
    days_rlse   = mean(days_rlse, na.rm = TRUE), 
    days_submit = mean(days_submit, na.rm = TRUE),
    days_accept = mean(days_accept, na.rm = TRUE),
    days_adjud  = mean(days_adjud, na.rm = TRUE),
    days_recon  = mean(days_recon, na.rm = TRUE),
    days_in_ar  = mean(days_in_ar, na.rm = TRUE), 
    .groups = "drop")
#> # A tibble: 5 × 10
#>    year  nqtr n_claims balance days_rlse days_submit days_accept days_adjud
#>   <int> <int>    <int>   <dbl>     <dbl>       <dbl>       <dbl>      <dbl>
#> 1  2022     2      120      0       8.06        3.06        12.8       74.0
#> 2  2022     3      394      0       8.31        3.07        12.8       74.0
#> 3  2022     4      380      0       7.77        2.96        12.2       74.6
#> 4  2023     1      385  36869.      7.89        2.80        12.2       74.9
#> 5  2023     2      221  24373.      8.13        3.00        12.6       74.8
#> # ℹ 2 more variables: days_recon <dbl>, days_in_ar <dbl>
```

## Aging Calculation

``` r
x |> 
  bin_aging(days_in_ar, bin_type = "chop") |> 
  group_by(aging_bin) |> 
  summarise(
    n_claims = n(),
    balance = roundup(sum(balance, na.rm = TRUE)), 
    .groups = "drop")
#> # A tibble: 5 × 3
#>   aging_bin  n_claims balance
#>   <fct>         <int>   <dbl>
#> 1 (30, 60]        124   5934.
#> 2 (60, 90]        453  20147.
#> 3 (90, 120]       492  19992.
#> 4 (120, 150]      345  13099.
#> 5 (150, 180]       86   2070.
```

``` r

x |> 
  bin_aging(days_in_ar, bin_type = "case") |> 
  group_by(aging_bin) |> 
  summarise(
    n_claims = n(),
    balance = roundup(sum(balance, na.rm = TRUE)), 
    .groups = "drop")
#> # A tibble: 4 × 3
#>   aging_bin n_claims balance
#>   <fct>        <int>   <dbl>
#> 1 31-60          124   5934.
#> 2 61-90          453  20147.
#> 3 91-120         492  19992.
#> 4 121+           431  15169.
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
#>  1 2024-01-01 249971 290387     1 Jan   January       1 2024. 1Q24   2024 2024.
#>  2 2024-02-01 249609 289524     2 Feb   February      1 2024. 1Q24   2024 2024.
#>  3 2024-03-01 250604 290556     3 Mar   March         1 2024. 1Q24   2024 2024.
#>  4 2024-04-01 249649 290402     4 Apr   April         2 2024. 2Q24   2024 2024.
#>  5 2024-05-01 250781 290856     5 May   May           2 2024. 2Q24   2024 2024.
#>  6 2024-06-01 250043 290617     6 Jun   June          2 2024. 2Q24   2024 2024.
#>  7 2024-07-01 249686 289370     7 Jul   July          3 2024. 3Q24   2024 2024.
#>  8 2024-08-01 250669 289316     8 Aug   August        3 2024. 3Q24   2024 2024.
#>  9 2024-09-01 249563 290971     9 Sep   September     3 2024. 3Q24   2024 2024.
#> 10 2024-10-01 249992 290669    10 Oct   October       4 2024. 4Q24   2024 2024.
#> 11 2024-11-01 249929 289751    11 Nov   November      4 2024. 4Q24   2024 2024.
#> 12 2024-12-01 250540 289247    12 Dec   December      4 2024. 4Q24   2024 2024.
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
#> 1 2024-03-01 285101     3     1 March 748742    91 8228.  34.7 TRUE      -0.350 
#> 2 2024-06-01 285522     6     2 June  750220    91 8244.  34.6 TRUE      -0.367 
#> 3 2024-09-01 285733     9     3 Sept… 749819    92 8150.  35.1 FALSE      0.0584
#> 4 2024-12-01 284571    12     4 Dece… 750898    92 8162.  34.9 TRUE      -0.134 
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
