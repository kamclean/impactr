# **Collaborator Engagement**

In collaborative research projects, there can be hundreds or even
thousands of collaborators involved who gain pubmed-citable authorship
on the publications arising from data collected. Since the first
inception of the [collaborative research
model](https://www.bmj.com/content/345/bmj.e5084) in 2010, there has
arisen numerous research collaboratives which have run multiple projects
with resultant publications. In addition to more traditional research
metrics, a measure of the success of these projects is reflected in:

1.  The number of new collaborators involved in each project (aka
    growth).

2.  The involvement of collaborators across multiple projects (aka
    retention).

3.  The total number of collaborators involved in the project (overall
    engagement e.g. growth + retention).

However, with potentially thousands of collaborators involved, being
able to easily compare authors across multiple publications is a
challenging task.

 

## **impact\_auth()**

The `impact_auth()` function aims to simplify this process by providing
an easy method to gain a comprehensive understanding of collaborator
engagement using publication data.

Both the `extract_pmid()` and `extract_doi()` functions extract a list
of authors that can be used directly by `impact_auth()`. The only
mandatory requirements are a dataframe of the grouping variable
(`pub_group` e.g. “project”) and the authors
(“author”).

``` r
data <- extract_pmid(pmid = c(25091299, 27321766, 30513129), get_auth = TRUE) %>%
  dplyr::mutate(project = factor(pmid,
                                 levels = c(25091299, 27321766, 30513129),
                                 labels =c("STARSurg-1", "DISCOVER", "OAKS-1"))) %>%
  dplyr::select(project, author)
```

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

project

</th>

<th style="text-align:left;">

author

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

OAKS-1

</td>

<td style="text-align:left;">

Nepogodiev D, Walker K, Glasbey JC, Drake TM, Borakati A, Kamarajah S,
McLean K,…

</td>

</tr>

<tr>

<td style="text-align:left;">

DISCOVER

</td>

<td style="text-align:left;">

Drake TM, Nepogodiev D, Chapman SJ, Glasbey JC, Khatri C, Kong CY,
Claireaux HA,…

</td>

</tr>

<tr>

<td style="text-align:left;">

STARSurg-1

</td>

<td style="text-align:left;">

Chapman SJ, Glasbey J, Kelly M, Khatri C, Nepogodiev D, Fitzgerald JE,
Bhangu A,…

</td>

</tr>

</tbody>

</table>

To track collaborator involvement over time, the author names must be
matched between the groups (and dupliciates within groups excluded).
Ideally authors would be matched on orcid (or similar unique
identifier). Unfortunalely, that information is rarely stored in on-line
repositories and so authors dervied in this way must be matched by last
name and initials. However, `max_inital` allows flexiblity in how
restrictive matching authors will be.

  - If `max_inital` = 3, then the authors will be matched on their last
    name and exact initials (up to 3). This **more** restrictive
    matching will **overestimate** growth and **underestimate**
    retention (as the same person with a middle initial in one
    authorship list will be counted as two).

  - If `max_inital` = 1, then the authors will be matched on their last
    name and first initial only. This **less** restrictive matching will
    **underestimate** growth and **overestimate** retention (as people
    with the same last name and first initial will be
combined).

<!-- end list -->

``` r
example <- impact_auth(data, pub_group = "project", max_inital = 1, upset = TRUE, metric = TRUE)
```

 

## **Output**

There are 3 potential outputs from `impact_auth()` as nested dataframes:
`$auth_out`, `$upset_data`, and `$metrics`.

### **1. $auth\_out**

This will provide a basic summary of all unique collaborators across all
groups (`author`), and their involvement in each (`pub_n`,
`pub_group`).

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

author

</th>

<th style="text-align:right;">

pub\_n

</th>

<th style="text-align:left;">

pub\_group

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

makanji d

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

OAKS-1

</td>

</tr>

<tr>

<td style="text-align:left;">

luck j

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

STARSurg-1

</td>

</tr>

<tr>

<td style="text-align:left;">

mishra a

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

DISCOVER

</td>

</tr>

<tr>

<td style="text-align:left;">

maru d

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

DISCOVER

</td>

</tr>

<tr>

<td style="text-align:left;">

lim e

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

DISCOVER

</td>

</tr>

<tr>

<td style="text-align:left;">

van den berg n

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

OAKS-1

</td>

</tr>

<tr>

<td style="text-align:left;">

mccann m

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

DISCOVER

</td>

</tr>

<tr>

<td style="text-align:left;">

ahmad a

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

OAKS-1

</td>

</tr>

<tr>

<td style="text-align:left;">

marsh a

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

DISCOVER

</td>

</tr>

<tr>

<td style="text-align:left;">

wright a

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:left;">

DISCOVER

</td>

</tr>

</tbody>

</table>

This data can be used in a variety of ways, including a basic summary of
involvement over time. For example, the number of projects
authors/collaborators have been involved in:

``` r
example$auth_out %>%
  finalfit::summary_factorlist(explanatory = "pub_n", column = TRUE) %>%
  tibble::as_tibble() %>% knitr::kable() %>% kableExtra::kable_styling(bootstrap_options = "striped", full_width = F)
```

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

label

</th>

<th style="text-align:left;">

levels

</th>

<th style="text-align:left;">

all

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

pub\_n

</td>

<td style="text-align:left;">

1

</td>

<td style="text-align:left;">

2612 (89.5)

</td>

</tr>

<tr>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

2

</td>

<td style="text-align:left;">

271 (9.3)

</td>

</tr>

<tr>

<td style="text-align:left;">

</td>

<td style="text-align:left;">

3

</td>

<td style="text-align:left;">

37 (1.3)

</td>

</tr>

</tbody>

</table>

 

### **2. $data\_upset**

The `impact_auth()` function has the capability to derive information on
how the authors relate using the `upset = TRUE` arguement (default).

A subset of the `data_upset` output is displayed below. Each column is a
level from the `pub_group` variable (e.g. “project”), with `0`
representing presence and the `1` representing absence of the author
from each
project.

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:right;">

STARSurg-1

</th>

<th style="text-align:right;">

DISCOVER

</th>

<th style="text-align:right;">

OAKS-1

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

</tr>

<tr>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

</tr>

<tr>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

</tr>

<tr>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

</tr>

<tr>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

</tr>

</tbody>

</table>

This data can be used in multiple ways, for example:

#### a). Descriptive summaries:

The `data_upset` output can be used by the
[ComplexHeatmap](https://github.com/jokergoo/ComplexHeatmap) package to
derive information on the relationships between authors and the groups
(`pub_group` variable).

``` r
upset_comb_mat <- ComplexHeatmap::make_comb_mat(example$data_upset)

knitr::kable(comb_name_size(upset_comb_mat)) %>% kableExtra::kable_styling(bootstrap_options = "striped", full_width = F)
```

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

combination

</th>

<th style="text-align:right;">

n

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

STARSurg-1

</td>

<td style="text-align:right;">

306

</td>

</tr>

<tr>

<td style="text-align:left;">

DISCOVER

</td>

<td style="text-align:right;">

858

</td>

</tr>

<tr>

<td style="text-align:left;">

STARSurg-1\&DISCOVER

</td>

<td style="text-align:right;">

74

</td>

</tr>

<tr>

<td style="text-align:left;">

OAKS-1

</td>

<td style="text-align:right;">

1448

</td>

</tr>

<tr>

<td style="text-align:left;">

STARSurg-1\&OAKS-1

</td>

<td style="text-align:right;">

29

</td>

</tr>

<tr>

<td style="text-align:left;">

DISCOVER\&OAKS-1

</td>

<td style="text-align:right;">

168

</td>

</tr>

<tr>

<td style="text-align:left;">

STARSurg-1\&DISCOVER\&OAKS-1

</td>

<td style="text-align:right;">

37

</td>

</tr>

</tbody>

</table>

 

#### b). UpSet plots / Venn diagrams

UpSet plots provide an efficient way to visualize intersections of
multiple sets compared to the traditional approaches (e.g. Venn
Diagram). The `data_upset` output can be used directly to make UpSet
plots by the
[ComplexHeatmap](https://github.com/jokergoo/ComplexHeatmap) and
[UpSetR](https://github.com/hms-dbmi/UpSetR) packages.

``` r
example$data_upset %>%
  ComplexHeatmap::make_comb_mat() %>%
  ComplexHeatmap::UpSet(m = ., set_order = c("STARSurg-1", "DISCOVER", "OAKS-1"))
```

<img src="impact_auth_upset3-1.png" style="display: block; margin: auto;" />

``` r
example$data_upset %>%
  UpSetR::upset(data = ., keep.order = T, group.by = "degree",
                  sets = colnames(.), text.scale = 1.7,
                  mainbar.y.label = "STARSurg Project Participation",
                  sets.x.label = "Number of Collaborators")
```

<img src="impact_auth_upset3-2.png" style="display: block; margin: auto;" />

 

#### c). Alluvial diagrams:

Alternatively, it can be used for Alluvial diagrams to provide a
visualisation of author/collaborator involvement over time (variations
of [Sankey
diagrams](https://datavizcatalogue.com/methods/sankey_diagram.html)).

<img src="impact_auth_alluvial-1.png" style="display: block; margin: auto;" />

 

### **3. $metric**

Finally `impact_auth()` can provide metrics on author/collaborator
engagement over time (note this requires `upset=TRUE`).

``` r
knitr::kable(example$metric)%>% 
  kableExtra::kable_styling(bootstrap_options = "striped", full_width = F) %>% 
  kableExtra::scroll_box(width = "1000")
```

<div style="border: 1px solid #ddd; padding: 5px; overflow-x: scroll; width:1000; ">

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

level

</th>

<th style="text-align:right;">

n\_total

</th>

<th style="text-align:right;">

n\_total\_prior

</th>

<th style="text-align:right;">

total\_change\_prop

</th>

<th style="text-align:right;">

n\_old

</th>

<th style="text-align:right;">

n\_new

</th>

<th style="text-align:right;">

n\_new\_prior

</th>

<th style="text-align:right;">

new\_change\_prop

</th>

<th style="text-align:right;">

n\_retain

</th>

<th style="text-align:right;">

retain\_prop

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

STARSurg-1

</td>

<td style="text-align:right;">

446

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

446

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

140

</td>

<td style="text-align:right;">

0.314

</td>

</tr>

<tr>

<td style="text-align:left;">

DISCOVER

</td>

<td style="text-align:right;">

1137

</td>

<td style="text-align:right;">

446

</td>

<td style="text-align:right;">

2.549

</td>

<td style="text-align:right;">

111

</td>

<td style="text-align:right;">

1026

</td>

<td style="text-align:right;">

446

</td>

<td style="text-align:right;">

2.300

</td>

<td style="text-align:right;">

205

</td>

<td style="text-align:right;">

0.180

</td>

</tr>

<tr>

<td style="text-align:left;">

OAKS-1

</td>

<td style="text-align:right;">

1682

</td>

<td style="text-align:right;">

1137

</td>

<td style="text-align:right;">

1.479

</td>

<td style="text-align:right;">

234

</td>

<td style="text-align:right;">

1448

</td>

<td style="text-align:right;">

1026

</td>

<td style="text-align:right;">

1.411

</td>

<td style="text-align:right;">

NA

</td>

<td style="text-align:right;">

NA

</td>

</tr>

</tbody>

</table>

</div>

a). `total_change_prop` and `new_change_prop` refers to the number of
collaborators (in total or new) involved in each project compared to the
previous project.

  - A value of **1** indicates **consistant** engagement **compared with
    previous years** (stable growth).

  - A value **\>1** indicates an **increase** in engagement **compared
    with previous years** (accelerated growth).

b). `retain_prop` refers to the proportion of collaborators from each
project involved in future projects (e.g. `n_retain` / `n_total`). This
value can range from 0 (0%) to 1 (100%).
