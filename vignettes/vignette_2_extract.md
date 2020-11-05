**Extract Publication Data**
============================

Keeping accurate and up-to-date information regarding the output from an
author / research group can be a time-consuming task, however remains
essential in order to evaluate the research impact. There are multiple
repositories on-line such as PubMed or CrossRef which store this
information, and can already be accessed using an API in R in order to
extract this data on an automatic basis.

There are excellent packages that already exist to access this data -
[RISmed](https://cran.r-project.org/web/packages/RISmed/RISmed.pdf) for
PubMed and [rcrossref](https://github.com/ropensci/rcrossref) for
CrossRef. While these provide a vast quantity of useful information,
this is often outwith a dataframe/tibble format and so requires a
significant quantity of post-processing to otherwise achieve an easily
usable output.

 

**1. Extract Data**
-------------------

The functions `extract_pmid()` (PubMed) and `extract_doi()` (CrossRef)
use unique identifiers to extract important information regarding
publications. This can be used for the purposes of citation, cataloguing
publications, or for further evaluation of impact (see **ImpactR:
Citations**).

However, it should be noted that the information extracted is dependent
on the accuracy and completeness of the information within these
repositories. Therefore, some additional editing may be required to
remove heterogeneity / make corrections / supply missing data.

### **a). `extract_pmid()`**

The `extract_pmid()` function only requires a vector/list of PubMed
identification numbers to extract publication information.

The function will automatically extract the authors (`auth_group`,
`auth_n`, `authors`), and the associated altmetric score (`altmetric`).
However, this functionality has been made optional as it can extend the
run time of the function (particularly in the case of a large number of
authors).

    out_pubmed <- impactr::extract_pmid(pmid = c(26769786, 26195471, 30513129),
                                        get_altmetric = FALSE, get_impact = FALSE)

    ## [1] "Chunk 1"
    ## [1] 1
    ## [1] 2
    ## [1] 3

<div style="border: 1px solid #ddd; padding: 5px; overflow-x: scroll; width:1000px; ">
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
pmc
</th>
<th style="text-align:left;">
title
</th>
<th style="text-align:left;">
journal\_nlm
</th>
<th style="text-align:left;">
journal\_issn
</th>
<th style="text-align:left;">
journal\_full
</th>
<th style="text-align:left;">
journal\_abbr
</th>
<th style="text-align:left;">
journal\_vol
</th>
<th style="text-align:left;">
journal\_issue
</th>
<th style="text-align:left;">
journal\_pages
</th>
<th style="text-align:right;">
author\_n
</th>
<th style="text-align:left;">
author\_list
</th>
<th style="text-align:left;">
author\_group
</th>
<th style="text-align:right;">
collab\_n
</th>
<th style="text-align:left;">
collab\_list
</th>
<th style="text-align:left;">
type
</th>
<th style="text-align:left;">
status
</th>
<th style="text-align:left;">
date\_publish
</th>
<th style="text-align:right;">
year
</th>
<th style="text-align:left;">
author
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;">
26769786
</td>
<td style="text-align:left;">
10.1136/bmjopen-2015-009812
</td>
<td style="text-align:left;">
PMC4735315
</td>
<td style="text-align:left;min-width: 6in; ">
Outcomes After Kidney injury in Surgery (OAKS): protocol for a
multicentre, observational cohort study of acute kidney injury following
major gastrointestinal and liver surgery.
</td>
<td style="text-align:left;">
101552874
</td>
<td style="text-align:left;">
2044-6055, 2044-6055
</td>
<td style="text-align:left;">
BMJ open
</td>
<td style="text-align:left;">
BMJ Open
</td>
<td style="text-align:left;">
6
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
e009812
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
STARSurg Collaborative
</td>
<td style="text-align:right;">
40
</td>
<td style="text-align:left;">
Bath M; Glasbey J; Claireaux H; Drake T; Gundogan B; Khatri C; Kong N;
McNamee L; Mohan M; Amin H; Barai I; Bhanderi S; Brown FS; Chapman SJ;
Corbridge O; Cumber E; Deekonda P; Dennis Y; Gokani V; Ibrahim I;
Kamarajah SK; Logan AE; Mills A; Phan PN; Robinson C; Sethi R; Shaw A;
Suresh R; Suresh S; Wigley C; Wilson H; Arulkumaran N; Richards T;
Duthie F; Thomas M; Prowle J; Harrison E; Fitzgerald JE; Bhangu A;
Nepogodiev D
</td>
<td style="text-align:left;">
Journal Article, Multicenter Study, Observational Study, Research
Support, Non-U.S. Gov’t
</td>
<td style="text-align:left;">
epublish
</td>
<td style="text-align:left;">
2016-01-14
</td>
<td style="text-align:right;">
2016
</td>
<td style="text-align:left;">
NA…
</td>
</tr>
<tr>
<td style="text-align:left;">
26195471
</td>
<td style="text-align:left;">
10.1136/bmjopen-2015-008811
</td>
<td style="text-align:left;">
PMC4513439
</td>
<td style="text-align:left;min-width: 6in; ">
Determining Surgical Complications in the Overweight (DISCOVER): a
multicentre observational cohort study to evaluate the role of obesity
as a risk factor for postoperative complications in general surgery.
</td>
<td style="text-align:left;">
101552874
</td>
<td style="text-align:left;">
2044-6055, 2044-6055
</td>
<td style="text-align:left;">
BMJ open
</td>
<td style="text-align:left;">
BMJ Open
</td>
<td style="text-align:left;">
5
</td>
<td style="text-align:left;">
7
</td>
<td style="text-align:left;">
e008811
</td>
<td style="text-align:right;">
11
</td>
<td style="text-align:left;">
Nepogodiev D; Chapman SJ; Glasbey J; Kelly M; Khatri C; Drake TM; Kong
CY; Mitchell H; Harrison EM; Fitzgerald JE; Bhangu A
</td>
<td style="text-align:left;">
STARSurg Collaborative
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
Journal Article, Multicenter Study, Observational Study, Research
Support, Non-U.S. Gov’t
</td>
<td style="text-align:left;">
epublish
</td>
<td style="text-align:left;">
2015-07-20
</td>
<td style="text-align:right;">
2015
</td>
<td style="text-align:left;">
Nepogodiev D; Chapman SJ; Glasbey J; Kelly M; Khat…
</td>
</tr>
<tr>
<td style="text-align:left;">
30513129
</td>
<td style="text-align:left;">
10.1002/bjs5.86
</td>
<td style="text-align:left;">
PMC6254006
</td>
<td style="text-align:left;min-width: 6in; ">
Prognostic model to predict postoperative acute kidney injury in
patients undergoing major gastrointestinal surgery based on a national
prospective observational cohort study.
</td>
<td style="text-align:left;">
101722685
</td>
<td style="text-align:left;">
2474-9842, 2474-9842
</td>
<td style="text-align:left;">
BJS open
</td>
<td style="text-align:left;">
BJS Open
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
6
</td>
<td style="text-align:left;">
400-410
</td>
<td style="text-align:right;">
0
</td>
<td style="text-align:left;">
NA
</td>
<td style="text-align:left;">
STARSurg Collaborative
</td>
<td style="text-align:right;">
1784
</td>
<td style="text-align:left;">
Nepogodiev D; Walker K; Glasbey JC; Drake TM; Borakati A; Kamarajah S;
McLean K; Khatri C; Arulkumaran N; Harrison EM; Fitzgerald JE; Cromwell
D; Prowle J; Bhangu A; Walker K; Drake TM; Cromwell D; Glasbey JC;
Borakati A; Drake TM; Kamarajah S; McLean K; Bath MF; Claireaux HA;
Gundogan B; Mohan M; Deekonda P; Kong C; Joyce H; Mcnamee L; Woin E;
Burke J; Khatri C; Fitzgerald JE; Harrison EM; Bhangu A; Nepogodiev D;
Arulkumaran N; Bell S; Duthie F; Hughes J; Pinkney TD; Prowle J;
Richards T; Thomas M; Dynes K; Patel P; Wigley C; Suresh R; Shaw A;
Klimach S; Jull P; Evans D; Preece R; Ibrahim I; Manikavasagar V; Brown
FS; Deekonda P; Teo R; Sim DPY; Borakati A; Logan AE; Barai I; Amin H;
Suresh S; Sethi R; Bolton W; Corbridge O; Horne L; Attalla M; Morley R;
Hoskins T; McAllister R; Lee S; Dennis Y; Nixon G; Heywood E; Wilson H;
Ng L; Samaraweera S; Mill A; Doherty C; Woin E; Belchos J; Phan V;
Chouari T; Gardner T; Goergen N; Hayes JDB; MacLeod CS; McCormack R;
McKinley A; McKinstry S; Milligan W; Ooi L; Rafiq NM; Sammut T; Sinclair
E; Smith M; Baker C; Boulton APR; Collins J; Copley HC; Fearnhead N; Fox
H; Mah T; McKenna J; Naruka V; Nigam N; Nourallah B; Perera S; Qureshi
A; Saggar S; Sun L; Wang X; Yang DD; Caroll P; Doyle C; Elangovan S;
Falamarzi A; Gascon Perai K; Greenan E; Jain D; Lang-Orsini M; Lim S;
O’Byrne L; Ridgway P; Van der Laan S; Wong J; Arthur J; Barclay J;
Bradley P; Edwin C; Finch E; Hayashi E; Hopkins M; Kelly D; Kelly M;
McCartan N; Ormrod A; Pakenham A; Hayward J; Hitchen C; Kishore A;
Martins T; Philomen J; Rao R; Rickards C; Burns N; Copeland M; Durand C;
Dyal A; Ghaffar A; Gidwani A; Grant M; Gribbon C; Gruhn A; Leer M; Ahmad
K; Beattie G; Beatty M; Campbell G; Donaldson G; Graham S; Holmes D;
Kanabar S; Liu H; McCann C; Stewart R; Vara S; Ajibola-Taylor O; Andah
EJE; Ani C; Cabdi NMO; Ito G; Jones M; Komoriyama A; Patel P; Titu L;
Basra M; Gallogly P; Harinath G; Leong SH; Pradhan A; Siddiqui I; Zaat
S; Ali A; Galea M; Looi WL; Ng JCK; Atkin G; Azizi A; Cargill Z; China
Z; Elliot J; Jebakumar R; Lam J; Mudalige G; Onyerindu C; Renju M;
Shankar Babu V; Hussain M; Joji N; Lovett B; Mownah H; Ali B; Cresswell
B; Dhillon AK; Dupaguntla YS; Hungwe C; Lowe-Zinola JD; Tsang JCH; Bevan
K; Cardus C; Duggal A; Hossain S; McHugh M; Scott M; Chan F; Evans R;
Gurung E; Haughey B; Jacob-Ramsdale B; Kerr M; Lee J; McCann E; O’Boyle
K; Reid N; Hayat F; Hodgson S; Johnston R; Jones W; Khan M; Linn T; Long
S; Seetharam P; Shaman S; Smart B; Anilkumar A; Davies J; Griffith J;
Hughes B; Islam Y; Kidanu D; Mushaini N; Qamar I; Robinson H; Schramm M;
Yan Tan C; Apperley H; Billyard C; Blazeby JM; Cannon SP; Carse S;
Göpfert A; Loizidou A; Parkin J; Sanders E; Sharma S; Slade G; Telfer R;
Whybrow Huppatz I; Worley E; Chandramoorthy L; Friend C; Harris L; Jain
P; Karim MJ; Killington K; McGillicuddy J; Rafferty C; Rahunathan N;
Rayne T; Varathan Y; Verma N; Zanichelli D; Arneill M; Brown F; Campbell
B; Crozier L; Henry J; McCusker C; Prabakaran P; Wilson R; Asif U;
Connor M; Dindyal S; Math N; Pagarkar A; Saleem H; Seth I; Sharma S;
Standfield N; Swartbol T; Adamson R; Choi JE; El Tokhy O; Ho W; Javaid
NR; Kelly M; Mehdi AS; Menon D; Plumptre I; Sturrock S; Turner J; Warren
O; Crane E; Ferris B; Gadsby C; Smallwood J; Vipond M; Wilson V;
Amarnath T; Doshi A; Gregory C; Kandiah K; Powell B; Spoor H; Toh C;
Vizor R; Common M; Dunleavy K; Harris S; Luo C; Mesbah Z; Prem Kumar A;
Redmond A; Skulsky S; Walsh T; Daly D; Deery L; Epanomeritakis E; Harty
M; Kane D; Khan K; Mackey R; McConville J; McGinnity K; Nixon G; Ang A;
Kee JY; Leung E; Norman S; Palaniappan SV; Partha Sarathy P; Yeoh T;
Frost J; Hazeldine P; Jones L; Karbowiak M; Macdonald C; Mutarambirwa A;
Omotade A; Runkel M; Ryan G; Sawers N; Searle C; Suresh S; Vig S; Ahmad
A; McGartland R; Sim R; Song A; Wayman J; Brown R; Chang LH; Concannon
K; Crilly C; Arnold TJ; Burgin A; Cadden F; Choy CH; Coleman M; Lim D;
Luk J; Mahankali-Rao P; Prudence-Taylor AJ; Ramakrishnan D; Russell J;
Fawole A; Gohil J; Green B; Hussain A; McMenamin L; McMenamin L; Tang M;
Azmi F; Benchetrit S; Cope T; Haque A; Harlinska A; Holdsworth R; Ivo T;
Martin J; Nisar T; Patel A; Sasapu K; Trevett J; Vernet G; Aamir A; Bird
C; Durham-Hall A; Gibson W; Hartley J; May N; Maynard V; Johnson S;
McDonald Wood C; O’Brien M; Orbell J; Stringfellow TD; Tenters F;
Tresidder S; Cheung W; Grant A; Tod N; Bews-Hair M; Lim ZH; Lim SW;
Vella-Baldacchino M; Auckburally S; Chopada A; Easdon S; Goodson R;
McCurdie F; Narouz M; Radford A; Rea E; Taylor O; Yu T; Alfa-Wali M;
Amani L; Auluck I; Bruce P; Emberton J; Kumar R; Lagzouli N; Mehta A;
Murtaza A; Raja M; Dennahy IS; Frew K; Given A; He YY; Karim MA;
MacDonald E; McDonald E; McVinnie D; Ng SK; Pettit A; Sim DPY;
Berthaume-Hawkins SD; Charnley R; Fenton K; Jones D; Murphy C; Ng JQ;
Reehal R; Robinson H; Seraj SS; Shang E; Tonks A; White P; Yeo A; Chong
P; Gabriel R; Patel N; Richardson E; Symons L; Aubrey-Jones D; Dawood S;
Dobrzynska M; Faulkner S; Griffiths H; Mahmood F; Patel P; Perry M;
Power A; Simpson R; Ali A; Brobbey P; Burrows A; Elder P; Ganyani R;
Horseman C; Hurst P; Mann H; Marimuthu K; McBride S; Pilsworth E; Powers
N; Stanier P; Innes R; Kersey T; Kopczynska M; Langasco N; Patel N;
Rajagopal R; Atkins B; Beasley W; Cheng Lim Z; Gill A; Li Ang H;
Williams H; Yogeswara T; Carter R; Fam M; Fong J; Latter J; Long M;
Mackinnon S; McKenzie C; Osmanska J; Raghuvir V; Shafi A; Tsang K;
Walker L; Bountra K; Coldicutt O; Fletcher D; Hudson S; Iqbal S; Lopez
Bernal T; Martin JWB; Moss-Lawton F; Smallwood J; Vipond M; Cardwell A;
Edgerton K; Laws J; Rai A; Robinson K; Waite K; Ward J; Youssef H;
Knight C; Koo PY; Lazarou A; Stanger S; Thorn C; Triniman MC; Botha A;
Boyles L; Cumming S; Deepak S; Ezzat A; Fowler AJ; Gwozdz AM; Hussain
SF; Khan S; Li H; Lu Morrell B; Neville J; Nitiahpapand R; Pickering O;
Sagoo H; Sharma E; Welsh K; Denley S; Khan S; Agarwal M; Al-Saadi N;
Bhambra R; Gupta A; Jawad ZAR; Jiao LR; Khan K; Mahir G; Singagireson S;
Thoms BL; Tseu B; Wei R; Yang N; Britton N; Leinhardt D; Mahfooz M;
Palkhi A; Price M; Sheikh S; Barker M; Bowley D; Cant M; Datta U;
Farooqi M; Lee A; Morley G; Naushad Amin M; Parry A; Patel S; Strang S;
Yoganayagam N; Adlan A; Chandramoorthy S; Choudhary Y; Das K; Feldman M;
France B; Grace R; Puddy H; Soor P; Ali M; Dhillon P; Faraj A; Gerard L;
Glover M; Imran H; Kim S; Patrick Y; Peto J; Prabhudesai A; Smith R;
Tang A; Vadgama N; Dhaliwal R; Ecclestone T; Harris A; Ong D; Patel D;
Philp C; Stewart E; Wang L; Wong E; Xu Y; Ashaye T; Fozard T; Galloway
F; Kaptanis S; Mistry P; Nguyen T; Olagbaiye F; Osman M; Philip Z;
Rembacken R; Tayeh S; Theodoropoulou K; Herman A; Lau J; Saha A; Trotter
M; Adeleye O; Cave D; Gunwa T; Magalhães J; Makwana S; Mason R; Parish
M; Regan H; Renwick P; Roberts G; Salekin D; Sivakumar C; Tariq A; Liew
I; McDade A; Stewart D; Hague M; Hudson-Peacock N; Jackson CES; James F;
Pitt J; Walker EY; Aftab R; Ang JJ; Anwar S; Battle J; Budd E; Chui J;
Crook H; Davies P; Easby S; Hackney E; Ho B; Imam SZ; Rammell J; Andrews
H; Perry C; Schinle P; Ahmed P; Aquilina T; Balai E; Church M; Cumber E;
Curtis A; Davies G; Dennis Y; Dumann E; Greenhalgh S; Kim P; King S;
Metcalfe KHM; Passby L; Redgrave N; Soonawalla Z; Waters S; Zornoza A;
Gulzar I; Hole J; Hull K; Ishaq H; Karaj J; Kelkar A; Love E; Patel S;
Thakrar D; Vine M; Waterman A; Dib NP; Francis N; Hanson M; Ingleton R;
Sadanand KS; Sukirthan N; Arnell S; Ball M; Bassam N; Beghal G; Chang A;
Dawe V; George A; Huq T; Hussain A; Ikram B; Kanapeckaite L; Khan M;
Ramjas D; Rushd A; Sait S; Serry M; Yardimci E; Capella S; Chenciner L;
Episkopos C; Karam E; McCarthy C; Moore-Kelly W; Watson N; Ahluwalia V;
Barnfield J; Ben-Gal O; Bloom I; Gharatya A; Khodatars K; Merchant N;
Moonan A; Moore M; Patel K; Spiers H; Sundaram K; Turner J; Bath MF;
Black J; Chadwick H; Huisman L; Ingram H; Khan S; Martin L; Metcalfe M;
Sangal P; Seehra J; Thatcher A; Venturini S; Whitcroft I; Afzal Z; Brown
S; Gani A; Gomaa A; Hussein N; Oh SY; Pazhaniappan N; Sharkey E;
Sivagnanasithiyar T; Williams C; Yeung J; Cruddas L; Gurjar S; Pau A;
Prakash R; Randhawa R; Chen L; Eiben I; Naylor M; Osei-Bordom D; Trenear
R; Bannard-Smith J; Griffiths N; Patel BY; Saeed F; Abdikadir H; Bennett
M; Church R; Clements SE; Court J; Delvi A; Hubert J; Macdonald B;
Mansour F; Patel RR; Perris R; Small S; Betts A; Brown N; Chong A;
Croitoru C; Grey A; Hickland P; Ho C; Hollington D; McKie L; Nelson AR;
Stewart H; Eiben P; Nedham M; Ali I; Brown T; Cumming S; Hunt C; Joyner
C; McAlinden C; Roberts J; Rogers D; Thachettu A; Tyson N; Vaughan R;
Verma N; Yasin T; Andrew K; Bhamra N; Leong S; Mistry R; Noble H; Rashed
F; Walker NR; Watson L; Worsfold M; Yarham E; Abdikadir H; Arshad A;
Barmayehvar B; Cato L; Chan-Lam N; Do V; Leong A; Sheikh Z; Zheleniakova
T; Coppel J; Hussain ST; Mahmood R; Nourzaie R; Prowle J; Sheik-Ali S;
Thomas A; Alagappan A; Ashour R; Bains H; Diamond J; Gordon J; Ibrahim
B; Khalil M; Mittapalli D; Neo YN; Patil P; Peck FS; Reza N; Swan I;
Whyte M; Chaudhry S; Hernon J; Khawar H; O’Brien J; Pullinger M; Rothnie
K; Ujjal S; Bhatte S; Curtis J; Green S; Mayer A; Watkinson G; Chapple
K; Hawthorne T; Khaliq M; Majkowski L; Malik TAM; Mclauchlan K; Ng Wei
En B; O’Connor T; Parton S; Robinson SD; Saat MI; Shurovi BN;
Varatharasasingam K; Ward AE; Behranwala K; Bertelli M; Cohen J; Duff F;
Fafemi O; Gupta R; Manimaran M; Mayhew J; Peprah D; Wong MHY; Farmer N;
Houghton C; Kandhari N; Khan K; Ladha D; Mayes J; McLennan F; Panahi P;
Seehra H; Agrawal R; Ahmed I; Ali S; Birkinshaw F; Choudhry M; Gokani S;
Harrogate S; Jamal S; Nawrozzadeh F; Swaray A; Szczap A; Warusavitarne
J; Abdalla M; Asemota N; Cullum R; Hartley M; Maxwell-Armstrong C;
Mulvenna C; Phillips J; Yule A; Ahmed L; Clement KD; Craig N; Elseedawy
E; Gorman D; Kane L; Livie J; Livie V; Moss E; Naasan A; Ravi F; Shields
P; Zhu Y; Archer M; Cobley H; Dennis R; Downes C; Guevel B; Lamptey E;
Murray H; Radhakrishnan A; Saravanabavan S; Sardar M; Shaw C; Tilliridou
V; Wright R; Ye W; Alturki N; Helliwell R; Jones E; Kelly D; Lambotharan
S; Scott K; Sivakumar R; Victor L; Boraluwe-Rallage H; Froggatt P;
Haynes S; Hung YMA; Keyte A; Matthews L; Evans E; Haray P; John I;
Mathivanan A; Morgan L; Oji O; Okorocha C; Rutherford A; Spiers H;
Stageman N; Tsui A; Whitham R; Amoah-Arko A; Cecil E; Dietrich A;
Fitzpatrick H; Guy C; Hair J; Hilton J; Jawad L; McAleer E; Taylor Z;
Yap J; Akhbari M; Debnath D; Dhir T; Elbuzidi M; Elsaddig M; Glace S;
Khawaja H; Koshy R; Lal K; Lobo L; McDermott A; Meredith J; Qamar MA;
Vaidya A; Acquaah F; Barfi L; Carter N; Gnanappiragasam D; Ji C;
Kaminski F; Lawday S; Mackay K; Sulaiman SK; Webb R; Ananthavarathan P;
Dalal F; Farrar E; Hashemi R; Hossain M; Jiang J; Kiandee M; Lex J;
Mason L; Matthews JH; McGeorge E; Modhwadia S; Pinkney T; Radotra A;
Rickard L; Rodman L; Sales A; Tan KL; Bachi A; Bajwa DS; Battle J; Brown
LR; Butler A; Calciu A; Davies E; Gardner I; Girdlestone T; Ikogho O;
Keelan G; O’Loughlin P; Tam J; Elias J; Ngaage M; Thompson J; Bristow S;
Brock E; Davis H; Pantelidou M; Sathiyakeerthy A; Singh K; Chaudhry A;
Dickson G; Glen P; Gregoriou K; Hamid H; Mclean A; Mehtaji P; Neophytou
G; Potts S; Belgaid DR; Burke J; Durno J; Ghailan N; Hanson M; Henshaw
V; Nazir UR; Omar I; Riley BJ; Roberts J; Smart G; Van Winsen K; Bhatti
A; Chan M; D’Auria M; Green S; Keshvala C; Li H; Maxwell-Armstrong C;
Michaelidou M; Simmonds L; Smith C; Wimalathasan A; Abbas J; Cairns C;
Chin YR; Connelly A; Moug S; Nair A; Svolkinas D; Coe P; Subar D; Wang
H; Zaver V; Brayley J; Cookson P; Cunningham L; Gaukroger A; Ho M; Hough
A; King J; O’Hagan D; Widdison A; Brown B; Brown R; Chavan A; Francis S;
Hare L; Lund J; Malone N; Mavi B; McIlwaine A; Rangarajan S; Abuhussein
N; Campbell HS; Daniels J; Fitzgerald I; Mansfield S; Pendrill A;
Robertson D; Smart YW; Teng T; Yates J; Belgaumkar A; Katira A; Kossoff
J; Kukran S; Laing C; Mathew B; Mohamed T; Myers S; Novell R; Phillips
BL; Thomas M; Turlejski T; Turner S; Varcada M; Warren L; Wynell-Mayow
W; Church R; Linley-Adams L; Osborn G; Saunders M; Spencer R; Srikanthan
M; Tailor S; Tullett A; Ali M; Al-Masri S; Carr G; Ebhogiaye O; Heng S;
Manivannan S; Manley J; McMillan LE; Peat C; Phillips B; Thomas S;
Whewell H; Williams G; Bienias A; Cope EA; Courquin GR; Day L; Garner C;
Gimson A; Harris C; Markham K; Moore T; Nadin T; Phillips C; Subratty
SM; Brown K; Dada J; Durbacz M; Filipescu T; Harrison E; Kennedy ED;
Khoo E; Kremel D; Lyell I; Pronin S; Tummon R; Ventre C; Walls L;
Wootton E; Akhtar A; Davies E; El-Sawy D; Farooq M; Gaddah M; Griffiths
H; Katsaiti I; Khadem N; Leong K; Williams I; Chean CS; Chudek D; Desai
H; Ellerby N; Hammad A; Malla S; Murphy B; Oshin O; Popova P; Rana S;
Ward T; Abbott TEF; Akpenyi O; Edozie F; El Matary R; English W;
Jeyabaladevan S; Morgan C; Naidu V; Nicholls K; Peroos S; Prowle J;
Sansome S; Torrance HD; Townsend D; Brecher J; Fung H; Kazmi Z; Outlaw
P; Pursnani K; Ramanujam N; Razaq A; Sattar M; Sukumar S; Tan TSE;
Chohan K; Dhuna S; Haq T; Kirby S; Lacy-Colson J; Logan P; Malik Q;
McCann J; Mughal Z; Sadiq S; Sharif I; Shingles C; Simon A; Burnage S;
Chan SSN; Craig ARJ; Duffield J; Dutta A; Eastwood M; Iqbal F; Mahmood
F; Mahmood W; Patel C; Qadeer A; Robinson A; Rotundo A; Schade A; Slade
RD; De Freitas M; Kinnersley H; McDowell E; Moens-Lecumberri S; Ramsden
J; Rockall T; Wiffen L; Wright S; Bruce C; Francois V; Hamdan K; Limb C;
Lunt AJ; Manley L; Marks M; Phillips CFE; Agnew CJF; Barr CJ; Benons N;
Hart SJ; Kandage D; Krysztopik R; Mahalingam P; Mock J; Rajendran S;
Stoddart MT; Clements B; Gillespie H; Lee S; McDougall R; Murray C;
O’Loane R; Periketi S; Tan S; Amoah R; Bhudia R; Dudley B; Gilbert A;
Griffiths B; Khan H; McKigney N; Roberts B; Samuel R; Seelarbokus A;
Stubbing-Moore A; Thompson G; Williams P; Ahmed N; Akhtar R; Chandler E;
Chappelow I; Gil H; Gower T; Kale A; Lingam G; Rutler L; Sellahewa C;
Sheikh A; Stringer H; Taylor R; Aglan H; Ashraf MR; Choo S; Das E;
Epstein J; Gentry R; Mills D; Poolovadoo Y; Ward N; Bull K; Cole A; Hack
J; Khawari S; Lake C; Mandishona T; Perry R; Sleight S; Sultan S;
Thornton T; Williams S; Arif T; Castle A; Chauhan P; Chesner R; Eilon T;
Kamarajah S; Kambasha C; Lock L; Loka T; Mohammad F; Motahariasl S;
Roper L; Sadhra SS; Sheikh A; Toma T; Wadood Q; Yip J; Ainger E; Busti
S; Cunliffe L; Flamini T; Gaffing S; Moorcroft C; Peter M; Simpson L;
Stokes E; Stott G; Wilson J; York J; Yousaf A; Borakati A; Brown M;
Goaman A; Hodgson B; Ijeomah A; Iroegbu U; Kaur G; Lowe C; Mahmood S;
Sattar Z; Sen P; Szuman A; Abbas N; Al-Ausi M; Anto N; Bhome R; Eccles
L; Elliott J; Hughes EJ; Jones A; Karunatilleke AS; Knight JS; Manson
CCF; Mekhail I; Michaels L; Noton TM; Okenyi E; Reeves T; Yasin IH;
Banfield DA; Harris R; Lim D; Mason-Apps C; Roe T; Sandhu J; Shafiq N;
Stickler E; Tam JP; Williams LM; Ainsworth P; Boualbanat Y; Doull C;
Egan E; Evans L; Hassanin K; Ninkovic-Hall G; Odunlami W; Shergill M;
Traish M; Cummings D; Kershaw S; Ong J; Reid F; Toellner H; Alwandi A;
Amer M; George D; Haynes K; Hughes K; Peakall L; Premakumar Y; Punjabi
N; Ramwell A; Sawkins H; Ashwood J; Baker A; Baron C; Bhide I; Blake E;
De Cates C; Esmail R; Hosamuddin H; Kapp J; Nguru N; Raja M; Thomson F;
Ahmed H; Aishwarya G; Al-Huneidi R; Ali S; Aziz R; Burke D; Clarke B;
Kausar A; Maskill D; Mecia L; Myers L; Smith ACD; Walker G; Wroe N;
Donohoe C; Gibbons D; Jordan P; Keogh C; Kiely A; Lalor P; McCrohan M;
Powell C; Power Foley M; Reynolds J; Silke E; Thorpe O; Tseun Han Kong
J; White C; Ali Q; Dalrymple J; Ge Y; Khan H; Luo RS; Paine H; Paraskeva
B; Parker L; Pillai K; Salciccioli J; Selvadurai S; Sonagara V;
Springford LR; Tan L; Appleton S; Leadholm N; Zhang Y; Ahern D; Cotter
M; Cremen S; Durrigan T; Flack V; Hrvacic N; Jones H; Jong B; Keane K;
O’Connell PR; O’Sullivan J; Pek G; Shirazi S; Barker C; Brown A; Carr W;
Chen Y; Guillotte C; Harte J; Kokayi A; Lau K; McFarlane S; Morrison S;
Broad J; Kenefick N; Makanji D; Printz V; Saito R; Thomas O; Breen H;
Kirk S; Kong CH; O’Kane A; Eddama M; Engledow A; Freeman SK; Frost A;
Goh C; Lee G; Poonawala R; Suri A; Taribagil P; Brown H; Christie S;
Dean S; Gravell R; Haywood E; Holt F; Pilsworth E; Rabiu R; Roscoe HW;
Shergill S; Sriram A; Sureshkumar A; Tan LC; Tanna A; Vakharia A;
Bhullar S; Brannick S; Dunne E; Frere M; Kerin M; Muthu Kumar K;
Pratumsuwan T; Quek R; Salman M; Van Den Berg N; Wong C; Ahluwalia J;
Bagga R; Borg CM; Calabria C; Draper A; Farwana M; Joyce H; Khan A;
Mazza M; Pankin G; Sait MS; Sandhu N; Virani N; Wong J; Woodhams K;
Croghan N; Ghag S; Hogg G; Ismail O; John N; Nadeem K; Naqi M; Noe SM;
Sharma A; Tan S; Begum F; Best R; Collishaw A; Glasbey J; Golding D;
Gwilym B; Harrison P; Jackman T; Lewis N; Luk YL; Porter T; Potluri S;
Stechman M; Tate S; Thomas D; Walford B; Auld F; Bleakley A; Johnston S;
Jones C; Khaw J; Milne S; O’Neill S; Singh KKR; Smith R; Swan A; Thorley
N; Yalamarthi S; Yin ZD; Ali A; Balian V; Bana R; Clark K; Livesey C;
McLachlan G; Mohammad M; Pranesh N; Richards C; Ross F; Sajid M; Brooke
M; Francombe J; Gresly J; Hutchinson S; Kerrigan K; Matthews E; Nur S;
Parsons L; Sandhu A; Vyas M; White F; Zulkifli A; Zuzarte L; Al-Mousawi
A; Arya J; Azam S; Azri Yahaya A; Gill K; Hallan R; Hathaway C; Leptidis
I; McDonagh L; Mitrasinovic S; Mushtaq N; Pang N; Peiris GB; Rinkoff S;
Chan L; Christopher E; Farhan-Alanie MMH; Gonzalez-Ciscar A; Graham CJ;
Lim H; McLean KA; Paterson HM; Rogers A; Roy C; Rutherford D; Smith F;
Zubikarai G; Al-Khudairi R; Bamford M; Chang M; Cheng J; Hedley C;
Joseph R; Mitchell B; Perera S; Rothwell L; Siddiqui A; Smith J; Taylor
K; Wroe Wright O; Baryan HK; Boyd G; Conchie H; Cox L; Davies J; Gardner
S; Hill N; Krishna K; Lakin F; Scotcher S; Alberts J; Asad M;
Barraclough J; Campbell A; Marshall D; Wakeford W; Cronbach P; D’Souza
F; Gammeri E; Houlton J; Hall M; Kethees A; Patel R; Perera M; Prowle J;
Shaid M; Webb E; Beattie S; Chadwick M; El-Taji O; Haddad S; Mann M;
Patel M; Popat K; Rimmer L; Riyat H; Smith H; Anandarajah C; Cipparrone
M; Desai K; Gao C; Goh ET; Howlader M; Jeffreys N; Karmarkar A; Mathew
G; Mukhtar H; Ozcan E; Renukanthan A; Sarens N; Sinha C; Woolley A;
Bogle R; Komolafe O; Loo F; Waugh D; Zeng R; Crewe A; Mathias J; Mills
A; Owen A; Prior A; Saunders I; Baker A; Crilly L; McKeon J; Ubhi HK;
Adeogun A; Carr R; Davison C; Devalia S; Hayat A; Karsan RB; Osborne C;
Scott K; Weegenaar C; Wijeyaratne M; Babatunde F; Barnor-Ahiaku E;
Beattie G; Chitsabesan P; Dixon O; Hall N; Ilenkovan N; Mackrell T;
Nithianandasivam N; Orr J; Palazzo F; Saad M; Sandland-Taylor L;
Sherlock J; Ashdown T; Chandler S; Garsaa T; Lloyd J; Loh SY; Ng S;
Perkins C; Powell-Chandler A; Smith F; Underhill R
</td>
<td style="text-align:left;">
Journal Article
</td>
<td style="text-align:left;">
epublish
</td>
<td style="text-align:left;">
2018-07-27
</td>
<td style="text-align:right;">
2018
</td>
<td style="text-align:left;">
NA…
</td>
</tr>
</tbody>
</table>
</div>

In general, it appears that the information on PubMed tends to be the
most accurate/up-to-date, however the Digital Object Identifier (DOI)
occasionally is not updated to reflect the final DOI for the paper (this
can either be amended or the publisher contacted to correct).

 

### **b). `extract_doi()`**

The `extract_doi()` function only requires a vector/list of Digital
Object Identifiers (DOI), and uses the
[rcrossref](https://github.com/ropensci/rcrossref) package to extract
publication information.

The function will automatically extract the authors (`auth_group`,
`auth_n`, `authors`), and the associated altmetric score (`altmetric`).
However, this functionality has been made optional as it can extend the
run time of the function (particularly in the case of a large number of
authors). It should be also noted that crossref tends to record
authorship less well (compared to PubMed).

    # Example output from user_roles_n()
    out_doi <- impactr::extract_doi(doi = out_pubmed$doi,
                           get_authors = TRUE, get_altmetric = FALSE, get_impact = FALSE)

<div style="border: 1px solid #ddd; padding: 5px; overflow-x: scroll; width:1000px; ">
<table class="table table-striped" style="width: auto !important; margin-left: auto; margin-right: auto;">
<thead>
<tr>
<th style="text-align:left;">
doi
</th>
<th style="text-align:left;">
author\_group
</th>
<th style="text-align:left;">
title
</th>
<th style="text-align:right;">
year
</th>
<th style="text-align:left;">
journal\_abbr
</th>
<th style="text-align:left;">
volume
</th>
<th style="text-align:left;">
issue
</th>
<th style="text-align:left;">
pages
</th>
<th style="text-align:right;">
cite\_cr
</th>
<th style="text-align:right;">
auth\_n
</th>
<th style="text-align:left;">
author
</th>
<th style="text-align:left;">
journal\_full
</th>
<th style="text-align:left;">
journal\_issn
</th>
</tr>
</thead>
<tbody>
<tr>
<td style="text-align:left;min-width: 2.5in; ">
10.1136/bmjopen-2015-009812
</td>
<td style="text-align:left;min-width: 2.5in; ">
NA
</td>
<td style="text-align:left;min-width: 7in; ">
Outcomes After Kidney injury in Surgery (OAKS): protocol for a
multicentre, observational cohort study of acute kidney injury following
major gastrointestinal and liver surgery
</td>
<td style="text-align:right;">
2016
</td>
<td style="text-align:left;">
BMJ Open
</td>
<td style="text-align:left;">
6
</td>
<td style="text-align:left;">
1
</td>
<td style="text-align:left;">
e009812
</td>
<td style="text-align:right;">
16
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;min-width: 2.5in; ">
NA
</td>
<td style="text-align:left;">
BMJ Open
</td>
<td style="text-align:left;">
2044-6055
</td>
</tr>
<tr>
<td style="text-align:left;min-width: 2.5in; ">
10.1136/bmjopen-2015-008811
</td>
<td style="text-align:left;min-width: 2.5in; ">
NA
</td>
<td style="text-align:left;min-width: 7in; ">
Determining Surgical Complications in the Overweight (DISCOVER): a
multicentre observational cohort study to evaluate the role of obesity
as a risk factor for postoperative complications in general surgery
</td>
<td style="text-align:right;">
2015
</td>
<td style="text-align:left;">
BMJ Open
</td>
<td style="text-align:left;">
5
</td>
<td style="text-align:left;">
7
</td>
<td style="text-align:left;">
e008811
</td>
<td style="text-align:right;">
13
</td>
<td style="text-align:right;">
11
</td>
<td style="text-align:left;min-width: 2.5in; ">
Nepogodiev D, Chapman SJ, Glasbey J, Kelly M, Khat…
</td>
<td style="text-align:left;">
BMJ Open
</td>
<td style="text-align:left;">
2044-6055
</td>
</tr>
<tr>
<td style="text-align:left;min-width: 2.5in; ">
10.1002/bjs5.86
</td>
<td style="text-align:left;min-width: 2.5in; ">
STARSurg Collaborative
</td>
<td style="text-align:left;min-width: 7in; ">
Prognostic model to predict postoperative acute kidney injury in
patients undergoing major gastrointestinal surgery based on a national
prospective observational cohort study
</td>
<td style="text-align:right;">
2018
</td>
<td style="text-align:left;">
BJS Open
</td>
<td style="text-align:left;">
2
</td>
<td style="text-align:left;">
6
</td>
<td style="text-align:left;">
400-410
</td>
<td style="text-align:right;">
3
</td>
<td style="text-align:right;">
NA
</td>
<td style="text-align:left;min-width: 2.5in; ">
NA
</td>
<td style="text-align:left;">
BJS Open
</td>
<td style="text-align:left;">
2474-9842
</td>
</tr>
</tbody>
</table>
</div>
