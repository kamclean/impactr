# cite_oc------------------------------
# Documentation
#' Derive citation data from the Open Citations database.
#' @description Derive citation data from the Open Citations database (https://opencitations.net/). Note this is too sparce a resource to be of practical use at present.
#' @param id Vector of doi (not pmid)
#' @return Nested dataframe of (1) All referencing publications (2) Total citations recorded (3) Citations over time
#' @import magrittr
#' @import dplyr
#' @import purrr
#' @import lubridate
#' @import tibble
#' @import citecorp
#' @importFrom lubridate as_date year
#' @export

# devtools::install_github("ropenscilabs/citecorp")
cite_oc <- function(list_doi){

  doi_data <- list_doi %>% tibble::enframe(name="n", value="doi") %>%
    dplyr::filter(is.na(doi)==F)

  oc_data <-  doi_data %>%
    dplyr::pull(doi) %>%
    purrr::map(function(x){tryCatch(citecorp::oc_coci_cites(doi = x), error=function(e) tibble::tibble())}) %>%
    dplyr::bind_rows() %>%
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
    dplyr::right_join(doi_data, by=c("doi")) %>%
    dplyr::select(doi, "cite" = total)

  out <- list("full" = oc_data, "total" = cite_total, "year" = cite_time)

return(out)}
