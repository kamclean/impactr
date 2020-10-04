---
title: "Impact from Co-authorship Network"
date: "2020-10-04"
always_allow_html: yes
output:
  md_document:
    variant: gfm
vignette: >
  %\VignetteIndexEntry{Vignette Title}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---


# **Impact from from Co-authorship Network**
Authorship lists on publications can range from one to potentially hundreds or even thousands of co-authors (particularly in the case of [collaborative research](https://www.bmj.com/content/345/bmj.e5084) studies).

&nbsp;

## **impact_auth()**
The `impact_auth()` function aims to simplify this process by providing an easy method to gain a comprehensive understanding of co-authorship networks using publication data.

Both the `extract_pmid()` and `extract_doi()` functions extract a list of authors that can be used directly by `impact_auth()`. The only mandatory requirements are a dataframe of the grouping variable (`pub_group` e.g. "project") and the authors ("author").

To track co-authors across publications, the author names must be matched between the groups (and dupliciates within groups excluded). Ideally authors would be matched on ORCID (or similar unique identifier). Unfortunalely, that information is rarely stored in on-line repositories and so authors dervied in this way can only be reliably matched by last name and initials. However, `max_inital` allows flexiblity in how restrictive matching authors will be.

 - If `max_inital` = 3, then the authors will be matched on their last name and exact initials (up to 3). As a result, this **more** restrictive matching may overestimate the number of unique co-authors. For example, if the **same author** is listed as "Smith ABC" and "Smith AB" on 2 separate publications, these will be treated as **different authors**.

 - If `max_inital` = 1, then the authors will be matched on their last name and first initial only. As a result, this **less** restrictive matching may underestimate the number of unique co-authors. For example, if **different authors** have the same last name and first initial (e.g. listed as "Smith AB" and "Smith AK") on 2 separate publications, these will be treated as the **same author**.

&nbsp;

## **1. Traditional Authorship Model**
Traditional authorship models, largely based on the criteria of the International Committee of Medical Journal Editors (ICMJE), consider the authors' byline in the papers as the key for attributing credit. Securing a place in the byline is itself a credit, whilst taking the first place is often the reward for contributing the most to the multi-authored work. While this model has been criticised (particularly given this definition of authorship only covers a very limited series of relationships that a person can have with a published article), this remains the mainstay of scientific publication ( [read more here](https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3677992/) ).

An example of several papers published using a traditional authorship model can be seen here:

```r
source('~/impactr/R/extract_pmid.R')
  source('~/impactr/R/extract_pubmed_xml.R')
```

```
## Error in file(filename, "r", encoding = encoding): cannot open the connection
```

```r
source('~/impactr/R/score_alm.R')
source('~/impactr/R/extract_impact_factor.R')
data_auth <- extract_pmid(pmid = c(26445672, 28280919, 27531411, 28027614,30850367, 31585971, 30793373)) %>%
                                            
  dplyr::mutate(pubmed = factor(pubmed)) %>%
  dplyr::select(pubmed, author_n, author_list)
```

```
## [1] "Chunk 1"
## [1] 1
## [1] 2
## [1] 3
## [1] 4
## [1] 5
## [1] 6
## [1] 7
```

```
## Error: Problem with `mutate()` input `pubmed`.
## x object 'pubmed' not found
## ℹ Input `pubmed` is `factor(pubmed)`.
```


```
## Error in eval(lhs, parent, parent): object 'data_auth' not found
```

```r
example_auth <- impact_auth(data_auth, pub_group = "pubmed", max_inital = 1)
```

```
## Error in eval(lhs, parent, parent): object 'data_auth' not found
```


&nbsp;

### **a). Unique authors (`$list`)**
We can use `impact_auth()` to derive a basic summary (`$list`) of all unique collaborators across all groups (`author`), and their involvement in each (`pub_n`, `pub_group`). 


```r
example_auth$list
```


```
## Error in eval(lhs, parent, parent): object 'example_auth' not found
```

&nbsp;

### **b). Network analysis (`impact_auth_network()`)**
Scientific collaboration networks are a hallmark of contemporary academic research. Researchers are no longer independent players, but members of teams that bring together complementary skills and multidisciplinary approaches around common goals. Social network analysis and co-authorship networks are increasingly used as powerful tools to assess collaboration trends and to identify leading scientists and organizations ( [read more here](https://health-policy-systems.biomedcentral.com/articles/10.1186/s12961-016-0104-5) ). R provides many capabilities to visualise network analyses, however all require inputs with specific formats in order to perform these.

**`impact_auth_network()`** takes a dataframe produced by `extract_pmid()` or `extract_doi()` (or any dataframe which matches the format of the `pmid` or `doi`, and `auth_list` columns) and will produce a nested list of:

  1. **$node**: All individual authors.
  
  2. **$edge**: All connections between authors (and their weight).

This can then be plotted using packages such as `igraph`, `tidygraph`, `networkD3`, etc.


```r
plot_network1 <- impact_auth_network(data_auth) %$%
  
  tidygraph::tbl_graph(nodes = node, edges = edge, directed = FALSE) %>%
  dplyr::mutate(centrality = tidygraph::centrality_betweenness()) %>% 
  
  ggraph::ggraph(layout = "nicely") +
  ggraph::geom_edge_link(aes(width = weight), alpha = 0.5) + 
  ggraph::scale_edge_width(range = c(0.1, 1)) +
  ggraph::geom_node_point(aes(size = centrality)) +
  ggraph::geom_node_text(aes(label = author),colour="red", fontface="bold", repel = TRUE) +
  ggplot2::scale_color_manual(values = c("Yes" = "red", "No" = "#ADD8E6")) +
  ggplot2::labs(edge_width = "Co-authorship") +
  ggraph::theme_graph()
```

```
## Error in eval(lhs, parent, parent): object 'data_auth' not found
```

```
## Error in grid.draw(plot): object 'plot_network1' not found
```
       
<img src="plot/plot_network1.png" align="center"/>

&nbsp;

If there are specific authors of interest, these can be supplied via `auth_interest`. This will ensure only direct connections to the specified author(s) will be included.


```r
plot_network2 <- impact_auth_network(data_auth,
                                              auth_interest = c("mclean k", "drake t", "harrison e", "ots r", "wigmore s")) %$%

tidygraph::tbl_graph(nodes = node, edges = edge, directed = FALSE) %>%
  dplyr::mutate(centrality = tidygraph::centrality_betweenness()) %>% 
  
  ggraph::ggraph(layout = "nicely") +
  ggraph::geom_edge_link(aes(width = weight), alpha = 0.2) + 
  ggraph::scale_edge_width(range = c(0.1, 1)) +
  ggraph::geom_node_point(aes(size = centrality)) +
  ggraph::geom_node_text(aes(label = author, group = interest, colour = interest), fontface="bold", repel = TRUE) +
  ggplot2::scale_color_manual(values = c("Yes" = "red", "No" = "blue")) +
  ggplot2::labs(edge_width = "Co-authorship") +
  ggraph::theme_graph()
```

```
## Error in eval(lhs, parent, parent): object 'data_auth' not found
```

```
## Error in grid.draw(plot): object 'plot_network2' not found
```

<img src="plot/plot_network2.png" align="center"/>

**Note**: *Publications with a hundreds or thousands of authors (e.g. collaborative authorship model publications) are generally unsuitable for this form of network analysis. It is recommended that UpSet plots are used instead to investigate these publications (see below). However, if the publications under investigation consist of traditional and collaborative authorships, this can be done (however `edge_min` should be set to 2 or more to account for the high number of single connections within publications).*

&nbsp;

## **2. Collaborative Authorship Model**
Collaborative research is becoming increasingly common, recognising the valuable contribution that people beyond traditionally recognised "authors" make. Typically, those involved are listed as PubMed-citable "collaborators" on the publications due to contibuting eligible data. The number of "collaborators" can range from hundreds to thousands.

An example of several publications by the [STARSurg collaborative](https://starsurg.org/) using a collaborative authorship model can be seen below. This composes 3 successive studies from the group (STARSurg-1, DISCOVER, and OAKS-1)


```r
data_collab <- impactr::extract_pmid(pmid = c(25091299, 27321766, 30513129), get_auth = TRUE) %>%
  dplyr::mutate(project = factor(pmid,
                                 levels = c(25091299, 27321766, 30513129),
                                 labels =c("STARSurg-1", "DISCOVER", "OAKS-1"))) %>%
  dplyr::mutate(author_n = stringr::str_count(author, ", ")+1) %>%
  dplyr::select(project, pmid, author_n, author)
```

```
## [1] "Chunk 1"
## [1] 1
## [1] 2
## [1] 3
```

```
## Error: Problem with `mutate()` input `author_n`.
## x object 'author' not found
## ℹ Input `author_n` is `stringr::str_count(author, ", ") + 1`.
```


```
## Error in eval(lhs, parent, parent): object 'data_collab' not found
```


```r
example_collab <- impactr::impact_auth(data_collab, pub_group = "project", max_inital = 1, upset = TRUE, metric = TRUE)
```

```
## Error in eval(lhs, parent, parent): object 'data_collab' not found
```

&nbsp;

### **a). Unique authors (`$list`)**
We can use `impact_auth()` to derive a basic summary (`$list`) of all unique collaborators across all groups (`author`), and their involvement in each (`pub_n`, `pub_group`). 


```r
example_collab$list
```


```
## Error in eval(lhs, parent, parent): object 'example_collab' not found
```

This data can be used in a variety of ways, including a basic summary of involvement over time. For example, the number of projects authors/collaborators have been involved in:


```
## Error in eval(lhs, parent, parent): object 'example_collab' not found
```

&nbsp;

### **b). Intersection analysis (`$upset`)**
As discussed above, when collaborative authorship reaches hundreds or thousands, detailed network analysis becomes meaningless. Instead, the `impact_auth()` function has the capability to derive information on how the authors relate using the `upset = TRUE` argument.

A subset of the `$upset` output is displayed below. Each column is a level from the `pub_group` variable (e.g. "project"), with `1` representing presence and the `0` representing absence of the author from each project.


```
## Error in eval(lhs, parent, parent): object 'example_collab' not found
```

&nbsp;

#### **i). Summary**

The `upset` output can be used to derive information on the relationships between authors and the groups (`pub_group` variable).


```r
upset_comb_mat <- impactr::format_intersect(data_upset) %>% knitr::kable() %>%
  kableExtra::kable_styling(bootstrap_options = "striped", full_width = F)
```

```
## Error in eval(lhs, parent, parent): object 'data_upset' not found
```

&nbsp;

#### **ii). UpSet plots**

Furthermore, UpSet plots provide an efficient way to visualize intersections of multiple sets compared to the traditional approaches (e.g. Venn Diagram). The `upset` output can be used directly to make UpSet plots via the [UpSetR](https://github.com/hms-dbmi/UpSetR) packages.


```r
as.data.frame(example_collab$upset) %>% UpSetR::upset(text.scale = 1.7)
```









