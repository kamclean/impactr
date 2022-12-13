# impact_altmetric----------------------
# Documentation
#' Extract altmetric data on social media engagment
#' @description Extract impact data from social media engagment
#' @param id_list Vector of unique PubMed identifier numbers (PMID)
#' @return Nested dataframe (1) df; Original dataset with appended altmetric data (2) temporal; Long format data on temporal changes (3) rank; Long format data altmetric ranking (4) source; Long format data sources used to derive altmetric.
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @import stringr
#' @import httr
#' @importFrom purrr map_df
#' @importFrom tidyr unite pivot_longer pivot_wider unnest
#' @importFrom lubridate as_date as_datetime
#' @export

# Function-------------------------------
# aim to be able to use either pmid or doi
impact_altmetric <- function(id_list){


  # Set-up--------------------------
  # Load packages

  # Extract data
  id_class <- suppressWarnings(as.character(id_list) %>%
                                 tibble::enframe(name = "n", value = "id") %>%
                                 # https://www.crossref.org/blog/dois-and-matching-regular-expressions/
                                 dplyr::mutate(id_type = dplyr::case_when(stringr::str_detect(id, "^10\\.\\d{4,9}/")==T ~  "doi",
                                                                          nchar(id)==8&is.numeric(as.numeric(id))==T ~ "pmid",
                                                                          TRUE ~ "invalid")))

  df <- id_class %>%
    dplyr::filter(id_type %in% c("pmid", "doi")) %>%
    dplyr::mutate(request = paste0("https://api.altmetric.com/v1/", id_type, "/",id)) %>%
    dplyr::mutate(response = purrr::map(request, function(x){httr::GET(x)}),
                  response404 = purrr::map_chr(response, function(x){httr::status_code(x) == 404})) %>%
    dplyr::filter(response404==FALSE) %>%
    dplyr::select(-request, -response404,-n,-id_type) %>%
    dplyr::mutate(purrr::map_df(response, function(x){
      jsonlite::fromJSON(httr::content(x, as = "text"), flatten = TRUE) %>%
        rlist::list.flatten() %>%
        tibble::enframe() %>%
        tidyr::pivot_wider(everything())})) %>%
    dplyr::select(-response) %>%
    dplyr::full_join(id_class %>% select(id), by = "id") %>%
    dplyr::mutate(journal_issn= paste0(issns, collapse = ", "),
                  author_list= paste0(authors, collapse = ", ")) %>%
    dplyr::select(-schema,-is_oa, -starts_with("publisher_subjects"),
                  -issns, -authors, -starts_with("cohorts.")) %>%
    dplyr::mutate(across(everything(), function(x){as.character(x)})) %>%
    tidyr::unnest(everything()) %>%
    dplyr::mutate(across(everything(), function(x){ifelse(x=="NULL", NA, x)})) %>%
    dplyr::mutate(across(c(starts_with("context."),starts_with("cited_by"),starts_with("history."), "score"),
                         function(x){as.numeric(x)})) %>%
    dplyr::mutate(across(any_of(c("last_updated", "published_on", "added_on", "pubdate", "epubdate")),
                         function(x){lubridate::as_date(lubridate::as_datetime(as.numeric(x)))})) %>%
    dplyr::rename("date_update" = last_updated, "date_publish" = published_on, "date_added" = added_on,
                  "date_publish_print" = pubdate, "date_publish_online" ="epubdate") %>%

    dplyr::rename_at(vars(starts_with("history.")),
                     function(x){stringr::str_replace(x, "history.", "alm_score_")}) %>%
    dplyr::rename("alm_score_now" = alm_score_at) %>%
    dplyr::rename_at(vars(starts_with("context.similar_age_journal_3m.")),
                     function(x){stringr::str_replace(x, "context.similar_age_journal_3m.", "alm_journal_3m_")}) %>%
    dplyr::rename_at(vars(starts_with("context.journal.")),
                     function(x){stringr::str_replace(x, "context.journal.", "alm_journal_all_")}) %>%
    dplyr::rename_at(vars(starts_with("context.similar_age_3m")),
                     function(x){stringr::str_replace(x, "context.similar_age_3m.", "alm_3m_")}) %>%
    dplyr::rename_at(vars(starts_with("context.all.")),
                     function(x){stringr::str_replace(x, "context.all.", "alm_all_")}) %>%
    dplyr::rename_at(vars(ends_with("_count")&starts_with("alm_")),
                     function(x){stringr::str_replace(x, "_count", "_n")})

  # Altmetric sources--------------
  sources <- df %>%
    dplyr::select(id, starts_with("cited_by_"), starts_with("readers")) %>%
    dplyr::mutate(across(-id, function(x){as.numeric(x)})) %>%
    tidyr::pivot_longer(cols = -id) %>%
    dplyr::mutate(type = ifelse(stringr::str_detect(name, "readers")==T, "reader", "post"),
                  name = stringr::str_remove_all(name, "_count|cited_by_|readers."),
                  name = case_when(name =="accounts" ~ "online_users",
                                   name == "fbwalls" ~ "fb",
                                   name =="accounts" ~ "all",
                                   name =="tweeters" ~ "twitter_users",
                                   name =="posts" ~ "twitter_tweets",
                                   name =="msm" ~ "news_media",
                                   name =="wikipedia" ~ "wikipedia",
                                   name =="feeds" ~ "blogs",
                                   name =="forum" ~ "forum",
                                   name =="gplus" ~ "googleplus",
                                   name =="msm" ~ "news",
                                   name =="linkedin" ~ "linkedin",
                                   name =="rh" ~ "research_highlight",
                                   name =="policies" ~ "policy_source",
                                   TRUE ~ name)) %>%
    dplyr::mutate(value = ifelse(is.na(value)==T, 0, value)) %>%
    dplyr::filter(! name %in% c("twitter_users", "online_users")) %>%
    dplyr::filter(! (type=="reader"&name=="count")) %>%
    dplyr::mutate(name = stringr::str_replace(name, "twitter_tweets", "twitter")) %>%

    dplyr::filter(is.na(name)==F) %>%
    dplyr::group_by(id) %>%
    dplyr::mutate(total = sum(value))  %>% dplyr::mutate(prop = value / total) %>%
    dplyr::ungroup()



  # Output --------------
  df_out <-



    temporal <- df %>%
    dplyr::select(id, doi, starts_with("alm_score"), starts_with("date_")) %>%
    dplyr::mutate(alm_score_0d = 0) %>%
    dplyr::mutate(add2now = (date_update-date_added) %>% as.numeric()) %>%
    dplyr::filter(is.na(doi)==F) %>%
    tidyr::pivot_longer(cols = starts_with("alm_score"),
                        names_to = "alm_time", values_to = "alm_score") %>%

    dplyr::mutate(alm_time = dplyr::case_when(alm_time=="alm_score_now" ~ add2now,
                                              alm_time=="alm_score_1y" ~ 365,
                                              alm_time=="alm_score_6m" ~ 180,
                                              alm_time=="alm_score_3m" ~ 90,
                                              alm_time=="alm_score_1m" ~ 30,
                                              alm_time=="alm_score_1w" ~ 7,
                                              alm_time=="alm_score_6d" ~ 6,
                                              alm_time=="alm_score_5d" ~ 5,
                                              alm_time=="alm_score_4d" ~ 4,
                                              alm_time=="alm_score_3d" ~ 3,
                                              alm_time=="alm_score_2d" ~ 2,
                                              alm_time=="alm_score_1d" ~ 1,
                                              alm_time=="alm_score_0d" ~ 0)) %>%
    dplyr::filter(add2now>=alm_time) %>%
    dplyr::distinct() %>% # get rid of now when same as a recorded value
    dplyr::select(-add2now, -date_publish) %>%
    dplyr::arrange(doi, alm_time)

  rank <- df %>%
    dplyr::select(id, doi, journal,alm_score_now,
                  starts_with("alm_all_"),
                  starts_with("alm_journal_all_"),
                  starts_with("alm_3m_"),
                  starts_with("alm_journal_3m_")) %>%
    dplyr::mutate(alm_all_prop = 1-((alm_all_rank-1)/alm_all_n),
                  alm_3m_prop = 1-((alm_3m_rank-1)/alm_3m_n),
                  alm_journal_all_prop = 1-((alm_journal_all_rank-1)/alm_journal_all_n),
                  alm_journal_3m_prop = 1-((alm_journal_3m_rank-1)/alm_journal_3m_n)) %>%
    tidyr::pivot_longer(cols = -c(id, doi, journal, alm_score_now), names_to = "alm_category") %>%

    dplyr::mutate(alm_category = gsub("alm_", "", alm_category),
                  journal = factor(journal)) %>%
    dplyr::mutate(comparator_journal = ifelse(stringr::str_detect(alm_category, "journal_"), "journal", "all"),
                  comparator_time = ifelse(stringr::str_detect(alm_category, "3m"), "3 months", "ever")) %>%
    dplyr::mutate(comparator_journal = ifelse(comparator_journal=="journal", as.character(journal), comparator_journal)) %>%
    dplyr::mutate(alm_measure = dplyr::case_when(stringr::str_detect(alm_category, "_n") ~ "n",
                                                 stringr::str_detect(alm_category, "_mean") ~ "mean",
                                                 stringr::str_detect(alm_category, "_rank") ~ "rank",
                                                 stringr::str_detect(alm_category, "_higher_than") ~ "higher_than",
                                                 stringr::str_detect(alm_category, "_pct") ~ "pct",
                                                 stringr::str_detect(alm_category, "_prop") ~ "prop")) %>%
    dplyr::select(-alm_category) %>%
    dplyr::filter(! alm_measure %in% c("pct", "higher_than")) %>%
    tidyr::pivot_wider(id_cols  = c(id, doi, journal, alm_score_now, comparator_journal, comparator_time),
                       names_from = alm_measure, values_from = value) %>%
    dplyr::filter(is.na(mean)==F) %>%
    dplyr::rename("alm_score" = alm_score_now)

  out <- list("df" = df %>%dplyr::select(id, "altmetric" = alm_score_now), "temporal" = temporal, "rank" = rank, "source" = sources)


  return(out)}
