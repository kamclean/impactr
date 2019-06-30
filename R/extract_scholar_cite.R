# extract_scholar_journal----------------------
# Documentation
#' @title Extract additional citation metrics from Google Scholar
#' @description Extract additional citation metrics from Google Scholar
#' @param df Dataframe containing at least three columns: publictaion title ("title"), publication year ("year"), and journal name ("journal") with each publication listed as a row.
#' @param scholar_id Google scholar ID number linking to records in the dataframe.
#' @param var_citation Column in dataframe which already contains number of citations for each publication (optional).
#' @param match_by_year Argument to match publications by title and year, rather than just title (default = TRUE). See "unmatch" output.
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @importFrom scholar get_impactfactor get_publications
#' @return Nested dataframe of: (1)."output" - Amended dataframe with additional citaion metrics appended (2). "no_scholar" - Dataframe of publications with no scholar record (3). "unmatch" - Dataframe of publications that could not be matched to a journal.
#' @export

# Function----------------
extract_scholar_cite <- function(df, scholar_id, var_citation="", match_by_year =  TRUE){
  "%ni%" <- Negate("%in%")

  df_gs <- scholar_id %>%
    scholar::get_publications() %>%
    tibble::as_tibble() %>%
    dplyr::select("title_gs" = title, year, "cite_gs" = cites) %>%
    dplyr::mutate(title_gs = tolower(title_gs),
                  title_match = substr(gsub("[[:punct:]]", "",tolower(title_gs)), 1, 50))

  df_out <- df %>%
    dplyr::mutate(title_match = substr(gsub("[[:punct:]]", "",tolower(title)), 1, 50))

  if(match_by_year==TRUE){df_out <- dplyr::left_join(df_out,
                                                     df_gs,
                                                     by = c("title_match", "year"))}else{df_out <- dplyr::left_join(df_out,
                                                                                                                    dplyr::select(df_gs,-year),
                                                                                                                    by = c("title_match"))}

  if(var_citation!=""){df_out <- df_out %>%
    dplyr::mutate(citation = dplyr::pull(., var_citation)) %>%
    dplyr::mutate(cite_total = ifelse(is.na(cite_gs)==F, cite_gs, ifelse(is.na(citation)==F, citation, 0))) %>%
    dplyr::select(-citation)}

  no_scholar <- NULL
  if(sum(df_out$title_match %ni% df_gs$title_match)>0){
    no_scholar <- df_out %>%
      dplyr::filter(title_match %ni% df_gs$title_match) %>%
      dplyr::select(doi, title,year) %>%
      dplyr::arrange(-year)}

  unmatch <- NULL
  if(sum(is.na(df_out$title_gs)==T&df_out$title_match %in% df_gs$title_match)>0){
    unmatch <- df_out %>%
      dplyr::filter(df_out$title_match %in% df_gs$title_match) %>%
      dplyr::filter(is.na(title_gs)==T) %>%
      dplyr::select(doi, year, title) %>%
      dplyr::arrange(-year)}

  df_out <- df_out %>%
    dplyr::select(-title_match, -title_gs)

  out <- list("output" = df_out, "no_scholar" = no_scholar, "unmatch" = unmatch)

  return(out)}
