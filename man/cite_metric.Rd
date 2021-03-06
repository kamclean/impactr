% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cite_metric.R
\name{cite_metric}
\alias{cite_metric}
\title{Calculate several common citation metrics (H-Index, G-Index, M-Quotient).}
\usage{
cite_metric(citations, year = "")
}
\arguments{
\item{citations}{Vector of citations (numerical variable).}

\item{year}{Vector of years or minimum year of publication (optional - required for M-Quotient)}
}
\value{
Dataframe of citation metrics for data supplied (H-Index, G-Index, M-Quotient)
}
\description{
Calculate several common citation metrics (H-Index, G-Index, M-Quotient).
}
