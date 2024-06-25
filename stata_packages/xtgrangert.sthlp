{smcl}
{* *! version 4.0  5 Jul 2022}{...}
{viewerjumpto "Title" "xtgrangert##title"}{...}
{viewerjumpto "Syntax" "xtgrangert##syntax"}{...}
{viewerjumpto "Description" "xtgrangert##description"}{...}
{viewerjumpto "Options" "xtgrangert##options"}{...}
{viewerjumpto "Postestimation command" "xtgrangert##postestimation"}{...}
{viewerjumpto "Postestimation options" "xtgrangert##postoptions"}{...}
{viewerjumpto "Examples" "xtgrangert##examples"}{...}
{viewerjumpto "Stored results" "xtgrangert##results"}{...}
{viewerjumpto "References" "xtgrangert##references"}{...}
{viewerjumpto "Acknowledgments" "xtgrangert##acknowledgments"}{...}
{viewerjumpto "Authors" "xtgrangert##authors"}{...}
{viewerjumpto "Also see" "xtgrangert##alsosee"}{...}
{cmd:help xtgrangert}{right: ({browse "https://doi.org/10.1177/1536867X231162034":SJ23-1: st0706})}
{hline}

{marker title}{...}
{title:Title}

{p2colset 5 19 21 2}{...}
{p2col :{cmd:xtgrangert} {hline 2}}Testing for Granger noncausality in
heterogeneous panel-data models, using the methodology developed by Juodis,
Karavias, and Sarafidis (2021){p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmd:xtgrangert} {depvar} [{indepvars}] {ifin}
[{cmd:,} {opt lags(#)}
{opt maxlags(#)} {cmd:het} {cmd:nodfc}
{cmdab:boot:strap}[{cmd:(}{it:#reps}{cmd:, seed({it:{help seed}}))}] {cmd:sum}] 

{p 4 6 2}
You must {cmd:xtset} your data before using {cmd:xtgrangert}; see 
{helpb xtset:[XT] xtset}.  The panel must be balanced.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:xtgrangert} performs the half-panel jackknife (HPJ) Wald-type test for
Granger noncausality, developed by Juodis, Karavias, and Sarafidis (2021).
This test offers superior size and power performance, which stems from the use
of a pooled estimator with a sqrt(NT) rate of convergence.  The test has two
other useful properties; it can be used in multivariate systems, and it has
power against both homogeneous as well as heterogeneous alternatives.  The
test allows for cross-sectional dependence and cross-sectional
heteroskedasticity.  The command also reports results for the HPJ estimator
with overlapping half panels.  In the presence of cross-sectional dependence,
the variance of the HPJ estimator can be obtained by bootstrapping.  The
bootstrap resamples across the cross-sectional dimension.

{pstd}
{cmd:xtgrangert} internally adds lags of the dependent variable with
heterogeneous slope coefficients when calculating the HPJ test statistic and
estimating the HPJ estimator.  The lags are partialed out, and their
estimation results not presented in the output.


{marker options}{...}
{title:Options}

{phang}
{opt lags(#)} specifies the number of lags of dependent and independent
variables to be added to the regression.  The default is {cmd:lags(1)}.  The
lags of the dependent variable are partialed out.

{phang}
{opt maxlags(#)} specifies the upper bound of lags.  The Bayesian information
criterion (BIC) is used to select the number of lags that provides the best
model fit.  {cmd:lags()} and {cmd:maxlags()} cannot be used at the same time.

{phang}
{opt het} allows for cross-sectional heteroskedasticity.

{phang}
{opt nodfc} does not apply a degrees-of-freedom correction in the computation
of the variance-covariance matrix of the HPJ estimator.  This option is mostly
useful under cross-sectional heteroskedasticity.

{phang}
{opt bootstrap}[{cmd:(}{it:#reps}{cmd:, seed({it:{help seed}}))}] specifies a
bootstrap variance estimator in the HPJ Wald statistic that allows for
cross-sectional dependence and uses a custom {it:{help seed}} and {it:#reps}
replications.  By default, 100 replications are used based on the current
seed.  This is useful in the presence of weak cross-sectional dependence.

{phang}
{opt sum} presents results on the sum of the estimated feedback coefficients.
This option can be useful when the number of lags is greater than 1.


{marker postestimation}{...}
{title:Postestimation command}

{pstd}
{cmd:predict} can be used after {cmd:xtgrangert}.  The residuals and predicted
values will be stored in {it:newvar}.{p_end}

{p 8 16 2}
{cmd:predict} {newvar} {ifin}
[{cmd:,} {opt res:iduals} {cmd:xb}] 


{marker postoptions}{...}
{title:Postestimation options}

{phang}
{opt residuals} calculates the residuals.{p_end}

{phang}
{opt xb} calculates the linear prediction on the partialed-out
variables.{p_end} 


{marker examples}{...}
{title:Examples}

{pstd}
Set up{p_end}
{phang2}{cmd:. use xtgrangert_example.dta}

{pstd}{cmd:xtset} the data{p_end}
{phang2}{cmd:. xtset cert time} 

{pstd}Dynamic model with given lags{p_end}
{phang2}{cmd:. xtgrangert roa inefficiency quality, lags(2)} 

{pstd}
Dynamic model with given lags, cross-sectional heteroskedasticity-robust
standard errors{p_end}
{phang2}{cmd:. xtgrangert roa inefficiency quality, lags(2) het}

{pstd}
Dynamic model with given lags and cross-sectional heteroskedasticity-robust
standard errors; it reports the sum of the lagged coefficients{p_end}
{phang2}{cmd:. xtgrangert roa inefficiency quality, lags(2) het sum}

{pstd}
Dynamic model with lag-length selection (up to 4 lags) based on BIC, with
cross-sectional heteroskedasticity-robust standard errors{p_end}
{phang2}{cmd:. xtgrangert roa inefficiency quality, maxlags(4) het}{p_end}

{pstd}
Dynamic model with lag-length selection (up to 4 lags) based on BIC, with
cross-sectional heteroskedasticity-robust standard errors, and no variance
degrees-of-freedom correction{p_end}
{phang2}{cmd:. xtgrangert roa inefficiency quality, maxlags(4) het nodfc}{p_end}

{pstd}
Bootstrap variance of the HPJ estimator that allows for cross-sectional
dependence, with a default of 100 replications{p_end}
{phang2}{cmd:. xtgrangert roa inefficiency quality, bootstrap}{p_end}

{pstd}
Bootstrap variance of the HPJ estimator that allows for cross-sectional
dependence, with 200 replications and control of the {help seed}{p_end}
{phang2}{cmd:. xtgrangert roa inefficiency quality, bootstrap(200, seed(123))}{p_end}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:xtgrangert} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of individual units{p_end}
{synopt:{cmd:e(T)}}number of time periods{p_end}
{synopt:{cmd:e(p)}}number of lags{p_end}
{synopt:{cmd:e(BIC)}}BIC value{p_end}
{synopt:{cmd:e(W_HPJ)}}Wald test statistic{p_end}
{synopt:{cmd:e(pvalue)}}{it:p}-value for the HPJ Wald test{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b_HPJ)}}HPJ coefficient estimator{p_end}
{synopt:{cmd:e(Var_HPJ)}}variance-covariance matrix of the HPJ
estimator{p_end}
{synopt:{cmd:e(b_Sum_HPJ)}}sum of the HPJ estimates for the feedback
coefficients{p_end}
{synopt:{cmd:e(Var_Sum_HPJ)}}variance of the sum of the HPJ estimators{p_end}


{marker references}{...}
{title:References}

{phang}
Juodis, A., Y. Karavias, and V. Sarafidis. 2021. A homogeneous approach to
testing for Granger non-causality in heterogeneous panels. 
{it:Empirical Economics} 60: 93-112. 
{browse "https://doi.org/10.1007/s00181-020-01970-9"}.

{phang}
Xiao, J., A. Juodis, Y. Karavias, V. Sarafidis, and J. Ditzen. 2023. 
Improved tests for Granger causality in panel data.
{it:Stata Journal} 23: 230-242.
{browse "https://doi.org/10.1177/1536867X231162034"}.


{marker acknowledgments}{...}
{title:Acknowledgments}

{pstd}
{cmd:xtgrangert} is not an official Stata command.  It is a free
contribution to the research community.  Please cite Xiao et al. (2023)
and Juodis, Karavias, and Sarafidis (2021), as listed in the references above.


{marker authors}{...}
{title:Authors}

{pstd}
Jiaqi Xiao{break}
University of Birmingham{break}
Birmingham, U.K.{break}
{browse "mailto:Jxx963@outlook.com?subject=Question/remark about -xtgrangert-&cc=Jxx963@outlook.com":Jxx963@outlook.com}

{pstd}
Artūras Juodis{break}
University of Amsterdam{break}
Amsterdam, Netherlands{break}
{browse "mailto:a.juodis@uva.nl?subject=Question/remark about -xtgrangert-&cc=i.Karavias@bham.ac.uk":a.juodis@uva.nl}

{pstd}
Yiannis Karavias{break}
University of Birmingham{break}
Birmingham, U.K.{break}
{browse "mailto:i.Karavias@bham.ac.uk?subject=Question/remark about -xtgrangert-&cc=i.Karavias@bham.ac.uk":i.Karavias@bham.ac.uk}

{pstd}
Vasilis Sarafidis{break}
BI Norwegian Business School{break}
Oslo, Norway{break}
{browse "mailto:vasilis.sarafidis@bi.no?subject=Question/remark about -xtgrangert-&cc=vasilis.sarafidis@bi.no":vasilis.sarafidis@bi.no}

{pstd}
Jan Ditzen{break}
Free University of Bozen-Bolzano{break}
Bozen, Italy{break}
{browse "mailto:jan.ditzen@unibz.it?subject=Question/remark about -xtgrangert-&cc=jan.ditzen@unibz.it":jan.ditzen@unibz.it}


{marker alsosee}{...}
{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 23, number 1: {browse "https://doi.org/10.1177/1536867X231162034":st0706}{p_end}
