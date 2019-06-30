# impact_almetric----------------------
# Documentation
#' Extract almetric data on social media engagment
#' @description Extract impact data from social media engagment
#' @param list_pmid Vector of unique PubMed identifier numbers (PMID)
#' @return Dataframe of data on social media engagment from the almetric repository
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @importFrom rAltmetric altmetric_data altmetrics
#' @importFrom purrr map map_chr
#' @importFrom data.table rbindlist
#' @importFrom tidyr unite
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
      dplyr::mutate(n_engage_other = sum(dplyr::select(., starts_with("n_engage_other")))) %>%
      dplyr::select(-one_of(names(dplyr::select(., n_engage_other1:n_engage_other6))))

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
                    "alm_journal_3m_n" = context.similar_age_journal_3m.count) %>%
      dplyr::mutate_at(vars(pmid, dplyr::starts_with("alm_")), as.numeric) %>%
      dplyr::mutate(alm_all_prop = 1-(alm_all_rank/alm_all_n),
                    alm_journal_all_prop = 1-(alm_journal_all_rank/alm_journal_all_n),
                    alm_journal_3m_prop = 1-(alm_journal_3m_rank/alm_journal_3m_n)) %>%
      dplyr::select(pmid:alm_all_n, alm_all_prop,
                    alm_journal_all_mean:alm_journal_all_n, alm_journal_all_prop,
                    alm_journal_3m_mean:alm_journal_3m_n, alm_journal_3m_prop) %>%
      dplyr::bind_cols(cited_by)}) %>%
  data.table::rbindlist() %>% as_tibble()

pmid_na <- df %>% dplyr::filter(pmid %ni% df_alm$pmid) %>% dplyr::pull(pmid) %>% as.numeric()

df_pmid_na<- head(df_alm, length(pmid_na)) %>%
  dplyr::mutate_at(vars(-pmid), function(x){x = NA}) %>%
  dplyr::mutate(pmid = pmid_na)

df_out <- bind_rows(df_alm, df_pmid_na) %>%
  dplyr::mutate(pmid = factor(pmid, levels=as.numeric(df$pmid))) %>%
  dplyr::arrange(pmid) %>%
  dplyr::mutate(pmid = as.numeric(as.character(pmid)))

return(df_out)}
