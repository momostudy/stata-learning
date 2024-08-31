{smcl}
{* *! version 1.0.0  21jan2015}{...}
{* *! version 1.0.1  11mar2015}{...}
{cmd:help sftfe}{right:also see:  {help sftfe postestimation}}
{hline}

{title:Title}

{p2colset 5 17 21 2}{...}
{p2col :{hi:sftfe} {hline 1}}Consistent estimation of fixed-effects stochastic frontier models{p_end}
{p2colreset}{...}

{title:Syntax}

{phang}
Marginal Maximum Likelihood within estimator (Chen et al., 2014)

{p 8 16 2}{cmd:sftfe} {depvar} [{indepvars}] {ifin} {weight}
{cmd:, estimator(within)} [{it:{help sftfe##withinoptions:within_options}}]

{phang}
Marginal Maximum Likelihood first-difference estimator (Belotti and Ilardi, 2018; Chen et al., 2014)

{p 8 16 2}{cmd:sftfe} {depvar} [{indepvars}] {ifin} {weight}
{cmd:, estimator(fdiff)} [{it:{help sftfe##fdiffoptions:fdiff_options}}]

{phang}
Marginal Maximum Simulated Likelihood estimator (Belotti and Ilardi, 2018)

{p 8 16 2}{cmd:sftfe} {depvar} [{indepvars}] {ifin} {weight}
{cmd:, estimator(mmsle)} [{it:{help sftfe##mmsleoptions:mmsle_options}}]

{phang}
Pairwise Difference estimator (Belotti and Ilardi, 2018)

{p 8 16 2}{cmd:sftfe} {depvar} [{indepvars}] {ifin} {weight}
{cmd:, estimator(pde)} [{it:{help sftfe##pdeoptions:pde_options}}]


{marker withinoptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr : within_options}
{synoptline}
{syntab :Inefficiency distribution}
{synopt :{cmdab:d:istribution(}{opt h:normal)}}half-normal distribution for the inefficiency term{p_end}

{syntab :{help sftfe##sv_remarks:Starting values}}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt resc:ale}}determine rescaling of initial values{p_end}

{syntab :Other}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt r:obust} or {opt cl:uster} {it:clustvar}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{opt nowarn:ing}}do not display warning message "convergence not achieved"{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}
{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help sftfe##tfe_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help sftfe##maximize_options:maximize_options}}}control the maximization process; seldom used{p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}

{marker fdiffoptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :fdiff_options}
{synoptline}
{syntab :Inefficiency distribution}
{synopt :{cmdab:d:istribution(}{opt h:normal)}}half-normal distribution for the
inefficiency term{p_end}
{synopt :{cmdab:d:istribution(}{opt t:normal)}}truncated-normal distribution for the inefficiency term{p_end}

{syntab :{help sftfe##sv_remarks:Starting values}}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt resc:ale}}determine rescaling of initial values{p_end}

{syntab :Other}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}


{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{opt nowarn:ing}}do not display warning message "convergence not achieved"{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help sftfe##tre_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help sftfe##maximize_options:maximize_options}}}control the maximization process; seldom used {p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}


{marker mmsleoptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :mmsle_options}
{synoptline}
{syntab :Inefficiency distribution}
{synopt :{cmdab:d:istribution(}{opt h:normal)}}half-normal distribution for the
inefficiency term{p_end}
{synopt :{cmdab:d:istribution(}{opt e:xponential)}}exponential distribution for the inefficiency term{p_end}

{syntab :Ancillary equations}
{synopt :{cmdab:u:sigma(}{it:{help varlist:varlist_u}}[{cmd:,} {opt nocons:tant}]{cmd:)}}specify explanatory variables for the inefficiency variance function;
    use {opt noconstant} to suppress constant term. Notice that variables contained in {opt varlist_u} must be time-invariant{p_end}

{syntab :{help sftfe##sv_remarks:Starting values}}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt resc:ale}}determine rescaling of initial values{p_end}

{syntab :Other}
{synopt :{cmdab:simtype(}{it:{help sftfe##simtype:simtype}}{cmd:)}}method to produce random draws for simulation{p_end}
{synopt :{opt nsim:ulations(#)}}# of random draws{p_end}
{synopt :{opt base(#)}}prime number used as a base for Halton sequences generation; only with {cmd:simtype(halton)}{p_end}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{it:{help sftfe##tre_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help sftfe##maximize_options:maximize_options}}}control the maximization process; seldom used {p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}

{synoptset 20}{...}
{marker simtype}{...}
{synopthdr :simtype}
{synoptline}
{synopt :{opt u:niform}}Uniformly distributed random variates{p_end}
{synopt :{opt ha:lton}}Halton sequence with {opt base(#)} (default){p_end}
{synoptline}
{p2colreset}{...}


{marker pdeoptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :pde_options}
{synoptline}
{syntab :Inefficiency distribution}
{synopt :{cmdab:d:istribution(}{opt e:xponential)}}exponential distribution for the
inefficiency term{p_end}
{synopt :{cmdab:d:istribution(}{opt h:normal)}}half-normal distribution for the
inefficiency term{p_end}
{synopt :{cmdab:d:istribution(}{opt t:normal)}}truncated-normal distribution for the
inefficiency term{p_end}

{syntab :Ancillary equations}
{synopt :{cmdab:e:mean(}{it:{help varlist:varlist_m}}[{cmd:,} {opt nocons:tant}]{cmd:)}}fit conditional mean model;
    only with {cmd:d(tnormal)}{p_end}
{synopt :{cmdab:u:sigma(}{it:{help varlist:varlist_u}}[{cmd:,} {opt nocons:tant}]{cmd:)}}specify explanatory variables for the inefficiency variance function;
    use {opt noconstant} to suppress constant term{p_end}
{synopt :{cmdab:v:sigma(}{it:{help varlist:varlist_v}}[{cmd:,} {opt nocons:tant}]{cmd:)}}specify explanatory variables for the idiosyncratic error variance function;
    use {opt noconstant} to suppress constant term{p_end}

{syntab :{help sftfe##sv_remarks:Starting values}}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt resc:ale}}determine rescaling of initial values{p_end}

{syntab :Other}
{synopt :{opt dynamic}}fit the model where inefficiency is assumed to follow a first-order autoregressive process. This option can be specified only when inefficiency is half-normal or truncated normal distributed{p_end}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{opt nowarn:ing}}do not display warning message "convergence not achieved"{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help sftfe##tre_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help sftfe##maximize_options:maximize_options}}}control the maximization process; seldom used {p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{p2colreset}{...}


{p 4 6 2}
A panel and a time variable must be specified. Use {helpb xtset}.{p_end}
{p 4 6 2}
{it:indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}
{it:depvars} and {it:indepvars} may contain time-series operators; see
{help tsvarlist}.{p_end}
{p 4 6 2}
See {help sftfe postestimation} for
features available after estimation.{p_end}


{title:Description}

{pstd}
{cmd:sftfe} fits the following fixed-effects stochastic frontier model:

		y_it = alpha_i + beta*X_it + v_it {c 177} u_it

{pstd}
where v_it is a normally distributed error term and u_it is a one-sided strictly non-negative term representing inefficiency.
The sign of the u_it term is positive or negative depending on whether the frontier describes a cost or production function, respectively.
Depending on the estimator used, {cmd: sftfe} allows the underlying mean and variance of the inefficiency (as well as the variance of the
idiosyncratic error) to be expressed as functions of exogenous covariates. Of special note is that {cmd:sftfe} allows the estimation of
the model in which the inefficiency is assumed to follow a first-order autoregressive process.

{title:Remarks}

{pstd}
When the inefficiency is assumed to follow a first-order autoregressive process ({opt dynamic}), we use the inverse hyperbolic tangent parameterization in oder to constrain the autocorrelation coefficient (/rho) within its valid domain.
This also allows to achieve numerical stability during optimization.{p_end}
{pstd}
Notice that for -within- and -fdiff- estimators the cumulative multivariate half-normal (or truncated-normal) distribution is approximated exploiting
the result outlined in Kotz et al. (2000) (see Chen et al. [2014] and Belotti and Ilardi [2018] for more details). On the other hand, the -pde- uses the Genz (2004) approach to efficiently compute bivariate normal probabilities.
The {cmd:sftfe} command was written for research purposes only. It has been extensively tested but it is distributed without any warranty.
If you use the command for academic and research purposes, please cite the first two papers reported below

{pstd}
The user needs to set the seed by him/herselves, using the {cmd: set seed} command or the {cmd: seed()} option to ensure replicability of results when using estimators requiring the generation of random-numbers.


{title:References}

{pstd}
Belotti, F., Ilardi, G. (2018). Consistent Inference in Fixed-effects Stochastic Frontier Models. Journal of Econometrics, 202, 161-177.{p_end}

{pstd}
Chen, Y., Wang, H., & Schmidt, P. (2014). Consistent estimation of the fixed effects stochastic frontier model. Journal of Econometrics, 181, 65-76.{p_end}

{pstd}
Genz, A. (2004), Numerical computation of rectangular bivariate and trivariate normal and t-probabilities, Statistics and Computing,14, 251-260.{p_end}

{pstd}
Kotz, S., Balakrishnan, N., & Johnson, N. L. (2000). Continuous Multivariate Distributions, Volume 1, Models and Applications, 2nd Edition. John Wiley & Sons.{p_end}


{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Department of Economics and Finance, University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}

{pstd}Giuseppe Ilardi{p_end}
{pstd}Directorate General for Economics, Statistics and Research, Bank of Italy{p_end}
{pstd}Rome, Italy{p_end}
{pstd}giuseppe.ilardi@bancaditalia.it{p_end}


{title:Examples}

{pstd}Homoskedasticity - production frontier{p_end}
{phang}{cmd:. use http://www.econometrics.it/stata/data/sftfe_homo_demo, clear}{p_end}
{phang}{cmd:. xtset id t}{p_end}

{phang}{cmd:. sftfe y x1 x2, est(fdiff) dist(hn)}{p_end}

{phang}{cmd:. sftfe y x1 x2, est(within) dist(hn)}{p_end}

{phang}{cmd:. sftfe y x1 x2, est(mmsle) dist(hn) symtype(halton) nsim(1000)}{p_end}


{pstd}Heteroskedasticity in both u and v - cost frontier{p_end}
{phang}{cmd:. use http://www.econometrics.it/stata/data/sftfe_hetero_demo, clear}{p_end}
{phang}{cmd:. xtset id t}{p_end}

{phang}{cmd:. sftfe y x1 x2, est(pde) dist(hn) usigma(zu) vsigma(zv) cost}{p_end}

{pstd}Heteroskedastic and first-order autoregressive inefficiency{p_end}
{phang}{cmd:. use http://www.econometrics.it/stata/data/sftfe_dyn_demo, clear}{p_end}
{phang}{cmd:. xtset id t}{p_end}

{phang}{cmd:. sftfe y x, est(pde) dist(hn) usigma(z) dynamic}{p_end}


{title:Also see}

{psee}
{space 2}Help:  {help sftfe_postestimation}, {help sfpanel}, {help sfpanel_postestimation}.
{p_end}
