# **On-line Attention of Research Outputs**

On-line attention and engagement for research is now well recognised as
important alternative metrics to traditional metrics (although there are
well recognised concerns regarding potential for manipuation), and has
been repeatedly found to be positively correlated with article
citations.

Altmetric is one such system that tracks the attention research outputs
receive online, and this package utilises the
[rAltmetric](https://cran.r-project.org/web/packages/rAltmetric/README.html)
package developed by the [rOpenSci](https://ropensci.org/) group to
incorporate this data.

**Note**: At present this package only includes Altmetric data. PlumX is
the other major source of alternative metrics, however there is no open
API avialable for this product (it requires an authentication token) and
so has not been incorportated at present.

## **impact\_altmetric()**

Altmetric is a system that tracks the attention that research outputs
such as scholarly articles and datasets receive online. It pulls data
from:

  - Social media like Twitter and Facebook

  - Traditional media - both mainstream (The Guardian, New York Times)
    and field specific (New Scientist, Bird Watching).

  - Blogs - both major organisations (Cancer Research UK) and individual
    researchers.

  - Online reference managers like Mendeley and CiteULike

The `impact_altmetric()` function aims to provide easy access to this
source of information in useful format. At present this required
articles to a pubmed identfication number (pmid), however functionality
to use DOI as an alternative is planned.

``` r
altmetric <- impactr::impact_altmetric(pmid)
```

## **Output**

There are 4 outputs from `impact_altmetric()` as nested dataframes:
`$df_output`, `$temporal`, `$rank`, and `$source`.

### **1. Original dataset ($df\_output)**

This will return the original dataset with data from altmetric appended
as columns. There are 4 broad groups that describes the:

  - **“alm\_score\_” prefix**: Overall altmetric score over time (see
    `$temporal` output below).

  - **“alm\_all” / “alm\_journal” prefixes**: Context of altmetric score
    relative to other articles (see `$rank` output below).

  - **“n\_engage\_” prefix**: Number of engagements with the article by
    source (see `$source` output below).

  - **“date\_” prefix**: Dates that the article was published, added to
    altmetric, and when altmetric data was last
updated.

<div style="border: 1px solid #ddd; padding: 5px; overflow-x: scroll; width:1000; ">

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

journal

</th>

<th style="text-align:right;">

pmid

</th>

<th style="text-align:left;">

doi

</th>

<th style="text-align:left;">

title

</th>

<th style="text-align:left;">

type

</th>

<th style="text-align:left;">

author list

</th>

<th style="text-align:left;">

journal issn

</th>

<th style="text-align:left;">

altmetric id

</th>

<th style="text-align:right;">

alm score 1w

</th>

<th style="text-align:right;">

alm score 1m

</th>

<th style="text-align:right;">

alm score 3m

</th>

<th style="text-align:right;">

alm score 6m

</th>

<th style="text-align:right;">

alm score 1y

</th>

<th style="text-align:right;">

alm score now

</th>

<th style="text-align:right;">

alm all mean

</th>

<th style="text-align:right;">

alm all rank

</th>

<th style="text-align:right;">

alm all n

</th>

<th style="text-align:right;">

alm all prop

</th>

<th style="text-align:right;">

alm journal all mean

</th>

<th style="text-align:right;">

alm journal all rank

</th>

<th style="text-align:right;">

alm journal all n

</th>

<th style="text-align:right;">

alm journal all prop

</th>

<th style="text-align:right;">

alm journal 3m mean

</th>

<th style="text-align:right;">

alm journal 3m rank

</th>

<th style="text-align:right;">

alm journal 3m n

</th>

<th style="text-align:right;">

alm journal 3m prop

</th>

<th style="text-align:right;">

n engage all

</th>

<th style="text-align:right;">

n engage twitter accounts

</th>

<th style="text-align:right;">

n engage twitter posts

</th>

<th style="text-align:right;">

n engage fb

</th>

<th style="text-align:right;">

n engage news media

</th>

<th style="text-align:right;">

n engage policy source

</th>

<th style="text-align:right;">

n engage peer review sites

</th>

<th style="text-align:right;">

n engage wikipedia

</th>

<th style="text-align:right;">

n engage blogs

</th>

<th style="text-align:right;">

n engage forum

</th>

<th style="text-align:right;">

n engage googleplus

</th>

<th style="text-align:right;">

n engage research highlight

</th>

<th style="text-align:right;">

n engage linkedin

</th>

<th style="text-align:right;">

n engage readers

</th>

<th style="text-align:right;">

n engage other

</th>

<th style="text-align:left;">

date update

</th>

<th style="text-align:left;">

date pub

</th>

<th style="text-align:left;">

date added

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

Anaesthesia

</td>

<td style="text-align:right;">

30656658

</td>

<td style="text-align:left;min-width: 1.5in; ">

10.1111/anae.14552

</td>

<td style="text-align:left;min-width: 7.5in; ">

Peri-operative acute kidney injury - a reply

</td>

<td style="text-align:left;">

article

</td>

<td style="text-align:left;min-width: 3in; ">

T. M. Drake, W. Ahmed, R. A. Khaw, I. Yasin, D. Baker, E. Mills, S. K.
Kamarajah…

</td>

<td style="text-align:left;">

0003-2409

</td>

<td style="text-align:left;">

54194373

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:right;">

8.338628

</td>

<td style="text-align:right;">

3916614

</td>

<td style="text-align:right;">

14189288

</td>

<td style="text-align:right;">

\-3916613

</td>

<td style="text-align:right;">

16.184855

</td>

<td style="text-align:right;">

1640

</td>

<td style="text-align:right;">

3544

</td>

<td style="text-align:right;">

0.5372460

</td>

<td style="text-align:right;">

72.70437

</td>

<td style="text-align:right;">

68

</td>

<td style="text-align:right;">

97

</td>

<td style="text-align:right;">

0.2989691

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;min-width: 1.5in; ">

2019-01-25

</td>

<td style="text-align:left;min-width: 1.5in; ">

2019-01-17

</td>

<td style="text-align:left;min-width: 1.5in; ">

2019-01-20

</td>

</tr>

<tr>

<td style="text-align:left;">

BJA

</td>

<td style="text-align:right;">

30579405

</td>

<td style="text-align:left;min-width: 1.5in; ">

10.1016/j.bja.2018.07.029

</td>

<td style="text-align:left;min-width: 7.5in; ">

Critical care usage after major gastrointestinal and liver surgery: a
prospective, multicentre observational study

</td>

<td style="text-align:left;">

article

</td>

<td style="text-align:left;min-width: 3in; ">

K.A. McLean, J.C. Glasbey, A. Borakati, T.M. Brooks, H.M. Chang, S.M.
Choi, R. G…

</td>

<td style="text-align:left;">

0007-0912

</td>

<td style="text-align:left;">

48729371

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:right;">

4.00

</td>

<td style="text-align:right;">

31.40

</td>

<td style="text-align:right;">

8.383203

</td>

<td style="text-align:right;">

582311

</td>

<td style="text-align:right;">

14322719

</td>

<td style="text-align:right;">

\-582310

</td>

<td style="text-align:right;">

7.558154

</td>

<td style="text-align:right;">

166

</td>

<td style="text-align:right;">

4261

</td>

<td style="text-align:right;">

0.9610420

</td>

<td style="text-align:right;">

14.32074

</td>

<td style="text-align:right;">

9

</td>

<td style="text-align:right;">

95

</td>

<td style="text-align:right;">

0.9052632

</td>

<td style="text-align:right;">

92

</td>

<td style="text-align:right;">

57

</td>

<td style="text-align:right;">

55

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

37

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;min-width: 1.5in; ">

2020-02-09

</td>

<td style="text-align:left;min-width: 1.5in; ">

2019-01-01

</td>

<td style="text-align:left;min-width: 1.5in; ">

2018-09-21

</td>

</tr>

<tr>

<td style="text-align:left;">

BJS Open

</td>

<td style="text-align:right;">

30513129

</td>

<td style="text-align:left;min-width: 1.5in; ">

10.1002/bjs5.86

</td>

<td style="text-align:left;min-width: 7.5in; ">

Prognostic model to predict postoperative acute kidney injury in
patients undergoing major gastrointestinal surgery based on a national
prospective observational cohort study

</td>

<td style="text-align:left;">

article

</td>

<td style="text-align:left;min-width: 3in; ">

NA

</td>

<td style="text-align:left;">

2474-9842

</td>

<td style="text-align:left;">

45614197

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

3.25

</td>

<td style="text-align:right;">

55.15

</td>

<td style="text-align:right;">

8.280699

</td>

<td style="text-align:right;">

334119

</td>

<td style="text-align:right;">

14069062

</td>

<td style="text-align:right;">

\-334118

</td>

<td style="text-align:right;">

10.861055

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

200

</td>

<td style="text-align:right;">

0.9700000

</td>

<td style="text-align:right;">

14.87250

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

21

</td>

<td style="text-align:right;">

0.9047619

</td>

<td style="text-align:right;">

218

</td>

<td style="text-align:right;">

92

</td>

<td style="text-align:right;">

92

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

28

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;min-width: 1.5in; ">

2019-05-03

</td>

<td style="text-align:left;min-width: 1.5in; ">

2018-07-27

</td>

<td style="text-align:left;min-width: 1.5in; ">

2018-07-27

</td>

</tr>

<tr>

<td style="text-align:left;">

Anaesthesia

</td>

<td style="text-align:right;">

29984818

</td>

<td style="text-align:left;min-width: 1.5in; ">

10.1111/anae.14349

</td>

<td style="text-align:left;min-width: 7.5in; ">

Association between peri‐operative angiotensin‐converting enzyme
inhibitors and angiotensin‐2 receptor blockers and acute kidney injury
in major elective non‐cardiac surgery: a multicentre, prospective cohort
study

</td>

<td style="text-align:left;">

article

</td>

<td style="text-align:left;min-width: 3in; ">

Thomas M Drake, Lok Ka Cheung, Fortis Gaba, James Glasbey, Nathan
Griffiths, Reb…

</td>

<td style="text-align:left;">

0003-2409, 1365-2044, NA

</td>

<td style="text-align:left;">

44721348

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:right;">

4.60

</td>

<td style="text-align:right;">

32.50

</td>

<td style="text-align:right;">

32.50

</td>

<td style="text-align:right;">

133.28

</td>

<td style="text-align:right;">

8.383055

</td>

<td style="text-align:right;">

124854

</td>

<td style="text-align:right;">

14321429

</td>

<td style="text-align:right;">

\-124853

</td>

<td style="text-align:right;">

16.372684

</td>

<td style="text-align:right;">

75

</td>

<td style="text-align:right;">

3567

</td>

<td style="text-align:right;">

0.9789739

</td>

<td style="text-align:right;">

33.54487

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

81

</td>

<td style="text-align:right;">

0.9135802

</td>

<td style="text-align:right;">

481

</td>

<td style="text-align:right;">

209

</td>

<td style="text-align:right;">

208

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

56

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;min-width: 1.5in; ">

2020-02-09

</td>

<td style="text-align:left;min-width: 1.5in; ">

2018-07-09

</td>

<td style="text-align:left;min-width: 1.5in; ">

2018-07-09

</td>

</tr>

<tr>

<td style="text-align:left;">

Colorectal Disease

</td>

<td style="text-align:right;">

29897171

</td>

<td style="text-align:left;min-width: 1.5in; ">

10.1111/codi.14292

</td>

<td style="text-align:left;min-width: 7.5in; ">

Body mass index and complications following major gastrointestinal
surgery: a prospective, international cohort study and meta-analysis

</td>

<td style="text-align:left;">

article

</td>

<td style="text-align:left;min-width: 3in; ">

NA

</td>

<td style="text-align:left;">

1462-8910

</td>

<td style="text-align:left;">

43673857

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

0.50

</td>

<td style="text-align:right;">

3.10

</td>

<td style="text-align:right;">

142.65

</td>

<td style="text-align:right;">

8.375431

</td>

<td style="text-align:right;">

114369

</td>

<td style="text-align:right;">

14279581

</td>

<td style="text-align:right;">

\-114368

</td>

<td style="text-align:right;">

8.473578

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

1628

</td>

<td style="text-align:right;">

0.9963145

</td>

<td style="text-align:right;">

12.13214

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

57

</td>

<td style="text-align:right;">

0.9824561

</td>

<td style="text-align:right;">

871

</td>

<td style="text-align:right;">

227

</td>

<td style="text-align:right;">

227

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

62

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;min-width: 1.5in; ">

2019-09-30

</td>

<td style="text-align:left;min-width: 1.5in; ">

2018-07-09

</td>

<td style="text-align:left;min-width: 1.5in; ">

2018-06-13

</td>

</tr>

</tbody>

</table>

</div>

### **2. Focussed Altmetric datasets**

The following outputs do not contain additional information beyond what
is already provided in `$df_output`. However, these provide long format
and focussed aspects of data to facilitate easier visualisation and
analysis. These exclude any publications not tracked by altmetric.

#### **2. a). altmetric score over time ($temporal)**

altmetric records the altmetric score contemporaneous, and at set
intervals following publication (1 week, 1 month, 3 months, 6 months, 1
year). It also records date of publication which allows calculation of a
standardised time since publication
(`alm_time`).

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

pmid

</th>

<th style="text-align:left;">

doi

</th>

<th style="text-align:left;">

date\_pub

</th>

<th style="text-align:left;">

date\_added

</th>

<th style="text-align:right;">

alm\_time

</th>

<th style="text-align:right;">

alm\_score

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

25091299

</td>

<td style="text-align:left;">

10.1002/bjs.9614

</td>

<td style="text-align:left;">

2014-08-04

</td>

<td style="text-align:left;">

2014-08-05

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

0.000

</td>

</tr>

<tr>

<td style="text-align:left;">

25091299

</td>

<td style="text-align:left;">

10.1002/bjs.9614

</td>

<td style="text-align:left;">

2014-08-04

</td>

<td style="text-align:left;">

2014-08-05

</td>

<td style="text-align:right;">

30

</td>

<td style="text-align:right;">

0.850

</td>

</tr>

<tr>

<td style="text-align:left;">

25091299

</td>

<td style="text-align:left;">

10.1002/bjs.9614

</td>

<td style="text-align:left;">

2014-08-04

</td>

<td style="text-align:left;">

2014-08-05

</td>

<td style="text-align:right;">

90

</td>

<td style="text-align:right;">

7.650

</td>

</tr>

<tr>

<td style="text-align:left;">

25091299

</td>

<td style="text-align:left;">

10.1002/bjs.9614

</td>

<td style="text-align:left;">

2014-08-04

</td>

<td style="text-align:left;">

2014-08-05

</td>

<td style="text-align:right;">

180

</td>

<td style="text-align:right;">

8.400

</td>

</tr>

<tr>

<td style="text-align:left;">

25091299

</td>

<td style="text-align:left;">

10.1002/bjs.9614

</td>

<td style="text-align:left;">

2014-08-04

</td>

<td style="text-align:left;">

2014-08-05

</td>

<td style="text-align:right;">

365

</td>

<td style="text-align:right;">

8.650

</td>

</tr>

<tr>

<td style="text-align:left;">

25091299

</td>

<td style="text-align:left;">

10.1002/bjs.9614

</td>

<td style="text-align:left;">

2014-08-04

</td>

<td style="text-align:left;">

2014-08-05

</td>

<td style="text-align:right;">

2020

</td>

<td style="text-align:right;">

115.358

</td>

</tr>

<tr>

<td style="text-align:left;">

25775005

</td>

<td style="text-align:left;">

10.1371/journal.pone.0118899

</td>

<td style="text-align:left;">

2015-03-16

</td>

<td style="text-align:left;">

2015-03-17

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

0.000

</td>

</tr>

<tr>

<td style="text-align:left;">

25775005

</td>

<td style="text-align:left;">

10.1371/journal.pone.0118899

</td>

<td style="text-align:left;">

2015-03-16

</td>

<td style="text-align:left;">

2015-03-17

</td>

<td style="text-align:right;">

30

</td>

<td style="text-align:right;">

0.000

</td>

</tr>

<tr>

<td style="text-align:left;">

25775005

</td>

<td style="text-align:left;">

10.1371/journal.pone.0118899

</td>

<td style="text-align:left;">

2015-03-16

</td>

<td style="text-align:left;">

2015-03-17

</td>

<td style="text-align:right;">

90

</td>

<td style="text-align:right;">

0.000

</td>

</tr>

</tbody>

</table>

**Figure 1**: Plot of altmetric score over time for each paper

``` r
altmetric$temporal %>% 
  ggplot() +
  aes(x = alm_time, y = alm_score, group = pmid, colour = pmid) +
  geom_line() + geom_point() + theme_bw()
```

<img src="plot/alm_plot1.png" align="center"/>

#### **2 b). altmetric ranking ($rank)**

The altmetric score is not normalised, and so it is meaningless without
context. As such, altmetric allows you to see the score relative to
other articles (whether from all indexed by altmetric or those from the
same journal at the same time). Within `$rank` these categories
(alm\_category) include:

  - **all**: All papers recorded by altmetric.

  - **journal\_all**: All papers recorded by altmetric **for that
    journal**

  - **journal\_3m**: All papers recorded by altmetric **for that journal
    within 3 month period**

For each category, altmetric records the following measures:

  - The mean altmetric score (`mean`).

  - The number (`n`) of all papers, and the rank of the specific paper
    within those (`rank`).

  - The proportion of papers (`prop`) that the paper outranks (`rank` /
    `n`).

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:right;">

pmid

</th>

<th style="text-align:left;">

doi

</th>

<th style="text-align:left;">

journal

</th>

<th style="text-align:right;">

alm\_score

</th>

<th style="text-align:left;">

alm\_category

</th>

<th style="text-align:right;">

mean

</th>

<th style="text-align:right;">

rank

</th>

<th style="text-align:right;">

n

</th>

<th style="text-align:right;">

prop

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:right;">

30656658

</td>

<td style="text-align:left;">

10.1111/anae.14552

</td>

<td style="text-align:left;">

Anaesthesia

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:left;">

all

</td>

<td style="text-align:right;">

8.338628

</td>

<td style="text-align:right;">

3916614

</td>

<td style="text-align:right;">

14189288

</td>

<td style="text-align:right;">

\-3.916613e+06

</td>

</tr>

<tr>

<td style="text-align:right;">

30656658

</td>

<td style="text-align:left;">

10.1111/anae.14552

</td>

<td style="text-align:left;">

Anaesthesia

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:left;">

journal\_all

</td>

<td style="text-align:right;">

16.184855

</td>

<td style="text-align:right;">

1640

</td>

<td style="text-align:right;">

3544

</td>

<td style="text-align:right;">

5.372460e-01

</td>

</tr>

<tr>

<td style="text-align:right;">

30656658

</td>

<td style="text-align:left;">

10.1111/anae.14552

</td>

<td style="text-align:left;">

Anaesthesia

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:left;">

journal\_3m

</td>

<td style="text-align:right;">

72.704375

</td>

<td style="text-align:right;">

68

</td>

<td style="text-align:right;">

97

</td>

<td style="text-align:right;">

2.989691e-01

</td>

</tr>

<tr>

<td style="text-align:right;">

30579405

</td>

<td style="text-align:left;">

10.1016/j.bja.2018.07.029

</td>

<td style="text-align:left;">

BJA

</td>

<td style="text-align:right;">

31.40

</td>

<td style="text-align:left;">

all

</td>

<td style="text-align:right;">

8.383203

</td>

<td style="text-align:right;">

582311

</td>

<td style="text-align:right;">

14322719

</td>

<td style="text-align:right;">

\-5.823100e+05

</td>

</tr>

<tr>

<td style="text-align:right;">

30579405

</td>

<td style="text-align:left;">

10.1016/j.bja.2018.07.029

</td>

<td style="text-align:left;">

BJA

</td>

<td style="text-align:right;">

31.40

</td>

<td style="text-align:left;">

journal\_all

</td>

<td style="text-align:right;">

7.558154

</td>

<td style="text-align:right;">

166

</td>

<td style="text-align:right;">

4261

</td>

<td style="text-align:right;">

9.610420e-01

</td>

</tr>

<tr>

<td style="text-align:right;">

30579405

</td>

<td style="text-align:left;">

10.1016/j.bja.2018.07.029

</td>

<td style="text-align:left;">

BJA

</td>

<td style="text-align:right;">

31.40

</td>

<td style="text-align:left;">

journal\_3m

</td>

<td style="text-align:right;">

14.320745

</td>

<td style="text-align:right;">

9

</td>

<td style="text-align:right;">

95

</td>

<td style="text-align:right;">

9.052632e-01

</td>

</tr>

<tr>

<td style="text-align:right;">

30513129

</td>

<td style="text-align:left;">

10.1002/bjs5.86

</td>

<td style="text-align:left;">

BJS Open

</td>

<td style="text-align:right;">

55.15

</td>

<td style="text-align:left;">

all

</td>

<td style="text-align:right;">

8.280699

</td>

<td style="text-align:right;">

334119

</td>

<td style="text-align:right;">

14069062

</td>

<td style="text-align:right;">

\-3.341180e+05

</td>

</tr>

<tr>

<td style="text-align:right;">

30513129

</td>

<td style="text-align:left;">

10.1002/bjs5.86

</td>

<td style="text-align:left;">

BJS Open

</td>

<td style="text-align:right;">

55.15

</td>

<td style="text-align:left;">

journal\_all

</td>

<td style="text-align:right;">

10.861055

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

200

</td>

<td style="text-align:right;">

9.700000e-01

</td>

</tr>

<tr>

<td style="text-align:right;">

30513129

</td>

<td style="text-align:left;">

10.1002/bjs5.86

</td>

<td style="text-align:left;">

BJS Open

</td>

<td style="text-align:right;">

55.15

</td>

<td style="text-align:left;">

journal\_3m

</td>

<td style="text-align:right;">

14.872500

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

21

</td>

<td style="text-align:right;">

9.047619e-01

</td>

</tr>

</tbody>

</table>

``` r
altmetric$rank %>%
  dplyr::mutate(journal = gsub(": The British Journal of Anaesthesia", "", journal),
                pmid = as.character(pmid)) %>%
  dplyr::mutate("Altmetric Ranking (%)" = round((1 - (rank-1)/n)*100, 1),
                "Altmetric Category" = factor(as.character(alm_category),
                                      levels=c("all", "journal_all", "journal_3m"),
                                      labels=c("All Altmetric",
                                               "All from Journal",
                                               "All from Journal within 3 months"))) %>%
  ggplot() +
  aes(x = `Altmetric Category`, y = `Altmetric Ranking (%)`) +
  geom_point() + geom_boxplot() +
  theme_bw()
```

**Figure 3**: Plot of the percentage rank of each publication within
each altmetric category.

<img src="plot/alm_plot2.png" align="center"/>

#### **2 c). altmetric sources ($source)**

The Altmetric score for a research output provides an indicator of the
amount of attention that it has received from, and as such records both
the type and amount of attention recieved. This data excludes any
sources **not** recorded for any of the
papers.

<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">

<thead>

<tr>

<th style="text-align:left;">

pmid

</th>

<th style="text-align:left;">

doi

</th>

<th style="text-align:left;">

source

</th>

<th style="text-align:right;">

n

</th>

<th style="text-align:right;">

total

</th>

<th style="text-align:right;">

prop

</th>

</tr>

</thead>

<tbody>

<tr>

<td style="text-align:left;">

30656658

</td>

<td style="text-align:left;">

10.1111/anae.14552

</td>

<td style="text-align:left;">

twitter

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

0.7500000

</td>

</tr>

<tr>

<td style="text-align:left;">

30656658

</td>

<td style="text-align:left;">

10.1111/anae.14552

</td>

<td style="text-align:left;">

fb

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

0.0000000

</td>

</tr>

<tr>

<td style="text-align:left;">

30656658

</td>

<td style="text-align:left;">

10.1111/anae.14552

</td>

<td style="text-align:left;">

news\_media

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

0.0000000

</td>

</tr>

<tr>

<td style="text-align:left;">

30656658

</td>

<td style="text-align:left;">

10.1111/anae.14552

</td>

<td style="text-align:left;">

wikipedia

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

0.0000000

</td>

</tr>

<tr>

<td style="text-align:left;">

30656658

</td>

<td style="text-align:left;">

10.1111/anae.14552

</td>

<td style="text-align:left;">

blogs

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

0.0000000

</td>

</tr>

<tr>

<td style="text-align:left;">

30656658

</td>

<td style="text-align:left;">

10.1111/anae.14552

</td>

<td style="text-align:left;">

readers

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

8

</td>

<td style="text-align:right;">

0.2500000

</td>

</tr>

<tr>

<td style="text-align:left;">

30579405

</td>

<td style="text-align:left;">

10.1016/j.bja.2018.07.029

</td>

<td style="text-align:left;">

twitter

</td>

<td style="text-align:right;">

57

</td>

<td style="text-align:right;">

96

</td>

<td style="text-align:right;">

0.5937500

</td>

</tr>

<tr>

<td style="text-align:left;">

30579405

</td>

<td style="text-align:left;">

10.1016/j.bja.2018.07.029

</td>

<td style="text-align:left;">

fb

</td>

<td style="text-align:right;">

2

</td>

<td style="text-align:right;">

96

</td>

<td style="text-align:right;">

0.0208333

</td>

</tr>

<tr>

<td style="text-align:left;">

30579405

</td>

<td style="text-align:left;">

10.1016/j.bja.2018.07.029

</td>

<td style="text-align:left;">

news\_media

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

96

</td>

<td style="text-align:right;">

0.0000000

</td>

</tr>

<tr>

<td style="text-align:left;">

30579405

</td>

<td style="text-align:left;">

10.1016/j.bja.2018.07.029

</td>

<td style="text-align:left;">

wikipedia

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

96

</td>

<td style="text-align:right;">

0.0000000

</td>

</tr>

<tr>

<td style="text-align:left;">

30579405

</td>

<td style="text-align:left;">

10.1016/j.bja.2018.07.029

</td>

<td style="text-align:left;">

blogs

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

96

</td>

<td style="text-align:right;">

0.0000000

</td>

</tr>

<tr>

<td style="text-align:left;">

30579405

</td>

<td style="text-align:left;">

10.1016/j.bja.2018.07.029

</td>

<td style="text-align:left;">

readers

</td>

<td style="text-align:right;">

37

</td>

<td style="text-align:right;">

96

</td>

<td style="text-align:right;">

0.3854167

</td>

</tr>

</tbody>

</table>

**Figure 3**: Plot of the proportion of altmetric sources for each paper

``` r
altmetric$source %>% 
  ggplot() +
  aes(x = pmid, y = prop, colour = source, fill = source) +
  geom_col() + coord_flip()+ theme_bw()
```

<img src="plot/alm_plot3.png" align="center"/>
