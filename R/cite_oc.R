# cite_oc------------------------------
# Documentation
#' Derive citation data from the Open Citations database.
#' @description Derive citation data from the Open Citations database (https://opencitations.net/). Note this is too sparce a resource to be of practical use at present.
#' @param id_list Vector of pmid / doi
#' @return Nested dataframe of (1) All referencing publications (2) Total citations recorded (3) Citations over time
#' @import magrittr
#' @import dplyr
#' @import purrr
#' @import lubridate
#' @import tibble
#' @import citecorp
#' @export

# devtools::install_github("ropenscilabs/citecorp")
cite_oc <- function(id_list){
  require(magrittr);require(tibble);require(stringr);require(purrr);require(dplyr)
  require(lubridate);require(citecorp)


  id_class <- as.character(id_list) %>%
    tibble::enframe(name = "n", value = "id") %>%
    # https://www.crossref.org/blog/dois-and-matching-regular-expressions/
    dplyr::mutate(id_type = dplyr::case_when(stringr::str_detect(id, "^10\\.\\d{4,9}/")==T ~  "doi",
                                             nchar(id)==8&is.numeric(as.numeric(id))==T ~ "pmid",
                                             TRUE ~ "invalid"))


  id_class <- id_class %>%
      dplyr::filter(id_type=="pmid") %>%
      dplyr::mutate(id_doi = rcrossref::id_converter(id, type="pmid")$records$doi) %>%
      dplyr::right_join(id_class, by = c("n", "id", "id_type")) %>%
      dplyr::mutate(id_doi = dplyr::if_else(id_type=="doi",id,id_doi))


  doi_data <- id_class %>% dplyr::filter(is.na(id_doi)==F)


  oc_data <-  doi_data %>%
    dplyr::pull(id_doi) %>%
    purrr::map_df(function(x){tryCatch(citecorp::oc_coci_cites(doi = x), error=function(e) tibble::tibble())}) %>%
    dplyr::select("doi" = cited, "cite_doi" = citing, "cite_date" = creation, sc_auth = "author_sc", sc_journal = "journal_sc") %>%
    dplyr::mutate(cite_date = lubridate::as_date(ifelse(nchar(cite_date)==4,
                                                        paste0(cite_date, "-01-01"),
                                                        ifelse(nchar(cite_date)==7,
                                                               paste0(cite_date, "-01"),
                                                               cite_date)))) %>%
    dplyr::mutate(cite_year = lubridate::year(cite_date))

  cite_time <- oc_data %>%
    dplyr::mutate(cite_year = factor(cite_year, levels=unique(sort(cite_year)))) %>%
    dplyr::group_by(doi, cite_year,.drop = FALSE) %>%
    dplyr::summarise(cite_n = n()) %>%
    dplyr::group_by(doi) %>%
    dplyr::mutate(cite_cumsum = cumsum(cite_n)) %>%
    dplyr::ungroup()

  cite_total <- oc_data %>%
    dplyr::group_by(doi) %>%
    dplyr::summarise(total = n()) %>%
    dplyr::ungroup() %>%
    dplyr::right_join(doi_data, by=c("doi" ="id_doi")) %>%
    dplyr::select(doi, "cite" = total)

  out <- list("full" = oc_data, "total" = cite_total, "year" = cite_time)

return(out)}
