{smcl}
{* *! version 1.0.6  06feb2023}{...}
{title:Title}

{phang}
{bf:ardlbounds} {hline 2} tabulate critical values for ARDL bounds test


{* foldend}{* foldbeg}{* * * SYNTAX * * *}{marker syntax}{...}
{title:Syntax}

{phang}
Standard behavior

{p 8 17 2}
{cmd:ardlbounds} {cmd:,} {opt c:ase(#)} [ {opt s:tat(stattype)} {opt n(#)} {opt k(#)} {opt sr(#)} {opt sig:levels(levellist)} {opt pv:alue(statval)} ]


{phang}
Tabular presentation over the number of weakly exogenous model variables {it:k}

{p 8 17 2}
{cmd:ardlbounds} {cmd:,} {opt tab:le} {opt c:ase(#)} [ {opt s:tat(stattype)} {opt n(#)} {opt kmax(#)} {opt la:gs(#)} ]


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:    }
{synopt:{opt c:ase(#)}}show CVs for {help ardl##deterministiccomponents:model deterministics case} {it:case}{p_end}
{synopt:{opt s:tat(stattype)}}show CVs for statistic {it:stattype}; {it:stattype} is either 't' or 'F'{p_end}
{synopt:{opt n(#)}}show CVs for sample size {it:n}; default: display asymptotic CVs{p_end}
{synopt:{opt k(#)}}show results for {it:k} weakly exogenous model variables; default: {it:k}=0{p_end}
{synopt:{opt sr(#)}}specify number of short-run coefficients; default: {it:sr}=0{p_end}
{synopt:{opth sig:levels(numlist)}}show CVs for levels in {it:levelslist}; default: '10 5 1'.{p_end}
{synopt:{opt pv:alue(statval)}}show p-value for value {it:statval} of the {it:stattype}-statistic{p_end}
{synopt:{opt tab:le}}build table over weakly exogenous model variables{p_end}
{synopt:{opt kmax(#)}}tabulate up to {it:kmax} weakly exogenous model variables{p_end}
{synopt:{opt la:gs(#)}}show results for {it:lags} lags for all levels regressors in the model{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}See {help ardl} for more information about ARDL estimation.{p_end}


{* foldend}{* foldbeg}{* * * DESCRIPTION * * *}{marker description}{...}
{title:Description}

{pstd}
{cmd:ardlbounds} displays critical values and approximate p-values for the bounds test for a level
relationship based on the response surface regressions of {help ardl##KS2020:Kripfganz and Schneider (2020)}.
As with many other test statistics in the analysis of non-stationary times series,
these magnitudes are somewhat difficult to obtain since they relate to non-standard distributions.

{pstd}
Regression-based predicted critical values and approximate p-values can be obtained for any combination
of values of the sample size, the number of weakly exogenous model variables, and the model lag structure.

{pstd}
The response surface regression methodology as used by {cmd:ardlbounds} was mainly developed by {help ardl##M1991:MacKinnon (1991)} and {help ardl##M1996:MacKinnon (1996)}.


{* foldend}{* foldbeg}{* * * ABBREVIATIONS * * *}{marker abbreviations}{...}
{title:Abbreviations and definitions used in this help entry}

{pstd}
See the {help ardl##abbreviations:abbreviations section of ardl}.


{* foldend}{* foldbeg}{* * * OPTIONS * * *}{marker options}{...}
{title:Options}

{phang}
{opt c:ase(#)} determines a particular {help ardl##deterministiccomponents:specification of model deterministics}.
CVs differ across model deterministics cases.

{phang}
{opt s:tat(stattype)} determines one of two possible statistics to be checked.
{it:stattype} must be either 't' or 'F', with 'F' being the default.
The option is not case-sensitive.

{phang}
{opt n(#)} show CVs for the effective sample size {it:n}, i.e. the total number of observations
minus the number of observations used up for lags.
This magnitude is reported by {help ardl} in {bf:e(N)}.
If the option is omitted, asymptotic CVs are displayed.

{phang}
{opt k(#)} show results for {it:k} weakly exogenous model variables. CVs differ across {it:k}.

{marker options_sr}{...}
{phang}
{opt sr(#)} specifies the number of short-run coefficients. For an ARDL(p,q_1,...,q_k) model,

{phang3}{it:sr} = max(0,p-1) + q_1 + ... + q_k

{pmore}
The number of short-run coefficients matters only for finite samples.
This option is therefore ignored if {it:n} is not specified.

{phang}
{opt sig:levels(numlist)} shows CVs for levels in the {it:siglevels} {help numlist}, which must have at least one element
and must be supplied in descending order.
The default numlist is '10 5 1'. Levels are specified as percentiles but do allow for two digits after the decimal point.
There are 221 different levels among which you can choose, indicated by the Stata numlist{...}

{pmore2}{...}
00.01 00.02 00.05 00.10(00.10)00.90 01.00(00.50)98.50 99.00(00.10)99.90 99.95 99.98 99.99

{phang}
{opt pv:alue(statval)} shows the (approximate) I(0)/I(1) p-values for value {it:statval} of the statistic.

{pmore}
Since the calculation of approximate p-values may fail to give sensible results for
values of {it:statval} that are outside the range of the critical values for percentile levels 00.01-99.99,
we set p-values to 0 or 1 in these cases.
Therefore, in the returned matrix {bf:r(cvmat)}, a p-value exactly equal to 0 (1) should
be interpreted as <0.0001 (>0.9999), which is unlikely to ever matter in practice.
The calculation of approximate p-values follows {help ardl##M1996:MacKinnon (1996)};
see {help ardl##KS2020:Kripfganz and Schneider (2020)} for details.

{phang}
{opt tab:le} displays an expanded CV table over increasing numbers of weakly exogenous model variables.
This options exists mainly to facilitate comparisons to the CVs tabulated in
{help ardl##PSS2001:Pesaran, Shin, and Smith (2001)} and {help ardl##N2005:Narayan (2005)},
who provide non-regression-based, simulation design-specific critical value tabulations.

{phang}
Options {opt kmax} and {opt lags()} can only be used in conjunction with option {opt table}.

{phang2}
{opt kmax(#)} specifies that the tabulation of CVs ranges from zero up to {it:kmax} weakly exogenous model variables.

{phang2}
{opt la:gs(#)} show results for {it:lags} lags for all levels regressors in the model.
{cmd:ardlbounds} calculates CVs according to the number of implied short-run coefficients for each level of {it:k}.
For example, ARDL(3,3) and ARDL(3,3,3) models have 5 and 8 short-run coefficients, respectively.
See option {opt sr()} above.
The number of lags (short-run coefficients) matters only for finite samples.


{* foldend}{* foldbeg}{* * * EXAMPLES * * *}{marker examples}{...}
{title:Examples}

{phang}
We check {cmd:ardlbounds} against a few, randomly chosen numbers from the empirical example of
{help ardl##PSS2001:PSS}. They report the following (p.311/312):{p_end}

{pmore}I0/I1 5% level bounds of (3.05, 3.97) for : case 4, k=4, lags=4, n=1000{p_end}{...}
{pmore}I0/I1 5% level bounds of (3.47, 4.57) for : case 5, k=4, lags=4, n=1000{p_end}{...}
{pmore}I0/I1 5% level bounds of (3.19, 4.16) for : case 4, k=4, lags=4, n= 104{p_end}{...}
{pmore}I0/I1 5% level bounds of (3.61, 4.76) for : case 5, k=4, lags=4, n= 104{p_end}

{pmore}
We compare this to the magnitudes returned by {cmd:ardlbounds}. Moreover, we supply the value of the
F-statistic in question, 2.99, to get an approximate p-value as an additional piece of information.
Note that the assumption of 4 lags per variable implies 3 + 4*4 = 19 short-run coefficients
(see option {help ardlbounds##options_sr:sr()} above).

{phang2}{stata ardlbounds , c(4) k(4) sr(19) n(1000) pval(2.99):. ardlbounds , c(4) k(4) sr(19) n(1000) pval(2.99)}{p_end}
{phang2}{stata ardlbounds , c(5) k(4) sr(19) n(1000) pval(2.99):. ardlbounds , c(5) k(4) sr(19) n(1000) pval(2.99)}{p_end}
{phang2}{stata ardlbounds , c(4) k(4) sr(19) n(104)  pval(2.99):. ardlbounds , c(4) k(4) sr(19) n(104)  pval(2.99)}{p_end}
{phang2}{stata ardlbounds , c(5) k(4) sr(19) n(104)  pval(2.99):. ardlbounds , c(5) k(4) sr(19) n(104)  pval(2.99)}{p_end}
{* gives:}{...}
{* (3.05, 3.96) }{...}
{* (3.48, 4.57) }{...}
{* (3.04, 4.19) }{...}
{* (3.45, 4.80) }{...}

{pmore}
While the numbers for the large sample (n=1000) are very close, some small differences arise for the small sample numbers (n=104).
This, however, should mostly be unrelated to simulation or methodological differences, but to the fact that {cmd:ardlbounds}
takes into account the number of short run regressors, which the simulations of PSS do not.
Asymptotically, this does not matter, which is why the results for n=1000 are close.
To confirm this, we re-run {cmd:ardlbounds},
setting the number of short-run coefficients to zero (the default):

{phang2}{stata ardlbounds , c(4) k(4) n(104) pval(2.99):. ardlbounds , c(4) k(4) n(104) pval(2.99)}{p_end}
{phang2}{stata ardlbounds , c(5) k(4) n(104) pval(2.99):. ardlbounds , c(5) k(4) n(104) pval(2.99)}{p_end}
{* gives:}{...}
{* 3.19, 4.13) }{...}
{* 3.62, 4.75) }{...}

{pmore}
The resulting numbers are again fairly close to what PSS report.


{* foldend}{* foldbeg}{* * * STOREDRESULTS * * *}{marker storedresults}{...}
{title:Saved results}

{pstd}
{cmd:ardlbounds} saves the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{syntab:Scalars}
{synopt:{cmd:r(k)}}# of weakly exogenous model variables{p_end}
{synopt:{cmd:r(case)}}model deterministics case used for tabulation{p_end}
{synopt:}{p_end}
{synopt:if option {opt n()} was used:}{p_end}
{synopt:{cmd:r(N)}}sample size used for tabulation{p_end}
{synopt:{cmd:r(sr)}}# of short-run coefficients in the model{p_end}

{syntab:Macros}
{synopt:{cmd:r(stat)}}'t' or 'F'{p_end}
{synopt:{cmd:r(siglevels)}}levels of critical values tabulated{p_end}

{syntab:Matrices}
{synopt:{cmd:r(cvmat)}}matrix of critical values; also contains approximate p-values if option {opt pvalue()} was used{p_end}
{p2colreset}{...}


{* foldend}{* foldbeg}{* * * AUTHORS * * *}{marker authors}{...}
{title:Authors}

{pstd}
Sebastian Kripfganz, University of Exeter Business School, S.Kripfganz@exeter.ac.uk

{pstd}
Daniel C. Schneider, Max Planck Institute for Demographic Research, schneider@demogr.mpg.de


{* foldend}{* foldbeg}{* * * ALSOSEE * * *}{marker alsosee}{...}
{title:Also see}

{psee}
Other commands of the {cmd:ardl} package: {help ardl}

{* foldend}
