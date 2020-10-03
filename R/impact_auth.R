# impact_auth--------------------------------
# Documentation
#' Provide a citation for a research publication
#' @description Used to generate a text version of the difference between 2 dates.
#' @param df Dataframe with 2 mandatory columns (1) pub_group (the paper or project authored) (2) auth_list = A string of all authors for the pub_group.
#' @param author_list A vector of the collapsed authorship lists of each publication, listed per row (should be an output from paste0(x, collapse = ", ")).
#' @param pub_group A vector of the research outputs (the paper or project authored) which the authors are being compared across (default = pmid)
#' @param max_inital = Number of initials to match authors on (default = 1).
#' @param upset Compare intersections of authorship across each pub_group, and produces data format suitable for producing UpSet plots (default = FALSE).
#' @param metric Provide author engagement metrics across each pub_group (default = FALSE)
#'
#' @return Nested dataframe of: (1). "auth_out" - All unique authors; (2). data_upset = intersection data (if upset = TRUE). (3). metric = author engagement metrics (if metric = TRUE).
#'
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @importFrom tidyr unnest
#' @importFrom stringr str_split str_split_fixed str_replace
#' @importFrom stringi stri_locate_last
#' @importFrom purrr map
#' @export

# Function-------------------
impact_auth <- function(df, author_list = "author", pub_group = "pubmed", max_inital = 1, upset = FALSE, metric = FALSE){
  require(dplyr);require(tidyr);require(stringr);require(tibble);require(stringi)
  auth_out <- df %>%
    dplyr::mutate(pub_group = dplyr::pull(., pub_group)) %>%
    dplyr::mutate(author = dplyr::pull(., author_list)) %>%
    dplyr::select(pub_group, author) %>%
    tidyr::separate_rows(author, sep = "; ") %>%
    dplyr::mutate(author = tolower(author)) %>%

    # identify last space (prior to first name)
    dplyr::mutate(fnln_break = tibble::as_tibble(stringi::stri_locate_last(author, regex = " "))$start) %>%
    dplyr::mutate(auth_ln = trimws(substr(author,1, fnln_break)),
                  auth_fn = trimws(substr(author, fnln_break, nchar(author)))) %>%
    dplyr::mutate(auth_fn_imax = trimws(substr(auth_fn, 1,max_inital))) %>%
    dplyr::mutate(auth_imax = paste0(auth_ln, " ", auth_fn_imax)) %>%
    dplyr::select(pub_group, auth_imax, auth_ln,auth_fn_imax) %>%
    dplyr::distinct() %>%
    dplyr::group_by(auth_imax) %>%
    dplyr::summarise(pub_n = n(),
                     pub_group = paste0(pub_group, collapse = c(", "))) %>%
    dplyr::arrange(-pub_n) %>%
    dplyr::select("author" = auth_imax, pub_n, pub_group)

  data_upset <- NULL
  if(upset==TRUE){
  group_val <- levels(unique(dplyr::pull(df, pub_group)))

  data_upset = auth_out %>%
    tidyr::separate_rows(pub_group, sep = ", ") %>%
    dplyr::mutate(name = author) %>%
    tidyr::pivot_wider(names_from = "pub_group", values_from = "author") %>%
    dplyr::select(-name, -pub_n) %>%
    dplyr::mutate_all(function(x){as.numeric(ifelse(is.na(x)==T, 0, 1))})}

  out_metric <- NULL


  if(metric==TRUE&upset==TRUE){
    out_metric <- data_upset %>%
      tidyr::pivot_longer(cols = everything(), names_to = "level", values_to = "n_total") %>%
      dplyr::mutate(level = factor(level, levels=unique(level))) %>%
      dplyr::group_by(level) %>%
      dplyr::summarise(n_total = sum(n_total)) %>%
      dplyr::group_split(level) %>%
      purrr::map_df(function(x){x %>%
          dplyr::mutate(n_old = format_intersect(data_upset) %>%
                          dplyr::filter(grepl(paste0("&", x$level), combination)) %>%
                          dplyr::pull(n) %>% sum()) %>%
          dplyr::mutate(n_retain = format_intersect(data_upset) %>%
                          dplyr::filter(grepl(paste0(x$level, "&"), combination)) %>%
                          dplyr::pull(n) %>% sum()) %>%
          dplyr::mutate(n_new = n_total-n_old)}) %>%

      dplyr::mutate(n_total_prior = c(NA, dplyr::filter(., level!=level[length(level)])$n_total),
                    n_new_prior = c(NA, dplyr::filter(., level!=level[length(level)])$n_new),
                    n_retain = ifelse(n_retain==0, NA, n_retain)) %>%
      dplyr::mutate(total_change_prop = round(n_total / n_total_prior, 3),
                    new_change_prop = round(n_new / n_new_prior, 3),
                    retain_prop = round(n_retain / n_total, 3)) %>%
      dplyr::select(level, n_total, n_total_prior, total_change_prop,
                    n_old, n_new, n_new_prior, new_change_prop,
                    n_retain, retain_prop)}

  auth_out <- list("list" = auth_out, "upset" = data_upset, "metric" = out_metric)

  return(auth_out)}
