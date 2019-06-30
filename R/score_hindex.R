# score_hindex--------------------------------
# Documentation
#' Calculate an H-Index based on number of citations.
#' @description Calculate an H-Index based on a vector of citations.
#' @param n_citations Vector of citations (numerical variable).
#' @return H-Index score
#' @export

# Function-------------------------------
score_hindex <- function(n_citations){
  n_citations <- ifelse(is.na(n_citations)==T, 0, n_citations)

  for(i in 1:max(n_citations)){
    if(sum(as.character(n_citations>i)=="TRUE")<=i){
      break}
    next}
  return(i)}
