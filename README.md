
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `forager` <a href="https://andrewallenbruce.github.io/forager/"><img src="man/figures/logo.svg" align="right" height="500"/></a>

> ***Forager** (noun)*
>
> *A person that goes from place to place searching for things that they
> can eat or use.*[^1]

> ***Ager** (noun)*
>
> *A person that calls from place to place searching for payment before
> insurance can refuse.*[^2]

<br>

<!-- badges: start -->

[![R-CMD-check](https://github.com/andrewallenbruce/forager/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/andrewallenbruce/forager/actions/workflows/R-CMD-check.yaml)
[![lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://lifecycle.r-lib.org/articles/stages.html#experimental)
[![repo status:
WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![License:
MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://choosealicense.com/licenses/mit/)
[![code
size](https://img.shields.io/github/languages/code-size/andrewallenbruce/forager.svg)](https://github.com/andrewallenbruce/forager)
[![last
commit](https://img.shields.io/github/last-commit/andrewallenbruce/forager.svg)](https://github.com/andrewallenbruce/forager/commits/master)

<!-- badges: end -->

The goal of {forager} is to provide a suite of tools for the analysis of
common healthcare revenue cycle management Key Performance Indicators
(KPIs).

## Installation

You can install the development version of forager from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("andrewallenbruce/forager")
```

## Aging Calculation

``` r
library(forager)
```

<br>

``` r
date_ex <- tibble::tibble(
  dos = as.POSIXct(
    c(
      "2022-02-10", "2022-02-09", "2022-02-08", "2022-02-08", "2022-02-07",
      "2022-02-07", "2022-02-05", "2022-02-05", "2022-02-02", "2022-02-02",
      "2022-02-02", "2022-02-01", "2022-02-01", "2022-02-01", "2022-01-31",
      "2022-01-30", "2022-01-30", "2022-01-29", "2022-01-29", "2022-01-28",
      "2022-01-28", "2022-01-28", "2022-01-21", "2022-01-21", "2022-01-20",
      "2022-01-20", "2022-01-20", "2022-01-08", "2022-01-07", "2021-12-31",
      "2021-12-31", "2021-12-31", "2021-12-31", "2021-12-31", "2021-12-27",
      "2021-12-27", "2021-12-26", "2021-12-26", "2021-12-25", "2021-12-25",
      "2021-12-25", "2021-12-25", "2021-12-25", "2021-12-25", "2021-12-19",
      "2021-12-18", "2021-12-08", "2021-11-27", "2021-11-20", "2021-11-20",
      "2021-11-19", "2021-11-19"
    ),
    tz = "UTC"
  ),
  dor = as.POSIXct(
    c(
      "2022-02-28", "2022-02-10", "2022-02-10", "2022-02-10", "2022-02-10",
      "2022-02-01", "2022-02-01", "2022-02-01", "2022-02-01", "2022-02-01",
      "2022-02-01", "2022-02-01", "2022-02-01", "2022-02-01", "2021-01-21",
      "2022-01-18", "2022-01-18", "2022-01-18", "2022-01-18", "2022-01-18",
      "2022-01-18", "2022-01-18", "2022-01-18", "2022-01-21", "2022-01-18",
      "2021-12-28", "2022-01-18", "2022-01-21", "2022-01-18", "2022-01-18",
      "2022-02-01", "2022-02-01", "2021-12-11", "2022-01-31", "2022-01-31",
      "2022-01-31", "2022-01-28", "2022-01-28", "2022-01-28", "2022-01-28",
      "2022-01-28", "2022-01-28", "2022-01-31", "2022-01-31", "2022-01-31",
      "2022-01-31", "2022-01-31", "2022-01-31", "2022-01-31", "2022-01-31",
      "2022-01-31", "2022-01-31"
    ),
    tz = "UTC"
  ),
)
```

<br> Calculate the number of days between the Date of Service (DOS) and
today’s date: <br>

``` r
date_ex |> 
  dplyr::select(dos) |> 
  dplyr::mutate(today = lubridate::today()) |> 
  forager::age_days(dos, today) |> 
  dplyr::arrange(desc(age))
#> # A tibble: 52 × 3
#>    dos                 today        age
#>    <dttm>              <date>     <dbl>
#>  1 2021-11-19 00:00:00 2022-09-05   292
#>  2 2021-11-19 00:00:00 2022-09-05   292
#>  3 2021-11-20 00:00:00 2022-09-05   291
#>  4 2021-11-20 00:00:00 2022-09-05   291
#>  5 2021-11-27 00:00:00 2022-09-05   284
#>  6 2021-12-08 00:00:00 2022-09-05   273
#>  7 2021-12-18 00:00:00 2022-09-05   263
#>  8 2021-12-19 00:00:00 2022-09-05   262
#>  9 2021-12-25 00:00:00 2022-09-05   256
#> 10 2021-12-25 00:00:00 2022-09-05   256
#> # … with 42 more rows
```

<br> Calculate the number of days between the Date of Service (DOS) and
the Date of Release (DOR): <br>

``` r
date_ex |> 
  dplyr::select(dos, dor) |>
  dplyr::filter(!is.na(dor)) |> 
  forager::age_days(dos, dor) |> 
  dplyr::arrange(desc(age))
#> # A tibble: 52 × 3
#>    dos                 dor                   age
#>    <dttm>              <dttm>              <dbl>
#>  1 2021-11-19 00:00:00 2022-01-31 00:00:00    74
#>  2 2021-11-19 00:00:00 2022-01-31 00:00:00    74
#>  3 2021-11-20 00:00:00 2022-01-31 00:00:00    73
#>  4 2021-11-20 00:00:00 2022-01-31 00:00:00    73
#>  5 2021-11-27 00:00:00 2022-01-31 00:00:00    66
#>  6 2021-12-08 00:00:00 2022-01-31 00:00:00    55
#>  7 2021-12-18 00:00:00 2022-01-31 00:00:00    45
#>  8 2021-12-19 00:00:00 2022-01-31 00:00:00    44
#>  9 2021-12-25 00:00:00 2022-01-31 00:00:00    38
#> 10 2021-12-25 00:00:00 2022-01-31 00:00:00    38
#> # … with 42 more rows
```

<br><br>

## Days in AR Monthly Calculation

The following is a basic example of a monthly Days in AR calculation:

``` r
# Example data frame
dar_mon_ex |> 
  knitr::kable(col.names = c("Month", "Total Gross Charges", "Ending AR Balance"))
```

| Month      | Total Gross Charges | Ending AR Balance |
|:-----------|--------------------:|------------------:|
| 2022-01-01 |            325982.0 |          288432.5 |
| 2022-02-01 |            297731.7 |          307871.1 |
| 2022-03-01 |            198655.1 |          253976.6 |
| 2022-04-01 |            186047.0 |          183684.9 |
| 2022-05-01 |            123654.0 |          204227.6 |
| 2022-06-01 |            131440.3 |          203460.5 |
| 2022-07-01 |            153991.0 |          182771.3 |
| 2022-08-01 |            156975.0 |          169633.6 |
| 2022-09-01 |            146878.1 |          179347.7 |
| 2022-10-01 |            163799.4 |          178051.1 |
| 2022-11-01 |            151410.7 |          162757.5 |
| 2022-12-01 |            169094.5 |          199849.3 |

<br>

Using the `dar_month()` function, we set the Days in AR target (`dart`)
to 35 and calculate:

<br>

``` r
dar_month_2022 <- dar_mon_ex |> forager::dar_month(date, gct, earb, 35)
```

<br>

| Month     | Gross Charges | Ending AR | Target AR | Days in AR | Pass  |
|:----------|--------------:|----------:|----------:|-----------:|:------|
| January   |      325982.0 |  288432.5 |  368044.2 |      27.43 | TRUE  |
| February  |      297731.7 |  307871.1 |  372164.7 |      28.95 | TRUE  |
| March     |      198655.1 |  253976.6 |  224288.1 |      39.63 | FALSE |
| April     |      186047.0 |  183684.9 |  217054.8 |      29.62 | TRUE  |
| May       |      123654.0 |  204227.6 |  139609.4 |      51.20 | FALSE |
| June      |      131440.3 |  203460.5 |  153347.0 |      46.44 | FALSE |
| July      |      153991.0 |  182771.3 |  173860.8 |      36.79 | FALSE |
| August    |      156975.0 |  169633.6 |  177229.8 |      33.50 | TRUE  |
| September |      146878.1 |  179347.7 |  171357.8 |      36.63 | FALSE |
| October   |      163799.4 |  178051.1 |  184934.9 |      33.70 | TRUE  |
| November  |      151410.7 |  162757.5 |  176645.9 |      32.25 | TRUE  |
| December  |      169094.5 |  199849.3 |  190913.1 |      36.64 | FALSE |

<br>

### Presentation Examples

<details>
<summary>
Click to View Code for Table
</summary>

``` r
gt_1 <- dar_month_2022 |> 
  dplyr::select(month, gct, earb, earb_trg, dar, pass) |> 
  headliner::add_headline_column(x = earb, y = earb_trg, 
  headline = "{delta_p}% {trend} than Target", 
  trend_phrases = headliner::trend_terms(more = "HIGHER", less = "Lower"), n_decimal = 0) |> 
  gt::gt(rowname_col = "month") |> 
  gt::cols_label(gct = "Gross Charges",
                 earb = "Ending AR",
                 earb_trg = "Target AR",
                 dar = "Days in AR",
                 pass = "Pass",
                 headline = "Ending AR Trend") |> 
  gt::tab_row_group(label = "Q4", rows = c(10:12)) |>
  gt::tab_row_group(label = "Q3", rows = c(7:9)) |>
  gt::tab_row_group(label = "Q2", rows = c(4:6)) |>
  gt::tab_row_group(label = "Q1", rows = c(1:3)) |> 
  gt::fmt_number(columns = dar) |>
  gt::fmt_currency(columns = c(gct, earb, earb_trg)) |>
  gt::tab_style(style = gt::cell_text(font = c(gt::google_font(name = "IBM Plex Mono"),
  gt::default_fonts())), locations = gt::cells_body(columns = c(gct, earb, earb_trg, dar))) |> 
  gt::opt_stylize(style = 6, color = "cyan") |> 
  gt::tab_header(
    title = gt::md("Example **Days in AR Analysis** with the **{forager}** Package"), 
    subtitle = gt::md("**May** saw the *highest* Days in AR of 2022 *(51.2)*. This coincided with the largest <br> month-to-month increase in AR & highest percentage over the AR Target *(46%)*.")) |> 
  gt::opt_all_caps() |> 
  gt::grand_summary_rows(
    columns = c(gct, earb, earb_trg, dar),
    fns = list(Mean = ~mean(., na.rm = TRUE), Median = ~median(., na.rm = TRUE))) |> 
  gt::opt_table_font(font = list(gt::google_font(name = "Roboto"))) |> 
  gt::opt_align_table_header(align = "left")

#gt_1 |> gt::gtsave("gt_1.png", expand = 20)
```

</details>

<img src="man/figures/gt_1.png" style="width:75.0%" />

<details>
<summary>
Click to View Code for Table
</summary>

``` r
# Create df for gt_plt_bar_stack
dar_month_2022_pct <- dar_month_2022 |>
  dplyr::mutate(gct_pct = (gct / (gct + earb) * 100),
         earb_pct = (earb / (gct + earb) * 100)) |>
  dplyr::select(month, gct_pct, earb_pct) |>
  tidyr::pivot_longer(-month, names_to = "measure", values_to = "percentage") |>
  dplyr::group_by(month) |>
  dplyr::summarize(list_data = list(percentage))

# Right join the two data frames
dar_month_2022_join <- dplyr::right_join(dar_month_2022, 
                                         dar_month_2022_pct, 
                                         by = "month")

# Create new copy cols for gt_plt_bullet
dar_month_2022_gt <- dar_month_2022_join |> 
  dplyr::select(month, 
                gct, 
                earb, 
                earb_trg, 
                dar, 
                pass,
                list_data) |>
  dplyr::mutate(target_col = earb, 
                plot_col = earb_trg)

# Create gt table
gt_2 <- dar_month_2022_gt |> 
  gt::gt(rowname_col = "month") |>
  gt::cols_label(
    #month = "Month",
                 gct = "Gross Charges",
                 earb = "Ending AR",
                 earb_trg = "Optimal AR",
                 dar = "Days in AR",
                 pass = "Pass",
                 plot_col = "Optimal AR Threshold") |>
  gt::tab_row_group(label = "Q4", rows = c(10:12)) |>
  gt::tab_row_group(label = "Q3", rows = c(7:9)) |>
  gt::tab_row_group(label = "Q2", rows = c(4:6)) |>
  gt::tab_row_group(label = "Q1", rows = c(1:3)) |> 
  #gt::tab_options(row_group.as_column = TRUE) |> 
  gtExtras::gt_theme_espn() |> 
  gt::fmt_number(columns = dar) |>
  gt::fmt_currency(columns = c(gct, earb, earb_trg)) |>
  #gtExtras::gt_plt_dot(dar, month, palette = c("#2c3e50", "#8ca0aa")) |> 
  gtExtras::gt_plt_bullet(column = plot_col, target = target_col, palette = c("#8ca0aa", "black"), width = 65) |>
  gtExtras::gt_plt_bar_stack(list_data, width = 50, labels = c("Charges (%) ", " AR (%)"), palette = c("#2c3e50", "#8ca0aa")) |>
  gtExtras::gt_badge(pass, palette = c("FALSE" = "#8ca0aa")) |> 
  gt::tab_style(style = gt::cell_text(color = "#2c3e50", weight = "bolder"), locations = gt::cells_body(columns = pass, rows = pass == "FALSE")) |>
  gt::tab_style(style = gt::cell_text(color = "#8ca0aa", weight = "normal"), locations = gt::cells_body(columns = pass, rows = pass == "TRUE")) |> 
  gt::data_color(columns = c(gct, earb, dar), colors = scales::col_numeric(palette = c("#2c3e50", "#8ca0aa") |> as.character(), domain = NULL)) |> 
  gt::tab_footnote(footnote = "Horizontal bar indicates Optimal AR, vertical bar is Actual.", locations = gt::cells_column_labels(columns = plot_col)) |> 
  gt::tab_header(title = gt::md("Example **Days in AR Analysis** with the **{forager}** Package"))

#gt_2 |> gt::gtsave("gt_2.png", expand = 20)
```

</details>

<img src="man/figures/gt_2.png" style="width:75.0%" />

<br>

``` r
library(GGally)
#> Loading required package: ggplot2
#> Registered S3 method overwritten by 'GGally':
#>   method from   
#>   +.gg   ggplot2
dar_month_2022 |> 
  dplyr::select(earb, 
                earb_trg, 
                gct, 
                dar,
                pass) |> 
  ggparcoord(columns = 1:4, 
             scale = "uniminmax",
             #scale = "globalminmax",
             groupColumn = "pass") + 
  ggplot2::scale_color_manual(values = c("red", "#00BFC4")) +
  ggplot2::xlab("") +
  ggplot2::ylab("") +
  ggplot2::coord_flip() +
  ggplot2::facet_wrap("pass") +
  ggplot2::theme(legend.position = "none")
```

<img src="man/figures/README-unnamed-chunk-11-1.png" width="100%" />

## Days in AR Quarterly Calculation

``` r
dar_quarter_2022 <- dar_mon_ex |> forager::dar_qtr(date, gct, earb, 35)
```

<br>

| Quarter | Gross Charges | Ending AR | Target AR | Days in AR | Pass  |
|--------:|--------------:|----------:|----------:|-----------:|:------|
|       1 |      822368.9 |  253976.6 |  319810.1 |      27.80 | TRUE  |
|       2 |      441141.3 |  203460.5 |  169669.7 |      41.97 | FALSE |
|       3 |      457844.1 |  179347.7 |  174179.8 |      36.04 | FALSE |
|       4 |      484304.6 |  199849.3 |  184246.3 |      37.96 | FALSE |

<br>

``` r
library(GGally)
dar_quarter_2022 |> 
  dplyr::select(earb, 
                earb_trg, 
                gct_qtr, 
                dar,
                pass) |> 
  ggparcoord(columns = 1:4, 
             scale = "uniminmax",
             #scale = "globalminmax",
             groupColumn = "pass") + 
  ggplot2::scale_color_manual(values = c("red", "#00BFC4")) +
  ggplot2::xlab("") +
  ggplot2::ylab("") +
  ggplot2::coord_flip() +
  ggplot2::facet_wrap("pass") +
  ggplot2::theme(legend.position = "none")
```

<img src="man/figures/README-unnamed-chunk-14-1.png" width="100%" />

## Code of Conduct

Please note that the `forager` project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/forager/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: <https://dictionary.cambridge.org/dictionary/english/forager>

[^2]: Me.
