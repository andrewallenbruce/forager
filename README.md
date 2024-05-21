
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
x <- forager::generate_data(15000)
x |> head(n = 10)
#> # A tibble: 10 × 9
#>    claim_id   date_of_service payer    ins_class balance    date_of_release
#>    <variable> <date>          <chr>    <chr>     <variable> <date>         
#>  1 00001      2022-06-20      Medicaid Secondary 191.92213  2022-07-05     
#>  2 00002      2022-12-20      BCBS     Primary   239.44870  2022-12-29     
#>  3 00003      2022-06-20      Cigna    Secondary 150.90283  2022-07-04     
#>  4 00004      2023-02-20      BCBS     Primary   100.98583  2023-03-03     
#>  5 00005      2023-03-20      Medicaid Secondary 103.16400  2023-04-02     
#>  6 00006      2022-10-20      BCBS     Primary    26.85437  2022-11-06     
#>  7 00007      2022-07-20      Cigna    Secondary 116.19070  2022-08-01     
#>  8 00008      2022-12-20      Humana   Secondary 180.63007  2022-12-30     
#>  9 00009      2022-06-20      Medicare Secondary 179.69207  2022-07-02     
#> 10 00010      2022-10-20      Anthem   Primary   141.31267  2022-11-06     
#> # ℹ 3 more variables: date_of_submission <date>, date_of_acceptance <date>,
#> #   date_of_adjudication <date>
```

<br>

``` r
x |> 
  pivot_longer(
    cols      = starts_with("date"), 
    names_to  = "date_type", 
    values_to = "date") |> 
  mutate(days_diff = lead(date) - date,
         .by = claim_id)
#> # A tibble: 75,000 × 7
#>    claim_id   payer    ins_class balance    date_type       date       days_diff
#>    <variable> <chr>    <chr>     <variable> <chr>           <date>     <drtn>   
#>  1 00001      Medicaid Secondary 191.9221   date_of_service 2022-06-20 15 days  
#>  2 00001      Medicaid Secondary 191.9221   date_of_release 2022-07-05  4 days  
#>  3 00001      Medicaid Secondary 191.9221   date_of_submis… 2022-07-09  1 days  
#>  4 00001      Medicaid Secondary 191.9221   date_of_accept… 2022-07-10 31 days  
#>  5 00001      Medicaid Secondary 191.9221   date_of_adjudi… 2022-08-10 NA days  
#>  6 00002      BCBS     Primary   239.4487   date_of_service 2022-12-20  9 days  
#>  7 00002      BCBS     Primary   239.4487   date_of_release 2022-12-29  1 days  
#>  8 00002      BCBS     Primary   239.4487   date_of_submis… 2022-12-30  5 days  
#>  9 00002      BCBS     Primary   239.4487   date_of_accept… 2023-01-04 27 days  
#> 10 00002      BCBS     Primary   239.4487   date_of_adjudi… 2023-01-31 NA days  
#> # ℹ 74,990 more rows
```

<br>

``` r
x_days <- x |> 
  count_days(date_of_service, date_of_release, prov_lag) |> 
  count_days(date_of_release, date_of_submission, bill_lag) |> 
  count_days(date_of_submission, date_of_acceptance, proc_lag) |> 
  count_days(date_of_submission, date_of_adjudication, payer_lag) |> 
  count_days(date_of_release, date_of_adjudication, dar)
```

``` r
x_days |> 
  group_by(month = date_month_factor(date_of_service)) |> 
  summarise(
    n_claims = n(), 
    balance = sum(balance),
    prov_lag = mean(prov_lag), 
    bill_lag = mean(bill_lag),
    proc_lag = mean(proc_lag),
    payer_lag = mean(payer_lag),
    dar = mean(dar), 
    .groups = "drop")
#> # A tibble: 12 × 8
#>    month     n_claims balance prov_lag bill_lag proc_lag payer_lag   dar
#>    <ord>        <int>   <dbl>    <dbl>    <dbl>    <dbl>     <dbl> <dbl>
#>  1 January       1190 163636.     11.1     2.34     3.06      33.1  35.4
#>  2 February      1262 161645.     11.0     2.24     3.12      33.0  35.3
#>  3 March         1339 171348.     10.9     2.33     3.22      33.3  35.7
#>  4 April         1164 162699.     11.0     2.41     3.13      33.2  35.6
#>  5 May           1203 161203.     11.0     2.32     3.13      33.0  35.3
#>  6 June          1269 173170.     10.9     2.36     3.03      33.1  35.5
#>  7 July          1284 174301.     11.2     2.31     3.25      33.2  35.6
#>  8 August        1243 163962.     10.9     2.39     3.12      33.2  35.5
#>  9 September     1237 167538.     11.0     2.33     3.14      33.1  35.4
#> 10 October       1287 176752.     11.0     2.31     3.10      33.2  35.5
#> 11 November      1252 166784.     11.1     2.28     3.13      33.2  35.5
#> 12 December      1270 167237.     11.3     2.35     3.12      33.2  35.6
```

<br>

``` r
x_days |> 
  group_by(qtr = quarter(date_of_service)) |> 
  summarise(
    n_claims = n(), 
    balance = sum(balance),
    prov_lag = mean(prov_lag), 
    bill_lag = mean(bill_lag),
    proc_lag = mean(proc_lag),
    payer_lag = mean(payer_lag),
    dar = mean(dar), 
    .groups = "drop")
#> # A tibble: 4 × 8
#>     qtr n_claims balance prov_lag bill_lag proc_lag payer_lag   dar
#>   <int>    <int>   <dbl>    <dbl>    <dbl>    <dbl>     <dbl> <dbl>
#> 1     1     3791 496629.     11.0     2.31     3.14      33.1  35.4
#> 2     2     3636 497072.     11.0     2.36     3.09      33.1  35.5
#> 3     3     3764 505800.     11.0     2.34     3.17      33.2  35.5
#> 4     4     3809 510773.     11.1     2.31     3.12      33.2  35.5
```

## Aging Calculation

``` r
x |> 
  count_days(date_of_service, date_of_adjudication, dar) |> 
  group_by(aging_bin = cut(dar, breaks = seq(0, 500, by = 30))) |> 
  summarise(
    n_claims = n(),
    balance = roundup(sum(balance)), 
    .groups = "drop")
#> # A tibble: 3 × 3
#>   aging_bin n_claims  balance
#>   <fct>        <int>    <dbl>
#> 1 (0,30]          16    2836.
#> 2 (30,60]      14880 1994347.
#> 3 (60,90]        104   13091.
```

``` r
x |> 
  bin_aging(date_of_service)
#> # A tibble: 15,000 × 11
#>    claim_id   date_of_service payer    ins_class balance    date_of_release
#>    <variable> <date>          <chr>    <chr>     <variable> <date>         
#>  1 00001      2022-06-20      Medicaid Secondary 191.92213  2022-07-05     
#>  2 00002      2022-12-20      BCBS     Primary   239.44870  2022-12-29     
#>  3 00003      2022-06-20      Cigna    Secondary 150.90283  2022-07-04     
#>  4 00004      2023-02-20      BCBS     Primary   100.98583  2023-03-03     
#>  5 00005      2023-03-20      Medicaid Secondary 103.16400  2023-04-02     
#>  6 00006      2022-10-20      BCBS     Primary    26.85437  2022-11-06     
#>  7 00007      2022-07-20      Cigna    Secondary 116.19070  2022-08-01     
#>  8 00008      2022-12-20      Humana   Secondary 180.63007  2022-12-30     
#>  9 00009      2022-06-20      Medicare Secondary 179.69207  2022-07-02     
#> 10 00010      2022-10-20      Anthem   Primary   141.31267  2022-11-06     
#> # ℹ 14,990 more rows
#> # ℹ 5 more variables: date_of_submission <date>, date_of_acceptance <date>,
#> #   date_of_adjudication <date>, dar <int>, aging_bin <fct>
```

## Days in AR Monthly Calculation

``` r
tibble(
  date = date_build(2024, 1:12),
  gct = abs(rnorm(12, c(365000.567, 169094.46, 297731.74), c(2:3))),
  earb = abs(rnorm(12, c(182771.32, 169633.64, 179347.72), c(2:3)))) |> 
  avg_dar(
    date, 
    gct, 
    earb, 
    dart = 35)
#> # A tibble: 12 × 27
#>    date           gct    earb  nmon mon   month     nqtr  yqtr dqtr   year  ymon
#>    <date>       <dbl>   <dbl> <dbl> <ord> <ord>    <int> <dbl> <chr> <dbl> <dbl>
#>  1 2024-01-01 364999. 182771.     1 Jan   January      1 2024. 1Q24   2024 2024.
#>  2 2024-02-01 169097. 169635.     2 Feb   February     1 2024. 1Q24   2024 2024.
#>  3 2024-03-01 297734. 179347.     3 Mar   March        1 2024. 1Q24   2024 2024.
#>  4 2024-04-01 365001. 182773.     4 Apr   April        2 2024. 2Q24   2024 2024.
#>  5 2024-05-01 169093. 169632.     5 May   May          2 2024. 2Q24   2024 2024.
#>  6 2024-06-01 297731. 179344.     6 Jun   June         2 2024. 2Q24   2024 2024.
#>  7 2024-07-01 365000. 182773.     7 Jul   July         3 2024. 3Q24   2024 2024.
#>  8 2024-08-01 169092. 169635.     8 Aug   August       3 2024. 3Q24   2024 2024.
#>  9 2024-09-01 297731. 179348.     9 Sep   Septemb…     3 2024. 3Q24   2024 2024.
#> 10 2024-10-01 365002. 182771.    10 Oct   October      4 2024. 4Q24   2024 2024.
#> 11 2024-11-01 169094. 169631.    11 Nov   November     4 2024. 4Q24   2024 2024.
#> 12 2024-12-01 297729. 179347.    12 Dec   December     4 2024. 4Q24   2024 2024.
#> # ℹ 16 more variables: myear <chr>, nhalf <int>, yhalf <dbl>, dhalf <chr>,
#> #   ndip <int>, adc <dbl>, dar <dbl>, dar_pass <lgl>, dar_diff <dbl>,
#> #   ratio_actual <dbl>, ratio_ideal <dbl>, ratio_diff <dbl>, earb_target <dbl>,
#> #   earb_dec_abs <dbl>, earb_dec_pct <dbl>, earb_gct_diff <dbl>
```

<br>

## Days in AR Quarterly Calculation

``` r
tibble(
  date = date_build(2024, 1:12),
  gct = abs(rnorm(12, c(365000.567, 169094.46, 297731.74), c(2:3))),
  earb = abs(rnorm(12, c(182771.32, 169633.64, 179347.72), c(2:3)))) |> 
  avg_dar(date, 
          gct, 
          earb, 
          dart = 35, 
          period = "quarter")
```

# A tibble: 4 × 18

date earb nmon nqtr month gct ndip adc dar dar_pass dar_diff <date>
<dbl> <dbl> <int> <ord> <dbl> <int> <dbl> <dbl> <lgl> <dbl> 1 2024-03-01
1.79e5 3 1 March 8.32e5 91 9141. 19.6 TRUE -15.4 2 2024-06-01 1.79e5 6 2
June 8.32e5 91 9141. 19.6 TRUE -15.4 3 2024-09-01 1.79e5 9 3 Sept…
8.32e5 92 9042. 19.8 TRUE -15.2 4 2024-12-01 1.79e5 12 4 Dece… 8.32e5 92
9042. 19.8 TRUE -15.2 \# ℹ 7 more variables: ratio_actual <dbl>,
ratio_ideal <dbl>, ratio_diff <dbl>, \# earb_target <dbl>, earb_dec_abs
<dbl>, earb_dec_pct <dbl>, \# earb_gct_diff <dbl>

## Code of Conduct

Please note that the `forager` project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/forager/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: <https://dictionary.cambridge.org/dictionary/english/forager>

[^2]: Me.
