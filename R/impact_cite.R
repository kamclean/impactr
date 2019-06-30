# impact_cite----------------------
# Documentation
#' @title Extract additional traditional metrics from Google Scholar
#' @description Extract additional traditional metrics from Google Scholar
#' @param df Dataframe containing at least three columns: publictaion title ("title"), publication year ("year"), and journal name (var_journal) with each publication listed as a row.
#' @param scholar_id Google scholar ID number linking to records in the dataframe.
#' @param var_journal Column in dataframe which contains the full name of the journal (note google scholar requires specific name formats).
#' @param var_citation Column in dataframe which already contains number of citations for each publication (optional).
#' @param match_by_year Argument to match publications by title and year, rather than just title (default = TRUE). See "unmatch" output.
#' @param h_index Return H-index score (default = TRUE)
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @return Nested dataframe of: (1)."output" - Amended dataframe with additional citaion metrics appended (2). "no_scholar" - Dataframe of publications with no scholar record (3). "unmatch" - Dataframe of publications that could not be matched to a journal. (4) "hindex" - H-Index score (if hindex = TRUE)
#' @export

impact_cite <- function(df, scholar_id  = FALSE, var_journal = "journal", var_citation = "", match_by_year = TRUE, h_index=TRUE){

  df_ori <- NULL
  if("journal" %in% names(df)){df_ori <- df; df <- df %>% dplyr::select(-journal)}

  df_out <- df %>%
    dplyr::mutate(journal = dplyr::pull(., var_journal)) %$%
    dplyr::left_join(., extract_scholar_journal(journal)$metrics, by=c("journal")) %>%
    dplyr::select(-journal_out) %$%

    # add in citations
    extract_scholar_cite(df = ., scholar_id = scholar_id, var_citation, match_by_year = match_by_year)

  if(is.null(df_ori)==F){df_out$output <- df_out$output %>% dplyr::mutate(journal = df_ori$journal)}

  if(h_index==TRUE){

    if(var_citation==""){hindex <- score_hindex(pull(df_out$output, cite_gs))}else{hindex <- score_hindex(pull(df_out$output, cite_total))}


    df_out <- list("output" = df_out$output,
                   "no_scholar" = df_out$no_scholar,
                   "unmatch" = df_out$unmatch,
                   "hindex" = hindex)}

  return(df_out)}
