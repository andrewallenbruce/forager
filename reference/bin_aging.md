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
mock_claims(1000) |>
  dplyr::mutate(
    dar = dplyr::if_else(
      !is.na(date_rec),
      as.integer(date_rec - date_srv),
      as.integer(date_adj - date_srv)
    )
  ) |>
  bin_aging(dar, "chop") |>
  dplyr::summarise(
    n_claims = dplyr::n(),
    balance = sum(balance, na.rm = TRUE),
    .by = c(aging_bin)
  )
#> # A tibble: 2 × 3
#>   aging_bin n_claims balance
#>   <fct>        <int>   <dbl>
#> 1 (30, 60]       732  55136.
#> 2 (0, 30]        268  22686.

mock_claims(100)[c(
  "date_srv",
  "charges",
  "payer"
)] |>
  days_between(date_srv) |>
  bin_aging(days_elapsed)
#> # A tibble: 100 × 5
#>    date_srv   charges payer       days_elapsed aging_bin
#>    <date>       <dbl> <fct>              <int> <fct>    
#>  1 2025-03-04    232. Highmark             380 121+     
#>  2 2025-03-03    295. Medicaid             381 121+     
#>  3 2025-03-02    202. Centene              382 121+     
#>  4 2025-03-01    237. GuideWell            383 121+     
#>  5 2025-02-28    305. HCSC                 384 121+     
#>  6 2025-02-26    309. Wellcare             386 121+     
#>  7 2025-02-25     20. Bright               387 121+     
#>  8 2025-02-24     82. Omaha                388 121+     
#>  9 2025-02-23    166. Athene               389 121+     
#> 10 2025-02-23    173. Mass Mutual          389 121+     
#> # ℹ 90 more rows

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
