# format_pubmed_xml----------------------
# Documentation
#' Extract all pubmed data for list of PMID
#' @description Extract all pubmed data for list of PMID
#' @param xml_pubmed Vector of PMID that details are desired from.
#' @param var_id Extract article identification numbers (PMID, DOI, and PMC)
#' @param var_journal Extract journal information (journal name and abbreviation, journal identification numbers, journal issue/volume/pages)
#' @param var_author Extract author information  (names with and without affiliations, overall number)
#' @param var_collaborator Extract collaborator information (names with and without affiliations, overall number)
#' @param var_metadata Extract article metadata (publication status, type of article)
#' @param var_history Extract article history (dates of publication, entry onto pubmed, etc)
#' @param var_registry Extract article registry information (registry number and location)
#' @param var_abstract Extract article abstract
#' @param n_chunk Maximum number within each individual API request to pubmed (suggested <200).
#' @return Tibble of data extracted from pubmed XML
#' @import magrittr
#' @import dplyr
#' @import xml2
#' @import lubridate
#' @import tidyr
#' @import dplyr
#' @import dplyr
#' @import stringr
#' @import tibble
#' @import purrr
#' @import furrr
#' @importFrom stringr str_split_fixed str_count
#' @importFrom zoo na.locf
#' @importFrom rlang is_empty
#' @export

format_pubmed_xml <- function(pmid, var_id = TRUE, var_journal = TRUE,var_author = TRUE, var_collaborator = TRUE,
                              var_metadata = TRUE, var_history = TRUE, var_registry = F,var_abstract = F,
                              n_chunk = 200){


  extract_xml <- function(xml){

    require(dplyr);require(xml2);require(tidyr);require(lubridate);require(zoo);require(tibble);
    require(rlang);require(purrr);require(stringr)

    xml_pubmed <- xml %>% xml2::as_list()

    id <- NULL
    if(var_id==T){

      id_names <-c("pmid", "doi", "pmc")

      id <- tibble::tibble(pmid = NA_character_, doi = NA_character_, pmc = NA_character_)
      if(is.null(xml_pubmed$PubmedData$ArticleIdList)==F){

        id <- dplyr::bind_cols(tibble::enframe(unlist(lapply(xml_pubmed$PubmedData$ArticleIdList, attributes)),
                                               name = NULL, value = "id_type"),
                               tibble::enframe(unlist(xml_pubmed$PubmedData$ArticleIdList),
                                               name = NULL, value = "id_value" )) %>%
          dplyr::mutate(id_type = ifelse(id_type=="pubmed", "pmid", id_type)) %>%
          dplyr::filter(id_type %in% id_names) %>%
          dplyr::mutate(across(everything(), function(x){as.character(x)})) %>%
          tidyr::pivot_wider(names_from = "id_type",  values_from = "id_value")

        if(rlang::is_empty(id_names[! id_names %in% names(id)])==F){

          id <- id %>%
            dplyr::bind_cols(id_names[! id_names %in% names(id)] %>%
                               purrr::map_dfc(setNames, object = list(NA_character_)))}}

      title <- tibble::tibble(title = NA)
      if(is.null(xml_pubmed$MedlineCitation$Article$ArticleTitle)==F){
        title <- tibble::enframe(unlist(xml_pubmed$MedlineCitation$Article$ArticleTitle),
                                 name = NULL, value = "title") %>%
          dplyr::summarise(title = paste(title, collapse = ""))}

      id <- dplyr::bind_cols(id, title)}

    journal <- NULL
    if(var_journal == T){

      journal_names <- paste0("journal_", c("nlm", "issn", "full", "abbr", "vol", "issue", "pages"))

      if(is.null(xml_pubmed$MedlineCitation$MedlineJournalInfo)==F){
        journal_na <- journal
        journal <- dplyr::bind_rows(tibble::enframe(unlist(xml_pubmed$MedlineCitation$MedlineJournalInfo)) %>% mutate_all(as.character),
                                    tibble::enframe(unlist(xml_pubmed$MedlineCitation$Article$Journal)) %>% mutate_all(as.character),
                                    tibble::enframe(unlist(xml_pubmed$MedlineCitation$Article$Pagination)) %>% mutate_all(as.character)) %>%
          dplyr::mutate(name = dplyr::case_when(name == "NlmUniqueID" ~ "journal_nlm",
                                                name %in% c("ISSN", "ISSNLinking") ~ "journal_issn",
                                                name == "Title" ~ "journal_full",
                                                name == "ISOAbbreviation" ~ "journal_abbr",
                                                name == "JournalIssue.Volume" ~ "journal_vol",
                                                name == "JournalIssue.Issue" ~ "journal_issue",
                                                name == "MedlinePgn" ~ "journal_pages",
                                                TRUE ~ name)) %>%
          dplyr::filter(stringr::str_detect(name, "journal_")) %>%
          dplyr::group_by(name) %>%
          dplyr::summarise(value = paste(value, collapse = ", ")) %>%
          dplyr::mutate(across(everything(), function(x){as.character(x)})) %>%
          tidyr::pivot_wider(names_from = "name",  values_from = "value")

        if(rlang::is_empty(journal_names[! journal_names %in% names(journal)])==F){

          journal <- journal %>%
            dplyr::bind_cols(journal_names[! journal_names %in% names(journal)] %>%
                               purrr::map_dfc(setNames, object = list(NA_character_)))}

        journal <- journal %>% dplyr::select(all_of(journal_names))}}

    author <- NULL
    if(var_author==T){
      author <- tibble::tibble("author_n" = 0, "author_list" = NA_character_,
                               "author_list_aff" = NA_character_, "author_group" = NA_character_)
      author_group = tibble::tibble("author_group" = NA_character_)
      author_names <- c("LastName", "Initials", "AffiliationInfo.Affiliation")

      if(is.null(xml_pubmed$MedlineCitation$Article$AuthorList)==F){

        author_raw <- tibble::enframe(xml_pubmed$MedlineCitation$Article$AuthorList) %>%
          dplyr::mutate(n = 1:n(),
                        collective = stringr::str_detect(tolower(as.character(value)), "collectivename"))

        if(nrow(dplyr::filter(author_raw, collective==F))>0){
          author <- author_raw %>%
            dplyr::filter(collective==F) %>%
            dplyr::select(n, value) %>%
            dplyr::mutate(name = purrr::map(value, function(x){names(x)})) %>%
            tidyr::unnest(cols = c(value, name)) %>%
            dplyr::mutate(name2 = purrr::map(value, function(x){names(x)})) %>%
            dplyr::mutate(name2 = purrr::map(name2, function(x){ifelse(is.null(x)==T, NA, x) %>% as.character()})) %>%
            tidyr::unnest(c(value, name2))  %>% dplyr::mutate(value = unlist(value)) %>%
            dplyr::filter(name %in% c("LastName", "Initials", "AffiliationInfo.Affiliation")|name2=="Affiliation") %>%
            dplyr::group_by(n, name) %>%
            dplyr::summarise(value = paste(value, collapse = "; ")) %>%
            dplyr::ungroup() %>%
            dplyr::mutate(across(everything(), function(x){as.character(x)})) %>%
            tidyr::pivot_wider(id_cols= n, names_from = name, values_from = value)


          if(rlang::is_empty(author_names[! author_names %in% names(author)])==F){

            author <- author %>%
              dplyr::bind_cols(author_names[! author_names %in% names(author)] %>%
                                 purrr::map_dfc(setNames, object = list(rep(NA_character_, nrow(author)))))}

          author <- author %>%
            dplyr::mutate(author_aff = paste0(LastName, " ", Initials, " [", AffiliationInfo.Affiliation, "]"),
                          author = paste0(LastName, " ", Initials)) %>%
            dplyr::select(author, author_aff) %>%
            dplyr::mutate_all(function(x){ifelse(grepl("NA NA",x)==T, NA_character_, x)}) %>%
            dplyr::summarise(author_n = n(),
                             author_list = paste(author, collapse = "; "),
                             author_list_aff = paste(author_aff, collapse = "; ")) %>%
            dplyr::mutate(author_n = ifelse(author_list=="NA", 0, author_n),
                          author_list = ifelse(author_list=="NA", NA, author_list),
                          author_list_aff = ifelse(author_list_aff=="NA", NA, author_list_aff))}


        if(nrow(dplyr::filter(author_raw, collective==T))>0){
          author_group <- author_raw %>%
            dplyr::filter(collective==T) %>%
            dplyr::select(n, value) %>%
            dplyr::mutate(name = purrr::map(value, function(x){names(x)})) %>%
            tidyr::unnest(cols = c(value, name)) %>% dplyr::mutate(value = unlist(value)) %>%
            dplyr::filter(name %in% c("CollectiveName")) %>%
            dplyr::group_by(n, name) %>%
            dplyr::summarise(author_group = paste(value, collapse = "; ")) %>%
            dplyr::ungroup() %>% dplyr::select(author_group)}

        author <- dplyr::bind_cols(dplyr::select(author,- dplyr::contains("author_group")), author_group)
        author_raw <- NULL}

      }

    collaborator <- NULL
    if(var_collaborator==T){

      collaborator <- dplyr::bind_cols("collab_n" = 0, "collab_list" = NA_character_, "collab_list_aff" = NA_character_)

      if(is.null(xml_pubmed$MedlineCitation$InvestigatorList)==F){

        collaborator <- tibble::enframe(xml_pubmed$MedlineCitation$InvestigatorList) %>%
          dplyr::mutate(n = 1:n()) %>%
          dplyr::select(n, value) %>%
          dplyr::mutate(name = purrr::map(value, function(x){names(x)})) %>%
          tidyr::unnest(cols = c(value, name)) %>%
          dplyr::mutate(name2 = purrr::map(value, function(x){names(x)})) %>%
          dplyr::mutate(name2 = purrr::map(name2, function(x){ifelse(is.null(x)==T, NA, x) %>% as.character()})) %>%
          tidyr::unnest(c(value, name2)) %>% dplyr::mutate(value = unlist(value)) %>%
          dplyr::filter(name %in% c("LastName", "Initials", "AffiliationInfo.Affiliation")) %>%
          dplyr::group_by(n, name) %>%
          dplyr::summarise(value = paste(value, collapse = "; ")) %>%
          dplyr::ungroup() %>%
          dplyr::mutate(across(everything(), function(x){as.character(x)})) %>%
          tidyr::pivot_wider(id_cols= n, names_from = name, values_from = value)

        if(ncol(collaborator)<4){
          if(nrow(collaborator)==0){collaborator <- tibble::tibble(n = NA)}

          collaborator <- tibble::tibble(LastName = rep(NA_character_, nrow(collaborator)),
                                         Initials = rep(NA_character_, nrow(collaborator)),
                                         AffiliationInfo.Affiliation = rep(NA_character_, nrow(collaborator))) %>%
            dplyr::select(names(.)[! names(.) %in% names(collaborator)]) %>%
            dplyr::bind_cols(collaborator)}


        collaborator <- collaborator %>%
          dplyr::mutate(collab_aff = paste0(LastName, " ", Initials, " [", AffiliationInfo.Affiliation, "]"),
                        collab = paste0(LastName, " ", Initials)) %>%
          dplyr::select(collab, collab_aff) %>%
          dplyr::summarise(collab_n = n(),
                           collab_list = paste(collab, collapse = "; "),
                           collab_list_aff = paste(collab_aff, collapse = "; ")) %>%
          dplyr::mutate(collab_n = ifelse(collab_list=="NA", 0, collab_n),
                        collab_list = ifelse(collab_list=="NA", NA, collab_list),
                        collab_list_aff = ifelse(collab_list_aff=="NA", NA, collab_list_aff))}}

    metadata <- NULL
    if(var_metadata == T){

      status <- tibble::tibble(status = NA_character_)
      if(is.null(xml_pubmed$PubmedData$PublicationStatus)==F){
        status <- tibble::enframe(unlist(xml_pubmed$PubmedData$PublicationStatus)) %>%
          dplyr::summarise(status = paste(value, collapse = ", "))}

      type <- tibble::tibble(type = NA_character_)
      if(is.null(xml_pubmed$MedlineCitation$Article$PublicationTypeList)==F){
        type <- tibble::enframe(unlist(xml_pubmed$MedlineCitation$Article$PublicationTypeList)) %>%
          dplyr::summarise(type = paste(value, collapse = ", "))}

      date_publish <- tibble::tibble(date_publish = NA)
      if(is.null(xml_pubmed$MedlineCitation$Article$ArticleDate)==F){
        date_publish <- tibble::enframe(unlist(xml_pubmed$MedlineCitation$Article$ArticleDate)) %>%
          dplyr::select("time" = name, value) %>%
          dplyr::mutate(across(everything(), function(x){as.character(x)})) %>%
          tidyr::pivot_wider(names_from = "time",  values_from = "value") %>%
          dplyr::mutate(date_publish = lubridate::as_date(paste0(Year, "-", Month, "-", Day))) %>%
          dplyr::select(date_publish)}

      metadata <- dplyr::bind_cols(type, status, date_publish)}

    history <- NULL
    if(var_history==T){

      history_names <- paste0("history_", c("received", "revised", "accepted", "entrez", "pubmed", "medline"))

      history <- history_names %>% purrr::map_dfc(setNames, object = list(NA)) %>% dplyr::mutate_all(lubridate::as_date)

      if(is.null(xml_pubmed$PubmedData$History)==F){
        history <- tibble::enframe(unlist(lapply(xml_pubmed$PubmedData$History, attributes)),
                                   value = "time_unit") %>%
          dplyr::mutate(type = ifelse(name == "PubMedPubDate.PubStatus", paste0("history_", time_unit), NA)) %>%
          dplyr::mutate(type = zoo::na.locf(type, fromLast=T)) %>%
          dplyr::filter(name!="PubMedPubDate.PubStatus") %>%
          dplyr::select(-name) %>%
          dplyr::bind_cols(tibble::enframe(unlist(xml_pubmed$PubmedData$History), name = NULL, value = "time_value")) %>%
          dplyr::mutate(across(everything(), function(x){as.character(x)})) %>%
          tidyr::pivot_wider(id_col = "type", names_from = "time_unit",  values_from = "time_value") %>%
          dplyr::mutate(history = lubridate::as_date(paste0(Year, "-", Month, "-", Day))) %>%
          dplyr::select(type, "date" = history) %>%
          dplyr::mutate(across(everything(), function(x){as.character(x)})) %>%
          tidyr::pivot_wider(names_from = "type",  values_from = "date")

        if(rlang::is_empty(history_names[! history_names %in% names(history)])==F){

          history <- history %>%
            dplyr::bind_cols(history_names[! history_names %in% names(history)] %>%
                               purrr::map_dfc(setNames, object = list(NA)) %>% dplyr::mutate_all(lubridate::as_date)) %>%
            dplyr::select(all_of(history_names))}}}

    abstract <- NULL
    if(var_abstract==T){
      abstract <- tibble::tibble(abstract = NA_character_)

      if(is.null(xml_pubmed$MedlineCitation$Article$Abstract)==F){

        abstract_all <- NULL;abstract_all_label <- NULL;abstract_all_content <- NULL
        abstract_all_label <- tibble::enframe(unlist(lapply(xml_pubmed$MedlineCitation$Article$Abstract, attributes)),
                                              value = "abstract_label")

        abstract_all_content <- tibble::enframe(unlist(xml_pubmed$MedlineCitation$Article$Abstract),
                                                value = "abstract_text") %>%
          dplyr::filter(! name %in% c("CopyrightInformation", "AbstractText.sub")) %>%
          dplyr::select(-name)

        name= NULL
        if(nrow(abstract_all_label)!=0){
          abstract_all_label <- abstract_all_label %>%
            dplyr::filter(name=="AbstractText.Label") %>%
            dplyr::select(-name) %>%
            dplyr::mutate(abstract_label = zoo::na.locf(ifelse(abstract_label %in% c("", "sub"), NA, abstract_label), fromLast=T))}

        if(nrow(abstract_all_label)!=nrow(abstract_all_content)){
          abstract <- tibble::tibble("abstract" = paste(dplyr::pull(abstract_all_content, abstract_text), collapse="\n\n"))
        }else{
          abstract_all <- dplyr::bind_cols(abstract_all_label, abstract_all_content)

        if(nrow(abstract_all_label)!=0){
          abstract <- abstract_all %>%
            dplyr::filter(stringr::str_detect(tolower(abstract_label), "fund", negate = T)) %>%
            dplyr::mutate(abstract_label = stringr::str_to_sentence(abstract_label)) %>%
            dplyr::mutate(abstract = paste0(abstract_label, ": ", abstract_text)) %>%
            dplyr::summarise(abstract = paste(abstract, collapse = "\n\n"))}else{
              abstract <- abstract_all %>%
                dplyr::filter(stringr::str_detect(tolower(abstract_label), "fund", negate = T)) %>%
                dplyr::mutate(abstract_label = stringr::str_to_sentence(abstract_label)) %>%
                dplyr::mutate(abstract = paste0("Abstract: ", abstract_label)) %>%
                dplyr::select(abstract)}}

        if(is.null(abstract)==F){if(nrow(abstract)==0){abstract <- NULL} }}}


    registry <- NULL
    if(var_registry == T){
      registry <- tibble::tibble(registry_num = NA_character_, registry_name = NA_character_)

      if(is.null(xml_pubmed$MedlineCitation$Article$DataBankList)==F){

        registry <- tibble::enframe(unlist(xml_pubmed$MedlineCitation$Article$DataBankList)) %>%
          dplyr::mutate(across(everything(), function(x){as.character(x)})) %>%
          tidyr::pivot_wider() %>%
          dplyr::rename(registry_name = "DataBank.DataBankName", registry_num = "DataBank.AccessionNumberList.AccessionNumber") %>%
          dplyr::summarise(registry_num = paste(registry_num, collapse = ", "),
                           registry_name = paste(registry_name, collapse = ", "))}}

    output <- dplyr::bind_cols(id, journal, author, collaborator, metadata, history, registry, abstract) %>%
      mutate(across(everything(), as.character))

    return(output)}



  # Clean pmid----------------
  check_pmid <- pmid %>%
    tibble::enframe(name = NULL, value= "original") %>%
    dplyr::mutate(numeric = as.numeric(original)) %>%

    # ensure no NA/ non-numeric
    dplyr::mutate(check = dplyr::case_when(is.na(numeric)==T ~"fail",
                                           purrr::map_lgl(numeric, is.numeric)==F ~ "fail",
                                           TRUE ~ "pass"))

  pmid <- check_pmid %>% dplyr::filter(check == "pass") %>% dplyr::pull(numeric) %>% as.character()



  # Function to extract PMID information from pubmed XML
  final <- pmid %>%
    tibble::enframe(name = NULL, value = "pmid") %>%
    dplyr::mutate(n = 1:n()) %>%
    dplyr::mutate(chunk = cut(n, breaks = seq(0, length(pmid)+n_chunk, by =n_chunk))) %>%
    dplyr::group_split(chunk) %>%

    # Across each chunk of X patients
    furrr::future_map2_dfr(., seq_along(1:length(.)), function(a, b){

      print(paste("Chunk", b))

      # Pull XML from Pubmed

      RCurl::getURL(paste0("https://eutils.ncbi.nlm.nih.gov/entrez/eutils/efetch.fcgi?db=pubmed&id=",
                           paste(a$pmid, collapse = "+OR+"),
                           "&retmode=xml"), .encoding = "Windows-1252") %>%

        xml2::as_xml_document() %>% xml2::xml_find_all("PubmedArticle") %>%

        # extract information from XML for each record
        furrr::future_map2_dfr(., seq_along(1:length(.)), function(d, e){

          print(e)

           out <- suppressMessages(extract_xml(d))

          return(out)})})  %>%
    group_by(across(c(-author_group))) %>%
    dplyr::summarise(author_group = paste0(author_group, collapse = "; ")) %>%
    dplyr::ungroup()

  return(final)}
