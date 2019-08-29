# impact_cite_metric--------------------------------
# Documentation
#' Calculate several common citation metrics (H-Index, G-Index, M-Quotient).
#' @description Calculate several common citation metrics (H-Index, G-Index, M-Quotient).
#' @param n_citations Vector of citations (numerical variable).
#' @param year Vector of years or minimum year of publication (optional - required for M-Quotient)
#' @return Dataframe of citation metrics for data supplied (H-Index, G-Index, M-Quotient)
#' @export

# Function-------------------------------
impact_cite_metric(citations, year = ""){

  if(length(citations)==length(year)){df <- dplyr::bind_cols("n_cite" = citations,
                                                             "year" = as.numeric(year))}

  if(length(citations)!=length(year)){df <- dplyr::bind_cols("n_cite" = citations,
                                                             "year" = rep(min(as.numeric(year)),
                                                                          length(citations)))}
  if(year==""){df <- dplyr::bind_cols("n_cite" = citations,
                                      "year" = rep(NA,
                                                   length(citations)))}
  # https://datascienceplus.com/hindex-gindex-pubmed-rismed/
  out <- df %>%
    dplyr::select(year, n_cite) %>%
    dplyr::arrange(-n_cite) %>%
    dplyr::filter(is.na(n_cite)==F) %>%
    tibble::rowid_to_column(var = "id") %>%
    dplyr::mutate(gindex_square = id^2,
                  gindex_cumsum = cumsum(n_cite)) %>%
    dplyr::mutate(hindex = max(which(id<=n_cite)),
                  gindex = max(which(gindex_square<gindex_cumsum))) %>%
    dplyr::mutate(mquotient = unique(hindex)/(lubridate::year(Sys.Date())-min(year))) %>%
    head(1) %>% dplyr::select(hindex:mquotient)

  return(out)}
