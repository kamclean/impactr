# extract_impact_factor--------------------------------
# Documentation
#' Provide a citation for a research publication
#' @description Used to extract journal impact metrics for publications.
#' @param df Dataframe with publications listed rowwise with at least 1 column containing the journal ISSN
#' @param var_issn String of column name with the journal International Standard Serial Number (ISSN) number listed (default: journal_issn)
#' @return Dataframe of journal impact metrics
#' @import sjrdata
#' @import dplyr
#' @importFrom tidyr unnest
#' @importFrom stringr str_split str_split_fixed str_replace
#' @importFrom purrr map map_df
#' @export

# Function-------------------
extract_impact_factor <- function(df, var_id = "pmid", var_issn = "journal_issn"){
  update.packages("sjrdata")

  df <- df %>%
    dplyr::mutate(journal_issn = dplyr::pull(., var_issn),
                  var_id = dplyr::pull(., var_id)) %>%
    dplyr::mutate(journal_issn = gsub("-","", journal_issn)) %>%
    tidyr::separate_rows(., journal_issn, sep = ", ")  %>%
    dplyr::mutate(journal_issn = trimws(journal_issn))

  out <- sjrdata::sjr_journals %>%
    dplyr::filter(type=="journal") %>%
    dplyr::select(year, "journal_full" = title, "journal_issn" = issn, "journal_if" = cites_doc_2years) %>%
    dplyr::mutate(journal_issn = ifelse(grepl("09598146", journal_issn)==T,
                                        "17561833, 09598146, 09598138", journal_issn), # bmj
                  journal_issn = ifelse(grepl("01406736|1474547", journal_issn)==T,
                                        "1474547X, 01406736, 1474547", journal_issn),
                  journal_issn = ifelse(grepl("00029610", journal_issn)==T,
                                        "18791883, 00029610", journal_issn)) %>% #AJoS

    dplyr::filter(grepl(paste(df$journal_issn, collapse="|"), journal_issn)) %>%
    dplyr::mutate(journal_issn = stringr::str_split(journal_issn, ", "),
                  year = as.numeric(year)) %>%
    tidyr::unnest(journal_issn) %>%
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

  out2 <- out %>%
    dplyr::bind_rows(df_missing_max, df_missing_min) %>%
    dplyr::select(-journal_full) %>%
    dplyr::left_join(df, ., by=c("year", "journal_issn")) %>%
    dplyr::arrange(var_id, journal_if) %>%
    dplyr::mutate(journal_if = zoo::na.locf(journal_if)) %>%
    dplyr::group_by(var_id) %>%
    dplyr::mutate(journal_issn = paste(journal_issn, collapse=", ")) %>%
    dplyr::distinct(var_id, journal_issn, .keep_all = TRUE) %>%
    dplyr::ungroup(var_id) %>%
    dplyr::select(-var_id)

  return(out2)}
