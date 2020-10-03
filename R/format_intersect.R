# format_intersect----------------------
# Documentation
#' Additional function for ComplexHeatmap
#' @description Additional function for ComplexHeatmap to faciltate named sets in combinations
#' @param comb_mat Combination matrix output from ComplexHeatmap::make_comb_mat()
#' @return Tibble of combinations with the name of the sets provided.
#' @import magrittr
#' @import dplyr
#' @import tibble
#' @importFrom ComplexHeatmap comb_size set_name
#' @importFrom stringr str_split_fixed str_count
#' @importFrom tidyr unite
#' @export

# Function-------------------------------
format_intersect <- function(data_upset){

out <- data_upset %>%
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
