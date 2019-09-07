# impact_cite----------------------
# Documentation
#' @title Extract additional traditional metrics from Google Scholar
#' @description Extract additional traditional metrics from Google Scholar
#' @param df Dataframe containing at least two columns: publication year ("year") and  with each publication listed as a row.
#' @param scholar_id Google scholar ID number linking to records in the dataframe.
#' @param var_citation Column in dataframe which already contains number of citations for each publication (optional).
#' @param match_by_year Argument to match publications by title and year, rather than just title (default = TRUE). See "unmatch" output.
#' @param h_index Return H-index score (default = TRUE)
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @return Nested dataframe of: (1)."output" - Amended dataframe with additional citation metrics appended (2). "no_scholar" - Dataframe of publications with no scholar record (3). "unmatch" - Dataframe of publications that could not be matched to a journal. (4) "hindex" - H-Index score (if hindex = TRUE)
#' @export

impact_cite <- function(df, var_citation, var_year = "year", scholar_id=FALSE, match_title_nchar = 50, metric=TRUE){

  scholar <- NULL
  #  add in citations from google scholar
  if(scholar_id!=FALSE){
    scholar <- extract_scholar_cite(df, scholar_id = scholar_id, match_title_nchar = match_title_nchar)

    df <- scholar$out_df %>%
      dplyr::mutate(var_citation = cite_gs)}

  if(var_year=="year"){df <- df %>%
    dplyr::mutate(var_citation = dplyr::pull(., var_citation),
                  var_year = year)}else{df <- df %>%
                    dplyr::mutate(var_citation = dplyr::pull(., var_citation),
                                  var_year = dplyr::pull(., var_year))}

  # add in citations from other sources
  # TBC

  # add in citation metrics
  df_metric <- NULL
  if(metric==TRUE){df_metric <- suppressWarnings(impact_cite_metric(citations = df$var_citation, year = df$var_year))}


  df_out <- list("output" = dplyr::select(df, -var_citation,-var_year),
                 "validation" = scholar$validation,
                 "time" = scholar$out_cite,
                 "metric" = df_metric)
  return(df_out)}
