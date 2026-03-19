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

    #> # A tibble: 15,000 × 10
    #>    id    payer    charges date_srv   date_rel   date_sub   date_acc   date_adj  
    #>    <chr> <fct>      <dbl> <date>     <date>     <date>     <date>     <date>    
    #>  1 04173 Humana      116. 2025-03-04 2025-03-13 2025-03-14 2025-03-23 2025-04-07
    #>  2 12227 Oscar       182. 2025-03-04 2025-03-13 2025-03-13 2025-03-21 2025-04-03
    #>  3 12277 UHC         102. 2025-03-04 2025-03-11 2025-03-13 2025-03-19 2025-04-01
    #>  4 13363 Omaha        31. 2025-03-04 2025-03-13 2025-03-15 2025-03-20 2025-04-11
    #>  5 00067 Mass Mu…     90. 2025-03-04 2025-03-12 2025-03-18 2025-03-25 2025-04-09
    #>  6 14354 Athene       97. 2025-03-04 2025-03-13 2025-03-14 2025-03-23 2025-04-06
    #>  7 06940 Aetna       168. 2025-03-04 2025-03-14 2025-03-19 2025-03-27 2025-04-21
    #>  8 06460 BCBS         16. 2025-03-04 2025-03-13 2025-03-22 2025-03-24 2025-04-11
    #>  9 08288 Equitab…    182. 2025-03-04 2025-03-12 2025-03-14 2025-03-22 2025-04-06
    #> 10 13155 Humana       87. 2025-03-04 2025-03-12 2025-03-13 2025-03-18 2025-03-30
    #> # ℹ 14,990 more rows
    #> # ℹ 2 more variables: date_rec <date>, balance <dbl>

  

``` r
(x <- prep_claims(x))
```

    #> # A tibble: 15,000 × 13
    #>    id    payer    charges balance date_srv   aging_bin   dar days_rel days_sub
    #>    <chr> <fct>      <dbl>   <dbl> <date>     <fct>     <int>    <int>    <int>
    #>  1 00001 NY Life      93.     93. 2025-01-07 31-60        44       10        4
    #>  2 00002 Wellcare    192.    192. 2025-02-06 31-60        31        9        0
    #>  3 00003 Allianz      23.     23. 2025-02-02 31-60        33        8        4
    #>  4 00004 Oscar        40.      0  2025-01-27 31-60        37        9        7
    #>  5 00005 Omaha        51.      0  2025-02-14 31-60        32       10        0
    #>  6 00006 Cigna        99.     99. 2025-02-23 31-60        53       10        9
    #>  7 00007 Allianz     208.    208. 2025-01-04 31-60        34       10        0
    #>  8 00008 Cigna        68.      0  2025-01-18 0-30         25       10        1
    #>  9 00009 Medicare    135.    135. 2025-02-09 31-60        37        9        3
    #> 10 00010 Highmark     99.      0  2025-01-21 31-60        34        8        4
    #> # ℹ 14,990 more rows
    #> # ℹ 4 more variables: days_acc <int>, days_adj <int>, days_rec <int>,
    #> #   dates <list>

  

``` r
summarise_claims(x) |> 
  dplyr::glimpse()
```

    #> Rows: 1
    #> Columns: 9
    #> $ n_claims      <int> 15000
    #> $ gross_charges <dbl> 1996764
    #> $ ending_ar     <dbl> 1105623
    #> $ mean_rel      <dbl> 8.502133
    #> $ mean_sub      <dbl> 2.9982
    #> $ mean_acc      <dbl> 7.504933
    #> $ mean_adj      <dbl> 15.02673
    #> $ mean_rec      <dbl> NA
    #> $ mean_dar      <dbl> 35.14327

``` r
x |> 
  dplyr::group_by(
    year = clock::get_year(date_srv),
    month = clock::get_month(date_srv)) |>
  summarise_claims()
```

    #> # A tibble: 4 × 11
    #>    year month n_claims gross_cha…¹ ending_ar mean_rel mean_sub mean_acc mean_adj
    #>   <int> <int>    <int>       <dbl>     <dbl>    <dbl>    <dbl>    <dbl>    <dbl>
    #> 1  2024    12     2407     326021.        0       8.5      3.0      7.6      15.
    #> 2  2025     1     6173     823056.   552455.      8.5      3.0      7.4      15.
    #> 3  2025     2     5628     744339.   482550.      8.5      3.0      7.5      15.
    #> 4  2025     3      792     103349.    70618.      8.5      3.0      7.4      15.
    #> # ℹ abbreviated name: ¹​gross_charges
    #> # ℹ 2 more variables: mean_rec <dbl>, mean_dar <dbl>

  

``` r
x |> 
  dplyr::group_by(
    year = clock::get_year(date_srv),
    quarter = lubridate::quarter(date_srv)) |>
  summarise_claims()
```

    #> # A tibble: 2 × 11
    #>    year quarter n_claims gross_charges ending_ar mean_rel mean_sub mean_acc
    #>   <int>   <int>    <int>         <dbl>     <dbl>    <dbl>    <dbl>    <dbl>
    #> 1  2024       4     2407       326021.        0       8.5      3.0      7.6
    #> 2  2025       1    12593      1670744.  1105623.      8.5      3.0      7.5
    #> # ℹ 3 more variables: mean_adj <dbl>, mean_rec <dbl>, mean_dar <dbl>

``` r
x |> 
  dplyr::group_by(
    year = clock::get_year(date_srv),
    month = clock::get_month(date_srv),
    aging_bin) |>
  summarise_claims()
```

    #> # A tibble: 11 × 12
    #>     year month aging_bin n_claims gross_charges ending_ar mean_rel mean_sub
    #>    <int> <int> <fct>        <int>         <dbl>     <dbl>    <dbl>    <dbl>
    #>  1  2024    12 0-30           447        62085.        0       8.3      1.6
    #>  2  2024    12 31-60         1958       263634.        0       8.6      3.3
    #>  3  2024    12 61-90            2          301.        0       8.5      9  
    #>  4  2025     1 0-30          1737       229872.   162803.      8.3      2.1
    #>  5  2025     1 31-60         4433       592954.   389652.      8.6      3.4
    #>  6  2025     1 61-90            3          230.        0       9.3      7  
    #>  7  2025     2 0-30          1508       194705.   134900.      8.3      2.1
    #>  8  2025     2 31-60         4117       549379.   347524.      8.6      3.3
    #>  9  2025     2 61-90            3          255.      127.      8.3      5  
    #> 10  2025     3 0-30           222        29624.    20000.      8.3      2.1
    #> 11  2025     3 31-60          570        73724.    50617.      8.6      3.3
    #> # ℹ 4 more variables: mean_acc <dbl>, mean_adj <dbl>, mean_rec <dbl>,
    #> #   mean_dar <dbl>

  

``` r
x |> 
  dplyr::group_by(
    year = clock::get_year(date_srv),
    quarter = lubridate::quarter(date_srv),
    payer) |>
  summarise_claims()
```

    #> # A tibble: 48 × 12
    #>     year quarter payer  n_claims gross_ch…¹ ending_ar mean_rel mean_sub mean_acc
    #>    <int>   <int> <fct>     <int>      <dbl>     <dbl>    <dbl>    <dbl>    <dbl>
    #>  1  2024       4 Aetna        95     13318.         0      8.5      3.0      7.8
    #>  2  2024       4 Allia…       96     13480.         0      8.5      2.8      7.8
    #>  3  2024       4 Ameri…      111     13436.         0      8.5      3.3      7.8
    #>  4  2024       4 Athene       95     12110.         0      8.5      2.7      7.5
    #>  5  2024       4 BCBS        101     14017.         0      8.4      3        7.7
    #>  6  2024       4 Bright      109     14619.         0      8.6      3.0      7.7
    #>  7  2024       4 Cente…       96     14606.         0      8.5      3.1      7.4
    #>  8  2024       4 Cigna        93     13443.         0      8.5      3.0      7.7
    #>  9  2024       4 Eleva…       91     12430.         0      8.6      2.6      8.2
    #> 10  2024       4 Equit…      115     16889.         0      8.3      3.2      7.8
    #> # ℹ 38 more rows
    #> # ℹ abbreviated name: ¹​gross_charges
    #> # ℹ 3 more variables: mean_adj <dbl>, mean_rec <dbl>, mean_dar <dbl>

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
    #>  1 2024-01-01 2.5e5 2.9e5    31 8058.    35   36. FALSE           1.1        1.2
    #>  2 2024-02-01 2.5e5 2.9e5    29 8608.    35   34. TRUE            1.2        1.2
    #>  3 2024-03-01 2.5e5 2.9e5    31 8052.    35   36. FALSE           1.1        1.2
    #>  4 2024-04-01 2.5e5 2.9e5    30 8343.    35   35. TRUE            1.2        1.2
    #>  5 2024-05-01 2.5e5 2.9e5    31 8076.    35   36. FALSE           1.1        1.2
    #>  6 2024-06-01 2.5e5 2.9e5    30 8310.    35   35. TRUE            1.2        1.2
    #>  7 2024-07-01 2.5e5 2.9e5    31 8049.    35   36. FALSE           1.1        1.2
    #>  8 2024-08-01 2.5e5 2.9e5    31 8084.    35   36. FALSE           1.1        1.2
    #>  9 2024-09-01 2.5e5 2.9e5    30 8341.    35   35. TRUE            1.2        1.2
    #> 10 2024-10-01 2.5e5 2.9e5    31 8057.    35   36. FALSE           1.1        1.2
    #> 11 2024-11-01 2.5e5 2.9e5    30 8345.    35   35. TRUE            1.2        1.2
    #> 12 2024-12-01 2.5e5 2.9e5    31 8068.    35   36. FALSE           1.1        1.2
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
    #> 1 2024-03-01 285574 7.5e5    91 8236.    35   35. TRUE           0.38       0.38
    #> 2 2024-06-01 285758 7.5e5    91 8240.    35   35. TRUE           0.38       0.38
    #> 3 2024-09-01 285994 7.5e5    92 8149.    35   35. FALSE          0.38       0.38
    #> 4 2024-12-01 285351 7.5e5    92 8142.    35   35. FALSE          0.38       0.38
    #> # ℹ abbreviated names: ¹​ratio_ideal, ²​ratio_actual
    #> # ℹ 5 more variables: ratio_diff <dbl>, earb_target <dbl>, earb_diff <dbl>,
    #> #   gct_pct <dbl>, earb_pct <dbl>

  
