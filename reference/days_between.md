# Calculate Number of Days Between Two Dates

Calculate Number of Days Between Two Dates

## Usage

``` r
days_between(df, from, to = NULL)
```

## Arguments

- df:

  `<data.frame>` or `<tibble>`

- from:

  `[character]` column of start dates

- to:

  `[character]` column of end dates

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
mock_claims(100)[c("date_srv", "charges", "payer")] |>
  days_between(date_srv)
#> # A tibble: 100 × 4
#>    date_srv   charges payer     days_elapsed
#>    <date>       <dbl> <fct>            <int>
#>  1 2025-03-03    139. Humana             381
#>  2 2025-03-03    150. Equitable          381
#>  3 2025-03-02    279. Aetna              382
#>  4 2025-03-02     31. Omaha              382
#>  5 2025-03-01    126. Bright             383
#>  6 2025-03-01     65. Allianz            383
#>  7 2025-02-28     64. Bright             384
#>  8 2025-02-27     94. Medicare           385
#>  9 2025-02-27    280. Elevance           385
#> 10 2025-02-25    246. Athene             387
#> # ℹ 90 more rows
```
