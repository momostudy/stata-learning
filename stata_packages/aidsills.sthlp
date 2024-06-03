{smcl}
{cmd:help aidsills}{right: ({browse "https://doi.org/10.1177/1536867X211025840":SJ21-2: st0393_3})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{cmd:aidsills} {hline 2}}Estimate almost-ideal demand systems with
endogenous regressors using iterated linear least squares{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd: aidsills} {it:varlist_shares} {ifin}
[{help aidsills##weights:{it:weight}}]{cmd:,}
{opt pri:ces(varlist_prices)}
{opt exp:enditure(varname)}
[{opt int:ercept(varlist)}
 {opt ivp:rices(varlist)}
 {opt ive:xpenditure(varlist)}
 {opt qua:dratic}
 {opt hom:ogeneity}
 {opt sym:metry}
 {opt nof:irst}
 {opt tol:erance(#)}
 {opt it:eration(#)}
 {opt al:pha_0(#)}
 {opt l:evel(#)}]

{p 8 15 2}
{cmd:aidsills_pred} {it:newvar} {ifin}{cmd:,}
{opt eq:uation(varname_share)}
[{opt r:esiduals}]

{p 8 15 2}
{cmd:aidsills_elas} {ifin}

{p 8 15 2}
{cmd:aidsills_vif}

{phang}
where {it:varlist_shares} is a list of N variables for budget shares, the last
being used as the reference.  They must sum to one for each observation.


{title:Description}

{pstd}
{cmd:aidsills} fits almost-ideal demand system (AIDS) (default) or quadratic
AIDS (when the {cmd:quadratic} option is specified) models with (or without)
endogenous regressors by using the iterated linear least-squares estimator
developed by Blundell and Robin (1999).  Demographic variables can be included,
and theoretical constraints can be tested and imposed.

{pstd}
{cmd:aidsills_pred} calculates the linear prediction ({opt xb}, the default)
or residuals using the estimates of the equation specified in
{cmd:equation()}.  Predictions are available both in and out of sample; type
{cmd:aidsills_pred} ... {cmd:if e(sample)} ... if predictions are wanted only
for the estimation sample.

{pstd}
{cmd:aidsills_elas} provides predicted shares, budget, and uncompensated and
compensated price elasticities (evaluated at the mean point of the sample
defined by {cmd:if} and {cmd:in}) with their standard errors.  Results are
presented using Jann's (2005) {cmd:estout} command, which can be downloaded from
within Stata by typing {cmd:search estout}.  See 
{browse "http://repec.org/bocode/e/estout"} for more information.

{pstd}
{cmd:aidsills_vif} calculates the centered variance-inflation factors
for the independent variables specified in the demand equations, as well as
for the independent variables specified in the instrumental regression(s), if
any.


{title:Options of aidsills}

{phang}
{opt prices(varlist_prices)} specifies a list of N variables for prices, in
level (not logarithm).  Prices must appear in the same order as shares.
{cmd:prices()} is required.

{phang}
{opt expenditure(varname)} specifies the total expenditure variable, in level
(not logarithm).  {it:varname} must represent the total amount of money spent
on the N goods of the system for each observation.  {cmd:expenditure()} is
required.

{phang}
{opt intercept(varlist)} specifies the variables used as sociodemographic
shifters; a constant term is added by default, whether the {cmd:intercept()}
option is specified or not.

{phang}
{opt ivprices(varlist)} specifies that the potentially
endogenous prices (or unit values) are to be instrumented by all exogenous
variables listed in {it:varlist} of {opt intercept()}, the log of
{it:varname} in {cmd:expenditure()} if expenditure is exogenous, and
identifying instrumental variables (IVs) listed in {it:varlist} of
{opt ivprices()} -- the number of variables in {cmd:ivprices()} must be at
least equal to the number of prices -- and {cmd:ivexpenditure()}.

{phang}
{opt ivexpenditure(varlist)} specifies that the potentially
endogenous total expenditure is to be instrumented by all exogenous
variables listed in {it:varlist} of {opt intercept()}, the log of
variables listed in {it:varlist} of {opt prices()} if prices are exogenous, and
identifying IVs listed in {it:varlist} of {opt ivprices()} and
{cmd:ivexpenditure()}.

{p 8 8 2}
Note: Variables in {it:varlist} of {opt ivprices()} cannot enter
{it:varlist} of {opt ivexpenditure()}, and vice versa.

{phang}
{opt quadratic} indicates that the quadratic version of the AIDS must be
considered.

{phang}
{opt homogeneity} indicates that the log price-parameters must satisfy the
homogeneity constraint; a homogeneity chi-squared test is provided when the
unconstrained model is fit.

{phang}
{opt symmetry} indicates that the log price-parameters must satisfy the
homogeneity and symmetry constraints; a symmetry chi-squared test is provided
when the homogeneity constrained model is fit.

{phang}
{opt nofirst} indicates that the output from the first-stage instrumental
regressions be omitted.

{phang}
{opt tolerance(#)} specifies the criterion used to declare convergence of the
iterated linear least squares estimator.  The default is
{cmd:tolerance(1e-5)}.

{phang}
{opt iteration(#)} specifies the maximum number of iterations;
{cmd:iteration(0)} estimates the linearized version of the model, where
a(.) is replaced by the Stone price index and b(.) = 1.  The default is
{cmd:iteration(50)}.

{phang}
{opt alpha_0(#)} specifies the value of alpha_0 in the price index a(.).  The
default is {cmd:alpha_0(0)}.

{phang}
{opt level(#)} specifies the confidence level, as a percentage, for confidence
intervals.  The default is {cmd:level(95)}.

{phang}
{cmd:fweight}s and {cmd:aweight}s are allowed; see {help weight}. 

{title:Options of aidsills_pred}

{phang}
{opt equation(varname_share)} specifies the variable for which
predictions are calculated.  {cmd:equation()} is required.

{phang}
{cmd:residuals} calculates the residuals rather than the linear prediction
({cmd:xb}, the default) for the specified equation.


{title:Examples}

{pstd}
Fit a 4-good quadratic AIDS model, unconstrained, with alpha_0 = 10{p_end}
{phang2}{cmd:. aidsills w1-w4, prices(p1-p4) expenditure(totexp) quadratic alpha_0(10)}
{p_end}

{pstd}
Same as above, but including household-size variable {opt hhsize} and
imposing homogeneity contraints{p_end}
{phang2}{cmd:. aidsills w1-w4, prices(p1-p4) expenditure(totexp) intercept(hhsize) quadratic homogeneity alpha_0(10)}{p_end}

{pstd}
Same as above, but linearized using the Stone price index and the unit vector
as proxies for price aggregators a() and b(), respectively{p_end}
{phang2}{cmd:. aidsills w1-w4, prices(p1-p4) expenditure(totexp) intercept(hhsize) quadratic homogeneity iteration(0) alpha_0(10)}{p_end}

{pstd}
Fit a 4-good AIDS model, imposing homogeneity and symmetry constraints, with
alpha_0 = 0 and using {opt lninc} and {opt ivp1-ivp4} as identifying IVs for
potentially endogenous {opt totexp} and {opt p1-p4}, respectively{p_end}
{phang2}{cmd:. aidsills w1-w4, prices(p1-p4) expenditure(totexp) ivprices(ivp1-ivp4) ivexpenditure(lninc) symmetry}{p_end}

{pstd}
Calculate the predicted residuals for equation {opt w1}{p_end}
{phang2}{cmd:. aidsills_pred res1, equation(w1) residuals}{p_end}

{pstd}
Calculate the elasticities at the mean point of the subsample composed by
households with less than 3 people{p_end}
{phang2}{cmd:. aidsills_elas if hhsize<3}{p_end}


{title:Stored results}

{pstd}
{cmd:aidsills} stores the following in {cmd:e()}:

{synoptset 17 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(alpha_0)}}value of alpha_0{p_end}
{synopt:{cmd:e(iteration) }}maximum number of iterations{p_end}

{synoptset 17 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:aidsills}{p_end}
{synopt:{cmd:e(model)}}name of the model{p_end}
{synopt:{cmd:e(const)}}constraint label used in the output header{p_end}
{synopt:{cmd:e(shares)}}budget share variables{p_end}
{synopt:{cmd:e(prices)}}price variables{p_end}
{synopt:{cmd:e(expenditure)}}expenditure variable{p_end}
{synopt:{cmd:e(ivprices)}}IVs for price variables{p_end}
{synopt:{cmd:e(ivexpenditure)}}IVs for expenditure variable{p_end}
{synopt:{cmd:e(intercept)}}demographic variables{p_end}
{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wvar)}}weight variable{p_end}

{synoptset 17 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(alpha)}}estimated {cmd:alpha} vector{p_end}
{synopt:{cmd:e(gamma)}}estimated {cmd:Gamma} matrix{p_end}
{synopt:{cmd:e(beta)}}estimated {cmd:beta} vector{p_end}
{synopt:{cmd:e(lambda)}}estimated {cmd:lambda} vector{p_end}
{synopt:{cmd:e(rho)}}estimated {cmd:rho} vector{p_end}

{synoptset 17 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{title:References}

{phang}
Blundell, R., and J.-M. Robin. 1999. Estimation in large and
disaggregated demand systems:  An estimator for conditionally linear
systems. {it:Journal of Applied Econometrics} 14:  209-232.

{phang}
Jann, B. 2005.
{browse "http://www.stata-journal.com/article.html?article=st0085":Making regression tables from stored estimates}. 
{it:Stata Journal} 5: 288-308.


{title:Authors}

{pstd}Sebastien Lecocq{p_end}
{pstd}Universite Paris-Saclay, INRAE, UR ALISS{p_end}
{pstd}Paris, France{p_end}
{pstd}sebastien.lecocq@inrae.fr{p_end}

{pstd}Jean-Marc Robin{p_end}
{pstd}Sciences Po{p_end}
{pstd}Paris, France{p_end}
{pstd}and University College London{p_end}
{pstd}London, UK{p_end}
{pstd}jeanmarc.robin@sciencespo.fr{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 21, number 2: {browse "https://doi.org/10.1177/1536867X211025840":st0393_3},{break}
                    {it:Stata Journal}, volume 17, number 4: {browse "http://www.stata-journal.com/article.html?article=up0057":st0393_2},{break}
                    {it:Stata Journal}, volume 16, number 1: {browse "http://www.stata-journal.com/article.html?article=up0050":st0393_1},{break}
                    {it:Stata Journal}, volume 15, number 2: {browse "http://www.stata-journal.com/article.html?article=st0393":st0393}

{p 5 14 2}Manual:  {manlink R reg3}

{p 7 14 2}Help:  {manhelp reg3 R}{p_end}
