# extract_doi_auth--------------------------------
# Documentation
#' Extract publication data on authorship using doi / crossref
#' @description Extract publication data on authorship using doi / rcrossref
#' @param doi Vector of Digital Object Identifiers (DOI)
#' @return Dataframe authorship data for each DOI.
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @importFrom rcrossref cr_cn cr_works
#' @importFrom rAltmetric altmetric_data altmetrics
#' @importFrom purrr map_df
#' @export

# Function-------------------------------
extract_doi_auth <- function(doi){
  "%ni%" <- Negate("%in%")

  extract_doi_auth1 <- function(doi){
    author <- rcrossref::cr_works(doi = doi)$data$author[[1]]
    if(is.null(author)==T){author2 <- tibble::tibble(author_group = NA, auth_n = NA, auth_list = NA)}else{
      if("given" %in% names(author)){author2 <- author %>%
        dplyr::mutate(initials = paste0(substr(stringr::str_split_fixed(given, " ", 3)[,1],1,1),
                                        substr(stringr::str_split_fixed(given, " ", 3)[,2],1,1),
                                        substr(stringr::str_split_fixed(given, " ", 3)[,3],1,1))) %>%
        dplyr::mutate(name = paste0(family, " ", initials)) %>%
        dplyr::summarise(author_group = NA,
                         auth_n = n(),
                         auth_list =  paste(name, collapse="; "))}else{author2 <- tibble::tibble(author_group = author$name,
                                                                                                 auth_n = NA, auth_list = NA)}}
    return(author2)}

  doi <- doi[which(doi %ni% NA)] # ensure no NA

  df_auth <- doi %>%
    purrr::map_df(function(x){extract_doi_auth1(x)}) %>%
    dplyr::mutate(doi = tolower(doi)) %>%
    dplyr::mutate(auth_list = gsub("NA , ", "", auth_list)) %>%
    dplyr::mutate(auth_list = gsub(", NA", "", auth_list)) %>%
    dplyr::select(doi, author_group, auth_n, auth_list)

  return(df_auth)}
