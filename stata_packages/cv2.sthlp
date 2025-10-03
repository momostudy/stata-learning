{smcl}
{* *! version 0.2.0  13mar2022}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "cv2##syntax"}{...}
{viewerjumpto "Description" "cv2##description"}{...}
{viewerjumpto "Examples" "cv2##examples"}{...}
{title:Title}

{phang}
{bf:cv2} {hline 2} Stata module to calculate the coefficient of variation for variables


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:cv2}
{it: varlist}
[{helpb if}]
[{helpb in}]
[{cmd:,} {it:warn(warning_level) onlynomiss}]

{synoptset 12 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt warn}} specifies below which value of the absolute mean warnings should be issued; if none is specified, {cmd:cv2} will assume .05{p_end}
{synopt:{opt onlynomiss}} instructs {cmd:cv2} to only consider observations that have no missing values in any of the variables listed in {it:varlist}{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:cv2} automates the trivial task of calculating the coefficient of variation (CV) for each of a given list of variables.{p_end}

{pstd}The CV (infrequently also referred to as the coefficient of relative variation, CRV) is a measure of dispersion of a variable. It is defined as the variable's standard deviation divided by the mean. The CV is independent of the units of measurement and of the magnitude of the data. Consequently, it can be used to compare the variability of different variables. Of two variables, the variable with the smaller CV is less dispersed than the variable with the larger CV.
{p_end}

{pstd}
Please note that the CV is only meaningful for ratio variables, i.e., variables for which zero indicates the complete absence of the measured quantity. Temperature measured in degrees Celsius, for instance, is {it: not} such a variable because zero degrees Celsius does not imply the absence of temperature. A unit that would yield an interpretable CV would be degrees Kelvin, with zero indicating complete absence of temperature.
{p_end}

{pstd}
Please note that the CV is not defined for cases in which the mean is zero. The CV also takes on extreme values when the mean becomes very small. {cmd:cv2} will therefore issue warnings in such cases. Please also note that the CV will become negative if the mean value is negative. Again, {cmd:cv2} will issue a warning.
{p_end}

{phang} {cmd:cv2} can be used with {helpb by}:{p_end}

{pstd}{cmd: . by my_group_id: cv2 var1 var2}{p_end}


{marker examples}{...}
{title:Examples}

{pstd}Simple example for three variables, with user-specified warning threshold{p_end}
{phang2}{cmd:. webuse rvary2}{p_end}
{phang2}{cmd:. cv2 rater1 rater2 rater3, warn(.10)}{p_end}

{marker references}{...}
{title:References}

{phang}Abdi, H. (2010). Coefficient of Variation. In N. J. Salkind (Ed.), {it: Encyclopedia of Research Design}, Vol. 1 (pp. 169-171), Thousand Oaks, CA: SAGE Publications.{p_end}
{phang}Allison, P. D. (1978). Measures of Inequality. {it:American Sociological Review}, 43(6), 169-171.{p_end}

{marker author}{...}
{title:Author}

{phang}Lorenz Graf-Vlachy{p_end}
{phang}{browse "http://www.graf-vlachy.com":graf-vlachy.com}{p_end}
{phang}mail@graf-vlachy.com{p_end}

