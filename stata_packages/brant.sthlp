{smcl}
{* 2014-08-06 scott long & jeremy freese}{...}
{title:Title}
{p2colset 5 14 23 2}{...}

{p2col:{cmd:brant} {hline 2}}Perform Brant test of parallel regression assumption after {bf:ologit}{p_end}
{p2colreset}{...}

{title:General syntax}

{p 4 18 2}
{cmdab:brant}
{cmd:,}
[{opt detail}]

{marker overview}
{title:Overview}

{pstd}
{cmd:brant} performs a Brant test of the parallel regression assumption (also
called the proportional odds assumption) after {helpb ologit}.  The test compares
slope coefficients of the J-1 binary logits implied by the ordered regression
model.  Stata reports both the results of an omnibus test for the entire
model and tests of the assumption for each of the independent variables in
the model.
{p_end}

{pstd}
The Brant test can only be computed if all of the independent variables in
the ordered model are retained in all of the implied binary models.  This
is most likely not to be the case with models that have few observations in
the extreme categories and many independent variables.
{p_end}

{marker options}
{title:Options}
{p2colset 5 12 13 0}
{synopt:{opt detail}}
specifies that the coefficients for each of the estimated binary
logits should be presented.

{marker examples}
{title:Example}

{pstd}
{cmd: . spex ologit}
{p_end}
{pstd}
<output omitted>
{p_end}
{pstd}
{cmd: . brant, detail}
{p_end}

INCLUDE help spost13_footer



