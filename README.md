
<!-- README.md is generated from README.Rmd. Please edit that file -->

# {forager}

> ***Forager** (noun)*
>
> *A person that goes from place to place searching for things that they
> can eat or use.*[^1]

> ***Ager** (noun)*
>
> *A person that calls from place to place searching for payment before
> insurance can refuse.*[^2]

<br><br>

<!-- badges: start -->

[![R-CMD-check](https://github.com/andrewallenbruce/forager/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/andrewallenbruce/forager/actions/workflows/R-CMD-check.yaml)
[![repo status:
WIP](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)

<!-- badges: end -->

The goal of {forager} is to provide tools for common healthcare revenue
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
dar_month(dar_mon_ex, date, gct, earb, dart = 39.445) |> 
  dplyr::select(!c(date, nmon, ndip, actual:radiff))
#>         gct     earb     month      adc   dar earb_trg    earb_dc earb_dcpct
#> 1  325982.0 288432.5   January 10515.55 27.43 414785.8 -126353.29      -0.44
#> 2  297731.7 307871.1  February 10633.28 28.95 419429.6 -111558.51      -0.36
#> 3  198655.1 253976.6     March  6408.23 39.63 252772.6    1203.91       0.00
#> 4  186047.0 183684.9     April  6201.57 29.62 244620.8  -60935.90      -0.33
#> 5  123654.0 204227.6       May  3988.84 51.20 157339.7   46887.85       0.23
#> 6  131440.3 203460.5      June  4381.34 46.44 172822.1   30638.41       0.15
#> 7  153991.0 182771.3      July  4967.45 36.79 195941.1  -13169.81      -0.07
#> 8  156975.0 169633.6    August  5063.71 33.50 199738.0  -30104.39      -0.18
#> 9  146878.1 179347.7 September  4895.94 36.63 193120.2  -13772.53      -0.08
#> 10 163799.4 178051.1   October  5283.85 33.70 208421.6  -30370.47      -0.17
#> 11 151410.7 162757.5  November  5047.02 32.25 199079.9  -36322.40      -0.22
#> 12 169094.5 199849.3  December  5454.66 36.64 215159.1  -15309.76      -0.08
#>     pass
#> 1   TRUE
#> 2   TRUE
#> 3  FALSE
#> 4   TRUE
#> 5  FALSE
#> 6  FALSE
#> 7   TRUE
#> 8   TRUE
#> 9   TRUE
#> 10  TRUE
#> 11  TRUE
#> 12  TRUE
```

## Code of Conduct

Please note that the forager project is released with a [Contributor
Code of
Conduct](https://andrewallenbruce.github.io/forager/CODE_OF_CONDUCT.html).
By contributing to this project, you agree to abide by its terms.

[^1]: <https://dictionary.cambridge.org/dictionary/english/forager>

[^2]: Bruce, A.A.
