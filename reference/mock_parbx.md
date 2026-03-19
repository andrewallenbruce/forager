# Generate Mock PARBx data

Generate Mock PARBx data

## Usage

``` r
mock_parbx()
```

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
mock_parbx()
#> ! Expressions will be optimised where possible.
#> 
#> Optimised expressions are independent from unoptimised ones and typical
#> data-masking rules may not apply
#> 
#> Run `fastplyr::fastplyr_disable_optimisations()` to disable optimisations
#> globally
#> 
#> Run `fastplyr::fastplyr_disable_informative_msgs()` to disable this and other
#> informative messages
#> This message is displayed once per session.
#> # A tibble: 60 × 5
#>    date       month    payer    bin    aging
#>    <date>     <ord>    <fct>    <fct>  <dbl>
#>  1 2025-01-01 January  Bright   0-30    0.12
#>  2 2025-01-01 January  Bright   31-60   0.15
#>  3 2025-01-01 January  Bright   61-90   0.33
#>  4 2025-01-01 January  Wellcare 91-120  0.23
#>  5 2025-01-01 January  Wellcare 121+    0.17
#>  6 2025-02-01 February Humana   0-30    0.13
#>  7 2025-02-01 February Omaha    31-60   0.27
#>  8 2025-02-01 February Omaha    61-90   0.22
#>  9 2025-02-01 February BCBS     91-120  0.25
#> 10 2025-02-01 February Wellcare 121+    0.13
#> # ℹ 50 more rows
```
