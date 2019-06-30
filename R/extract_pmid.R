# extract_pmid--------------------------------
# Documentation
#' @title Extract publication data using RISmed / pmid
#' @description Extract publication data using RISmed / pmid
#' @param pmid Vector of unique PubMed identifier numbers (PMID)
#' @param get_auth Extract authorship data (default = TRUE)
#' @param get_almetric Extract overall altmetric score data (default = TRUE)
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
extract_pmid <- function(pmid, get_auth = TRUE, get_almetric = TRUE, get_impact= TRUE){

  "%ni%" <- Negate("%in%")

  pmid_original <- pmid
  pmid_error <- pmid[which(is.na(pmid)==T|is.numeric(pmid)==F)]
  pmid <- pmid[which(is.na(pmid)==F&is.numeric(pmid)==T)] # ensure no NA/ numeric

  pubmed_call <- RISmed::EUtilsSummary(paste0(paste(pmid, collapse = '[PMID] or '), '[PMID]')) %>%
    RISmed::EUtilsGet()

  pmid_norecord <- as.character(pmid_original[which(pmid_original %ni% RISmed::PMID(pubmed_call))])

  type <-  pubmed_call %$%
    RISmed::PublicationType(.) %>%
    purrr::map(function(x){paste0(as.vector(x), collapse = ", ")}) %>%
    purrr::map_chr(function(x){ifelse(grepl("Journal Article", x)==T,
                                  "Paper",
                                  ifelse(grepl("Letter|Editorial", x)==T,
                                         "Letter",
                                         x))})

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
                   journal_issn = RISmed::ISSN(.),  # issn
                   # status = RISmed::PublicationStatus(.), # aheadofprint vs p/epub
                   cite_pm = RISmed::Cited(.))

   if(get_almetric==TRUE){
     score_alm <- function(x) {unlist(lapply(x, function(x){tryCatch(rAltmetric::altmetric_data(rAltmetric::altmetrics(doi = x))$score, error=function(e) NA)}))}

    out_pubmed <- out_pubmed %>%
      mutate(almetric = score_alm(doi))}

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

  if(get_impact==TRUE){out_pubmed <- extract_impact_factor(out_pubmed)}

  if("journal_full.y" %in% names(out_pubmed)){
    out_pubmed <- out_pubmed %>%
      dplyr::rename("journal_full" = journal_full.x, "journal_full2" = journal_full.y)}

  out_pubmed <- out_pubmed %>%
    dplyr::bind_rows(., head(., length(pmid_error)) %>%
                       dplyr::mutate(pmid = pmid_error) %>%
                       dplyr::mutate_if(names(.) %ni% "pmid", function(x){ifelse(is.na(x)==F, NA, x)})) %>%
    dplyr::bind_rows(., head(., length(pmid_norecord)) %>%
                       dplyr::mutate(pmid = pmid_norecord) %>%
                       dplyr::mutate_if(names(.) %ni% "pmid", function(x){ifelse(is.na(x)==F, NA, x)})) %>%
    dplyr::mutate(pmid = factor(pmid, levels = c(pmid_original))) %>%
    dplyr::arrange(pmid)

  return(out_pubmed)}
