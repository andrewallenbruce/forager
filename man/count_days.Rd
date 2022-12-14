% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/utils.R
\name{count_days}
\alias{count_days}
\title{Count days between two dates}
\usage{
count_days(df, start, end, name)
}
\arguments{
\item{df}{data frame}

\item{start}{date column}

\item{end}{date column}

\item{name}{name of output column}
}
\value{
A \link[tibble:tibble-package]{tibble}
}
\description{
Count days between two dates
}
\examples{
generate_data(rows = 5) |>
tidyr::unnest(dates) |>
count_days(date_of_service, date_of_release, provider_lag)
}
