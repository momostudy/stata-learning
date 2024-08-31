{smcl}
{* *! version 1.0.0  10mar2015}{...}
{* revised: }{...}
{cmd:help sftfe postestimation}{right:also see: {help sftfe}}
{hline}

{title:Title}

{p2colset 5 32 38 2}{...}
{p2col :{hi:sftfe postestimation} {hline 2}}Postestimation tools for sftfe{p_end}
{p2colreset}{...}


{title:Description}

{pstd}
The following postestimation commands are available for {cmd:sftfe}.

{synoptset 13}{...}
{p2coldent :command}description{p_end}
{synoptline}
{synopt:{bf:{help estat}}}AIC, BIC, VCE, and estimation sample summary{p_end}
INCLUDE help post_estimates
INCLUDE help post_lincom
INCLUDE help post_lrtest
INCLUDE help post_nlcom
{synopt :{helpb sftfe postestimation##predict:predict}}predictions, residuals, influence statistics, and other diagnostic measures{p_end}
INCLUDE help post_predictnl
INCLUDE help post_test
INCLUDE help post_testnl
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} {it:statistic}]

{synoptset 15 tabbed}{...}
{synopthdr :statistic}
{synoptline}
{syntab:Main}
{synopt :{opt xb}}linear prediction; the default{p_end}
{synopt :{opt stdp}}standard error of the prediction{p_end}
{synopt :{opt alpha}}fixed-effects estimation{p_end}
{synopt :{opt u}}estimates of (technical or cost) inefficiency via {it:E}(u|e) (Jondrow et al., 1982){p_end}
{synopt :{opt jlms}}estimates of (technical or cost) efficiency via exp[-E(u|e)]{p_end}
{synopt :{cmdab:ghkd:raws(}[#]{cmd: ,}[{opt type(halton | random)}]{cmd:)}} 
governs the draws used in GHK simulation of higher-dimensional cumulative multivariate half-normal (or truncated-normal) distributions when a dynamic model has been estimated{p_end}
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
{opt alpha} calculates the prediction of a_i, the estimated fixed effect.
 
{phang}
{opt u} produces estimates of (technical or cost) inefficiency via E(u|e) using the Jondrow et al. (1982) estimator.

{phang}
{opt jlms} produces estimates of (technical or cost) efficiency via exp[-E(u|e)]. 

{phang}
{opt ghkdraws()} the postestimation of fixed-effects and (technical or cost) inefficiency, when the latter it is assumed to follow an AR(1) process, requires the approximation of T-dimensional cumulative multivariate half-normal (or truncated-normal) distributions.
This option governs the draws to be used in the GHK simulator. The optional {opt type(string)} suboption specifies the type of draws in the GHK simulation, {cmd:halton} being the default.{p_end}

{title:Remarks}

{pstd}When the {cmd:sftfe} command is used to estimate production frontiers, {cmd:predict} will provide the post-estimation of technical (in)efficiency, 
while when the {cmd:sftfe} command is used to estimate cost frontiers, {cmd:predict} will provide the post-estimation of cost (in)efficiency. 
It is worth noting that {cmd:sftfe} and the related {cmd:predict} command follow the definitions of technical and cost (in)efficiency given in Kumbhakar and Lovell (2000).{p_end}


{title:Examples}

{pstd}Homoskedasticity - production frontier{p_end}
{phang}{cmd:. use http://www.econometrics.it/stata/data/sftfe_homo_demo, clear}{p_end}
{phang}{cmd:. xtset id t}{p_end}

{phang}{cmd:. sftfe y x1 x2, est(fdiff) dist(hn)}{p_end}
{phang}{cmd:. predict uhat_fdiff, u}{p_end}
{phang}{cmd:. predict a_fdiff, alpha}{p_end}

{phang}{cmd:. sftfe y x1 x2, est(within) dist(hn)}{p_end}
{phang}{cmd:. predict uhat_within, u}{p_end}
{phang}{cmd:. predict a_within, alpha}{p_end}

{phang}{cmd:. sftfe y x1 x2, est(mmsle) dist(hn) symtype(halton) nsim(1000)}{p_end}
{phang}{cmd:. predict uhat_mmsle, u}{p_end}
{phang}{cmd:. predict a_mmsle, alpha}{p_end}

{pstd}Heteroskedasticity in both u and v - cost frontier{p_end}
{phang}{cmd:. use http://www.econometrics.it/stata/data/sftfe_hetero_demo, clear}{p_end}
{phang}{cmd:. xtset id t}{p_end}

{phang}{cmd:. sftfe y x1 x2, est(pde) dist(hn) usigma(zu) vsigma(zv) cost}{p_end}
{phang}{cmd:. predict uhat_pde, u}{p_end}
{phang}{cmd:. predict a_pde, alpha}{p_end}

{pstd}Heteroskedastic and first-order autoregressive inefficiency{p_end}
{phang}{cmd:. use http://www.econometrics.it/stata/data/sftfe_dyn_demo, clear}{p_end}
{phang}{cmd:. xtset id t}{p_end}

{phang}{cmd:. sftfe y x, est(pde) dist(hn) usigma(z) dynamic}{p_end}
{phang}{cmd:. predict uhat_pde_ar1, u}{p_end}
{phang}{cmd:. predict a_pde_ar1, alpha}{p_end}


{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Centre for Economic and International Studies, University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}

{pstd}Giuseppe Ilardi{p_end}
{pstd}Directorate General for Economics, Statistics and Research, Bank of Italy{p_end}
{pstd}Rome, Italy{p_end}
{pstd}giuseppe.ilardi@bancaditalia.it{p_end}


{title:Also see}

{psee}
{space 2}Help:  {help sftfe}.
{p_end}
