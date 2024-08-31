{smcl}
{* *! version 1.1.3  23jan2012}{...}
{* revised: 6Aug2013}{...}
{cmd:help sfpanel postestimation}{right:also see:  {help sfpanel}}
{hline}

{title:Title}

{p2colset 5 32 38 2}{...}
{p2col :{hi:sfpanel postestimation} {hline 2}}Postestimation tools for sfpanel{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following postestimation commands are available for {cmd:sfpanel}.

{synoptset 13}{...}
{p2coldent :command}description{p_end}
{synoptline}
{synopt:{bf:{help estat}}}AIC, BIC, VCE, and estimation sample summary{p_end}
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_margins
INCLUDE help post_nlcom
{synopt :{helpb sfpanel postestimation##predict:predict}}predictions, residuals, influence statistics, and other diagnostic measures{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:statistic}]

{p 8 16 2}{cmd:predict}{dtype}{c -(}{it:stub*}{c |}{it:newvar_xb} {it:newvar_v} {it:newvar_u}{c )-}{ifin}{cmd:,} {opt sc:ores}

{synoptset 15 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab:Main}
{synopt :{opt xb}}linear prediction; the default{p_end}
{synopt :{opt stdp}}standard error of the prediction{p_end}
{synopt :{opt u}}estimates of (technical or cost) inefficiency via {it:E}(u|e) (Jondrow et al., 1982){p_end}
{synopt :{opt u0}}estimates of (technical or cost) inefficiency via {it:E}(u|e) when the random effect is zero; only after {cmd:model(tre)}{p_end}
{synopt :{opt m}}estimates of (technical or cost) inefficiency via M(u|e){p_end}
{synopt :{opt jlms}}estimates of (technical or cost) efficiency via exp[-E(u|e)]{p_end}
{synopt :{opt bc}}estimates of (technical or cost) efficiency via E[exp(-u)|e] (Battese and Coelli, 1988){p_end}
{synopt :{opt ci}}estimates of confidence interval for (technical or cost) inefficiency/efficiency{p_end}
{synopt :{opt marginal}}marginal effects of the exogenous determinants on the unconditional mean and variance of the inefficiency (Wang, 2002){p_end}
{synopt :{opt trunc(tlevel)}}truncation of estimated efficiency/inefficiency{p_end}
{synopt :{opt scores}}calculates score variables{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
These statistics are only available for the estimation sample.


INCLUDE help menu_predict


{title:Options for predict}

{dlgtab:Main}

{phang}
{opt xb}, the default, calculates the linear prediction.

{phang}
{opt stdp} calculates the standard error of the linear prediction.

{phang}
{opt u} produces estimates of (technical or cost) inefficiency via E(u|e) using the Jondrow et al. (1982) estimator.

{phang}
{opt u0} produces estimates of the (technical or cost) inefficiency via
E(u|e) assuming the random effect is zero. This statistic is allowed only when the estimation is performed with the {cmd:model(tre)} option.

{phang}
{opt m} produces estimates of (technical or cost) inefficiency via M(u|e), the mode of the conditional distribution u|e. This statistic is not allowed when the estimation is performed with {cmd:model(fels)},
{cmd:model(fecss)}, {cmd:model(fe)} or {cmd:model(regls)} option.

{phang}
{opt jlms} produces estimates of (technical or cost) efficiency via exp[-E(u|e)]. 

{phang}
{opt bc} produces estimates of (technical or cost) efficiency via E[exp(-u)|e] using the Battese and Coelli (1988) estimator. This statistic is allowed when the estimation is performed with {cmd:model(tfe)}, {cmd:model(tre)}, {cmd:model(bc95)},
{cmd:model(bc92)}, {cmd:model(kumb90)}, {cmd:model(bc88)} and {cmd:model(pl81)}. 

{phang}
{opt ci} computes confidence interval using the approach proposed by Horrace and Schmidt (1996).
This option can be used together with {opt u} or {opt jlms} or {opt bc}. It is not allowed when the estimation is performed with {cmd:model(fels)}, {cmd:model(fecss)}, {cmd:model(fe)} or {cmd:model(regls)}
or when the estimation is performed with {cmd:model(bc92)} or {cmd:model(kumb90)} and {opt bc} has been specified.
The default confidence level is 95, meaning a 95% confidence interval.
If the option {cmd:level(#)} is used in the previous estimation command, the confidence interval will be computed using the {it:#} level. 
This option creates two additional variables: {it:newvar_LBcilevel}
and {it:newvar_UBcilevel}, that are the lower and the upper bound, respectively. 

{phang}
{opt marginal} calculates the marginal effects of the exogenous determinants on E(u) and Var(u) using the approach proposed by Wang (2002). 
The marginal effects are observation-specific and are saved in the new variables {it:varname_m_M} and {it:varname_u_V}, the marginal effects on the unconditional mean and variance of inefficiency, respectively.
{it:varname_m} and {it:varname_u} are the names of each exogenous determinants specified in options {cmd:emean(}{help varlist:varlist_m} [,{opt noconstant}]{cmd:)}
and {cmd:usigma(}{help varlist:varlist_u} [,{opt noconstant}]{cmd:)}. {opt marginal} can be used only if the estimation
is performed with {cmd:model(bc95)} or when the inefficiency in {cmd:model(tfe)} or {cmd:model(tre)} is {cmd:distribution(tnormal)}. 
When they are both specified, {it:varlist_m} and {it:varlist_u} must contain the same variables in the same order. 
This option can be specified in two ways: i) together with either {opt u}, {opt m}, {opt jlms} or {opt bc}; ii) alone without specifying {it:newvar}.

{phang}
{opt trunc(tlevel)} excludes from the inefficiency estimation the units whose effects are, at least at one time period, in the upper and bottom {it:tlevel}% range. {opt trunc()} can be used only if the estimation is performed 
with {cmd:model(fe)}, {cmd:model(regls)}, {cmd:model(fecss)} and {cmd:model(fels)}.

{phang}
{opt scores} calculates score variables. This option is not allowed when the estimation is performed with the option {opt  model(fecss)}, {opt  model(fels)}, {opt  model(fe)} or {opt  model(regls)}. 
When the argument of the option {opt  model()} is {opt  tfe} or {opt  bc95} scores are defined as the derivative of the objective function with respect to the {help mf_moptimize##def_parameter:parameters}. 
When the argument of the option {opt  model()} is {opt  tre}, {opt  bc88}, {opt  bc92}, {opt  kumb90} or {opt  pl81} scores are defined as the derivative of the objective function with respect to the {help mf_moptimize##def_K:coefficients}. 
This difference is due to the different {opt  moptimize()} {it: evaluator type} used to implement the estimators (See {help mata moptimize()}).


{title:Remarks}

{pstd}When the {cmd:sfpanel} command is used to estimate production frontiers, {cmd:predict} will provide the post-estimation of technical (in)efficiency, 
while when the {cmd:sfpanel} command is used to estimate cost frontiers, {cmd:predict} will provide the post-estimation of cost (in)efficiency. 
It is worth noting that {cmd:sfpanel} and the related {cmd:predict} command follow the definitions of technical and cost (in)efficiency given in Kumbhakar and Lovell (2000).{p_end}


{title:Examples}

{pstd}True fixed-effects model (Greene, 2005){p_end}
{phang}{cmd:. webuse xtfrontier1, clear}{p_end}
{phang}{cmd:. sfpanel lnwidgets lnworkers lnmachines, m(tfe) usigma(lnworkers) robust}{p_end}

{pstd}Linear prediction{p_end}
{phang}{cmd:. predict xb}

{pstd}Technical inefficiency{p_end}
{phang}{cmd:. predict ineffmean, u}{p_end}
{phang}{cmd:. predict ineffmode, m}{p_end}

{pstd}Technical efficiency{p_end}
{phang}{cmd:. predict jlms, jlms}{p_end}

{pstd}Technical efficiency/inefficiency confidence intervals{p_end}
{phang}{cmd:. predict ineffmean, u ci}{p_end}
{phang}{cmd:. predict bc, bc ci}{p_end}
{phang}{cmd:. predict jlms, jlms ci}{p_end}

{pstd}Non-monotonic marginal effects{p_end}
{phang}{cmd:. webuse xtfrontier1, clear}{p_end}
{phang}{cmd:. sfpanel lnwidgets lnworkers lnmachines, m(tfe) d(tnormal) e(lnworkers) u(lnworkers) robust}{p_end}
{phang}{cmd:. predict, marg}{p_end}

{pstd}Score variables{p_end}
{phang}{cmd:. predict score*, scores}{p_end}


{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Centre for Economic and International Studies, University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}

{pstd}Silvio Daidone{p_end}
{pstd}Centre for Health Economics, University of York{p_end}
{pstd}York, UK{p_end}
{pstd}silvio.daidone@york.ac.uk{p_end}

{pstd}Vincenzo Atella{p_end}
{pstd}Centre for Economic and International Studies, University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}atella@uniroma2.it{p_end}

{pstd}Giuseppe Ilardi{p_end}
{pstd}Economic and Financial Statistics Department, Bank of Italy{p_end}
{pstd}Rome, Italy{p_end}
{pstd}giuseppe.ilardi@bancaditalia.it{p_end}


{title:Also see}

{psee}
{space 2}Help:  {help sfpanel}, {help sfcross}, {help sfcross_postestimation}.
{p_end}
