# Generate Mock PARBx data

Generate Mock PARBx data

## Usage

``` r
mock_parbx(payers = payer_names(), ...)
```

## Arguments

- payers:

  `[character]` vector of payer names

- ...:

  `[dots]` additional arguments

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
# Every payer name generates 60 rows of data
mock_parbx()
#> # A tibble: 1,440 × 5
#>    date       month    payer    aging_bin aging_prop
#>    <date>     <ord>    <chr>    <ord>          <dbl>
#>  1 2024-01-01 January  Medicare 0-30           0.22 
#>  2 2024-01-01 January  Medicare 31-60          0.19 
#>  3 2024-01-01 January  Medicare 61-90          0.078
#>  4 2024-01-01 January  Medicare 91-120         0.25 
#>  5 2024-01-01 January  Medicare 121+           0.26 
#>  6 2024-02-01 February Medicare 0-30           0.13 
#>  7 2024-02-01 February Medicare 31-60          0.11 
#>  8 2024-02-01 February Medicare 61-90          0.36 
#>  9 2024-02-01 February Medicare 91-120         0.35 
#> 10 2024-02-01 February Medicare 121+           0.050
#> # ℹ 1,430 more rows
```
