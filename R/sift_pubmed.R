# sift_pubmed------------------------------
#' Sift though pubmed records to stratify by potential relevance
#' @description Highlight pubmed records potentially relevant to the authors of interest
#' @param pmid Vector of pubmed identifiers (PMID) desired to be screened.
#' @param authors Vector of last name and initial(s) which correspond to relevant authors (default = NULL).
#' @param affiliations Vector of strings which correspond to relevant author affiliations (default = NULL).
#' @param keyword Vector of keyword or patterns that are expected to be present in the title/abstract/journal (default = NULL).
#' @param ignoreword Vector of keyword or patterns that are expected to NOT be present in the title/abstract/journal (default = NULL).
#' @param separate Logical value to separate the output into wheat (highlighted publications) and chaff (unhighlighted publications).
#' @return Tibble containing pmid, results from sifting based on the authors, affiliations, and keyword, and the title/journal/abstract to allow further evaluation.
#' @import dplyr
#' @import tidyr
#' @import purrr
#' @import stringr
#' @import tibble
#' @export
#'

sift_pubmed <- function(pmid, authors = NULL, affiliations = NULL, keyword = NULL, ignoreword = NULL, separate = T){

  require(dplyr);require(tidyr);require(purrr);require(tibble);require(stringr)


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

    sift_author <- authors %>%
      tibble::enframe(name = NULL) %>%
      dplyr::mutate(include = stringr::str_extract(value, "^[a-z]+ [a-z]"),
                    exclude = stringr::str_split_fixed(value, " ", 2)[,2],
                    exclude = stringr::str_sub(exclude, 2,2),
                    exclude = case_when(exclude=="" ~ NA_character_,
                                        TRUE ~ paste0(include, "[^", exclude, "]")),
                    exclude = ifelse(is.na(exclude)==F, paste0(exclude), exclude)) %>%
      dplyr::summarise(include_any = paste0(unique(c(value, include)), collapse = "|"),
                       include_single = paste0(c(paste0(include, ";"), paste0(include, "$")), collapse = "|"),
                       exclude = paste0(exclude, collapse = "|") %>% stringr::str_remove_all("\\|NA"))

    df_author <- data %>%
      tidyr::unite(col = "full_list", author_list, collab_list, sep = "; ", na.rm = T) %>%
      tidyr::unite(col = "full_list_aff", author_list_aff, collab_list_aff, sep = "; ", na.rm = T) %>%
      dplyr::mutate_at(dplyr::vars(dplyr::starts_with("full_list")),
                       function(x){tolower(x) %>% iconv(to ="ASCII//TRANSLIT")}) %>%
      dplyr::select(pmid, full_list, full_list_aff)  %>%
      dplyr::mutate(author_multi_list = stringr::str_extract_all(full_list, sift_author$include_any) %>%
                      purrr::map_chr(function(x){paste0(unique(x) %>% stringr::str_remove_all(";"), collapse = "; ")})) %>%
      dplyr::mutate(author_multi_list = case_when(stringr::str_detect(full_list, sift_author$include_single)==F&stringr::str_detect(full_list, sift_author$exclude)==T ~ NA_character_,
                                         TRUE ~ author_multi_list)) %>%
      dplyr::mutate(author_multi_n = stringr::str_count(author_multi_list,"; ")+1) %>%
      dplyr::mutate(author_multi_n = ifelse(is.na(author_multi_list), 0, author_multi_n))

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
                               keyword = rep(NA_character_, nrow(data)),
                               ignoreword = rep(NA_character_, nrow(data)))

  if(is.null(keyword)==F|is.null(ignoreword)==F){

    df_keyword <- data %>%
      dplyr::select(pmid, title, journal, abstract) %>%
      dplyr::mutate_all(function(x){iconv(tolower(x), to ="ASCII//TRANSLIT")}) %>%
      tidyr::unite(col = text, title, journal, abstract, sep = "; ", na.rm = T)

    if(is.null(ignoreword)==T&is.null(keyword)==F){
    keyword_logic = keyword %>%
      tibble::enframe(value = "term") %>%
      dplyr::mutate(term = iconv(term, to ="ASCII//TRANSLIT")) %>%
      dplyr::mutate(term = stringr::str_replace_all(term,"OR", "|"),
                    term = stringr::str_replace_all(term,"AND", "&"),
                    term = stringr::str_replace_all(term, "\\*", ""),
                    term = stringr::str_remove_all(term, " "),
                    term_final = stringr::str_split(term, "&")) %>%
      dplyr::group_by(name) %>%
      dplyr::mutate(term_final = purrr::map_chr(term_final, function(x){stringr::str_remove_all(x, "\\(|\\)") %>%
          paste0('stringr::str_detect(df_keyword$text, "', ., '")==T') %>% paste0(collapse = "&")})) %>%
      dplyr::group_by(name) %>%
      dplyr::group_split(name) %>%
      purrr::map_df(function(x){x %>%
          dplyr::mutate(search = list(eval(parse(text=term_final))),
                        search = list(eval(parse(text=term_final))))}) %>%
      dplyr::select(term, search) %>%
      tidyr::unnest(cols = names(.)) %>%
      dplyr::group_by(term) %>%
      dplyr::mutate(rowid = 1:n()) %>%
      dplyr::group_by(rowid) %>%
      dplyr::summarise(search = ifelse(sum(search==T)>0, "Yes", "No"))

    df_keyword <- df_keyword %>%
      dplyr::bind_cols(keyword_logic %>% select("keyword" = search))}

    if(is.null(ignoreword)==F&is.null(keyword)==T){
    df_keyword <- df_keyword %>%
      dplyr::mutate(ignoreword = stringr::str_detect(text, pattern = paste0(ignoreword, collapse = "|"))==F,
                    ignoreword = ifelse(ignoreword==T, "Yes", "No"))}


    if(is.null(ignoreword)==F&is.null(keyword)==F){
      keyword_logic = keyword %>%
        tibble::enframe(value = "term") %>%
        dplyr::mutate(term = iconv(term, to ="ASCII//TRANSLIT")) %>%
        dplyr::mutate(term = stringr::str_replace_all(term,"OR", "|"),
                      term = stringr::str_replace_all(term,"AND", "&"),
                      term = stringr::str_replace_all(term, "\\*", ""),
                      term = stringr::str_remove_all(term, " "),
                      term_final = stringr::str_split(term, "&")) %>%
        dplyr::group_by(name) %>%
        dplyr::mutate(term_final = purrr::map_chr(term_final, function(x){stringr::str_remove_all(x, "\\(|\\)") %>%
            paste0('stringr::str_detect(df_keyword$text, "', ., '")==T') %>% paste0(collapse = "&")})) %>%
        dplyr::group_by(name) %>%
        dplyr::group_split(name) %>%
        purrr::map_df(function(x){x %>%
            dplyr::mutate(search = list(eval(parse(text=term_final))))}) %>%
        dplyr::select(term, search) %>%
        tidyr::unnest(cols = names(.)) %>%
        dplyr::group_by(term) %>%
        dplyr::mutate(rowid = 1:n()) %>%
        dplyr::group_by(rowid) %>%
        dplyr::summarise(search = ifelse(sum(search==T)>0, "Yes", "No"))

      df_keyword <- df_keyword %>%
        dplyr::bind_cols(keyword_logic %>% select("keyword" = search)) %>%
        dplyr::mutate(ignoreword = stringr::str_detect(text, pattern = paste0(ignoreword, collapse = "|"))==F,
                      ignoreword = ifelse(ignoreword==T, "Yes", "No"))}}



  df_output <- data %>%
    dplyr::left_join(df_author_final, by="pmid") %>%
    dplyr::left_join(df_affiliations_any, by="pmid") %>%
    dplyr::left_join(df_keyword, by="pmid") %>%
    dplyr::mutate(criteria_met = ifelse(is.na(author_multi_n)==F&author_multi_n>=2, 1, 0),
                  criteria_met = ifelse(is.na(affiliations_author)==F&affiliations_author=="Yes", criteria_met+1, criteria_met),
                  criteria_met = ifelse(is.na(affiliations_any)==F&affiliations_any=="Yes", criteria_met+1, criteria_met),
                  criteria_met = ifelse(is.na(keyword)==F&keyword=="Yes", criteria_met+1, criteria_met),
                  criteria_met = ifelse(is.na(ignoreword)==F&ignoreword=="Yes", criteria_met+1, criteria_met)) %>%
    dplyr::mutate(highlight = ifelse(criteria_met>0, "Yes", "No")) %>%
    dplyr::select(pmid, highlight, criteria_met, author_multi_n, author_multi_list, affiliations_author:keyword,ignoreword,
                  "author_list" = full_list, "author_affiliation_list" = full_list_aff,
                  title,journal,abstract) %>%
    dplyr::arrange(dplyr::desc(highlight), dplyr::desc(criteria_met), dplyr::desc(author_multi_n), dplyr::desc(affiliations_author),
                   dplyr::desc(affiliations_any), dplyr::desc(keyword)) %>%
    distinct()

  if(separate==T){df_output <- list("wheat" = df_output %>%
                                      dplyr::filter(highlight=="Yes") %>%
                                      dplyr::select(-highlight) %>%
                                      distinct(),
                                    "chaff" = df_output %>%
                                      dplyr::filter(highlight=="No"|is.na(highlight)==T) %>%
                                      dplyr::arrange(author_multi_n) %>%
                                      dplyr::select(-highlight) %>%
                                      distinct())}

  return(df_output)}
