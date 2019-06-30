# cite_publication--------------------------------
# Documentation
#' Provide a citation for a research publication
#' @description Used to generate a text version of the difference between 2 dates.
#' @param df Dataframe with publications listed rowwise
#' @param author String of column name with publication authors listed (mandatory).
#' @param title String of column name with publication title listed (mandatory).
#' @param journal String of column name with publication journal name listed (mandatory).
#' @param year String of column name with publication year listed (mandatory).
#' @param volume String of column name with publication volume listed (mandatory).
#' @param issue String of column name with publication issue listed (optional)
#' @param pages String of column name with publication pages listed (mandatory).
#' @param pmid String of column name with publication pmid listed (optional)
#' @param doi String of column name with publication journal name listed (optional).
#'
#' @param max_auth Argument to limit number of authors listed to the number specified. All n+1 authors will be replaced by a single "et al.". (default = FALSE e.g. no restriction).
#' @param cite_format Customisable string specifying the exact format for the preferred referencing style (default is Vancouver style). Note exact parameter names are required and are limited to those specified.
#'
#' @return Dataframe with addition of citation variable.
#' @import magrittr
#' @import dplyr
#' @importFrom stringr str_split str_split_fixed str_replace
#' @importFrom purrr map
#' @export

# Function-------------------
cite_publication <- function(df, author = "author", title = "title", journal = "journal",
                             year = "year",volume = "volume",issue = "issue", pages = "pages",
                             pmid = "pmid", doi = "doi", max_auth = FALSE,
                             cite_format = "author. title. journal. year; volume (issue): pages. PMID: pmid. DOI: doi."){
  "%ni%" <- Negate("%in%")
  if(pmid  %ni%  names(df)){df <- df %>% dplyr::mutate(pmid = NA)}

  cite <- df %>%
    tibble::as_tibble() %>%
    dplyr::rename(author = author,title = title,journal = journal,
                year = year,volume = volume,issue = issue,pages = pages,
                pmid = pmid,doi = doi) %>%
    dplyr::mutate_at(vars(author, title, journal, year, volume,issue,pages,pmid, doi), function(x){ifelse(is.na(x)==T, NA, trimws(as.character(x)))}) %>%
    dplyr::mutate_at(vars(author, title, journal, year, volume,issue,pages,pmid, doi),
                      function(x){x = ifelse(substr(x,nchar(x),nchar(x))==".",
                                             substr(x, 1, nchar(x)-1),
                                             x)})

  if(max_auth!=FALSE&is.numeric(max_auth)>0){

    cite <- cite %>%
      dplyr::mutate(author_original = author,
             author = stringr::str_split_fixed(author_original, ";", 2)[,1],
             author_group = stringr::str_split_fixed(author_original, ";", 2)[,2]) %>%
      dplyr::mutate(author = lapply(stringr::str_split(author, ", "),
                                    function(x){paste0(paste0(x[c(1:max_auth)], collapse = ", "), ", et al")})) %>%
      dplyr::mutate(author = unlist(author)) %>%
      dplyr::mutate(author = gsub(", NA, et al", "", author)) %>%
      dplyr::mutate(author = trimws(paste0(trimws(gsub(", NA", "", author)), "; ", author_group))) %>%
      dplyr::mutate(author = ifelse(substr(author, nchar(author), nchar(author))==";",
                                    substr(author, 1, nchar(author)-1), author)) %>%
      dplyr::mutate(author = trimws(gsub("NA , ", "", author))) %>%
      dplyr::mutate_all(function(x){ifelse(x=="NA;"|x=="NA", NA, x)})}

  citation_na <- cite %>%
    dplyr::mutate_all(function(x){ifelse(x=="", NA, x)}) %>%
    dplyr::select(author, title, journal, year,volume, pages) %>%
    apply(., 1, function(x)which(is.na(x)==T)) %>%
    lapply(., names) %>%
    purrr::map(., function(x){paste(x, collapse = ", ")}) %>%
    unlist()

  if(is.null(citation_na)==T){citation_na <- rep(NA, nrow(cite))}

  cite <- cite %>%
    dplyr::mutate(citation_na = ifelse(citation_na=="", NA, citation_na)) %>%

    # use format from function -> replace with current values
    dplyr::mutate(citation = cite_format) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "author", ifelse(is.na(author)==T, "NA", author))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "title", ifelse(is.na(title)==T, "NA", title))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "journal", ifelse(is.na(journal)==T, "NA", journal))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "year", ifelse(is.na(year)==T, "NA", year))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "volume", ifelse(is.na(volume)==T, "NA", volume))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "issue", ifelse(is.na(issue)==T, "NA", issue))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "pages", ifelse(is.na(pages)==T, "NA", pages))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "pmid", ifelse(is.na(pmid)==T, "NA", pmid))) %>%
    dplyr::mutate(citation = stringr::str_replace(citation, "doi", paste0("http://dx.doi.org/", ifelse(is.na(doi)==T, "NA", doi)))) %>%
    dplyr::mutate(citation = ifelse(grepl("; NA \\(NA\\): NA.", citation)==T,
                                    gsub("; NA \\(NA\\): NA.", "; [epub ahead of print].", citation), citation)) %>%
    dplyr::mutate(citation = ifelse( is.na(citation_na)==F&(citation_na!="volume, pages"),
                                    paste0("[Incomplete citation data: ", citation_na, "]."), citation)) %>%
    dplyr::select(-citation_na) %>%

    # clean string
    dplyr::mutate(citation = gsub("DOI: http://dx.doi.org/NA.", "", citation)) %>%
    dplyr::mutate(citation = gsub("PMID: NA.", "", citation)) %>%
    dplyr::mutate(citation = gsub("\\(NA)", "", citation)) %>%
    dplyr::mutate(citation = gsub("  ", " ", citation)) %>%
    dplyr::mutate(citation = gsub(" :", ":", citation)) %>%
    dplyr::mutate(citation = gsub(";\\.", ".", citation)) %>%

    dplyr::mutate_at(vars(author, title, journal, year, volume,issue,pages,pmid, doi,citation), (function(x){ifelse(x=="", NA, x)}))

  return(cite)}
