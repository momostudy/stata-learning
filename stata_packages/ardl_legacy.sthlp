{smcl}
{* *! version 1.0.6  06feb2023}{...}
{title:Title}

{phang}
{bf:ardl legacy} {hline 2} legacy, out-of-date options and behavior of commands included in the {help ardl} package

{marker listoflegacyentries}{...}{* * * * * * * * * * * * * * LIST OF LEGACY ENTRIES * * * * * * * * * * * * * * * * * }
{title:List of legacy entries}

    {help ardl_legacy##ardl:ardl}
    {help ardl_legacy##btest:estat btest}


{marker abbreviations}{...}{* * * * * * * * * * * * * * * * * ABBREVIATIONS * * * * * * * * * * * * * * * *}
{title:Abbreviations and definitions used in this help entry}

{pstd}
See the {help ardl##abbreviations:abbreviations section of ardl}.


{marker ardl}{...}{* * * * * * * * * * * * * * * * * * * ARDL * * * * * * * * * * * * * * * * * }
{bf:{dlgtab 0 0:ardl}}

{marker ardl_options_short}{...}
{title:Legacy options}

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Syntax I}
{synopt:{opt minl:ag1}}like option {opt ec1}, but in addition requires at least one lag for {it:indepvars}{p_end}
{synopt:{opt bt:est}}display Pesaran/Shin/Smith (2001) bounds test{p_end}
{synoptline}
{p2colreset}{...}

{marker ardl_description}{...}
{title:Description}

{pstd}
This help section lists options from former versions of the {cmd:ardl} command that
have been superseded by other commands or options but that continue to work for
backward compatibility reasons.

{marker ardl_options}{...}
{title:Legacy option detail}

{phang}
{opt minl:ag1} will only consider models where {it:indepvars} have at least one lag, i.e.
the optimal lag selection iterations will skip models where one or more of these variables have a lag length of zero.
An implication of this is that you may not use option {opt minlag1} in conjunction with a lag
specification in option {opt lags} that sets the lag order of any variable to zero.

{pmore}
If in addition option {opt ec} is specified, the error-correction output of the long-run regressors
(other than the dependent variable) are expressed in terms of time t-1.
Without usage of option {opt minlag1}, the default of option {opt ec} is to write them in terms of time t.

{phang}
{opt bt:est} displays the F- and t-statistics in relation to the long-run relationship,
and displays critical values for these statistics tabulated in PSS.
Superseded by {help ardl_legacy##btest:estat btest}, which in turn has been superseded by
{help ardl_postestimation##ectest:estat ectest}.

{marker storedresults}{...}
{title:Saved results}

{pstd}
{cmd:ardl} saves the following as historical results in {cmd:e()}.
These items can be listed using the {opt all} option of {help return list}.

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:if option {opt ec} or {opt ec1} was used:}{p_end}
{synopt:{cmd:e(F_critval)}}PSS/Narayan critical values, F-statistic, bounds test for case {it:casenum}{p_end}
{synopt:{cmd:e(t_critval)}}PSS/Narayan critical values, t-statistic, bounds test for case {it:casenum}{p_end}


{marker btest}{...}{* * * * * * * * * * * * * * * * ESTAT BTEST * * * * * * * * * * * * * * * * * }
{bf:{dlgtab 0 0:estat btest}}

{phang}
{bf:legacy routine estat btest} {hline 2} legacy, out-of-date postestimation command for {help ardl} to perform the
bounds testing procedure for a levels relationship. It has been superseded by {help ardl_postestimation##ectest:estat ectest}.

{title:Syntax for estat btest}

{p 8 17 2}
{cmd:estat {ul:bt}est} {cmd:,} [ {cmd:n}[{cmd:(}{it:nobs}{cmd:)}] ]

{title:Description for estat btest}

{pstd}
{cmd:estat btest} implements the bounds test for a levels relationship proposed by {help ardl##PSS2001:PSS}.
The F-statistic and the t-statistic, which are dependent on the specification of the {help ardl##deterministiccomponents:model deterministics},
are displayed along with critical values of the associated non-standard distributions provided by PSS (large sample critical values) and {help ardl##N2005:NAR} (small sample critical values).

{pstd}
You must use one of the options {opt ec} or {opt ec1} in your {cmd:ardl} model for bounds test-related statistics to be available.

{pstd}
The t-statistic is only available for PSS tables.

{pstd}
To avoid pretesting problems, PSS suggest to apply the bounds test only to ARDL models without restrictions on the short-run coefficients (i.e. with a sufficiently high and common lag order for the regressors).
However, {cmd:estat btest} displays the F-statistic and t-statistic as well as the relevant critical values for any model specification.

{title:Options for estat btest}

{phang}
{cmd:n}[{cmd:(}{it:nobs}{cmd:)}] determines whether small sample critical values should be tabulated.
Argument {it:nobs} is optional.
If it is not specified, {cmd:estat btest} uses the sample size from the estimation results in memory.
Available sample size tabulations range from 30 to 80 with increments of 5.
If {it:nobs} does not exactly match one of these numbers, {cmd:ardl btest} picks the one that is closest.

{pmore}
If {opt n} or {opt n(nobs)} is not specified, or if {it:nobs} is larger or equal than 83, large sample critical values are displayed.

{marker storedresults}{...}
{title:Saved results of estat btest}

{pstd}
{cmd:estat btest} stores the following results for the PSS bounds test in {cmd:r()}:

{synoptset 15 tabbed}{...}
{p2col 5 15 19 2: Scalars}{p_end}
{synopt:{cmd:r(case)}}{it:casenum} for model deterministics{p_end}
{synopt:{cmd:r(F_pss)}}F-statistic, calculated according to {it:casenum}{p_end}
{synopt:{cmd:r(t_pss)}}t-statistic, calculated according to {it:casenum}{p_end}

{synoptset 15 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(F_critval)}}critical values, F-statistic, PSS bounds test for {it:casenum}{p_end}
{synopt:{cmd:r(t_critval)}}critical values, t-statistic, PSS bounds test for {it:casenum}{p_end}

