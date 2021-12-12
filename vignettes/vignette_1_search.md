---
title: "Search Pubmed"
date: "2021-12-12"
always_allow_html: yes
output: md_document
vignette: >
  %\VignetteIndexEntry{Vignette Title}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---



# **Search Publication Data**



&nbsp;

## **1. Search Pubmed**

The `search_pubmed()` function provides a focussed method

- *Note: This is not intended to replicate the search function within pubmed. This is intended for the specific use of identifying the publications associated with an individual or group of authors*.

At present the search can be refined in 2 ways:

 - Timeperiod (`date_min` and `date_max`): The default is no limitations.

 - Keywords (`keywords`): This will search for the keyword(s) within *All Fields* on PubMed.
 
    - Multiple keywords can be supplied as a list (e.g. keywords = c("surgery", "infection")), and will be searched for in combination (via "OR" Boolean operator).
 
    - Boolean operators ("AND", "OR", and "NOT") can be used to combine search terms within a keyword (e.g. keywords = "surgery AND infection")

    - The asterisk wildcard search ("*") is supported to further refine the search.


```r
search <- impactr::search_pubmed(search_list = c("mclean ka", "ots r", "drake tm", "harrison em"),
                        date_min = "2018/01/01", date_max = "2020/05/01")
```

The output from `search_pubmed()` is a list of PMIDs resulting from this search (e.g. 271 in the above case).


&nbsp;

## **2. Sift Pubmed Results**

There may be 1000s of records which meet the search criteria specified 

 - **list_pmid** - can be identified via the `search_pubmed()` function or another method.
 
  - Note: There is a limit to the number of PMID that can be supplied to the PubMed API at once via this method (approximately 200 PMID). It is highly suggested that if you wish to sift > 200 records, these are supplied to the function separately. 

 - **authors** = If these authors are linked (e.g. likelihood of being co-authors), then the `authors` parameter is suggested to be used. 
 
  - Note: This is generally the rate-limiting step for this function (particularly when publications contain hundreds or thousands or authors).  

 - **Author affiliations** (`affiliations`): This will search within the information held on authors for:
 
  - A match within any of the affiliations listed for all authors.
  
  - A match witin any of the affiliations listed specifically for authors supplied in `authors` (if provided).

 - **Keywords** (`keywords`): This will search for the keyword(s) within the title, abstract, and journal name. Otherwise this parameter functions as in the `search_pubmed()` function (see above).
 
Note: This function 


```r
extract <- impactr::extract_pmid(pmid = search, get_authors = TRUE, get_altmetric = F, get_impact = F)
```




```r
sifted <- extract %>%
  sift(authors = c("mclean ka", "ots r", "drake tm", "harrison em"),
                affiliations = c("edinburgh", "lothian"),
                keyword = c("surg"))
```


```
## # A tibble: 10 × 15
##    var_id   criteria_met author_multi_n
##    <chr>           <dbl>          <dbl>
##  1 31585971            2              4
##  2 30620075            2              3
##  3 31600252            2              2
##  4 30793373            1              4
##  5 30234014            1              2
##  6 32345457            1              1
##  7 32072750            1              1
##  8 32033800            1              1
##  9 31903586            1              1
## 10 31726643            1              1
## # … with 12 more variables:
## #   author_multi_list <chr>,
## #   affiliations_author <chr>,
## #   affiliations_any <chr>, text <chr>,
## #   keyword <chr>, ignoreword <lgl>,
## #   author_list <chr>,
## #   author_affiliation_list <chr>, title <chr>, …
```


```
## # A tibble: 10 × 15
##    var_id   criteria_met author_multi_n
##    <chr>           <dbl>          <dbl>
##  1 32021696            1              0
##  2 31630664            1              0
##  3 31519896            1              0
##  4 29561180            1              0
##  5 29100900            1              0
##  6 33062652            0              0
##  7 32502207            0              0
##  8 32468912            0              0
##  9 32341509            0              0
## 10 32318915            0              0
## # … with 12 more variables:
## #   author_multi_list <chr>,
## #   affiliations_author <chr>,
## #   affiliations_any <chr>, text <chr>,
## #   keyword <chr>, ignoreword <lgl>,
## #   author_list <chr>,
## #   author_affiliation_list <chr>, title <chr>, …
```



Based on the above search of 271 identified using `pubmed_search()` there are:

 - 36 identified as **wheat** (e.g. more likely to be relevant), of which 27/39 (69.2%) were relevant when maunally screened.
 
 - 235 identified as **chaff** (e.g. less likely to be relevant), of which 12/235 (5.1%) were relevant when maunally screened. 
 
 
However, it should be noted that all publications that met 2 or more criteria (n=`nrow(sifted$wheat %>% dplyr::filter(criteria_met>1))`) were relevant. The function has been designed with sensitivity in mind to maximise negative predictive value.


```r
accuracy_table <- accuracy_check %>%
  dplyr::select(designation, relevance) %>%
  table()

accuracy_table
```

```
##            relevance
## designation Yes  No
##       Wheat  27   9
##       Chaff  12 223
```
  
The accuracy of the search entirely depends upon the parameters used - 75.9% (n=22/29) would not have been highlighted if a keyword ("surg") was not used. 


```r
venn_data <- accuracy_check %>%
  dplyr::filter(relevance=="Yes") %>%
  dplyr::filter(designation=="Wheat") %>%
  dplyr::mutate(`Multiple Specified Authors` = ifelse(author_multi_n>1, 1, 0),
                `Affiliation (Specified Author)` = ifelse(affiliations_author=="Yes", 1, 0),
                `Affiliation (Any Author)` = ifelse(affiliations_any=="Yes", 1, 0),
                `Keyword` = ifelse(keyword=="Yes", 1, 0)) %>%
  dplyr::select(`Multiple Specified Authors`:`Keyword`) %>%
  impactr::format_intersect() %>%
  dplyr::select(-degree) %>%
  dplyr::filter(combination!="") %>% # patients who are recorded as asymptomatic (on these 3 variables)
  tidyr::pivot_wider(names_from = combination, values_from = n) %>%
  unlist()

grDevices::png(filename = here::here("vignettes/plot/venn_sift.png"),
               height = 3.6, width = 5.6, units = "in", res=300)

plot(eulerr::euler(venn_data),
     edges = list("black", alpha = 0.8),
     fill = list(alpha = 0.5),
     quantities = list(fontsize = 15), legend = list(alpha = 1))

dev.off()
```

```
## png 
##   2
```
Let's add some more parameters in to try to improve sensitivity. This will include a common coauthor ("wigmore sj"), and another common topic of publications ("liver").


```r
sifted2 <- extract %>%
  sift(authors = c("mclean ka", "ots r", "drake tm", "harrison em", "wigmore sj"),
                affiliations = c("edinburgh", "lothian"),
                keyword = c("surg", "liver"))
```

Based on the above criteria:

 - 55 identified as **wheat** (e.g. more likely to be relevant), of which 35/55 (63.6%) were relevant when maunally screened.
 
 - 216 identified as **chaff** (e.g. less likely to be relevant), of which 4/212 (1.8%) were relevant when maunally screened. 


```
##            relevance
## designation Yes  No
##       Wheat  35  20
##       Chaff   4 212
```
