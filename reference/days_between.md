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
mock_claims(10)[c(
  "date_service",
  "charges",
  "payer")] |>
  days_between(date_service)
#> Error in loadNamespace(x): there is no package called ‘fastplyr’
```
