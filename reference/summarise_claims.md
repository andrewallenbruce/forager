# Summarise mock coding/billing data frame

Summarise mock coding/billing data frame

## Usage

``` r
summarise_claims(df, vars = c(dplyr::starts_with("days_"), dar))
```

## Arguments

- df:

  `[data.frame]` data generated from `prep_claims(mock_claims())`

- vars:

  `[character]` variables to summarise, e.g. `c(days_srv, days_rec)`

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
x <- mock_claims(5000)
x
#> # A tibble: 5,000 × 10
#>    id    payer    charges date_srv   date_rel   date_sub   date_acc   date_adj  
#>    <chr> <fct>      <dbl> <date>     <date>     <date>     <date>     <date>    
#>  1 1374  Lincoln     301. 2025-03-04 2025-03-11 2025-03-11 2025-03-18 2025-03-28
#>  2 4063  Lincoln      39. 2025-03-04 2025-03-14 2025-03-15 2025-03-17 2025-04-02
#>  3 1120  Oscar       120. 2025-03-04 2025-03-13 2025-03-22 2025-03-28 2025-04-07
#>  4 3714  Aetna        14. 2025-03-04 2025-03-14 2025-03-15 2025-03-19 2025-04-07
#>  5 2853  Medicaid     19. 2025-03-04 2025-03-12 2025-03-14 2025-03-22 2025-04-11
#>  6 2359  Oscar        17. 2025-03-04 2025-03-15 2025-03-19 2025-03-26 2025-04-08
#>  7 2859  Molina      148. 2025-03-04 2025-03-12 2025-03-16 2025-03-23 2025-04-11
#>  8 2702  Allianz     154. 2025-03-04 2025-03-11 2025-03-14 2025-03-20 2025-03-28
#>  9 2579  Molina      248. 2025-03-04 2025-03-13 2025-03-13 2025-03-21 2025-04-04
#> 10 4867  GuideWe…     77. 2025-03-04 2025-03-11 2025-03-11 2025-03-20 2025-03-30
#> # ℹ 4,990 more rows
#> # ℹ 2 more variables: date_rec <date>, balance <dbl>

x <- prep_claims(x)
x
#> # A tibble: 5,000 × 13
#>    id    payer      charges balance date_srv   aging_bin   dar days_rel days_sub
#>    <chr> <fct>        <dbl>   <dbl> <date>     <fct>     <int>    <int>    <int>
#>  1 0001  Omaha         374.    374. 2025-01-27 31-60        34        8        4
#>  2 0002  Highmark      105.      0  2024-12-20 0-30         29        7        2
#>  3 0003  Cigna         185.      0  2024-12-30 31-60        42        6        2
#>  4 0004  Bright        139.    139. 2025-01-11 31-60        34       10        1
#>  5 0005  Mass Mutu…    165.      0  2025-02-15 31-60        37       10        2
#>  6 0006  Lincoln       256.    256. 2025-02-24 31-60        34        7        2
#>  7 0007  Mass Mutu…    234.      0  2025-02-11 31-60        31        8        0
#>  8 0008  Allianz        22.     22. 2025-01-06 31-60        32        9        5
#>  9 0009  Cigna         340.      0  2024-12-24 31-60        36        7        0
#> 10 0010  American      160.      0  2025-02-13 31-60        35        8        2
#> # ℹ 4,990 more rows
#> # ℹ 4 more variables: days_acc <int>, days_adj <int>, days_rec <int>,
#> #   dates <list>

summarise_claims(x) |>
dplyr::glimpse()
#> Rows: 1
#> Columns: 9
#> $ n_claims      <int> 5000
#> $ gross_charges <dbl> 664468.7
#> $ ending_ar     <dbl> 372201.3
#> $ mean_rel      <dbl> 8.4854
#> $ mean_sub      <dbl> 2.9998
#> $ mean_acc      <dbl> 7.4984
#> $ mean_adj      <dbl> 14.971
#> $ mean_rec      <dbl> NA
#> $ mean_dar      <dbl> 35.0556

dplyr::group_by(x,
year = ymd::year(date_srv),
month = ymd::month(date_srv)) |>
summarise_claims() |>
dplyr::glimpse()
#> Rows: 4
#> Columns: 11
#> $ year          <int> 2024, 2025, 2025, 2025
#> $ month         <int> 12, 1, 2, 3
#> $ n_claims      <int> 788, 2046, 1863, 303
#> $ gross_charges <dbl> 101572.34, 276983.34, 248050.85, 37862.15
#> $ ending_ar     <dbl> 0.00, 180113.10, 168749.51, 23338.71
#> $ mean_rel      <dbl> 8.390863, 8.521017, 8.478261, 8.534653
#> $ mean_sub      <dbl> 3.019036, 3.010264, 2.973698, 3.039604
#> $ mean_acc      <dbl> 7.436548, 7.553275, 7.543747, 7.009901
#> $ mean_adj      <dbl> 14.76396, 15.03275, 14.99463, 14.94719
#> $ mean_rec      <dbl> 3.046954, NA, NA, NA
#> $ mean_dar      <dbl> 36.65736, 34.87830, 34.68706, 34.35314
```
