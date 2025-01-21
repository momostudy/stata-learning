{smcl}
{* *! version 2.0  June 2023}{...}
{cmd:help quaidsce}
{right:also see:  {help quaidsce postestimation}}
{hline}

{title:Title}

{p2colset 5 15 17 2}{...}
{p2col :{cmd:quaidsce} {hline 2}}Estimate censored almost-ideal demand systems{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 14 2}
{opt quaidsce} {it:varlist_expshares} {ifin}{cmd:,} {opt anot(#)} {opt reps(#)} 
   {c -(}{opt pr:ices(varlist_prices)}|{opt lnpr:ices(varlist_lnprices)}{c )-} 
   {c -(}{opt exp:enditure(varlist_exp)}|{opt lnexp:enditure(varlist_lnexp)}{c )-}
   [{it:{help quaidsce##options:options}}]

{pstd}
where {it:varlist_expshares} is the list of expenditure share
variables.  You must specify all the expenditure share variables. Do
not omit one of the shares to avoid a singular covariance matrix;
{cmd:quaidsce} does that automatically when censoring is not accounted.

{synoptset 30 tabbed}{...}
{marker options}{...}
{synopthdr}
{synoptline}
{p2coldent :# {opt anot(#)}}value to use for alpha_0 parameter{p_end}
{p2coldent :# {opt reps(#)}}value to use for bootstrap repetitions{p_end}
{p2coldent :* {opt pr:ices(varlist_prices)}}list of price variables{p_end}
{p2coldent :* {opt lnpr:ices(varlist_lnprices)}}list of variables containing natural logarithms of prices{p_end}
{p2coldent :+ {opt exp:enditure(varlist_exp)}}variable representing total expenditure{p_end}
{p2coldent :+ {opt lnexp:enditure(varlist_lnexp)}}variable representing the natural logarithm of total expenditure{p_end}
{synopt :{opt demo:graphics(varlist_demo)}}demographic variables to include{p_end}
{synopt :{opt noqu:adratic}}do not include quadratic expenditure term{p_end}
{synopt :{opt noce:nsor}}do not include censoring correction{p_end}
{synopt :{opt nolo:g}}suppress the iteration log{p_end}
{synopt :{cmd:vce(}{it:{help quaidsce##vcetype:vcetype}}{cmd:)}}{it:vcetype} may be {opt gnr}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt l:evel(#)}}set confidence level; default is {cmd:level(95)}{p_end}
{synopt :{opt m:ethod(method_name)}}NLSUR estimator; default is {ifgnls}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}# {opt anot(#)} and {opt reps(#)} are required.{p_end}
{p 4 6 2}* You must specify {opt prices()} or {opt lnprices()} but not both.{p_end}
{p 4 6 2}+ You must specify {opt expenditure()} or {opt lnexpenditure()} but not both.{p_end}


{title:Description}

{pstd}
{cmd:quaidsce} estimates the parameters of Deaton and Muellbauer's
(1980) almost-ideal demand system (AIDS) and Banks, Blundell, and
Lewbel's (1997) quadratic AIDS model.  Demographic variables can be
included in the model based on Ray's (1983) expenditure function scaling
technique.  Censoring is accounted for based on the two-step method proposed by
Shonkwiler and Yen (1999). This command extends over the {cmd:quaids} 
command, as described in Poi (2012).

{pstd}
Given the two-step process, {cmd:quaidsce} uses bootstrap to produce standard errors
that are consistent with the predicted variables in the first stage. If censoring is 
not required, we recommend using {cmd:quaids} or {cmd:demandsys}. Also note that 
{cmd:quaidsce} works only when censoring is present in all expenditure shares, and 
it can be predicted by demographic variables.

{title:Options}

{phang}
{opt anot(#)} specifies the value of the alpha_0 parameter that
appears in the price index. {opt anot()} is required.

{phang}
{opt reps(#)} specifies the number of repetitions for the bootstrap
standard errors. {opt reps()} is required.

{phang}
{opt prices(varlist_prices)} specifies the list of price
variables.  You must specify the price variables in the same order that
you specify the expenditure share variables {it:varlist_expshares}.  You
must specify {opt prices()} or {opt lnprices()} but not both.

{phang}
{opt lnprices(varlist_lnprices)} specifies the list of variables
containing the natural logarithms of the price variables.  You must
specify this list in the same order that you specify the expenditure
share variables {it:varlist_expshares}.  You must specify {opt prices()}
or {opt lnprices()} but not both.

{phang}
{opt expenditure(varlist_exp)} specifies the variable
representing total expenditure on all the goods in the demand system.
You must specify {opt expenditure()} or {opt lnexpenditure()} but not
both.

{phang}
{opt lnexpenditure(varlist_lnexp)} specifies the variable
representing the natural logarithm of the total expenditure on all
the goods in the demand system.  You must specify {opt expenditure()} or
{opt lnexpenditure()} but not both.

{phang}
{opt demographics(varlist_demo)} requests that the variables
{it:varlist_demo} be included in the demand system based on the scaling
technique introduced by Ray (1983) and Poi (2012).

{phang}
{opt noquadratic} requests that the quadratic income term not be
included in the expenditure share equations.  Specifying this option
requests Deaton and Muellbauer's (1980) AIDS model.  The default is to
include the quadratic income term, yielding Banks, Blundell, and
Lewbel's (1997) quadratic AIDS model.


{phang}
{opt nocensor} requests to avoid the censoring correction two-step approach.
The default is to conduct the two-step as proposed by Shonkwiler and Yen (1999).

{phang}
{opt nolog} requests that the iteration log be suppressed.

{phang}
{opt method(method_name)}; nlsur estimator method; see {manhelp nlsur R}. Default is ifgnls.
Other methods can be used to conduct faster model selection (at your own risk).

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.


{title:Saved results}

{pstd}
{cmd:quaidsce} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 15 17 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(N_clust)}}number of clusters{p_end}
{synopt:{cmd:e(ndemos)}}number of demographic variables{p_end}
{synopt:{cmd:e(anot)}}value of alpha_0{p_end}
{synopt:{cmd:e(reps)}}number of bootstrap repetitions{p_end}
{synopt:{cmd:e(ngoods)}}number of goods{p_end}

{p2col 5 15 17 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:quaidsce}{p_end}
{synopt:{cmd:e(clustvar)}}name of cluster variable{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used in label Std. Err.{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:{cmd:e(estat_cmd)}}program used to implement {cmd:estat}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(demographics)}}demographic variables included{p_end}
{synopt:{cmd:e(lhs)}}expenditure share variables{p_end}
{synopt:{cmd:e(expenditure)}}expenditure variable{p_end}
{synopt:{cmd:e(lnexpenditure)}}log-expenditure variable{p_end}
{synopt:{cmd:e(prices)}}price variables{p_end}
{synopt:{cmd:e(lnprices)}}log-price variables{p_end}
{synopt:{cmd:e(cdf)}}cdf variables{p_end}
{synopt:{cmd:e(pdf)}}pdf variables{p_end}
{synopt:{cmd:e(quadratic)}}{cmd:noquadratic}{p_end}
{synopt:{cmd:e(censor)}}{cmd:nocensor}{p_end}
{synopt:{cmd:e(method)}} specified in {cmd:method()}{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{p2col 5 15 17 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(best)}}coefficient vector of estimated parameters{p_end}
{synopt:{cmd:e(Vest)}}variance-covariance matrix of estimated parameters{p_end}
{synopt:{cmd:e(alpha)}}alpha vector{p_end}
{synopt:{cmd:e(beta)}}beta vector{p_end}
{synopt:{cmd:e(gamma)}}gamma matrix{p_end}
{synopt:{cmd:e(lambda)}}lambda vector{p_end}
{synopt:{cmd:e(eta)}}eta matrix{p_end}
{synopt:{cmd:e(rho)}}rho vector{p_end}
{synopt:{cmd:e(delta)}}delta vector{p_end}
{synopt:{cmd:e(delta)}}tau vector{p_end}
{synopt:{cmd:e(elas_i)}}Income elasticities{p_end}
{synopt:{cmd:e(elas_u)}}Uncompensated elasticities{p_end}
{synopt:{cmd:e(elas_c)}}Compensated elasticities{p_end}


{p2col 5 15 17 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:References}

{phang}
Banks, J., R. Blundell, and A. Lewbel.  1997.  Quadratic Engle curves
and consumer demand. {it:Review of Economics and Statistics} 79:
527-539.

{phang}
Deaton, A. S., and J. Muellbauer.  1980.  An almost ideal demand system.
{it:American Economic Review} 70: 312-326.

{phang}
Poi, B. P.  2012.  Easy demand system estimation with quaids. 
{it:Stata Journal} 12: 433-446.

{phang}
Shonkwiler, J and Yen, Steven T., (1999), Two-Step estimation of a censored system of equations, 
{it:American Journal of Agricultural Economics}, 81, issue 4, p. 972-982, 

{phang}
Ray, R.  1983.  Measuring the costs of children: An alternative approach.
{it:Journal of Public Economics} 22: 89-102.


{title:Corresponding author}

{pstd}Juan C. Caro{p_end}
{pstd}Universidad de Concepcion{p_end}
{pstd}juancaros@udec.cl{p_end}


{title:Also see}

{p 7 14 2}Help:  {help quaidsce postestimation}{p_end}
