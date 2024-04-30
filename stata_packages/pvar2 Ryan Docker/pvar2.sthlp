{smcl}
{* *! version 1.1.0  01jul2009}{...}
{cmd:help pvar2}
{hline}

{title:pvar2}

{phang}
{bf:pvar2} {hline 2} Panel vector autoregressive models


{title:Syntax}

{p 8 17 2}
{cmd:pvar2}
[{depvarlist}]
{ifin}
{weight}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt gmm}}estimates the model coefficients using GMM (required option; must be specified as the first option){p_end}
{synopt:{opt lag(#)}}specifies the number of lags in the underlying VAR; default is 1{p_end}
{synopt:{opt impulse [max IRF] [IRF x-axis intervals]}}generates numerical impulse response functions without error bands; see below for options{p_end}
{synopt:{opt list_imp}}generates a table with impulse response functions (use after impulse){p_end}
{synopt:{opt gr_imp}}generates graphical impulse responses (without error bands){p_end}
{synopt:{opt monte [repetitions] [max IRF] [IRF x-axis intervals]}}generates error bands for impulse response functions (see below){p_end}
{synopt:{opt list_mon}}lists a table containing impulse response functions and standard errors (use after monte){p_end}
{synopt:{opt decomp [maxnum] [interval]}}generates a table containing variance decompositions (must be listed after impulse or monte in command); see below for options{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
You must tsset or xtset your data before using pvar2; see {help tsset} or {help xtset}.{p_end}
{p 4 6 2}
{it:depvarlist} may contain time series operators; see {help depvarlist}.{p_end}


{title:Description}

{pstd}
{cmd:pvar2} estimates a panel vector autoregression model as described in Holtz et al. (1988). The data should be Helmert transformed prior to estimation to remove fixed effects (see helm). 

{pstd}
{it:depvarlist} is the list with variable names in the desired order. pvar2 uses Cholesky decomposition to construct impulse response functions; the first variable in the list is the "most exogenous," that is, the user assumes that each variable is not contemporaneously affected by variables which appear later in depvarlist.


{title:Options}

{dlgtab:Main}

{phang}
{opt gmm} estimates the model coefficients using GMM (required option; must be specified as the first option). This option calls sgmm2.ado; if not specified, estimates from the previous run are taken from memory.

{phang}
{opt lag(#)} specifies the number of lags in the underlying VAR; default is 1. {it:#} must be a positive integer.

{phang}
{opt impulse [max IRF] [IRF x-axis intervals]} generates numerical impulse response functions without error bands. The first option allows the user to choose the maximum horizon for which impulse response functions will be reported (default is 6)        . The second option allows the user to choose the interval at which the x-axis on impulse response function charts will be labeled (default is 1). NOTE: when specifying the third option after impulse, the user must also specify the first and seco           nd options (even when using the default).

{phang}
{opt list_imp} generates a table with impulse response functions (use after impulse).

{phang}
{opt gr_imp} generates graphical impulse responses (without error bands).

{phang}
{opt monte [repetitions] [max IRF] [IRF x-axis intervals]} generates error bands for impulse response functions using monte carlo simulations. The first option after monte is the number of desired repetitions (default is 200). The second option          after monte allows the user to choose the maximum horizon for which impulse response functions will be reported (default is 6). The third option after monte allows the user to choose the interval at which the x axis on impulse response function          charts will be labeled (default is 1). When using monte, do not specify impulse or gr_imp (monte automatically calls these options). NOTE: when specifying the third option after monte, the user must also specify the first and second options (even          when using the default). Likewise, when specifying the second option after monte, the user must also specify the first option (even when using the default).

{phang}
{opt list_mon} lists a table containing impulse response functions and standard errors (use after monte).

{phang}
{opt decomp [maxnum] [interval]} generates a table containing variance decompositions (must be listed after impulse or monte in command); maxnum is the max number of periods (default is 20); interval is the interval at which decompositions will          be displayed (default is 10). So "decomp 30 5" will fill the table with variance decompositions for every 5 years up to 30 years. NOTE: when specifying non-default intervals, the maximum period must also be specified (even if using the default of          20).

{phang}
{opt getresid} saves reduced-form residuals (by panel variable, time variable, and equation) in the working directory with the filename pvar2_resid.dta.


{title:Remarks}

{pstd}
The model uses untransformed variables as instruments for the Helmert-transformed variables in the model. If the user wants to estimate the model using a different transformation (e.g., first differences), the easiest way is to name the manually         transformed variables h_y1 h_y2 ... To estimate the model without fixed effects, create copies of the original variables named h_y1 h_y2... The program will use the original variables as both regressors and instruments (i.e., system OLS without a constant).

{pstd}
Many features of pvar2 require Stata version 9.0 or above. Users of older Stata versions should use the first version of the command, pvar.

{pstd}
Note that when you input the pvar2 command do not list the names of the Helmert-transformed variables (which are prefixed with "h_"); rather, list the original variable names instead.


{title:Examples}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse grunfeld, clear}{p_end}
{phang2}{cmd:. rename company id}{p_end}
{phang2}{cmd:. xtset id year}{p_end}

{pstd}Helmert transform the data to remove fixed effects{p_end}
{phang2}{cmd:. helm invest mvalue kstock}{p_end}

{pstd}Fit panel VAR with three lags; produce impulse response functions with monte carlo standard errors up to 12 periods (and label even periods on IRF graphs); produce variance decompositions for every 5th period up to 30 periods; save reduced-         form residuals in the working directory as pvar2_resid.dta.{p_end}
{phang2}{cmd:. pvar2 kstock invest mvalue, lag(3) gmm monte 500 12 2 decomp 30 5 getresid}{p_end}

{title:Saved results}

Matrix
{synopt:{cmd:D}}Variance decomposition matrix; column s indicates time interval.

{title:References}

{pstd}Holtz Eakin, D., W. Newey, and H. Rosen (1988). "Estimating Vector Autoregression with Panel Data," Econometrica, 56, 1371-1395. (http://www.jstor.org/stable/pdfplus/1913103.pdf){p_end}

{pstd}Love, I. and Ziccino, L. (2006). "Financial Development and Dynamic Investment Behavior: Evidence from Panel VAR," Quarterly Review of Economics and Finance, 46, 190-210. (doi:10.1016/j/qref.2005.11.007){p_end}

{title:Acknowledgements}

{pstd}Help files were written by:

{pstd}Christian Danne{p_end}
{pstd}Trinity College Dublin - Department of Economics{p_end}
{pstd}College Green{p_end}
{pstd}Dublin 2{p_end}
{pstd}Ireland{p_end}
{pstd}dannec@tcd.ie{p_end}

{pstd}Javier Miranda{p_end}
{pstd}Center for Economic Studies (US Census Bureau){p_end}

{pstd}Ryan Decker{p_end}
{pstd}University of Maryland{p_end}

{title:Author of pvar}

{pstd}Inessa Love{p_end}
{pstd}Senior Economist{p_end}
{pstd}Research Department- Finance Group{p_end}
{pstd}The World Bank{p_end}
{pstd}1818 Hst, NW, MC3-639, mailstop MC3-207{p_end}
{pstd}ilove@worldbank.org{p_end}

{pstd}Modifications by Ryan Decker{p_end}
{pstd}University of Maryland{p_end}

{title:Also see}
{help helm}, {help var intro}, {help xt}

{psee}
{space 2}Help:  {manhelp help R}
{p_end}
