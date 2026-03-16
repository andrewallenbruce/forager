# PARBx & BPI

## PARBx

PARB$x$, or *Percentage of Accounts Receivable Beyond $x$ Days*, is
exactly what it sounds like: monitoring the percentage of your AR
balances as they age, in what are commonly referred to as aging
“buckets” or “bins.” This idea, in and of itself, is not revolutionary,
other than his suggestion to use PARB$x$ to resolve Days in AR’s
inability to highlight the overall behavior of Accounts Receivable. The
innovation comes in the form of using the PARB$x$ data to create an
index that tracks a payer’s performance month-to-month and annually:

PARB$x$ data can then be used to calculate a BPI, or Billing Performance
Index. BPI is a key billing performance characteristic because it’s an
indicator of claims that are never paid. Obviously, the lower the index,
the better the billing performance. But this statistic is meaningful
only when considered in the context of the relative performance of other
payers. Lirov (2009)

PARBx resolves the sensitivity issues of the DAR metric. It offers a
simple billing process metric that’s not dependent on the charge. Its
graphic representation has a skewed bell shape. Its steepness represents
billing process quality; a steep curve and thin tail mean a healthy
billing process, while a flat bell and fat tail also mean billing
problems.

## Billing Performance Index (BPI)

Lirov’s Billing Performance Index was inspired by a Wall Street
benchmarking technique called a payment performance index. He emphasizes
the advantage of a “context-driven, rule-based approach to relative
benchmarking”:

The advantage of rule-driven indexing is that participation is
dynamically determined at a point in time, reflecting the dynamic nature
of the entire market. Today’s top 10 list of index performers may not
include the same names next week…A financial instrument’s specific
performance is recomputed every time the index itself is computed,
reflecting the dynamic nature of performance relative to the market
itself. Lirov (2009)

Applying this indexing method to payers allows providers to track the
ease/difficulty of the reimbursement process with each payer. Inclusion
in the monthly index indicates that the percentage of AR older than 120
days belonging to a payer ranks among the lowest in a provider’s payer
mix.

This results in a provider being able to focus his or her AR management
resources on more problematic payers. Lirov does suggest several
criteria that should be considered before a payer is elligible for
inclusion such as a minimum threshold of claims submitted and total
gross charges processed.

### Monthly BPI Ranking

For this example, I’ve put the mock data provided by Dr. Lirov into a
data frame. The data ranks (or indexes) the payers with the top 10
lowest PARBx percentages by the most recent month’s (December) figures,
including November’s figures as well. December’s rankings appear
alongside a Rank Change column indicating the number of places each
payer rose or fell from November to December. Using {reactable} and
{reactablefmtr} I can create an interactive table of the data:

``` r
parbx_rank <- dplyr::tibble(
  payer = c(
    "Medicare Illinois",
    "BCBS Illinois",
    "Cigna",
    "Horizon BCBS NJ",
    "Aetna",
    "UnitedHealthcare",
    "Medicare NJ",
    "GEICO",
    "BCBS Pennsylvania",
    "BCBS Georgia"
  ),
  parbx_nov = c(5.8, 7.9, 15.7, 20.7, 20, 15, 19.4, 36.2, 30.5, 39.9) / 100,
  parbx_dec = c(6.8, 8.1, 10.7, 13.9, 14.8, 21.2, 18.8, 35.2, 43.4, 43.3) / 100
) |> 
  dplyr::mutate(
    rank_nov = dplyr::min_rank(parbx_nov),
    rank_dec = dplyr::min_rank(parbx_dec),
    rank_change = rank_nov - rank_dec) |> 
  dplyr::arrange(rank_dec)

parbx_rank
```

    #> # A tibble: 10 × 6
    #>    payer             parbx_nov parbx_dec rank_nov rank_dec rank_change
    #>    <chr>                 <dbl>     <dbl>    <int>    <int>       <int>
    #>  1 Medicare Illinois     0.058     0.068        1        1           0
    #>  2 BCBS Illinois         0.079     0.081        2        2           0
    #>  3 Cigna                 0.157     0.107        4        3           1
    #>  4 Horizon BCBS NJ       0.207     0.139        7        4           3
    #>  5 Aetna                 0.2       0.148        6        5           1
    #>  6 Medicare NJ           0.194     0.188        5        6          -1
    #>  7 UnitedHealthcare      0.15      0.212        3        7          -4
    #>  8 GEICO                 0.362     0.352        9        8           1
    #>  9 BCBS Georgia          0.399     0.433       10        9           1
    #> 10 BCBS Pennsylvania     0.305     0.434        8       10          -2

``` r
parbx_rank |>
  arrange(rank_dec) |> 
  mutate(dir = case_when(
    rank_change == 0 ~ "code-commit",
    rank_change > 0 ~ "arrow-up",
    rank_change < 0 ~ "arrow-down"
  )
) |> 
  gt(rowname_col = "payer") |>
  cols_add(change_abs = abs(rank_change)) |>
  fmt_icon(
    columns = dir,
    fill_color = c("arrow-up" = "#15607A", "arrow-down" = "#FA8C00", "code-commit" = "grey90")) |> 
  fmt_percent(columns = starts_with("parbx_"),
              drop_trailing_zeros = TRUE) |>
  fmt_integer(columns = ends_with("_change"), force_sign = TRUE) |>
  cols_hide(columns = c(rank_change)) |> 
  cols_move_to_start(columns = c(dir, change_abs, rank_nov, parbx_nov, rank_dec, parbx_dec)) |>
  cols_align(align = "center", columns = c(dir, rank_change, rank_nov, parbx_nov, rank_dec, parbx_dec)) |> 
  # cols_merge(columns = c(change_abs, dir), pattern = "{1} {2}") |> 
  cols_label(
    change_abs = "Change",
    rank_nov = "Rank",
    parbx_nov = md("PARB<b><i><sub>x</sub></i></b>"),
    rank_dec = "Rank",
    parbx_dec = md("PARB<b><i><sub>x</sub></i></b>"),
    dir = ""
  ) |>
  data_color(columns = starts_with("parbx_"),
             palette = c("#15607A", "#FFFFFF", "#FA8C00")) |>
  opt_table_font(font = gt::google_font(name = "Atkinson Hyperlegible")) |> 
  tab_header(title = md("**Billing Performance Index**"),
             subtitle = "Top 10 Payers with the Lowest Percentage of AR Beyond 120 Days") |> 
  tab_spanner(label = md("**November**"), columns = c(rank_nov, parbx_nov)) |> 
  tab_spanner(label = md("**December**"), columns = c(rank_dec, parbx_dec)) |> 
  opt_stylize(color = "cyan", add_row_striping = FALSE) |>
  tab_options(
    quarto.disable_processing = TRUE,
    table.font.size = gt::px(18),
    table.width = gt::pct(100),
    heading.align = "left",
    heading.title.font.size = gt::px(24),
    heading.subtitle.font.size = gt::px(21))
```

[TABLE]

``` r
parbx_rank |> 
  select(payer, parbx_nov, parbx_dec) |> 
  mutate(
    parbx_nov = parbx_nov * wakefield::probs(n()),
    parbx_dec = parbx_dec * wakefield::probs(n()),
    rank_nov = dplyr::min_rank(parbx_nov),
    rank_dec = dplyr::min_rank(parbx_dec),
    rank_change = rank_nov - rank_dec
  ) |>
  arrange(rank_dec) |> 
  gt(rowname_col = "payer") |>
  fmt_percent(columns = starts_with("parbx_"), drop_trailing_zeros = TRUE) |>
  fmt_integer(columns = ends_with("_change"), force_sign = TRUE) |>
  cols_move_to_start(columns = c(rank_change, rank_nov, parbx_nov, rank_dec, parbx_dec)) |>
  cols_align(align = "center", columns = c(rank_change, rank_nov, parbx_nov, rank_dec, parbx_dec)) |> 
  cols_label(
    rank_change = "Change",
    rank_nov = "Rank",
    parbx_nov = md("<sub>wt</sub>PARB<b><i><sub>x</sub></i></b>"),
    rank_dec = "Rank",
    parbx_dec = md("<sub>wt</sub>PARB<b><i><sub>x</sub></i></b>")
  ) |>
  data_color(columns = starts_with("parbx_"),
             palette = c("#15607A", "#FFFFFF", "#FA8C00")) |> 
  opt_table_font(font = gt::google_font(name = "Atkinson Hyperlegible")) |> 
  tab_header(title = md("**Weighted Billing Performance Index**"),
             subtitle = "Top 10 Payers with the Lowest Percentage of AR Beyond 120 Days") |> 
  tab_spanner(label = md("**November**"), columns = c(rank_nov, parbx_nov)) |> 
  tab_spanner(label = md("**December**"), columns = c(rank_dec, parbx_dec)) |> 
  opt_stylize(color = "cyan", add_row_striping = FALSE) |>
  tab_options(
    quarto.disable_processing = TRUE,
    table.font.size = gt::px(18),
    table.width = gt::pct(100),
    heading.align = "left",
    heading.title.font.size = gt::px(24),
    heading.subtitle.font.size = gt::px(21)
              )
```

[TABLE]

### Annual BPI Summary

The final destination for all of this data is the annual summary of the
monthly Billing Performance Index.

The Annual BPI is simply a list of the payers who participated in the
Monthly BPI, ranked by the number of times that they made the top 10
that year. Also included are each payer’s mean, minimum, and maximum BPI
for the year. Lirov sums up the importance of the annual summary:

A low percentage of accounts receivable beyond 120 days is critical to
being included in the billing index. However, the frequency of inclusion
in the index is a more robust performance metric, because it measures
billing performance consistency over a longer time period.

``` r
tibble(
  rank = 1:15,
  n_months = c(
    12, 11, 11, 10, 10,
    7, 7, 7, 5, 4, 3,
    3, 3, 2, 2
  ),
  payer = c(
    "BCBS Illinois", "Cigna",
    "Medicare New Jersey",
    "Aetna", "UnitedHealthcare",
    "Medicare Illinois", "Horizon BCBS New Jersey",
    "BCBS Pennsylvania", "BCBS Georgia",
    "Anthem BCBS Colorado",
    "BCBS Michigan", "BCBS Texas", "GEICO",
    "Anthem BCBS Colorado", "Humana"
  ),
  min = c(
    7.1, 8.9, 7.5, 8.8, 11.3,
    5.8, 13.9, 12.4, 22.9, 12.4,
    3.2, 10.3, 33.4, 6.8, 7.9
  ) / 100,
  mean = c(
    10.9, 13.4, 15.7, 16.6, 17.2,
    14, 18, 23.5, 34.1, 19.1, 6.8,
    15.2, 34.9, 9.6, 9.9
  ) / 100,
  max = c(
    16, 24.1, 20.5, 22.1, 23.2,
    30.4, 24.3, 43.4, 43.3, 34.1,
    13.6, 20, 36.2, 12.3, 11.8
  ) / 100
) |> 
  gt(rowname_col = "rank", groupname_col = "payer", row_group_as_column = TRUE) |>
  fmt_percent(columns = c(min, mean, max), drop_trailing_zeros = TRUE) |>
  cols_align(align = "center", columns = c(rank, n_months, min, mean, max)) |> 
  cols_label(
    rank = "Rank",
    n_months = "Months",
    min = "Minimum",
    mean = "Average",
    max = "Maximum"
  ) |>
  data_color(columns = c(min, mean, max),
             palette = c("#15607A", "#FFFFFF", "#FA8C00")) |> 
  opt_table_font(font = gt::google_font(name = "Atkinson Hyperlegible")) |> 
  tab_header(title = md("**Annual Billing Performance Index**"),
             subtitle = "Top 15 Payers Ranked by Months Included on BPI.") |> 
  tab_spanner(label = md("**Percentage of AR Beyond 120 Days**"), columns = c(min, mean, max)) |> 
  opt_stylize(color = "cyan", add_row_striping = FALSE) |>
  tab_options(
    quarto.disable_processing = TRUE,
    table.font.size = gt::px(18),
    table.width = gt::pct(100),
    heading.align = "left",
    heading.title.font.size = gt::px(24),
    heading.subtitle.font.size = gt::px(21))
```

[TABLE]

## Mock PARBx

``` r
mock_parbx()
```

    #> # A tibble: 1,440 × 5
    #>    date       month    payer    aging_bin aging_prop
    #>    <date>     <ord>    <chr>    <ord>          <dbl>
    #>  1 2024-01-01 January  Medicare 0-30           0.19 
    #>  2 2024-01-01 January  Medicare 31-60          0.10 
    #>  3 2024-01-01 January  Medicare 61-90          0.23 
    #>  4 2024-01-01 January  Medicare 91-120         0.27 
    #>  5 2024-01-01 January  Medicare 121+           0.21 
    #>  6 2024-02-01 February Medicare 0-30           0.092
    #>  7 2024-02-01 February Medicare 31-60          0.27 
    #>  8 2024-02-01 February Medicare 61-90          0.048
    #>  9 2024-02-01 February Medicare 91-120         0.28 
    #> 10 2024-02-01 February Medicare 121+           0.31 
    #> # ℹ 1,430 more rows

``` r
mock_parbx() |>
  mutate(aging_prop = fuimus::roundup(aging_prop * 100)) |> 
  pivot_wider(names_from = "aging_bin", 
              values_from = "aging_prop") |> 
  arrange(month) |> 
  select(-date) |> 
  gt(rowname_col = "payer", 
     groupname_col = "month", 
     row_group_as_column = TRUE) |> 
  fmt_number(decimals = 1) |> 
  opt_table_font(font = google_font(name = "Atkinson Hyperlegible")) |> 
  tab_options(
    column_labels.font.weight = "bold",
    column_labels.font.size = px(16),
    column_labels.border.bottom.width = px(3),
    quarto.disable_processing = TRUE,
    table.font.size = px(18),
    table.width = pct(75),
    heading.align = "left",
    heading.title.font.size = px(24),
    heading.subtitle.font.size = px(21),
    # table_body.hlines.style = "none",
    column_labels.border.top.color = "darkgreen",
    column_labels.border.bottom.color = "darkgreen",
    table_body.border.bottom.color = "darkgreen",
    stub.border.style = "none",
    stub.background.color = "darkgreen",
    # stub.font.weight = "bold",
    row_group.font.weight = "bold"
    )
```

|           |               | 0-30 | 31-60 | 61-90 | 91-120 | 121+ |
|-----------|---------------|------|-------|-------|--------|------|
| January   | Medicare      | 24.8 | 4.7   | 32.1  | 2.3    | 36.1 |
|           | Medicaid      | 0.2  | 12.2  | 20.1  | 38.7   | 28.8 |
|           | Elevance      | 33.5 | 5.5   | 25.0  | 31.8   | 4.3  |
|           | HCSC          | 20.3 | 6.6   | 48.5  | 5.6    | 19.0 |
|           | UHC           | 55.7 | 14.1  | 5.0   | 7.2    | 18.0 |
|           | Centene       | 17.8 | 19.8  | 23.0  | 9.6    | 29.9 |
|           | Aetna         | 38.1 | 5.5   | 6.3   | 36.6   | 13.5 |
|           | Humana        | 22.6 | 12.7  | 32.1  | 30.8   | 1.8  |
|           | Cigna         | 51.4 | 19.5  | 9.5   | 7.6    | 11.9 |
|           | Molina        | 4.2  | 28.8  | 20.5  | 5.2    | 41.3 |
|           | GuideWell     | 13.5 | 33.5  | 10.7  | 9.8    | 32.6 |
|           | Highmark      | 33.2 | 1.0   | 9.7   | 35.0   | 21.1 |
|           | BCBS          | 24.6 | 39.0  | 2.9   | 16.4   | 17.2 |
|           | Bright        | 8.7  | 27.4  | 12.1  | 27.2   | 24.7 |
|           | Oscar         | 13.0 | 21.5  | 19.8  | 21.6   | 24.1 |
|           | Wellcare      | 24.0 | 18.1  | 11.2  | 24.2   | 22.5 |
|           | Omaha         | 5.0  | 27.6  | 8.7   | 25.6   | 33.1 |
|           | Athene        | 14.1 | 26.8  | 5.2   | 26.8   | 27.2 |
|           | American      | 10.8 | 34.6  | 30.2  | 3.8    | 20.7 |
|           | Mass Mutual   | 37.7 | 12.1  | 5.9   | 16.7   | 27.6 |
|           | New York Life | 1.6  | 39.9  | 29.9  | 20.5   | 8.1  |
|           | Lincoln       | 26.8 | 11.1  | 10.0  | 22.3   | 29.9 |
|           | Equitable     | 12.7 | 13.0  | 39.0  | 16.5   | 18.7 |
|           | Allianz       | 12.8 | 18.9  | 26.3  | 29.1   | 12.8 |
| February  | Medicare      | 6.6  | 0.4   | 29.6  | 14.0   | 49.3 |
|           | Medicaid      | 18.0 | 18.5  | 19.3  | 11.8   | 32.4 |
|           | Elevance      | 62.7 | 5.0   | 29.6  | 2.2    | 0.6  |
|           | HCSC          | 26.1 | 6.5   | 12.4  | 8.4    | 46.5 |
|           | UHC           | 11.7 | 42.6  | 13.5  | 1.1    | 31.1 |
|           | Centene       | 7.1  | 2.9   | 38.5  | 12.6   | 39.0 |
|           | Aetna         | 36.0 | 15.4  | 10.2  | 25.5   | 12.9 |
|           | Humana        | 1.0  | 6.9   | 29.3  | 14.9   | 47.8 |
|           | Cigna         | 20.2 | 20.3  | 26.0  | 19.1   | 14.5 |
|           | Molina        | 30.8 | 58.1  | 0.5   | 6.8    | 3.9  |
|           | GuideWell     | 27.8 | 22.3  | 18.9  | 12.4   | 18.6 |
|           | Highmark      | 27.8 | 11.7  | 14.8  | 33.2   | 12.6 |
|           | BCBS          | 9.4  | 40.8  | 4.8   | 10.8   | 34.2 |
|           | Bright        | 27.1 | 28.8  | 3.9   | 20.1   | 20.0 |
|           | Oscar         | 22.2 | 13.2  | 24.5  | 14.6   | 25.5 |
|           | Wellcare      | 43.6 | 18.9  | 18.8  | 0.6    | 18.0 |
|           | Omaha         | 5.3  | 22.6  | 26.4  | 9.1    | 36.6 |
|           | Athene        | 19.8 | 26.8  | 0.8   | 28.1   | 24.4 |
|           | American      | 25.9 | 17.4  | 13.3  | 20.5   | 22.9 |
|           | Mass Mutual   | 11.7 | 24.7  | 24.6  | 31.4   | 7.6  |
|           | New York Life | 12.8 | 23.8  | 29.2  | 21.2   | 12.9 |
|           | Lincoln       | 24.2 | 7.0   | 32.9  | 30.6   | 5.3  |
|           | Equitable     | 6.5  | 30.8  | 32.2  | 28.4   | 2.1  |
|           | Allianz       | 3.9  | 45.7  | 31.5  | 9.1    | 9.9  |
| March     | Medicare      | 11.8 | 6.8   | 20.6  | 14.8   | 46.0 |
|           | Medicaid      | 11.4 | 25.5  | 34.3  | 8.5    | 20.4 |
|           | Elevance      | 34.7 | 1.6   | 10.8  | 38.1   | 14.7 |
|           | HCSC          | 32.9 | 0.3   | 8.7   | 28.1   | 30.0 |
|           | UHC           | 19.6 | 10.3  | 7.6   | 31.4   | 31.1 |
|           | Centene       | 27.2 | 20.4  | 19.2  | 3.4    | 29.9 |
|           | Aetna         | 11.7 | 47.4  | 15.4  | 13.4   | 12.0 |
|           | Humana        | 25.2 | 2.6   | 1.2   | 33.4   | 37.6 |
|           | Cigna         | 35.8 | 42.9  | 2.4   | 1.7    | 17.2 |
|           | Molina        | 33.5 | 44.3  | 11.5  | 7.8    | 2.8  |
|           | GuideWell     | 11.6 | 2.3   | 3.2   | 49.2   | 33.8 |
|           | Highmark      | 18.3 | 28.4  | 45.5  | 4.8    | 2.9  |
|           | BCBS          | 0.1  | 18.7  | 22.1  | 21.5   | 37.5 |
|           | Bright        | 31.5 | 12.1  | 21.0  | 24.7   | 10.7 |
|           | Oscar         | 19.9 | 22.6  | 27.0  | 2.8    | 27.6 |
|           | Wellcare      | 22.6 | 28.4  | 27.3  | 11.1   | 10.6 |
|           | Omaha         | 17.8 | 20.5  | 25.9  | 31.1   | 4.6  |
|           | Athene        | 34.9 | 10.2  | 18.6  | 29.0   | 7.3  |
|           | American      | 17.9 | 24.9  | 27.3  | 4.2    | 25.7 |
|           | Mass Mutual   | 30.9 | 5.3   | 19.7  | 7.6    | 36.5 |
|           | New York Life | 8.6  | 7.6   | 17.2  | 26.3   | 40.4 |
|           | Lincoln       | 24.7 | 8.5   | 33.5  | 23.8   | 9.5  |
|           | Equitable     | 22.7 | 22.1  | 33.4  | 0.1    | 21.7 |
|           | Allianz       | 23.5 | 24.6  | 14.7  | 12.1   | 25.1 |
| April     | Medicare      | 23.7 | 10.7  | 4.4   | 29.2   | 32.1 |
|           | Medicaid      | 24.8 | 31.1  | 29.2  | 10.9   | 4.1  |
|           | Elevance      | 9.3  | 30.1  | 24.9  | 23.5   | 12.2 |
|           | HCSC          | 15.8 | 23.9  | 28.1  | 16.0   | 16.2 |
|           | UHC           | 18.9 | 17.5  | 6.7   | 39.1   | 17.9 |
|           | Centene       | 32.6 | 28.4  | 16.5  | 20.9   | 1.6  |
|           | Aetna         | 21.6 | 24.9  | 23.0  | 10.0   | 20.5 |
|           | Humana        | 22.5 | 19.7  | 28.8  | 2.1    | 27.0 |
|           | Cigna         | 16.3 | 24.8  | 47.8  | 10.6   | 0.6  |
|           | Molina        | 33.2 | 23.0  | 7.6   | 21.2   | 15.0 |
|           | GuideWell     | 1.4  | 26.6  | 35.2  | 2.8    | 34.0 |
|           | Highmark      | 35.9 | 24.6  | 1.6   | 18.7   | 19.2 |
|           | BCBS          | 37.1 | 33.3  | 15.0  | 14.2   | 0.4  |
|           | Bright        | 3.0  | 24.2  | 34.9  | 35.0   | 2.9  |
|           | Oscar         | 13.2 | 4.7   | 31.0  | 32.0   | 19.1 |
|           | Wellcare      | 29.5 | 19.1  | 28.2  | 6.9    | 16.2 |
|           | Omaha         | 19.8 | 24.2  | 25.4  | 29.6   | 1.0  |
|           | Athene        | 31.5 | 1.6   | 59.1  | 2.1    | 5.7  |
|           | American      | 19.6 | 3.0   | 28.6  | 27.4   | 21.4 |
|           | Mass Mutual   | 21.3 | 23.1  | 15.8  | 16.7   | 23.1 |
|           | New York Life | 37.9 | 7.0   | 30.3  | 24.8   | 0.1  |
|           | Lincoln       | 4.1  | 7.8   | 43.8  | 29.2   | 15.2 |
|           | Equitable     | 11.6 | 27.6  | 32.8  | 11.4   | 16.6 |
|           | Allianz       | 6.3  | 31.6  | 29.7  | 25.4   | 7.0  |
| May       | Medicare      | 8.0  | 29.5  | 21.8  | 11.8   | 28.9 |
|           | Medicaid      | 19.0 | 1.7   | 34.7  | 9.0    | 35.7 |
|           | Elevance      | 22.6 | 9.9   | 17.5  | 26.9   | 23.2 |
|           | HCSC          | 6.2  | 7.2   | 36.1  | 46.2   | 4.2  |
|           | UHC           | 32.9 | 16.8  | 19.3  | 26.7   | 4.2  |
|           | Centene       | 21.6 | 29.1  | 14.1  | 33.6   | 1.6  |
|           | Aetna         | 32.7 | 30.7  | 4.9   | 3.4    | 28.3 |
|           | Humana        | 15.2 | 27.0  | 18.4  | 14.7   | 24.7 |
|           | Cigna         | 6.2  | 25.9  | 13.7  | 41.8   | 12.5 |
|           | Molina        | 21.5 | 5.5   | 33.6  | 34.0   | 5.4  |
|           | GuideWell     | 54.8 | 16.0  | 12.0  | 9.5    | 7.8  |
|           | Highmark      | 23.3 | 24.6  | 1.9   | 10.8   | 39.5 |
|           | BCBS          | 26.3 | 5.6   | 23.2  | 17.0   | 27.8 |
|           | Bright        | 25.0 | 19.7  | 10.5  | 24.8   | 20.1 |
|           | Oscar         | 27.9 | 7.5   | 23.1  | 26.9   | 14.6 |
|           | Wellcare      | 19.1 | 21.2  | 15.1  | 25.6   | 19.0 |
|           | Omaha         | 9.9  | 1.4   | 3.5   | 40.3   | 45.0 |
|           | Athene        | 13.5 | 22.4  | 29.3  | 9.2    | 25.6 |
|           | American      | 18.9 | 9.8   | 12.4  | 29.0   | 29.9 |
|           | Mass Mutual   | 17.1 | 8.2   | 28.4  | 27.8   | 18.5 |
|           | New York Life | 47.9 | 10.5  | 18.0  | 8.8    | 14.8 |
|           | Lincoln       | 26.0 | 19.5  | 8.4   | 6.8    | 39.4 |
|           | Equitable     | 33.9 | 8.2   | 26.3  | 8.2    | 23.3 |
|           | Allianz       | 12.1 | 2.0   | 23.5  | 22.4   | 40.0 |
| June      | Medicare      | 48.4 | 16.5  | 28.8  | 3.6    | 2.7  |
|           | Medicaid      | 8.4  | 2.9   | 13.1  | 8.0    | 67.5 |
|           | Elevance      | 19.6 | 23.0  | 19.2  | 20.9   | 17.3 |
|           | HCSC          | 30.7 | 18.7  | 5.3   | 26.5   | 18.7 |
|           | UHC           | 13.9 | 32.6  | 37.5  | 9.9    | 6.1  |
|           | Centene       | 32.0 | 21.0  | 16.5  | 0.1    | 30.3 |
|           | Aetna         | 22.4 | 19.0  | 23.8  | 17.3   | 17.5 |
|           | Humana        | 38.5 | 25.0  | 23.7  | 4.0    | 8.8  |
|           | Cigna         | 34.2 | 6.8   | 29.1  | 13.2   | 16.7 |
|           | Molina        | 17.3 | 33.5  | 8.4   | 13.5   | 27.3 |
|           | GuideWell     | 18.9 | 10.2  | 25.8  | 8.4    | 36.8 |
|           | Highmark      | 1.7  | 4.6   | 36.8  | 34.1   | 22.9 |
|           | BCBS          | 24.9 | 13.9  | 42.9  | 4.9    | 13.4 |
|           | Bright        | 12.2 | 16.9  | 29.4  | 29.6   | 11.8 |
|           | Oscar         | 24.7 | 28.2  | 20.9  | 13.0   | 13.1 |
|           | Wellcare      | 24.5 | 6.8   | 56.4  | 9.9    | 2.5  |
|           | Omaha         | 18.0 | 13.1  | 33.3  | 25.9   | 9.7  |
|           | Athene        | 9.8  | 4.4   | 35.2  | 30.6   | 20.0 |
|           | American      | 27.9 | 11.2  | 15.3  | 37.1   | 8.5  |
|           | Mass Mutual   | 13.0 | 28.4  | 0.7   | 29.6   | 28.4 |
|           | New York Life | 55.9 | 0.7   | 17.9  | 5.2    | 20.3 |
|           | Lincoln       | 38.8 | 31.2  | 1.1   | 16.2   | 12.6 |
|           | Equitable     | 36.6 | 9.6   | 21.7  | 19.8   | 12.3 |
|           | Allianz       | 15.0 | 17.2  | 22.1  | 31.3   | 14.5 |
| July      | Medicare      | 27.1 | 13.1  | 27.6  | 22.8   | 9.4  |
|           | Medicaid      | 17.5 | 26.4  | 9.8   | 45.7   | 0.7  |
|           | Elevance      | 23.9 | 15.4  | 14.1  | 28.3   | 18.3 |
|           | HCSC          | 32.4 | 1.9   | 33.2  | 31.2   | 1.2  |
|           | UHC           | 31.6 | 21.9  | 19.0  | 15.3   | 12.2 |
|           | Centene       | 25.3 | 14.3  | 36.7  | 16.1   | 7.6  |
|           | Aetna         | 19.7 | 24.6  | 15.9  | 22.8   | 17.0 |
|           | Humana        | 41.9 | 2.7   | 25.7  | 26.9   | 2.8  |
|           | Cigna         | 16.2 | 22.4  | 23.2  | 23.4   | 14.8 |
|           | Molina        | 8.5  | 9.8   | 4.2   | 35.0   | 42.5 |
|           | GuideWell     | 21.8 | 15.5  | 23.9  | 17.9   | 21.0 |
|           | Highmark      | 40.3 | 10.4  | 24.2  | 5.3    | 19.8 |
|           | BCBS          | 36.8 | 14.6  | 37.7  | 6.5    | 4.4  |
|           | Bright        | 8.1  | 22.5  | 24.9  | 23.2   | 21.3 |
|           | Oscar         | 19.2 | 17.2  | 20.1  | 20.9   | 22.5 |
|           | Wellcare      | 23.7 | 14.6  | 21.4  | 30.2   | 10.2 |
|           | Omaha         | 32.4 | 6.6   | 41.2  | 19.0   | 0.8  |
|           | Athene        | 25.3 | 24.1  | 36.0  | 10.2   | 4.5  |
|           | American      | 44.2 | 36.1  | 3.9   | 3.9    | 11.8 |
|           | Mass Mutual   | 11.7 | 10.7  | 31.4  | 29.8   | 16.4 |
|           | New York Life | 31.6 | 19.4  | 25.9  | 14.3   | 8.8  |
|           | Lincoln       | 21.5 | 40.4  | 16.1  | 17.5   | 4.5  |
|           | Equitable     | 4.2  | 19.1  | 43.7  | 31.5   | 1.5  |
|           | Allianz       | 22.8 | 33.2  | 24.1  | 12.5   | 7.4  |
| August    | Medicare      | 10.8 | 6.3   | 26.8  | 28.2   | 28.0 |
|           | Medicaid      | 11.3 | 28.1  | 21.9  | 19.1   | 19.7 |
|           | Elevance      | 34.4 | 36.1  | 6.3   | 22.2   | 0.9  |
|           | HCSC          | 23.6 | 4.8   | 35.8  | 22.5   | 13.3 |
|           | UHC           | 48.1 | 0.5   | 4.1   | 0.3    | 47.0 |
|           | Centene       | 19.4 | 31.2  | 15.8  | 24.6   | 9.0  |
|           | Aetna         | 19.8 | 22.2  | 27.8  | 8.3    | 21.9 |
|           | Humana        | 32.1 | 20.4  | 0.9   | 26.7   | 19.9 |
|           | Cigna         | 7.5  | 22.6  | 22.9  | 24.4   | 22.5 |
|           | Molina        | 20.3 | 37.5  | 23.3  | 10.8   | 8.1  |
|           | GuideWell     | 27.0 | 37.4  | 15.2  | 9.8    | 10.7 |
|           | Highmark      | 4.7  | 23.2  | 46.9  | 13.7   | 11.4 |
|           | BCBS          | 25.8 | 11.1  | 21.4  | 23.2   | 18.6 |
|           | Bright        | 10.6 | 21.5  | 20.4  | 17.8   | 29.7 |
|           | Oscar         | 16.1 | 24.9  | 27.8  | 14.1   | 17.2 |
|           | Wellcare      | 24.5 | 20.7  | 7.9   | 31.9   | 15.0 |
|           | Omaha         | 18.5 | 18.2  | 22.6  | 22.3   | 18.4 |
|           | Athene        | 18.6 | 13.8  | 22.7  | 17.7   | 27.2 |
|           | American      | 22.2 | 11.7  | 23.1  | 22.1   | 21.0 |
|           | Mass Mutual   | 8.8  | 11.6  | 24.1  | 23.4   | 32.1 |
|           | New York Life | 28.8 | 15.5  | 8.9   | 23.9   | 23.0 |
|           | Lincoln       | 19.2 | 24.1  | 16.1  | 22.9   | 17.7 |
|           | Equitable     | 18.7 | 9.7   | 50.4  | 16.8   | 4.4  |
|           | Allianz       | 12.9 | 31.7  | 22.6  | 13.3   | 19.5 |
| September | Medicare      | 17.2 | 24.6  | 2.6   | 20.9   | 34.8 |
|           | Medicaid      | 30.4 | 12.7  | 29.9  | 21.6   | 5.4  |
|           | Elevance      | 31.7 | 4.0   | 14.8  | 12.5   | 37.0 |
|           | HCSC          | 10.3 | 18.8  | 11.8  | 27.9   | 31.2 |
|           | UHC           | 14.5 | 2.2   | 32.8  | 9.5    | 41.0 |
|           | Centene       | 19.0 | 27.1  | 17.1  | 14.4   | 22.4 |
|           | Aetna         | 27.6 | 23.1  | 4.3   | 19.3   | 25.6 |
|           | Humana        | 3.3  | 31.0  | 34.9  | 25.9   | 4.9  |
|           | Cigna         | 26.9 | 19.6  | 21.9  | 4.8    | 26.8 |
|           | Molina        | 18.1 | 17.7  | 26.3  | 21.0   | 17.0 |
|           | GuideWell     | 18.3 | 33.6  | 32.0  | 7.5    | 8.6  |
|           | Highmark      | 16.7 | 26.4  | 6.1   | 25.5   | 25.2 |
|           | BCBS          | 5.8  | 9.6   | 34.5  | 44.9   | 5.2  |
|           | Bright        | 30.4 | 6.3   | 30.8  | 2.9    | 29.7 |
|           | Oscar         | 29.2 | 16.2  | 16.0  | 11.9   | 26.6 |
|           | Wellcare      | 4.3  | 34.3  | 41.9  | 12.6   | 7.0  |
|           | Omaha         | 9.1  | 9.6   | 23.4  | 2.7    | 55.2 |
|           | Athene        | 22.4 | 28.4  | 15.6  | 0.8    | 32.9 |
|           | American      | 17.2 | 23.7  | 18.4  | 20.9   | 19.8 |
|           | Mass Mutual   | 12.7 | 22.9  | 30.1  | 12.2   | 22.1 |
|           | New York Life | 20.0 | 24.3  | 21.9  | 27.7   | 6.2  |
|           | Lincoln       | 12.7 | 32.6  | 20.5  | 33.1   | 1.1  |
|           | Equitable     | 35.3 | 5.6   | 3.6   | 24.9   | 30.7 |
|           | Allianz       | 33.6 | 1.5   | 8.6   | 33.7   | 22.6 |
| October   | Medicare      | 30.6 | 4.1   | 28.7  | 17.6   | 19.1 |
|           | Medicaid      | 24.9 | 20.6  | 28.1  | 18.9   | 7.5  |
|           | Elevance      | 25.2 | 8.0   | 3.3   | 27.7   | 35.8 |
|           | HCSC          | 9.8  | 14.6  | 22.3  | 22.1   | 31.2 |
|           | UHC           | 5.0  | 35.8  | 23.2  | 29.1   | 6.9  |
|           | Centene       | 25.7 | 21.3  | 24.6  | 16.9   | 11.4 |
|           | Aetna         | 29.5 | 18.2  | 11.3  | 23.6   | 17.4 |
|           | Humana        | 34.5 | 11.2  | 21.3  | 1.2    | 31.8 |
|           | Cigna         | 2.2  | 31.2  | 19.0  | 27.3   | 20.3 |
|           | Molina        | 16.5 | 37.5  | 35.1  | 8.1    | 2.9  |
|           | GuideWell     | 22.8 | 30.5  | 11.7  | 17.5   | 17.6 |
|           | Highmark      | 28.9 | 3.2   | 18.6  | 33.0   | 16.3 |
|           | BCBS          | 10.4 | 21.3  | 21.2  | 29.7   | 17.5 |
|           | Bright        | 27.9 | 20.9  | 15.8  | 26.4   | 9.1  |
|           | Oscar         | 25.6 | 27.5  | 7.2   | 25.9   | 13.9 |
|           | Wellcare      | 32.9 | 20.5  | 18.8  | 26.0   | 1.8  |
|           | Omaha         | 23.1 | 11.1  | 31.2  | 5.0    | 29.6 |
|           | Athene        | 16.9 | 9.1   | 19.1  | 18.2   | 36.6 |
|           | American      | 0.0  | 31.9  | 30.1  | 23.7   | 14.2 |
|           | Mass Mutual   | 34.6 | 12.2  | 14.0  | 14.4   | 24.8 |
|           | New York Life | 18.8 | 10.4  | 26.6  | 23.8   | 20.4 |
|           | Lincoln       | 30.5 | 7.0   | 27.9  | 26.7   | 7.9  |
|           | Equitable     | 33.4 | 11.0  | 20.3  | 35.1   | 0.2  |
|           | Allianz       | 30.7 | 30.8  | 10.6  | 18.6   | 9.3  |
| November  | Medicare      | 33.8 | 7.8   | 18.2  | 21.1   | 19.2 |
|           | Medicaid      | 5.0  | 32.5  | 28.4  | 9.8    | 24.4 |
|           | Elevance      | 13.8 | 8.0   | 29.2  | 31.4   | 17.5 |
|           | HCSC          | 33.1 | 26.2  | 27.6  | 10.2   | 2.9  |
|           | UHC           | 17.6 | 23.7  | 16.5  | 28.8   | 13.4 |
|           | Centene       | 25.4 | 18.4  | 4.9   | 14.8   | 36.5 |
|           | Aetna         | 54.9 | 2.5   | 16.4  | 2.4    | 23.8 |
|           | Humana        | 10.0 | 13.7  | 38.5  | 8.9    | 28.8 |
|           | Cigna         | 21.0 | 7.2   | 33.8  | 25.6   | 12.4 |
|           | Molina        | 27.6 | 11.2  | 21.5  | 9.2    | 30.5 |
|           | GuideWell     | 28.3 | 0.6   | 37.7  | 7.2    | 26.3 |
|           | Highmark      | 28.5 | 12.6  | 18.6  | 23.6   | 16.7 |
|           | BCBS          | 27.7 | 21.1  | 16.2  | 8.9    | 26.0 |
|           | Bright        | 17.2 | 37.0  | 2.3   | 20.7   | 22.8 |
|           | Oscar         | 24.2 | 17.0  | 2.1   | 24.9   | 31.8 |
|           | Wellcare      | 14.7 | 28.9  | 3.0   | 26.6   | 26.8 |
|           | Omaha         | 12.9 | 22.1  | 31.5  | 6.9    | 26.5 |
|           | Athene        | 21.4 | 2.9   | 20.4  | 40.9   | 14.3 |
|           | American      | 17.7 | 36.1  | 6.8   | 2.8    | 36.5 |
|           | Mass Mutual   | 22.9 | 7.2   | 17.3  | 28.9   | 23.7 |
|           | New York Life | 35.5 | 0.6   | 27.3  | 35.1   | 1.6  |
|           | Lincoln       | 2.4  | 28.5  | 29.0  | 30.6   | 9.5  |
|           | Equitable     | 27.7 | 8.1   | 1.2   | 16.8   | 46.2 |
|           | Allianz       | 6.0  | 48.0  | 26.8  | 7.5    | 11.7 |
| December  | Medicare      | 29.4 | 16.4  | 17.1  | 7.1    | 29.9 |
|           | Medicaid      | 13.4 | 13.0  | 37.1  | 16.7   | 19.7 |
|           | Elevance      | 11.3 | 30.3  | 16.6  | 19.5   | 22.3 |
|           | HCSC          | 6.2  | 19.4  | 14.3  | 29.7   | 30.4 |
|           | UHC           | 27.6 | 38.7  | 17.9  | 14.5   | 1.2  |
|           | Centene       | 24.6 | 0.4   | 23.5  | 29.3   | 22.3 |
|           | Aetna         | 1.7  | 13.2  | 46.6  | 35.3   | 3.2  |
|           | Humana        | 28.7 | 23.0  | 10.1  | 3.4    | 34.8 |
|           | Cigna         | 39.9 | 15.4  | 6.1   | 12.2   | 26.4 |
|           | Molina        | 4.7  | 19.8  | 33.3  | 24.0   | 18.1 |
|           | GuideWell     | 16.9 | 20.1  | 33.3  | 15.2   | 14.5 |
|           | Highmark      | 15.4 | 32.1  | 24.6  | 26.7   | 1.2  |
|           | BCBS          | 22.1 | 19.3  | 26.2  | 8.9    | 23.5 |
|           | Bright        | 25.0 | 33.8  | 4.9   | 33.1   | 3.2  |
|           | Oscar         | 21.8 | 24.2  | 26.0  | 6.3    | 21.8 |
|           | Wellcare      | 30.4 | 15.5  | 17.5  | 6.8    | 29.8 |
|           | Omaha         | 21.5 | 17.6  | 20.5  | 18.8   | 21.7 |
|           | Athene        | 13.6 | 24.6  | 10.5  | 28.4   | 23.0 |
|           | American      | 3.6  | 25.1  | 23.8  | 41.0   | 6.6  |
|           | Mass Mutual   | 17.8 | 1.2   | 49.9  | 19.7   | 11.5 |
|           | New York Life | 12.8 | 18.8  | 12.0  | 31.1   | 25.3 |
|           | Lincoln       | 12.4 | 9.3   | 9.6   | 46.8   | 22.0 |
|           | Equitable     | 35.4 | 12.4  | 34.0  | 2.1    | 16.1 |
|           | Allianz       | 36.3 | 37.6  | 5.5   | 18.0   | 2.5  |

``` r
ex_prop <- mock_parbx() |> 
  pivot_wider(names_from = "aging_bin", 
              values_from = "aging_prop") |> 
  select(month, payer, `121+`) |> 
  pivot_wider(names_from = month, values_from = `121+`) |> 
  rlang::set_names(c("payer", month.abb))

ex_prop_payer <- mock_parbx() |> 
  pivot_wider(names_from = "aging_bin", 
              values_from = "aging_prop") |> 
  select(month, payer, `121+`) |> 
  pivot_wider(names_from = payer, values_from = `121+`)

ex_prop |> 
  gt(rowname_col = "payer") |> 
  fmt_percent(decimals = 0) |>
  cols_align(align = "center") |> 
  data_color(
    columns = !payer,
    palette = "ggsci::red_material",
    apply_to = "text"
    ) |> 
  opt_table_font(font = google_font(name = "Fira Code")) |> 
  tab_options(
    column_labels.font.weight = "bold",
    quarto.disable_processing = TRUE,
    # table.background.color = "grey50",
    table.font.size = gt::px(18),
    table.width = gt::pct(100),
    heading.align = "left",
    heading.title.font.size = gt::px(24),
    heading.subtitle.font.size = gt::px(21))
```

|               | Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec |
|---------------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Medicare      | 44% | 31% | 35% | 31% | 1%  | 29% | 29% | 38% | 15% | 16% | 30% | 15% |
| Medicaid      | 31% | 1%  | 1%  | 4%  | 24% | 45% | 8%  | 30% | 26% | 14% | 35% | 21% |
| Elevance      | 40% | 2%  | 24% | 4%  | 30% | 32% | 25% | 31% | 4%  | 28% | 5%  | 29% |
| HCSC          | 20% | 24% | 38% | 37% | 6%  | 9%  | 25% | 1%  | 30% | 1%  | 12% | 34% |
| UHC           | 31% | 23% | 36% | 31% | 22% | 7%  | 22% | 22% | 44% | 38% | 9%  | 11% |
| Centene       | 42% | 17% | 16% | 10% | 9%  | 10% | 19% | 26% | 5%  | 30% | 33% | 9%  |
| Aetna         | 3%  | 9%  | 34% | 30% | 8%  | 38% | 30% | 42% | 27% | 24% | 26% | 32% |
| Humana        | 25% | 24% | 1%  | 13% | 23% | 12% | 8%  | 5%  | 29% | 25% | 8%  | 28% |
| Cigna         | 28% | 12% | 13% | 33% | 34% | 10% | 10% | 15% | 42% | 5%  | 22% | 16% |
| Molina        | 16% | 28% | 18% | 42% | 11% | 17% | 22% | 40% | 20% | 38% | 27% | 9%  |
| GuideWell     | 22% | 14% | 22% | 10% | 29% | 10% | 13% | 10% | 29% | 32% | 2%  | 26% |
| Highmark      | 7%  | 6%  | 16% | 22% | 11% | 9%  | 28% | 33% | 17% | 12% | 16% | 33% |
| BCBS          | 33% | 12% | 22% | 26% | 31% | 3%  | 12% | 32% | 14% | 19% | 13% | 7%  |
| Bright        | 23% | 0%  | 7%  | 17% | 14% | 27% | 38% | 26% | 10% | 3%  | 25% | 1%  |
| Oscar         | 2%  | 8%  | 29% | 6%  | 22% | 21% | 0%  | 17% | 2%  | 5%  | 29% | 3%  |
| Wellcare      | 40% | 5%  | 14% | 4%  | 38% | 29% | 32% | 26% | 16% | 2%  | 32% | 19% |
| Omaha         | 29% | 51% | 11% | 40% | 6%  | 14% | 10% | 13% | 34% | 9%  | 34% | 19% |
| Athene        | 29% | 7%  | 25% | 38% | 18% | 2%  | 24% | 22% | 24% | 11% | 65% | 8%  |
| American      | 65% | 12% | 12% | 1%  | 27% | 9%  | 16% | 29% | 19% | 28% | 34% | 17% |
| Mass Mutual   | 26% | 24% | 15% | 4%  | 29% | 24% | 24% | 34% | 16% | 12% | 16% | 28% |
| New York Life | 24% | 15% | 19% | 19% | 28% | 24% | 42% | 23% | 32% | 18% | 22% | 4%  |
| Lincoln       | 21% | 27% | 9%  | 30% | 21% | 22% | 6%  | 23% | 12% | 20% | 15% | 14% |
| Equitable     | 10% | 28% | 2%  | 6%  | 26% | 10% | 14% | 21% | 33% | 6%  | 26% | 21% |
| Allianz       | 9%  | 16% | 6%  | 15% | 17% | 31% | 14% | 33% | 27% | 30% | 11% | 5%  |

``` r
ex_prop |> 
  reframe(
    payer,
    Jan = min_rank(Jan),
    Feb = min_rank(Feb),
    Mar = min_rank(Mar),
    Apr = min_rank(Apr),
    May = min_rank(May),
    Jun = min_rank(Jun),
    Jul = min_rank(Jul),
    Aug = min_rank(Aug),
    Sep = min_rank(Sep),
    Oct = min_rank(Oct),
    Nov = min_rank(Nov),
    Dec = min_rank(Dec)) |> 
  gt(rowname_col = "payer") |> 
  opt_table_font(font = google_font(name = "JetBrains Mono")) |> 
  data_color(
    columns = !payer,
    palette = "Greens",
    apply_to = "text",
    reverse = TRUE
    ) |> 
  cols_align(align = "center") |> 
  tab_options(
    column_labels.font.weight = "bold",
    column_labels.font.size = px(16),
    column_labels.border.bottom.width = px(3),
    quarto.disable_processing = TRUE,
    table.font.size = px(18),
    table.width = pct(75),
    heading.align = "left",
    heading.title.font.size = px(24),
    heading.subtitle.font.size = px(21),
    table_body.hlines.style = "none",
    column_labels.border.top.color = "darkgreen",
    column_labels.border.bottom.color = "darkgreen",
    table_body.border.bottom.color = "darkgreen",
    stub.border.style = "none",
    stub.background.color = "darkgreen"
    )
```

|               | Jan | Feb | Mar | Apr | May | Jun | Jul | Aug | Sep | Oct | Nov | Dec |
|---------------|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|-----|
| Medicare      | 23  | 23  | 22  | 18  | 1   | 19  | 20  | 22  | 7   | 12  | 18  | 11  |
| Medicaid      | 17  | 2   | 2   | 3   | 15  | 24  | 4   | 16  | 14  | 11  | 23  | 16  |
| Elevance      | 20  | 3   | 18  | 5   | 21  | 22  | 18  | 17  | 2   | 18  | 2   | 21  |
| HCSC          | 7   | 17  | 24  | 21  | 2   | 5   | 17  | 1   | 19  | 1   | 6   | 24  |
| UHC           | 18  | 16  | 23  | 19  | 13  | 3   | 13  | 8   | 24  | 23  | 4   | 9   |
| Centene       | 22  | 15  | 12  | 8   | 5   | 9   | 12  | 12  | 3   | 21  | 20  | 8   |
| Aetna         | 2   | 8   | 21  | 17  | 4   | 23  | 21  | 24  | 15  | 16  | 14  | 22  |
| Humana        | 12  | 19  | 1   | 10  | 14  | 11  | 3   | 2   | 17  | 17  | 3   | 20  |
| Cigna         | 14  | 9   | 9   | 20  | 23  | 10  | 5   | 5   | 23  | 5   | 11  | 12  |
| Molina        | 6   | 22  | 14  | 24  | 6   | 13  | 14  | 23  | 12  | 24  | 16  | 7   |
| GuideWell     | 9   | 12  | 17  | 9   | 19  | 7   | 8   | 3   | 18  | 22  | 1   | 18  |
| Highmark      | 3   | 5   | 13  | 14  | 7   | 6   | 19  | 19  | 10  | 10  | 10  | 23  |
| BCBS          | 19  | 10  | 16  | 15  | 22  | 2   | 7   | 18  | 6   | 14  | 7   | 5   |
| Bright        | 10  | 1   | 5   | 12  | 8   | 18  | 23  | 14  | 4   | 3   | 13  | 1   |
| Oscar         | 1   | 7   | 20  | 6   | 12  | 14  | 1   | 6   | 1   | 4   | 17  | 2   |
| Wellcare      | 21  | 4   | 10  | 4   | 24  | 20  | 22  | 13  | 8   | 2   | 19  | 14  |
| Omaha         | 16  | 24  | 7   | 23  | 3   | 12  | 6   | 4   | 22  | 7   | 22  | 15  |
| Athene        | 15  | 6   | 19  | 22  | 10  | 1   | 15  | 9   | 13  | 8   | 24  | 6   |
| American      | 24  | 11  | 8   | 1   | 17  | 4   | 11  | 15  | 11  | 19  | 21  | 13  |
| Mass Mutual   | 13  | 18  | 11  | 2   | 20  | 17  | 16  | 21  | 9   | 9   | 9   | 19  |
| New York Life | 11  | 13  | 15  | 13  | 18  | 16  | 24  | 11  | 20  | 13  | 12  | 3   |
| Lincoln       | 8   | 20  | 6   | 16  | 11  | 15  | 2   | 10  | 5   | 15  | 8   | 10  |
| Equitable     | 5   | 21  | 3   | 7   | 16  | 8   | 9   | 7   | 21  | 6   | 15  | 17  |
| Allianz       | 4   | 14  | 4   | 11  | 9   | 21  | 10  | 20  | 16  | 20  | 5   | 4   |
