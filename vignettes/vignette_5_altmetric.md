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

## **impact\_almetric()**

Altmetric is a system that tracks the attention that research outputs
such as scholarly articles and datasets receive online. It pulls data
from:

  - Social media like Twitter and Facebook

  - Traditional media - both mainstream (The Guardian, New York Times)
    and field specific (New Scientist, Bird Watching).

  - Blogs - both major organisations (Cancer Research UK) and individual
    researchers.

  - Online reference managers like Mendeley and CiteULike

The `impact_almetric()` function aims to provide easy access to this
source of information in useful format. At present this required
articles to a pubmed identfication number (pmid), however functionality
to use DOI as an alternative is planned.

``` r
almetric <- impact_almetric(data_pub$pmid)
```

## **Output**

There are 4 outputs from `impact_almetric()` as nested dataframes:
`$df_output`, `$temporal`, `$rank`, and `$source`.

### **1. Original dataset ($df\_output)**

This will return the original dataset with data from almetric appended
as columns. There are 4 broad groups that describes the:

  - **“alm\_score\_” prefix**: Overall almetric score over time (see
    `$temporal` output below).

  - **“alm\_all” / “alm\_journal” prefixes**: Context of almetric score
    relative to other articles (see `$rank` output below).

  - **“n\_engage\_” prefix**: Number of engagements with the article by
    source (see `$source` output below).

  - **“date\_” prefix**: Dates that the article was published, added to
    almetric, and when almetric data was last
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

author\_list

</th>

<th style="text-align:left;">

journal\_issn

</th>

<th style="text-align:left;">

altmetric\_id

</th>

<th style="text-align:right;">

alm\_score\_1w

</th>

<th style="text-align:right;">

alm\_score\_1m

</th>

<th style="text-align:right;">

alm\_score\_3m

</th>

<th style="text-align:right;">

alm\_score\_6m

</th>

<th style="text-align:right;">

alm\_score\_1y

</th>

<th style="text-align:right;">

alm\_score\_now

</th>

<th style="text-align:right;">

alm\_all\_mean

</th>

<th style="text-align:right;">

alm\_all\_rank

</th>

<th style="text-align:right;">

alm\_all\_n

</th>

<th style="text-align:right;">

alm\_all\_prop

</th>

<th style="text-align:right;">

alm\_journal\_all\_mean

</th>

<th style="text-align:right;">

alm\_journal\_all\_rank

</th>

<th style="text-align:right;">

alm\_journal\_all\_n

</th>

<th style="text-align:right;">

alm\_journal\_all\_prop

</th>

<th style="text-align:right;">

alm\_journal\_3m\_mean

</th>

<th style="text-align:right;">

alm\_journal\_3m\_rank

</th>

<th style="text-align:right;">

alm\_journal\_3m\_n

</th>

<th style="text-align:right;">

alm\_journal\_3m\_prop

</th>

<th style="text-align:left;">

n\_engage\_all

</th>

<th style="text-align:left;">

n\_engage\_twitter\_accounts

</th>

<th style="text-align:left;">

n\_engage\_twitter\_posts

</th>

<th style="text-align:left;">

n\_engage\_fb

</th>

<th style="text-align:left;">

n\_engage\_news\_media

</th>

<th style="text-align:right;">

n\_engage\_policy\_source

</th>

<th style="text-align:right;">

n\_engage\_peer\_review\_sites

</th>

<th style="text-align:left;">

n\_engage\_wikipedia

</th>

<th style="text-align:left;">

n\_engage\_blogs

</th>

<th style="text-align:right;">

n\_engage\_forum

</th>

<th style="text-align:right;">

n\_engage\_googleplus

</th>

<th style="text-align:right;">

n\_engage\_research\_highlight

</th>

<th style="text-align:right;">

n\_engage\_linkedin

</th>

<th style="text-align:left;">

n\_engage\_readers

</th>

<th style="text-align:right;">

n\_engage\_other

</th>

<th style="text-align:left;">

date\_update

</th>

<th style="text-align:left;">

date\_pub

</th>

<th style="text-align:left;">

date\_added

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

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.0

</td>

<td style="text-align:right;">

0.00

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:right;">

3.75

</td>

<td style="text-align:right;">

8.062658

</td>

<td style="text-align:right;">

3642028

</td>

<td style="text-align:right;">

13404018

</td>

<td style="text-align:right;">

0.7282883

</td>

<td style="text-align:right;">

14.99963

</td>

<td style="text-align:right;">

1510

</td>

<td style="text-align:right;">

3393

</td>

<td style="text-align:right;">

0.5549661

</td>

<td style="text-align:right;">

70.27167

</td>

<td style="text-align:right;">

69

</td>

<td style="text-align:right;">

97

</td>

<td style="text-align:right;">

0.2886598

</td>

<td style="text-align:left;">

7

</td>

<td style="text-align:left;">

6

</td>

<td style="text-align:left;">

6

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:left;">

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

<td style="text-align:left;">

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

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.0

</td>

<td style="text-align:right;">

0.25

</td>

<td style="text-align:right;">

33.85

</td>

<td style="text-align:right;">

33.85

</td>

<td style="text-align:right;">

8.024820

</td>

<td style="text-align:right;">

478772

</td>

<td style="text-align:right;">

13318908

</td>

<td style="text-align:right;">

0.9640532

</td>

<td style="text-align:right;">

7.13592

</td>

<td style="text-align:right;">

119

</td>

<td style="text-align:right;">

4055

</td>

<td style="text-align:right;">

0.9706535

</td>

<td style="text-align:right;">

14.96613

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

94

</td>

<td style="text-align:right;">

0.9255319

</td>

<td style="text-align:left;">

84

</td>

<td style="text-align:left;">

58

</td>

<td style="text-align:left;">

56

</td>

<td style="text-align:left;">

2

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:left;">

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

<td style="text-align:left;">

18

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;min-width: 1.5in; ">

2019-04-11

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

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.0

</td>

<td style="text-align:right;">

0.50

</td>

<td style="text-align:right;">

36.20

</td>

<td style="text-align:right;">

57.35

</td>

<td style="text-align:right;">

8.062658

</td>

<td style="text-align:right;">

293809

</td>

<td style="text-align:right;">

13404018

</td>

<td style="text-align:right;">

0.9780805

</td>

<td style="text-align:right;">

10.90774

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

169

</td>

<td style="text-align:right;">

0.9704142

</td>

<td style="text-align:right;">

15.02250

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

<td style="text-align:left;">

221

</td>

<td style="text-align:left;">

95

</td>

<td style="text-align:left;">

95

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:left;">

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

<td style="text-align:left;">

21

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

0003-2409, 1365-2044

</td>

<td style="text-align:left;">

44721348

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0.0

</td>

<td style="text-align:right;">

1.25

</td>

<td style="text-align:right;">

39.13

</td>

<td style="text-align:right;">

113.68

</td>

<td style="text-align:right;">

8.073367

</td>

<td style="text-align:right;">

134027

</td>

<td style="text-align:right;">

13439767

</td>

<td style="text-align:right;">

0.9900276

</td>

<td style="text-align:right;">

15.07054

</td>

<td style="text-align:right;">

76

</td>

<td style="text-align:right;">

3400

</td>

<td style="text-align:right;">

0.9776471

</td>

<td style="text-align:right;">

32.69888

</td>

<td style="text-align:right;">

6

</td>

<td style="text-align:right;">

81

</td>

<td style="text-align:right;">

0.9259259

</td>

<td style="text-align:left;">

338

</td>

<td style="text-align:left;">

177

</td>

<td style="text-align:left;">

176

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:left;">

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

<td style="text-align:left;">

30

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;min-width: 1.5in; ">

2019-05-06

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

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

3.1

</td>

<td style="text-align:right;">

3.10

</td>

<td style="text-align:right;">

25.25

</td>

<td style="text-align:right;">

146.85

</td>

<td style="text-align:right;">

8.027434

</td>

<td style="text-align:right;">

95764

</td>

<td style="text-align:right;">

13324898

</td>

<td style="text-align:right;">

0.9928132

</td>

<td style="text-align:right;">

7.64457

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

1437

</td>

<td style="text-align:right;">

0.9965205

</td>

<td style="text-align:right;">

14.32717

</td>

<td style="text-align:right;">

1

</td>

<td style="text-align:right;">

47

</td>

<td style="text-align:right;">

0.9787234

</td>

<td style="text-align:left;">

877

</td>

<td style="text-align:left;">

233

</td>

<td style="text-align:left;">

233

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;">

0

</td>

<td style="text-align:left;">

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

<td style="text-align:left;">

31

</td>

<td style="text-align:right;">

0

</td>

<td style="text-align:left;min-width: 1.5in; ">

2019-06-25

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

#### **2. a). Almetric score over time ($temporal)**

Almetric records the almetric score contemporaneous, and at set
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

0.750

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

1.250

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

1.750

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

1.750

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

1.750

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

1853

</td>

<td style="text-align:right;">

113.008

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

5.450

</td>

</tr>

</tbody>

</table>

**Plot of almetric score over time**

``` r
almetric$temporal %>% 
  ggplot() +
  aes(x = alm_time, y = alm_score, group = pmid, colour = pmid) +
  geom_line() + geom_point() + theme_bw()
```

<img src="/tmp/Rtmpx7a3jU/preview-ca7128dfc261.dir/vignette_5_altmetric_files/figure-gfm/impact_almetric_plot1-1.png" style="display: block; margin: auto;" />

#### **2 b). Almetric ranking ($rank)**

The almetric score is not normalised, and so it is meaningless without
context. As such, almetric allows you to see the score relative to other
articles (whether from all indexed by almetric or those from the same
journal at the same time). Within `$rank` these categories
(alm\_category) include:

  - **all**: All papers recorded by almetric.

  - **journal\_all**: All papers recorded by almetric **for that
    journal**

  - **journal\_3m**: All papers recorded by almetric **for that journal
    within 3 month period**

For each category, almetric records the following measures:

  - The mean almetric score (`mean`).

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

8.062658

</td>

<td style="text-align:right;">

3642028

</td>

<td style="text-align:right;">

13404018

</td>

<td style="text-align:right;">

0.7282883

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

14.999629

</td>

<td style="text-align:right;">

1510

</td>

<td style="text-align:right;">

3393

</td>

<td style="text-align:right;">

0.5549661

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

70.271667

</td>

<td style="text-align:right;">

69

</td>

<td style="text-align:right;">

97

</td>

<td style="text-align:right;">

0.2886598

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

33.85

</td>

<td style="text-align:left;">

all

</td>

<td style="text-align:right;">

8.024820

</td>

<td style="text-align:right;">

478772

</td>

<td style="text-align:right;">

13318908

</td>

<td style="text-align:right;">

0.9640532

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

33.85

</td>

<td style="text-align:left;">

journal\_all

</td>

<td style="text-align:right;">

7.135920

</td>

<td style="text-align:right;">

119

</td>

<td style="text-align:right;">

4055

</td>

<td style="text-align:right;">

0.9706535

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

33.85

</td>

<td style="text-align:left;">

journal\_3m

</td>

<td style="text-align:right;">

14.966129

</td>

<td style="text-align:right;">

7

</td>

<td style="text-align:right;">

94

</td>

<td style="text-align:right;">

0.9255319

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

57.35

</td>

<td style="text-align:left;">

all

</td>

<td style="text-align:right;">

8.062658

</td>

<td style="text-align:right;">

293809

</td>

<td style="text-align:right;">

13404018

</td>

<td style="text-align:right;">

0.9780805

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

57.35

</td>

<td style="text-align:left;">

journal\_all

</td>

<td style="text-align:right;">

10.907738

</td>

<td style="text-align:right;">

5

</td>

<td style="text-align:right;">

169

</td>

<td style="text-align:right;">

0.9704142

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

57.35

</td>

<td style="text-align:left;">

journal\_3m

</td>

<td style="text-align:right;">

15.022500

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

</tr>

</tbody>

</table>

#### **2 c). Almetric sources ($source)**

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

58

</td>

<td style="text-align:right;">

78

</td>

<td style="text-align:right;">

0.7435897

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

78

</td>

<td style="text-align:right;">

0.0256410

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

78

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

78

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

78

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

18

</td>

<td style="text-align:right;">

78

</td>

<td style="text-align:right;">

0.2307692

</td>

</tr>

</tbody>

</table>

**Plot of the proportion of almetric sources for each paper**

``` r
almetric$source %>% 
  ggplot() +
  aes(x = pmid, y = prop, colour = source, fill = source) +
  geom_col() + coord_flip()+ theme_bw()
```

<img src="/tmp/Rtmpx7a3jU/preview-ca7128dfc261.dir/vignette_5_altmetric_files/figure-gfm/impact_almetric_plot2-1.png" style="display: block; margin: auto;" />
