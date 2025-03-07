{smcl}
{* 27dec2017}{...}
{cmd:help tvdiff}
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col: {hi:tvdiff} {hline 1}}Pre- and post-treatment estimation of the Average Treatment Effect (ATE) with binary time-varying treatment{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:tvdiff}
{it: outcome} 
{it: treatment}
[{it:varlist}]
{ifin}
{weight}{cmd:,}
{cmd:model}{cmd:(}{it:{help tvdiff##modeltype:modeltype}}{cmd:)}
{cmd:pre}{cmd:(}{it:#}{cmd:)}
{cmd:post}{cmd:(}{it:#}{cmd:)}
[{cmd:test_tt}
{cmd:graph}
{cmd:save_graph}{cmd:(}{it:graphname}{cmd:)}
{cmd:vce}{cmd:(}{it:vcetype}{cmd:)}]


{pstd}{cmd:fweight}s, {cmd:iweight}s, and {cmd:pweight}s are allowed;
see {help weight}.



{title:Description}

{pstd}{cmd:tvdiff} estimates Average Treatment Effects (ATEs) when the treatment is binary and varying over time. Using {cmd:tvdiff}, the user can estimate 
the {it:pre}- and {it:post}-intervention effects by selecting the {it:pre} and {it:post} intervention periods, also by
plotting the results in a easy-to-read graphical representation. In order to assess the reliability of the causal results achieved by
the user's specified model, {cmd:tvdiff} allows to test the "common trend" assumption
either via a joint test on leads significance, or via a time-trend significance test. The model estimated by {cmd:tvdiff} is a generalization of the Difference-In-Differences (DID) approach to the 
case of many {it:post-} and {it:pre-}intervention times.


{phang} According to the {cmd:tvdiff} syntax:

{phang} {it:outcome}: is the target variable over which measuring the impact of the treatment

{phang} {it:treatment}: is the binary treatment variable taking 1 for treated, and 0 for untreated units

{phang} {it:varlist}: is the set of pre-treatment (or observable confounding) variables

     
{title:Options}
    
{phang} {cmd:model}{cmd:(}{it:{help tvdiff##modeltype:modeltype}}{cmd:)} specifies the estimation model, 
where {it:modeltype} must be one out of these two alternatives:
"fe" (fixed effects), or "ols" (ordinary least squares). It is always required to specify one model.  

{phang} {cmd:pre}{cmd:(}{it:#}{cmd:)} allows to specify the number (#) of pre-treatment periods.   

{phang} {cmd:post}{cmd:(}{it:#}{cmd:)} allows to specify the number (#) of post-treatment periods.   

{phang} {cmd:test_tt} allows for performing the parallel–trend test using the time–trend approach.
The default is to use the leads.

{phang} {cmd:graph} allows for a graphical representation of results. It uses the {cmd:coefplot} command
implemented by Jann (2014). 

{phang} {cmd:vce}{cmd:(}{it:vcetype}{cmd:)} allows for robust and clustered regression standard errors in model's estimates.


{marker modeltype}{...}
{synopthdr:modeltype_options}
{synoptline}
{syntab:Model}
{p2coldent : {opt ols}}The model is estimated by ordinary least squares{p_end}
{p2coldent : {opt fe}}The model is estimated by fixed-effects panel regression{p_end}
{synoptline}


{pstd}
{cmd:tvdiff} creates a number of variables:

{pmore}

{pmore}
{inp:_D_L1, _D_L2, ..., _D_Lm}:  are the lags of the treatment variable, with {it:m} equal to {it:#} in the {it:post(#)} option.

{pmore}
{inp:_D_F1, _D_F2, ..., _D_Fp}:  are the leads of the treatment variable, with {it:p} equal to {it:#} in the {it:pre(#)} option.



{pstd}
{cmd:tvdiff} returns the following scalars:

{pmore}
{inp:e(N)} is the total number of (used) observations.

{pmore}
{inp:e(N1)} is the number of (used) treated units.

{pmore}
{inp:e(N0)} is the number of (used) untreated units.

{pmore}
{inp:e(ate)} is the value of the (contemporaneous) Average Treatment Effect.


{title:Remarks} 

{pstd} - The treatment has to be a 0/1 binary variable (1 = treated, 0 = untreated).

{pstd} - Before running {cmdab:tvdiff}, check that {helpb coefplot} is installed, or install it by typing:

{pstd} . ssc install coefplot

{pstd} - It is assumed that the model is correctly specified.

{pstd} - Please remember to use the {cmdab:update query} command before running
this program to make sure you have an up-to-date version of Stata installed.


{title:Examples}

{cmd:*** SIMULATED DATA ***}
. clear
. set obs 5
. set seed 10101
. gen id=_n
. expand 50
. drop in 1/5
. bys id: gen time=_n+1999
. gen D=rbinomial(1,0.4)
. gen x1=rnormal(1,7)
. tsset id time
  forvalues i=1/6{
  gen L`i'_x=L`i'.x
  }
. bys id: gen y0=5+1*x+ rnormal()
. bys id: gen y1=100+5*x+90*L1_x+90*L2_x+120*L3_x+100*L4_x+90*L5_x +90*L6_x + rnormal()
. gen A=6*x+rnormal()
. replace D=1 if A>=15
. replace D=0 if A<15
. gen y=y0+D*(y1-y0)
. tsset id time
. xi: tvdiff y D x , model(fe) pre(6) post(6) vce(robust) graph save_graph(mygraph)


   
{title:References}

{phang}
Angrist J.D. and Pischke J.S. 2009. {it:Mostly Harmless Econometrics: An Empiricist's Companion},
Princeton University Press. 
{p_end}

{phang}
Autor, D. 2003. Outsourcing at Will: The Contribution of Unjust Dismissal Doctrine to the Growth of Employment Outsourcing,
{it:Journal of Labor Economics}, 21(1).
{p_end}

{phang}
Cerulli, G. 2015. {it:Econometric Evaluation of Socio-Economic Programs: Theory and Applications},
Springer.
{p_end}

{phang}
Jann, B. 2014. {it:A new command for plotting regression coefficients and other estimates}. 12th German Stata Users Group meeting,
Hamburg, June 13. (http://www.stata.com/meeting/germany14/abstracts/materials/de14_jann.pdf)
{p_end}



{title:Authors}

{phang}Giovanni Cerulli{p_end}
{phang}IRCrES-CNR{p_end}
{phang}Research Institute on Sustainable Economic Growth, National Research Council of Italy{p_end}
{phang}E-mail: {browse "mailto:giovanni.cerulli@ircres.cnr.it":giovanni.cerulli@ircres.cnr.it}{p_end}

{phang}Marco Ventura{p_end}
{phang}ISTAT{p_end}
{phang}Methodological and Data Quality Division, Italian Statistics Office{p_end}
{phang}E-mail: {browse "mailto:mventura@istat.it":mventura@istat.it}{p_end}



{title:Also see}

{psee}
Online: {helpb coefplot}, {helpb teffects}, {helpb ivtreatreg}, {helpb ctreatreg}
{p_end}
