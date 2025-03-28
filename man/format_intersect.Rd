% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/format_intersect.R
\name{format_intersect}
\alias{format_intersect}
\title{Determine intersections (combinations) for upset or venn diagrams.}
\usage{
format_intersect(data)
}
\arguments{
\item{data}{Dataset containing only columns which intersections are aiming to be determined for (must be binary - 01)}
}
\value{
Tibble of combinations with the name of the sets provided.
}
\description{
Determine intersections (combinations) for upset or venn diagrams.
}
