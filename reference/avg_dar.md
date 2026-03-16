# Calculate Average Days in AR

Calculate Average Days in AR

## Usage

``` r
avg_dar(df, date, gct, earb, dart = 35, by = c("month", "quarter"))
```

## Arguments

- df:

  `<data.frame>` or `<tibble>`

- date:

  column of `<date>`s

- gct:

  `<dbl>` column of total Gross Charges

- earb:

  `<dbl>` column of ending accounts receivable balances

- dart:

  `[numeric]` Target Days in AR, default is `35` days

- by:

  `[character]` string specifying the calculation period; one of
  `"month"`, `"quarter"`, or `"year"`; defaults to `"month"`

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
avg_dar(df     = dar_ex(),
        date   = date,
        gct    = gross_charges,
        earb   = ending_ar,
        dart   = 35,
        by = "month")
#> # A tibble: 12 × 15
#>    date         gct  earb  ndip   adc  dart   dar dar_pass ratio_id…¹ ratio_ac…²
#>    <date>     <dbl> <dbl> <int> <dbl> <dbl> <dbl> <lgl>         <dbl>      <dbl>
#>  1 2024-01-01 3.3e5 2.9e5    31 1.1e4    35   27. TRUE            1.1       0.88
#>  2 2024-02-01 3.0e5 3.1e5    29 1.0e4    35   30. TRUE            1.2       1.0 
#>  3 2024-03-01 2.0e5 2.5e5    31 6.4e3    35   40. FALSE           1.1       1.3 
#>  4 2024-04-01 1.9e5 1.8e5    30 6.2e3    35   30. TRUE            1.2       0.99
#>  5 2024-05-01 1.2e5 2.0e5    31 4.0e3    35   51. FALSE           1.1       1.7 
#>  6 2024-06-01 1.3e5 2.0e5    30 4.4e3    35   46. FALSE           1.2       1.5 
#>  7 2024-07-01 1.5e5 1.8e5    31 5.0e3    35   37. FALSE           1.1       1.2 
#>  8 2024-08-01 1.6e5 1.7e5    31 5.1e3    35   33. TRUE            1.1       1.1 
#>  9 2024-09-01 1.5e5 1.8e5    30 4.9e3    35   37. FALSE           1.2       1.2 
#> 10 2024-10-01 1.6e5 1.8e5    31 5.3e3    35   34. TRUE            1.1       1.1 
#> 11 2024-11-01 1.5e5 1.6e5    30 5.0e3    35   32. TRUE            1.2       1.1 
#> 12 2024-12-01 1.7e5 2.0e5    31 5.5e3    35   37. FALSE           1.1       1.2 
#> # ℹ abbreviated names: ¹​ratio_ideal, ²​ratio_actual
#> # ℹ 5 more variables: ratio_diff <dbl>, earb_target <dbl>, earb_diff <dbl>,
#> #   gct_pct <dbl>, earb_pct <dbl>

avg_dar(df     = dar_ex(),
        date   = date,
        gct    = gross_charges,
        earb   = ending_ar,
        dart   = 35,
        by = "quarter")
#> # A tibble: 4 × 15
#>   date         earb   gct  ndip   adc  dart   dar dar_pass ratio_id…¹ ratio_ac…²
#>   <date>      <dbl> <dbl> <int> <dbl> <dbl> <dbl> <lgl>         <dbl>      <dbl>
#> 1 2024-03-01  2.5e5 8.2e5    91 9037.    35   28. TRUE           0.38       0.31
#> 2 2024-06-01  2.0e5 4.4e5    91 4848.    35   42. FALSE          0.38       0.46
#> 3 2024-09-01  1.8e5 4.6e5    92 4977.    35   36. FALSE          0.38       0.39
#> 4 2024-12-01  2.0e5 4.8e5    92 5264.    35   38. FALSE          0.38       0.41
#> # ℹ abbreviated names: ¹​ratio_ideal, ²​ratio_actual
#> # ℹ 5 more variables: ratio_diff <dbl>, earb_target <dbl>, earb_diff <dbl>,
#> #   gct_pct <dbl>, earb_pct <dbl>
```
