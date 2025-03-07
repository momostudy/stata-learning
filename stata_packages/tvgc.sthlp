{smcl}
{* *! version 1 03dec2020}{...}
{cmd:help tvgc}
{hline}

{title:Title}

{p2colset 5 14 16 2}{...}
{p2col :{hi:tvgc} {hline 2}}Time-Varying Granger Causality tests {p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 13 2}
{cmd:tvgc} {varlist} {ifin} [{cmd:,}
{opt trend}
{opt pre:fix(string)}
{opt p:(integer)}
{opt d:(integer)}
{opt win:dow(integer)}
{opt robust}
{opt matrix}
{opt boot(integer)}
{opt size:control(integer)}
{opt seed(integer)}
{cmdab:graph}
{cmdab:eps}
{cmdab:pdf}
{cmdab:notitle}
{cmdab:restab}]

{p 4 6 2}
You must {cmd:tsset} your data before using {cmd:tvgc}; see {manhelp tsset TS}.{p_end}
{p 4 6 2}
{it:varlist} contains the variables in the VAR or LA-VAR. {cmd:tvgc} tests whether the first variable in {it:varlist} is Granger-caused by the remaining variables.{p_end}
{p 4 6 2}
The {it:varlist} can contain time-series operators. The sample may not contain gaps.{p_end}
{p 4 6 2}
The {it:moremata} community-contributed package must be installed from the SSC Archive via {cmd:ssc install moremata}.

{title:Description}

{pstd}
{cmd:tvgc} implements the VAR-based time-varying Granger causality tests proposed by Shi, Phillips and Hurn (2018).
These are sequences of Wald statistics based on forward recursive estimation, rolling estimation, and recursive evolving estimation.
The command also supports estimation of these three sequences of Wald statistics in the context of a Lag-Augmented VAR (LA-VAR) model, as recommended to allow for the possibility of integrated variables;
see Shi, Hurn, Phillips (2020) and the references therein.

{pstd}
{cmd:tvgc} computes 90th, 95th, and 99th percentile bootstrap critical values following the bootstrap scheme advocated by Shi et al. (2018, 2020).

{title:Options}

{phang}
{opt trend} includes a linear trend in the VAR (LA-VAR) model.
		  
{phang}
{opt prefix} can be used to provide a `stub' with which variables created in {cmd: tvgc} will be named.
If this option is given, three Stata variables will be created for the appropriate range of dates:
{it:prefix_}forward_{it:varname}, {it:prefix_}rolling_{it:varname}, {it:prefix_}recursive_{it:varname}. These variables must not already exist in memory.
These variables record the Wald statistics that result from estimating the VAR or LA-VAR model using forward recursive, rolling and recursive evolving windows.
The {opt prefix} option must be specified to enable the {opt graph} option, which includes 90th and 95th percentile bootstrap critical values in the plots.

{phang}
{opt p} sets the number of lags in the VAR model. This can be determined using the Stata command {manhelp varsoc TS}.

{phang}
{opt d} sets the number of lags in the lag-augmented part of the VAR model. This option must be used when there are integrated variables in the VAR model. See Toda and Yamamoto (1995) and Dolado and L{c u:}tkepohl (1996). 

{phang}
{opt window} specifies the initial window width used in forward recursive, rolling and recursive evolving windows estimation. If not specified, 20% of the  number of available observations is used. 

{phang}
{opt robust} indicates that the Wald statistics should be computed using a heteroskedastic-robust specification of the variance-covariance matrix. 

{phang}
{opt boot} computes right-tail Monte Carlo critical values for 90, 95 and 99 percentiles based on the bootstrap advocated by Shi et al. (2018, 2020), using the specified number of replications. 
If not provided, 199 replications are computed. No fewer than 20 replications are computed.
The bootstrap critical values can be replicated if the option {opt seed} is used.

{phang}
{opt sizecontrol} specifies the number of periods included in the bootstrap critical values in order to control the size of the test. If not specified, 12 periods are used. 

{phang}
{opt seed} sets the seed for random number generation in the bootstrap results. 

{phang}
{opt noprint} specifies that detailed results are not to be printed.

{phang}
{opt graph}, if combined with {opt prefix},  specifies that the timeseries with the sequences of Wald statistics should be graphed along with their 90% and 95% bootstrapped critical values. The graphs can be saved from the Graph window.

{phang}
{opt eps} specifies that graphs are to be saved as .eps files as well as displayed in the Graph Window.

{phang}
{opt pdf} specifies that graphs are to be saved as .pdf files as well as displayed in the Graph Window.

{phang}
{opt notitle} specifies that graph titles are suppressed.

{phang}
{opt restab} writes the results of tests and their 95th and 99th percentile values to a LaTeX table
as restab.tex. The file will be replaced if it exists. When including this fragment in a LaTeX
document, the booktabs package is required.

{title:Example of use}

{pstd}
We illustrate the use of the {cmd:tvgc} command using monthly data for the US economy 
used in the Shi et al. (2018, 2020) articles. Their data, available online, was converted from MATLAB to Stata format and
 placed with the Boston College Economics Stata datasets.{p_end}

{pstd}
We being by loading the dataset using the command {cmd:bcuse}, available from the SSC Archive, and verifying that  it is a time series:{p_end}

{phang2}{bf:. {stata "bcuse MoneyIncome":bcuse MoneyIncome}}{p_end}

{phang2}{bf:. {stata "tsset":tsset}}{p_end}

{pstd}
We would like to test whether the logarithm of US industrial production (li) is Granger-caused 
by the log of the money base (lm1), the log of the price index (lp) and the three-month Treasury bill interest rate (r). 
The data span January 1959 to April 2014 and can be accessed from FRED with {cmd:freduse}. 
The three time-varying Granger causality statistics are computed using a specification with p=2 lags and d=1 lag augmented in the LA-VAR model, including a trend.											  
The sequence of tests for the forward recursive, rolling window, and recursive evolving procedures run with 72 observations for the minimum window size; hence, we use the option win=72.
The bootstrapped critical values are obtained with the default number of 199 repetitions and size controlled over a one-year period; this means that we can use the dafault value of sizecontrol which is 12.

{pstd}
The prefix option is used to save the constructed test statistics as additional variables. This example should run in about 3-4 minutes.{p_end}

{phang2}{bf:. {stata "tvgc li lm1 lp r, p(2) d(1) trend win(72) prefix(_WALD) graph":tvgc li lm1 lp r, p(2) d(1) trend win(72) prefix(_WALD) graph}}{p_end}

{pstd}
The new variables _WALDforward_lm1, _WALDrolling_lm1, and _WALDrecursive_lm1 replicate, to a great degree of precision, the sequences of statistics plotted in Figures 2a, 2b 2c of Shi et al. (2020).
The bootstrapped critical values are not replicable because of random variation.{p_end}

{pstd}
To replicate the sequences of statistics plotted in Figures 3a, 3c and 3e of Shi et al. (2020), we compute heteroskedasticity-robust version of the Wald statistics:{p_end}

{phang2}{bf:. {stata "tvgc li lm1 lp r, p(2) d(1) trend win(72) robust prefix(_WALDROB) graph":tvgc li lm1 lp r, p(2) d(1) trend win(72) robust prefix(_WALDROB) graph}}{p_end}

{pstd}
To replicate the sequences of statistics plotted in Figures 3b, 3d and 3f of Shi et al. (2020), size controlled over a five-year period. This example should run in about 15-18 minutes.{p_end}

{phang2}{bf:. {stata "tvgc li lm1 lp r, p(2) d(1) trend win(72) sizecontrol(60) prefix(_WALD5Y) graph":tvgc li lm1 lp r, p(2) d(1) trend win(72) sizecontrol(60) prefix(_WALD5Y) graph}}{p_end}


{title:Stored results}

{pstd}
{cmd:tvgc} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(T)}}number of observations available for test statistics{p_end}
{synopt:{cmd:r(p)}}maximum lag order in VAR/LA-VAR{p_end}
{synopt:{cmd:r(d)}}lag augmentation in test{p_end}
{synopt:{cmd:r(bootrepl)}}number of bootstrap replications{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(depvar)}}dependent variable{p_end}
{synopt:{cmd:r(rhsvars)}}RHS variable list{p_end}
{synopt:{cmd:r(cmdline)}}command line{p_end}
{synopt:{cmd:r(cmd)}}tvgc{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(gcres)}}matrix of test statistics{p_end}
{synopt:{cmd:r(gccv90)}}matrix of bootstrap critical values, 90th percentile {p_end}
{synopt:{cmd:r(gccv95)}}matrix of bootstrap critical values, 95th percentile {p_end}
{synopt:{cmd:r(gccv99)}}matrix of bootstrap critical values, 99th percentile {p_end}

{title:References}

{phang} 
Dolado, J. J., and H. L{c u:}tkepohl. 1996. Making Wald tests work for cointegrated VAR systems. Econometric Reviews 15: 369–386.

{phang}
Shi, S., S. Hurn, P.C.B. Phillips. 2020. Causal change detection in possibly integrated systems: Revisiting the money-income relationship. Journal of Financial Econometrics 18: 158–180.

{phang}
Shi, S., P.C.B. Phillips, S. Hurn.  2018. Change detection and the causal impact of the yield curve. Journal of Time Series Analysis 39: 966-987.

{phang}
Toda, H. Y., and T. Yamamoto. 1995. Statistical inference in vector autoregressions with possibly integrated Processes. Journal of Econometrics 66: 225–250.

{title:Authors}

{pstd}
Christopher F. Baum{break}
Boston College{break}
Chestnut Hill, MA USA{break}
baum@bc.edu{p_end}

{pstd}
Jes{c u'}s Otero{break}
Universidad del Rosario{break}
Bogot{c a'}, Colombia{break}
jesus.otero@urosario.edu.co{p_end}

{pstd}
Stan Hurn{break}
Queensland University of Technology{break}
Brisbane, Australia{break}
s.hurn@qut.edu.au{p_end}

{title:Also see}

{p 4 14 2}
Article: {it:Stata Journal}, volume 18, number 1: {browse "http://www.stata-journal.com/article.html?article=up0058":st0508_1},{break}
   {it:Stata Journal}, volume 17, number 4: {browse "http://www.stata-journal.com/article.html?article=st0508":st0508}{p_end}
