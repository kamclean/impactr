# extract_pmid--------------------------------
# Documentation
#' @title Extract publication data using RISmed / pmid
#' @description Extract publication data using RISmed / pmid
#' @param pmid Vector of unique PubMed identifier numbers (PMID)
#' @param get_auth Extract authorship data (default = TRUE)
#' @param get_altmetric Extract overall altmetric score data (default = TRUE)
#' @param get_impact Extract journal impact factor and metrics (default = TRUE)
#' @return Dataframe of essential publication data
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @import RISmed
#' @importFrom rAltmetric altmetric_data altmetrics
#' @importFrom purrr map map_chr
#' @importFrom data.table rbindlist
#' @export

# Function-------------------------------
extract_pmid <- function(pmid, get_altmetric = TRUE, get_impact= TRUE){

  # Load required functions----------------
  require(magrittr);require(dplyr);require(furrr);require(RCurl);require(xml2);require(lubridate)
  "%ni%" <- Negate("%in%")

  # Function to extract PMID information from pubmed XML
  extract_pmid_xml <- function(list_pmid){

    RCurl::getURL(paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=",
                         paste(list_pmid, collapse = "+OR+"),
                         "&retmode=xml")) %>%
      xml2::as_xml_document() %>% xml2::xml_find_all("PubmedArticle")}

  # Clean pmid----------------
  pmid_original <- as.numeric(pmid)
  pmid_error <- pmid[which(is.na(pmid)==T|purrr::map_lgl(pmid_original, is.numeric)==F)]
  pmid <- pmid[which(is.na(pmid)==F&purrr::map_lgl(pmid_original, is.numeric)==T)] # ensure no NA/ non-numeric



  out <- extract_pmid_xml(list_pmid = pmid) %>%
    furrr::future_map2_dfr(., seq_along(1:length(.)), function(x, y){print(y)

      return(suppressMessages(extract_pubmed_xml(x, var_abstract = F, var_registry = F)))}) %>%

    dplyr::mutate(date_publish = dplyr::case_when(is.na(date_publish)==T ~ history_entrez,
                                                  is.na(date_publish)==T ~ history_pubmed,
                                                  is.na(date_publish)==T ~ history_medline,
                                                  TRUE ~ date_publish)) %>%
    dplyr::mutate(year = lubridate::year(date_publish)) %>%
    dplyr::select(-dplyr::ends_with("aff"), -dplyr::starts_with("history_"))


   if(get_altmetric==TRUE){

     out <- out %>%
      dplyr::mutate(altmetric = impactr::score_alm(doi))}

  if(get_auth==TRUE){
    pub_auth <- pubmed_call %$%
      data.table::rbindlist(RISmed::Author(.), idcol="pubmed_id") %>%
      dplyr::mutate(pubmed_id = factor(pubmed_id, labels = RISmed::PMID(pubmed_call))) %>%
      dplyr::mutate(name = paste0(LastName, " ", Initials)) %>%
      dplyr::group_by(pubmed_id) %>%
      dplyr::summarise(auth_n = n(),
                       author_list =  paste(name, collapse=", "))

    out_pubmed <- out_pubmed %>%
      dplyr::mutate(auth_n = pub_auth$auth_n,
             author = pub_auth$author_list)}

  if(get_impact==TRUE){out_pubmed <- impactr::extract_impact_factor(out_pubmed)}

  if("journal_full.y" %in% names(out_pubmed)){
    out_pubmed <- out_pubmed %>%
      dplyr::rename("journal_full" = journal_full.x, "journal_full2" = journal_full.y)}

  out_pubmed2 <- out_pubmed %>%
    dplyr::bind_rows(., head(., length(pmid_error)) %>%
                       dplyr::mutate(pmid = pmid_error) %>%
                       dplyr::mutate_if(names(.) %ni% "pmid", function(x){ifelse(is.na(x)==F, NA, x)})) %>%
    dplyr::bind_rows(., head(., length(pmid_norecord)) %>%
                       dplyr::mutate(pmid = pmid_norecord) %>%
                       dplyr::mutate_if(names(.) %ni% "pmid", function(x){ifelse(is.na(x)==F, NA, x)})) %>%
    dplyr::mutate(pmid = factor(pmid, levels = c(pmid_original))) %>%
    dplyr::arrange(pmid)

  return(out_pubmed2)}
