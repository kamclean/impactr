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
extract_pmid <- function(pmid, get_auth = TRUE, get_altmetric = TRUE, get_impact= TRUE){
  require(magrittr)
  "%ni%" <- Negate("%in%")

  pmid_original <- as.numeric(pmid)
  pmid_error <- pmid[which(is.na(pmid)==T|purrr::map_lgl(pmid_original, is.numeric)==F)]
  pmid <- pmid[which(is.na(pmid)==F&purrr::map_lgl(pmid_original, is.numeric)==T)] # ensure no NA/ numeric

  pubmed_call <- RISmed::EUtilsSummary(paste0(paste(pmid, collapse = '[PMID] or '), '[PMID]')) %>%
    RISmed::EUtilsGet()

  pmid_norecord <- as.character(pmid[which(pmid %ni% RISmed::PMID(pubmed_call))])

  type <-  pubmed_call %$%
    RISmed::PublicationType(.) %>%
    purrr::map_chr(function(x){paste0(as.vector(x), collapse = ", ")}) %>%
    purrr::map_chr(function(x){ifelse(grepl("Clinical Trial|Randomized Controlled Trial", x)==T,
                                      "Paper (Clinical Trial)",
                                      ifelse(grepl("Letter|Editorial", x)==T,
                                             "Letter",
                                             ifelse(grepl("Review|Meta-Analysis", x)==T,
                                                    "Paper (Review)",
                                                    ifelse(grepl("Journal Article", x)==T,
                                                           "Paper (Original)",x))))})

   out_pubmed <- pubmed_call %$%
    tibble::tibble(pmid = RISmed::PMID(.), # pmid
                   author_group = gsub(" &amp;",";", RISmed::CollectiveName(.)),
                   type = type, # type of publication
                   title = RISmed::ArticleTitle(.),
                   year = RISmed::YearPubmed(.),
                   journal_full = RISmed::Title(.), # journal full name
                   journal_abbr = RISmed::ISOAbbreviation(.), # journal abbreviated name
                   volume = RISmed::Volume(.),
                   issue = RISmed::Issue(.),
                   pages = RISmed::MedlinePgn(.), # pagenumber
                   doi = tolower(RISmed::ELocationID(.)),  # doi
                   journal_issn1 = trimws(RISmed::ISSN(.)),  # issn
                   journal_issn2 = trimws(RISmed::ISSNLinking(.)),  # issn
                   # status = RISmed::PublicationStatus(.), # aheadofprint vs p/epub
                   cite_pm = RISmed::Cited(.),
                   nlmid = RISmed::NlmUniqueID(.)) %>%
     dplyr::mutate(journal_issn = ifelse(journal_issn1==journal_issn2,
                                  journal_issn1,
                                  paste0(journal_issn1, ", ", journal_issn2))) %>%
     dplyr::select(-journal_issn1, -journal_issn2)


   if(get_altmetric==TRUE){

    out_pubmed <- out_pubmed %>%
      mutate(altmetric = impactr::score_alm(doi))}

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
