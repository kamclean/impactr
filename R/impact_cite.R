# impact_cite----------------------
# Documentation
#' @title Extract additional traditional metrics from Google Scholar
#' @description Extract additional traditional metrics from Google Scholar
#' @param df Dataframe containing at least two columns: publication year ("year") and id with each publication listed as a row.
#' @param id String of the column name containing the publication id (accepts DOI and PMID).
#' @param crossref Crossref database to be used for citation data (default=TRUE)
#' @param dimentions Dimentions database to be used for citation data (default=TRUE)
#' @param scopus Scopus database to be used for citation data (default=FALSE). Requires Scopus API.
#' @param oc Open citations database to be used for citation data (default=FALSE due to sparse population at present).
#' @param gscholar Google scholar database to be used for citation data (default=FALSE). Requires Google Scholar ID (and all relevent publications to be associated with this).
#' @param gscholar_title_nchar Argument to specify how many characters the titles should be matched (default = 50). See "gscholar_invalid" output.
#' @param metric Return common citation metrics (default = TRUE)
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @return Nested dataframe of: (1)."df": Amended dataframe with additional citation data appended (2). "time": Dataframe of citations over time (only avaiable for Scopus and google scholar). (3). "metric": output from cite_metric() (4). Unmatched recorded (only for google scholar)
#' @export

impact_cite <- function(df, crossref=TRUE, dimentions=TRUE, scopus=FALSE, oc = FALSE,
                        gscholar=FALSE, gscholar_title_nchar = 50, metric=TRUE){

  df <- df %>% dplyr::mutate(id = dplyr::pull(., id))

  # Get citation data
  require(dplyr)
  if(crossref==T){
    df <- df %>%
      dplyr::select(id) %>%
      dplyr::filter(is.na(id)==F) %>%
      dplyr::mutate(cite_cr = impactr::cite_cr(id)$cite) %>%
      dplyr::right_join(dplyr::select(df, -dplyr::matches("cite_cr")), by = "doi") %>%
      dplyr::select(-cite_cr, everything())}

  if(dimentions==T){
    df <- df %>%
      dplyr::select(id) %>%
      dplyr::filter(is.na(id)==F) %>%
      dplyr::mutate(cite_dim = impactr::cite_dim(id)$cite) %>%
      dplyr::right_join(dplyr::select(df, -dplyr::matches("cite_dim")), by = "doi") %>%
      dplyr::select(-cite_dim, everything())} # to move cite_dim last

  if(scopus==T){
    if(scopus==T&"doi" %in% names(df)&rscopus::have_api_key()==T){
      df <- df %>%
        dplyr::select(doi) %>%
        dplyr::filter(is.na(doi)==F) %>%
        dplyr::mutate(cite_scopus = impactr::cite_scopus(doi)$cite) %>%
        dplyr::right_join(dplyr::select(df, -dplyr::matches("cite_scopus")), by = "doi") %>%
        dplyr::select(-cite_scopus, everything())}else{print("Please use rscopus::set_api_key() with a valid api")}}

  data_oc <- NULL
  if(oc==T&"doi" %in% names(df)){
    doi_oc <- df %>%
      dplyr::select(doi) %>%
      dplyr::filter(is.na(doi)==F) %>%
      dplyr::pull(doi)

    data_oc <- impactr::cite_oc(doi_oc)

    df <- df %>%
      dplyr::select(doi) %>%
      dplyr::filter(is.na(doi)==F) %>%
      dplyr::mutate(cite_oc = data_oc$total$cite) %>%
      dplyr::right_join(dplyr::select(df, -dplyr::matches("cite_oc")), by = "doi") %>%
      dplyr::select(-cite_oc, everything())}

  data_gs <- NULL
  gscholar_invalid <- NULL
  if(gscholar!=FALSE){

    data_gs <- suppressMessages(suppressWarnings(impactr::cite_gs(df, gscholar_id = gscholar, match_title_nchar = gscholar_title_nchar)))

    df <- data_gs$df

    gscholar_invalid <- data_gs$validation}


  df_out <- df %>%
    dplyr::mutate_at(.vars = dplyr::vars(dplyr::starts_with("cite_")), as.numeric) %>%
    dplyr::mutate(cite_max = apply(dplyr::select(., dplyr::starts_with("cite_")), 1, function(x){suppressWarnings(max(x, na.rm=T))})) %>%
    dplyr::mutate(cite_max = ifelse(cite_max==-Inf, NA, cite_max))

  df_time <- NULL
  if(is.null(data_gs)==F|is.null(data_oc)==F){

    time_gs <- NULL

    if(is.null(data_gs)==F){
      time_gs  <- data_gs$year %>%
        dplyr::mutate(source = "gs") %>%
        dplyr::select(source, doi, cite_year,cite_n,cite_cumsum) %>%
        dplyr::mutate_all(as.character)}

    time_oc <- NULL
    if(is.null(data_oc)==F){
      time_oc  <- data_oc$year %>%
        dplyr::mutate(source = "oc") %>%
        dplyr::select(source, everything()) %>%
        dplyr::mutate_all(as.character)}

    df_time <- dplyr::bind_rows(time_gs,time_oc) %>%
      dplyr::mutate(source = factor(source),
                    doi = factor(doi),
                    cite_year = factor(cite_year, levels=sort(unique(cite_year))),
                    cite_n = as.numeric(cite_n),
                    cite_cumsum = as.numeric(cite_cumsum))}

  df_metric <- NULL
  if(metric==TRUE){df_metric <- suppressWarnings(impactr::cite_metric(citations = df_out$cite_max, year = df_out$year))}

  df_out <- list("df" = df_out, "time" = df_time, "metric" = df_metric, "gscholar_invalid" = gscholar_invalid)

  if(gscholar==FALSE){df_out$gscholar_invalid <- NULL}
  if(is.null(data_gs)==T&is.null(data_oc)==T){df_out$time <- NULL}
  if(metric!=TRUE){df_out$metric <- NULL}

  return(df_out)}
