# Lirov's Net Payment Estimation

Lirov's Net Payment Estimation

## Usage

``` r
predict_net(df, date, gct, earb, net, parb_120)
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

- net:

  column of net payments

- parb_120:

  column of percentage of AR beyond 120 days old

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
predict_net(
  net_ex(),
  date,
  gct,
  earb,
  net,
  parb_120)
#> # A tibble: 13 × 11
#>    date           gct    earb earb_lt120 earb_gt120 parl_120 parb_120 pct_paid
#>    <date>       <dbl>   <dbl>      <dbl>      <dbl>    <dbl>    <dbl>    <dbl>
#>  1 2024-01-01 325982  288433.    282375.      6057.    0.979    0.021    0.320
#>  2 2024-02-01 297732. 307871.    293401.     14470.    0.953    0.047    0.418
#>  3 2024-03-01 198655. 253977.    234928.     19048.    0.925    0.075    0.601
#>  4 2024-04-01 186047  183685.    179828.      3857.    0.979    0.021    0.386
#>  5 2024-05-01 123654  204228.    194629.      9599.    0.953    0.047    0.405
#>  6 2024-06-01 131440. 203460.    188201.     15260.    0.925    0.075    0.500
#>  7 2024-07-01 153991  182771.    178933.      3838.    0.979    0.021    0.554
#>  8 2024-08-01 156975  169634.    161661.      7973.    0.953    0.047    0.434
#>  9 2024-09-01 146878. 179348.    165897.     13451.    0.925    0.075    0.502
#> 10 2024-10-01 163799. 178051.    174312.      3739.    0.979    0.021    0.497
#> 11 2024-11-01 151411. 162757.    155108.      7650.    0.953    0.047    0.518
#> 12 2024-12-01 169094. 199849.    184861.     14989.    0.925    0.075    0.408
#> 13 2025-01-01     NA      NA         NA         NA    NA       NA       NA    
#> # ℹ 3 more variables: net <dbl>, net_pred <dbl>, net_diff <dbl>
```
