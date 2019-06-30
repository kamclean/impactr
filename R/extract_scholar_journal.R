# extract_scholar_journal----------------------
# Documentation
#' @title Extract additional jounral metrics from Google Scholar
#' @description Extract additional jounral metrics from Google Scholar
#' @param list_journals Vector of journal names (note: Google Scholar requires specific formats to match to journal records)
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @importFrom scholar get_impactfactor
#' @return Nested dataframe of: (1). "metrics" - journal metrics derived from Google Scholar; (2). "unmatch" - list of journals unable to be matched within Google Scholar.
#' @export

# Function----------------
extract_scholar_journal <- function(list_journals){
  library(dplyr)
  out <- tibble::tibble("journal_in" = list_journals) %$%
    scholar::get_impactfactor(journal_in, max.distance = 0) %>%
    dplyr::mutate(journal = list_journals,
                  journal_in = toupper(list_journals)) %>%
    dplyr::select(journal, journal_in, "journal_out" = Journal,
                  "journal_impact" = ImpactFactor,"journal_eigen" = Eigenfactor) %>%
    dplyr::mutate(journal_out = toupper(journal_out)) %>%
    dplyr::mutate(journal_match = ifelse(journal_in!=journal_out|is.na(journal_out)==T, "No", "Yes")) %>%
    dplyr::distinct(journal_in, .keep_all=TRUE)

  unmatch <- NULL
  if("No" %in% out$journal_match){
    unmatch <- out %>%
      dplyr::filter(journal_match=="No") %>%
      dplyr::select(journal:journal_out)}

  metrics <- NULL
  if("Yes" %in% out$journal_match){
    metrics <- out %>%
      dplyr::filter(journal_match=="Yes") %>%
      dplyr::select(-journal_in, -journal_match)}

  output <- list("metrics" = metrics, "unmatch" = unmatch)
  return(output)}
