{smcl}
{* *! version 1.0  10jul2017}{...}
{vieweralsosee "reshape" "help reshape"}{...}
{viewerjumpto "Syntax" "gather##syntax"}{...}
{viewerjumpto "Description" "gather##description"}{...}
{viewerjumpto "Options" "gather##options"}{...}
{viewerjumpto "Examples" "gather##examples"}{...}

{title:Title}
{bf:gather} {hline 2} An easier way to reshape long

{marker syntax}{...}
{title:Syntax}
{p 8 15 2}{cmd:gather} {varlist} {cmd:, [}{opt variable(newvar)} {opt value(newvar)} {opt label(newvar)}{cmd:]}

{marker description}{...}
{title:Description}
{pstd}
{cmd:gather}  takes a list of variables {varlist} and collapses into variable-value pairs. It is a simpler version of reshape long. Its goal is similar to the homonym function in the R package tidyr.

{marker options}{...}
{title:Options}
{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt variable(newvar)}} name of new variable corresponding to variable names. Defaults to "variable" {p_end}
{synopt :{opt value(newvar)}}  name of new variable corresponding to variable values. Defaults to "values" {p_end}
{synopt :{opt label(newvar)}} creates a new variable to store the variable labels of {it:varlist} {p_end}
{synoptline}
{p2colreset}{...}

{marker examples}{...}
{title:Examples}
{phang2}{cmd:. sysuse educ99gdp.dta, clear}{p_end}
{phang2}{cmd:. gather public private}{p_end}


{marker contact}{...}
{title:Author}

{phang}
Matthieu Gomez

{phang}
Department of Economics, Princeton University

{phang}
Please report issues on Github
{browse "https://github.com/matthieugomez/stata-tidy":https://github.com/matthieugomez/stata-tidy}
{p_end}
