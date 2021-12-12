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
                   "volume", "issue", "page", "published", "published-print","published-online", "is-referenced-by-count")

  if(length(doi)>1){
    out_crossref <- rcrossref::cr_cn(dois = doi, format = "citeproc-json") %>%
      purrr::map_df(function(x){

        x <- x[which(names(x) %in% extract_var)]

        if(is.null(x$`published`)==F){
          x$year <- ifelse(length(x$`published`$`date-parts`)>1,
                           x$`published`$`date-parts`[1,1],
                           x$`published`)

          if(length(x$`published`$`date-parts`)==3){
            x$date_publish <- x$`published`$`date-parts` %>%
              tibble::as_tibble() %>%
              dplyr::mutate(date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
              pull(date_publish)}
          if(length(x$`published`$`date-parts`)==2){
            x$date_publish <- x$`published`$`date-parts` %>%
              tibble::as_tibble() %>%
              dplyr::mutate(V3 = 1,
                            date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
              pull(date_publish)}
          if(length(x$`published`$`date-parts`)==1){
            x$date_publish <- NA}}

        if(is.null(x$`published-online`)==F){
          x$year <- ifelse(length(x$`published-online`$`date-parts`)>1,
                           x$`published-online`$`date-parts`[1,1],
                           x$`published-online`)

          if(length(x$`published-online`$`date-parts`)==3){
            x$date_publish <- x$`published-online`$`date-parts` %>%
              tibble::as_tibble() %>%
              dplyr::mutate(date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
              pull(date_publish)}
          if(length(x$`published-online`$`date-parts`)==2){
            x$date_publish <- x$`published-online`$`date-parts` %>%
              tibble::as_tibble() %>%
              dplyr::mutate(V3 = 1,
                            date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
              pull(date_publish)}
          if(length(x$`published-online`$`date-parts`)==1){
            x$date_publish <- NA}}

        if(is.null(x$`published-print`)==F){
          x$year <- ifelse(length(x$`published-print`$`date-parts`)>1,
                           x$`published-print`$`date-parts`[1,1],
                           x$`published-print`)

          if(length(x$`published-print`$`date-parts`)==3){
            x$date_publish <- x$`published-print`$`date-parts` %>%
              tibble::as_tibble() %>%
              dplyr::mutate(date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
              pull(date_publish)}
          if(length(x$`published-print`$`date-parts`)==2){
            x$date_publish <- x$`published-print`$`date-parts` %>%
              tibble::as_tibble() %>%
              dplyr::mutate(V3 = 1,
                            date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
              pull(date_publish)}
          if(length(x$`published-print`$`date-parts`)==1){
            x$date_publish <- NA}}


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
                        "issue" = issue, "pages" = page, "cite_cr" = `is-referenced-by-count`, date_publish)
        return(y)})}else{
        x <- rcrossref::cr_cn(dois = doi, format = "citeproc-json")
        x <- x[which(names(x) %in% extract_var)]

        if(is.null(x$`published`)==F){
          x$year <- ifelse(length(x$`published`$`date-parts`)>1,
                           x$`published`$`date-parts`[1,1],
                           x$`published`)

          if(length(x$`published`$`date-parts`)==3){
            x$date_publish <- x$`published`$`date-parts` %>%
              tibble::as_tibble() %>%
              dplyr::mutate(date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
              pull(date_publish)}
          if(length(x$`published`$`date-parts`)==2){
            x$date_publish <- x$`published`$`date-parts` %>%
              tibble::as_tibble() %>%
              dplyr::mutate(V3 = 1,
                            date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
              pull(date_publish)}
          if(length(x$`published`$`date-parts`)==1){
            x$date_publish <- NA}}

        if(is.null(x$`published-online`)==F){
          x$year <- ifelse(length(x$`published-online`$`date-parts`)>1,
                           x$`published-online`$`date-parts`[1,1],
                           x$`published-online`)

          if(length(x$`published-online`$`date-parts`)==3){
          x$date_publish <- x$`published-online`$`date-parts` %>%
            tibble::as_tibble() %>%
            dplyr::mutate(date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
            pull(date_publish)}
          if(length(x$`published-online`$`date-parts`)==2){
            x$date_publish <- x$`published-online`$`date-parts` %>%
              tibble::as_tibble() %>%
              dplyr::mutate(V3 = 1,
                            date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
              pull(date_publish)}
          if(length(x$`published-online`$`date-parts`)==1){
            x$date_publish <- NA}}

        if(is.null(x$`published-print`)==F){
          x$year <- ifelse(length(x$`published-print`$`date-parts`)>1,
                           x$`published-print`$`date-parts`[1,1],
                           x$`published-print`)

          if(length(x$`published-print`$`date-parts`)==3){
            x$date_publish <- x$`published-print`$`date-parts` %>%
              tibble::as_tibble() %>%
              dplyr::mutate(date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
              pull(date_publish)}
          if(length(x$`published-print`$`date-parts`)==2){
            x$date_publish <- x$`published-print`$`date-parts` %>%
              tibble::as_tibble() %>%
              dplyr::mutate(V3 = 1,
                            date_publish = paste0(V1, "/", V2, "/", V3) %>% lubridate::as_date()) %>%
              pull(date_publish)}
          if(length(x$`published-print`$`date-parts`)==1){
            x$date_publish <- NA}}

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
                        "journal_issn" = ISSN,"title" = title, "year" = year, "volume" = volume,date_publish,
                        "issue" = issue, "pages" = page, "cite_cr" = `is-referenced-by-count`)}


  out_crossref <- out_crossref %>% dplyr::mutate_all(function(x){x <- ifelse(x=="", NA, x)}) %>%
    dplyr::mutate(doi = tolower(doi)) %>%
    dplyr::select(doi, title, year, journal_abbr,volume,issue,pages,cite_cr, everything())

  if(get_authors==TRUE){crossref_auth <- impactr::extract_doi_auth(doi)

  out_crossref <- dplyr::left_join(out_crossref, crossref_auth, by=c("doi")) %>%
    dplyr::mutate(collab_n = NA, collab_list = NA) %>%
    dplyr::rename("author_n" = auth_n, author_list = auth_list)}

  if(get_altmetric==TRUE){
    out_crossref <- out_crossref %>%
      dplyr::mutate(altmetric = impactr::score_alm(doi))}

  if(get_impact==TRUE){out_crossref <- impactr::extract_impact_factor(out_crossref, var_id="doi") %>%
    dplyr::rename("journal_nlm" = "nlmid")}

  if("journal_full.y" %in% names(out_crossref)){
    out_crossref<- out_crossref %>%
      dplyr::rename("journal_full" = journal_full.x, "journal_full2" = journal_full.y)}

  out_crossref <- out_crossref %>%
    dplyr::mutate_all(function(x){x <- ifelse(x=="", NA, x)}) %>%
    tibble::as_tibble() %>%
    dplyr::mutate(pmid = NA, pmc = NA, type = NA, status = NA,  abstract = NA) %>%

    dplyr::select(pmid, doi, pmc, title,
                  any_of(c("author_n", "author_list", "author_group", "collab_n", "collab_list")),
                  any_of(c("journal_nlm", "journal_if")), journal_issn, journal_full, journal_abbr,
                  "journal_vol" = volume, journal_issue = issue, journal_pages = pages,
                  type, status, date_publish, abstract, year, any_of("altmetric"))

  return(out_crossref)}
