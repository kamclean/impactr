# score_alm--------------------------------
# Documentation
#' Extract overall almetric score for a publication
#' @description Extract overall almetric score for a publication
#' @param id_list Vector of unique Digital Object Identifiers (DOI) and/or PMID
#' @return Vector of overall almetric scores (or NA if not available)
#' @import purrr
#' @import tibble
#' @import dplyr
#' @importFrom rAltmetric altmetric_data altmetrics
#' @export

# Function-------------------------------
score_alm <- function(id_list){
  require(dplyr);require(tibble);require(purrr); require(rAltmetric)

  # Extract data
  id_class <- suppressWarnings(as.character(id_list) %>%
                                 tibble::enframe(name = "n", value = "id") %>%
                                 # https://www.crossref.org/blog/dois-and-matching-regular-expressions/
                                 dplyr::mutate(id_type = dplyr::case_when(stringr::str_detect(id, "^10\\.\\d{4,9}/")==T ~  "doi",
                                                                          nchar(id)==8&is.numeric(as.numeric(id))==T ~ "pmid",
                                                                          TRUE ~ "invalid")))

  score <- id_class %>%
    dplyr::filter(id_type %in% c("pmid", "doi")) %>%
    dplyr::mutate(request = paste0("https://api.altmetric.com/v1/", id_type, "/",id)) %>%
    dplyr::mutate(response = purrr::map(request, function(x){httr::GET(x)}),
                  response404 = purrr::map_chr(response, function(x){httr::status_code(x) == 404})) %>%
    dplyr::filter(response404==FALSE) %>%
    dplyr::select(-request, -response404,-n,-id_type) %>%
    dplyr::mutate(purrr::map_df(response, function(x){
      jsonlite::fromJSON(httr::content(x, as = "text"), flatten = TRUE) %>%
        rlist::list.flatten() %>%
        tibble::enframe() %>%
        tidyr::pivot_wider(everything())})) %>%
    dplyr::select(-response) %>%
    dplyr::left_join(id_class %>% select(id),., by = "id") %>%
    dplyr::select(id, score) %>%
    tidyr::unnest(score,keep_empty = T) %>%
    pull(score)

  return(score)}
