# cite_presentation--------------------------------
# Documentation
#' Provide a citation for a research presentation
#' @description Used to generate a text version of the difference between 2 dates.
#' @param df Dataframe with publications listed rowwise
#' @param type String of column name with presentation type (e.g. poster, oral, etc) listed (optional).
#' @param level String of column name with presentation level (e.g. national, international, etc) listed (optional).
#' @param title String of column name with presentation title listed (mandatory).
#' @param con_org String of column name with the name of the organisation where the work was presented (mandatory)
#' @param con_name String of column name with the name of the meeting/conference where the work was presented (mandatory)
#' @param con_date_start  String of column name which represents the start date (optional).
#' @param con_date_end String of column name which represents the end date (optional).
#' @param con_city String of column name with the city of the meeting/conference where the work was presented (mandatory)
#' @param con_country String of column name with the country of the meeting/conference where the work was presented (mandatory)
#' @param author String of column name with the authors of the work presented (mandatory).
#'
#' @param cite_format Customisable string specifying the exact format for the preferred referencing style. Note exact parameter names are required and are limited to those specified.
#' @return Dataframe with addition of citation variable.
#' @import magrittr
#' @import dplyr
#' @importFrom purrr map
#' @importFrom stringr str_replace
#' @export

# Function------------------------
cite_presentation <- function(df, type = "type", level = "level", title = "title",
                              con_org = "con_org",con_name = "con_name",
                              con_date_start = "con_date_start", con_date_end = "con_date_end",
                              con_city = "con_city", con_country = "con_country", author = "author",
                              cite_format = "author. title. con_org con_name, con_date_range, con_city (con_country)."){
  cite <- df %>%
    tibble::as_tibble() %>%
    dplyr::rename(type = type,
                  level = level,
                  title = title,
                  con_org = con_org,
                  con_name = con_name,
                  con_date_start = con_date_start,
                  con_date_end = con_date_end,
                  con_city = con_city,
                  con_country = con_country,
                  author = author) %>%
    dplyr::mutate(con_date_range = diffdate_text(., "con_date_start", "con_date_end")$date_range)

  citation_na <- cite %>%
    dplyr::select(author, title, con_org, con_name, con_city, con_country) %>%
    apply(., 1, function(x)which(is.na(x)==T)) %>%
    lapply(., names) %>%
    purrr::map(., function(x){paste(x, collapse = ", ")}) %>%
    unlist()

  if(is.null(citation_na)==T){citation_na <- rep(NA, nrow(cite))}

  cite2 <- cite %>%
    dplyr::mutate(citation_na = ifelse(citation_na=="", NA, citation_na)) %>%

    # use format from function -> replace with current values
    dplyr::mutate(citation = cite_format) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "type", ifelse(is.na(as.character(type))==T, "NA",as.character(type)))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "level", ifelse(is.na(as.character(level))==T, "NA", as.character(level)))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "author", ifelse(is.na(author)==T, "NA", author))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "title", ifelse(is.na(title)==T, "NA", title))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "con_org", ifelse(is.na(con_org)==T, "NA", con_org))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "con_name", ifelse(is.na(con_name)==T, "NA", con_name))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "con_date_range", ifelse(is.na(con_date_range)==T, "NA", con_date_range))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "con_city", ifelse(is.na(con_city)==T, "NA", con_city))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "con_country", ifelse(is.na(con_country)==T, "NA", con_country))) %>%
    dplyr::mutate(citation = ifelse(is.na(citation_na)==F, paste0("[Incomplete citation data: ", citation_na, "]."), citation)) %>%
    dplyr::select(-citation_na) %>%

    # clean string
    dplyr::mutate(citation = gsub("  ", " ", citation)) %>%
    dplyr::mutate(citation = gsub(", NA, ", ", ", citation)) %>%
    dplyr::mutate_at(vars(title, con_name, con_org, con_date_range, con_city,con_country,author,citation), (function(x){ifelse(x=="", NA, x)}))

  return(cite2)}
