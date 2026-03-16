# Generate mock coding/billing data frame

Generate mock coding/billing data frame

## Usage

``` r
mock_claims(rows = 100, payers = payer_names(), count_days = FALSE, ...)
```

## Arguments

- rows:

  `[integerish]` rows number of rows to generate; default is `100`

- payers:

  `[character]` vector of payer names; default is `payer_names()`

- count_days:

  `[logical]` add columns for days between events; default is `FALSE`

- ...:

  `[dots]` additional arguments

## Value

A [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
mock_claims(rows = 5)
#> Error in loadNamespace(x): there is no package called ‘fastplyr’
```
