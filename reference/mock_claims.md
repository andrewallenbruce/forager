# Generate mock coding/billing data frame

Generate mock coding/billing data frame

## Usage

``` r
mock_claims(rows = 1000L, days = FALSE)
```

## Arguments

- rows:

  `<int>` number of rows to generate

- days:

  `<lgl>` add counts of days between events

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
mock_claims(rows = 100)
#> # A tibble: 100 × 10
#>    id    payer    charges date_srv   date_rel   date_sub   date_acc   date_adj  
#>    <chr> <fct>      <dbl> <date>     <date>     <date>     <date>     <date>    
#>  1 018   Cigna        98. 2025-03-04 2025-03-12 2025-03-15 2025-03-20 2025-04-07
#>  2 016   Omaha        49. 2025-03-04 2025-03-13 2025-03-16 2025-03-24 2025-04-08
#>  3 031   Highmark    193. 2025-03-04 2025-03-13 2025-03-19 2025-03-22 2025-04-09
#>  4 086   Medicaid     23. 2025-03-03 2025-03-11 2025-03-13 2025-03-19 2025-04-16
#>  5 026   Humana      147. 2025-03-03 2025-03-10 2025-03-14 2025-03-23 2025-04-01
#>  6 077   Medicaid    169. 2025-03-02 2025-03-11 2025-03-17 2025-03-30 2025-04-09
#>  7 052   Wellcare     71. 2025-02-27 2025-03-07 2025-03-13 2025-03-25 2025-04-12
#>  8 009   Cigna       309. 2025-02-27 2025-03-09 2025-03-12 2025-03-21 2025-03-31
#>  9 011   Equitab…    245. 2025-02-27 2025-03-06 2025-03-11 2025-03-18 2025-04-01
#> 10 039   NY Life     207. 2025-02-24 2025-03-04 2025-03-04 2025-03-11 2025-03-29
#> # ℹ 90 more rows
#> # ℹ 2 more variables: date_rec <date>, balance <dbl>
```
