# cite_dim--------------------------------
# Documentation
#' Derive citation data from the Dimentions database (https://app.dimensions.ai/discover/publication)
#' @description Derive citation data from the Dimentions database
#' @param id_list Vector of pmid / doi
#' @return Dataframe
#' @import magrittr
#' @import dplyr
#' @import purrr
#' @import tibble
#' @importFrom xml2 read_html
#' @importFrom rvest html_text
#' @importFrom jsonlite fromJSON
#' @importFrom rcrossref id_converter
#' @export

# rcr_dim = Relative Citation Ratio (RCR)
# Indicates the relative citation performance of an article when comparing its citation rate to that of
# other articles in its area of research. A value of more than 1.0 shows a citation rate above average.
# The article’s area of research is defined by the articles that have been cited alongside it.
#  The RCR is calculated for all PubMed publications which are at least 2 years old.

# fcr = Field Citation Ratio (FCR)
# An article-level metric that indicates the relative citation performance of an article, when compared to
# similarly-aged articles in its subject area. A value of more than 1.0 indicates higher than average citation,
# when defined by FoR Subject Code, publishing year and age. The FCR is calculated for all publications
# in Dimensions which are at least 2 years old and were published in 2000 or later

cite_dim <- function(id_list){
  require(dplyr)

  # Classify ID supplied
  id_class <- id_list %>%
    tibble::enframe(name = "n", value = "id") %>%
    # https://www.crossref.org/blog/dois-and-matching-regular-expressions/
    dplyr::mutate(id_type = suppressWarnings(dplyr::if_else(grepl("^10\\.\\d{4,9}/", id)==T,
                                                         "doi",
                                                         if_else(nchar(id)==8&is.numeric(as.numeric(id))==T,
                                                         "pmid", "invalid"))))

  # Create Dimentions call
  call <- id_class %>%
    dplyr::mutate(call = paste0("https://metrics-api.dimensions.ai/",id_type, "/",id)) %>%
    dplyr::mutate(id = ifelse(id_type=="invalid", NA, id),
                  call = ifelse(id_type=="invalid", NA, call))  %>%
    dplyr::pull(call)

  # Check validity of Dimentions call (e.g. record avaliable)
  validity <- call %>%
    purrr::map_chr(function(x){y <- tryCatch(xml2::read_html(x), error=function(e) NA)

    if(grepl("xml_",class(y)[1])){y <- "valid"}else{y <- "invalid"}})

  # All ID
  id_class <- id_class %>%
    dplyr::mutate(id_call = validity,
                  call = call)

  # Only use valid ID
  output <- id_class %>%
    dplyr::filter(id_type!="invalid"&id_call!="invalid") %>%
    dplyr::pull(call) %>%
    purrr::map_df(function(x){xml2::read_html(x) %>%
        rvest::html_text() %>%
        jsonlite::fromJSON() %>%
        replace(., sapply(., is.null), NA) %>%
        tibble::as_tibble() %>%
        magrittr::set_colnames(c("id", colnames(.)[2:ncol(.)])) %>%
        dplyr::mutate(id = as.character(id)) %>%
        dplyr::select(-license)}) %>%
    dplyr::rename("cite" = times_cited, "cite_2y" = recent_citations,
           "rcr" = relative_citation_ratio, "fcr" = field_citation_ratio)

  # Output
  cite <- id_class %>%
    dplyr::left_join(output, by=c("id")) %>%
    dplyr::mutate(id_pmid = ifelse(id_type=="pmid", id, NA),
                  id_doi = ifelse(id_type=="doi", id, NA)) %>%
    dplyr::select(n:id_call, id_pmid, id_doi, cite:fcr)

  return(cite)}
