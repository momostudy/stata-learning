{smcl}
{* *! version 1.3 10 Feb 2020}{...}
{cmd:help xtqreg} 

{hline}

{title:Title}

{p2colset 8 18 19 2}{...}
{p2col :{cmd: xtqreg} {hline 2}}Quantile regression with fixed effects{p_end}
{p2colreset}{...}


{title:Syntax}

{phang}

{p 8 13 2}
{cmd:xtqreg} {depvar} {indepvars} {ifin} [{cmd:,} {it:options}]


{synoptset 25 tabbed}{...}
{marker options}{...}
{synopthdr :options}
{synoptline}

{synopt :{opt q:uantile(#[#[# ...]])}}estimate {it:#} quantile; default is {cmd:quantile(.5)}{p_end}

{synopt:{opt i:d}}specifies the variable defining the panel{p_end}

{synopt :{opt ls}}displays the estimates of the location and scale parameters{p_end}

{synopt :{opt save:fe(newvar)}}saves the fixed effects for each estimated quantile{p_end}

{synopt :{opt p:redict(newvar)}}saves the fitted values for each estimated quantile{p_end}

{synoptline}
{p2colreset}{...}

{phang} {it: indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{phang}{cmd:xtqreg} does not allow {cmd:weight}s.{p_end}



{title:Description}

{pstd}
{cmd:xtqreg} estimates quantile regressions with fixed effects using the method of Machado and Santos Silva (2019).


{marker options}
{title:Options}

{phang}{opt quantile(#[#[# ...]])} specifies the quantile to be estimated and should be
a number strictly between 0 and 1. The default value of 0.5 corresponds to the median.
The quantiles can be specified as a list, in which case the regression will be estimated
for each quantile.

{phang}{opt id(panelvar)} specifies that the variable defining the panel is {it:panelvar}.

{phang}{opt ls} displays the estimates of the location and scale parameters{p_end}

{phang}{opt save:fe(newvar)}saves the fixed effects for each estimated quantile in a variable whose 
name starts with {it:newvar}{p_end}

{phang}{opt p:redict(newvar)}saves the fitted values for each estimated quantile in a variable whose 
name starts with {it:newvar}{p_end}



{title:Remarks}

{pstd}
{cmd: xtqreg} was written by J.A.F. Machado and J.M.C. Santos Silva and it is not an 
official Stata command; we are grateful to Fernando Rios-Avila for help writing this command. 
For further help and support, please contact jmcss@surrey.ac.uk. Please notice 
that this software is provided as is, without warranty of any kind, express or implied, including but 
not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. 
In no event shall the authors be liable for any claim, damages or other liability, whether in an action 
of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other 
dealings in the software.


{title:Examples}

    {hline}
{pstd}Setup{p_end}
{phang2}{cmd:. sysuse auto}{p_end}

{pstd}Median regression with fixed effects for headroom{p_end}
{phang2}{cmd:. xtqreg price weight length i.foreign, i(headroom)}{p_end}

{pstd}Estimate .25 quantile with fixed effects for headroom{p_end}
{phang2}{cmd:. xtqreg price weight length i.foreign, i(headroom) quantile(.25)}{p_end}

{pstd}Estimate the nine deciles with fixed effects for headroom{p_end}
{phang2}{cmd:. xtqreg price weight length i.foreign, i(headroom) quantile(.1(0.1)0.9)}{p_end}

{pstd}Median regression with fixed effects for headroom reporting the location and scale estimates {p_end}
{phang2}{cmd:. xtqreg price weight length i.foreign, i(headroom) quantile(.25) ls}{p_end}


    {hline}


{title:Saved results}

{pstd}
When only one quantile is estimated, {cmd:xtreg} saves the following results in {cmd:e()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:xtqreg}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(V)}}covariance matrix{p_end}
{synopt:{cmd:e(q)}}estimated quantile of the scaled errors{p_end}
{synopt:{cmd:e(b_location)}}location-coefficients vector{p_end}
{synopt:{cmd:e(V_location)}}location-coefficients covariance matrix{p_end}
{synopt:{cmd:e(b_scale)}}scale-coefficients vector{p_end}
{synopt:{cmd:e(V_scale)}}scale-coefficients covariance matrix{p_end}


{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}

{pstd}
If multiple quantiles are estimated, {cmd:xtqreg} also saves b, V, and q for each quantile with 
names of the form (for the first quartile) e(b_25), e(V_25), and e(q_25). In this case, the 
matrices e(b), e(V), and e(q) contain the results for the last estimated quantile.


{title:References}

{phang} Machado, J.A.F. and Santos Silva, J.M.C. (2019), 
{browse "https://doi.org/10.1016/j.jeconom.2019.04.009":Quantiles via Moments}, 
{it: Journal of Econometrics}, 213(1), pp. 145-173.{p_end} 

{title:Also see}

{psee}
Manual:  {manlink R xtreg}

