{smcl}
{* *! version 1.8  13dec2016}{...}
{vieweralsosee "[R] regress, beta" "help regress"}{...}
{vieweralsosee "[R] estimates table" "help estimates table"}{...}
{viewerjumpto "Syntax" "stdBeta##syntax"}{...}
{viewerjumpto "Description" "stdBeta##description"}{...}
{viewerjumpto "Options" "stdBeta##options"}{...}
{viewerjumpto "Remarks" "stdBeta##remarks"}{...}
{viewerjumpto "Examples" "stdBeta##examples"}{...}
{title:Title}

{phang}
{bf:stdBeta} {hline 2} After estimating a statistical model, calculate centered and standardized coefficients


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:stdBeta}
[{cmd:,} {it:options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main}
{synopt:{opt nodepvar}}do not center or rescale the dependent variable{p_end}
{synopt:{opt store}[({it:store_names}, replace)]}store centered and standardized estimation results{p_end}
{synopt:{opt gen:erate}[({it:prefixes}, replace)]}save centered and standardized variables{p_end}
{synopt:{it:estimates_table_options}}output options to pass to {cmd:estimates table}{p_end}
{synoptline}
{p2colreset}{...}

{marker description}{...}
{title:Description}

{pstd}
{cmd:stdBeta} calculates centered and standardized coefficients, standard errors,
  and fit statistics, optionally storing the results as {cmd:estimates store}s.


{marker options}{...}
{title:Options}

{dlgtab:Main}

{phang}
{opt nodepvar} suppresses centering and rescaling the dependent variable.

{phang}
{opt store} stores ereturn statistics for all three models.  The
default names of these
{cmd:estimates store}s are Original, Centered, and Standardized.
Optionally accepts user supplied estimate names, and replaces
previously stored estimates.

{phang}
{opt generate} Save the centered and standardized versions of the
variables in the model.  The default prefix for the centered
variable names is "c_", while the default prefix for the
standardized variables is "z_".
Optionally accepts user supplied variable prefixes, and replaces
previously saved variables.

{phang}
{it:estimates_table_options} Options passed to {cmd:estimates table} for
reporting.


{marker author}{...}
{title:Author}

{pstd}
Doug Hemken, Social Science Computing Coop, Univ. of Wisconsin-Madison, dehemken@wisc.edu

{marker remarks}{...}
{title:Remarks}

{pstd}
For detailed information on stdBeta, see 
{browse "http://www.ssc.wisc.edu/~hemken/Stataworkshops/stata.html#recentering-rescaling-standardizing-coefficients":{it:Getting Standardized Coefficients Right}}.


{marker examples}{...}
{title:Examples}

{phang}{cmd:. regress price c.mpg##c.weight}{p_end}

{phang}{cmd:. stdBeta}{p_end}
