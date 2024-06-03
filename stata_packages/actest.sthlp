{smcl}
{* 16Mar2014}{...}
{hline}
help for {hi:actest}
{hline}

{title:Perform Cumby-Huizinga general test for autocorrelation in time series}

{p 8 14}{cmd:actest}
[
{it:varname}
]
[if]
[in]
[ {cmd:,} 
{cmdab:lag:s(}{it:numlist}{cmd:)}
{cmd:strictexog}
{cmd:q0}
{cmd:bp}
{cmd:small}
{cmd:robust}
{cmd:cluster(}{it:varlist}{cmd:)}
{cmd:kernel(}{it:string}{cmd:)}
{cmd:bw(}{it:#}{cmd:)}
{cmd:psd(}{it:string}{cmd:)}
]

{p}{cmd:actest} may be used on the univariate time series specified in {it:varname}
or after {help regress}, {help newey}, {help ivreg}, {help ivregress}, {help ivreg2} and {help newey2}.
{cmd:actest} is for use with time-series data.  You must {cmd:tsset} your data before 
using {cmd:actest}; see {help tsset}. You may apply {cmd:actest} to a panel dataset that has been defined by {help tsset} or
{help xtset}.{p_end}


{title:Description}

{p}{cmd:actest} performs the general specification test of serial correlation in a time series proposed by Cumby and Huizinga (C-H, 1990, 1992).  
It can be applied to a univariate time series or as a postestimation command after OLS or instrumental variables (IV) estimation.
The null hypothesis of the test is that the time series is a 
moving average of known order q, which could be zero or a positive value. The test considers the general alternative that 
autocorrelations of the time series are nonzero at lags greater than q.
The test is general enough to test the hypothesis that the time series has
no serial correlation (q=0) or the null hypothesis that serial correlation in 
the time series exists, but dies out at a known finite lag (q>0).{p_end}

{p} The test is especially attractive because it can be used in three frequently 
encountered cases where alternatives such as the Box-Pierce/Ljung-Box (B-P-L-B) 'portmanteau' or {it:Q} test ({help wntestq}), Durbin's h test ({help regress postestimationts##durbinalt:estat durbinalt})
and the Breusch-Godfrey (B-G) test ({help regress postestimationts##bgodfrey:estat bgodfrey}) are not applicable. {p_end}

{p} The B-P-L-B test may be applied to the residuals of a time series regression (or indeed to any time series) to test for autocorrelation at lag orders 1...p, with the null hypothesis that all p autocorrelations are zero. 
In a regression context, the maintained hypothesis is that the regressors are strictly exogenous and the time series is homoskedastic.{p_end}

{p} The B-G test, of which Durbin's h test is a special case, relaxes the assumption of strictly exogenous regressors, allowing predeterminedness or weak exogeneity in the regressors. 
It may be applied to any time series by regressing that series on a constant.
Like the portmanteau test, the B-G test may be used to test for autocorrelation at lag orders 1...p, with the null hypothesis that all p autocorrelations are zero.{p_end}

{p} These tests are not appropriate in several circumstances. The presence of conditional heteroskedasticity in the time series violates the assumptions underlying the portmanteau and B-G tests. 
Endogenous regressors render each of these tests invalid, preventing their use in the context of an instrumental variables regression. 
A third case involves the overlapping data commonly encountered
in financial markets where the observation interval is shorter than the holding
period. {p_end}

{p} One of the major advantages of the C-H framework is that it can be used to test for autocorrelation at lag orders (q+1)...(q+s) under the null hypothesis that the series being tested is MA(q). 
For instance, in the case of overlapping data, such as the three-month Treasury bill rate observed at a monthly frequency, the error process is MA(2) by construction, and cannot be i.i.d. 
In applying the C-H test, we may allow for q=2 and test for autocorrelation at higher than 2nd order. 
In general, the C-H test, when applied to lag order m, applies the null hypothesis that the time series is MA(q) where q=m-1. {p_end}

{p} The C-H test may also be applied to realistically test for autocorrelation at a specific lag order. 
Although it was originally developed for a univariate time-series setting, it may also be applied in the fixed-T large-N panel data context. 
The C-H test is then essentially the same test as the Arellano and Bond (1991) test for autocorrelation, implemented for Stata by Roodman (2009) as {help abar}. {p_end}

{p} The options available in {cmd:actest} permit the user to conduct, as special cases of the C-H test, a B-P-L-B {it:Q} test, a B-G test, or an A-B test, as well as tests appropriate for non-i.i.d. time series.{p_end}

{p} {cmd:actest} may be used as a standalone command by specifying a {it:varname}, or it may be used as a postestimation command after several regression commands. In the latter case, {cmd:actest} operates on the residuals of the prior regression.{p_end}

{title:Options}

{p 0 4}{cmd:lags(}{it:numlist}{cmd:)} specifies the lag orders to be tested. 
If a single value {it:m} greater than 1 is provided, tests are conducted for lag orders 1...{it:m}
for two hypotheses: that all autocorrelations in the range 1...{it:m} are zero, and that the autocorrelation at each lag order is zero, allowing for nonzero autocorrelations at lower lag orders. 
If a numlist {it:m n} is given, the tests are conducted for lag orders {it:m} through {it:n}. If a numlist {it:m m} is given, the test is conducted for that lag order only. 
If the option is not specified, a test for first-order autocorrelation is performed. {p_end}

{p 0 4}{cmd:strictexog} specifies that the regressors in the prior regression may be considered strictly exogenous, as is assumed in the portmanteau test.{p_end}

{p 0 4}{cmd:q0} specifies that tests of autocorrelation at specific lag orders are to be conducted under the null hypothesis of no autocorrelation at any lag order (q=0), as is assumed in the portmanteau and B-G tests.{p_end}

{p 0 4}{cmd:bp} specifies that the Box-Pierce test, in its original form, is to be performed. {p_end}

{p 0 4}{cmd:small} specifies that the Ljung-Box test, which incorporates a small-sample correction for the original Box-Pierce test, is to be performed.{p_end}

{p 0 4}{cmd:robust} specifies that the time series being tested may exhibit conditional heteroskedasticity, so that a robust form of the C-H test is to be performed.{p_end}

{p 0 4}{cmd:cluster(}{it:varlist}{cmd:)} specifies that the time series being tested may exhibit both within-cluster arbitrary correlation and between-cluster heteroskedasticity, as defined by the clustering variable(s). 
As in {help ivreg2}, two-way clustering is supported. {p_end}

{p 0 4}{cmd:kernel(}{it:string}{cmd:)} specifies that the time series being tested may exhibit arbitrary autocorrelation, so that an autocorrelation-robust VCE should be computed, using the specified kernel. 
This option should rarely be used, as the default for {cmd:actest}, the truncated kernel with bandwidth={it:q}, is the most appropriate for the C-H test's
null hypothesis of MA(q) (Hayashi 2000, p. 408).
The choices of kernel available are those defined in {help ivreg2}.
Note that in line with {help ivreg2}, HAC estimates require the use of the {cmd:robust} option as well.
{p_end}

{p 0 4}{cmd:bw(}{it:#}{cmd:)} specifies that the time series being tested may exhibit arbitrary autocorrelation, so that an autocorrelation-robust VCE should be computed, using the specified bandwidth parameter. 
This option should rarely be used, as the default for {cmd:actest}, the truncated kernel with bandwidth={it:q}, is the most appropriate for the C-H test
null hypothesis of MA(q) (Hayashi 2000, p. 408).
Note that in line with {help ivreg2}, HAC estimates require the use of the {cmd:robust} option as well.{p_end}

{p 0 4}{cmd:psd(}{it:string}{cmd:)} specifies the method to be used to deal with a non-positive semidefinite (PSD) VCE. 
Some kernels, including the default truncated kernel, are not guaranteed to produce a PSD VCE in finite samples. 
The default is {cmd:psd(}{it:psda}{cmd:)}, where negative eigenvalues will be replaced with their absolute values, per Stock and Watson (2008). 
With the option {cmd:psd(}{it:psd0}{cmd:)}, negative eigenvalues will be replaced with zeros.
Note that {cmd:actest} will indicate in the test output whether a test statistic uses such an adjustment.{p_end}
 

{title:Saved results}

{p}{cmd:actest} saves the minimum and maximum lag orders tested in {cmd:r(minlag), r(maxlag}). 
The matrix {cmd:r(results)} contains, in each row, the results up to that lag order (in columns 3-4) and the results for that lag order (in columns 6-7). 
See {cmd:return list}.{p_end}


{title:Examples}

{p} Comparison with B-P-L-B {it:Q} test, applied to a time series{p_end}  
{p 8 12}{stata "webuse air2" : . webuse air2 }{p_end}
{p 8 12}{stata "wntestq air, lags(1)" : . wntestq air, lags(1)}{p_end}
{p 8 12}{stata "actest air, lags(1) bp small" : . actest air, lags(1) bp small}{p_end}

{p 8 12}{stata "wntestq air, lags(4)" : . wntestq air, lags(4)}{p_end}
{p 8 12}{stata "actest air, lags(4) bp small" : . actest air, lags(4) bp small}{p_end}

{p 8 12}{stata "wntestq air in 1/72, lags(4)" : . wntestq air in 1/72, lags(4)}{p_end}
{p 8 12}{stata "actest air in 1/72, lags(4) bp small" : . actest air in 1/72, lags(4) bp small}{p_end}

{p 8 12}{stata "wntestq air if t>80, lags(4)" : . wntestq air if t>80, lags(4)}{p_end}
{p 8 12}{stata "actest air if t>80, lags(4) bp small" : . actest air if t>80, lags(4) bp small}{p_end}

{p} Comparison with B-P-L-B {it:Q} test: strictly exogenous regressors {p_end}
{p 8 12}{stata "qui reg air time" : . qui reg air time}{p_end}
{p 8 12}{stata "qui predict double airhat, residual" : . qui predict double airhat, residual}{p_end}
{p 8 12}{stata "wntestq airhat, lags(4)" : . wntestq airhat, lags(4)}{p_end}
{p 8 12}{stata "actest airhat, lags(4) bp small strict" : . actest airhat, lags(4) bp small strict}{p_end}

{p} Comparison with Breusch-Godfrey test: predetermined regressors {p_end}
{p 8 12}{stata "qui reg air" : . qui reg air}{p_end}
{p 8 12}{stata "estat bgodfrey, lags(1)" : . estat bgodfrey, lags(1)}{p_end}
{p 8 12}{stata "actest, lags(1)" : . actest, lags(1)}{p_end}

{p 8 12}{stata "estat bgodfrey, lags(4)" : . estat bgodfrey, lags(4)}{p_end}
{p 8 12}{stata "actest, lags(4)" : . actest, lags(4)}{p_end}
{p 8 12}{stata "actest, lags(4) robust" : . actest, lags(4) robust}{p_end}

{p 8 12}{stata "qui reg air L(1/2).air" : . qui reg air L(1/2).air}{p_end}
{p 8 12}{stata "estat bgodfrey, lags(4)" : . estat bgodfrey, lags(4)}{p_end}
{p 8 12}{stata "actest, lags(4)" : . actest, lags(4)}{p_end}
{p 8 12}{stata "actest, lags(3 4)" : . actest, lags(3 4)}{p_end}

{p 8 12}{stata "webuse lutkepohl" : . webuse lutkepohl }{p_end}
{p 8 12}{stata "qui reg investment L(1/4).income" : . qui reg investment L(1/4).income}{p_end}
{p 8 12}{stata "estat bgodfrey, lags(1/8)" : . estat bgodfrey, lags(1/8)}{p_end}
{p 8 12}{stata "actest, lags(8)" : . actest, lags(8)}{p_end}

{p} Application in an IV context {p_end}
{p 8 12}{stata "qui ivreg2 investment (income=L(1/2).income)" : . qui ivreg2 investment (income=L(1/2).income)}{p_end}
{p 8 12}{stata "actest, lags(3)" : . actest, lags(3)}{p_end}
{p 8 12}{stata "actest, lags(3) robust" : . actest, lags(3) robust}{p_end}

{p} Comparison with Arellano-Bond {it:abar} test (reported as N(0,1) vs. {it:actest}'s chi-sq(1)) {p_end}
{p 8 12}{stata "qui reg investment income" : . qui reg investment income}{p_end}
{p 8 12}{stata "abar, lags(2)" : . abar, lags(2)}{p_end}
{p 8 12}{stata "di r(ar1)^2 * e(N)/e(df_r)" : . di r(ar1)^2 * e(N)/e(df_r)}{p_end}
{p 8 12}{stata "di r(ar2)^2 * e(N)/e(df_r)" : . di r(ar2)^2 * e(N)/e(df_r)}{p_end}
{p 8 12}{stata "actest, lags(2) q0" : . actest, lags(2) q0}{p_end}

{p} Application with HAC VCE {p_end}
{p 8 12}{stata "qui ivreg2 investment income, robust kernel(bartlett) bw(5)" : . qui ivreg2 investment income, robust kernel(bartlett) bw(5)}{p_end}
{p 8 12}{stata "actest, lags(4) q0 robust kernel(bartlett) bw(5)" : . actest, lags(4) q0 robust kernel(bartlett) bw(5)}{p_end}

{p} Application to panel data, pooled OLS estimates, and comparison to {it:abar} test{p_end}
{p 8 12}{stata "webuse abdata" : . webuse abdata }{p_end}
{p 8 12}{stata "qui reg n w k, clu(id)" : . qui reg n w k, clu(id)}{p_end}
{p 8 12}{stata "abar, lags(2)" : . abar, lags(2)}{p_end}
{p 8 12}{stata "di r(ar1)^2" : . di r(ar1)^2}{p_end}
{p 8 12}{stata "di r(ar2)^2" : . di r(ar2)^2}{p_end}
{p 8 12}{stata "actest, lags(2) clu(id)" : . actest, lags(2) clu(id)}{p_end}

{p} Application to panel data, IV-GMM estimates {p_end}
{p 8 12}{stata "qui ivreg2 D.n (D.w D.k = D(1/2).(w k)), noco gmm2s clu(id)" : . qui ivreg2 D.n (D.w D.k = D(1/2).(w k)), noco gmm2s clu(id)}{p_end}
{p 8 12}{stata "actest, lags(3) clu(id)" : . actest, lags(3) clu(id)}{p_end}


{title:References}

{p 0 4}Arellano, M., Bond, S., 1991. Some tests of specification for panel data: Monte Carlo evidence and an application to employment equations. Review of Economic Studies, 58:2, 277-297.

{p 0 4}Baum, C. F., Schaffer, M. E., Stillman, S., 2003. Instrumental variables and GMM:
Estimation and testing. Stata Journal, 3:1, 1-31.
{browse "http://ideas.repec.org/a/tsj/stataj/v3y2003i1p1-31.html":http://ideas.repec.org/a/tsj/stataj/v3y2003i1p1-31.html}.

{p 0 4}Baum, C. F., Schaffer, M. E., and Stillman, S. 2007. Enhanced routines for instrumental variables/GMM estimation and testing. Stata Journal, 7:4, 465-506.
{browse "http://ideas.repec.org/a/tsj/stataj/v7y2007i4p465-506.html":http://ideas.repec.org/a/tsj/stataj/v7y2007i4p465-506.html}.

{p 0 4}Cumby, R. E. and Huizinga, J.  1990. Testing the autocorrelation structure
of disturbances in ordinary least squares and instrumental variables regressions. 
{browse "http://www.nber.org/papers/t0092":NBER Technical Working Paper No. 92.}

{p 0 4}Cumby, R. E. and Huizinga, J.  1992. Testing the autocorrelation structure
of disturbances in ordinary least squares and instrumental variables regressions. 
Econometrica, 60:1, 185-195.

{p 0 4}Hayashi, F. 2000. Econometrics. Princeton University Press.

{p 0 4}Roodman, D. M. 2009. How to do xtabond2: An introduction to difference and system GMM in Stata. Stata Journal, 9:1, 86-136.
{browse "http://ideas.repec.org/a/tsj/stataj/v9y2009i1p86-136.html":http://ideas.repec.org/a/tsj/stataj/v9y2009i1p86-136.html}.

{title:Citation of actest}

{p}{cmd:actest} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Baum, C.F., Schaffer, M.E.  2013.
actest: Stata module to perform Cumby-Huizinga general test for autocorrelation in time series.
{browse "http://ideas.repec.org/c/boc/bocode/s457668.html":http://ideas.repec.org/c/boc/bocode/s457668.html}{p_end}


{title:Authors}

{p 0 4}Christopher F Baum, Boston College, USA{p_end}
{p 0 4}baum@bc.edu{p_end}

{p 0 4}Mark E. Schaffer, Heriot-Watt University, UK{p_end}
{p 0 4}m.e.schaffer@hw.ac.uk{p_end}


{title:Also see}

{p 1 14}Manual:  {hi:[R] regression postestimation}{p_end}
{p 0 19}On-line:  help for {help ivreg2}, {help ivhettest}, {help abar} (if installed)
{p_end}
