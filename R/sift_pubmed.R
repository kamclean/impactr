# sift_pubmed------------------------------
#' Sift though pubmed records to stratify by potential relevance
#' @description Highlight pubmed records potentially relevant to the authors of interest
#' @param pmid Vector of pubmed identifiers (PMID) desired to be screened.
#' @param authors Vector of last name and initial(s) which correspond to relevant authors (default = NULL).
#' @param affiliations Vector of strings which correspond to relevant author affiliations (default = NULL).
#' @param keywords Vector of keywords or patterns that are expected to be present in the title/abstract/journal (default = NULL).
#' @param separate Logical value to separate the output into wheat (highlighted publications) and chaff (unhighlighted publications).
#' @return Tibble containing pmid, results from sifting based on the authors, affiliations, and keywords, and the title/journal/abstract to allow further evaluation.
#' @import magrittr
#' @import dplyr
#' @import RCurl
#' @import xml2
#' @import purrr
#' @import stringr
#' @import tibble
#' @export
#'

sift_pubmed <- function(pmid, authors = NULL, affiliations = NULL, keywords = NULL, separate = T){

  require(magrittr);require(RCurl);require(xml2);require(dplyr);require(tidyr);require(purrr)
  require(tibble);require(stringr);require(lubridate);require(RCurl);require(xml2)

  data <- impactr::format_pubmed_xml(pmid = pmid,
                                     var_author= if(is.null(authors)==T){F}else{T},
                                     var_collaborator = if(is.null(authors)==T){F}else{T},
                                     var_metadata = F,
                                     var_history=F,
                                     var_registry = F,
                                     var_abstract = T) %>%
    dplyr::select(-pmc, -journal_nlm,-journal_issn, -journal_vol, -journal_issue,-journal_pages) %>%
    tidyr::unite(col="journal", sep = ", ", dplyr::starts_with("journal_"))

  print("XML Download: Done")

df_author_final <- tibble::tibble(pmid = data$pmid,
                                  full_list = rep(NA_character_, nrow(data)),
                                  full_list_aff = rep(NA_character_, nrow(data)),
                                  author_multi_list = rep(NA_character_, nrow(data)),
                                  author_multi_n = rep(NA_character_, nrow(data)),
                                  affiliations_author = rep(NA_character_, nrow(data)))


  if(is.null(authors)==F){
    authors = iconv(tolower(authors), to ="ASCII//TRANSLIT")

    df_author <- data %>%
      tidyr::unite(col = "full_list", author_list, collab_list, sep = "; ", na.rm = T) %>%
      tidyr::unite(col = "full_list_aff", author_list_aff, collab_list_aff, sep = "; ", na.rm = T) %>%
      dplyr::mutate_at(dplyr::vars(dplyr::starts_with("full_list")),
                       function(x){tolower(x) %>% iconv(to ="ASCII//TRANSLIT")}) %>%
      dplyr::select(pmid, full_list, full_list_aff) %>%
      dplyr::mutate(author_multi_list = stringr::str_extract_all(full_list,
                                                                 paste(authors, collapse = "|")) %>%
                      purrr::map_chr(function(x){unique(x) %>% paste(., collapse = "; ")})) %>%
      dplyr::mutate(author_multi_n = stringr::str_count(author_multi_list,"; ")+1) %>%
      dplyr::mutate(author_multi_n = ifelse(author_multi_list=="", 0, author_multi_n),
                    author_multi_list = ifelse(author_multi_list=="", NA, author_multi_list))

    if(is.null(affiliations)==F){
      affiliations = iconv(tolower(affiliations), to ="ASCII//TRANSLIT")

      df_author_affiliations <- df_author %>%
        dplyr::select(pmid, full_list_aff) %>%
        tidyr::separate_rows(full_list_aff, sep = "];") %>%
        dplyr::mutate(full_list_aff = trimws(full_list_aff)) %>%
        dplyr::mutate(author = stringr::str_split_fixed(full_list_aff, " \\[", 2)[,1],
                      affiliation = stringr::str_split_fixed(full_list_aff, " \\[", 2)[,2]) %>%
        dplyr::filter(grepl(paste(authors, collapse = "|"), author)) %>%
        dplyr::distinct() %>%
        dplyr::filter(grepl(paste(affiliations, collapse = "|"), affiliation)) %>%
        dplyr::group_by(pmid) %>%
        dplyr::summarise(affiliations_author = ifelse(n()>0, "Yes", "No"))}

    if(is.null(affiliations)==T|nrow(df_author_affiliations)==0){
      df_author_affiliations <- df_author %>%
        dplyr::select(pmid) %>% dplyr::mutate(affiliations_author = "No")}

    df_author_final <- dplyr::left_join(df_author, df_author_affiliations, by="pmid")}

  df_affiliations_any <- tibble::tibble(pmid = data$pmid,
                                        affiliations_any = rep(NA_character_, nrow(data)))
  if(is.null(affiliations)==F){
    affiliations = iconv(tolower(affiliations), to ="ASCII//TRANSLIT")

    df_affiliations_any <- data %>%
      tidyr::unite(col = "full_list_aff", author_list_aff, collab_list_aff, sep = "; ", na.rm = T) %>%
      dplyr::mutate_at(dplyr::vars(dplyr::starts_with("full_list")),
                       function(x){tolower(x) %>% iconv(to ="ASCII//TRANSLIT")}) %>%
      dplyr::select(pmid:doi, full_list_aff) %>%
      tidyr::separate_rows(full_list_aff, sep = "];") %>%
      dplyr::mutate(full_list_aff = trimws(full_list_aff)) %>%
      dplyr::mutate(author = stringr::str_split_fixed(full_list_aff, " \\[", 2)[,1],
                    affiliation = stringr::str_split_fixed(full_list_aff, " \\[", 2)[,2]) %>%
      dplyr::filter(grepl(paste(affiliations, collapse = "|"), affiliation)) %>%
      dplyr::distinct() %>%
      dplyr::group_by(pmid) %>%
      dplyr::summarise(affiliations_any = ifelse(n()>0, "Yes", "No"))

    if(nrow(df_affiliations_any)==0){
      df_affiliations_any <- data %>%
        dplyr::select(pmid) %>% dplyr::mutate(affiliations_any = "No")}}

  df_keyword <- tibble::tibble(pmid = data$pmid,
                               keyword = rep(NA_character_, nrow(data)))

  if(is.null(keywords)==F){

    df_keyword <- data %>%
      dplyr::select(pmid, title, journal, abstract) %>%
      dplyr::mutate_all(function(x){iconv(tolower(x), to ="ASCII//TRANSLIT")}) %>%
      tidyr::unite(col = keyword_text, title, journal, abstract, sep = "; ", na.rm = T)

    keywords_logic = iconv(keywords, to ="ASCII//TRANSLIT") %>%
      tibble::enframe(value = "term") %>%
      tidyr::separate_rows(term, sep =  "(?<=AND|OR|NOT)") %>%
      dplyr::mutate(operator = stringr::str_extract(term, "AND|OR|NOT"),
                    term = trimws(stringr::str_remove(term, "AND|OR|NOT"))) %>%

      dplyr::mutate(term = gsub("\\*", "",term) %>% tolower(),
                    operator = gsub("OR", "|",operator) %>% gsub("AND", "&",. )) %>%
      dplyr::mutate(term = ifelse(grepl("&", term), paste0("(", term, ")"), term))

    keywords_logic_group <- keywords_logic %>%
      dplyr::mutate(operator_lag = lag(operator, 1)) %>%
      dplyr::mutate(term_final = ifelse(operator %in% c("&", "|"), paste0(term, "==T"), term)) %>%
      dplyr::mutate(term_final = ifelse(operator_lag %in% c("NOT"), paste0(term_final, "==F"), term_final)) %>%
      dplyr::mutate(term_final = ifelse(operator_lag %in% c("&", "|"), paste0(term_final, "==T"), term_final)) %>%
      dplyr::mutate(operator_final = ifelse(operator == "NOT", "&", operator)) %>%
      dplyr::mutate(operator_final = ifelse(is.na(operator_final)==T, "", operator_final)) %>%
      dplyr::group_by(name) %>%
      dplyr::summarise(group = paste(paste0(term_final,operator_final), collapse = "")) %>%
      dplyr::mutate(group = paste0("(", group, ")")) %>%
      dplyr::summarise(group = paste0(group, collapse = "|"))


      for(i in 1:nrow(keywords_logic)){
        df_keyword <- df_keyword %>%
          dplyr::mutate(search = grepl(keywords_logic$term[i], keyword_text)) %>%
          dplyr::rename_at(vars(search), function(x){x = keywords_logic$term[i]})}

    df_keyword <- df_keyword %>%
      dplyr::mutate(keyword = ifelse(eval(parse(text=keywords_logic_group$group))==T, "Yes", "No")) %>%
      select(pmid, keyword)}

  df_output <- NULL
  df_output <- data %>%
    dplyr::left_join(df_author_final, by="pmid") %>%
    dplyr::left_join(df_affiliations_any, by="pmid") %>%
    dplyr::left_join(df_keyword, by="pmid") %>%
    dplyr::mutate(criteria_met = ifelse(is.na(author_multi_n)==F&author_multi_n>2, 1, 0),
                  criteria_met = ifelse(is.na(affiliations_author)==F&affiliations_author=="Yes", criteria_met+1, criteria_met),
                  criteria_met = ifelse(is.na(affiliations_any)==F&affiliations_any=="Yes", criteria_met+1, criteria_met),
                  criteria_met = ifelse(is.na(keyword)==F&keyword=="Yes", criteria_met+1, criteria_met)) %>%
    dplyr::mutate(highlight = ifelse(criteria_met>0, "Yes", "No")) %>%
    dplyr::select(pmid, highlight, criteria_met, author_multi_n, author_multi_list, affiliations_author:keyword,
                  "author_list" = full_list, "author_affiliation_list" = full_list_aff,
                  title,journal,abstract) %>%
    dplyr::arrange(dplyr::desc(highlight), dplyr::desc(criteria_met), dplyr::desc(author_multi_n), dplyr::desc(affiliations_author),
                   dplyr::desc(affiliations_any), dplyr::desc(keyword))

  if(separate==T){df_output <- list("wheat" = df_output %>%
                                      dplyr::filter(highlight=="Yes") %>%
                                      dplyr::select(-highlight),
                                    "chaff" = df_output %>%
                                      dplyr::filter(highlight=="No"|is.na(highlight)==T) %>%
                                      dplyr::arrange(author_multi_n) %>%
                                      dplyr::select(-highlight))}

  return(df_output)}
