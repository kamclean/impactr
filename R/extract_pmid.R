# extract_pmid--------------------------------
# Documentation
#' @title Extract publication data using Pubmed ID
#' @description Extract publication data using Pubmed ID
#' @param pmid Vector of unique PubMed identifier numbers (PMID)
#' @param get_authors Extract authorship data (default = TRUE)
#' @param get_altmetric Extract overall altmetric score data (default = TRUE)
#' @param get_impact Extract journal impact factor and metrics (default = TRUE)
#' @return Dataframe of essential publication data
#' @import magrittr
#' @import dplyr
#' @import RCurl
#' @import xml2
#' @import tibble
#' @import stringr
#' @import lubridate
#' @importFrom furrr future_map2_dfr
#' @importFrom purrr map_chr map_lgl
#' @export

# Function-------------------------------
extract_pmid <- function(pmid, get_authors = TRUE, get_collaborators = F, get_altmetric = TRUE, get_impact= TRUE){

  # Load required functions----------------
  require(magrittr);require(dplyr);require(furrr);require(RCurl);require(xml2);require(lubridate)


  # Clean pmid----------------
  check_pmid <- as.character(pmid) %>%
    tibble::enframe(name = NULL, value= "original") %>%
    dplyr::mutate(numeric = as.numeric(original)) %>%

    # ensure no NA/ non-numeric
    dplyr::mutate(check = dplyr::case_when(is.na(numeric)==T ~"fail",
                                           purrr::map_lgl(numeric, is.numeric)==F ~ "fail",
                                           TRUE ~ "pass"))

  pmid <- check_pmid %>% dplyr::filter(check == "pass") %>% dplyr::pull(numeric)

  data2 <- format_pubmed_xml(pmid, var_author = get_authors, var_collaborator = get_collaborators,
                                     var_abstract = F) %>%

    dplyr::mutate(date_publish = dplyr::case_when(is.na(date_publish)==T ~ history_entrez,
                                                  is.na(date_publish)==T ~ history_pubmed,
                                                  is.na(date_publish)==T ~ history_medline,
                                                  TRUE ~ date_publish)) %>%
    dplyr::mutate(year = lubridate::year(date_publish)) %>%
    dplyr::select(-dplyr::starts_with("history_")) %>%
    dplyr::mutate(pmid = as.character(pmid))


  if(get_altmetric==TRUE){data2 <- data2 %>% dplyr::mutate(altmetric = impactr::score_alm(doi))}

  if(get_impact==TRUE){data2 <- impactr::extract_impact_factor(data2)}

  if("journal_full.y" %in% names(data2)){
    data2 <- data2 %>%
      dplyr::rename("journal_full" = journal_full.x, "journal_full2" = journal_full.y)}

  out <- tibble::enframe(as.character(pmid), name=  NULL, value = "pmid") %>%
    dplyr::left_join(data2, by = "pmid") %>%
    dplyr::distinct(pmid, .keep_all = T) %>%
    dplyr::mutate(pmid = factor(pmid, levels = c(pmid)))

  return(out)}
