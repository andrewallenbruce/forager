
<!-- README.md is generated from README.Rmd. Please edit that file -->

# forager

<!-- badges: start -->

[![R-CMD-check](https://github.com/andrewallenbruce/forager/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/andrewallenbruce/forager/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

The goal of forager is to provide tools for common healthcare revenue
cycle management processes and analyses.

## Installation

You can install the development version of forager from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("andrewallenbruce/forager")
```

## Calculating Days in AR

This is a basic example of a monthly Days in Accounts Receivables
calculation:

``` r
library(forager)

# Example data frame
dar_mon_ex
#>          date      gct     earb
#> 1  2022-01-01 325982.0 288432.5
#> 2  2022-02-01 297731.7 307871.1
#> 3  2022-03-01 198655.1 253976.6
#> 4  2022-04-01 186047.0 183684.9
#> 5  2022-05-01 123654.0 204227.6
#> 6  2022-06-01 131440.3 203460.5
#> 7  2022-07-01 153991.0 182771.3
#> 8  2022-08-01 156975.0 169633.6
#> 9  2022-09-01 146878.1 179347.7
#> 10 2022-10-01 163799.4 178051.1
#> 11 2022-11-01 151410.7 162757.5
#> 12 2022-12-01 169094.5 199849.3
```

``` r
dar_month(dar_mon_ex, date, gct, earb, dart = 39.445)
#>          date      gct     earb nmon     month ndip      adc   dar actual ideal
#> 1  2022-01-01 325982.0 288432.5    1   January   31 10515.55 27.43   0.88  1.27
#> 2  2022-02-01 297731.7 307871.1    2  February   28 10633.28 28.95   1.03  1.41
#> 3  2022-03-01 198655.1 253976.6    3     March   31  6408.23 39.63   1.28  1.27
#> 4  2022-04-01 186047.0 183684.9    4     April   30  6201.57 29.62   0.99  1.31
#> 5  2022-05-01 123654.0 204227.6    5       May   31  3988.84 51.20   1.65  1.27
#> 6  2022-06-01 131440.3 203460.5    6      June   30  4381.34 46.44   1.55  1.31
#> 7  2022-07-01 153991.0 182771.3    7      July   31  4967.45 36.79   1.19  1.27
#> 8  2022-08-01 156975.0 169633.6    8    August   31  5063.71 33.50   1.08  1.27
#> 9  2022-09-01 146878.1 179347.7    9 September   30  4895.94 36.63   1.22  1.31
#> 10 2022-10-01 163799.4 178051.1   10   October   31  5283.85 33.70   1.09  1.27
#> 11 2022-11-01 151410.7 162757.5   11  November   30  5047.02 32.25   1.07  1.31
#> 12 2022-12-01 169094.5 199849.3   12  December   31  5454.66 36.64   1.18  1.27
#>    radiff earb_trg    earb_dc earb_dcpct  pass
#> 1   -0.39 414785.8 -126353.29      -0.44  TRUE
#> 2   -0.38 419429.6 -111558.51      -0.36  TRUE
#> 3    0.01 252772.6    1203.91       0.00 FALSE
#> 4   -0.32 244620.8  -60935.90      -0.33  TRUE
#> 5    0.38 157339.7   46887.85       0.23 FALSE
#> 6    0.24 172822.1   30638.41       0.15 FALSE
#> 7   -0.08 195941.1  -13169.81      -0.07  TRUE
#> 8   -0.19 199738.0  -30104.39      -0.18  TRUE
#> 9   -0.09 193120.2  -13772.53      -0.08  TRUE
#> 10  -0.18 208421.6  -30370.47      -0.17  TRUE
#> 11  -0.24 199079.9  -36322.40      -0.22  TRUE
#> 12  -0.09 215159.1  -15309.76      -0.08  TRUE
```
