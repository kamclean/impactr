# extract_doi--------------------------------
# Documentation
#' Extract publication data using doi / crossref
#' @description Extract publication data using doi / rcrossref
#' @param doi Vector of Digital Object Identifiers (DOI)
#' @param get_authors Extract authorship data (default = TRUE)
#' @param get_altmetric Extract overall altmetric score data (default = TRUE)
#' @param get_impact Extract journal impact factor and metrics (default = TRUE)
#' @return Dataframe of essential publication data
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @importFrom rcrossref cr_cn
#' @importFrom rAltmetric altmetric_data altmetrics
#' @importFrom purrr map_df
#' @export

# Function-------------------------------
extract_doi <- function(doi, get_authors = TRUE, get_altmetric = TRUE, get_impact=TRUE){

  "%ni%" <- Negate("%in%")

  doi <- doi[which(doi %ni% c(NA, ""))]

  extract_var <- c("DOI", "title","container-title", "container-title-short", "ISSN",
                   "volume", "issue", "page", "published-print","published-online", "is-referenced-by-count")

  if(length(doi)>1){
    out_crossref <- rcrossref::cr_cn(dois = doi, format = "citeproc-json") %>%
      purrr::map_df(function(x){

        x <- x[which(names(x) %in% extract_var)]

        if(is.null(x$`published-online`)==F){
          x$year <- ifelse(length(x$`published-online`$`date-parts`)>1,
                           x$`published-online`$`date-parts`[1,1],
                           x$`published-online`)}

        if(is.null(x$`published-print`)==F){
          x$year <- ifelse(length(x$`published-print`$`date-parts`)>1,
                           x$`published-print`$`date-parts`[1,1],
                           x$`published-print`)}

        x$ISSN <-  x$ISSN[1]
        x$page <- paste(unique(x$page), collapse="-")

        df_na <- NULL
        if(length(extract_var[which(extract_var %ni% names(x))])>0){
          df_na <- rbind.data.frame(rep(NA, length(extract_var[which(extract_var %ni% names(x))])))
          colnames(df_na) <- extract_var[which(extract_var %ni% names(x))]}

        y <- tibble::as_tibble(x)

        if(is.null(df_na)==F){y <- cbind.data.frame(y, df_na)}

        y <- y %>%
          dplyr::select("doi" = "DOI", "journal_abbr" = `container-title-short`,"journal_full" = `container-title`,
                        "journal_issn" = ISSN,"title" = title, "year" = year, "volume" = volume,
                        "issue" = issue, "pages" = page, "cite_cr" = `is-referenced-by-count`)
        return(y)})}else{
        x <- rcrossref::cr_cn(dois = doi, format = "citeproc-json")
        x <- x[which(names(x) %in% extract_var)]

        if(is.null(x$`published-online`)==F){
          x$year <- ifelse(length(x$`published-online`$`date-parts`)>1,
                           x$`published-online`$`date-parts`[1,1],
                           x$`published-online`)}

        if(is.null(x$`published-print`)==F){
          x$year <- ifelse(length(x$`published-print`$`date-parts`)>1,
                           x$`published-print`$`date-parts`[1,1],
                           x$`published-print`)}

        x$ISSN <- x$ISSN[1]
        x$page <- paste(x$page, collapse="-")

        df_na <- NULL
        if(length(extract_var[which(extract_var %ni% names(x))])>0){
          df_na <- rbind.data.frame(rep(NA, length(extract_var[which(extract_var %ni% names(x))])))
          colnames(df_na) <- extract_var[which(extract_var %ni% names(x))]}

        out_crossref <- tibble::as_tibble(x)

        if(is.null(df_na)==F){out_crossref <- cbind.data.frame(out_crossref, df_na)}

        out_crossref <- out_crossref %>%
          dplyr::select("doi" = "DOI", "journal_abbr" = `container-title-short`,"journal_full" = `container-title`,
                        "journal_issn" = ISSN,"title" = title, "year" = year, "volume" = volume,
                        "issue" = issue, "pages" = page, "cite_cr" = `is-referenced-by-count`)}


  out_crossref <- out_crossref %>% dplyr::mutate_all(function(x){x <- ifelse(x=="", NA, x)}) %>%
    dplyr::mutate(doi = tolower(doi)) %>%
    dplyr::select(doi, title, year, journal_abbr,volume,issue,pages,cite_cr, everything())

  if(get_authors==TRUE){crossref_auth <- impactr::extract_doi_auth(doi)

  out_crossref <- dplyr::left_join(out_crossref, crossref_auth, by=c("doi")) %>%
    dplyr::select(doi, author_group, title:cite_cr, auth_n, "author" = auth_list, everything())}


  if(get_altmetric==TRUE){
    out_crossref <- out_crossref %>%
      dplyr::mutate(altmetric = impactr::score_alm(doi)) %>%
      dplyr::select(doi:cite_cr, altmetric, everything())}

  if(get_impact==TRUE){out_crossref <- impactr::extract_impact_factor(out_crossref, var_id="doi")}

  out_crossref <- out_crossref %>%
    dplyr::mutate_all(function(x){x <- ifelse(x=="", NA, x)}) %>%
    tibble::as_tibble()

  if("journal_full.y" %in% names(out_crossref)){
    out_crossref<- out_crossref %>%
      dplyr::rename("journal_full" = journal_full.x, "journal_full2" = journal_full.y)}

  return(out_crossref)}
