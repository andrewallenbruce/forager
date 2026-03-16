# Getting started

### Introduction

Date of Service (DOS) to Date of Reconciliation is a critical metric for
Revenue Cycle Management. The time it takes to process a claim can have
a significant impact on cash flow. This vignette demonstrates how to
calculate the average days in accounts receivable (AR) for a medical
practice.

### Definitions

- Date of Service: The date a patient receives medical services.
- Date of Release: The date a claim is released for billing.
- Date of Submission: The date a claim is submitted to the payer.
- Date of Acceptance: The date a claim is accepted by the payer.
- Date of Adjudication: The date a claim is adjudicated by the payer.
- Date of Reconciliation: The date a claim is reconciled by the medical
  practice.

### The Lifecycle of a Claim

- **Provider Lag**: Date of Service - Date of Release
- **Billing Lag**: Date of Release - Date of Submission
- **Acceptance Lag**: Date of Submission - Date of Acceptance
- **Payment Lag**: Date of Acceptance - Date of Adjudication
- **Days in AR**: Date of Release - Date of Adjudication

  

``` r
(x <- mock_claims(15000))
```

    #> Error in `loadNamespace()`:
    #> ! there is no package called 'fastplyr'

  

``` r
(x <- prep_claims(x))
```

    #> Error:
    #> ! object 'x' not found

  

``` r
summarise_claims(x) |> 
  dplyr::glimpse()
```

    #> Error:
    #> ! object 'x' not found

``` r
x |> 
  dplyr::group_by(
    year = clock::get_year(date_service),
    month = clock::get_month(date_service)) |>
  summarise_claims()
```

    #> Error:
    #> ! object 'x' not found

  

``` r
x |> 
  dplyr::group_by(
    year = clock::get_year(date_service),
    quarter = lubridate::quarter(date_service)) |>
  summarise_claims()
```

    #> Error:
    #> ! object 'x' not found

``` r
x |> 
  dplyr::group_by(
    year = clock::get_year(date_service),
    month = clock::get_month(date_service),
    aging_bin) |>
  summarise_claims()
```

    #> Error:
    #> ! object 'x' not found

  

``` r
x |> 
  dplyr::group_by(
    year = clock::get_year(date_service),
    quarter = lubridate::quarter(date_service),
    payer) |>
  summarise_claims()
```

    #> Error:
    #> ! object 'x' not found

## Average Days in AR

### Monthly Calculation

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
    #>  1 2024-01-01 2.5e5 2.9e5    31 8042.    35   36. FALSE           1.1        1.2
    #>  2 2024-02-01 2.5e5 2.9e5    29 8603.    35   34. TRUE            1.2        1.2
    #>  3 2024-03-01 2.5e5 2.9e5    31 8064.    35   36. FALSE           1.1        1.2
    #>  4 2024-04-01 2.5e5 2.9e5    30 8346.    35   35. TRUE            1.2        1.2
    #>  5 2024-05-01 2.5e5 2.9e5    31 8050.    35   36. FALSE           1.1        1.2
    #>  6 2024-06-01 2.5e5 2.9e5    30 8329.    35   35. TRUE            1.2        1.2
    #>  7 2024-07-01 2.5e5 2.9e5    31 8040.    35   36. FALSE           1.1        1.2
    #>  8 2024-08-01 2.5e5 2.9e5    31 8056.    35   36. FALSE           1.1        1.2
    #>  9 2024-09-01 2.5e5 2.9e5    30 8319.    35   35. TRUE            1.2        1.2
    #> 10 2024-10-01 2.5e5 2.9e5    31 8038.    35   36. FALSE           1.1        1.2
    #> 11 2024-11-01 2.5e5 2.9e5    30 8342.    35   35. TRUE            1.2        1.2
    #> 12 2024-12-01 2.5e5 2.9e5    31 8053.    35   36. FALSE           1.1        1.2
    #> # ℹ abbreviated names: ¹​ratio_ideal, ²​ratio_actual
    #> # ℹ 5 more variables: ratio_diff <dbl>, earb_target <dbl>, earb_diff <dbl>,
    #> #   gct_pct <dbl>, earb_pct <dbl>

  

### Quarterly Calculation

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
    #> 1 2024-03-01 284480 7.5e5    91 8253.    35   34. TRUE           0.38       0.38
    #> 2 2024-06-01 285515 7.5e5    91 8239.    35   35. TRUE           0.38       0.38
    #> 3 2024-09-01 284292 7.5e5    92 8155.    35   35. TRUE           0.38       0.38
    #> 4 2024-12-01 285693 7.5e5    92 8163.    35   35. TRUE           0.38       0.38
    #> # ℹ abbreviated names: ¹​ratio_ideal, ²​ratio_actual
    #> # ℹ 5 more variables: ratio_diff <dbl>, earb_target <dbl>, earb_diff <dbl>,
    #> #   gct_pct <dbl>, earb_pct <dbl>

  
