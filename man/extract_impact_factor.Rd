% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/extract_impact_factor.R
\name{extract_impact_factor}
\alias{extract_impact_factor}
\title{Provide a citation for a research publication}
\usage{
extract_impact_factor(
  data,
  var_id = "pmid",
  var_issn = "journal_issn",
  all = F
)
}
\arguments{
\item{data}{Dataframe with publications listed rowwise with at least 1 column containing the journal ISSN}

\item{var_id}{String of column name with identifier name: "pmid" or "doi" (default: "pmid")}

\item{var_issn}{String of column name with the journal International Standard Serial Number (ISSN) number listed (default: journal_issn)}

\item{all}{Logical value indicating if only the 2 year impact factor should be returned (or if it should include all impact factor information)}
}
\value{
Dataframe of journal impact metrics
}
\description{
Used to extract journal impact metrics for publications.
}
