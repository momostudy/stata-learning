{smcl}
{* *! version 1.1.1  23jan2017}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "konfoundhelpfile##syntax"}{...}
{viewerjumpto "Description" "konfoundhelpfile##description"}{...}
{viewerjumpto "Options" "konfoundhelpfile##options"}{...}
{viewerjumpto "Remarks" "konfoundhelpfile##remarks"}{...}
{viewerjumpto "Examples" "konfoundhelpfile##examples"}{...}
{viewerjumpto "Authors" "konfoundhelpfile##authors"}{...}
{viewerjumpto "References" "konfoundhelpfile##references"}{...}
{title:Title}

{phang}
{bf:konfound} {hline 2} For user's model, this command calculates (1) how much bias there must be in an estimate to nullify/sustain an inference; (2) the impact of an omitted variable necessary to nullify/sustain an inference for a regression coefficient.


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:konfound}
[{varlist}]
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{syntab: {ul:Main}}

{phang}
{opt varlist} a list of variables in the previous model. User can provide 1 to 10 variable names{p_end}

{syntab: {ul:Options}}

{phang}
{opt sig(#)} Significance level of the test; default is 0.05 {cmd:sig(.05)}; to change the significance level to .10 use {cmd:sig(.1)}.

{phang}
{opt nu(#)} The null hypothesis against which to test the estimate; the default is 0 {cmd:nu(0)}. At this time, the default {cmd:nu(0)} is the only available option. For non-zero null hypotheses please use the {opt pkonfound} command and manually enter parameter estimates and other quantities.

{phang}
{opt onetail(#)} One-tail or two-tail test; the default is two-tail {cmd:onetail(0)}; to change to one-tail use {cmd:onetail(1)}.

{phang}
{opt uncond(#)} Calculate the impact and component correlations before or after conditioning on covariates in the model; the default is to calculate the impact and component correlations after conditioning on covariates {cmd:uncond(0)}; to change the calculation to before conditioning (unconditional) on covariates use {cmd:uncond(1)}.

{phang}
{opt rep_0(#)} For % bias, this controls the effect in replacement cases; the default is null effect (which may or may not be 0) {cmd:rep_0(0)}; to force replacing cases with effect of zero use {cmd:rep_0(1)}. Note that at this time, the default {cmd:rep_0(0)} is the only option for the {opt konfound} command. For replacement data with non-zero effect, use the konfound-it spreadsheet and manually enter parameter estimates and other quantities. 

{phang}
See {browse "https://docs.google.com/spreadsheets/d/1VWVhdzIaXgqjZienfzUGJM-IIaPu4Qn3/edit?usp=sharing&ouid=107224617699146866513&rtpof=true&sd=true":konfound-it spreadsheet} for more information.

{phang}
{opt non_li(#)} Basis for interpreting % bias to nullify/sustain an inference for non-linear models (e.g., logit or probit); default is to use the original coefficient {cmd:non_li(0)}. To change the calcuation based on average partial effects, use {cmd:non_li(1)}. Note that if user's model is a logistic regression we recommend using the {opt pkonfound} command for logistic regression with manually entered parameter estimates and other quantities. Otherwise, the command can calculate the robustness of inference (RIR) when the user provides the number of treatment observations ({cmd:n_treat}).

{phang}
{opt indx(#)} The user can specify whether the output for a model should be RIR {cmd:indx("RIR")} or ITCV {cmd:indx("IT")}; the default is RIR. To change to ITCV one should specify {cmd:indx("IT")} 	


{syntab: {ul:Values}}

{pstd} 
{opt konfound} stores the following in {cmd: r()}. The following results are stored after each run of {cmd:konfound} and can be accessed with the command {cmd:return list}. These results are stored with the highest possible decimal accuracy.{p_end}

{phang}
{opt itcv} ITCV conditioning on the observed covariates

{phang}
{opt unconitcv} Unconditional ITCV

{phang}
{opt rir} Robustness of Inference to Replacement (RIR)

{phang}
{opt thr} Threshold value for estimated effect

{phang}
{opt RsqXZ} R-squared using all observed covariates to explain the predictor of interest (X)

{phang}
{opt RsqYZ} R-squared using all observed covariates to explain the outcome (Y)

{phang}
{opt Rsq} The unadjusted, original R-squared in the observed function

{phang}
{opt r_xcv} Correlation between predictor of interest (X) and CV necessary to nullify the inference for smallest impact

{phang}
{opt r_ycv} Correlation between outcome (Y) and CV necessary to nullify the inference for smallest impact


{synoptline}


{marker description}{...}
{title:Description}

{pstd}
{cmd:konfound} calculates (1) how much bias there must be in an estimate to nullify/sustain an inference from the immediately preceding model, interpreting this bias in terms of sample replacement. After running a model (example: linear regression), user can input a list of variable names, and {cmd:konfound} will calculate the % bias needed to nullify/sustain the inference for each variable in the variable list. The command generates sensitivity plots for variables that are statistically significant in the user's model. {p_end}

{pstd}
{cmd:konfound} also calculates (2) the impact of an omitted variable necessary to nullify/sustain an inference for a regression coefficient from a user's model. It assesses how strong an omitted variable has to be correlated with the outcome and the predictor of interest to nullify/sustain the inference. After running a model (example: linear regression), the user can provide a list of variables, and {cmd:konfound} will calculate the impact of an omitted variable necessary to nullify/sustain an inference. The command also produces the observed impact table for all observed covariates in the user's previous model. {p_end}


{marker examples}{...}
{title:Examples}

{phang}When you run {opt konfound} the first time on your computer, please install the following packages:

{phang}{cmd:. ssc install indeplist, replace} {p_end}
{phang}{cmd:. ssc install matsort, replace} {p_end}
{phang}{cmd:. ssc install moss, replace} {p_end}

{phang}Then you can start:

{phang}{cmd:. sysuse auto.dta, clear} {p_end}

{pstd}
## {cmd:konfound} command calculates bias and sensitivity analysis for the specified variable after conditioning on covariates. To specify the output index, the user can set it using {cmd:indx("RIR")}  (the default) or {cmd:indx("IT")} .

{phang}{cmd:. regress mpg weight displacement} {p_end}

{phang}{cmd:. konfound weight} {p_end}

{phang}{cmd:. konfound weight, indx("IT")} {p_end}

{phang}{cmd:. konfound weight, indx("RIR")} {p_end}


{pstd}
## {cmd:konfound} command to calculate bias and sensitivity analysis for the weight variable before conditioning on covariates

{phang}{cmd:. regress mpg weight displacement} {p_end}

{phang}{cmd:. konfound weight, uncond(1)}{p_end}

{pstd}
Please note that {opt konfound} should only be run immediately after a model is estimated. No other commands should be entered between estimating the model and running {opt konfound}. 


{marker authors}{...}
{title:Authors}

{phang} Ran Xu {p_end}
{phang} University of Connecticut {p_end}

{phang} Xuesen Cheng {p_end}
{phang} Michigan State University {p_end}

{phang} Jihoon Choi {p_end}
{phang} Michigan State University {p_end}

{phang} Yunhe Cui {p_end}
{phang} University of Connecticut {p_end}

{phang} Kenneth Frank {p_end}
{phang} Michigan State University {p_end}

{phang} Qinyun Lin {p_end}
{phang} University of Gothenburg {p_end}

{phang} Spiro Maroulis {p_end}
{phang} Arizona State University {p_end}

{phang} Joshua Rosenberg {p_end}
{phang} University of Tennessee, Knoxville {p_end}

{phang} Guan Saw {p_end}
{phang} Claremont Graduate University {p_end}

{phang} Gaofei Zhang {p_end}
{phang} University of Connecticut {p_end}

{phang} Please email {bf:ran.2.xu@uconn.edu} if you observe any problems. {p_end}


{marker references}{...}
{title:References}

{pstd}
Frank, K.A. (2000). Impact of a Confounding Variable on the Inference of a Regression Coefficient. Sociological Methods and Research, 29(2), 147-194.

{pstd}
Frank, K.A., Maroulis, S., Duong, M., and Kelcey, B. (2013). What would it take to Change an Inference?: Using Rubin's Causal Model to Interpret the Robustness of Causal Inferences. Education, Evaluation and Policy Analysis. 35, 437-460.

{pstd}
Xu, R., Frank, K. A., Maroulis, S. J., & Rosenberg, J. M. (2019). konfound: Command to Quantify Robustness of Causal Inferences. The Stata Journal, 19(3), 523-550.

See {browse "https://konfound-it.org/":https://konfound-it.org/} for more information.
