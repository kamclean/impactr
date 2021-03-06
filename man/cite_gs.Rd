% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/cite_gs.R
\name{cite_gs}
\alias{cite_gs}
\title{Extract additional citation metrics from Google Scholar}
\usage{
cite_gs(df, gscholar_id, match_title_nchar = 50)
}
\arguments{
\item{df}{Dataframe containing at least three columns: publictaion title ("title"), publication year ("year"), and DOI/PMID with each publication listed as a row.}

\item{match_title_nchar}{Argument to specify how many characters the titles should be matched (default = 50). See "unmatch" output.}

\item{scholar_id}{Google scholar ID number linking to records in the dataframe.}
}
\value{
Nested dataframe of: (1)."out_df" - Amended dataframe with additional total citations appended (2). "df_cite" - Dataframe of citations over time for google doc papers (3). "validation" - Dataframe of publications that could not be matched to a google scholar record (noscholar) or google scholar records that could not be matched to the dataframe (unmatched).
}
\description{
Extract additional citation metrics from Google Scholar
}
