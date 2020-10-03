# cite_scopus------------------------------
# Documentation
#' Derive citation data from the Crossref database via rcrossref
#' @description Derive citation data from the Crossref database
#' @param id Vector of pmid / doi
#' @param scopus_api Either scopus API directly or ignore if preset via rscopus::set_api_key(scopus_api). Instructions to obtain can be found here (https://rdrr.io/cran/rscopus/f/vignettes/api_key.Rmd)
#' @return Dataframe
#' @import magrittr
#' @import rscopus
#' @import purrr
#' @import tibble
#' @import stringr
#' @export

# Function
cite_scopus <- function(id, scopus_api = rscopus::get_api_key()){
  require(magrittr);require(tibble);require(stringr);require(purrr);require(dplyr)
  require(rscopus);

  rscopus::set_api_key(scopus_api)

  id_class <- as.character(id_list) %>%
    tibble::enframe(name = "n", value = "id") %>%
    # https://www.crossref.org/blog/dois-and-matching-regular-expressions/
    dplyr::mutate(id_type = dplyr::case_when(stringr::str_detect(id, "^10\\.\\d{4,9}/")==T ~  "doi",
                                             nchar(id)==8&is.numeric(as.numeric(id))==T ~ "pmid",
                                             TRUE ~ "invalid"))

  result_pmid <- NULL
  # Get SCOPUS API https://rdrr.io/cran/rscopus/f/vignettes/api_key.Rmd
  # SCOPUS search terms https://dev.elsevier.com/tips/ScopusSearchTips.htm
  if(rscopus::have_api_key()&("pmid" %in% id_class$id_type)) {
    search_pmid <- id_class %>%
      dplyr::filter(id_type=="pmid") %>%
      dplyr::mutate(id_pmid = id) %$%
      rscopus::scopus_search(query=paste0("PMID(", paste(id_pmid, collapse= ") OR PMID("),")"),verbose = F)$entries

    result_pmid <- rscopus::gen_entries_to_df(search_pmid)$df %>%
      dplyr::select("id_pmid" = `pubmed-id`, "id_doi" = `prism:doi`, "cite" = `citedby-count`) %>%
      dplyr::left_join(id_class, by=c("id_pmid"="id")) %>%
      dplyr::mutate(id = id_pmid) %>%
      dplyr::select(n, id, id_pmid, id_doi, cite)}

  result_doi <- NULL
  if(rscopus::have_api_key()&("doi" %in% id_class$id_type)) {
    search_doi <- id_class %>%
      dplyr::filter(id_type=="doi") %>%
      dplyr::mutate(id_pmid = id) %$%
      rscopus::scopus_search(query=paste0("DOI(", paste(id_pmid, collapse= ") OR DOI("),")"),verbose = F)$entries

    result_doi <- rscopus::gen_entries_to_df(search_doi)$df %>%
      dplyr::select("id_pmid" = `pubmed-id`, "id_doi" = `prism:doi`, "cite" = `citedby-count`) %>%
      dplyr::left_join(id_class, by=c("id_doi"="id")) %>%
      dplyr::mutate(id = id_doi) %>%
      dplyr::select(n, id, id_pmid, id_doi, cite)}


  result_comb <- dplyr::bind_rows(result_doi, result_pmid) %>% tibble::as_tibble()

  result_na <- NULL
  if(FALSE %in% c(id_class$n %in% result_comb$n)){
  result_na <- id_class %>%
    dplyr::filter(! n %in% result_comb$n) %>%
    dplyr::mutate(id_pmid = NA, id_doi = NA, cite = NA) %>%
    dplyr::mutate(id_pmid = ifelse(id_type=="pmid", id, id_pmid),
                  id_doi = ifelse(id_type=="doi", id, id_doi)) %>%
    dplyr::select(n, id, id_pmid, id_doi, cite)}


  result_comb <- dplyr::bind_rows(result_comb, result_na) %>%
    dplyr::arrange(n)

  return(result_comb)}
