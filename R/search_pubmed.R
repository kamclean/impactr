# search_pubmed------------------------------
# Documentation
#' Perform a focused pubmed search to identify the PMID associated with specified authors or registry identifiers.
#' @description Search pubmed to identify PMID associated with specified authors or registry identifiers.
#' @param search_type Type of search desired (either "author" or "registry_id").
#' @param search_list Vector of search terms (either author last name and initial, or registry identifers).
#' @param date_min String of a date in "Year-Month-Day" format to provide  a lower limit to search within (default = NULL).
#' @param date_max String of a date in "Year-Month-Day" format to provide an upper limit to search within (default = current date).
#' @param keywords Vector of keywords or patterns that are required to be present for inclusion (default = NULL).
#' @return Vector of pubmed identifiers (PMID)
#' @import magrittr
#' @import dplyr
#' @import RCurl
#' @import lubridate
#' @import tibble
#' @import jsonlite
#' @import stringr
#' @export

search_pubmed <- function(search_type = "author", search_list, date_min=NULL, date_max=Sys.Date(),keywords = NULL){
  # The E-utilities In-Depth: Parameters, Syntax and More (https://www.ncbi.nlm.nih.gov/books/NBK25499/)
  require(dplyr); require(lubridate); require(RCurl); require(jsonlite); require(stringr)

  url_search <- "https://eutils.ncbi.nlm.nih.gov/entrez/eutils/esearch.fcgi?db=pubmed&esearch.fcgi?db=pubmed"

  return_format = "&retmode=json&retmax=100000"

  if(is.null(keywords)==F){keywords <- keywords %>%
    stringr::str_replace(" AND ", "+AND+") %>%
    stringr::str_replace(" OR ", "+OR+") %>%
    stringr::str_replace(" NOT ", "+NOT+") %>%
    stringr::str_replace("\\?", "%3F") %>%
    paste0("(", ., ")") %>%  paste(collapse = "+OR+") %>% paste0("AND(",.,")")}

  search_list <- tolower(search_list)
  search_list <- unique(stringr::str_extract_all(search_list, "^[a-z]+ [a-z]")) %>% unlist()

  if(search_type == "author"){search_list_formatted <- gsub(" ",
                                                            "%20",
                                                            paste0("&term=(",paste(search_list, collapse = '[author]+OR+'), '[author])'))}



  if(search_type == "registry_id"){search_list_formatted <- paste0("&term=",
                                                                paste(paste0(search_list,"%5BSecondary%20Source%20ID%5D"), collapse = "+OR+"))}

  limit_date = NULL
  if(is.null(date_min)==F){date_min <- paste0("&mindate=", format(lubridate::as_date(date_min), "%Y/%m/%d"))}
  if(is.null(date_max)==F){date_max <- paste0("&maxdate=", format(lubridate::as_date(date_max), "%Y/%m/%d"))}
  limit_date = paste0("&datetype=pdat", date_min, date_max)

  search <- RCurl::getURL(paste0(url_search, limit_date, search_list_formatted, keywords, return_format)) %>%
    jsonlite::fromJSON()

  return(search$esearchresult$idlist)}
