# cite_cr------------------------------
# Documentation
#' Derive citation data from the Crossref database via rcrossref
#' @description Derive citation data from the Crossref database
#' @param id Vector of pmid / doi
#' @return Dataframe
#' @import magrittr
#' @import dplyr
#' @import purrr
#' @import tibble
#' @importFrom rcrossref id_converter cr_citation_count
#' @export

cite_cr <- function(id){
  id_class <- id %>%
    tibble::enframe(name = "n", value = "id") %>%
    # https://www.crossref.org/blog/dois-and-matching-regular-expressions/
    dplyr::mutate(id_type = suppressWarnings(dplyr::if_else(grepl("^10\\.\\d{4,9}/", id)==T,
                                                            "doi",
                                                            if_else(nchar(id)==8&is.numeric(as.numeric(id))==T,
                                                                    "pmid", "invalid"))))
  data_doi <- NULL
  if("doi" %in% id_class$id_type){
    data_doi <- id_class %>%
      dplyr::filter(id_type=="doi") %>%
      dplyr::mutate(id_pmid = NA,
                    id_doi = id) %>%
      dplyr::mutate(cite = purrr::map_chr(id_doi, function(x){tryCatch(rcrossref::cr_citation_count(doi = x), error=function(e) NA) %>%
                          dplyr::pull(count) %>%
                          as.integer()}))}

  data_pmid <- NULL
  if("pmid" %in% id_class$id_type){
    data_pmid <- id_class %>%
      dplyr::filter(id_type=="pmid") %>%
      dplyr::mutate(id_pmid = id) %>%
      dplyr::mutate(id_doi = ifelse(is.null(rcrossref::id_converter(id_pmid, type="pmid")$records$doi)==T,NA,
                                    rcrossref::id_converter(id_pmid, type="pmid")$records$doi)) %>%
      dplyr::mutate(cite = as.integer(purrr::map_chr(id_doi,
                                                     function(x){tryCatch(rcrossref::cr_citation_count(doi = x), error=function(e) NA)})))}

  data_invalid <- NULL
  if("invalid" %in% id_class$id_type){
    data_invalid <- id_class %>%
      dplyr::filter(id_type=="invalid") %>%
      dplyr::mutate(id_pmid = NA, id_doi = NA, cite = NA)}

  cr_data <- dplyr::bind_rows(data_doi, data_pmid, data_invalid) %>%
    dplyr::arrange(n)

  return(cr_data)}
