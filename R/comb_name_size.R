# comb_name_size----------------------
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
comb_name_size <- function(comb_mat){

  out_comb_size <- ComplexHeatmap::comb_size(comb_mat)

  out_set_name <- ComplexHeatmap::set_name(comb_mat)

  name_binary <- names(out_comb_size) %>%
    tibble::as_tibble() %$%
    stringr::str_split_fixed(value, "", length(out_set_name)) %>%
    tibble::as_tibble()

  for(i in c(1:length(out_set_name))){
    name_binary <- name_binary %>% dplyr::mutate_if(names(.)==names(.)[i],
                                                    function(x){ifelse(x=="1",paste0(out_set_name[i], "&", ""),"")})}

  name_new <- name_binary %>%
    tidyr::unite(col = "name", sep = "") %>%
    dplyr::mutate(name = substr(name, 1, nchar(name)-1)) %>% dplyr::pull(name)

  out <- out_comb_size %>% setNames(name_new) %>%
    as.data.frame() %>%
    tibble::rownames_to_column(var = "combination") %>% tibble::as_tibble() %>%
    setNames(c("combination", "n")) %>%
    dplyr::mutate(degree = stringr::str_count(combination, pattern = "&")+1) %>%
    dplyr::select(combination, degree, n)

  return(out)}
