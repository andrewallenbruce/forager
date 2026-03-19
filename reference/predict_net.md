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
predict_net(net_ex(), date, gct, earb, net, parb_120) |>
dplyr::glimpse()
#> Rows: 13
#> Columns: 11
#> $ date       <date> 2024-01-01, 2024-02-01, 2024-03-01, 2024-04-01, 2024-05-01…
#> $ gct        <dbl> 325982.0, 297731.7, 198655.1, 186047.0, 123654.0, 131440.3,…
#> $ earb       <dbl> 288432.5, 307871.1, 253976.6, 183684.9, 204227.6, 203460.5,…
#> $ earb_lt120 <dbl> 282375.4, 293401.1, 234928.3, 179827.5, 194628.9, 188200.9,…
#> $ earb_gt120 <dbl> 6057.083, 14469.941, 19048.242, 3857.383, 9598.697, 15259.5…
#> $ parl_120   <dbl> 0.979, 0.953, 0.925, 0.979, 0.953, 0.925, 0.979, 0.953, 0.9…
#> $ parb_120   <dbl> 0.021, 0.047, 0.075, 0.021, 0.047, 0.075, 0.021, 0.047, 0.0…
#> $ pct_paid   <dbl> 0.3195932, 0.4183258, 0.6012708, 0.3856885, 0.4052617, 0.49…
#> $ net        <dbl> 104181.64, 124548.88, 119445.53, 71756.18, 50112.23, 65715.…
#> $ net_pred   <dbl> NA, 101993.83, 118695.08, 110487.12, 70249.30, 47756.96, 60…
#> $ net_diff   <dbl> NA, -22555.0544, -750.4474, 38730.9353, 20137.0702, -17958.…
```
