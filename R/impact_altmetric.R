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
#' @importFrom rAltmetric altmetric_data altmetrics
#' @importFrom purrr map_df
#' @importFrom tidyr unite pivot_longer pivot_wider unnest
#' @importFrom lubridate as_date as_datetime
#' @export

# Function-------------------------------
# aim to be able to use either pmid or doi
impact_altmetric <- function(id_list){
  # https://api.altmetric.com/docs/call_citations.html
  # https://github.com/ropensci/rAltmetric/issues/27

  # Set-up--------------------------
  # Load packages
  require(dplyr);require(tibble);require(purrr);require(tidyr)
  require(lubridate);require(magrittr);require(rAltmetric);require(stringr)

  # Define essential columnns
  var <- c("doi", "title", "type", "author_list", "journal", "issns", "altmetric_id",
           "history.1w","history.1m","history.3m","history.6m", "history.1y",
           "score","context.all.mean", "context.all.count", "context.all.rank",
           "context.journal.mean","context.journal.rank","context.journal.count",
           "context.similar_age_journal_3m.mean","context.similar_age_journal_3m.rank", "context.similar_age_journal_3m.count")

  var_dates <- c("published_on", "last_updated","added_on")

  essential_col = c("authors", var, var_dates)

  essential_df <- tibble::enframe(essential_col, name = "value", value = "name") %>%
    dplyr::mutate(value = NA_character_) %>%
    tidyr::pivot_wider()

  # Extract data

  id_class <- as.character(id_list) %>%
    tibble::enframe(name = "n", value = "id") %>%
    # https://www.crossref.org/blog/dois-and-matching-regular-expressions/
    dplyr::mutate(id_type = dplyr::case_when(stringr::str_detect(id, "^10\\.\\d{4,9}/")==T ~  "doi",
                                             nchar(id)==8&is.numeric(as.numeric(id))==T ~ "pmid",
                                             TRUE ~ "invalid"))

  df <- id_class %>%
    dplyr::filter(id_type %in% c("pmid", "doi")) %>%
    dplyr::group_split(id) %>%
    purrr::map_df(function(x){

      data <- tryCatch(rAltmetric::altmetrics(pmid = if(x$id_type=="pmid"){x$id}else{NULL},
                                              doi = if(x$id_type=="doi"){x$id}else{NULL}) %>%
                           rAltmetric::altmetric_data() %>% tibble::as_tibble(),
                         error=function(e) essential_df)

      for(i in 1:length(essential_col)){
        if(essential_col[i] %in% names(data)){data <- data}else{
          data <- data %>%
            dplyr::mutate(new_col = NA) %>%
            dplyr::rename_at(vars(matches("new_col")), function(x){x = essential_col[i]})}}

      data <- data %>%
        tidyr::unite(col = "author_list",tidyselect::starts_with("authors"), sep = ", ", remove = TRUE) %>%
        tidyr::unite(col = "journal_issn", tidyselect::starts_with("issns"), sep = ", ", remove = TRUE)})

  # Altmetric sources--------------
  sources_old <- c("posts", "accounts","tweeters","fbwalls",
                   "msm","policies","peer_review_sites", "wikipedia",
                   "feeds", "forum", "gplus","rh", "linkedin", "readers",
                   "delicious","pinners","qs","weibo", "rdts","videos")

  names_cited_old <- paste0("cited_by_",sources_old,"_count")

  names_cited <- tibble::tibble(old = names_cited_old,
                                new = sources_old) %>%
    dplyr::mutate(new = dplyr::case_when(new == "fbwalls" ~ "fb",
                                         new =="posts" ~ "all",
                                         new =="tweeters" ~ "twitter_posts",
                                         new =="accounts" ~ "twitter_accounts",
                                         new =="msm" ~ "news_media",
                                         new =="wikipedia" ~ "wikipedia",
                                         new =="feeds" ~ "blogs",
                                         new =="forum" ~ "forum",
                                         new =="gplus" ~ "googleplus",
                                         new =="msm" ~ "news",
                                         new =="linkedin" ~ "linkedin",
                                         new =="rh" ~ "research_highlight",
                                         new =="policies" ~ "policy_source",
                                         new =="delicious" ~ "other_1",
                                         new =="pinners" ~ "other_2",
                                         new =="qs" ~ "other_3",
                                         new =="weibo" ~ "other_4",
                                         new =="rdts" ~ "other_5",
                                         new =="videos" ~ "other_6",
                                         TRUE ~ new)) %>%
    dplyr::filter(! new %in% c("delicious", "pinners", "qs","weibo")) %>%
    dplyr::mutate(new = paste0("n_engage_", new))

  names_cited_included <- names_cited %>% dplyr::filter(old %in% names(df))

  for(i in 1:nrow(names_cited_included)){
    df <- df %>%
      dplyr::rename_at(vars(matches(names_cited_included$old[i])),
                       function(x){x = names_cited_included$new[i]})}

  names_cited_excluded <- names_cited %>%
    dplyr::filter(! old %in% names(df)) %>%
    dplyr::filter(! new %in% names(df)) %>%
    dplyr::mutate(value = list(rep(NA, nrow(df)))) %>%
    tidyr::pivot_wider(id_cols=-old, names_from = new) %>%
    tidyr::unnest(col = everything())

  df <- dplyr::bind_cols(df, names_cited_excluded) %>%
    dplyr::mutate_at(vars(starts_with("n_engage_")), function(x){ifelse(is.na(x)==T, 0, x) %>% as.numeric()}) %>%
    dplyr::mutate(n_engage_other =  dplyr::select(., starts_with("n_engage_other")) %>% rowSums(na.rm = T)) %>%
    dplyr::select(-starts_with("n_engage_other_"))

  # Altmetric dates--------------
  df <- df %>%
    dplyr::mutate(last_updated = lubridate::as_date(lubridate::as_datetime(as.numeric(last_updated))),
                  published_on = lubridate::as_date(lubridate::as_datetime(as.numeric(published_on))),
                  added_on = lubridate::as_date(lubridate::as_datetime(as.numeric(added_on)))) %>%
    dplyr::rename("date_update" = last_updated, "date_publish" = published_on, "date_added" = added_on)

  # Output --------------
  df_out <- df %>%
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
    dplyr::rename_at(vars(ends_with("_count")),
                     function(x){stringr::str_replace(x, "_count", "_n")}) %>%
    dplyr::mutate_at(vars(tidyselect::starts_with("alm_")), as.numeric) %>%

    dplyr::mutate(alm_all_prop = 1-((alm_all_rank-1)/alm_all_n),
                  alm_3m_prop = 1-((alm_3m_rank-1)/alm_3m_n),
                  alm_journal_all_prop = 1-((alm_journal_all_rank-1)/alm_journal_all_n),
                  alm_journal_3m_prop = 1-((alm_journal_3m_rank-1)/alm_journal_3m_n)) %>%
    dplyr::mutate(id = id_class %>% dplyr::filter(id_type %in% c("pmid", "doi")) %>% dplyr::pull(id)) %>%
    dplyr::select(id, doi,altmetric_id,title,
                  type, author_list, journal, journal_issn,
                  starts_with("alm_score_"),
                  starts_with("alm_all_"), starts_with("alm_journal_all_"),
                  starts_with("alm_3m_"), starts_with("alm_journal_3m_"),
                  starts_with("date_"), starts_with("n_engage_"), "url_image" = images.large)

  df_alm_time <- df_out %>%
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

  df_alm_source <- df_out %>%
    dplyr::select(id, doi, starts_with("n_engage_")) %>%
    dplyr::filter(is.na(doi)==F) %>%
    tidyr::pivot_longer(cols = starts_with('n_engage_')&-ends_with('_all'),
                        names_to = "source", values_to = "n") %>%
    dplyr::mutate(source = stringr::str_replace(source, "n_engage_", "")) %>%
    dplyr::filter(! source %in% c("twitter_accounts")) %>%
    dplyr::mutate(source = stringr::str_replace(source, "twitter_posts", "twitter")) %>%
    dplyr::mutate(source = factor(source, levels = c(dplyr::group_by(., source)   %>%
                                                       dplyr::summarise(sum = sum(n)) %>%
                                                       dplyr::arrange(-sum) %>%
                                                       dplyr::filter(sum>0) %>%
                                                       dplyr::pull(source)))) %>%
    dplyr::filter(is.na(source)==F) %>%
    dplyr::group_by(id) %>%
    dplyr::mutate(total = sum(n))  %>% dplyr::mutate(prop = n / total) %>%
    dplyr::ungroup()

  df_alm_rank <- df_out %>%
    dplyr::select(id, doi, journal,alm_score_now,
                  starts_with("alm_all_"),
                  starts_with("alm_journal_all_"),
                  starts_with("alm_3m_"),
                  starts_with("alm_journal_3m_")) %>%
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

    df_out <- id_class %>%
      dplyr::left_join(df_out, by = "id")

  out <- list("df" = df_out, "temporal" = df_alm_time, "rank" = df_alm_rank, "source" = df_alm_source)

  return(out)}
