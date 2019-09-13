# impact_almetric----------------------
# Documentation
#' Extract almetric data on social media engagment
#' @description Extract impact data from social media engagment
#' @param list_pmid Vector of unique PubMed identifier numbers (PMID)
#' @return Nested dataframe (1) df_output; Original dataset with appended almetric data (2) temporal; Long format data on temporal changes (3) rank; Long format data almetric ranking (4) source; Long format data sources used to derive almetric.
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @importFrom rAltmetric altmetric_data altmetrics
#' @importFrom purrr map map_chr
#' @importFrom data.table rbindlist
#' @importFrom tidyr unite pivot_longer pivot_wider
#' @importFrom tidyr unite pivot_longer pivot_wider
#' @importFrom stringr str_split_fixed
#' @importFrom stringi stri_reverse
#' @importFrom lubridate as_date as_datetime
#' @importFrom data.table rbindlist
#' @export

# Function-------------------------------
# aim to be able to use either pmid or doi
impact_almetric <- function(list_pmid){
  "%ni%" <- Negate("%in%")
# https://api.altmetric.com/docs/call_citations.html
# https://github.com/ropensci/rAltmetric/issues/27

names_cited_old <- c("cited_by_posts_count", "cited_by_accounts_count","cited_by_tweeters_count","cited_by_fbwalls_count","cited_by_msm_count",
                     "cited_by_policies_count","cited_by_peer_review_sites_count", "cited_by_wikipedia_count","cited_by_feeds_count",
                     "cited_by_forum_count", "cited_by_gplus_count","cited_by_rh_count", "cited_by_linkedin_count", "readers_count",
                     "cited_by_delicious_count","cited_by_pinners_count","cited_by_qs_count","cited_by_weibo_count",
                     "cited_by_rdts_count","cited_by_videos_count")

names_cited <- tibble::tibble(old = names_cited_old) %>%
  dplyr::mutate(new = gsub("_count",  "", gsub("cited_by_", "", old))) %>%
  dplyr::mutate(new = gsub("fbwalls",  "fb", new),
                new = gsub("posts",  "all", new),
                new = gsub("tweeters",  "twitter_posts", new),
                new = gsub("accounts",  "twitter_accounts", new),
                new = gsub("msm",  "news_media", new),
                new = gsub("wikipedia",  "wikipedia", new),
                new = gsub("feeds",  "blogs", new),
                new = gsub("forum",  "forum", new),
                new = gsub("gplus",  "googleplus", new),
                new = gsub("msm",  "news", new),
                new = gsub("linkedin",  "linkedin", new),
                new = gsub("rh",  "research_highlight", new),
                new = gsub("policies",  "policy_source", new),
                new = gsub("delicious",  "other1", new),
                new = gsub("pinners",  "other2", new),
                new = gsub("qs",  "other3", new),
                new = gsub("weibo",  "other4", new),
                new = gsub("rdts",  "other5", new),
                new = gsub("videos",  "other6", new)) %>%
  dplyr::filter(new %ni% c("delicious", "pinners", "qs","weibo")) %>%
  dplyr::mutate(new = paste0("n_engage_", new))

df = tibble::tibble(pmid = list_pmid)

df_alm <- df %>%
  dplyr::mutate(alm_data = purrr::map_chr(pmid,
                                          function(x){tryCatch(rAltmetric::altmetric_data(rAltmetric::altmetrics(pmid = x))$score, error=function(e) NA)})) %>%
  dplyr::filter(is.na(alm_data)==F) %>%
  dplyr::group_split(pmid) %>%
  purrr::map(function(x){rAltmetric::altmetric_data(rAltmetric::altmetrics(pmid = x$pmid)) %>%
      tibble::as_tibble() %>%
      dplyr::mutate(authors = NA) %>%
      tidyr::unite(., col = "author_list", sep = ", ", remove = TRUE,
                   names(dplyr::select(., dplyr::starts_with("authors")))) %>%
      tidyr::unite(., col = "issns", sep = ", ", remove = TRUE,
                   names(dplyr::select(., dplyr::starts_with("issns")))) -> v

    names_cited_included <- v %>%
      dplyr::select(names_cited$old[names_cited$old %in% names(.)]) %>%
      setNames(names_cited$new[names_cited$old %in% names(.)])

    names_cited_excluded <- names_cited$new[names_cited$old %ni% names(v)] %>%
      setNames(object = rbind.data.frame(rep(NA, length(.))),nm=.)

    cited_by <- dplyr::bind_cols(names_cited_included, names_cited_excluded) %>%
      dplyr::select(names_cited$new) %>%
      dplyr::mutate_all(function(x){ifelse(is.na(x)==T, 0, x)}) %>%
      dplyr::mutate(n_engage_other = sum(dplyr::select(., dplyr::starts_with("n_engage_other")))) %>%
      dplyr::select(-dplyr::one_of(names(dplyr::select(., n_engage_other1:n_engage_other6))))

    v_out <- v %>%
      dplyr::mutate(pmid = x$pmid) %>%
      dplyr::select(pmid, doi, title, type, author_list, journal, "journal_issn" = issns, altmetric_id,
                    "alm_score_1w" = history.1w,
                    "alm_score_1m" = history.1m,
                    "alm_score_3m" = history.3m,
                    "alm_score_6m" = history.6m,
                    "alm_score_1y" = history.1y,
                    "alm_score_now" = score,

                    "alm_all_mean" = context.all.mean,
                    "alm_all_rank" = context.all.rank,
                    "alm_all_n" = context.all.count,
                    "alm_journal_all_mean" = context.journal.mean,
                    "alm_journal_all_rank" = context.journal.rank,
                    "alm_journal_all_n" = context.journal.count,
                    "alm_journal_3m_mean" = context.similar_age_journal_3m.mean,
                    "alm_journal_3m_rank" = context.similar_age_journal_3m.rank,
                    "alm_journal_3m_n" = context.similar_age_journal_3m.count,
                    last_updated, published_on,added_on,journal) %>%
      dplyr::mutate_at(dplyr::vars(pmid, dplyr::starts_with("alm_")), as.numeric) %>%
      dplyr::mutate(alm_all_prop = 1-(alm_all_rank-1/alm_all_n),
                    alm_journal_all_prop = 1-(alm_journal_all_rank/alm_journal_all_n),
                    alm_journal_3m_prop = 1-(alm_journal_3m_rank/alm_journal_3m_n)) %>%
      dplyr::select(journal, pmid:alm_all_n, alm_all_prop,
                    alm_journal_all_mean:alm_journal_all_n, alm_journal_all_prop,
                    alm_journal_3m_mean:alm_journal_3m_n, alm_journal_3m_prop,
                    last_updated, published_on,added_on) %>%
      dplyr::bind_cols(cited_by)}) %>%
  data.table::rbindlist() %>% tibble::as_tibble() %>%
  dplyr::mutate(date_update = lubridate::as_date(lubridate::as_datetime(as.numeric(last_updated))),
                date_pub = lubridate::as_date(lubridate::as_datetime(as.numeric(published_on))),
                date_added = lubridate::as_date(lubridate::as_datetime(as.numeric(added_on)))) %>%
  dplyr::select(-last_updated, -published_on, -added_on)

pmid_na <- df %>% dplyr::filter(pmid %ni% df_alm$pmid) %>% dplyr::pull(pmid) %>% as.numeric()


df_pmid_na <- head(df_alm, length(pmid_na)) %>%
  dplyr::mutate_at(dplyr::vars(-pmid), function(x){x = NA}) %>%
  dplyr::mutate(pmid = pmid_na)

df_out <- dplyr::bind_rows(df_alm, df_pmid_na) %>%
  dplyr::mutate(pmid = factor(pmid, levels=as.numeric(df$pmid))) %>%
  dplyr::arrange(pmid) %>%
  dplyr::mutate(pmid = as.numeric(as.character(pmid)))

df_alm_time <- df_out %>%
  dplyr::select(pmid, doi, alm_score_1w:alm_score_now, date_pub,date_added) %>%
  dplyr::filter(is.na(doi)==F) %>%
  tidyr::pivot_longer(cols = c(alm_score_1w:alm_score_now),
                      names_to = "alm_time", values_to = "alm_score") %>%
  dplyr::mutate(alm_time = ifelse(alm_time=="alm_score_1w", 7,
                                   ifelse(alm_time=="alm_score_1m", 30,
                                          ifelse(alm_time=="alm_score_3m", 90,
                                                 ifelse(alm_time=="alm_score_6m", 180,
                                                        ifelse(alm_time=="alm_score_1y", 365,
                                                               alm_time)))))) %>%
  dplyr::mutate(pub2now =  as.numeric(lubridate::as_date(Sys.Date())-date_added)) %>%
  dplyr::mutate(alm_time = as.numeric(ifelse(alm_time == "alm_score_now",
                                             pub2now, alm_time))) %>%
  dplyr::filter(pub2now>=alm_time) %>%
  dplyr::select(-pub2now) %>%
  dplyr::arrange(pmid, alm_time) %>%
  dplyr::mutate(pmid = factor(pmid))

df_alm_source <- df_out %>%
  dplyr::select(pmid, doi, n_engage_all:n_engage_other) %>%
  dplyr::mutate_at(dplyr::vars(dplyr::starts_with("n_engage")), as.numeric) %>%
  dplyr::filter(is.na(doi)==F) %>%
  tidyr::pivot_longer(cols = c(n_engage_all:n_engage_other),
                      names_to = "source", values_to = "n") %>%
  dplyr::mutate(source = gsub("n_engage_", "", source)) %>%
  dplyr::filter(source %ni% c("twitter_posts","all")) %>%
  dplyr::mutate(source = gsub("twitter_accounts", "twitter", source)) %>%
  dplyr::mutate(pmid = factor(pmid),
                source = factor(source, levels = c(dplyr::group_by(., source)   %>%
                                                     dplyr::summarise(sum = sum(n)) %>%
                                                     dplyr::arrange(-sum) %>%
                                                     dplyr::filter(sum>0) %>%
                                                     dplyr::pull(source)))) %>%
  dplyr::filter(is.na(source)==F) %>%
  dplyr::group_by(pmid) %>%
  dplyr::mutate(total = sum(n))  %>% dplyr::mutate(prop = n / total) %>%
  dplyr::ungroup()

df_alm_rank <- df_out %>%
  dplyr::select(pmid, doi, journal,alm_score_now,alm_all_mean:alm_journal_3m_prop) %>%
  tidyr::pivot_longer(names(dplyr::select(., alm_all_mean:alm_journal_3m_prop)), names_to = "alm_category") %>%
  dplyr::mutate(alm_category = gsub("alm_", "", alm_category),
                journal = factor(journal)) %>%
  dplyr::mutate(alm_measure = stringr::str_split_fixed(stringi::stri_reverse(alm_category), "_", 2)[,1],
                alm_category = stringr::str_split_fixed(stringi::stri_reverse(alm_category), "_", 2)[,2]) %>%
  dplyr::mutate(alm_measure = stringi::stri_reverse(alm_measure),
                alm_category = factor(stringi::stri_reverse(alm_category))) %>%
  tidyr::pivot_wider(names_from = alm_measure, values_from = value) %>%
  dplyr::filter(is.na(mean)==F) %>%
  dplyr::rename(alm_score = alm_score_now)


  out <- list("df_output" = df_out, "temporal" = df_alm_time, "rank" = df_alm_rank, "source" = df_alm_source)

  return(out)}
