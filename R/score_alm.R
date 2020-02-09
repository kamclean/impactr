# score_alm--------------------------------
# Documentation
#' Extract overall almetric score for a publication
#' @description Extract publication data using RISmed / pmid
#' @param doi Vector of unique Digital Object Identifiers (DOI)
#' @return Vector of overall almetric scores (or NA if not available)
#' @import dplyr
#' @importFrom rAltmetric altmetric_data altmetrics
#' @export

# Function-------------------------------
score_alm <- function(doi){unlist(lapply(doi, function(x){tryCatch(rAltmetric::altmetric_data(rAltmetric::altmetrics(doi = x))$score, error=function(e){NA})}))}


