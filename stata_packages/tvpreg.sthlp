{smcl}
{* July 2022}{...}
{title:Title}

{p 4 4 2}
{bf:tvpreg} —— Estimation of the parameter path in unstable environments

{title:Syntax}

{p 8 15 2} {cmd:tvpreg} {it:{help varlist:varlist_dep}} {it:{help varlist:varlist1}}
{cmd:(}{it:{help varlist:varlist2}} {cmd:=}
{it:{help varlist:varlist_iv}}{cmd:)}
{ifin} [{cmd:,} {help tvpreg##options:options}] 
{p_end}

{phang}
{it:varlist_dep} denotes the list of dependent variables.{p_end}
{phang}
{it:varlist1} denotes the list of exogenous variables.{p_end}
{phang}
{it:varlist2} denotes the list of endogenous variables.{p_end}
{phang}
{it:varlist_iv} denotes the list of exogenous variables used with {it:varlist1} as instruments for {it:varlist2}.

{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Estimator}
{synopt: {opt ols}}ordinary least squares (OLS); the default when no insturment is specified;{p_end}
{synopt: {opt newey}}apply Newey-West HAC estimation to the long-run variance of scores{p_end}
{synopt: {opt 2sls}}two-stage least squares (2SLS); the default when instruments are specified;{p_end}
{synopt: {opt gmm}}generalized method of moments (GMM){p_end}
{synopt: {opt weakiv}}indicate the weak-instrument environment and use OLS for the reduced-from regression{p_end}
{synopt: {opt var}}indicate the vector autoregressive (VAR) environment{p_end}

{syntab:Model}
{synopt :{opt c:matrix(matname)}}specify the {it:C} grid for {it:ci}; the default is a scalar {it:ci} with the {it:C} grid 0:5:50. 
Both scalar and vector {it:ci} are allowed. 
A vector {it:ci} allows different magnitudes of time-variation of different blocks of parameters
With scalar {it:ci}, {it:C} is a row vector;
with vector {it:ci}, {it:C} is a matrix whose number of rows should equal the number of
parameters {it:q}.{p_end}
{synopt :{opth nhor:izon(numlist)}}specify the number list of horizons in the local projection or the vector autoregressive model;
the default is {cmd:nhorizon(0)};{p_end}
{synopt :{opt cum}}indicate that the dependent variables and endogeneous variables are cumulated over horizons{p_end}
{synopt :{opt slope}}indicate that only the slope parameters are time-varying{p_end}
{synopt :{opt chol:esky}}indicates that logarithm of the standard deviation is considered in the parameter path for univariate regressions,
or triangular reduction of the covariance matrix is implemented for multivariate regressions.{p_end}
{synopt :{opth nwl:ag(#)}}specify the number of lags to calculate the sandwich matrix;
the default is {cmd:nwlag(0)} when {it:estimator} option is {cmd:ols} or {cmd:var},
and {cmd:nwlag(T^(-1/3))} for other {it:estimator} options,
where {it:T} is the total sample size{p_end}
{synopt :{opt nocons:tant}}suppress constant term{p_end}
{synopt :{opth ny(#)}}specify the number of dependent variables;
the default is {cmd:ny(1)};
this option does not apply when the {it:estimator} option is {cmd:var}{p_end}
{synopt :{opth varlag(numlist)}}number of lags in the vector autoregressive model; 
the default is {cmd:varlag(1)};
this option may only applied when the {it:estimator} option is {cmd:var}
{p_end}
{synopt :{opth ndraw(#)}}specify the number of draws used to simulate the confidence band in the precense of weak instruments
or for the impulse responses computed by iterating the VAR; 
the default is {cmd:ndraw(1000)};
this option only applies when the {it:estimator} option is {cmd:weakiv} or {cmd:var}{p_end}
{synopt :{opt fix}}fix the random seed when simulating the confidence band;
this option only applies when the {it:estimator} option is {cmd:weakiv} or {cmd:var}{p_end}

{syntab:Reporting}
{synopt :{opt getb:and}}obtain the confidence band{p_end}
{synopt :{opth level(cilevel)}}set confidence level; the default is {cmd:level(95)}{p_end}
{synopt :{opt nodis:play}}suppress the text output{p_end}

{syntab:Plotting}
{synopt :{opt plotcoef(namelist)}}specify the parameter name (list) to be plotted;
the parameter name is stored in {cmd:e(paraname)};
To plot the slope parameters, {it:namelist} is specified by {it:"yvar1:xvar1 yvar2:xvar2 ..."} to locate the parameter to be plotted,
where {it:yvar} ({it:xvar}) is the left (right) hand side for the parameter.
To plot the covariance matrix parameters when {cmd:cholesky} is specified,
{it:namelist} is
specified by {it:"aij ... li ..."},
here {it:aij} denotes the {it:i}-th row and {it:j}-th column element in {it:A(t)},
{it:li} denotes the {it:i}-th element in {it:lnσ(t)},
where {it:A(t)Σ(e,t)A(t)' = Σ(ε,t)Σ(ε,t)}, {it:σ(t)=diag(Σ(ε,t))},
{it:A(t)} is a lower-triangular matrix with a diagonal of 1,
{it:Σ(e,t)} is the covariance matrix, and {it:i > j}.
To plot the convariance matrix parameters when {cmd:cholesky} is not specified,
{it:namelist} is specified by {it:"aij ... li ..."},
here {it:vij} denote the {it:i}-th row and {it:j}-th column element in the covariance matrix {it:Σ(e,t)},
where {it:i ≥ j}.{p_end}
{synopt :{opt plotvarirf(namelist)}}specify the parameter name (list) of  time-varying parameter vector autoregression impulse responses to be plotted.;
the parameter name is stored in {cmd:e(irfname)};
{it:namelist} is specified as {it:"var1:shock1 var2:shock2 ..."} to locate the impulse response to be plotted, 
where {it:var} ({it:shock}) is the variable (shock) of interest;
this option only applied when the {it:estimator} option is {cmd:var};
{opt plotcoef(namelist)} and {opt plotvarirf(namelist)} cannot be specified together{p_end}
{synopt :{opth plotnhor:izon(numlist)}}specify the number (list) of horizons to be plotted;
this list must be a subset of the number list in {opth nhorizon(numlist)};
the command plots the parameter path over time (horizons)
when {opth plotnhorizon(numlist)} specifies a single number (or a list of numbers);
the default is the list specified by {opth nhorizon(numlist)}{p_end}
{synopt :{opt plotc:onst}}adds a line of constant parameter estimates;
this option does not apply to the {it:estimator} option beiing {cmd:weakiv}{p_end}
{synopt :{opth period(varname)}}a dummy variable indicating the time points to be highlighted;
when plotting the parameter path over time, this option adds background shading to the denoted time points;
when plotting the parameter path over horizons, this option specifies the time points to be plotted{p_end}
{synopt :{opth movavg(#)}}specify degree of moving average when ploting a (smoothed) parameter path; the default is {cmd:movavg(1)}{p_end}
{synopt :{opt noci}}suppress the confidence band in the figures;
the confidence band is only computed and stored when {cmd:getband} is specified{p_end}
{synopt :{opt ti:tle(tinfo)}}specify the graph title; the default is the parameter name{p_end}
{synopt :{opt yti:tle(axis_title)}}specify y-axis title; the default is "Parameter"{p_end}
{synopt :{opt xti:tle(axis_title)}}specify x-axis title; the default is "Time" ("Horizons") for parameter path over time (horizons){p_end}
{synopt :{opt tvpl:egend(string)}}specify legend name of the time-varying-parameter estimate;
the default is "Time-varying parameter"{p_end}
{synopt :{opt constl:egend(string)}}specify legend name of the constant-parameter estimate;
the default is "Constant parameter";
this option may be specified only when {opt plotconst} is specified{p_end}
{synopt :{opt bandl:egend(string)}}specify legend name of the confidence band;
the default is "95% confidence band";
this option may be specified only when {opt getband} is specified and {opt noci} is not specified{p_end}
{synopt :{opt shadel:egend(string)}}specify legend name of the background shade;
the default is the variable name specified by {opth period(varname)};
this option may be specified only when {opth period(varname)} is specified and a single number is specified by {opth plotnhorizon(numlist)}{p_end}
{synopt :{opt periodl:egend(namelist)}}specify legend names of different periods when {opth plotnhorizon(numlist)} specifies a number list;
{it:namelist} is specified by {it:"name1,name2,..."};
the order of names should match the increasing order of time;
if this option is not specified, all the time-varying estimates have the same legend specified by {opt tvpl:egend(string)}{p_end}
{synopt :{opt nolegend}}suppress the legend;
the legend is displayed only when more than two of the above elements are plotted in the figure{p_end}
{synopt :{opth name(name_option)}}specify the graph name; the default is "tvpreg"{p_end}
{synoptline}
{p 4 6 2} The command allows to specify at most one estimator.{p_end}
{phang2}. {cmd:ols} or {cmd:newey} estimates the linear regression or local project.
The syntax is analogous to Stata command {cmd:regress} and {cmd:newey}:
{cmd:tvpreg} {it:{help varlist:varlist_dep}} {it:{help varlist:varlist1}}
{ifin} [{cmd:,} {cmd:ols/newey} {help tvpreg##options:options}]{p_end}
{phang2}. {cmd:2sls}, {cmd:gmm} and {cmd:weakiv} are designed for instrument variable estimation.
The syntax is analogous to Stata command {cmd:ivreg2}:
{cmd:tvpreg} {it:{help varlist:varlist_dep}} [{it:{help varlist:varlist1}}]
{cmd:(}{it:{help varlist:varlist2}} {cmd:=}
{it:{help varlist:varlist_iv}}{cmd:)}
{ifin} [{cmd:,} {cmd:2sls/gmm/weakiv} {help tvpreg##options:options}] {p_end}
{phang2}. {cmd:var} estimates vector autoregregressive models.
The syntax is analogous to Stata command {cmd:var}
{cmd:tvpreg} {it:{help varlist:varlist_dep}}
{ifin} [{cmd:,} {cmd:var} {help tvpreg##options:options}] {p_end}


{title:Description}

{p 4 4 2}{cmd:tvpreg} facalitates practitioners to estimate and visualize the parameter path and impulse response functions in unstable environments.
{help tvpreg##storedresults:Estimation results} are stored in {cmd:e()} form.
{help tvpreg##postestimation:Postestimation command} is provided to visualize more results. 
{p_end}


{marker postestimation}{...}
{title:Postestimation command}

{p 4 4 2}{cmd:tvpplot} helps further visualize the result after {cmd:tvpreg}:

{p 8 15 2} {cmd:tvpplot} [{cmd:,} {opt plotcoef(namelist)} {opt plotvarirf(namelist)} {opth hor:izon(numlist)} {opt plotc:onst} {opth period(varname)} {opth movavg(#)}
{cmd:noci} {opt ti:tle(tinfo)} {opt yti:tle(axis_title)} {opt xti:tle(axis_title)} {opth name(name_option)}
{opt tvpl:egend(string)} {opt constl:egend(string)} {opt bandl:egend(string)} {opt shadel:egend(string)} {opt periodl:egend(namelist)} {opt nolegend}] 
{p_end}

{p 4 4 2}The options are the same as {cmd:tvpreg}. {opt plotcoef(namelist)} or {opt plotvarirf(namelist)} should be specified to locate the parameter.


{marker examples}{...}
{title:Examples}

{synoptline}
{pstd}Example 1 (TVP-VAR): Effect of monetary policy shock (Inoue et al., 2024a).{p_end}
{phang2}{cmd:. use data_MP.dta, clear}{p_end}
{phang2}{cmd:. tsset time}{p_end}
{phang2}{cmd:. mata: cB = 0.2 * (3*(0::5))'; cB = cB # J(1,36,1)}{p_end}
{phang2}{cmd:. mata: ca = 0.4 * (3*(0::5))'; ca = J(1,6,1) # ca # J(1,6,1)}{p_end}
{phang2}{cmd:. mata: cl =       (3*(0::5))'; cl = J(1,36,1) # cl}{p_end}
{phang2}{cmd:. mata: cmat = (J(21,1,1) # cB) \ (J(3,1,1) # ca) \ (J(3,1,1) # cl)}{p_end}
{phang2}{cmd:. mata: st_matrix("cmat",cmat)}{p_end}
{pstd}Estimate the VAR model with two lags and obtain the impulse response functino from horizon 0 to 19.{p_end}
{phang2}{cmd:. tvpreg pi urate irate, var varlag(1/2) level(90) cmatrix(cmat) chol nhor(0/19) fix}{p_end}
{pstd}Plot the impulse response function in three specific time points with user specific legend.{p_end}
{phang2}{cmd:. gen period = 0}{p_end}
{phang2}{cmd:. replace period = 1 if time == yq(1975,1) | time == yq(1981,1) | time == yq(1996,1)}{p_end}
{phang2}{cmd:. tvpplot, plotvarirf(pi:pi pi:urate pi:irate urate:pi urate:urate urate:irate irate:pi irate:urate irate:irate) plotconst period(period) periodlegend(1975Q1, 1981Q1, 1996Q1) name(figure1_1)}{p_end}
{pstd}Plot the VAR coefficient of the first lag.{p_end}
{phang2}{cmd:. tvpplot, plotcoef(pi:L.pi pi:L.urate pi:L.irate urate:L.pi urate:L.urate urate:L.irate irate:L.pi irate:L.urate irate:L.irate) name(figure1_2)}{p_end}
{pstd}Plot the log standard deviation with user specific title.{p_end}
{phang2}{cmd:. tvpplot, plotcoef(l1) title("Log standard deviation of shocks in inflation equation") name(figure1_3)}{p_end}
{phang2}{cmd:. tvpplot, plotcoef(l2) title("Log standard deviation of shocks in unemployment equation") name(figure1_4)}{p_end}
{phang2}{cmd:. tvpplot, plotcoef(l3) title("Log standard deviation of shocks in interest rate equation") name(figure1_5)}{p_end}
{synoptline}
{pstd}Example 2 (TVP-LP): Government spending to news shock (Inoue et al., 2024a).{p_end}
{phang2}{cmd:. use data_Fiscal.dta, clear}{p_end}
{phang2}{cmd:. tsset time}{p_end}
{phang2}{cmd:. mat define cmat = (0,3,6,9,12,15)}{p_end}
{pstd}Estimate the model from horizon 0 to 19, and plot the impulse response function. {p_end}
{phang2}{cmd:. tvpreg gs shock gs_l* gdp_l* shock_l*, newey cmatrix(cmat) nhor(0/19) chol getband plotcoef(gs:shock) plotconst name(figure2_1)}{p_end}
{pstd}Plot the impulse response function in specific periods. {p_end}
{phang2}{cmd:. tvpplot, plotcoef(gs:shock) period(recession) name(figure2_2)}{p_end}
{pstd}Plot the parameter path within certain horizon. {p_end}
{phang2}{cmd:. tvpplot, plotcoef(gs:shock) plotnhor(1) plotconst name(figure2_3)}{p_end}
{phang2}{cmd:. tvpplot, plotcoef(gs:shock) plotnhor(1) period(recession) name(figure2_4)}{p_end}
{synoptline}
{pstd}Example 3 (TVP-LP-IV): Fiscal multiplier (Inoue et al., 2024a).{p_end}
{phang2}{cmd:. use data_Fiscal.dta, clear}{p_end}
{phang2}{cmd:. tsset time}{p_end}
{phang2}{cmd:. mata: cB = (3*(0::5))'; cB = cB # J(1,6,1)}{p_end}
{phang2}{cmd:. mata: cv = (3*(0::5))'; cv = J(1,6,1) # cv}{p_end}
{phang2}{cmd:. mata: cmat = (J(28,1,1) # cB) \ (J(3,1,1) # cv)}{p_end}
{phang2}{cmd:. mata: st_matrix("cmat",cmat)}{p_end}
{pstd}Estimate the fiscal multiplier from horizon 4 to 20 without plotting. {p_end}
{phang2}{cmd:. tvpreg gdp gs_l* gdp_l* shock_l* (gs = shock), cmatrix(cmat) nwlag(8) nhor(4/20) cum}{p_end}
{pstd}Plot the multiplier over horizons in specific periods.{p_end}
{phang2}{cmd:. tvpplot, plotcoef(gdp:gs) period(recession) name(figure3_1)}{p_end}
{pstd}Plot the multiplier path within certain horizon.{p_end}
{phang2}{cmd:. tvpplot, plotcoef(gdp:gs) plotnhor(8) name(figure3_2)}{p_end}
{synoptline}
{pstd}Example 4 (TVP-IV): Structural Phillips curve (Inoue et al., 2024b).{p_end}
{phang2}{cmd:. use data_PC.dta, clear}{p_end}
{phang2}{cmd:. tsset time}{p_end}
{phang2}{cmd:. mat define cmat = (0, 0.8, 1.6, 2.4, 3.2, 4)}{p_end}
{pstd}Estimate the Phillips curve without plotting. {p_end}
{phang2}{cmd:. tvpreg pi pib (x pif = x_l* ygap_l*), level(90) cmatrix(cmat) getband nwlag(4)}{p_end}
{pstd}Plot the slope parameters. {p_end}
{phang2}{cmd:. tvpplot, plotcoef(pi:x) name(figure4_1)}{p_end}
{phang2}{cmd:. tvpplot, plotcoef(pi:pif) name(figure4_2)}{p_end}
{phang2}{cmd:. tvpplot, plotcoef(pi:pib) name(figure4_3)}{p_end}
{synoptline}
{pstd}Example 5 (TVP-Weak-IV): Phillips curve during pandemics (Inoue et al., 2024b).{p_end}
{phang2}{cmd:. use data_PC_weak.dta, clear}{p_end}
{phang2}{cmd:. tsset time}{p_end}
{phang2}{cmd:. mat define cmat = (0, 0.8, 1.6, 2.4, 3.2, 4)}{p_end}
{pstd}Estimate the Phillips curve using weak-IV robust method without plotting. {p_end}
{phang2}{cmd:. tvpreg pi pib (x pif = x_l* pi_l* piw_l* ygap_l*), weakiv level(90) cmatrix(cmat) getband nwlag(19) fix}{p_end}
{pstd}Plot the smoothed slope parameters. {p_end}
{phang2}{cmd:. tvpplot, plotcoef(pi:x) movavg(7) name(figure5_1)}{p_end}
{phang2}{cmd:. tvpplot, plotcoef(pi:pif) movavg(7) name(figure5_2)}{p_end}
{phang2}{cmd:. tvpplot, plotcoef(pi:pib) movavg(7) name(figure5_3)}{p_end}
{synoptline}


{marker storedresults}{...}
{title:Stored results}

{pstd}{cmd:tvpreg} stores the following in {cmd:e()}:

{synoptset 23 tabbed}{...}
{p2col 5 23 26 2: Scalars}{p_end}
{synopt:{cmd:e(T)}}sample size{p_end}
{synopt:{cmd:e(q)}}number of time varying parameters{p_end}
{synopt:{cmd:e(level)}}confidence level{p_end}

{p2col 5 23 26 2: Macros}{p_end}
{synopt:{cmd:e(title)}}{opt Time-Varying-Parameter Estimation}{p_end}
{synopt:{cmd:e(cmd)}}{opt tvpreg}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(model)}}estimator type{p_end}
{synopt:{cmd:e(paraname)}}parameter name of the model{p_end}
{synopt:{cmd:e(irfname)}}parameter name of the TVP-VAR impulse response functions{p_end}
{synopt:{cmd:e(horizon)}}number (list) of horizons{p_end}
{synopt:{cmd:e(cum)}}whether the variables are cumulated{p_end}
{synopt:{cmd:e(timevar)}}name of time variable{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(indepvar)}}name of independent variables{p_end}
{synopt:{cmd:e(instd)}}name of instrumented variables{p_end}
{synopt:{cmd:e(insts)}}name of instruments{p_end}
{synopt:{cmd:e(inexog)}}name of included instruments{p_end}
{synopt:{cmd:e(exexog)}}name of excluded instruments{p_end}
{synopt:{cmd:e(varlags)}}number list of lags in TVP-VAR{p_end}
{synopt:{cmd:e(maxl)}}maximum lag in TVP-VAR{p_end}
{synopt:{cmd:e(constant)}}whether constant is included{p_end}
{synopt:{cmd:e(band)}}whether confidence band is obtained{p_end}
{synopt:{cmd:e(cholesky)}}whether triangular reduction of the coveriance matrix is implemented{p_end}

{p2col 5 23 26 2: Matrices}{p_end}
{synopt:{cmd:e(c)}}input {it:C} grid matrix{p_end}
{synopt:{cmd:e(qLL)}}qLL test statistic if {it:ci} is default{p_end}
{synopt:{cmd:e(weight)}}weights{p_end}
{synopt:{cmd:e(beta_const)}}constant parameter estimate{p_end}
{synopt:{cmd:e(beta)}}parameter path{p_end}
{synopt:{cmd:e(beta_lb)}}lower bound of the parameter path{p_end}
{synopt:{cmd:e(beta_ub)}}upper bound of the parameter path{p_end}
{synopt:{cmd:e(Omega)}}covariance matrix of the parameter path{p_end}
{synopt:{cmd:e(varirf_const)}}constant parameter estimate of VAR impulse response function{p_end}
{synopt:{cmd:e(varirf)}}TVP-VAR impulse response function path{p_end}
{synopt:{cmd:e(varirf_lb)}}lower bound of the TVP-VAR impulse response function path{p_end}
{synopt:{cmd:e(varirf_ub)}}upper bound of the TVP-VAR impulse response function path{p_end}
{synopt:{cmd:e(residual)}}residuals{p_end}

{p2col 5 23 26 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}


{title:References}

{phang}Müller, U.K. and Petalas, P.E., 2010. "Efficient estimation of the parameter path in unstable time series models". The Review of Economic Studies, 77(4), pp.1508-1539.{p_end}

{phang}Inoue, A., Rossi, B. and Wang, Y., 2024a. "Local Projections in Unstable Environments". {it:Working Paper.}{p_end}

{phang}Inoue, A., Rossi, B. and Wang, Y., 2024b. "Has the Phillips curve flattened?". {it:Working Paper.}{p_end}

{phang}Inoue, A., Rossi, B., Wang, Y., and Zhou, L., 2024. "Estimation of the parameter path in unstable environments: the tvpreg command".  {it:Working Paper.}{p_end}


{title:Compatibility and known issues}

{phang} Please ensure the following information before running the {opt tvpreg} program:{p_end}
{phang2}. The programs are written in version 17.0.{p_end}
{phang2}. Time-series structure is declared: {opt tsset} {it: timevar}.{p_end}
{phang2}. The time-series should be consecutive with no missing values.{p_end}
{phang2}. The tvpreg and tvpplot commands use the {help bgshade:bgshade} package to add background shading in the parameter path. 
It can be found and installed in Stata by typing -ssc install bgshade- in the command window.{p_end}


{title:Author}

{p 4 4 2}
{cmd:Atsushi INOUE}{break}
Department of Eonomics, Vanderbilt University.{break}

{p 4 4 2}
{cmd:Barbara ROSSI}{break}
Universitat Pompeu Fabra, Barcelona School of Economics, and CREI.{break}

{p 4 4 2}
{cmd:Yiru WANG}{break}
Department of Economics, University of Pittsburgh.{break}

{p 4 4 2}
{cmd:Lingyun ZHOU}{break}
PBC School of Finance, Tsinghua University.{break}
