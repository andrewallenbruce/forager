
<!-- README.md is generated from README.Rmd. Please edit that file -->

# `forager` <a href="https://andrewallenbruce.github.io/forager/"><img src="man/figures/logo.svg" align="right" height="500" /></a>

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

## Days in AR Calculation

This is a basic example of a monthly Days in AR calculation:

``` r
library(forager)

# Example data frame
dar_mon_ex |> 
  knitr::kable(
    digits = 2, 
    col.names = c(
      "Month", 
      "Gross Charges", 
      "Ending AR Balance"))
```

| Month      | Gross Charges | Ending AR Balance |
|:-----------|--------------:|------------------:|
| 2022-01-01 |      325982.0 |          288432.5 |
| 2022-02-01 |      297731.7 |          307871.1 |
| 2022-03-01 |      198655.1 |          253976.6 |
| 2022-04-01 |      186047.0 |          183684.9 |
| 2022-05-01 |      123654.0 |          204227.6 |
| 2022-06-01 |      131440.3 |          203460.5 |
| 2022-07-01 |      153991.0 |          182771.3 |
| 2022-08-01 |      156975.0 |          169633.6 |
| 2022-09-01 |      146878.1 |          179347.7 |
| 2022-10-01 |      163799.4 |          178051.1 |
| 2022-11-01 |      151410.7 |          162757.5 |
| 2022-12-01 |      169094.5 |          199849.3 |

``` r
dar_month_2022 <- dar_month(dar_mon_ex, date, gct, earb, dart = 35)

dar_month_2022
#>          date      gct     earb nmon     month ndip      adc   dar actual ideal
#> 1  2022-01-01 325982.0 288432.5    1   January   31 10515.55 27.43   0.88  1.13
#> 2  2022-02-01 297731.7 307871.1    2  February   28 10633.28 28.95   1.03  1.25
#> 3  2022-03-01 198655.1 253976.6    3     March   31  6408.23 39.63   1.28  1.13
#> 4  2022-04-01 186047.0 183684.9    4     April   30  6201.57 29.62   0.99  1.17
#> 5  2022-05-01 123654.0 204227.6    5       May   31  3988.84 51.20   1.65  1.13
#> 6  2022-06-01 131440.3 203460.5    6      June   30  4381.34 46.44   1.55  1.17
#> 7  2022-07-01 153991.0 182771.3    7      July   31  4967.45 36.79   1.19  1.13
#> 8  2022-08-01 156975.0 169633.6    8    August   31  5063.71 33.50   1.08  1.13
#> 9  2022-09-01 146878.1 179347.7    9 September   30  4895.94 36.63   1.22  1.17
#> 10 2022-10-01 163799.4 178051.1   10   October   31  5283.85 33.70   1.09  1.13
#> 11 2022-11-01 151410.7 162757.5   11  November   30  5047.02 32.25   1.07  1.17
#> 12 2022-12-01 169094.5 199849.3   12  December   31  5454.66 36.64   1.18  1.13
#>    radiff earb_trg   earb_dc earb_dcpct  pass
#> 1   -0.25 368044.2 -79611.67      -0.28  TRUE
#> 2   -0.22 372164.7 -64293.60      -0.21  TRUE
#> 3    0.15 224288.1  29688.50       0.12 FALSE
#> 4   -0.18 217054.8 -33369.93      -0.18  TRUE
#> 5    0.52 139609.4  64618.24       0.32 FALSE
#> 6    0.38 153347.0  50113.48       0.25 FALSE
#> 7    0.06 173860.8   8910.51       0.05 FALSE
#> 8   -0.05 177229.8  -7596.20      -0.04  TRUE
#> 9    0.05 171357.8   7989.91       0.04 FALSE
#> 10  -0.04 184934.9  -6883.74      -0.04  TRUE
#> 11  -0.10 176645.9 -13888.37      -0.09  TRUE
#> 12   0.05 190913.1   8936.20       0.04 FALSE
```

## Code of Conduct

Please note that the forager project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/forager/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: <https://dictionary.cambridge.org/dictionary/english/forager>

[^2]: Me.
