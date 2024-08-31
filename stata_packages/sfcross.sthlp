{smcl}
{* *! version 1.1.2  25nov2011}{...}
{cmd:help sfcross}{right:also see:  {help sfcross postestimation}}
{hline}

{title:Title}

{p2colset 5 16 23 2}{...}
{p2col :{hi:sfcross} {hline 2}}Stochastic frontier models for cross-sectional data{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:sfcross}
{depvar}
[{indepvars}]
{ifin}
{weight}
[{cmd:,} {it:options}]

{synoptset 33 tabbed}{...}
{synopthdr}
{synoptline}
{syntab :Frontier}
{synopt :{opt nocons:tant}}suppress constant term{p_end}
{synopt :{cmdab:d:istribution(}{opt e:xponential)}}exponential distribution for the inefficiency term, the default{p_end}
{synopt :{cmdab:d:istribution(}{opt h:normal)}}half-normal distribution for the
inefficiency term{p_end}
{synopt :{cmdab:d:istribution(}{opt t:normal)}}truncated-normal distribution for the inefficiency term{p_end}
{synopt :{cmdab:d:istribution(}{opt g:amma)}}gamma distribution for the inefficiency term{p_end}

{syntab :Ancillary equations}
{synopt :{cmdab:e:mean(}{it:{help varlist:varlist_m}} [{cmd:,} {opt nocons:tant}]{cmd:)}}fit
conditional mean model; only with {cmd:d(tnormal)}; use {opt noconstant} to
suppress constant term{p_end}
{synopt :{cmdab:u:sigma(}{it:{help varlist:varlist_u}} [{cmd:,} {opt nocons:tant}]{cmd:)}}specify explanatory
variables for the inefficiency variance function; use {opt noconstant}
to suppress constant term{p_end}
{synopt :{cmdab:v:sigma(}{it:{help varlist:varlist_v}} [{cmd:,} {opt nocons:tant}]{cmd:)}}specify explanatory
variables for the idiosyncratic error variance function; use {opt noconstant}
to suppress constant term{p_end}

{syntab :{help sfcross##sv_remarks:Starting values}}
{synopt:{opt svfront:ier()}}specify a {it:1 X k} vector of initial values for the coefficients of the frontier{p_end}
{synopt:{opt sve:mean()}}specify a {it: 1 X k_m} vector of initial values for the coefficients of the conditional mean model; only with {cmd:d(tnormal)}{p_end}
{synopt:{opt svu:sigma()}}specify a {it: 1 X k_u} vector of initial values for the coefficients of the inefficiency variance function{p_end}
{synopt:{opt svv:sigma()}}specify a {it: 1 X k_v} vector of initial values for the coefficients of the idiosyncratic error variance function{p_end}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt resc:ale}}determine rescaling of initial values{p_end}

{syntab :Other options}
{synopt :{opt cost}}fit cost frontier model; default is production frontier
model{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}
{synopt :{cmdab:simtype(}{it:{help sfcross##simtype:simtype}}{cmd:)}}method to produce random draws for simulation; only with {cmd:d(gamma)}{p_end}
{synopt :{opt nsim:ulations(#)}}# of draws; only with {cmd:d(gamma)}{p_end}
{synopt :{opt base(#)}}prime number used as a base for Halton sequences generation; only with {cmd:d(gamma)} and {cmd:simtype(halton)} or {cmd:simtype(genhalton)}{p_end}

{syntab :SE}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it:clustvar}{cmd:)}{p_end} 
{syntab :Reporting}
{synopt :{opt l:evel(#)}}set confidence level; default is
{cmd:level(95)}{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{opt nowarn:ing}}do not display warning message "convergence not achieved"{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end} 
{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help sfcross##display_options:display_options}}}control spacing
           and display of omitted variables and base and empty cells{p_end}

{syntab :Maximization}
{synopt :{it:{help sfcross##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}

{synoptset 20}{...}
{marker simtype}{...}
{synopthdr :simtype}
{synoptline}
{synopt :{opt ru:niform}}Uniformly distributed random variates{p_end}
{synopt :{opt ha:lton}}Halton sequence with {opt base(#)}{p_end}
{synopt :{opt genha:lton}}Generalized Halton sequence with {opt base(#)}{p_end}
{synoptline}
{p2colreset}{...}

{p2colreset}{...}
{p 4 6 2}
{it:indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}
{opt bootstrap}, {opt by}, {opt jackknife}, and {opt svy}
are allowed; see {help prefix}.{p_end}
{p 4 6 2}Weights are not allowed with the {helpb bootstrap} prefix.{p_end}
{p 4 6 2}
{opt aweight}s, {opt fweight}s, {opt iweight}s, and {opt pweight}s are allowed;
see {help weight}.{p_end}
{p 4 6 2}


{title:Description}

{pstd}
{opt sfcross} fits stochastic production or cost frontier models; the default
is a production frontier model.  It provides estimators for the parameters of
a linear model with a disturbance that is assumed to be a mixture of two components, 
which have a strictly nonnegative and symmetric distribution, respectively.
{opt sfcross} can fit models in which the nonnegative distribution component
(a measurement of inefficiency) is assumed to be from a half-normal, exponential, 
truncated-normal or gamma distribution. In the latter case, maximization is performed
through maximum simulated likelihood.

{title:Options}

{dlgtab:Frontier}

{phang}
{opt noconstant}; see
{helpb estimation options##noconstant:[R] estimation options}.

{phang}
{opt distribution(distname)} specifies the distribution for the inefficiency term 
    as half-normal ({opt hnormal}), truncated-normal ({opt tnormal}) or {opt exponential}. 
    The default is {opt exponential}.

{dlgtab:Ancillary equations}

{phang}
{cmd:emean(}{help varlist:varlist_m} [,{opt noconstant}]{cmd:)} may be used only with {cmd:distribution(tnormal)}.
    With this option, {opt sfcross} specifies the mean of the truncated-normal distribution in terms of a linear function of the covariates defined in {it:varlist_m}. Specifying {opt noconstant} suppresses the constant in this function.

{phang}
{cmd:usigma(}{help varlist:varlist_u} [,{opt noconstant}]{cmd:)}
specifies that the inefficiency component is heteroskedastic,
with the variance expressed as a function of the covariates defined in 
{it:varlist_u}. Specifying {opt noconstant} suppresses the
constant in this function. 

{phang}
{cmd:vsigma(}{help varlist:varlist_v} [,{opt noconstant}]{cmd:)}
specifies that the idiosyncratic error component is heteroskedastic,
with the variance expressed as a function of the covariates defined in 
{it:varlist_v}. Specifying {opt noconstant} suppresses the
constant in this function.  

{dlgtab:Starting values}

{phang}
{opt svfrontier()} specifies a 1 x k vector of initial values for the 
coefficients of the frontier.  The vector must have the
same length of the parameters vector to be estimated.

{phang}
{opt svemean()} specifies a 1 x k_m vector  of initial values for the 
coefficients of the conditional mean model. This option cab be specified only with 
{cmd:distribution(tnormal)}. 

{phang}
{opt svusigma()} specifies a 1 X k_u vector of initial values for the 
coefficients of the technical inefficiency variance function.

{phang}
{opt svvsigma()} specifies a 1 X k_v vector of initial values for the 
coefficients of the technical inefficiency variance function. This option cannot be specified 
with {cmd:distribution(gamma)}.

{phang}
{opt nosearch} determines that no attempts are made to improve on the initial
values via a search technique. In this case, the initial values become the 
starting values.

{phang}
{opt restart} determines that the random method of improving initial values is
to be attempted. See also {help mf_moptimize##init_search}

{phang}
{opt repeat(#)} controls how many times random values are tried if the random method is turned
on. The default is 10.

{phang}
{opt rescale} determines whether rescaling is attempted. Rescaling is a deterministic method.
It also usually improves initial values, and usually reduces the number of subsequent iterations 
required by the optimization technique.

{dlgtab:Other options}

{phang}
{opt cost} specifies that {opt sfcross} fits a cost frontier model.

{phang}
{opt constraints}({it:{help estimation options##constraints():constraints}}) applies specified linear constraints.

{phang}
{opt simtype(simtype)} specifies the method to generate random draws with {cmd:distribution(gamma)}. 
{opt runiform} generates uniformly distributed random variates; {opt halton} and {opt genhalton} create 
respectively Halton sequences and generalized Halton sequences where the base is expressed by the prime 
number in {opt base}(#). {opt runiform} is the default. See also {help mf_halton} for more details on Halton sequences generation.

{phang}
{opt nsimulations(#)} specifies the number of draws for simulation when 
{cmd:distribution(gamma)} is specified. The default is 250.

{phang}
{opt base(#)} specifies the number, preferably a prime, used as a base for the generation of Halton sequences and
generalized Halton sequences when {cmd:distribution(gamma)} is specified. The default is 7. Note that Halton sequences
based on large primes (#>10) can be highly correlated, and their coverage
worse than that of pseudorandom uniform sequences.

{dlgtab:SE}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported,
which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see 
{helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see
{helpb estimation options##level():[R] estimation options}.

{phang}
{opt nocnsreport}; see
     {helpb estimation options##nocnsreport:[R] estimation options}.

{phang}
{opt nowarning} specifies whether the warning message "convergence not achieved" should
        not be displayed when this stopping rule is invoked. By default the message is displayed.

{phang}
{opt postscore} saves an observation-by-observation matrix of scores in the estimation results list. 
Scores are defined as the derivative of the objective function with respect to the {help mf_moptimize##def_parameter:parameters}.
This option cannot be used when the size of the scores' matrix is greater than Stata matrix limit; see {helpb limits:[R] limits}.

{phang}
{opt posthessian} saves the Hessian matrix corresponding to the full set of coefficients 
in the estimation results list.

{marker display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

{marker maximize_options}{...}
{dlgtab:Maximization}

{phang}
{it:maximize_options}:
{opt dif:ficult},
{opt tech:nique(algorithm_spec)},
{opt iter:ate(#)},
[{cmdab:no:}]{opt lo:g},
{opt tr:ace},
{opt grad:ient},
{opt showstep},
{opt hess:ian},
{opt showtol:erance},
{opt tol:erance(#)},
{opt ltol:erance(#)},
{opt nrtol:erance(#)},
{opt nonrtol:erance};
see {manhelp maximize R}.
These options are seldom used.

{pstd}

{phang}
{opt coeflegend}; see
     {helpb estimation options##coeflegend:[R] estimation options}.

	 
{marker sv_remarks}{...}
{title:Remarks}

{pstd}
{cmd:sv{it:eqname}()} specifies initial values for the coefficients of {it:eqname}. You can specify the initial values in one of three ways:
1) by specifying the name of a vector contained in the initial values (e.g. {cmd:sv{it:frontier}(b0)}, where {cmd:b0} is a conformable 
vector); 2) by specifying coefficient names with the values in the same order as they appear in the command syntax 
(e.g. {cmd:sv{it:frontier}(x1=.5 x2=.3 _cons=1)}, if {cmd: sfcross y x1 x2}); 3) or by specifying a list of values
(e.g. {cmd:sv{it:frontier}(.5 .3 1)}.

{title:Examples}

    {hline}
    Setup
{phang2}{cmd:. webuse frontier1}{p_end}

{pstd}Cobb-Douglas production function with exponential distribution for
inefficiency term{p_end}
{phang2}{cmd:. sfcross lnoutput lnlabor lncapital}{p_end}

{pstd}Cobb-Douglas production function with half-normal distribution for
inefficiency term{p_end}
{phang2}{cmd:. sfcross lnoutput lnlabor lncapital, d(h)}{p_end}

{pstd}Cobb-Douglas production function with quartiles of {cmd:size} as explanatory variable
in variance function for idiosyncratic error{p_end}
{phang2}{cmd:. xtile qsize = size , nq(4)}{p_end}
{phang2}{cmd:. sfcross lnoutput lnlabor lncapital, vsigma(i.qsize)}{p_end}

{pstd}Cobb-Douglas production function with gamma distribution for inefficiency term{p_end}
{phang2}{cmd:. sfcross lnoutput lncapital lnlabor, d(gamma) rescale simtype(genha) nsim(100)}{p_end}

{pstd}Cobb-Douglas production function with {cmd:lnlabor}, {cmd:lncapital} and quartiles of {cmd:size} 
as explanatory variable of respectively the variance of the inefficiency term, the variance of the 
idiosyncratic error and the truncated mean{p_end}
{phang2}{cmd:. sfcross lnoutput lnlabor lncapital, d(tn) emean(i.qsize) usigma(lnlabor) vsigma( lncapital)}{p_end}

    {hline}
    Setup
{phang2}{cmd:. webuse frontier2}{p_end}

{pstd}Cost frontier model with exponential distribution for inefficiency
term with constraints on prices{p_end}
{phang2}{cmd:. cons def 1 lnp_l+ lnp_k=1}{p_end}
{phang2}{cmd:. sfcross lncost lnout lnp_l lnp_k, cost constr(1)}{p_end}
    {hline}


{title:Saved results}

{pstd}
{cmd:sfcross} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(k)}}number of parameters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(ll_c)}}log likelihood for H_0: sigma_u=0{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(iterations)}}number of iterations, including initiali step{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(chi2)}}chi-squared{p_end}
{synopt:{cmd:e(p)}}significance{p_end}
{synopt:{cmd:e(chi2_c)}}LR test statistic{p_end}
{synopt:{cmd:e(z)}}test for negative skewness of OLS residuals{p_end}
{synopt:{cmd:e(p_z)}}p-value for z{p_end}
{synopt:{cmd:e(k_autoCns)}}number of base, empty, and omitted constraints{p_end}
{synopt:{cmd:e(sigma_u)}}standard deviation of technical inefficiency{p_end}
{synopt:{cmd:e(sigma_v)}}standard deviation of V_i{p_end}
{synopt:{cmd:e(g_shape)}}Shape parameter of the Gamma distributed inefficiency{p_end}
{synopt:{cmd:e(avg_sigmau)}}average standard deviation of technical inefficiency{p_end}
{synopt:{cmd:e(avg_sigmav)}}average standard deviation of V_i{p_end}
{synopt:{cmd:e(lambda)}}signal to noise ratio{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:sfcross}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(function)}}{cmd:production} or {cmd:cost}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(covariates)}}name of independent variables{p_end}
{synopt:{cmd:e(crittype)}}optimization criterion{p_end}
{synopt:{cmd:e(dist)}}distribution assumption for U_i{p_end}
{synopt:{cmd:e(het)}}heteroskedastic components{p_end}
{synopt:{cmd:e(Emean)}}{it:varlist} in {cmd:emean()}{p_end}
{synopt:{cmd:e(Usigma)}}{it:varlist} in {cmd:usigma()}{p_end}
{synopt:{cmd:e(Vsigma)}}{it:varlist} in {cmd:vsigma()}{p_end}
{synopt:{cmd:e(simtype)}}method to produce random draws{p_end}
{synopt:{cmd:e(base)}}base number to generate Halton sequences{p_end}
{synopt:{cmd:e(nsim)}}number of random draws{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(opt)}}type of optimization{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(singularHmethod)}}{cmd:m-marquardt} or {cmd:hybrid}; method used when Hessian is singular{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform maximization or minimization{p_end}{synopt:{cmd:e(wtype)}}weight type{p_end}{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(chi2type)}}{cmd:Wald}; type of model chi-squared test{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(contraints)}}list of specified constraints{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix{p_end}
{synopt:{cmd:e(ilog)}}iteration log (up to 20 iterations){p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance{p_end}
{synopt:{cmd:e(postscore)}}observation-by-observation scores{p_end}
{synopt:{cmd:e(posthessian)}}Hessian corresponding to the full set of coefficients{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


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
{space 2}Help:  {help sfcross_postestimation},
{help sfpanel},
{help sfpanel_postestimation}.
{p_end}
