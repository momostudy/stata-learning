{smcl}
{* 20May2011}{...}
{cmd:help bma}{right: ({browse "http://www.stata-journal.com/article.html?article=st0239":SJ11-4: st0239})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{hi:bma} {hline 2}}Bayesian model averaging{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 16 2}{cmd:bma} {it:depvar} [{varlist}] 
{ifin}{cmd:,}
{cmdab:aux:iliary}{cmd:(}{varlist}{cmd:)} 
[{it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{p2coldent :* {opt auxiliary(varlist)}}auxiliary covariates{p_end}
{synopt :{opt nodots}}suppress display of dots tracking the progress of BMA estimation{p_end}
{synopt :{opt notable}}suppress display of table of results{p_end}
{synopt :{opt nocon:stant}}exclude constant term from the model{p_end}
{synoptline}
{p 4 6 2}* {opt auxiliary(varlist)} is required.{p_end}
{p 4 6 2}{it:depvar} is the dependent variable and {varlist} is the list of focus regressors.{p_end}
{p 4 6 2}Factor variables, time-series operators, and weights are not allowed.{p_end}


{title:Description}

{pstd}
{cmd:bma} uses the Bayesian model averaging (BMA) estimator introduced
by Magnus, Powell, and Pr{c u:}fer (2010) to fit a classical linear
regression model with uncertainty about the choice of the explanatory
variables.

{pstd}
The statistical framework is a classical linear regression model with
two subsets of explanatory variables.  The focus regressors contain
explanatory variables that we want in the model because of theoretical
reasons or other considerations about the phenomenon under
investigation.  The auxiliary regressors contain additional
explanatory variables of which we are less certain.

{pstd}
The problem of model uncertainty arises because different subsets of
auxiliary regressors could be excluded from the model to improve, in the
mean squared error sense, the unrestricted ordinary least-squares
estimator of the focus parameters.  When there are k2 auxiliary
regressors, the number of possible models to be considered is I=2^k2.

{pstd}
BMA provides a coherent method of inference on the regression parameters
of interest by taking explicit account of the uncertainty due to both
the estimation and the model selection steps.  This Bayesian estimator
uses conventional noninformative priors on the focus parameters and the
error variance, and a multivariate Gaussian prior on the auxiliary
parameters.  The unconditional BMA estimates are obtained as a weighted
average of the estimates from each of the possible models in the model space
with weights proportional to the marginal likelihood of {it:depvar} in
each model.


{title:Options}

{phang} {opt auxiliary(varlist)} is the required list of auxiliary
regressors of which we are less certain.

{phang}
{opt nodots} suppresses the display of the dots that track the progress of
{cmd:bma} estimation.  Dots are displayed only if the model space consists of
more than 128 models (that is, at least seven auxiliary regressors).  One dot
means that 1% of the models in the model space has been fit.

{phang}
{opt notable} suppresses the display of the table of results.

{phang} {opt noconstant} specifies that the constant term be excluded from
the model.  By default, the constant term is included and the
corresponding vector of ones is treated as a focus regressor.


{title:Examples}

{p 8 12 2}{cmd:. use data_mpp_small}

{p 8 12 2}{cmd:. bma growth gdp60 equipinv confuc school60 life60 law tropics avelf, auxiliary(mining dpop pright malaria)}

{p 8 12 2}{cmd:. bma growth, auxiliary(gdp60 equipinv confuc school60 life60 law tropics avelf mining dpop pright malaria)}


{title:Reference}

{p 4 8 2}
Magnus, J. R., O. Powell, and P. Pr{c u:}fer.  2010.
A comparison of two model averaging techniques with an application to growth
empirics.  {it:Journal of Econometrics} 154: 139-153.


{title:Authors}

{pstd}Giuseppe De Luca{p_end}
{pstd}ISFOL{p_end}
{pstd}Rome, Italy{p_end}

{pstd}Jan R. Magnus {p_end}
{pstd}Tilburg University{p_end}
{pstd}Tilburg, The Netherlands{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 11, number 4: {browse "http://www.stata-journal.com/article.html?article=st0239":st0239}

{p 4 14 2}{space 1}Manual:  {manlink R regress}, {manlink R stepwise}

{p 4 14 2}{space 3}Help:  {helpb regress}, {helpb stepwise}, {helpb vselect},
{helpb wals}, {helpb gmi} (if installed) 
{p_end}
