{smcl}
{* *! version 21jan2023}{...}
{hline}
{cmd:help ddml extract}{right: v1.2}
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{p2col:{hi: ddml extract}} Stata extract utility for Double Debiased Machine Learning{p_end}
{p2colreset}{...}

{pstd}
Please check the {helpb ddml extract##examples:examples} provided at the end of the help file.

{marker syntax}{...}
{title:Syntax}

{p 8 14}{cmd:ddml extract} [ {it:object_name} , {opt mname(name)} {opt show(display_item)} {opt detail} {opt ename(name)} {opt vname(varname)}
{opt stata} {opt keys} {opt key1(string)} {opt key2(string)} {opt key3(string)} {opt subkey1(string)} {opt subkey2(string)}{bind: ]}

{pstd}
{it:display_item} can be {it:mse}, {it:n} or {it:pystacked}.
{cmd:ddml} stores many internal results on associative arrays.
These can be retrieved using the different key options.

{marker syntax}{...}
{title:Options}

{synoptset 20}{...}
{synopthdr:main options}
{synoptline}
{synopt:{opt mname(name)}}
Name of the DDML model; a Mata object. Defaults to {it:m0}.
{p_end}
{synopt:{opt vname(name)}}
Name of a Y, D or Z variable corresponding to a DDML equation.
{p_end}
{synopt:{opt ename(name)}}
Name of a DDML equation struct; a Mata object.
Use with {helpb crossfit} or with a DDML eStruct that has been separately extracted.
{p_end}
{synopt:{opt stata}}
Saves extracted objects as Stata r(.) macros (default is to leave as Mata objects).
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}

{synoptset 20}{...}
{synopthdr:show options}
{synoptline}
{synopt:{opt show(pystacked)}}
Extracts {opt pystacked} weights and learner MSEs.
The MSEs are cross-validation MSEs and correspond to the predictions used to obtain the stacking weights;
see {helpb pystacked:help pystacked}.
{p_end}
{synopt:{opt detail}}
({opt show(pystacked)} only) Extract detailed {opt pystacked} weights and learner MSEs by cross-fit fold.
{p_end}
{synopt:{opt show(shortstack)}}
Extracts {opt shortstack} weights.
{p_end}
{synopt:{opt show(mse)}}
Extracts OOS MSEs by crossfitting fold.
{p_end}
{synopt:{opt show(n)}}
Extracts sample size by crossfitting fold.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}

{synoptset 20}{...}
{synopthdr:key options}
{synoptline}
{synopt:{opt keys}}
List all keys on the relevant associative array.
{p_end}
{synopt:{opt key1(string)}}
Associative array key #1.
{p_end}
{synopt:{opt key2(string)}}
Associative array key #2.
{p_end}
{synopt:{opt key3(string)}}
Associative array key #3.
{p_end}
{synopt:{opt subkey1(string)}}
Associative array subkey #1.
{p_end}
{synopt:{opt subkey2(string)}}
Associative array subkey #2.
{p_end}
{synoptline}
{p2colreset}{...}
{pstd}


{marker examples}{...}
{title:Examples}

{pstd}
The examples below use the partially linear model and stacking regression using {helpb pystacked}.
The model name is the default name "m0".
{p_end}

{pstd}Preparation:{p_end}
{phang2}. {stata "use https://github.com/aahrens1/ddml/raw/master/data/sipp1991.dta, clear"}{p_end}
{phang2}. {stata "global X tw age inc fsize educ db marr twoearn pira hown"}{p_end}
{phang2}. {stata "set seed 42"}{p_end}
{phang2}. {stata "ddml init partial, kfolds(3) reps(2)"}{p_end}
{pstd}Add supervised machine learners for estimating conditional expectations:{p_end}
{phang2}. {stata "global rflow max_features(5) min_samples_leaf(1) max_samples(.7)"}{p_end}
{phang2}. {stata "global rfhigh max_features(5) min_samples_leaf(10) max_samples(.7)"}{p_end}
{phang2}. {stata "ddml E[Y|X], learner(Y_m1): pystacked net_tfa $X || method(ols) || method(lassocv) || method(ridgecv) || method(rf) opt($rflow) || method(rf) opt($rfhigh), type(reg)"}{p_end}
{phang2}. {stata "ddml E[D|X], learner(D_m1): pystacked e401 $X || method(ols) || method(lassocv) || method(ridgecv) || method(rf) opt($rflow) || method(rf) opt($rfhigh), type(reg)"}{p_end}
{pstd}Cross-fitting and estimation.{p_end}
{phang2}. {stata "ddml crossfit"}{p_end}
{phang2}. {stata "ddml estimate, robust"}{p_end}

{pstd}{ul:{opt show} option examples}{p_end}

{pstd}{opt show} option examples: examine the learner weights and MSEs reported by {cmd:pystacked}, MSEs by fold, and sample sizes by fold.{p_end}
{phang2}. {stata "ddml extract, show(pystacked)"}{p_end}
{phang2}. {stata "ddml extract, show(mse)"}{p_end}
{phang2}. {stata "ddml extract, show(n)"}{p_end}
{pstd}{opt show} option leaves results in r(.) macros.{p_end}
{phang2}. {stata "ddml extract, show(pystacked)"}{p_end}
{phang2}. {stata "mat list r(Y_m1_w)"}{p_end}
{phang2}. {stata "ddml extract, show(mse)"}{p_end}
{phang2}. {stata "mat list r(e401_mse)"}{p_end}

{pstd}{ul:List keys examples}{p_end}

{pstd}List keys of associative arrays used in model m0.
Associative array m0.eqnAA is an "equation AA" and has one key,
which is is the name of the variable for which conditional expectations are estimated.
Associative array m0.estAA is an "estimation AA" and has two keys.
The objects stored on this AA are either estimation results,
AAs that have sets of estimation results, or objects with information about the estimations.
{p_end}
{phang2}. {stata "ddml extract, keys"}{p_end}
{pstd}List keys relating to equation for D variable, e401.
Keys for two associative arrays are reported.
Associative array e401.lrnAA is a "learner AA" and has two keys; it stores e.g. an estimation specification.
Associative array e401.resAA is a "results AA" and has three keys; it stores e.g. estimation results.
{p_end}
{phang2}. {stata "ddml extract, keys vname(e401)"}{p_end}

{pstd}{ul:Working with model estimation results}{p_end}

{pstd}Display matrix of betas for across resamplings and specifications.{p_end}
{phang2}. {stata "ddml extract, key1(bmat) key2(all)"}{p_end}
{pstd}Extract matrix of SEs for across resamplings and specifications.
Store it as a Mata object called semat.{p_end}
{phang2}. {stata "ddml extract semat, key1(semat) key2(all)"}{p_end}
{phang2}. {stata "mata: semat"}{p_end}
{pstd}As above, but store it as a Stata r(.) macro r(semat).{p_end}
{phang2}. {stata "ddml extract semat, key1(semat) key2(all) stata"}{p_end}
{phang2}. {stata "mat list r(semat)"}{p_end}
{pstd}Extract the estimated beta for specification 1, resample 2.
Provide the keys for the AA with the results for the specification and resampling,
and the subkeys for this AA to obtain the posted beta.
{p_end}
{phang2}. {stata "ddml extract, key1(1) key2(2) subkey1(b) subkey2(post)"}{p_end}
{pstd}More examples of the above, relating to specification 1 and
various resamples or the mean/median across resamples.
{p_end}
{phang2}. {stata "ddml extract, key1(1) key2(1) subkey1(D_m1_mse) subkey2(scalar)"}{p_end}
{phang2}. {stata "ddml extract, key1(1) key2(2) subkey1(D_m1_mse) subkey2(scalar)"}{p_end}
{phang2}. {stata "ddml extract, key1(1) key2(mn) subkey1(V) subkey2(post)"}{p_end}
{phang2}. {stata "ddml extract, key1(1) key2(md) subkey1(title) subkey2(local)"}{p_end}

{pstd}{ul:Working with equation estimation results}{p_end}

{pstd}Display information stored on learner AA e401.lrnAA
about the specification of conditional expectations for variable e401.{p_end}
{phang2}. {stata "ddml extract, vname(e401) key1(D_m1) key2(est_main)"}{p_end}
{phang2}. {stata "ddml extract, vname(e401) key1(D_m1) key2(stack_base_est)"}{p_end}
{pstd}Display information stored on results AA e401.resAA
about the estimation results for resamplings 1 and 2.{p_end}
{phang2}. {stata "ddml extract, vname(e401) key1(D_m1) key2(MSE_folds) key3(1)"}{p_end}
{phang2}. {stata "ddml extract, vname(e401) key1(D_m1) key2(MSE_folds) key3(2)"}{p_end}
{phang2}. {stata "ddml extract, vname(e401) key1(D_m1) key2(stack_weights) key3(1)"}{p_end}
{phang2}. {stata "ddml extract, vname(e401) key1(D_m1) key2(stack_weights) key3(2)"}{p_end}

{pstd}{ul:Working directly with an equation associative array}{p_end}

{pstd}Extract the associative AA for the estimation of conditional expectations for variable e401.
Store it as a Mata object called AA_e401.
Note: the {cmd:crossfit} command returns an equation associative array,
so this step is unnecessary when using this command.{p_end}
{phang2}. {stata "ddml extract AA_e401, vname(e401)"}{p_end}
{phang2}. {stata "mata: AA_e401"}{p_end}
{pstd}Examples of working with this equation associative array.
Note that the {opt ename} option must be used.{p_end}
{phang2}. {stata "ddml extract, ename(AA_e401) key1(D_m1) key2(MSE) key3(1)"}{p_end}
{phang2}. {stata "ddml extract, ename(AA_e401) key1(D_m1) key2(MSE) key3(2)"}{p_end}

{pstd}{ul:Using Mtata's associative array commands}{p_end}

{pstd}If preferred, Mata's associative array commands can be used directly.
Note that all keys are strings.{p_end}
{phang2}. {stata "mata: m0.estAA.keys()"}{p_end}
{phang2}. {stata `"mata: AA_e1_r2 = (m0.estAA).get(("1","2"))"'}{p_end}
{phang2}. {stata "mata: AA_e1_r2.keys()"}{p_end}
{phang2}. {stata `"mata: AA_e1_r2.get(("b","post"))"'}{p_end}

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
Help: {helpb ddml}, {helpb crossfit}, {helpb pystacked}.{p_end}
