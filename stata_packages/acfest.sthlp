{smcl}
{* *! version 1.0.0  jul2015}{...}
{cmd:help acfest}{right: ({browse "http://www.stata-journal.com/article.html?article=st0460":SJ16-4: st0460})}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col:{hi:acfest} {hline 2}}Production function estimation using the Ackerberg-Caves-Frazer method{p_end}


{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:acfest} {it:depvar} {ifin}{cmd:,} {opth free(varlist)}
{opth state(varlist)} {opth proxy(varname)}
[{opth i(varname)}
{opth t(varname)}
{opth intmat(varlist)}
{cmd:invest}
{opt nbs(#)}
{cmd:robust}
{cmd:nodum}
{cmd:second}
{cmd:va}
{cmd:overid}]

{phang}
where {it:depvar} is the dependent variable (revenue is the default or value
added).  All the variables should be in logs.  Panel data are required.
{it:depvar}, {cmd:free()}, {cmd:state()}, {cmd:proxy()}, {cmd:i()}, {cmd:t()},
and {cmd:intmat()} may contain time-series operators; see {help tsvarlist}.


{title:Syntax for predict after acfest}

{p 8 15 2}
{cmd:predict} {newvar} {ifin}{cmd:,} {cmd:omega}

{phang}
where {newvar} is the name of the variable that will contain the estimated
(log) productivity of the firms in the sample.


{marker description}{...}
{title:Description}

{pstd}
{cmd:acfest} yields production function estimates using the method proposed by
Ackerberg, Caves, and Frazer (2015).  This method deals with the functional
dependence problems that may arise in the approaches proposed by Olley and
Pakes (1996) and, particularly, by Levinsohn and Petrin (2003) (see 
{helpb opreg} and {helpb levpet}, respectively).  In particular, the
{cmd:acfest} command yields (nonlinear, robust) generalized method of moments
estimates using a Mata function.  The output from {cmd:acfest} also
includes the Wald test (joint significance of the explanatory variables) and
the Sargan-Hansen J test (overidentifying conditions).  After estimation,
{cmd:predict} provides the estimated productivity of the firms in the sample.


{title:Options}

{phang}
{opth free(varlist)} contains the list of labor inputs (for example,
white-collar and blue-collar workers).  {cmd:free()} is required.

{phang}
{opth state(varlist)} contains the list of state variables.  {cmd:state()} is
required.

{phang}
{opth proxy(varname)} contains the proxy variable.  {cmd:proxy()} is required.

{phang}
{opth i(varname)} identifies the panel variable.  Data in memory must have been
declared as panel; otherwise, {cmd:i()} is required.

{phang}
{opth t(varname)} identifies the time variable.  Data in memory must have been
declared as panel; otherwise, {cmd:t()} is required.

{phang}
{opth intmat(varlist)} lists intermediate inputs when investment is used as
a proxy.  In the revenue case, the user must specify the list of intermediate
inputs when using investment as a proxy, whereas when using the demand of an
intermediate input as a proxy, the user may optionally include other
intermediate materials than that used as a proxy (for example, fuels and
electricity).

{phang}
{opt invest} determines that investment is used as proxy.  The default is
materials.

{phang}
{opt nbs(#)} sets the number of replications used in the bootstrapping.  The
default is {cmd:nbs(100)}.

{phang}
{opt robust} reports standard errors robust to arbitrary heteroskedasticity.

{phang}
{opt nodum} specifies not to include time dummies in the (first-stage)
estimation of the function phi.

{phang}
{opt second} uses a second-order polynomial to construct the control function.
The default is a third-degree polynomial.

{phang}
{opt va} indicates that the dependent variable is value added.  The default is
revenue.

{phang}
{opt overid} uses the lag of the state variables and the second lag of
the labor variables in the value-added case (the default is to use the
state and lagged labor inputs); and it uses the lag of the state
variables and the second lag of the full set of variable inputs in the
revenue case (the default is to use the state and the full set of lagged
variable inputs).


{title:Option for predict}

{phang}
{cmd:omega} specifies the estimated productivity.  {cmd:omega} is required.


{marker examples}{...}
{title:Examples}

{pstd}
Robust standard errors using investment as proxy{p_end}
{phang2}{cmd:. acfest y1, free(l) proxy(inv) state(k age) robust invest}{p_end}

{pstd}
Value-added case and estimates of {cmd:omega} (after {cmd:predict}){p_end}
{phang2}{cmd:. acfest y2, free(l) proxy(m) state(k age) va second}{p_end}
{phang2}{cmd:. predict myomega, omega}{p_end}

	
{marker saved_results}{...}
{title:Stored results}

{pstd}
{cmd:acfest} stores the following in {cmd:e()}: 

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(L)}}number of instruments{p_end}
{synopt:{cmd:e(K)}}number of exogenous variables{p_end}
{synopt:{cmd:e(w)}}Wald test statistic of constant returns to scale{p_end}
{synopt:{cmd:e(j)}}Sargan-Hansen test statistic{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(vcetype)}}{cmd:robust}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{marker references}{...}
{title:References}

{phang}
Ackerberg, D. A., K. Caves, and G. Frazer. 2015. Identification properties of
recent production function estimators. {it:Econometrica} 83: 2411-2451.

{phang}
Levinsohn, J., and A. Petrin. 2003.  Estimating production functions using
inputs to control for unobservables.  {it:Review of Economic Studies} 70:
317-341.

{phang}
Olley, G. S., and A. Pakes. 1996. The dynamics of productivity in the
telecommunications equipment industry. {it:Econometrica} 64: 1263-1297.


{title:Authors}

{pstd}
Miguel Manj{c o'}n{break}
Research Centre on Industrial and Public Economics{break}
Department of Economics{break}
Rovira i Virgili University{break}
Reus, Spain{break}
miguel.manjon@urv.cat 

{pstd}
Juan Ma{c n~}ez{break}
Department of Applied Economics II and{break}
Estructura de Recerca Interdisciplinar Comportament Econ{c o'g}mic i Social{break}
Universitat de Val{c e'g}ncia{break}
Val{c e'g}ncia, Spain{break}
jamc@uv.es


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 16, number 4: {browse "http://www.stata-journal.com/article.html?article=st0460":st0460}{p_end}

{p 5 14 2}
Manual:
{manlink P program},
{manlink M-0 intro}

{p 7 14 2}
Help:  {helpb levpet},
{helpb opreg} (if installed){p_end}
