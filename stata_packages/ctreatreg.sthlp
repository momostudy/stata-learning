{smcl}
{* 30aug2012}{...}
{cmd:help ctreatreg}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col :{hi:ctreatreg} {hline 1}}Dose-Response model with "continuous" treatment, endogeneity and heterogeneous response to observable confounders{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:ctreatreg}
{it: outcome} 
{it: treatment}
[{it:varlist}]
{ifin}
{weight}{cmd:,}
{cmd:model}{cmd:(}{it:{help ctreatreg##modeltype:modeltype}}{cmd:)}
{cmd:ct}{cmd:(}{it:treat_level}{cmd:)}
{cmd:m}{cmd:(}{it:number}{cmd:)}
{cmd:s}{cmd:(}{it:number}{cmd:)}
[{cmd:hetero}{cmd:(}{it:varlist_h}{cmd:)}
{cmd:estype}{cmd:(}{it:model}{cmd:)}
{cmd:iv_t}{cmd:(}{it:instrument_t}{cmd:)}
{cmd:iv_w}{cmd:(}{it:instrument_w}{cmd:)}
{cmd:delta}{cmd:(}{it:number}{cmd:)}
{cmd:ci}{cmd:(}{it:number}{cmd:)}
{cmd:graphate}
{cmd:graphdrf}
{cmd:conf}{cmd:(}{it:number}{cmd:)}
{cmd:vce(robust)}
{cmd:heckvce}{cmd:(}{it:vcetype}{cmd:)}
{cmd:const(noconstant)}
{cmd:head(noheader)}]


{pstd}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.



{title:Description}

{pstd} {cmd:ctreatreg} estimates the Dose-Response-Function (DRF) of a given treatment on a specific
target variable, within a model where units are treated with different levels. The DRF is defined as the “average treatment effect, given the level of the treatment {it:t}” (i.e. ATE({it:t})). 
The routine also estimates other “causal” parameters of interest, such as the average treatment effect (ATE), the average treatment effect on treated (ATET), 
the average treatment effect on non-treated (ATENT), and the same effects 
conditional on {it:t} and on the vector of covariates {it:x}.The DRF is approximated by a third degree polynomial function. 
Both OLS and IV estimation are available, 
according to the case in which the treatment is not or is endogenous. In particular, the implemented IV estimation is based on a Heckman bivariate selection model (i.e., type-2 tobit) for 
{it:w} (the yes/no decision to treat a given unit) and {it:t} 
(the level of the treatment provided) in the first step, 
and a 2SLS estimation for the outcome ({it:y}) 
equation in the second step. 
The routine allows also for a graphical representation of results. 

     
{title:Options}
    
{phang} {cmd:model}{cmd:(}{it:{help ctreatreg##modeltype:modeltype}}{cmd:)} specifies the treatment model
to be estimated, where {it:modeltype} must be one of the following three
models: "ct-ols", "ct-fe", "ct-iv".
it is always required to specify one model.   

{phang} {cmd:ct}{cmd:(}{it:treat_level}{cmd:)} specifies the treatment level (or dose).
This variable takes values in the [0;100] interval, where 0 is the treatment level
of non-treated units. The maximun dose is thus 100.

{phang} {cmd:m}{cmd:(}{it:number}{cmd:)} sets the polynomial degree equal to the number specified in parenthesis.

{phang} {cmd:s}{cmd:(}{it:number}{cmd:)} sets a specific value of the continuous treatment variable
where the dose-response function is evaluated. The value ATE(s) is reported in the retun scalar e(ate_s).
 
{phang} {cmd:hetero}{cmd:(}{it:varlist_h}{cmd:)} specifies the variables over 
which to calculate the idyosincratic Average Treatment Effect ATE(x), ATET(x) and ATENT(x),
where x={it:varlist_h}. It is optional for all models. When this option is not specified, the command
estimates the specified model without heterogeneous average effect. Observe that
{it:varlist_h} should be the same set or a subset of the variables specified in {it:varlist}.
Observe however that only numerical variables may be considered.

{phang} {cmd:estype}{cmd:(}{it:model}{cmd:)} specifies which type of estimation method has to be used for estimating the type-2 tobit model in the endogenous treatment case. Two choices are available: "twostep" implements a 
Heckman two-step procedure; "ml" implements a maximum-likelihood estimation. This option is required only for "ct-iv".   

{phang} {cmd:iv_t}{cmd:(}{it:instrument_t}{cmd:)} specifies the variable to be used as instrument for the continuous treatment variable {it:t} in the type-2 tobit model. This option is required only for "ct-iv".

{phang} {cmd:iv_w}{cmd:(}{it:instrument_w}{cmd:)} specifies the variable to be used as instrument for the binary
treatment variable {it:w} in the type-2 tobit model. This option is required only for "ct-iv".

{phang} {cmd:delta}{cmd:(}{it:number}{cmd:)} identifies the average treatment effect between two states: t and t+delta. For any reliable delta, we can obtain the response function ATE(t;delta)=E[y(t)-y(t+delta)]. 

{phang} {cmd:ci}{cmd:(}{it:number}{cmd:)} sets the significant level for the dose-response function, where {it:number}
may be 1, 5 or 10.   

{phang} {cmd:graphate} allows for a graphical representation of the density distributions of 
ATE(x;t), ATET(x;t) and ATENT(x;t). It is optional for all models and gives an outcome 
only if variables into {cmd:hetero()} are specified.

{phang} {cmd:graphdrf} allows for a graphical representation of the Dose
Response Function (DRF) and of its derivative. It plots also the 95% confidence interval
of the DRF over the dose levels. 

{phang} {cmd:vce(robust)} allows for robust regression standard errors. It is optional for all models.

{phang} {cmd:heckvce({it:vcetype})} allows to choose the type of variance-covariance matrix estimation
in the first step Heckit model of the IV model. {it:vcetype} may be "conventional", "bootstrap", or "jackknife".

{phang} {cmd:const(noconstant)} suppresses regression constant term. It is optional for all models. 

{phang} {cmd:head(noheader)} suppresses output header

{phang} {cmd:conf}{cmd:(}{it:number}{cmd:)} sets the confidence level equal to the specified {it:number}. 
The default is {it:number}=95. 


{marker modeltype}{...}
{synopthdr:modeltype_options}
{synoptline}
{syntab:Model}
{p2coldent : {opt ct-ols}}Control-function regression estimated by ordinary least squares{p_end}
{p2coldent : {opt ct-fe}}Control-function regression estimated by fixed-effects{p_end}
{p2coldent : {opt ct-iv}}IV regression estimated by Heckman bivariate selection model and 2SLS{p_end}
{synoptline}


{pstd}
{cmd:ctreatreg} creates a number of variables:

{pmore}
{inp:_ws_}{it:varname_h} are the additional regressors used in model's regression when {cmd:hetero}{cmd:(}{it:varlist_h}{cmd:)} is specified.

{pmore}
{inp:_ps_}{it:varname_h} are the additional instruments used in model's regression when {cmd:hetero}{cmd:(}{it:varlist_h}{cmd:)} is specified in model "ct-iv".

{pmore}
{inp:ATE(x;t)} is an estimate of the idiosyncratic Average Treatment Effect.

{pmore}
{inp:ATET(x;t)} is an estimate of the idiosyncratic Average Treatment Effect on treated.

{pmore}
{inp:ATENT(x;t)} is an estimate of the idiosyncratic Average Treatment Effect on Non-Treated.

{pmore}
{inp:ATE(t)} is an estimate of the Dose-Response-Function.

{pmore}
{inp:ATET(t)} is the value of the Dose-Response-Function in t>0.

{pmore}
{inp:ATENT(t)} it is the value of the Dose-Response-Function in t=0.

{pmore}
{inp:probw} is the predicted probability from the Heckman bivariate selection model (estimated only 
for model "ct-iv").

{pmore}
{inp:mills} is the predicted Mills' ratio from the Heckman bivariate selection model (estimated only 
for model "ct-iv").

{pmore}
{inp:t} is a copy of the treatment level variable, but only in the sample considered.

{pmore}
{inp:t_hat} is the prediction of the level of treatment from the Heckman bivariate selection model (estimated only for model "ct-iv").

{pmore}
{inp:der_ATE_t} is the estimate of the derivative of the Dose-Response-Function.

{pmore}
{inp:std_ATE_t} is the standardized value of the Dose-Response-Function.

{pmore}
{inp:std_der_ATE_t} is the standardized value of the derivative of the Dose-Response-Function.

{pmore}
{inp:Tw, T2w, T3w} are the three polynomial factors of the Dose-Response-Function.

{pmore}
{inp:T_hatp, T2_hatp, T3_hatp} are the three instruments for the polynomial factors of the Dose-Response-Function when model "ct-iv" is used.



{pstd}
{cmd:ctreatreg} returns the following scalars:

{pmore}
{inp:e(N_tot)} is the total number of (used) observations.

{pmore}
{inp:e(N_treated)} is the number of (used) treated units.

{pmore}
{inp:e(N_untreated)} is the number of (used) untreated units.

{pmore}
{inp:e(ate)} is the value of the Average Treatment Effect.

{pmore}
{inp:e(atet)} is the value of the Average Treatment Effect on Treated.

{pmore}
{inp:e(atent)} is the value of the Average Treatment Effect on Non-treated.

{pmore}
{inp:e(ate_s)} is the value of the Average Treatment Effect calculated at a dose equal to s.



{title:Remarks} 

{pstd} The variable specified in {it:treatment} has to be a 0/1 binary variable (1 = treated, 0 = untreated).

{pstd} The standard errors for ATET and ATENT may be obtained via bootstrapping.

{pstd} Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.



{title:Examples}

{cmd:To begin with, use the sample dataset: "ctreatreg_example_dataset.dta".}


{pstd} {cmd:*** 1. EXAMPLE WITH CT-OLS ***}

   {inp:. #delimit ;}
   {inp:. set more off} 
   {inp:. xi: ctreatreg outcome treatment x1 x2 , graphate graphrf}   
   {inp:. delta(10) hetero(x1 x2) model(ct-ols) ct(dose)} 
   {inp:. ;}


{pstd} {cmd:*** 2. EXAMPLE WITH CT-IV ***}

   {inp:. #delimit ;}
   {inp:. set more off}
   {inp:. xi: ctreatreg outcome treatment x1 x2 , graphate graphrf}  
   {inp:. delta(10) hetero(x1 x2) model(ct-iv) ct(dose) estype(twostep) iv_t(z1) iv_w(z2)}
   {inp:. ;}

   
{title:References}

{phang}
Bia, M., and Mattei, A. (2008). A Stata package for the estimation of the dose–response function through adjustment for the generalized propensity score, {it:The Stata Journal}, 8, 3, 354–373.
{p_end}

{phang}
Cerulli, G. (2012). ivtreatreg: a new STATA routine for estimating binary treatment models with heterogeneous 
response to treatment under observable and unobservable selection, 
{it:Working Paper Cnr-Ceris}, N° 03/2012.
{p_end}

{phang}
Hirano, K., and Imbens, G. (2004). The propensity score with continuous treatments. In Gelman, A.
& Meng, X.L. (Eds.), {it:Applied Bayesian Modeling and Causal Inference from Incomplete-Data Perspectives} (73-84). New York: Wiley.
{p_end}



{title:Acknowledgment}

{pstd} I wish to thank all participants to the 2012 UK Stata Users Group Meeting, 
held on September 13-14 at the Cass Business School in London (UK), for the 
opportunity to present a first version of this routine and for their useful comments. 
I also wish to thank Una-Louise Bell for inviting me to present this module 
to the 2012 Italian Stata Users Group Meeting, held in Bologna (Italy) on September 20-21.



{title:Author}

{phang}Giovanni Cerulli{p_end}
{phang}Ceris-CNR{p_end}
{phang}CNR-IRCrES, Research Institute on Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}



{title:Also see}

{psee}
Online:  {helpb ivtreatreg}, {helpb treatreg}, {helpb ivregress}, {helpb pscore}, {helpb psmatch2}, {helpb nnmatch}
{p_end}
