{smcl}
{* *! version 21jan2023}{...}
{hline}
{cmd:help ddml}{right: v1.2}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{hi: ddml} {hline 2}}Stata package for Double Debiased Machine Learning{p_end}
{p2colreset}{...}

{pstd}
{opt ddml} implements algorithms for causal inference aided by supervised
machine learning as proposed in 
{it:Double/debiased machine learning for treatment and structural parameters}
(Econometrics Journal, 2018). Five different models are supported, allowing for 
binary or continous treatment variables and endogeneity, high-dimensional 
controls and/or instrumental variables. 
{opt ddml} supports a variety of different ML programs, including
but not limited to {helpb lassopack} and {helpb pystacked}. 

{pstd}
The package includes the wrapper program {helpb qddml},
which uses a simplified one-line syntax, 
but offers less flexibility.

{pstd}
{opt qddml} relies on {helpb crossfit}, which can be used as a standalone
program.

{pstd}
Please check the {helpb ddml##examples:examples} provided at the end of the help file.

{marker syntax}{...}
{title:Syntax}

{pstd}
Estimation with {cmd:ddml}
proceeds in four steps. 

{pstd}
{ul:Step 1.} Initialize {cmd:ddml} and select model:

{p 8 14}{cmd:ddml init}
{it:model} [if] [in]
[ , {opt mname(name)} {opt kfolds(integer)}
{opt fcluster(varname)}
{opt foldvar(varlist)} {opt reps(integer)} 
{opt norandom} {opt tabfold} {opt vars(varlist)}{bind: ]}

{pstd}
where {it:model} is either {it:partial}, {it:iv}, {it:interactive}, {it:fiv}, {it:interactiveiv};
see {helpb ddml##models:model descriptions}.

{pstd}
{ul:Step 2.} Add supervised ML programs for estimating conditional expectations:

{p 8 14}{cmd:ddml} {it:eq} 
[ , {opt mname(name)} {opt vname(varname)} {opt l:earner(varname)}
{opt vtype(string)}
{opt predopt(string)}{bind: ] :}
{it:command} {it:depvar} {it:vars} [ , {it:cmdopt}{bind: ]}

{pstd}
where, depending on model chosen in Step 1,
{it:eq} is either 
{it:E[Y|X]} {it:E[Y|D,X]} {it:E[Y|X,Z]} {it:E[D|X]} {it:E[D|X,Z]} {it:E[Z|X]}.
{it:command} is a supported supervised ML program (e.g. {helpb pystacked} or {helpb cvlasso}). 
See {helpb ddml##compatibility:supported programs}.

{pstd}
Note: Options before ":" and after the first comma refer to {cmd:ddml}. 
Options that come after the final comma refer to the estimation command. 
{p_end}

{pstd}
{ul:Step 3.} Cross-fitting:

{p 8 14}{cmd:ddml crossfit} [ , {opt mname(name)} {opt shortstack}{bind: ]} 

{pstd}
This step implements the cross-fitting algorithm. Each learner is fitted iteratively on training folds and out-of-sample predicted values are obtained.

{pstd}
{ul:Step 4.} Estimate causal effects:

{p 8 14}{cmd:ddml estimate} [ , {opt mname(name)} {cmdab:r:obust} {opt cluster(varname)} {opt vce(type)} {opt atet} {opt ateu} {opt trim(real)}{bind: ]} 

{pstd}
The {cmd:ddml estimate} command returns treatment effect estimates for all combination of learners 
added in Step 2.

{pstd}
{ul:Optional.} Report/post selected results:

{p 8 14}{cmd:ddml estimate} [ , {opt mname(name)} {opt spec(integer or string)} {opt rep(integer or string)} {opt allcombos} {opt not:able} {opt replay} {bind: ]} 

{pstd}
{ul:Auxiliary sub-programs:}
     
{pstd} 
Download latest {cmd:ddml} from Github:

{p 8 14}{cmd:ddml update} 

{pstd}
Report information about {cmd:ddml} model:

{p 8 14}{cmd:ddml desc} [ , {opt mname(name)} {opt learn:ers} {opt cross:fit} {opt est:imates} {opt sam:ple} {opt all}{bind: ]}

{pstd}
Export results in csv format:

{p 8 14}{cmd:ddml export} [ using filename , {opt mname(name)}{bind: ]}

{pstd}
Retrieve information from {cmd:ddml}:

{p 8 14}{cmd:ddml extract} [ {it:object_name} , {opt mname(name)} {opt show(display_item)} {opt ename(name)} {opt vname(varname)}
{opt stata} {opt keys} {opt key1(string)} {opt key2(string)} {opt key3(string)} {opt subkey1(string)}
{opt subkey2(string)}{bind: ]}

{pstd}
{it:display_item} can be {it:mse}, {it:n} or {it:pystacked}.
{cmd:ddml} stores many internal results on associative arrays.
These can be retrieved using the different key options.
See {helpb ddml extract} for details.

{pstd}
Drop the {cmd:ddml} estimation {it:mname} and all associated variables:

{p 8 14}{cmd:ddml drop} {it:mname}

{pstd}
Report overlap plots ({it:interactive} and {it:interactiveiv} models only):

{p 8 14}{cmd:ddml overlap} [ {opt mname(name)} {opt replist(numlist)} {opt pslist(namelist)} {opt n(integer)} {opt kernel(name)}
{opt name(name [, replace])} {opt title(string)} {opt subtitle(string)} {opt lopt0(string)}
{opt lopt1(string)}{bind: ]}

{pstd}One overlap (line) plot of propensity scores is reported for each treatment variable learner;
by default, propensity scores for all crossfit samples are plotted.
Overlap plots for the treatment variables are combined using {helpb graph combine}.

{marker syntax}{...}
{title:Options}

{synoptset 20}{...}
{synopthdr:init options}
{synoptline}
{synopt:{opt mname(name)}}
name of the DDML model. Allows to run multiple DDML
models simultaneously. Defaults to {it:m0}.
{p_end}
{synopt:{opt kfolds(integer)}}
number of cross-fitting folds. The default is 5.
{p_end}
{synopt:{opt fcluster(varname)}}
cluster identifiers for cluster randomization of random folds.
{p_end}
{synopt:{opt foldvar(varlist)}}
integer variable with user-specified cross-fitting folds (one per cross-fitting repetition).
{p_end}
{synopt:{opt norandom}}
use observations in existing order instead of randomizing before splitting into folds;
if multiple resamples, applies to first resample only;
ignored if user-defined fold variables are provided in {opt foldvar(varlist)}.
{p_end}
{synopt:{opt reps(integer)}}
cross-fitting repetitions, i.e., how often the cross-fitting procedure is
repeated on randomly generated folds. 
{p_end}
{synopt:{opt tabfold}}
prints a table with frequency of observations by fold.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}

{synoptset 20}{...}
{synopthdr:Equation options}
{synoptline}
{synopt:{opt mname(name)}}
name of the DDML model. Defaults to {it:m0}.
{p_end}
{synopt:{opt vname(varname)}}
name of the dependent variable in the reduced form estimation. 
This is usually inferred from the command line but is mandatory
for the {it:fiv} model.
{p_end}
{synopt:{opt l:earner(varname)}}
optional name of the variable to be created. 
{p_end}
{synopt:{opt vtype(string)}}
optional variable type of the variable to be created. Defaults to {it:double}. 
{it:none} can be used to leave the type field blank 
(required when using {cmd:ddml} with {helpb rforest}.)
{p_end}
{synopt:{opt predopt(string)}}
{cmd:predict} option to be used to get predicted values. 
Typical values could be {opt xb} or {opt pr}. Default is 
blank. 
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}

{synoptset 20}{...}
{synopthdr:Cross-fitting}
{synoptline}
{synopt:{opt mname(name)}}
name of the DDML model. Defaults to {it:m0}.
{p_end}
{synopt:{opt shortstack}} asks for short-stacking to be used.
Short-stacking runs constrained non-negative least squares on the
cross-fitted predicted values to obtain a weighted average
of several base learners.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}

{synoptset 20}{...}
{synopthdr:Estimation}
{synoptline}
{synopt:{opt mname(name)}}
name of the DDML model. Defaults to {it:m0}.
{p_end}
{synopt:{opt spec(integer/string)}}
select specification. This can either be the specification number, {it:mse} for minimum-MSE specification (the default) or {it:ss} for short-stacking. 
{p_end}
{synopt:{opt rep(integer/string)}}
select resampling iteration. This can either be the cross-fit repetition number, {it:mn} for mean aggregation or {it:md} for median aggregation (the default).
{p_end}
{synopt:{cmdab:r:obust}}
report SEs that are robust to the
presence of arbitrary heteroskedasticity.
{p_end}
{synopt:{opt cluster(varname)}}
select cluster-robust variance-covariance estimator, e.g. {cmd:vce(hc3)} or {cmd:vce(cluster id)}.
{p_end}
{synopt:{opt vce(type)}}
select variance-covariance estimator; see {helpb regress##vcetype:here}.
{p_end}
{synopt:{cmdab:noc:onstant}}
suppress constant term ({it:partial}, {it:iv}, {it:fiv} models only). Since the residualized outcome 
and treatment may not be exactly mean-zero in finite samples, {cmd:ddml} includes the constant by 
default in the estimation stage of partially linear models.
{p_end}
{synopt:{cmdab:showc:onstant}}
display constant term in summary estimation output table ({it:partial}, {it:iv}, {it:fiv} models only).
{p_end}
{synopt:{opt atet}}
report average treatment effect of the treated (default is ATE).
{p_end}
{synopt:{opt ateu}}
report average treatment effect of the untreated (default is ATE).
{p_end}
{synopt:{opt trim(real)}}
trimming of propensity scores for the Interactive and Interactive IV models. The default is 0.01
(that is, values below 0.01 and above 0.99 are set 
to 0.01 and 0.99, respectively).
{p_end}
{synopt:{opt allcombos}}
estimates all possible specifications. By default, only the min-MSE (or short-stacking)
specification is estimated and displayed.
{p_end}
{synopt:{opt replay}}
used in combination with {opt spec()} and {opt rep()} to display and return estimation results.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}

{synoptset 20}{...}
{synopthdr:Auxiliary}
{synoptline}
{synopt:{opt mname(name)}}
name of the DDML model. Defaults to {it:m0}.
{p_end}
{synopt:{opt replist(numlist)}}
(overlap plots) list of crossfitting resamples to plot. Defaults to all.
{p_end}
{synopt:{opt pslist(namelist)}}
(overlap plots) varnames of propensity scores to plot (excluding the resample number). Defaults to all.
{p_end}
{synopt:{opt n(integer)}}
(overlap plots) see {helpb teffects overlap}.
{p_end}
{synopt:{opt kernel(name)}}
(overlap plots) see {helpb teffects overlap}.
{p_end}
{synopt:{opt name(name)}}
(overlap plots) see {helpb graph combine}.
{p_end}
{synopt:{opt title(string)}}
(overlap plots) see {helpb graph combine}.
{p_end}
{synopt:{opt subtitle(string)}}
(overlap plots) see {helpb graph combine}.
{p_end}
{synopt:{opt lopt0(string)}}
(overlap plots) options for line plot of untreated; default is solid/navy; see {helpb line}.
{p_end}
{synopt:{opt lopt0(string)}}
(overlap plots) options for line plot of treated; default is short dash/dark orange; see {helpb line}.
{p_end}
{synoptline}

{p2colreset}{...}
{pstd}

{marker models}{...}
{title:Models}

{pstd}
This section provides an overview of supported models. 

{pstd}
Throughout we use {it:Y} to denote the outcome variable, 
{it:X} to denote confounders, 
{it:Z} to denote instrumental variable(s), and
{it:D} to denote the treatment variable(s) of interest.

{pstd}
{ul:Partially linear model} [{it:partial}]

	Y = {it:a}.D + g(X) + U
        D = m(X) + V

{pstd}
where the aim is to estimate {it:a} while controlling for X. To this end, 
we estimate the conditional expectations
E[Y|X] and E[D|X] using a supervised machine learner.

{pstd}
{ul:Interactive model} [{it:interactive}]

	Y = g(X,D) + U
        D = m(X) + V

{pstd}
which relaxes the assumption that X and D are separable. 
D is a binary treatment variable. 
We estimate the conditional expectations E[D|X], as well as 
E[Y|X,D=0] and E[Y|X,D=1] (jointly added using {cmd:ddml E[Y|X,D]}).

{pstd}
{ul:Partially linear IV model} [{it:iv}]

	Y = {it:a}.D + g(X) + U
        Z = m(X) + V

{pstd}
where the aim is to estimate {it:a}. 
We estimate the conditional expectations E[Y|X], 
E[D|X] and E[Z|X] using a supervised machine
learner.

{pstd}
{ul:Interactive IV model}  [{it:interactiveiv}]

	Y = g(Z,X) + U
        D = h(Z,X) + V
        Z = m(X) + E

{pstd}
where the aim is to estimate the local average treatment effect.
We estimate, using a supervised machine
learner, the following conditional expectations:
E[Y|X,Z=0] and E[Y|X,Z=1] (jointly added using {cmd:ddml E[Y|X,Z]});
E[D|X,Z=0] and E[D|X,Z=1] (jointly added using {cmd:ddml E[D|X,Z]});
E[Z|X].

{pstd}
{ul:Flexible Partially Liner IV model} [{it:fiv}]

	Y = {it:a}.D + g(X) + U
        D = m(Z) + g(X) + V 

{pstd}
where the estimand of interest is {it:a}. 
We estimate the conditional expectations
E[Y|X], 
E[D^|X] and D^:=E[D|Z,X] using a supervised machine
learner. The instrument is then formed as D^-E^[D^|X] where E^[D^|X] denotes
the estimate of E[D^|X]. 

{pstd}
Note: "{D}" is a placeholder that is used because last step (estimation of E[D|X]) 
uses the fitted values from estimating E[D|X,Z].
Please see {helpb ddml##examples:example section below}.

{marker compatibility}{...}
{title:Compatible programs}

{pstd}
{opt ddml} is compatible with a large set of user-written Stata commands. 
It has been tested with 

{p 7 9 0} 
- {helpb lassopack} for regularized regression (see {helpb lasso2}, {helpb cvlasso}, {helpb rlasso}).

{p 7 9 0} 
- the {helpb pystacked} package (see {helpb pystacked}. 
Note that {helpb pystacked} requires Stata 16.

{p 7 9 0} 
- {helpb rforest} by Zou & Schonlau. Note that {cmd:rforest} requires the option 
{cmd:vtype(none)}. 

{p 7 9 0} 
- {helpb svmachines} by Guenther & Schonlau.

{pstd}
Beyond these, it is compatible with any Stata program that 

{p 7 9 0} 
- uses the standard "{it:reg y x}" syntax,

{p 7 9 0} 
- supports {it:if}-conditions,

{p 7 9 0} 
- and comes with {helpb predict} post-estimation programs.

{marker examples}{...}
{title:Examples}

{pstd}
Below we demonstrate the use of {cmd:ddml} for each of the 5 models supported. 
Note that estimation models are chosen for demonstration purposes only and 
kept simple to allow you to run the code quickly.

{pstd}{ul:Partially linear model I.} 

{pstd}Preparation: we load the data, define global macros and set the seed.{p_end}
{phang2}. {stata "use https://github.com/aahrens1/ddml/raw/master/data/sipp1991.dta, clear"}{p_end}
{phang2}. {stata "global Y net_tfa"}{p_end}
{phang2}. {stata "global D e401"}{p_end}
{phang2}. {stata "global X tw age inc fsize educ db marr twoearn pira hown"}{p_end}
{phang2}. {stata "set seed 42"}{p_end}

{pstd}We next initialize the ddml estimation and select the model.
{it:partial} refers to the partially linear model.
The model will be stored on a Mata object with the default name "m0"
unless otherwise specified using the {opt mname(name)} option.{p_end} 
{pstd}Note that we set the number of random folds to 2, so that 
the model runs quickly. The default is {opt kfolds(5)}. We recommend 
to consider at least 5-10 folds and even more if your sample size is small.{p_end} 
{pstd}Note also that we recommend re-running the model multiple times on 
different random folds; see options {opt reps(integer)}.{p_end} 
{phang2}. {stata "ddml init partial, kfolds(2)"}{p_end}

{pstd}We add a supervised machine learners for estimating the conditional 
expectation E[Y|X]. We first add simple linear regression.{p_end}
{phang2}. {stata "ddml E[Y|X]: reg $Y $X"}{p_end}

{pstd}We can add more than one learner per reduced form equation. Here, we 
add a random forest learner. We do this using {helpb pystacked}.
In the next example we show how to use {helpb pystacked} to stack multiple learners,
but here we use it to implement a single learner.{p_end}
{phang2}. {stata "ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)"}{p_end}

{pstd}We do the same for the conditional expectation E[D|X].{p_end}
{phang2}. {stata "ddml E[D|X]: reg $D $X"}{p_end}
{phang2}. {stata "ddml E[D|X]: pystacked $D $X, type(reg) method(rf)"}{p_end}

{pstd}Optionally, you can check if the learners have been added correctly.
{p_end}
{phang2}. {stata "ddml desc"}{p_end}

{pstd}Cross-fitting. The learners are iteratively fitted on the training data.
This step may take a while.
{p_end}
{phang2}. {stata "ddml crossfit"}{p_end}

{pstd}Finally, we estimate the coefficients of interest. 
Since we added two learners for each of our two reduced form equations, 
there are four possible specifications. 
By default, the result shown corresponds to the specification 
with the lowest out-of-sample MSPE:
{p_end}
{phang2}. {stata "ddml estimate, robust"}{p_end}

{pstd}To estimate all four specifications, we use the {cmd:allcombos} option:
{p_end}
{phang2}. {stata "ddml estimate, robust allcombos"}{p_end}

{pstd}After having estimated all specifications, we can retrieve 
specific results. Here we use the specification relying on OLS for both
estimating both E[Y|X] and E[D|X]:
{p_end}
{phang2}. {stata "ddml estimate, robust spec(1) replay"}{p_end}

{pstd}You could manually retrieve the same point estimate by 
typing:
{p_end}
{phang2}. {stata "reg Y1_reg D1_reg, robust"}{p_end}
{pstd}or graphically:
{p_end}
{phang2}. {stata "twoway (scatter Y1_reg D1_reg) (lfit Y1_reg D1_reg)"}{p_end}

{pstd}where {opt Y1_reg} and {opt D1_reg} are the orthogonalized
versions of {opt net_tfa} and {opt e401}.
{p_end}

{pstd}To describe the ddml model setup or results in detail,
you can use {cmd: ddml describe} with the relevant option ({opt sample}, {opt learners}, {opt crossfit}, {opt estimates}),
or just describe them all with the {opt all} option:
{p_end}
{phang2}. {stata "ddml describe, all"}{p_end}

{pstd}{ul:Partially linear model II. Stacking regression using {helpb pystacked}.}

{pstd}Stacking regression is a simple and powerful method for 
combining predictions from multiple learners.
It is available in Stata via the {helpb pystacked} package.
Below is an example with the partially linear model,
but it can be used with any model supported by {cmd:ddml}.{p_end}

{pstd}Preparation: use the data and globals as above.
Use the name {cmd:m1} for this new estimation, 
to distinguish it from the previous example that uses the default name {cmd:m0}.
This enables having multiple estimations available for comparison.
Also specify 5 resamplings.
{p_end}
{phang2}. {stata "set seed 42"}{p_end}
{phang2}. {stata "ddml init partial, kfolds(2) reps(5) mname(m1)"}{p_end}

{pstd}Add supervised machine learners for estimating conditional expectations.
The first learner in the stacked ensemble is OLS.
We also use cross-validated lasso, ridge and two random forests with different settings, 
which we save in the following macros:{p_end}
{phang2}. {stata "global rflow max_features(5) min_samples_leaf(1) max_samples(.7)"}{p_end}
{phang2}. {stata "global rfhigh max_features(5) min_samples_leaf(10) max_samples(.7)"}{p_end}

{pstd}
In each step, we add the {cmd:mname(m1)} option to ensure that the learners
are not added to the {cmd:m0} model which is still in memory.
We also specify the names of the variables containing the estimated conditional
expectations using the {opt learner(varname)} option.
This avoids overwriting the variables created for the {cmd:m0} model using default naming.{p_end}

{phang2}. {stata "ddml E[Y|X], mname(m1) learner(Y_m1): pystacked $Y $X || method(ols) || method(lassocv) || method(ridgecv) || method(rf) opt($rflow) || method(rf) opt($rfhigh), type(reg)"}{p_end}
{phang2}. {stata "ddml E[D|X], mname(m1) learner(D_m1): pystacked $D $X || method(ols) || method(lassocv) || method(ridgecv) || method(rf) opt($rflow) || method(rf) opt($rfhigh), type(reg)"}{p_end}

{pstd}
Note: Options before ":" and after the first comma refer to {cmd:ddml}. 
Options that come after the final comma refer to the estimation command. 
Make sure to not confuse the two types of options.
{p_end}

{pstd}Check if learners were correctly added:{p_end}
{phang2}. {stata "ddml desc, mname(m1) learners"}{p_end}

{pstd}Cross-fitting and estimation.{p_end}
{phang2}. {stata "ddml crossfit, mname(m1)"}{p_end}
{phang2}. {stata "ddml estimate, mname(m1) robust"}{p_end}

{pstd}Examine the stacking weights and MSEs reported by {cmd:pystacked}.{p_end}
{phang2}. {stata "ddml extract, mname(m1) show(pystacked)"}{p_end}
{phang2}. {stata "ddml extract, mname(m1) show(mse)"}{p_end}

{pstd}We can compare the effects with the first {cmd:ddml} model 
(if you have run the first example above).{p_end}
{phang2}. {stata "ddml estimate, mname(m0) replay"}{p_end}

{pstd}{ul:Partially linear model III. Multiple treatments.}

{pstd}We can also run the partially linear model with multiple treatments. 
In this simple example, we estimate the effect of both 401k elligibility 
{cmd:e401} and education {cmd:educ}. 
Note that we remove {cmd:educ} 
from the set of controls.{p_end}
{phang2}. {stata "use https://github.com/aahrens1/ddml/raw/master/data/sipp1991.dta, clear"}{p_end}
{phang2}. {stata "global Y net_tfa"}{p_end}
{phang2}. {stata "global D1 e401"}{p_end}
{phang2}. {stata "global D2 educ"}{p_end}
{phang2}. {stata "global X tw age inc fsize db marr twoearn pira hown"}{p_end}
{phang2}. {stata "set seed 42"}{p_end}

{pstd}Initialize the model.{p_end}
{phang2}. {stata "ddml init partial, kfolds(2)"}{p_end}

{pstd}Add learners. Note that we add leaners with both {cmd:$D1} and
{cmd:$D2} as the dependent variable.{p_end}
{phang2}. {stata "ddml E[Y|X]: reg $Y $X"}{p_end}
{phang2}. {stata "ddml E[Y|X]: pystacked $Y $X, type(reg) method(rf)"}{p_end}
{phang2}. {stata "ddml E[D|X]: reg $D1 $X"}{p_end}
{phang2}. {stata "ddml E[D|X]: pystacked $D1 $X, type(reg) method(rf)"}{p_end}
{phang2}. {stata "ddml E[D|X]: reg $D2 $X"}{p_end}
{phang2}. {stata "ddml E[D|X]: pystacked $D2 $X, type(reg) method(rf)"}{p_end}

{pstd}Cross-fitting.{p_end}
{phang2}. {stata "ddml crossfit"}{p_end}

{pstd}Estimation.{p_end}
{phang2}. {stata "ddml estimate, robust"}{p_end}

{pstd}{ul:Partially linear IV model.} 

{pstd}Preparation: we load the data, define global macros and set the seed.{p_end}
{phang2}. {stata "use https://statalasso.github.io/dta/AJR.dta, clear"}{p_end}
{phang2}. {stata "global Y logpgp95"}{p_end}
{phang2}. {stata "global D avexpr"}{p_end}
{phang2}. {stata "global Z logem4"}{p_end}
{phang2}. {stata "global X lat_abst edes1975 avelf temp* humid* steplow-oilres"}{p_end}
{phang2}. {stata "set seed 42"}{p_end}

{pstd}Preparation: we load the data, define global macros and set the seed. Since the
data set is very small, we consider 30 cross-fitting folds.{p_end}
{phang2}. {stata "ddml init iv, kfolds(30)"}{p_end}

{pstd}The partially linear IV model has three conditional expectations: 
E[Y|X], E[D|X] and E[Z|X]. For each reduced form equation, we add
two learners: {helpb regress} and {helpb rforest}.{p_end}

{pstd}We need to add the option {opt vtype(none)} for {helpb rforest} to 
work with {cmd:ddml} since {helpb rforest}'s {cmd:predict} command doesn't
support variable types.{p_end}
{phang2}. {stata "ddml E[Y|X]: reg $Y $X"}{p_end}
{phang2}. {stata "ddml E[Y|X], vtype(none): rforest $Y $X, type(reg)"}{p_end}
{phang2}. {stata "ddml E[D|X]: reg $D $X"}{p_end}
{phang2}. {stata "ddml E[D|X], vtype(none): rforest $D $X, type(reg)"}{p_end}
{phang2}. {stata "ddml E[Z|X]: reg $Z $X"}{p_end}
{phang2}. {stata "ddml E[Z|X], vtype(none): rforest $Z $X, type(reg)"}{p_end}

{pstd}Cross-fitting and estimation. We use the {opt shortstack} option
to combine the base learners. Short-stacking is a computationally cheaper alternative
to stacking. Whereas stacking relies on cross-validated predicted values to obtain
the relative weights for the base learners, short-stacking uses the cross-fitted predicted values.{p_end}
{phang2}. {stata "ddml crossfit, shortstack"}{p_end}
{phang2}. {stata "ddml estimate, robust"}{p_end}

{pstd}If you are curious about what {cmd:ddml} does in the background:{p_end}
{phang2}. {stata "ddml estimate, allcombos spec(8) rep(1) robust"}{p_end}
{phang2}. {stata "ivreg Y2_rf (D2_rf = Z2_rf), robust"}{p_end}

{pstd}{ul:Interactive model--ATE and ATET estimation.} 

{pstd}Preparation: we load the data, define global macros and set the seed.{p_end}
{phang2}. {stata "webuse cattaneo2, clear"}{p_end}
{phang2}. {stata "global Y bweight"}{p_end}
{phang2}. {stata "global D mbsmoke"}{p_end}
{phang2}. {stata "global X prenatal1 mmarried fbaby mage medu"}{p_end}
{phang2}. {stata "set seed 42"}{p_end}

{pstd}We use 5 folds and 5 resamplings; that is, 
we estimate the model 5 times using randomly chosen folds.{p_end}
{phang2}. {stata "ddml init interactive, kfolds(5) reps(5)"}{p_end}

{pstd}We need to estimate the conditional expectations of E[Y|X,D=0], 
E[Y|X,D=1] and E[D|X]. The first two conditional expectations 
are added jointly.{p_end} 
{pstd}We consider two supervised learners: linear regression and gradient boosted
trees, stacked using {helpb pystacked}.
Note that we use gradient boosted regression trees for E[Y|X,D], but
gradient boosted classification trees for E[D|X].
{p_end} 
{phang2}. {stata "ddml E[Y|X,D]: pystacked $Y $X, type(reg) methods(ols gradboost)"}{p_end}
{phang2}. {stata "ddml E[D|X]: pystacked $D $X, type(class) methods(logit gradboost)"}{p_end}

{pstd}Cross-fitting:{p_end}
{phang2}. {stata "ddml crossfit"}{p_end}

{pstd}In the final estimation step, we can estimate
the average treatment effect (the default),
the average treatment effect of the treated ({opt atet}),
or the average treatment effect of the untreated ({opt ateu}).{p_end}
{phang2}. {stata "ddml estimate"}{p_end}
{phang2}. {stata "ddml estimate, atet"}{p_end}

{pstd}Recall that we have specified 5 resampling iterations ({opt reps(5)})
By default, the median over the minimum-MSE specification per resampling iteration is shown.
At the bottom, a table of summary statistics over resampling iterations is shown. 
{p_end}

{pstd}To estimate using the same two base learners but with short-stacking instead of stacking,
we would enter the learners separately and use the {opt shortstack} option:{p_end}

{phang2}. {stata "set seed 42"}{p_end}
{phang2}. {stata "ddml init interactive, kfolds(5) reps(5)"}{p_end}
{phang2}. {stata "ddml E[Y|X,D]: reg $Y $X"}{p_end}
{phang2}. {stata "ddml E[Y|X,D]: pystacked $Y $X, type(reg) method(gradboost)"}{p_end}
{phang2}. {stata "ddml E[D|X]: logit $D $X"}{p_end}
{phang2}. {stata "ddml E[D|X]: pystacked $D $X, type(class) method(gradboost)"}{p_end}
{phang2}. {stata "ddml crossfit, shortstack"}{p_end}
{phang2}. {stata "ddml estimate"}{p_end}

{pstd}{ul:Interactive IV model--LATE estimation.} 

{pstd}Preparation: we load the data, define global macros and set the seed.{p_end}
{phang2}. {stata "use http://fmwww.bc.edu/repec/bocode/j/jtpa.dta, clear"}{p_end}
{phang2}. {stata "global Y earnings"}{p_end}
{phang2}. {stata "global D training"}{p_end}
{phang2}. {stata "global Z assignmt"}{p_end}
{phang2}. {stata "global X sex age married black hispanic"}{p_end}
{phang2}. {stata "set seed 42"}{p_end}

{pstd}We initialize the model.{p_end}
{phang2}. {stata "ddml init interactiveiv, kfolds(5)"}{p_end}

{pstd}We use stacking (implemented in {helpb pystacked}) with two base 
learners for each reduced form equation.{p_end}
{phang2}. {stata "ddml E[Y|X,Z]: pystacked $Y c.($X)# #c($X), type(reg) m(ols lassocv)"}{p_end}
{phang2}. {stata "ddml E[D|X,Z]: pystacked $D c.($X)# #c($X), type(class) m(logit lassocv)"}{p_end}
{phang2}. {stata "ddml E[Z|X]: pystacked $Z c.($X)# #c($X), type(class) m(logit lassocv)"}{p_end}

{pstd}Cross-fitting and estimation.{p_end}
{phang2}. {stata "ddml crossfit"}{p_end}
{phang2}. {stata "ddml estimate, robust"}{p_end}

{pstd}To short-stack instead of stack:{p_end}
{phang2}. {stata "set seed 42"}{p_end}
{phang2}. {stata "ddml init interactiveiv, kfolds(5)"}{p_end}
{phang2}. {stata "ddml E[Y|X,Z]: reg $Y $X"}{p_end}
{phang2}. {stata "ddml E[Y|X,Z]: pystacked $Y c.($X)# #c($X), type(reg) m(lassocv)"}{p_end}
{phang2}. {stata "ddml E[D|X,Z]: logit $D $X"}{p_end}
{phang2}. {stata "ddml E[D|X,Z]: pystacked $D c.($X)# #c($X), type(class) m(lassocv)"}{p_end}
{phang2}. {stata "ddml E[Z|X]: logit $Z $X"}{p_end}
{phang2}. {stata "ddml E[Z|X]: pystacked $Z c.($X)# #c($X), type(class) m(lassocv)"}{p_end}

{pstd}Cross-fitting and estimation.{p_end}
{phang2}. {stata "ddml crossfit, shortstack"}{p_end}
{phang2}. {stata "ddml estimate, robust"}{p_end}

{pstd}{ul:Flexible Partially Linear IV model.} 

{pstd}Preparation: we load the data, define global macros and set the seed.{p_end}
{phang2}. {stata "use https://github.com/aahrens1/ddml/raw/master/data/BLP.dta, clear"}{p_end}
{phang2}. {stata "global Y share"}{p_end}
{phang2}. {stata "global D price"}{p_end}
{phang2}. {stata "global X hpwt air mpd space"}{p_end}
{phang2}. {stata "global Z sum*"}{p_end}
{phang2}. {stata "set seed 42"}{p_end}

{pstd}We initialize the model.{p_end}
{phang2}. {stata "ddml init fiv"}{p_end}

{pstd}We add learners for E[Y|X] in the usual way.{p_end}
{phang2}. {stata "ddml E[Y|X]: reg $Y $X"}{p_end}
{phang2}. {stata "ddml E[Y|X]: pystacked $Y $X, type(reg)"}{p_end}

{pstd}There are some pecularities that we need to bear in mind
when adding learners for E[D|Z,X] and E[D|X].
The reason for this is that the estimation of E[D|X]
depends on the estimation of E[D|X,Z].
More precisely, we first obtain the fitted values D^=E[D|X,Z] and 
fit these against X to estimate E[D^|X].{p_end}

{pstd}
When adding learners for E[D|Z,X],
we need to provide a name
for each learners using {opt learner(name)}.{p_end}
{phang2}. {stata "ddml E[D|Z,X], learner(Dhat_reg): reg $D $X $Z"}{p_end}
{phang2}. {stata "ddml E[D|Z,X], learner(Dhat_pystacked): pystacked $D $X $Z, type(reg)"}{p_end}

{pstd}
When adding learners for E[D|X], we explicitly refer to the learner from 
the previous step (e.g., {cmd:learner(Dhat_reg)}) and
also provide the name of the treatment variable ({cmd:vname($D)}).
Finally, we use the placeholder {cmd:{D}} in place of the dependent variable. 
{p_end}
{phang2}. {stata "ddml E[D|X], learner(Dhat_reg) vname($D): reg {D} $X"}{p_end}
{phang2}. {stata "ddml E[D|X], learner(Dhat_pystacked) vname($D): pystacked {D} $X, type(reg)"}{p_end}
 
{pstd}That's it. Now we can move to cross-fitting and estimation.{p_end}
{phang2}. {stata "ddml crossfit"}{p_end}
{phang2}. {stata "ddml estimate, robust"}{p_end}

{pstd}If you are curious about what {cmd:ddml} does in the background:{p_end}
{phang2}. {stata "ddml estimate, allcombos spec(8) rep(1) robust"}{p_end}
{phang2}. {stata "gen Dtilde = $D - Dhat_pystacked_h_1"}{p_end}
{phang2}. {stata "gen Zopt = Dhat_pystacked_1 - Dhat_pystacked_h_1"}{p_end}
{phang2}. {stata "ivreg Y2_pystacked_1 (Dtilde=Zopt), robust"}{p_end}

{marker references}{title:References}

{pstd}
Chernozhukov, V., Chetverikov, D., Demirer, M., 
Duflo, E., Hansen, C., Newey, W. and Robins, J. (2018), 
Double/debiased machine learning for 
treatment and structural parameters. 
{it:The Econometrics Journal}, 21: C1-C68. {browse "https://doi.org/10.1111/ectj.12097"}

{marker installation}{title:Installation}

{pstd}
To get the latest stable version of {cmd:ddml} from our website, 
check the installation instructions at {browse "https://statalasso.github.io/installation/"}.
We update the stable website version more frequently than the SSC version.

{pstd}
To verify that {cmd:ddml} is correctly installed, 
click on or type {stata "whichpkg ddml"} 
(which requires {helpb whichpkg} 
to be installed; {stata "ssc install whichpkg"}).

{title:Authors}

{pstd}
Achim Ahrens, Public Policy Group, ETH Zurich, Switzerland  {break}
achim.ahrens@gess.ethz.ch

{pstd}
Christian B. Hansen, University of Chicago, USA {break}
Christian.Hansen@chicagobooth.edu

{pstd}
Mark E Schaffer, Heriot-Watt University, UK {break}
m.e.schaffer@hw.ac.uk	

{pstd}
Thomas Wiemann, University of Chicago, USA {break}
wiemann@uchicago.edu

{title:Also see (if installed)}

{pstd}
Help: {helpb lasso2}, {helpb cvlasso}, {helpb rlasso}, {helpb ivlasso},
 {helpb pdslasso}, {helpb pystacked}.{p_end}
