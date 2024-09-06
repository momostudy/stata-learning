{smcl}
{* *! version 1.0  07mar2013}{...}
{vieweralsosee "[R] esize" "mansection R esize"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] esize" "help esize"}{...}
{vieweralsosee "[R] tabi" "help tabi"}{...}
{viewerjumpto "Syntax" "stddiff##syntax"}{...}
{viewerjumpto "Description" "stddiff##description"}{...}
{viewerjumpto "Options" "stddiff##options"}{...}
{viewerjumpto "Examples" "stddiff##examples"}{...}
{viewerjumpto "Stored results" "stddiff##results"}{...}
{viewerjumpto "References" "stddiff##references"}{...}

{title:Title}

{phang}
{bf:stddiff} {hline 2} Calculate standardized differences between groups for continuous and categorical variables


{marker syntax}{...}
{title:Syntax}

{pstd}
Standardized differences of variables in {it:varlist}

{p 8 17 2}
{cmd:stddiff}
[{varlist}]
{ifin},
{opth by:(varlist:groupvar)}
[{it:options}]


{pstd}
Immediate form of standardized differences for continuous variables

{p 8 17 2}
{cmd:stddiffi}
{it:[#obs1] #mean1 #sd1 [#obs2] #mean2 #sd2}
,
[{it:options}]

	
{pstd}
Immediate form of standardized differences for categorical variables

{p 8 17 2}
{cmd:stddiffi}
{it:#11 #12 \ #21 #22  [\ ...]}


{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt by}}specifices the grouping variable. {opt by} must be a two level variable and is not optional when {it:varlist} is specified.{p_end}
{synopt:{opt coh:ensd}}calculates Cohen's d, adjusting for sample size.{p_end}
{synopt:{opt hed:gesg}}calculates Hedges's g.{p_end}
{synopt:{opt abs}}calculates absolute values of the standardized difference.{p_end}
{synoptline}
{p2colreset}{...}


{marker description}{...}
{title:Description}

{pstd}
{cmd:stddiff} calculates the standardized difference between two groups for both continuous and categorical variables. Standardized difference estimates are increasingly used to compare groups in clinical trials 
and observational studies, in preference over p-values. Some have proposed that an absolute standardized difference of 0.10 or more indicates that covariates are imbalanced between groups (see {help stddiff##Austin:Austin} 2001).

{pstd}
{cmd:stddiff} calculaates standardized differences using the method of {help stddiff##Yang:Yange and Dalton} for both continuous and categorical variables. Categorical variables must be entered using Stata's factor variable notation (e.g., i.var)
. If the options {opt cohensd} or {opt hedgesg} are specified, {cmd:stddif} is a wrapper for {cmd:esize twosample}. See {manlink R esize}.

{pstd}
{cmd:stddiffi} is an immediate form of {cmd:stddiff}. If 4 numbers are entered, {cmd:stddiffi} calculates the standard difference using the formula (mean1-mean2)/((sd1^2+sd2^2)/2).
If 6 numbers are entered, {cmd:stddiffi} calculates the standarized difference using the formulas specified in {cmd:esize}. One of {opt cohensd} or {opt hedgesg} must be specifed. 
If both are specified, only Hedge's g is calculated. 
For categorical variables, numbers should be entered as they are for {help tabi}, with rows separated by a backslash (\). Each row must have exactly two columns.

{marker options}{...}
{title:Options}

{phang}
{opt cohensd} calculates Cohen's d using the formula specified by { help esize}, which adjusts for sample size.

{phang}
{opt hedgesg} calculates Heges's d using the formula specified by { help esize}, which adjusts for a bias in estimating Cohen's d. If both {opt cohensd} and {opt hedgesg} are specified, only {opt hedgesg} will be calculated.

{phang}
{opt abs} reports absolute values of the standardized difference. 

{marker examples}{...}
{title:Examples}

Setup
{phang}{cmd:. webuse depression}{p_end}

Standard difference for a continuos variable
{phang}{cmd:. stddiff age, by(sex)}{p_end}

Standard difference for a categorical variable
{phang}{cmd:. stddiff i.race, by(sex)}{p_end}

Absolute standard differences for multiple variables using Hedge's g for continuous variables
{phang}{cmd:. stddiff age i.race q*, by(sex) hedgesg abs}{p_end}

Immediate form of stddiffi using means and standard deviations
{phang}{cmd:. stddiffi  36.37 9.46 36.97 9.53}{p_end}

Immediate form of stddiffi using number of observations, means, and standard deviations calculating Cohen's d
{phang}{cmd:. stddiffi 712 36.37 9.46 288 36.97 9.53, cohensd}{p_end}

Immediate form of stddiffi for a categorical variable
{phang}{cmd:. stddiffi 88 45 \ 259 95 \ 365 148}{p_end}

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:stddiff} stores the following in
{cmd:r()}:

{synoptset 16 tabbed}{...}
{synopt:{cmd:r(stddiff)}}Matrix of standardized differences{p_end}
{synopt:{cmd:r(output)}}Matrix containing results tables (for expoort to excel or other further editing){p_end}


{pstd}
{cmd:stddiffi} stores the following in
{cmd:r()}:

{synoptset 16 tabbed}{...}
{synopt:{cmd:r(std_diff)}}Standarized difference{p_end}

{pstd}
{cmd:stddiffi} with categorical variables also stores the following in
{cmd:r()}:

{synoptset 16 tabbed}{...}
{synopt:{cmd:r(table)}}Matrix containing input table{p_end}


{marker references}{...}
{title:References}

{marker Yang}{...}
{phang}
Yang DS, Dalton JE.
A Unified Approach to Measuring the Effect Size Between Two Groups Using
SAS. SAS Global Forum 2012. Paper 335 {view "https://www.lerner.ccf.org/qhs/software/lib/stddiff.pdf"}.

{marker Austin}{...}
{phang}
Austin PC.
Balance diagnostics for comparing the distribution of baseline covariates between treatment groups in propensity-score matched samples.
Stat Med. 2009 Nov 10; 28(25): 3083–3107.  doi:10.1002/sim.3697
