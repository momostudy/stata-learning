{smcl}
{hline}
help {hi:bdiff}{right: 24Nov2020, {browse "https://www.lianxh.cn/news/051e3a01cdb19.html":blog}}
{hline}

{title:Title}

{p2colset 5 14 22 2}{...}
{p2col :{hi:bdiff} {hline 2}}Bootstrap and Permutaion tests for difference in coffiecients between two groups{p_end}
{p2colreset}{...}

{title:Syntax}

{p 8 14 4}{cmd:bdiff,} 
{cmdab:g:roup:(}{it:groupvar}{cmd:)}
{cmdab:m:odel:(}{it:string}{cmd:)}
[{it:options}]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Main (must be specified)}
{synopt :{opt g:roup(varname)}}specify a dummy variable 
to tag the sample into two groups{p_end}
{synopt :{opt m:odel(string)}}define the regression model, e.g., model(reg y x){p_end}

{syntab:Other options}
{synopt :{opt r:eps(#)}}set number of repetitions to {it:#}. Defult is 100.{p_end}
{synopt :{opt seed(#)}}set random-number seed to {it:#}{p_end}
{synopt :{opt bs:ample}}use bootstrap sample (sampling with replacement) to perform Fisher's Permuation test. 
In default, {help bdiff} uses the original sample to perform the Fisher's Permuation test.{p_end}
{synopt :{opt sur:test}}perform SUR test, see {help suest}.{p_end}

{syntab:Reporting}
{synopt :{opt f:irst}}report the coeffiencts difference and empirical p-value 
for the first regressor in the model{p_end}
{synopt :{opt g:ap}}to add extra spacing between rows{p_end}
{synopt :{opt no:dots}}suppress replication dots{p_end}
{synopt :{opt d:ec(#)}}to display # decimal places for all statistics. Defult is 3.{p_end}
{synopt :{opt bd:ec(#)}}to display # decimal places for just the coefficient. Defult is 3.{p_end}
{synopt :{opt pd:ec(#)}}to display # decimal places for just the empirical p-value. Defult is 3.{p_end}
{synopt :{opt det:ail}}report the regression results for both groups{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}{it:weights} are not allowed in {it:model}().{p_end}


{title:Description}

{dlgtab:Introduction}

{p 4 4 2}
A major focus of empirical literature is the comparison of coeffiencts of a particular variable(s)
(such as "investment-liquidity sensitivities" in corporate finance) across different groups of firms. 
However, traditional tests designed to detect differences in coefficients are not 
appropriate because the error terms likely violate the required assumptions.

{p 4 4 2}
Traditional tests are generally designed for testing changes in parameters across time series data, 
where it may sometimes be reasonable to assume no heteroscedasticity 
in the resulting residuals. Panel data and cross-sectional data, 
are likely violate the required assumptions. 
For example, the Chow test requires that the disturbance variance be the same for both regressions, 
while the standard Wald test requires independence of the error terms. 
These conditions are unlikely to be satisfied by panel data residuals.

{p 4 4 2}
As a result, conclusions regarding the existence of differences in 
investment-liquidity sensitivities across groups have been largely based on observing differences 
in magnitude and level of significance of the coefficient on 
the liquidity variable in regression estimates. 
{help bdiff} uses simulation evidence to determine the significance of observed differences in coefficient estimates (Cleary, 1999; Lian and Cheng, 2007).

{p 4 4 2}
{help bdiff} perform several tests 
(Fisher's Permuation test; Seemingly Unrelated Regression test, see {help suest})
to determine the significance of 
observed differences in coefficient estimates between two groups. 

{p 4 4 2}
By default, {help bdiff} performs traditional Fisher's permutation test (sampling without replacement) of differences in coefficient estimates between two groups
It uses simulation evidence to determine the significance of 
observed differences in coefficient estimates between two groups.
For general introduction of this method, see Efron and Tibshirani (1993, Section 15.2, pp.202).

{dlgtab:The Fisher's permutation test}

{p 4 4 2}
The Fisher's permutation test can be used to test the significance of difference between two groups
of any estimator. 

{p 4 4 2}
In case of regression coefficients difference, Cleary (1999, pp.684-685) uses this method to determine whether there is a significant 
difference of "investment-cash flow sensitivity" coefficients 
between financial constraint (FC) firms and non-financial constraint (NFC) firms.
Cleary states that:
A bootstrapping procedure is used to calculate empirical p-values 
that estimate the likelihood of obtaining the observed differences 
in coefficient estimates if the true coefficients are, in fact, equal. 

{p 6 6 4}
{it: Step} 1: Observations are pooled from the two groups whose coefficient estimates 
are to be compared. 
Using {it:n}1 and {it:n}2 to denote the number of observations available from each group, 
we end up with a total of {it:n}1 + {it:n}2 observations every year. 

{p 6 6 2}
{it: Step} 2: Each simulation randomly selects {it:n}1 and {it:n}2 observations 
from the pooled distribution and assigns them to group 1 and group 2, 
respectively. Coefficient estimates are then determined for each group using 
these observations. 
The difference between coefficient estimates of group 1 and group 2 is denoted as ({it:di})

{p 6 6 2}
{it: Step} 3: This procedure (Step 1 and Step 2) is repeated 5000 times. 

{p 6 6 2}
The empirical {it:p}-value is the percentage of simulations where 
the difference between coefficient estimates ({it:di}) 
exceeds the actual observed difference in coefficient estimates (dSample). 

{p 6 6 2}
This p-value tests against the one-tailed alternative hypothesis 
that the coefficient of one group is greater than that of the other group (H1: {it:d} > 0). 
For example, a {it:p}-value of 0.01 indicates that only 50 out of 5000 
simulated outcomes exceeded the sample result, 
which implies the sample difference is significant, 
and supports the notion that {it:d} > 0.

{p 6 6 2}
Note that, the procedures in Cleary (1999, pp.684-685) is in fact a Fisher's permutation test, 
because Cleary do not use samping with replacement. 
So, the "A bootstrapping procedure" argument in Cleary (1999, pp.684) may be misleading.
For details, see Efron and Tibshirani (1993, Section 15.2, pp.202).)

{dlgtab:For panel data}

{p 4 6 2}
If the command used for Panel data is specified in {opt model(string)}, e.g, xtreg, xtabond, etc.,
then the samping is clusted by {it:id} vairable specified by {help xtset}. {p_end}

{dlgtab:SUR test}

{p 4 6 2}
{cmd: bdiff}'s {it: surtest} option provides a convenient way to perform test for "Do coefficients vary between groups? ". For details, see {help suest} (example 2).{p_end}


{title:Examples}

{dlgtab:basic setting: the nlsw88.dta data}

{p 8 6 2}cap program drop bdiff{p_end}
{p 8 6 2}sysuse nlsw88, clear{p_end}
{p 8 6 2}global xx "ttl_exp married south hours age" {p_end}
	
{dlgtab:permutation test}

{p 8 6 2}bdiff, group(union) model(reg wage $xx) reps(100) detail{p_end}
{p 8 6 2}bdiff, group(union) model(reg wage $xx) reps(100) bdec(2) pdec(4) gap{p_end}

{dlgtab:Bootstrap sample + permutation test}

{p 8 6 2}bdiff, group(union) model(reg wage $xx) reps(500) bsample{p_end}

{dlgtab:SUR test}

{p 8 6 2}bdiff, group(union) model(reg wage $xx) surtest{p_end}

{dlgtab:Logit regression}

{p 8 6 2}bdiff, group(union) model(logit collgrad $xx) reps(500){p_end}

{dlgtab:IV regression}

{p 8 6 2}bdiff, group(union) model(ivregress 2sls wage $xx (tenure=grad collg)) ///{p_end}
{p 15 8 2}bdec(3) pdec(3) reps(100) detail{p_end}
		  
{dlgtab:the -first- option} 

{p 8 6 2}bdiff, group(union) model(reg wage $xx) reps(50){p_end}
{p 8 6 2}return list  // what is happen?{p_end}
{p 6 6 2}*-we want report the empirical p-value of variable "hours"{p_end}
{p 8 6 2}global xx "hours ttl_exp married south age"{p_end}
{p 6 6 2}*-Set 1{p_end}
{p 8 6 2}reg wage $xx if union==0{p_end}
{p 8 6 2}est store m0{p_end}
{p 8 6 2}reg wage $xx if union==1{p_end}
{p 10 6 2}bdiff, group(union) model(reg wage $xx) reps(500) nodots first {p_end}
{p 10 6 2}estadd scalar bdiff_hours = r(bdiff){p_end}
{p 10 6 2}estadd scalar pvalue= r(p){p_end}
{p 8 6 2}est store m1{p_end}
{p 8 6 2}*-Temp report the results{p_end}
{p 8 6 2}esttab m0 m1, mtitle(Non-Union Union) b(%6.3f) nogap ///{p_end}
{p 15 8 2}s(N r2_a bdiff_hours pvalue) star(* 0.1 ** 0.05 *** 0.01) {p_end}
{p 6 6 2}*-Set 2{p_end}
{p 8 6 2}reg wage $xx if c_city==0{p_end}
{p 8 6 2}est store c0{p_end}
{p 8 6 2}reg wage $xx if c_city==1{p_end}
{p 10 6 2}bdiff, group(c_city) model(reg wage $xx) reps(500) nodots first {p_end}
{p 10 6 2}estadd scalar bdiff_hours = r(bdiff){p_end}
{p 10 6 2}estadd scalar pvalue= r(p){p_end}
{p 8 6 2}est store c1{p_end}
{p 6 6 2}*-Report the results{p_end}
{p 8 6 2}esttab m0 m1 c0 c1, mtitle(Non-Union Union Non-Coll Coll) ///{p_end}
{p 15 8 2}b(%6.3f) nogap s(N r2_a bdiff_hours pvalue)                ///{p_end}
{p 15 8 2}star(* 0.1 ** 0.05 *** 0.01) 	{p_end}

{dlgtab:Campare different methods} 

{p 8 6 2}bdiff, group(union) model(reg wage $xx) reps(500) bsample{p_end}
{p 10 6 2}mat p_bs    = e(pvalues){p_end}
{p 8 6 2}bdiff, group(union) model(reg wage $xx) reps(500) {p_end}
{p 10 6 2} mat p_permu = e(pvalues){p_end}
{p 8 6 2}bdiff, group(union) model(reg wage $xx) surtest{p_end}
{p 10 6 2} mat p_sur   = e(pvalues)	  {p_end}
{p 8 6 2}mat S = (p_bs, p_permu, p_sur){p_end}
{p 8 6 2}mat colnames S = "Bootstrap" "Permute" "SUR"{p_end}
{p 8 6 2}matlist S, format(%10.3f) {p_end}

{dlgtab:Panel Data (sample by cluster(id))} 

{p 8 6 2}webuse nlswork.dta, clear{p_end}
{p 8 6 2}xtset id year{p_end}
{p 8 6 2}global x "age south ttl_exp hours tenure"{p_end}
{p 8 6 2}local m "xtreg ln_wage $x, fe"{p_end}
{p 8 6 2}bdiff, group(collgrad) model(`m') reps(100) bs first detail{p_end}

{title:Also see}

{p 4 13 2}
Online:  help for {help chowtest} (if installed), {help bsample}, {help permute}, {help suest}. 

{title: Acknowledgements}

{pstd}   
Thanks for Jingxin Hu (jhu109@syr.edu) from Syracuse University. 
Hu helps me fix the bug of {opt seed(#)} option.


{title:Author}

{phang}
{cmd:Yujun,Lian (arlionn)} Department of Finance, Lingnan College, Sun Yat-Sen University.{break}
E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com}. {break}
Blog: {browse "https://www.lianxh.cn":https://www.lianxh.cn} {break}
{p_end}


{title:For problems and suggestions}

{p 4 4 2}
Any problems or suggestions are welcome, please Email to
{browse "mailto:arlionn@163.com":arlionn@163.com}. 


{title:References}

{p 4 8 2}
Cleary, S., 1999, The Relationship between Firm Investment and Financial Status, 
{it:Journal of Finance}, 54(2): 673-692.
http://onlinelibrary.wiley.com/doi/10.1111/0022-1082.00121/full.{p_end}

{p 4 8 2}
Efron, B., Tibshirani, R., 1993. 
An Introduction to the Bootstrap, Chapmann & Hall. {p_end}

{p 4 8 2} Lian, Y.J., J. Cheng, 2007. 
Investment-cash flow sensitivity: Financial constraint or agency cost?
Journal of Finance and Economics, 2007(2): 37-46. (In Chinese)  

{p 4 8 2} 连玉君, 2016. 
Stata: 如何检验分组回归后的组间系数差异？, {browse "https://www.lianxh.cn/news/051e3a01cdb19.html":https://www.lianxh.cn/news/051e3a01cdb19.html}{p_end}

