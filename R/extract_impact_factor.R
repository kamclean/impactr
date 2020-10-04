# extract_impact_factor--------------------------------
# Documentation
#' Provide a citation for a research publication
#' @description Used to extract journal impact metrics for publications.
#' @param data Dataframe with publications listed rowwise with at least 1 column containing the journal ISSN
#' @param var_issn String of column name with the journal International Standard Serial Number (ISSN) number listed (default: journal_issn)
#' @param all Logical value indicating if only the 2 year impact factor should be returned (or if it should include all impact factor information)
#' @return Dataframe of journal impact metrics
#' @import dplyr
#' @import tidyr
#' @import stringr
#' @import purrr
#' @importFrom tidyr unnest
#' @importFrom zoo na.locf
#' @export

# Function-------------------
extract_impact_factor <- function(data, var_id = "pmid", var_issn = "journal_issn", all = F){
  df <- data %>%
    dplyr::mutate(journal_issn = dplyr::pull(., var_issn),
                  var_id = dplyr::pull(., var_id)) %>%
    tidyr::separate_rows(journal_issn, sep = ", ")  %>%
    dplyr::mutate(journal_issn = stringr::str_squish(journal_issn)) %>%
    dplyr::mutate(year = as.character(year),
                  var_id = as.character(var_id))

  out <- readr::read_rds(here::here("data/data_if.rds")) %>%
    dplyr::mutate(year = as.numeric(as.character(year))) %>%
    dplyr::filter(journal_issn %in% df$journal_issn)

  # Last IF recorded for missing years
  df_missing_max <- NULL
  if(max(df$year)>max(out$year)){
    max_year_miss <- seq(max(out$year)+1, max(df$year))
    df_missing_max <- purrr::map_df(max_year_miss, ~dplyr::filter(out, year==max(year))) %>%
      mutate(year = rep(max_year_miss, each=nrow(dplyr::filter(out, year==max(year)))))}

  df_missing_min <- NULL
  if(min(df$year)<min(out$year)){
    min_year_miss <- seq(min(df$year), min(out$year)-1)

    df_missing_min <- purrr::map_df(min_year_miss, ~dplyr::filter(out, year==min(year))) %>%
      mutate(year = rep(min_year_miss, each=nrow(dplyr::filter(out, year==min(year)))))}

  journal_data <- out %>%
    dplyr::bind_rows(df_missing_max, df_missing_min) %>%
    dplyr::mutate(year = as.character(year)) %>%
    dplyr::select(-journal_full, -journal_abbr)

  final <- df %>%
    dplyr::left_join(journal_data, by=c("journal_issn","year")) %>%
    dplyr::mutate(var_id = factor(var_id, levels =  unique(var_id))) %>%
    dplyr::arrange(var_id, journal_if_2y, journal_if_5y) %>%
    dplyr::group_by(var_id) %>%
    dplyr::mutate_at(dplyr::vars(journal_rank:journal_eigen), function(x){zoo::na.locf(x, na.rm = F)}) %>%
    dplyr::mutate(journal_issn = paste(journal_issn, collapse=", ")) %>%
    dplyr::distinct(var_id, journal_issn, .keep_all = TRUE) %>%
    dplyr::ungroup(var_id) %>%
    dplyr::select(-var_id)


  if(all==F){final <- final %>%
    select(-any_of(c("journal_if", "journal_rank", "journal_cite_total",
                     "journal_if_5y", "journal_eigen", "journal_issn_comb"))) %>%
    dplyr::rename("journal_if" = journal_if_2y)}

  return(final)}
