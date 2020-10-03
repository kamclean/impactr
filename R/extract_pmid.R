# extract_pmid--------------------------------
# Documentation
#' @title Extract publication data using RISmed / pmid
#' @description Extract publication data using RISmed / pmid
#' @param pmid Vector of unique PubMed identifier numbers (PMID)
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
#' @importFrom furrr map_chr map_lgl
#' @importFrom purrr future_map2_dfr
#' @export

# Function-------------------------------
extract_pmid <- function(pmid, get_altmetric = TRUE, get_impact= TRUE){

  # Load required functions----------------
  require(magrittr);require(dplyr);require(furrr);require(RCurl);require(xml2);require(lubridate)

  # Function to extract PMID information from pubmed XML
  extract_pmid_xml <- function(list_pmid){

    RCurl::getURL(paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=",
                         paste(list_pmid, collapse = "+OR+"),
                         "&retmode=xml")) %>%
      xml2::as_xml_document() %>% xml2::xml_find_all("PubmedArticle")}

  # Clean pmid----------------
  pmid_original <- pmid
  pmid_error <- pmid[which(is.na(pmid)==T|purrr::map_lgl(pmid_original, is.numeric)==F)]
  pmid <- pmid[which(is.na(pmid)==F&purrr::map_lgl(pmid_original, is.numeric)==T)] # ensure no NA/ non-numeric


  data <- extract_pmid_xml(list_pmid = pmid) %>%
    furrr::future_map2_dfr(., seq_along(1:length(.)), function(x, y){print(y)

      return(suppressMessages(impactr::extract_pubmed_xml(x, var_abstract = F, var_registry = F)))}) %>%

    dplyr::mutate(date_publish = dplyr::case_when(is.na(date_publish)==T ~ history_entrez,
                                                  is.na(date_publish)==T ~ history_pubmed,
                                                  is.na(date_publish)==T ~ history_medline,
                                                  TRUE ~ date_publish)) %>%
    dplyr::mutate(year = lubridate::year(date_publish)) %>%
    dplyr::select(-dplyr::ends_with("aff"), -dplyr::starts_with("history_")) %>%
    dplyr::mutate(pmid = as.character(pmid))


  if(get_altmetric==TRUE){

    data <- data %>%
      dplyr::mutate(altmetric = impactr::score_alm(doi))}

  if(get_impact==TRUE){data <- impactr::extract_impact_factor(data)}

  if("journal_full.y" %in% names(data)){
    data <- data %>%
      dplyr::rename("journal_full" = journal_full.x, "journal_full2" = journal_full.y)}

  out <- tibble::enframe(as.character(pmid), name=  NULL, value = "pmid") %>%
    dplyr::left_join(data, by = "pmid") %>%
    dplyr::mutate(pmid = factor(pmid, levels = c(pmid)))

  return(out)}
