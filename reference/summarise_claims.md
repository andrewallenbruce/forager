# Summarise mock coding/billing data frame

Summarise mock coding/billing data frame

## Usage

``` r
summarise_claims(df, vars = c(dplyr::starts_with("days_"), dar))
```

## Arguments

- df:

  `[data.frame]` data frame generated from
  `mock_claims() |> prep_claims()`

- vars:

  `[character]` variables to summarise, e.g.
  `c(days_service, days_reconciliation)`

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
x <- mock_claims(rows = 500) |> prep_claims()
#> Error in loadNamespace(x): there is no package called ‘fastplyr’

summarise_claims(x)
#> Error: object 'x' not found

x |>
  dplyr::group_by(
    year = ymd::year(date_service),
    month = ymd::month(date_service)) |>
  summarise_claims()
#> Error: object 'x' not found
```
