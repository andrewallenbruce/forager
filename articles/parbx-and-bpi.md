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
    parbx_nov = parbx_nov * forager:::prob(n()),
    parbx_dec = parbx_dec * forager:::prob(n()),
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

    #> # A tibble: 60 × 5
    #>    date       month    payer       bin    aging
    #>    <date>     <ord>    <fct>       <fct>  <dbl>
    #>  1 2025-01-01 January  Molina      0-30   0.19 
    #>  2 2025-01-01 January  Humana      31-60  0.29 
    #>  3 2025-01-01 January  Lincoln     61-90  0.36 
    #>  4 2025-01-01 January  Omaha       91-120 0.12 
    #>  5 2025-01-01 January  Highmark    121+   0.037
    #>  6 2025-02-01 February Mass Mutual 0-30   0.21 
    #>  7 2025-02-01 February Oscar       31-60  0.018
    #>  8 2025-02-01 February Athene      61-90  0.16 
    #>  9 2025-02-01 February Highmark    91-120 0.35 
    #> 10 2025-02-01 February Lincoln     121+   0.26 
    #> # ℹ 50 more rows

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

    #> Error in `mutate()`:
    #> ℹ In argument: `aging_prop = fuimus::roundup(aging_prop * 100)`.
    #> Caused by error:
    #> ! object 'aging_prop' not found

``` r
ex_prop <- mock_parbx() |> 
  pivot_wider(names_from = "aging_bin", 
              values_from = "aging_prop") |> 
  select(month, payer, `121+`) |> 
  pivot_wider(names_from = month, values_from = `121+`) |> 
  rlang::set_names(c("payer", month.abb))
```

    #> Error in `pivot_wider()`:
    #> ! Can't select columns that don't exist.
    #> ✖ Column `aging_bin` doesn't exist.

``` r
ex_prop_payer <- mock_parbx() |> 
  pivot_wider(names_from = "aging_bin", 
              values_from = "aging_prop") |> 
  select(month, payer, `121+`) |> 
  pivot_wider(names_from = payer, values_from = `121+`)
```

    #> Error in `pivot_wider()`:
    #> ! Can't select columns that don't exist.
    #> ✖ Column `aging_bin` doesn't exist.

``` r
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

    #> Error:
    #> ! object 'ex_prop' not found

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

    #> Error:
    #> ! object 'ex_prop' not found
