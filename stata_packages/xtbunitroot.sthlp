{smcl}
{* *! version 2.0 7 April 2022}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "Install command2" "ssc install command2"}{...}
{vieweralsosee "Help command2 (if installed)" "help command2"}{...}
{viewerjumpto "Syntax" "xturtb##syntax"}{...}
{viewerjumpto "Description" "xturtb##description"}{...}
{viewerjumpto "Options" "xturtb##options"}{...}
{viewerjumpto "Remarks" "xturtb##remarks"}{...}
{viewerjumpto "Examples" "xturtb##examples"}{...}
{title:Title}
{phang}
{bf:xtbunitroot} {hline 2} Unit root tests for panel data with structural breaks. The tests were developed by Karavias and Tzavalis (2014).


{marker syntax}{...}
{title:Syntax}
{p 8 17 2}
{cmdab:xtbunitroot}
{varname}
[{help if}]
[{help in}]
[,{cmdab:tr:end}
{cmdab:kn:own}({it:integer integer})
{cmdab:unk:nown}({it:numlist integer})
{cmdab:nor:mal}
{cmd:csd}
{cmd:het}
{cmdab:no:bootstrap}
{cmdab:l:evel}({it:integer})
{cmd:seed}({it:integer})
{cmdab:sho:windex}
]

{smcl}

{p 4 6 2}
where {varname} is the variable to be tested for non-stationarity. You must {cmd:xtset} your data before using {cmd:xtbunitroot}; see {helpb xtset:[XT] xtset}. 
If no option is specified, the default will be the model with a single break in the mean at an unknown date, 5% level of test, and seed 123: {cmd:xtbunitroot} {varname}{cmd:,} {cmdab:unk:nown}(1 100) {cmdab:l:evel}(5) {cmd:seed}(123).
{varname} can contain time-series operators.{p_end}

{smcl}

{marker description}{...}
{title:Description}
{pstd}

{pstd}
 {cmd:xtbunitroot} performs panel unit root tests allowing for structural breaks, using the methodology developed by Karavias and Tzavalis (2014). 
These tests allow for one or two structural breaks in the deterministic components of the series and can be used in both fixed-T and large-T settings, where T is the number of time series observations in the sample.  

{pstd}
The null hypothesis is that all series in the panel are unit root processes. The alternative is that some or all of the series are stationary, with breaks in the deterministic specification (intercepts and trends). 
The break dates are common for all units in the panel, but the magnitude of the breaks are unit-specific.

{pstd} 
Two models of deterministic components are considered. The first model contains fixed effects only (intercepts) and the second model includes interecepts and linear trends. The dates of the breaks can be known or unknown. 
When the dates of the breaks are unknown, a bootstrap procedure is used to calculate the critical and p-values of the test.

{pstd} 
The errors can be nonnormal, cross-sectionally dependent and cross-sectionally heteroskedastic.

{pstd}
The panel can be unbalanced.

{marker options}{...}
{title:Options}
{dlgtab:Model}

{phang}
{opt tr:end} specifies that the deterministic component of the model includes individual intercepts (means) and individual linear trends. The common breaks affect both intercepts and trends. 
Breaks in consecutive dates are not allowed in this model. The breaks can be in dates from 3 to T-2, while in the model with intercepts the breaks can take place from 2 up to T-1. 


{dlgtab:Break}

{pstd}
{p_end}
{phang}
{opt kn:own(break1 break2)} specifies the number and places of breaks. This option implements the case when the dates of the breaks are known. 
The first input specifies the location of the first break and the second input specifies the location of the second break. If only one break is assumed {cmdab:kn:own(#)} can be used. 
The inputs should be in terms of time ordering (from 1 to T), instead of using dates i.e. 1995 or 2020. The break dates should be in order. 
For example, {cmdab:kn:own(5)} means the break occurs in period 5 and {cmdab:kn:own(3 7)} means first break occurs in period 3 and second break occurs in period 7.

{pstd}
{p_end}
{phang}
{opt unk:nown(numbreaks numboot)} specifies the number of breaks and the number of bootstrap replications. This option is used when the dates of the breaks are unknown to the researcher. 
The number of bootstrap replications can be omitted. The option {cmdab:unk:nown(2)} states that there are 2 unknown breaks and the critical and p-values will be calculated based on the default number of bootstrap replication which is set to 100.

{pstd}
{p_end}
{phang}
{opt sho:windex} specifies that the estimated break date is reported as a time index. For example, an estimated break point at the 9th observation will be reported as 9 instead of 2021q4.


{dlgtab:Robust}

{pstd}
{p_end}
{phang}
{opt nor:mal}  specifies that the errors are normally distributed.

{pstd}
{p_end}
{phang}
{opt csd}  subtracts the cross-section averages for each time period and applies the tests in the demeaned series. 

{pstd}
{p_end}
{phang}
{opt het}  specifies that the errors are cross-sectionally heteroskedastic. If both {cmd:het} and {cmdab:nor:mal} are specified, the results will be the same as in the case that only {cmdab:nor:mal} is used,
because if the errors are normal, then heteroskedastic variances drop out.

{pstd}
{p_end}
{phang}
{opt no:bootstrap} prevents the command from running the bootstrap. The bootstrap is necessary for calculating critical values and p-values for the test when the dates of the breaks are unknown. 
However, if the dataset is very large then the bootstrap can be time consuming. This option stops the bootstrap but returns the minZ statistic and the estimated break dates.
The minZ statistic can then be compared to the approximate critical values which appear in Table 1 of Karavias and Tzavalis (2014), which is reported in the command output. 
This option can be used only together with the option {cmdab:nor:mal} because the available critical values are for normally distributed errors. 

{pstd}
{p_end}
{phang}
{opt l:evel} specifies the level of the test used. 5% level is the default and all integers between 1 and 99 are applicable. For example, {cmdab:l:evel}(10) sets the level of the one-sided null hypothesis to 10%.

{pstd}
{p_end}
{phang}
{opt seed} specifies the seed used in the bootstrap process for the case of unknown breaks. The default is {cmd:seed}(123). Seed is important for reproducing bootstrap-based results.


{marker examples}{...}
{title:Examples}

{phang} The dataset ``xtbunitroot_example.dta'' used in this example is downloadable from
{browse "https://sites.google.com/site/yianniskaravias/files/xtbunitroot"}.

{pstd}xtset the data{p_end}
{phang2}{cmd:xtset fed_rssd time} 

{pstd}Testing the null hypothesis of a random walk against the alternative of stationarity around breaking means, when it is known that the break in the intercepts happened in the 7th time period.
This date corresponds to the quarter ending on March 31, 2020.{p_end}
{phang2}{cmd:xtbunitroot roa, known(7)}

{pstd}Same as above but now we allow for cross-section dependence and cross-section heteroskedasticity. {p_end}
{phang2}{cmd:xtbunitroot roa, known(7) csd het}

{pstd}Two known breaks at dates 7 and 8, that is, in the quarters ending on on March 31, 2020 and on June 30, 2020.{p_end}
{phang2}{cmd:xtbunitroot lev, known(7 8) csd het}

{pstd}Testing the null hypothesis of a random walk with drift against the alternative of trend-stationarity around breaking means and linear trends, 
when it is known that the break happened in the 7th time period, which is the quarter ending on March 31, 2020.{p_end}
{phang2}{cmd:xtbunitroot tassets, known(7) trend}

{pstd}Testing the null hypothesis of a random walk against the alternative of stationarity around breaking means, when the date of the break is unknown.{p_end}
{phang2}{cmd:xtbunitroot roa, unknown(1) csd het}

{pstd}Testing the null hypothesis of a random walk against the alternative of stationarity around breaking means, when the date of the break is unknown. The bootstrap replications are set to 50.{p_end}
{phang2}{cmd:xtbunitroot roa, unknown(1 50) csd het}

{pstd}Testing the null hypothesis of a random walk against the alternative of stationarity around breaking means, when the dates of the breaks are unknown.{p_end}
{phang2}{cmd:xtbunitroot nii, unknown(2) csd het}
{p_end}

{title:Stored results}
{pstd}
{cmd:xtbunitroot} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N_g)}}number of cross sectional units{p_end}
{synopt:{cmd:r(T)}}number of time periods{p_end}
{synopt:{cmd:r(N)}}number of total observations{p_end}
{synopt:{cmd:r(breaks)}}number of breaks{p_end}
{synopt:{cmd:r(break1)}}time index of the first break{p_end}
{synopt:{cmd:r(break2)}}time index of the second break{p_end}
{synopt:{cmd:r(seed)}}seed{p_end}
{synopt:{cmd:r(Z)}}the Z or minZ statistic{p_end}
{synopt:{cmd:r(pvalue)}}p-value for the Z or minZ statistic{p_end}
{synopt:{cmd:r(cv)}}asymptotic or bootstrap critical value{p_end}
{synopt:{cmd:r(boot)}}number of bootstrap replications{p_end}
{synopt:{cmd:r(fihat)}}estimate of autoregressive parameter{p_end}
{synopt:{cmd:r(khat)}}estimate of k{p_end}
{synopt:{cmd:r(shat)}}estimate of error variance{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(idvar)}}name of panel id variable{p_end}
{synopt:{cmd:r(tvar)}}name of panel time variable{p_end}
{synopt:{cmd:r(varname)}}name of tested variable{p_end}
{synopt:{cmd:r(model)}}type of model: constant or constant and trend{p_end}
{synopt:{cmd:r(date1)}}date of the first break{p_end}
{synopt:{cmd:r(date2)}}date of the second break{p_end}
{synopt:{cmd:r(avert)}}average number of time periods{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(kui)}}the individual k for heteroskedastic errors{p_end}
{synopt:{cmd:r(sigmai)}}the individual variances for heteroskedastic errors {p_end}


{title:References}
{p}
{p_end}
{pstd}

Chen, P., Karavias, Y., and Tzavalis, E., 2021. Panel Unit Root Tests with Structural Breaks. Submitted to the Stata Journal.

Karavias, Y., and Tzavalis, E., 2014. Testing for unit roots in short panels allowing for a structural break. Computational Statistics & Data Analysis 76, 391–407. {browse "https://doi.org/10.1016/j.csda.2012.10.014"}


{title:Acknowledgements}
{p}
{p_end}
{pstd}
{cmd:xtbunitroot} is not an official Stata command. It is a free contribution to the research community. Please cite Chen et al (2021) and Karavias and Tzavalis (2014), as listed in the references above.


{title:Authors}
{p}
{p_end}

{pstd}
Pengyu Chen{break}
University of Birmingham{break}
Birmingham, UK{break}
{browse "mailto:cpy1416@outlook.com?subject=Question/remark about -xtbunitroot-&cc=cpy1416@outlook.com":cpy1416@outlook.com}

{pstd}
Yiannis Karavias{break}
University of Birmingham{break}
Birmingham, UK{break}
{browse "mailto:i.Karavias@bham.ac.uk?subject=Question/remark about -xtbunitroot-&cc=i.Karavias@bham.ac.uk":i.Karavias@bham.ac.uk}


