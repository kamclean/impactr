# format_intersect----------------------
# Documentation
#' Determine intersections (combinations) for upset or venn diagrams.
#' @description Determine intersections (combinations) for upset or venn diagrams.
#' @param data Dataset containing only columns which intersections are aiming to be determined for (must be binary - 01)
#' @return Tibble of combinations with the name of the sets provided.
#' @import dplyr
#' @import tidyr
#' @import tibble
#' @importFrom stringr str_count
#' @export

# Function-------------------------------
format_intersect <- function(data){

out <- data %>%
    tidyr::pivot_longer(cols = everything()) %>%
    dplyr::mutate(value = ifelse(value==1, name, NA)) %>%
    tidyr::pivot_wider(values_fn = list) %>%
    tidyr::unnest(cols=everything()) %>%
    tidyr::unite(everything(), col = "combination", sep = "&", na.rm = T) %>%
    dplyr::group_by(combination) %>%
    dplyr::summarise(n = n()) %>%
    dplyr::mutate(degree = stringr::str_count(combination, pattern = "&")+1) %>%
    dplyr::select(combination, degree, n)

  return(out)}
