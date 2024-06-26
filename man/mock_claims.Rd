% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/mock_data.R
\name{mock_claims}
\alias{mock_claims}
\title{Generate mock coding/billing data frame}
\usage{
mock_claims(rows = 100, payers = payer_names(), count_days = FALSE, ...)
}
\arguments{
\item{rows}{\verb{[integerish]} rows number of rows to generate; default is \code{100}}

\item{payers}{\verb{[character]} vector of payer names; default is \code{payer_names()}}

\item{count_days}{\verb{[logical]} add columns for days between events; default is \code{FALSE}}

\item{...}{\verb{[dots]} additional arguments}
}
\value{
A \link[tibble:tibble-package]{tibble}
}
\description{
Generate mock coding/billing data frame
}
\examples{
mock_claims(rows = 5)

}
