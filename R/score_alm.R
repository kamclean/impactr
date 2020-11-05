# score_alm--------------------------------
# Documentation
#' Extract overall almetric score for a publication
#' @description Extract overall almetric score for a publication
#' @param id Vector of unique Digital Object Identifiers (DOI) and/or PMID
#' @return Vector of overall almetric scores (or NA if not available)
#' @import purrr
#' @import tibble
#' @import dplyr
#' @importFrom rAltmetric altmetric_data altmetrics
#' @export

# Function-------------------------------
score_alm <- function(id){
  require(dplyr);require(tibble);require(purrr); require(rAltmetric)

  id_class <- id %>%
    tibble::enframe(name = "n", value = "id") %>%
    # https://www.crossref.org/blog/dois-and-matching-regular-expressions/
    dplyr::mutate(id_type = suppressWarnings(dplyr::if_else(grepl("^10\\.\\d{4,9}/", id)==T,
                                                            "doi",
                                                            if_else(nchar(id)==8&is.numeric(as.numeric(id))==T,
                                                                    "pmid", "invalid"))))

  score <- id_class %>%
    dplyr::mutate(altmetric = ifelse(id_type == "doi", purrr::map_chr(id,
                                                                 function(x){tryCatch(rAltmetric::altmetric_data(rAltmetric::altmetrics(doi = x))$score, error=function(e){NA})}), NA),
                  altmetric = ifelse(id_type == "pmid", purrr::map_chr(id,
                                                                     function(x){tryCatch(rAltmetric::altmetric_data(rAltmetric::altmetrics(pmid = x))$score, error=function(e){NA})}), altmetric)) %>%
    dplyr::pull(altmetric)
    return(score)}
