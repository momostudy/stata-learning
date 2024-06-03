{smcl}
{* *! version 1.0.6  06feb2023}{...}
{title:Title}

{phang}
{bf:ardl postestimation {hline 2}} Postestimation tools for {help ardl}


{* foldend}{* foldbeg}{* * * DESCRIPTION * * *}{marker description}{...}
{title:Description}

{pstd}
The following postestimation commands are of special interest after {opt ardl}:

{synoptset 20}{...}
{synopt:Command}Description{p_end}
{synoptline}
{synopt:{helpb ardl_postestimation##ectest:estat ectest}}Pesaran/Shin/Smith (2001) bounds test for the existence of a level relationship{p_end}
{synopt:{helpb regress_postestimation:estat {it:subcmd_reg}}}all {cmd:estat} subcommands available after {cmd:regress}, except for {cmd:estat moran}; see the {help ardl_postestimation##postregress:note} below{p_end}
{synopt:{helpb regress_postestimationts:estat {it:subcmd_reg_ts}}}all {cmd:estat} subcommands available after {cmd:regress} when run on a time series data set; see the {help ardl_postestimation##postregress:note} below{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
The following standard postestimation commands are also available: 

{synoptset 15}{...}
{synopt:Command}Description{p_end}
{synoptline}
{synopt:{helpb estat}}AIC/BIC, VCE, and estimation sample summary ({cmd:estat}
subcommands {cmd:ic}, {cmd:vce}, and {cmd:{ul:su}mmary}, respectively).{p_end}
{synopt:{helpb estimates}}cataloging estimation results{p_end}
{synopt:{helpb lincom}}point estimates, standard errors, testing, and inference for linear combinations of coefficients{p_end}
{synopt:{helpb lrtest}}likelihood-ratio test{p_end}
{synopt:{helpb nlcom}}point estimates, standard errors, testing, and inference for nonlinear combinations of coefficients{p_end}
{synopt:{helpb ardl postestimation##options_predict:predict}}generate fitted values, residuals, and error-correction term{p_end}
{synopt:{helpb test}}Wald tests of simple and composite linear hypotheses{p_end}
{synopt:{helpb testnl}}Wald tests of nonlinear hypotheses{p_end}
{synoptline}
{p2colreset}{...}


{* foldend}{* foldbeg}{* * * ABBREVIATIONS * * *}{marker abbreviations}{...}
{title:Abbreviations and definitions used in this help entry}

{pstd}
See the {help ardl##abbreviations:abbreviations section of ardl}.


{* foldend}{* foldbeg}{* * * ECTEST * * *}{marker ectest}{...}
{title:Syntax for estat ectest}

{p 8 17 2}
{cmd:estat {ul:ect}est} {cmd:,} [ {opt sig:levels(levellist)} {opt asy:mptotic} 
    {opt nocr:itval} {opt nor:ule} {opt nodec:ision} ]

{title:Description for estat ectest}

{pstd}
{cmd:estat ectest} implements the bounds test for a levels relationship proposed by
{help ardl##PSS2001:Pesaran, Shin, and Smith (2001)},
where criticial values and approximate p-values for the F and t-statistics are obtained via the 
response surface regressions results of {help ardl##KS2020:Kripfganz and Schneider (2020)}.
See {help ardlbounds} for more information on how the critical values are obtained.
{help ardl##KS2022:Kripfganz and Schneider (2022, section 2.4)} provide a discussion
and step-by-step guide for the bounds test.

{pstd}
You must use one of the options {opt ec} or {opt ec1} in your {cmd:ardl} model for bounds test-related statistics to be available.

{pstd}
To avoid pretesting problems, PSS suggest to apply the bounds test only to ARDL models without restrictions on the short-run coefficients (i.e. with a sufficiently high and common lag order for the regressors).
However, {cmd:estat ectest} displays the F-statistic and t-statistic as well as the relevant critical values for any model specification.

{p 4 13 2}
{bf:{ul:Warning}:} The Kripfganz/Schneider critical values and p-values are obtained on the basis of the
methodology used as of the release date of command version 1.0.3 (June 2020)
and are still applicable as of the release date of this command version (1.0.6, February 2023).
Compared to version 1.0.2 (September 2018), version 1.0.3 introduces very slight changes in the
computed statistics.
Future versions of {cmd:ardl} may reflect further potential methodological refinements.
As a consequence, numbers may change slightly again.

{title:Options for estat ectest}

{phang}
{opt sig:levels(numlist)} shows CVs for levels in the {it:siglevels} {help numlist}, which must have at least one element.
The default numlist is '10 5 1'. Levels are specified as percentiles but do allow for two digits after the decimal point.
There are 221 different levels among which you can choose, indicated by the Stata numlist{...}

{pmore2}{...}
00.01 00.02 00.05 00.10(00.10)00.90 01.00(00.50)98.50 99.00(00.10)99.90 99.95 99.98 99.99

{phang}
{opt asy:mptotic} requests that the sample size returned by {cmd:ardl} in {bf:e(N)} be ignored, and
shows asymptotic CVs instead.

{phang}
{opt nocr:itval} does not display the critical values table.

{phang}
{opt nor:ule} does not display the decision rule.

{phang}
{opt nodec:ision} does not display the decision table.


{* foldend}{* foldbeg}{* * * POSTESTIMATION COMMANDS BORROWED FROM REGRESS * * *}{marker postregress}{...}
{title:Postestimation Commands Borrowed from regress}

{pstd}
A large number of {cmd:estat} subcommands for {cmd:regress} can be used after {cmd:ardl};
see {help regress_postestimation:here} and {help regress_postestimationts:here}.
Importantly, the results obtained with some of them can
differ depending on whether the model is specified in levels form or in
first-difference / error-correction form (see the sections on {help ardl##terminology:terminology}
and on {help ardl##longruncoefficients:long-run coefficients} for a clarification of these terms).
For example, the {cmd:estat ovtest} includes higher-order powers
of the dependent variable – which is either y(t) or dy(t) – as regressors in an auxiliary regression.
This complication does not apply to postestimation commands based on
residuals – such as {cmd:estat bgodfrey} and {cmd:estat imtest} – because the error term e(t) is
unaffected by the model's reparameterization.


{* foldend}{* foldbeg}{* * * SYNTAX_PREDICT * * *}{marker syntax_predict}{...}
{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict}
{dtype}
{newvar}
{ifin}
[{cmd:,}
{it:statistic}
]

{synoptset 22 tabbed}{...}
{synopthdr:statistic}
{synoptline}
{synopt:{opt xb}}fitted values; the default{p_end}
{synopt:{opt r:esiduals}}residuals{p_end}
{synopt:{opt ec}}error-correction term{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
All statistics are available both in and out of sample; type {cmd:predict ... if e(sample)} if wanted only for the estimation sample.


{* foldend}{* foldbeg}{* * * OPTIONS_PREDICT * * *}{marker options_predict}{...}
{title:Options for predict}

{dlgtab:Main}

{phang}
{opt xb} is the default prediction.
It calculates fitted values. When {cmd:ardl} was used with option {opt ec} or {opt ec1},
the fitted values are computed for the first differences of the dependent variable. Otherwise, they are computed for the levels.

{phang}
{opt r:esiduals} calculates residuals.

{phang}
{opt ec} calculates the error correction term.
For a precise description of what is being calculated, refer to the {cmd:ardl} help section
{help ardl##errorcorrectionterm:The error-correction term}.


{* foldend}{* foldbeg}{* * * STOREDRESULTS * * *}{marker storedresults}{...}
{title:Saved results}

{pstd}
{cmd:estat ectest} stores the following results for the PSS bounds test in {cmd:r()}:

{synoptset 20 tabbed}{...}
{syntab:Scalars}
{synopt:{cmd:r(k)}}# of weakly exogenous model variables{p_end}
{synopt:{cmd:r(case)}}model deterministics case used for tabulation{p_end}
{synopt:{cmd:r(t_pss)}}value of the t-statistic for the bounds test{p_end}
{synopt:{cmd:r(F_pss)}}value of the F-statistic for the bounds test{p_end}
{synopt:}{p_end}
{synopt:if option {opt asymptotic} was not used:}{p_end}
{synopt:{cmd:r(N)}}sample size used for tabulation{p_end}
{synopt:{cmd:r(sr)}}# of short-run coefficients in the model{p_end}

{syntab:Macros}
{synopt:{cmd:r(siglevels)}}levels of critical values tabulated{p_end}

{syntab:Matrices}
{synopt:{cmd:r(cvmat)}}matrix of critical values and approximate p-values{p_end}
{synopt:{cmd:r(decmat)}}matrix indicating the decision on the bounds test{p_end}
{p2colreset}{...}

{* foldend}
