# Apply 30-Day Aging Bins

Apply 30-Day Aging Bins

## Usage

``` r
bin_aging(df, ndays, bin_type = c("case", "chop"))
```

## Arguments

- df:

  `<data.frame>` or `<tibble>`

- ndays:

  `<dbl>` column of counts of days elapsed to bin by

- bin_type:

  `<chr>` string specifying the bin type; one of "chop", "cut" or "ivs"

## Value

a [tibble](https://tibble.tidyverse.org/reference/tibble-package.html)

## Examples

``` r
mock_claims(100) |>
  dplyr::mutate(
    dar = dplyr::if_else(
      !is.na(date_reconciliation),
      as.numeric((date_reconciliation - date_service)),
      as.numeric((date_adjudication - date_service))
    )
  ) |>
    bin_aging(dar, "chop") |>
    dplyr::summarise(
      n_claims = dplyr::n(),
      balance = sum(balance, na.rm = TRUE),
      .by = c(aging_bin))
#> Error in loadNamespace(x): there is no package called ‘fastplyr’

mock_claims(10)[c(
  "date_service",
  "charges",
  "payer")] |>
  days_between(date_service) |>
  bin_aging(days_elapsed)
#> Error in loadNamespace(x): there is no package called ‘fastplyr’

load_ex("aging_ex") |>
  dplyr::select(dos, charges, ins_name) |>
  days_between(dos) |>
  bin_aging(days_elapsed) |>
  dplyr::arrange(aging_bin) |>
  dplyr::group_by(
    year = clock::get_year(dos),
    month = clock::date_month_factor(dos),
  ) |>
  janitor::tabyl(ins_name, aging_bin, year)
#> $`2023`
#>    ins_name 121+
#>       AETNA    6
#>  Blue Cross   13
#>       CIGNA    6
#>    Coventry    0
#>    Medicare    9
#>     Patient   24
#> 
#> $`2024`
#>    ins_name 121+
#>       AETNA  248
#>  Blue Cross  522
#>       CIGNA  273
#>    Coventry   30
#>    Medicare  488
#>     Patient  999
#> 
```
