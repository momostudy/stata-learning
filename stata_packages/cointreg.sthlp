{smcl}
{* *! version 1.1  27feb2011}{...}
{cmd:help cointreg} {right: ({browse "http://www.stata-journal.com/article.html?article=st0272":SJ12-3: st0272})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:cointreg} {hline 2}}Estimate cointegration regression using fully modified ordinary least squares, dynamic ordinary least squares, and canonical correlation regression methods{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2} {cmd:cointreg} {depvar} {indepvars} {ifin} [{cmd:,}
        {opt est(method)} {opt nocons:tant}  
	{opt eqt:rend(#)} {opt eqd:et(varlist)} {opt xt:rend(#)}
        {opt xd:et(varlist)} 
	{opt diff} {opt stage(#)} {opt nodivn}
	{opt dlead(#)} {opt dlag(#)} {opt dic(string)} {opt dmax:order(#)} 
	{opt dvar(varlist)} {opt dvce(string)} {opt l:evel(#)} 
{it:{help lrcov:lrcov_options}}]

{pstd}{it:depvar} may contain time-series operators.{p_end}
{pstd}{it:indepvars} may contain time-series operators and factor variables.


{title:Description}

{pstd}{hi:cointreg} implements three fully efficient estimations for
cointegration regression: fully modified ordinary least squares (FMOLS),
dynamic ordinary least squares (DOLS), and canonical cointegration
regression (CCR).  FMOLS and CCR use a semiparametric correction to
eliminate the problems caused by the cross-correlation between the
cointegration equation error and the regressor innovations.  The DOLS
estimators are obtained by adding the lead and lag of the differenced
regressors to soak up the long-run correlation.  {hi:cointreg} uses
{helpb lrcov} to compute the long-run covariance.


{title:Options}

{phang}{cmd:est(}{it:method}{cmd:)} specifies the estimation method,
which can be {cmd:fmols}, {cmd:dols}, or {cmd:ccr}.  The default is
{cmd:est(fmols)}.

{phang}{cmd:noconstant} suppresses the constant in the cointegration
equation.  If this option is specified, {cmd:eqtrend()} will set to -1
automatically; that is, there is no deterministic term in the
cointegration equation.

{phang}{cmd:eqtrend(}{it:#}{cmd:)} specifies the trend order in
the cointegration equation.  {cmd:eqtrend(0)} denotes the constant term,
{cmd:eqtrend(1)} denotes the linear trend, and {cmd:eqtrend(2)} denotes the
quadratic trend.  The default is {cmd:eqtrend(0)}.  A negative value
means that there are no deterministic terms.  The specification implies
all trends up to the specified order, so {cmd:eqtrend(2)} means the trend
terms include a constant and a linear trend term along with the
quadratic term.

{phang}{cmd:eqdet(}{it:varlist}{cmd:)} specifies the additional
deterministic terms in the cointegration equation.

{phang}{cmd:xtrend(}{it:#}{cmd:)} specifies the trend order in the independent
variables.  This option is used only for FMOLS and CCR regression.
{cmd:xtrend(0)}, {cmd:xtrend(1)}, and {cmd:xtrend(2)} are allowed and have the
same meaning as {cmd:eqtrend()}.  This trend order should be greater than or
equal to the order in the {cmd:eqtrend()} option; if that requirement is not
met, the program will force the two options to be equal.

{phang}{cmd:xdet(}{it:varlist}{cmd:)} specifies the additional
deterministic terms in the independent variables.  This option is used
for FMOLS and CCR regression.

{phang}{cmd:diff} obtains hat u_(2t) by regressing the differenced
equation.  The default is regressing the equation first and then
differencing the residuals.

{phang}{cmd:stage(}{it:#}{cmd:)} is used for FMOLS or CCR
regression.  This option specifies the number to repeat the estimation
process, each time using new residuals to compute the long run
covariance (LRCOV).  The default is {cmd:stage(1)}, which performs FMOLS
(or CCR) estimation once.  For example, {cmd:stage(2)} indicates that
{cmd:cointreg} use the FMOLS (or CCR) residual hat u_(1t) to recompute
LRCOV and estimate the cointegration equation again.

{phang}{cmd:nodivn} specifies that the program not divide the LRCOV by n in the
intermediate steps.  Thus this option omits the adjustment of degrees of
freedom.

{phang}{cmd:dlead(}{it:#}{cmd:)} sets the lead order in DOLS.  The
default is {cmd:dlead(1)}.

{phang}{cmd:dlag(}{it:#}{cmd:)} sets the lag order in DOLS.  The
default is {cmd:dlag(1)}.  If the number is negative, for example,
{cmd:dlag(-1)}, {cmd:cointreg} will estimate the static ordinary
least-squares regression.

{phang}{cmd:dic(}{it:string}{cmd:)} sets the information criterion used
to select optimal lead and lag length in DOLS. {it:string} can be
{cmd:aic}, {cmd:bic}, or {cmd:hq}.  If {cmd:dic()} is specified,
{cmd:cointreg} will omit the {cmd:dlead()} and {cmd:dlag()} options and
automatically select the optimal lead (lag).

{phang}{cmd:dmaxorder(}{it:#}{cmd:)} sets the maximum length to
select optimal lead and lag length in DOLS.  The default is set to
int[min{(T-K)/3,12} x (T/100)^(1/4)].

{phang}{cmd:dvar(}{it:varlist}{cmd:)} specifies the variables of D.X in
the DOLS equation.  {hi:cointreg} automatically adds the lead and lag
terms of all independent variables.  This option gives the user the
freedom to add his or her own variables in the cointegration equation.

{phang}{cmd:dvce(}{it:string}{cmd:)} sets the type of covariance matrix
in DOLS regression. {it:string} can be {cmd:rescaled}, {cmd:hac}, or
{cmd:ols}.  The default is {cmd:dvce(rescaled)}.

{phang}{cmd:level(}{it:#}{cmd:)} sets the confidence level; default
is {cmd:level(95)}.

{phang}{it:lrcov_options} specifies the options to compute LRCOV, which
include {cmd:vic(}{it:string}{cmd:)}, {cmd:vlag(}{it:#}{cmd:)},
{cmd:kernel(}{it:string}{cmd:)}, {cmd:bwidth(}{it:#}{cmd:)},
{cmd:bmeth(}{it:string}{cmd:)}, {cmd:blag(}{it:#}{cmd:)}, and
{cmd:btrunc}.  All of these options are specified in the same way as for
the {helpb lrcov} command.


{title:Examples}

{pstd}{hi:Example: DOLS}

{phang}{cmd:.} {bf:{stata use sw93}}{p_end}
{phang}{cmd:.} {bf:{stata qui cointreg mp y r if tin(1903, 1987), est(dols) dlag(-1) kernel(none) }}{p_end}
{phang}{cmd:.} {bf:{stata qui est store SOLS }}{p_end}
{phang}{cmd:.} {bf:{stata qui cointreg mp y r, est(dols) dlead(2) dlag(2) vlag(2) kernel(none) }}{p_end}
{phang}{cmd:.} {bf:{stata qui est store DOLS }}{p_end}
{phang}{cmd:.} {bf:{stata estimates table SOLS DOLS, b(%6.3f) se(%6.3f) style(oneline) }}{p_end}

{pstd}Chow test at year 1946{p_end}
{phang}{cmd:.} {bf:{stata gen dum=year>=1946 }}{p_end}
{phang}{cmd:.} {bf:{stata qui cointreg mp y r i.dum i.dum#c.(y r), est(dols) dlead(2) dlag(2) vlag(2) kernel(none) }}{p_end}
{phang}{cmd:.} {bf:{stata test 1.dum 1.dum#c.y 1.dum#c.r }}{p_end}

{pstd}{hi:Example: FMOLS}

{phang}{cmd:.} {bf:{stata use campbell, clear }}{p_end}
{phang}{cmd:.} {bf:{stata cointreg tc di, est(fmols) vlag(1) kernel(qs) bmeth(andrews) eqtrend(1) nodivn}}{p_end}

{pstd}{hi:Example: CCR}

{phang}{cmd:.} {bf:{stata use ccr, clear }}{p_end}
{phang}{cmd:.} {bf:{stata cointreg ndur price dur, est(ccr) vlag(1) kernel(qs) bmeth(andrews) stage(3) }}{p_end}


{title:Saved results}

{pstd}{cmd:cointreg} saves the following in {cmdab:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2:Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(r2)}}R-squared{p_end}
{synopt:{cmd:e(r2_a)}}adjusted R-squared{p_end}
{synopt:{cmd:e(rmse)}}root of mean squared error{p_end}
{synopt:{cmd:e(lrse)}}long-run standard error{p_end}
{synopt:{cmd:e(rss)}}residual sum of squares{p_end}
{synopt:{cmd:e(tss)}}total sum of squares{p_end}
{synopt:{cmd:e(eqtrend)}}trend term in equation {p_end}
{synopt:{cmd:e(xtrend)}}trend term in regressor {p_end}
{synopt:{cmd:e(bwidth)}}band width {p_end}
{synopt:{cmd:e(vlag)}}lag in VAR prewhitening {p_end}
{synopt:{cmd:e(dlead)}}lead length in DOLS {p_end}
{synopt:{cmd:e(dlag)}}lag length in DOLS {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2:Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:cointreg}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(dic)}}lag type in DOLS {p_end}
{synopt:{cmd:e(kernel)}}kernel specification{p_end}
{synopt:{cmd:e(est)}}estimation method{p_end}
{synopt:{cmd:e(vic)}}information criterion in VAR{p_end}
{synopt:{cmd:e(bmeth)}}bandwidth selection method {p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(vcetype)}}variance type in DOLS {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2:Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector {p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2:Functions}{p_end}
{synopt:{hi:e(sample)}}marks estimation sample{p_end}


{title:Author}

{pstd}Qunyong Wang{p_end}
{pstd}Institute of Statistics and Econometrics{p_end}
{pstd}Nankai University{p_end}
{pstd}brynewqy@nankai.edu.cn{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 12, number 3: {browse "http://www.stata-journal.com/article.html?article=st0272":st0272}

{p 7 14 2}Help:  {helpb lrcov}, {helpb hacreg} (if installed){p_end}
