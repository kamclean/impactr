# **Citation of Research Outputs**

The most common vehicles for research impact tend to be for
presentations and publications of the work conducted. These often are
often listed at both an individual- (CV) and institutional-level to
demonstrate scholary activity.

## **1. `ref_publication()`**

The `ref_publication()` function will accept direct input from both
`extract_pmid()` and `extract_doi()`, however will also accept other
dataframes with the prerequisite columns. These columns can be specified
within the function. Other features include:

  - Highlighting any missing data essential for citation (e.g. author,
    journal, etc). The issue, pmid, and doi are considered optional
    (depending on whether the dataset was generated from
    `extract_pmid()` or `extract_doi()`).

  - Automatically displaying all authors, however the auth\_max can be
    set from 1 to n to add “et al.” for any authors beyond that number.

  - The format can be customised via `ref_format` to match preferred
    referencing style (default is as shown below - Vancouver). Note the
    variable names in the string must exactly match an essential column
    (e.g. “author” not “Author” or “AUTHOR”)

<!-- end list -->

``` r
 out_doi %>%
  # If a single-authorship collaborative publication (e.g. "STARSurg Collaborative") then display that
  dplyr::mutate(author = ifelse(is.na(author_group)==TRUE, author, author_group)) %>%
  
  impactr::ref_publication(journal = "journal_full", max_auth = 10,
                   ref_format = "author. title. journal. year; volume (issue): pages. PMID: pmid. DOI: doi.") %>%
  
  dplyr::mutate(citation = gsub("\\]", "", gsub("\\[", "", as.character(citation)))) %>%
  dplyr::select(citation) %>%
  knitr::kable(format="html") %>% kableExtra::kable_styling(bootstrap_options = "striped", full_width = F)
```

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

citation

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Incomplete citation data: author.

</td>

</tr>

<tr>

<td style="text-align:left;">

Nepogodiev D, Chapman SJ, Glasbey J, Kelly M, Khatri C, Drake TM, Kong
CY, Mitchell H, Harrison EM, Fitzgerald JE, et al. Determining Surgical
Complications in the Overweight (DISCOVER): a multicentre observational
cohort study to evaluate the role of obesity as a risk factor for
postoperative complications in general surgery. BMJ Open. 2015; 5 (7):
e008811. DOI: <http://dx.doi.org/10.1136/bmjopen-2015-008811>.

</td>

</tr>

<tr>

<td style="text-align:left;">

STARSurg Collaborative. Prognostic model to predict postoperative acute
kidney injury in patients undergoing major gastrointestinal surgery
based on a national prospective observational cohort study. BJS Open.
2018; 2 (6): 400-410. DOI: <http://dx.doi.org/10.1002/bjs5.86>.

</td>

</tr>

</tbody>

</table>

 

## **2. `ref_presentation()`**

Presentations of academic work are important additional research
outputs, yet are often not recorded online and so cannot be extracted.
Therefore, the `ref_presentation()` function will accept any dataframe
with the prerequisite columns. The columns can be specified within the
function. Other features include:

  - Highlighting any missing data essential for citation (e.g. author,
    name of meeting/conference, etc). The type or level or presentation,
    and the date of the meeting/conference are considered optional for
    the purposes of citation.

  - The format can be customised via `ref_format` to match preferred
    referencing style. Note the variable names in the string must
    exactly match an essential column (e.g. “author” not “Author” or
    “AUTHOR”)

<div style="border: 1px solid #ddd; padding: 5px; overflow-x: scroll; width:1000px; ">

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

type

</th>

<th style="text-align:left;">

level

</th>

<th style="text-align:left;">

title

</th>

<th style="text-align:left;">

con org

</th>

<th style="text-align:left;">

con name

</th>

<th style="text-align:left;">

con date start

</th>

<th style="text-align:left;">

con date end

</th>

<th style="text-align:left;">

con city

</th>

<th style="text-align:left;">

con country

</th>

<th style="text-align:left;">

author

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;min-width: 1.5in; ">

Poster

</td>

<td style="text-align:left;">

International

</td>

<td style="text-align:left;min-width: 7in; ">

The effects of perioperative Angiotensin Converting Enzyme Inhibitors
and Angiotensin Receptor Blockers on acute kidney injury in major
elective non-cardiac surgery. A multicentre, prospective cohort study.

</td>

<td style="text-align:left;min-width: 3in; ">

ESCP (European Society of Coloproctology)

</td>

<td style="text-align:left;min-width: 3in; ">

International Conference 2018

</td>

<td style="text-align:left;">

2018-09-26

</td>

<td style="text-align:left;">

2018-09-28

</td>

<td style="text-align:left;">

Nice

</td>

<td style="text-align:left;min-width: 1.5in; ">

France

</td>

<td style="text-align:left;min-width: 3in; ">

STARSurg Collaborative

</td>

</tr>

<tr>

<td style="text-align:left;min-width: 1.5in; ">

Poster

</td>

<td style="text-align:left;">

International

</td>

<td style="text-align:left;min-width: 7in; ">

The impact of intravenous contrast on post-operative acute kidney injury
following major gastrointestinal and liver surgery

</td>

<td style="text-align:left;min-width: 3in; ">

ESCP (European Society of Coloproctology)

</td>

<td style="text-align:left;min-width: 3in; ">

International Conference 2018

</td>

<td style="text-align:left;">

2018-09-26

</td>

<td style="text-align:left;">

2018-09-28

</td>

<td style="text-align:left;">

Nice

</td>

<td style="text-align:left;min-width: 1.5in; ">

France

</td>

<td style="text-align:left;min-width: 3in; ">

STARSurg Collaborative

</td>

</tr>

<tr>

<td style="text-align:left;min-width: 1.5in; ">

Oral

</td>

<td style="text-align:left;">

International

</td>

<td style="text-align:left;min-width: 7in; ">

EuroSurg Student Initiative - IMAGINE Study: Preliminary Results

</td>

<td style="text-align:left;min-width: 3in; ">

ESCP (European Society of Coloproctology)

</td>

<td style="text-align:left;min-width: 3in; ">

International Conference 2018

</td>

<td style="text-align:left;">

2018-09-26

</td>

<td style="text-align:left;">

2018-09-28

</td>

<td style="text-align:left;">

Nice

</td>

<td style="text-align:left;min-width: 1.5in; ">

France

</td>

<td style="text-align:left;min-width: 3in; ">

EuroSurg Collaborative

</td>

</tr>

<tr>

<td style="text-align:left;min-width: 1.5in; ">

Oral

</td>

<td style="text-align:left;">

International

</td>

<td style="text-align:left;min-width: 7in; ">

NA

</td>

<td style="text-align:left;min-width: 3in; ">

RSM (Royal Society of Medicine)

</td>

<td style="text-align:left;min-width: 3in; ">

doctor as a scholar and a scientist: international research course for
medical students and foundation year doctors

</td>

<td style="text-align:left;">

2018-10-13

</td>

<td style="text-align:left;">

2018-10-13

</td>

<td style="text-align:left;">

London

</td>

<td style="text-align:left;min-width: 1.5in; ">

UK

</td>

<td style="text-align:left;min-width: 3in; ">

STARSurg Collaborative

</td>

</tr>

<tr>

<td style="text-align:left;min-width: 1.5in; ">

Oral-Poster

</td>

<td style="text-align:left;">

International

</td>

<td style="text-align:left;min-width: 7in; ">

Perioperative non-steroidal anti-inflammatory drugs (NSAID)
administration and Acute Kidney Injury (AKI) in major gastrointestinal
surgery: A national, multicentre, propensity matched cohort study

</td>

<td style="text-align:left;min-width: 3in; ">

ASiT (Association of Surgeons in Training)

</td>

<td style="text-align:left;min-width: 3in; ">

ASIT Conference

</td>

<td style="text-align:left;">

2019-03-22

</td>

<td style="text-align:left;">

2019-03-23

</td>

<td style="text-align:left;">

Belfast

</td>

<td style="text-align:left;min-width: 1.5in; ">

United
Kingdom

</td>

<td style="text-align:left;min-width: 3in; ">

NA

</td>

</tr>

</tbody>

</table>

</div>

 

``` r
impactr::ref_presentation(data_presentations, ref_format = "author. title. con_org con_name, con_date_range, con_city (con_country).") %>%
  
  dplyr::mutate(citation = gsub("\\]", "", gsub("\\[", "", as.character(citation)))) %>%
  dplyr::select(citation) %>%
  knitr::kable(format="html") %>% kableExtra::kable_styling(bootstrap_options = "striped", full_width = F)
```

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

citation

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

STARSurg Collaborative. The effects of perioperative Angiotensin
Converting Enzyme Inhibitors and Angiotensin Receptor Blockers on acute
kidney injury in major elective non-cardiac surgery. A multicentre,
prospective cohort study. ESCP (European Society of Coloproctology)
International Conference 2018, 26th to 28th September 2018, Nice
(France).

</td>

</tr>

<tr>

<td style="text-align:left;">

STARSurg Collaborative. The impact of intravenous contrast on
post-operative acute kidney injury following major gastrointestinal and
liver surgery. ESCP (European Society of Coloproctology) International
Conference 2018, 26th to 28th September 2018, Nice (France).

</td>

</tr>

<tr>

<td style="text-align:left;">

EuroSurg Collaborative. EuroSurg Student Initiative - IMAGINE Study:
Preliminary Results. ESCP (European Society of Coloproctology)
International Conference 2018, 26th to 28th September 2018, Nice
(France).

</td>

</tr>

<tr>

<td style="text-align:left;">

Incomplete citation data: title.

</td>

</tr>

<tr>

<td style="text-align:left;">

Incomplete citation data: author.

</td>

</tr>

</tbody>

</table>
