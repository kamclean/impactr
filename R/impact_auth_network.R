# impact_auth_network--------------------------------
# Documentation
#' Create a dataframe for network analysis of co-authorship
#' @description Create a dataframe for network analysis of co-authorship
#' @param df Dataframe with 2 mandatory columns (1) "id": A vector of unique paper IDs (e.g. DOI / PMID) (2) "author": A vector of strings of all authors (format must be last name + initials)
#' @param author Name of the "author" variable in the dataframe (default="author")
#' @param id Name of the "id" variable in the dataframe (default="pmid")
#' @param auth_interest = List of authors of interest (will exclude all vertices *not* involving these authors)
#' @param initial_right = Are the initials to the right of the last name? (default = TRUE)
#' @param initial_n = Number of initials to match authors on (default = 1).
#' @param edge_min = The minimum number of edges (weight) desired (default = 1)
#' @return Nested dataframe of: (1) Nodes (2) Vertices for network analysis
#'
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @import tidyr
#' @import stringr
#' @import stringi
#' @importFrom purrr map
#' @export

impact_auth_network <- function(df, author = "author", id="pmid", auth_interest="",
                                initial_right = TRUE, initial_num = 1, edge_min = 1){

  # if authors of interest, ensure matches authors
  auth_interest <- stringi::stri_enc_toascii(tolower(auth_interest))
  if(initial_right==TRUE){
    auth_interest <- tibble::enframe(auth_interest, value = "author") %>%
      dplyr::mutate(author_ln = stringr::str_sub(author, 1, stringi::stri_locate_last(author, regex = " ")[,"start"]-1),
                    author_in = stringr::str_sub(author, stringi::stri_locate_last(author, regex = " ")[,"start"]+1, nchar(author))) %>%
      dplyr::mutate(author_in = stringr::str_sub(author_in, 1, initial_num)) %>%
      dplyr::mutate(author = ifelse(author=="", author,trimws(paste0(author_ln, " ", author_in)))) %>%
      dplyr::pull(author)}else{
        auth_interest <- tibble::enframe(auth_interest, value = "author") %>%
          dplyr::mutate(author_ln = stringr::str_sub(author, stringi::stri_locate_first(author, regex = " ")[,"start"]+1, nchar(author)),
                        author_in = stringr::str_sub(author, 1, stringi::stri_locate_first(author, regex = " ")[,"start"]-1)) %>%
          dplyr::mutate(author_in = stringr::str_sub(author_in, 1, initial_num)) %>%
          dplyr::mutate(author = ifelse(author=="", author,trimws(paste0(author_ln, " ", author_in)))) %>%
          dplyr::pull(author)}

  # Create nodes (full dataset)
  df <- df %>%
    dplyr::mutate(id = dplyr::pull(., id),
                  author = dplyr::pull(., author)) %>%
    dplyr::mutate(author_n = stringr::str_count(author, ", ")+1)

  node <- impactr::impact_auth(df)$list %>%
    dplyr::select(author) %>%
    dplyr::mutate(author = iconv(tolower(author), to ="ASCII//TRANSLIT")) %>%
    tibble::rowid_to_column("id")


  # if authors of interest, ensure only publications where they are coauthor
  suppressWarnings(
    if(auth_interest!=""){
      df <- df %>%
        dplyr::mutate(author = iconv(tolower(author), to ="ASCII//TRANSLIT")) %>%
        dplyr::filter(rownames(.) %in% grep(paste0(auth_interest,collapse="|"), author))})


  # Create edges (full dataset)

  edge <- df %>%
    dplyr::filter(author_n>1) %>% # exclude single author papers

    # ensure no special characters
    dplyr::mutate(author = iconv(tolower(author), to ="ASCII//TRANSLIT")) %>%
    dplyr::select(id, author) %>%
    tidyr::separate_rows(author, sep= ", ")

  if(initial_right==TRUE){
    edge <- edge %>%
      dplyr::mutate(author_ln = stringr::str_sub(author, 1, stringi::stri_locate_last(author, regex = " ")[,"start"]-1),
                    author_in = stringr::str_sub(author, stringi::stri_locate_last(author, regex = " ")[,"start"]+1, nchar(author))) %>%
      dplyr::mutate(author_in = stringr::str_sub(author_in, 1, initial_num)) %>%
      dplyr::mutate(author = paste0(author_ln, " ", author_in)) %>%
      dplyr::select(-author_ln, -author_in)}else{
        edge <- edge %>%
          dplyr::mutate(author_ln = stringr::str_sub(author, stringi::stri_locate_first(author, regex = " ")[,"start"]+1, nchar(author)),
                        author_in = stringr::str_sub(author, 1, stringi::stri_locate_first(author, regex = " ")[,"start"]-1)) %>%
          dplyr::mutate(author_in = stringr::str_sub(author_in, 1, initial_num)) %>%
          dplyr::mutate(author = paste0(author_ln, " ", author_in)) %>%
          dplyr::select(-author_ln, -author_in)}

  edge <- edge %>%
    dplyr::group_split(id, keep=TRUE) %>%
    purrr::map(function(x){x %$%
        combn(author, m = 2) %>%
        t() %>% tibble::as_tibble() %>%
        dplyr::mutate(id = unique(x$id))}) %>%
    dplyr::bind_rows() %>%
    dplyr::rename("auth1" = V1,"auth2" = V2) %>%
    dplyr::mutate(status_auth1 = ifelse(grepl(paste0(auth_interest,collapse="|"), auth1)==T, "int", "ext"),
                  status_auth2 = ifelse(grepl(paste0(auth_interest,collapse="|"), auth2)==T, "int", "ext")) %>%
    dplyr::mutate(status_auth12 = paste0(status_auth1, "-", status_auth2)) %>%
    dplyr::filter(status_auth12!="ext-ext") %>%
    dplyr::select(id, auth1,auth2)

  n_edge <- edge %>%
    dplyr::filter(auth1!=auth2) %>% # cannot be paired with self
    dplyr::arrange(auth1, auth2) %>%
    # ensure pairings alphabetical
    dplyr::mutate(auth_alpha1 = ifelse(auth1<auth2, auth1, auth2),
                  auth_alpha2 = ifelse(auth1<auth2, auth2, auth1)) %>%
    dplyr::select(id, "auth1" = auth_alpha1, "auth2" = auth_alpha2) %>%

    # combination must start with auth_interest (if desired)
    dplyr::mutate(comb1 = paste0(auth1, "---", auth2),
                  comb2 = paste0(auth2, "---", auth1)) %>%
    tidyr::pivot_longer(cols=c("comb1", "comb2")) %>%
    dplyr::filter(grepl(paste0(auth_interest,collapse="|"), stringr::str_split_fixed(value, "---", 2)[,1])) %>%
    dplyr::distinct(.keep_all = TRUE) %>%
    tidyr::pivot_wider(names_from = "name", values_from = "value") %>%
    dplyr::mutate(comb = ifelse(is.na(comb1)==T, comb2, comb1)) %>%
    dplyr::mutate(auth1 = stringr::str_split_fixed(comb, "---", 2)[,1],
                  auth2 = stringr::str_split_fixed(comb, "---", 2)[,2]) %>%
    dplyr::select(id, auth1, auth2) %>%

    # determine weight
    dplyr::group_by(auth1, auth2) %>%
    dplyr::summarise(weight = n()) %>%
    dplyr::ungroup() %>%
    dplyr::arrange(-weight) %>%
    dplyr::filter(weight>=edge_min)

  edge_data <- n_edge %>%
    dplyr::left_join(node, by = c("auth1" = "author")) %>%
    dplyr::rename("auth1_id" = id) %>%
    dplyr::left_join(node, by = c("auth2" = "author")) %>%
    dplyr::rename("auth2_id" = id) %>%
    dplyr::select(auth1_id, auth2_id, "auth1_name" = auth1, "auth2_name" = auth2,
                  weight)

  suppressWarnings(
    if(auth_interest!=""){
      node <- node %>%
        dplyr::filter(id %in% c(edge_data$auth1_id, edge_data$auth2_id)) %>%
        dplyr::mutate(author = ifelse(c(author %in% auth_interest)==T, author, ""))})

  out <- list("node" = node, "edge" = edge_data)

  return(out)}
