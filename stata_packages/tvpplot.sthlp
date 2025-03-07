{smcl}
{* July 2022}{...}
{title:Title}

{p 4 4 2}
{bf:tvpplot} —— Visualize the time-varying coefficients and impulse responses after {cmd:tvpreg}.

{title:Syntax}

{p 8 15 2} {cmd:tvpplot} [{cmd:,} {opt plotcoef(namelist)} {opt plotvarirf(namelist)} {opth hor:izon(numlist)} {opt plotc:onst} {opth period(varname)} {opth movavg(#)}
{cmd:noci} {opt ti:tle(tinfo)} {opt yti:tle(axis_title)} {opt xti:tle(axis_title)} {opth name(name_option)}
{opt tvpl:egend(string)} {opt constl:egend(string)} {opt bandl:egend(string)} {opt shadel:egend(string)} {opt periodl:egend(namelist)} {opth sch:eme(schemename)} {opth tvpc:olor(colorstyle)} {opth constc:olor(colorstyle)} {opt nolegend}] 
{p_end}

{synoptset 23 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt plotcoef(namelist)}}specifies the parameter name (list) to be plotted.
The parameter name is stored in {cmd:e(coefname)}.
To plot the slope parameters, {it:namelist} is specified by {it:"yvar1:xvar1 yvar2:xvar2 ..."} and locates the parameter to be plotted.
These parameters correspond to the coefficients of the variables {it:xvar#} in the equations for {it:yvar#}.
To plot the covariance matrix parameters when {cmd:cholesky} is specified,
{it:namelist} is
specified by {it:"aij ... li ..."},
where {it:aij} denotes the {it:i}-th row and {it:j}-th column element in {it:A(t)},
{it:li} denotes the {it:i}-th element in {it:lnσ(t)};
{it:A(t)Σ(e,t)A(t)' = Σ(ε,t)Σ(ε,t)'}; {it:σ(t)=diag(Σ(ε,t))};
{it:A(t)} is a lower-triangular matrix with ones on the main diagonal;
{it:Σ(e,t)} is the covariance matrix; and {it:i > j}.
To plot the convariance matrix parameters when {cmd:cholesky} is not specified,
{it:namelist} is specified by {it:"vij ..."},
where {it:vij} denotes the {it:i}-th row and {it:j}-th column element in the covariance matrix {it:Σ(e,t)},
and {it:i ≥ j}.{p_end}
{synopt :{opt plotvarirf(namelist)}}specifies the parameter name (list) of the time-varying parameter vector autoregression impulse responses to be plotted.
The parameter name is stored in {cmd:e(varirfname)}.
{it:namelist} is specified as {it:"var1:shock1 var2:shock2 ..."} and locates the impulse response to be plotted, 
where {it:var} ({it:shock}) is the variable (shock) of interest.
This option only applies when the {it:estimator} option is {cmd:var}.
{opt plotcoef(namelist)} and {opt plotvarirf(namelist)} cannot be specified together.{p_end}
{synopt :{opth plotnhor:izon(numlist)}}specifies the number (list) of horizons to be plotted.
This list must be a subset of the number list in {opth nhorizon(numlist)}.
The command plots the parameter path over time (horizons)
when {opth plotnhorizon(numlist)} specifies a single number (or a list of numbers).
The default is the list specified by {opth nhorizon(numlist)}.{p_end}
{synopt :{opt plotc:onst}}includes the constant parameter estimate (a line in the graph).
This option does not apply when the {it:estimator} option is {cmd:weakiv}.{p_end}
{synopt :{opth period(varname)}}specifies the dummy variable indicating the time points to be highlighted in the plots.
when {opth plotnhorizon(numlist)} specifies a list of numbers, this option indicates the specific time points to be plotted in the parameter paths across horizons.
When {opth plotnhorizon(numlist)} specifies a single number, this option adds a background shade in the graph at the selected time points of the parameter path.{p_end}
{synopt :{opth movavg(#)}}specifies the degree of the moving average when ploting a (smoothed) parameter path.
The default is {cmd:movavg(1)}.{p_end}
{synopt :{opt noci}}suppresses the confidence band in the figures.
The confidence band is only computed and stored when {cmd:getband} is specified.{p_end}
{synopt :{opt ti:tle(tinfo)}}specifies the graph title.
The default is the parameter name.{p_end}
{synopt :{opt yti:tle(axis_title)}}specifies y-axis title.
The default is "Parameter."{p_end}
{synopt :{opt xti:tle(axis_title)}}specifies x-axis title
The default is "Time" ("Horizons") for parameter path across time (horizons).{p_end}
{synopt :{opt tvpl:egend(string)}}specifies the legend for the time-varying-parameter estimate.
The default is "Time-varying parameter."{p_end}
{synopt :{opt constl:egend(string)}}specifies the legend for the constant-parameter estimate.
The default is "Constant parameter."
This option may be specified only when {opt plotconst} is specified.{p_end}
{synopt :{opt bandl:egend(string)}}specifies the legend name for the confidence band.
The default is "95% confidence band."
This option may be specified only when {opt getband} is specified and {opt noci} is not specified.{p_end}
{synopt :{opt shadel:egend(string)}}specifies the legend for the background shade.
The default is the variable name specified by {opth period(varname)}.
This option may be specified only when {opth period(varname)} is specified and a single number is specified by {opth plotnhorizon(numlist)}.{p_end}
{synopt :{opt periodl:egend(namelist)}}specifies the legend for the time-varying estimates in different time periods;
{it:namelist} is specified by {it:"periodname1,periodname2,..."}, where the order of names should match the increasing order of time periods.
If this option is not specified, all the time-varying estimates have the same legend specified by {opt tvpl:egend(string)}.
This option may be specified only when a list of numbers is specified by {opth plotnhorizon(numlist)}.
{p_end}
{synopt :{opt nolegend}}suppresses the legend.
The legend is displayed only when more than two of the above elements are plotted in the figure.{p_end}
{synopt :{opth sch:eme(schemename)}}specifies the overall look of the graph.
The default is controled by {opt set scheme}.{p_end}
{synopt :{opth tvpc:olor(colorstyle)}}specifies the color of the time-varying-parameter estimate.
The default is {cmd:tvpcolor(green)}.{p_end}
{synopt :{opth constc:olor(colorstyle)}}specifies the color of the constant-parameter estimate.
The default is {cmd:constcolor(black)}.{p_end}
{synopt :{opth name(name_option)}}specifies the graph name.
The default is "tvpreg."{p_end}
{synoptline}
