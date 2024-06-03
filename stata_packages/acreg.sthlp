{smcl}
{* *! version 1.1.0  Dec 2020}{...}
{viewerjumpto "Title" "acreg##title"}{...}
{viewerjumpto "Syntax" "acreg##syntax"}{...}
{viewerjumpto "Description" "acreg##description"}{...}
{viewerjumpto "Options" "acreg##options"}{...}
{viewerjumpto "Examples" "acreg##examples"}{...}
{viewerjumpto "Stored results" "acreg##results"}{...}
{viewerjumpto "References" "acreg##references"}{...}
{viewerjumpto "Authors" "acreg##authors"}{...}
{viewerjumpto "Also see" "acreg##alsosee"}{...}
{cmd:help acreg}{right: ({browse "https://doi.org/10.1177/1536867X231162031":SJ23-1: st0703})}
{hline}

{marker title}{...}
{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{cmd:acreg} {hline 2}}Arbitrary correlation regression{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 13 2}
{cmd:acreg} {depvar} [{it:{help varlist:varlist1}}]
[{cmd:(}{it:{help varlist:varlist2}} {cmd:=}
{it:{help varlist:varlist_iv}}{cmd:)}] 
{ifin}
{weight}
[{cmd:,} {opt id(idvar)} {opt time(timevar)} 
{cmd:spatial} 
{opt latitude(latitudevar)} {opt longitude(longitudevar)} 
{opt dist_mat(varlist_distances)}
{opt dist:cutoff(#)} {opt lag:cutoff(#)} 
{cmd:network} 
{opt links_mat(varlist_links)} 
{opt cluster(varlist_cluster)} 
{opt weights(varlist_weights)}
{cmd:hac} {cmd:bartlett} {opt nbclust(n_clusters)} 
{opt pfe1(fe1var)} {opt pfe2(fe2var)} {cmd:correctr2} {cmd:dropsingletons}
{cmd:storeweights}
{cmd:storedistances}]

{phang}
{it:depvar} is the dependent variable.{p_end}

{phang}
{it:varlist1} is the list of exogenous variables.{p_end}

{phang}
{it:varlist2} is the list of endogenous variables.{p_end}

{phang}
{it:varlist_iv} is the list of exogenous variables used with {it:varlist1} as
instruments for {it:varlist2}.

{phang}
{cmd:fweight}s and {cmd:pweight}s are allowed; see {help weight}.


{marker description}{...}
{title:Description}

{pstd}
{cmd:acreg} computes standard errors corrected for arbitrary cluster
correlation in spatial and network settings.  It implements a range of
error-correction methods for linear regression models: ordinary least squares
(OLS) and two-stage least squares (2SLS).  {cmd:acreg} requires the
installation of the latest versions of {cmd:ranktest}, {cmd:ivreg2} (Baum,
Schaffer, and Stillman 2003), and {cmd:hdfe} (Correia 2016).  It is possible
to check whether the most up-to-date versions of these packages are installed
(and to install them if they are not) by typing {cmd:acregpackcheck} after
installing {cmd:acreg}.


{marker options}{...}
{title:Options}

{synoptset 28 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Panel}
{synopt :{opt id(idvar)}}specify the cross-sectional unit identifier named
{it:idvar}; required in panel setting{p_end}
{synopt :{opt time(timevar)}}specify the time unit variable named {it:timevar};
required in panel setting{p_end}

{syntab:Spatial environment}
{synopt:{opt spatial}}specify that the environment is a spatial one;
not required if arbitrary cluster correction is not performed or if 
{opt weights()},
{opt cluster()}, or {opt network} option is specified{p_end}
{p2coldent:+ {opt latitude(latitudevar)}}set the variable named {it:latitudevar} containing the
latitude of each observation in decimal degrees: range[-180,180]{p_end}
{p2coldent:+ {opt longitude(longitudevar)}}set the variable named {it:longitudevar} containing the
longitude of each observation in decimal degrees: range[-180,180]{p_end}
{p2coldent:# {opt dist_mat(varlist_distances)}}set the list of N variables, listed in {it:varlist_distances}, containing bilateral distances between observations; in the spatial environment, bilateral distance is the spatial distance 
between observations, for example, physical or travel distance between two locations{p_end}
{synopt:{opt dist:cutoff(#)}}specify the distance cutoff beyond which the correlation between error
terms of two observations is assumed to be zero; required if {cmd:latitude()} and {cmd:longitude()}
are specified or if {opt dist_mat()} is specified; the distance cutoff is in
kilometers if {cmd:latitude()} and {cmd:longitude()} are specified; it can be in any other meaningful
metric if bilateral distances are specified; {it:#} may be integer or float{p_end}
{synopt:{opt lag:cutoff(#)}}specify the time lag cutoff for those observations with the same
{opt id()};
not required in cross-sectional environment; default in panel environment
is {cmd:lagcutoff(0)}, that is, when {opt id()} and {opt time()} options are specified;
in panel environment when {opt lagcutoff(#)} is not specified, standard
errors are automatically clustered at {it:idvar} x {it:timevar} level; {it:#}
must be an integer{p_end}

{syntab:Network environment}
{synopt:{opt network}}specify that the environment is a network one; 
not required if arbitrary cluster correction is not performed and if 
{opt weights()}, {opt cluster()}, or
{cmd:spatial} option is specified{p_end}
{p2coldent:* {opt links_mat(varlist_links)}}set the N dummy variables,
listed in {it:varlist_links}, specifying the links between
observations, that is, the adjacency matrix; the links between two units
can change over time; however, if {cmd:distcutoff()} is set to be greater
than one, only the first observation in time of each individual will be
used as input to compute the bilateral distance between two nodes{p_end}
{p2coldent:# {opt dist_mat(varlist_distances)}}set the N variables,
listed in {it:varlist_distances}, containing bilateral distances
between observations; in the network environment, bilateral distance is
the network distance between observations, that is, the number of links
along the shortest path between two nodes{p_end}
{synopt:{opt dist:cutoff(#)}}specify the distance cutoff (geodesic
paths) beyond which the correlation between the error terms of two
observations is assumed to be zero; required if {cmd:dist_mat()} is specified;
optional if {opt links_mat()} is specified; default is
{cmd:distcutoff(1)} in the network environment; when {opt links_mat()}
 is specified and {cmd:distcutoff()} is greater than 1, {cmd:acreg}
 automatically computes the bilateral distance between two nodes; {it:#} may be integer or float{p_end}
{synopt:{opt lag:cutoff(#)}}specifies the time lag cutoff for those observations
with the same {opt id()}; not required in the cross-sectional
environment; default in panel environment is {cmd:lagcutoff(0)}, that is, when
{cmd:id()} and {cmd:time()} options are specified; when in the panel environment when
{cmd:lagcutoff(0)} or not specified, standard errors are clustered at {it:idvar} x {it:timevar} level{p_end}

{syntab:Multiway clustering environment}
{synopt:{opt cluster(varlist_cluster)}}set the variables, listed in
{it:varlist_cluster}, to use for
multiway clustered standard errors; not required if arbitrary cluster correction
is not performed and if the {cmd:spatial}, {cmd:network}, or
{opt weights()} option is specified{p_end}

{syntab:Arbitrary clustering environment}
{synopt:{opt weights(varlist_weights)}}set the N x T variables, listed in
{it:varlist_weights}, containing the weights that will be used for error
correction; not required if the {cmd:spatial}, {cmd:network}, or
{opt cluster()} option is specified; the N × T variables need to follow
the same order of the observations{p_end}

{syntab:Correlation structure}
{synopt:{opt hac}}report heteroskedastic- and autocorrelation-corrected
standard errors; {opt lagcutoff()} will be the temporal decay;
requires {opt id()}, {opt time()}, and {opt lagcutoff()}{p_end}
{synopt:{opt bartlett}}impose a distance-linear decay between observations
within the cutoff in the correlation structure{p_end}
{synopt:{opt nbclust(#)}}set the number of clusters used to compute the
Kleibergen-Paap statistic in case of arbitrary cluster correction; default is
{cmd:nbclust(100)}{p_end}

{syntab:High-dimensional fixed effects (partial out)}
{synopt:{opt pfe1(fe1var)}}set the categorical variable named {it:fe1var} that
identifies the first high-dimensional fixed effects to be absorbed{p_end}
{synopt:{opt pfe2(fe2var)}}set the categorical variable named {it:fe2var} that
identifies the second high-dimensional fixed effects to be absorbed{p_end}
{synopt:{opt correctr2}}report the R-squared of the overall model when 
{opt pfe1()} or {opt pfe2()} is
specified, that is, the R-squared obtained before partialing out the high-dimensional fixed
effects; the default reported R-squared is the R-squared of the within model when {opt pfe1()} or
{opt pfe2()} is specified, that is, on the "partialed-out sample"; not allowed with
{cmd:fweight}s{p_end}
{synopt:{opt dropsingletons}}drop singleton groups when {opt pfe1()} or {opt pfe2()} is specified{p_end}

{syntab:Storing}
{synopt:{opt storeweights}}store the computed weights used to correct the
variance-covariance for arbitrary cluster correlation as a matrix under the name {cmd:weightsmat}, which may be used as input for the option {opt weights()}; optional only if the {cmd:spatial}, 
{cmd:network}, or {opt cluster()} option is specified{p_end}
{synopt:{opt storedistances}}store the computed distances used to correct the
variance-covariance for arbitrary cluster correlation as a matrix under the name {cmd:distancesmat}, which may be used as input for the option {opt dist_mat()}; optional only if the {cmd:spatial}
or {cmd:network} option is specified and {opt dist_mat()} is not specified{p_end}
{synoptline}
{p 4 6 2}+ These options must be specified when {bf:spatial} is specified and
{opt dist_mat()} is not specified.{p_end}
{p 4 6 2}# This option may be specified only when {bf:spatial} is specified and
{opt latitude()} and {opt longitude()} are not specified or when {cmd:network}
is specified and {opt links_mat()} is not specified.{p_end}
{p 4 6 2}* This option must be specified when {bf:network} is specified and {opt dist_mat()} is not specified.{p_end}


{marker examples}{...}
{title:Examples}

{pstd}
Please find some examples below. For additional examples, please visit the page
{browse "https://acregstata.weebly.com/"}.{p_end}

    {title:Spatial Environment}

{pstd}Setup -- load spatial database{p_end}
{phang2}{bf:{stata "webuse homicide_1960_1990.dta":. webuse homicide_1960_1990.dta}}{p_end}

{pstd}Fit a regression via 2SLS, with no cluster correction -- robust standard errors{p_end}
{phang2}{bf:{stata "acreg hrate ln_population age (ln_income=unemployment)":. acreg hrate ln_population age (ln_income=unemployment)}}{p_end}

{pstd}Fit a regression via 2SLS, using longitude and latitude as input --
cross-section{p_end}
{phang2}{bf:{stata "acreg hrate ln_population age (ln_income=unemployment), latitude(_CX) longitude(_CY) distcutoff(50) spatial":. acreg hrate ln_population age (ln_income=unemployment), latitude(_CX) longitude(_CY) distcutoff(50) spatial}}{p_end}

{pstd}Fit a regression via 2SLS, using longitude and latitude as input --
panel, no heteroskedasticity- and autocorrelation-consistent{p_end}
{phang2}{bf:. {stata "acreg hrate ln_population age (ln_income=unemployment), id(_ID) time(year) latitude(_CX) longitude(_CY) distcutoff(50) lagcutoff(50) spatial"}}{p_end}

{pstd}
Fit a regression via 2SLS, using longitude and latitude as input -- panel,
heteroskedasticity- and autocorrelation-consistent{p_end}
{phang2}{bf:. {stata "acreg hrate ln_population age (ln_income=unemployment), id(_ID) time(year) latitude(_CX) longitude(_CY) distcutoff(50) lagcutoff(50) spatial hac"}}{p_end}

    {title:Network environment}

{pstd}Setup -- load network database -- Grund and Densley (2012){p_end}
{phang2}{bf:{stata "use nwexample.dta":. use nwexample.dta}}{p_end}

{pstd}Fit a regression via OLS, with no cluster correction -- robust standard errors{p_end}
{phang2}{bf:{stata "acreg Arrests Ranking Age Residence i.Birthplace":. acreg Arrests Ranking Age Residence i.Birthplace}}{p_end}

{pstd}Fit a regression via OLS, cluster correction{p_end}
{phang2}{bf:{stata "acreg Arrests Ranking Age Residence i.Birthplace, network links_mat(_net2_*) distcutoff(1)":. acreg Arrests Ranking Age Residence i.Birthplace, network links_mat(_net2_*) distcutoff(1)}}

{pstd}Fit a regression via OLS, cluster correction but to second degree{p_end}
{phang2}{bf:{stata "acreg Arrests Ranking Age Residence i.Birthplace, network links_mat(_net2_*) distcutoff(2)":. acreg Arrests Ranking Age Residence i.Birthplace, network links_mat(_net2_*) distcutoff(2)}}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:acreg} stores the following in {cmd:e()}:

{synoptset 13 tabbed}{...}
{syntab: Scalars}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(mss)}}model sum of squares (centered){p_end}
{synopt:{cmd:e(mssu)}}model sum of squares (uncentered){p_end}
{synopt:{cmd:e(rss)}}residual sum of squares{p_end}
{synopt:{cmd:e(tss)}}total sum of squares (centered){p_end}
{synopt:{cmd:e(tssu)}}total sum of squares (uncentered){p_end}
{synopt:{cmd:e(r2)}}centered R2 (1-{cmd:e(rss)}/{cmd:e(tss)}){p_end}
{synopt:{cmd:e(r2u)}}uncentered R2{p_end}
{synopt:{cmd:e(widstat)}}Kleibergen-Paap rk Wald {it:F} statistic{p_end}

{syntab: Matrices}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}corrected variance-covariance matrix of the estimators{p_end}

{syntab: Functions}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{marker references}{...}
{title:References}

{phang}
Baum, C. F., M. E. Schaffer, and S. Stillman. 2003. Instrumental variables and
GMM : Estimation and testing. {it:Stata Journal} 3: 1-31. 
{browse "https://doi.org/10.1177/1536867X0300300101"}.

{phang}
Correia, S. 2016. A feasible estimator for linear models with multi-way fixed
effects. {browse "http://scorreia.com/research/hdfe.pdf"}.

{phang}
Grund, T. U., and J. A. Densley. 2012. Ethnic heterogeneity in the activity
and structure of a Black street gang. {it:European Journal of Criminology} 9:
388-406. {browse "https://doi.org/10.1177/1477370812447738"}.


{marker authors}{...}
{title:Authors}

{pstd}
Fabrizio Colella{break}
University College London{break}
London, U.K.{break}
f.colella@ucl.ac.uk

{pstd}
Rafael Lalive{break}
HEC Lausanne{break}
Lausanne, Switzerland{break}
rafael.lalive@unil.ch

{pstd}
Seyhun Orcan Sakalli{break}
King's College London{break}
London, U.K.{break}
seyhun.sakalli@kcl.ac.uk

{pstd}
Mathias Thoenig{break}
HEC Lausanne{break}
Lausanne, Switzerland{break}
mathias.thoenig@unil.ch


{marker alsosee}{...}
{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 23, number 1: {browse "https://doi.org/10.1177/1536867X231162031":st0703}{p_end}
