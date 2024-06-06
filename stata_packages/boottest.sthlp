{smcl}
{* *! boottest 4.2.0 24 August 2022}{...}
{help boottest:boottest}
{hline}{...}

{title:Title}

{pstd}
Test linear hypotheses using wild or score bootstrap or Rao or Wald test for OLS, 2SLS, LIML, Fuller, {it:k}-class, or general ML estimation with classical, heteroskedasticity-robust, 
or (multi-way-) clustered standard errors and optional fixed effects{p_end}

{title:Syntax}

{phang}
{cmd:boottest} [{it:indeplist}] [, {it:options}]

{phang}
where {it:indeplist} is one of

{phang2}
{it:jointlist}

{phang2}
{cmd:{c -(}}{it:jointlist}{cmd:{c )-}} [{cmd:{c -(}}{it:jointlist}{cmd:{c )-}} ...]

{phang}
{it:jointlist} is one of

{phang2}
{it:test}

{phang2}
{cmd:(}{it:test}{cmd:)} [{cmd:(}{it:test}{cmd:)} ...]

{phang}
and {it:test} is

{phang2}
{it:{help exp}} {cmd:=} {it:{help exp}} | {it:{help test##coeflist:coeflist}}

{pstd}
In words, {it:indeplist} is a list of hypotheses to be tested independently; if there is more than one, then each must be enclosed in curly braces. Each independent hypothesis
in turn consists of one or more jointly tested constraints, linear in parameters; if there is more than one, then each must be enclosed in parentheses. Finally, each 
individual constraint expression must conform to the syntax for {help constraint:constraint define}.

{synoptset 37 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{cmdab:weight:type(}{it:rademacher} {cmd:|} {it:mammen} {cmd:|} }specify weight type for bootstrapping; default is {it:rademacher}{p_end}
{synopt:{space 12} {it:webb} {cmd:|} {it:normal} {cmd:|} {it:gamma}{cmd:)}}{p_end}
{synopt:{opt boot:type(wild | score)}}specify bootstrap type; after ML estimation, {it:score} is default and only option{p_end}
{synopt:{opt jack:knife} or {opt jk}}request jackknifing of bootstrap data-generating process{p_end}
{synopt:{opt stat:istic(t | c)}}specify statistic type to bootstrap; default is {it:t}{p_end}
{synopt:{opt r:eps(#)}}specifies number of replications for bootstrap-based tests; default is 999; set to 0 for Rao or Wald test{p_end}
{synopt:{opt nonul:l}}suppress imposition of null before bootstrapping{p_end}
{synopt:{opt marg:ins}}bootstrap current results from {cmd:margins}{p_end}
{synopt:{opt madj:ust(bonferroni | sidak)}}specify adjustment for multiple hypothesis tests{p_end}
{synopt:{opt l:evel(#)}}override default confidence level used for confidence set{p_end}
{synopt:{cmdab:svm:at}[{cmd:(}{it:t} {cmd:|} {it:numer}{cmd:)]}}request the bootstrapped quasi-t/z distribution, or numerators thereof, be saved in return value {cmd:r(dist)}{p_end}
{synopt:{cmd:svv}}request that the matrix of wild weights be saved in return value {cmd:r(v)}{p_end}
{synopt:{opt sm:all}}request finite-sample corrections, overriding estimation setting {p_end}
{synopt:{opt nosm:all}}prevent finite-sample corrections, overriding estimation setting {p_end}
{synopt:{opt r:obust}}request tests robust to heteroskedasticity only, overriding estimation setting{p_end}
{synopt:{opt cl:uster(varlist)}}request tests robust to (multi-way) clustering, overriding estimation setting{p_end}
{synopt:{opt bootcl:uster(varlist)}}sets cluster variable(s) to boostrap on; default is all {cmdab:cl:uster()} variables{p_end}
{synopt:{opt ar}}request Anderson-Rubin test{p_end}
{synopt:{opt seed(#)}}initialize random number seed to {it:#}{p_end}
{synopt:{cmdab:matsize:gb(#)}}set maximum size of wild weight matrix, in gigabytes{p_end}
{synopt:{opt qui:etly}}suppress display of null-imposed estimate; relevant after ML estimation{p_end}
{synopt:{opt cmd:line(string)}}provide estimation command line; needed only after custom ML estimation{p_end}
{synopt:{opt julia}}use the Julia implementation for speed in hard problems{p_end}
{synopt:{opt float(#)}}For Julia only, override default numerical precision (32- instead of 64-bit){p_end}
{synopt:{cmd:h0}({it:{help estimation options##constraints():constraints}}{cmd:)}}({it:deprecated}) specify linear hypotheses stored as constraints; default is "1" if {it:indeplist} empty{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
These options are relevant when testing one- or two-dimensional hypotheses after OLS/2SLS/LIML/k-class, when by default a confidence function is plotted and, if the hypothesis is
one-dimensional, a confidence set is derived:

{synoptset 37 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt gridmin(# [#])}}set lower end(s) of confidence set search range; two entries for 2-D hypotheses{p_end}
{synopt:{opt gridmax(# [#])}}analogous upper ends{p_end}
{synopt:{opt gridpoints(# [#])}}set number of equally space points to compute rejection confidence{p_end}
{synopt:{opt graphopt(string)}}formatting options to pass to graph command{p_end}
{synopt:{cmd:graphname(}{it:name}[{cmd:, replace}]{cmd:)}}name graph; for multiple independent hypotheses, uses {it:name} as stub{p_end}
{synopt:{opt nogr:aph}}allow derivation of confidence set but don't graph confidence function{p_end}
{synopt:{cmdab:f:ormat(}fmt{cmd:)}}set {help format:numerical format} for confidence set bounds; default is %6.0g{p_end}
{synopt:{opt noci}}prevent derivation of confidence set from inverted bootstrap test{p_end}
{synopt:{opt ptol:erance(#)}}sets precision of identification of confidence set bounds (default 1e-3){p_end}
{synopt:{cmdab:p:type(}{it:symmetric} {cmd:|} {it:equaltail} {cmd:|}}for unary hypotheses, set p value type; {it:symmetric} is default{p_end}
{synopt:{space 12} {it:lower} {cmd:|} {it:upper}{cmd:)}}{p_end}
{synoptline}
{p2colreset}{...}

{phang}
{cmd:waldtest} [, {it:options}]

{phang}
{cmd:scoretest} [, {it:options}]

{phang}
{cmd:artest} [, {it:options}]

{pstd}
{cmd:waldtest}, {cmd:artest}, and {cmd:scoretest} accept all options listed above except {cmdab:weight:type()}, {cmdab:boot:type()}, {opt r:eps(#)}, {opt svm:at}, {opt svv}, and {opt seed(#)}.

{title:Updates}
{pstd}Since the publication of Roodman et al. (2019), {cmd:boottest} has gained four significant features and some minor changes:

{p 2 4 0}* The first significant addition is an option to perform the bootstrap-c,
which bootstraps the distribution of the {it:coefficient(s)} of interest (or linear combinations thereof) rather t/z/F/chi2 statistics. Standard theory favors the latter, 
but Young (2022) presents evidence that the bootstrap-c (or "non-studentized" test) is at least as reliable in instrumental variables (IV) estimation. And theory and simulation in
Wang (2021) favors the non-studentized test when instruments are weak, but strong in at least one cluster. The option 
{cmdab:stat:istic(c)} invokes the feature. However, the boottest author does not recommend this method, because in appears about the same as the bootstrap-t in size
and worse in power.

{p 2 4 0}* The second notable new feature is the ability to jackknife the bootstrap data-generating process, as advocated for OLS by MacKinnon, Nielsen, and
Webb (2022) and for linear IV estimation by Young (2022). If a single cluster contains extreme observations,
that will drive the initial model fit toward minimizing their apparent extremity, thus potentially making the bootstrap data-generating process less realistic. To reduce this risk,
the {help jackknife} computes each bootstrapping cluster's best fit using only the data from all the other clusters. For OLS, {cmd:boottest}'s
implementation corresponds to what MacKinnon, Nielsen, and Webb (2023) calls the WCU/WCR-S.

{p 2 4 0}* The third new feature is the {cmdab:marg:ins} option, which allows you to bootstrap results from the {cmd:margins} command when those results are
linear functions of the parameters. To use this feature,
run {cmd:boottest} immediately after {cmd:margins} and do not include any hypotheses before the comma in the {cmd:boottest} command line. {cmd:boottest} will treat
each marginal effect separately.

{p 2 4 0}* The fourth new feature is the ability, in Stata 16 and higher, to use a faster implementation written in the free programming language Julia. Where {cmd:boottest} is already fast,
this option is useless. But for some computationally intensive applications, the {cmd:julia} option can improve performance by an order of magnitude. See {help boottest##julia:{it:Using Julia}}.

{p 2 4 0}* Version 2.0.6 of {cmd:boottest}, released in May 2018, introduced two changes that can slightly affect results. The default for {opt r:eps(#)}
is now 999 instead of 1000. And in computing percentiles in the bootstrap distribution, ties are no longer (half-)counted. 
For exact replication of earlier results, an older version, 2.0.5, is available as a
{browse "https://github.com/droodman/boottest/tree/2d93ed35025e2e10276151b3a64e443853d60bad":Github archive}, and can be directly installed in Stata 13 or later via
{stata "net install boottest, replace from(https://raw.github.com/droodman/boottest/v2.0.5)":net install boottest, replace from(https://raw.github.com/droodman/boottest/v2.0.5)}.

{p 2 4 0}* As of version 2.7.0, of 26 April 2020, {cmd:boottest} requires Stata version 13 or later. Version 2.6.0, which also works in Stata versions 11 and 12, can be downloaded
from {browse "https://github.com/droodman/boottest/archive/For-Stata-11,-12.zip"}.

{p 2 4 0}* Version 3.1.0, released in March 2021, also introduced a change that can slightly affect results, specifically the bounds for confidence sets. It switched to a faster algorithm for
pinpointing these bounds (Chandrupatla 1997). In the bootstrap, the {it:p} value as a function of the trial parameter value is a step function when viewed at high resolution: it can only take 
values {it:n}/{it:B} where {it:n} is an integer and {it:B} is the number of bootstrap replications. As a result, when searching for the cross-over point for, say, {it:p} = 0.05, locations in a small range are equally valid. The
new algorithm happens to settle at slightly different points. The last boottest version before this change is 3.0.2, and is available via 
{stata "net install boottest, replace from(https://raw.github.com/droodman/boottest/v3.0.2)":net install boottest, replace from(https://raw.github.com/droodman/boottest/v3.0.2)}.

{p 2 4 0}* Version 3.1.0 also added support for {cmd:ivreg2}'s {cmd:partial()} option, and radically sped up the bootstrap after IV/GMM regressions. But it dropped support for linear GMM regressions;
the lost feature stood on shaky ground anyway, since {cmd:boottest} did not recalculate the GMM weight matrix on each replication.

{p 2 4 0} * Version 4.4.3 changed the default for {opt ptol:erance(#)} option, which controls the precision with which confidence interval bounds are identified,
from 1e-6 to 1e-3. This saves time and only affects results in the third or fourth significant digit.

{marker description}{...}
{title:Description}

{pstd}
{cmd:boottest} is a post-estimation command that tests linear hypotheses about parameters. Roodman et al. (2019) documents it more fully than this help file, at least as of its late-2018 instantiation.

{pstd}
{cmd:boottest} offers several bootstraps--algorithms for generating simulated data sets--and
several tests to run on the data sets. The bootstraps are:

{p 4 6 0}
* The wild bootstrap (Wu 1986), available after (constrained) OLS estimation.

{p 4 6 0}
* The wild restricted efficient bootstrap (WRE; Davidson and MacKinnon 2010), which extends the wild bootstrap to instrumental variables estimators including
2SLS, LIML, Fuller LIML, and {it:k}-class estimation.

{p 4 6 0}
* The score bootstrap developed by Kline and Santos (2012) as an adaptation of the wild bootstrap to the general extremum estimator, including 2SLS, LIML, and ML. In 
estimators such as probit and logit, residuals are not well-defined, which prevents application of the wild bootstrap. As its name suggests, the score bootstrap 
works with a generalized analog of residuals, scores. Also, the score bootstrap does not require re-estimation on each replication, which would be 
computationally prohibitive with many ML-based estimators.

{pstd}
{cmd:boottest} uses the first two to bootstrap the empirical distribution of a Wald test of the null hypothesis. For instrumental variables models, the 
WRE may also be used to bootstrap the Anderson-Rubin (1949) test, which is itself a Wald test based on an auxilliary OLS regression 
(Baum, Schaffer, and Stillman 2007, p. 491). The score bootstrap, as its name suggests, is best seen as bootstrapping the Rao score/LM test.

{pstd}All of these tests may be considered bootstrap-t tests in that they simulate the distribution of pivotal quantities--t, z, F, or chi2 statistics. That means that for each
replication, the algorithm computes the numerator and denominator of the statistic of interest, then determines the quantile of the ratio from the original sample in this simulated
distribution. In contrast, the bootstrap-c uses the same bootstrap data-generating processes to simulate only the numerators--i.e., coefficients or linear 
combinations thereof. From the bootstrap numerators, the bootstrap-c algorithm then computes a single covariance matrix for use in all the statistics. For one-dimensional hypotheses,
dividing the test statistic numerator and its bootstrap replications by this universal denominator has no substantive effect; but it is needed for higher-dimensional hypothesis in order
to norm the numerators, which are vectors. Under standard asumptions, the
bootstrap-t, unlike the bootstrap-c, offers {it:asymptotic refinement}, more-rapid convergence to the true distribution. But Young (2022) and Wang (2021) provide evidence
that in instrumental variables estimation, the bootstrap-c is at least as reliable. {cmd:boottest} offers both through the {cmdab:stat:istic()} option, {cmd:stat(t)} being the default.

{p 4 6 0}
If one instructs {cmd:boottest} to generate zero bootstrap replications ({cmd:reps(0)}), then, depending on the bootstrap chosen and whether {cmd:ar} is specified, it will default to:

{p 4 6 0}
* The classical Wald (1943) test.

{p 4 6 0}
* The classical Anderson-Rubin (1949) test.

{p 4 6 0}
* The classical Rao (1948) score/Lagrange multiplier test.

{pstd}
{cmd:waldtest}, {cmd:artest}, and {cmd:scoretest} are wrappers for {cmd:boottest} to facilitate access to these classical tests. The Wald test should be the same as that 
provided by {help test}. {cmd:waldtest} adds value by allowing you to incorporate finite-sample corrections and (multi-way) clustering 
after estimation commands that do not support those adjustments.

{pstd}
The tests are available after OLS, constrained OLS, 2SLS, and LIML estimation performed with {help regress}, {help cnsreg}, {help ivreg}, {help ivregress}, or 
{stata ssc describe ivreg2:ivreg2}. The
program works with Fuller LIML and {it:k}-class estimates done with {help ivreg2} (WRE bootstrap only). The program also works with regressions with one set of "absorbed" fixed
effects performed with {help areg}; {help xtreg:xtreg, fe}; {help xtivreg:xtivreg, fe}; {help xtivreg2:xtivreg2, fe}; {help reghdfe:reghdfe}; {help didregress}; 
or {help xtdidregress}. ({help didregress} and {help xtdidregress} themselves can run the wild bootstrap, but much more slowly.) And {cmd:boottest} works after most Stata 
ML-based estimation commands, including {help probit}, {help glm}, {stata ssc describe cmp:cmp}, and, in Stata 14.0 or later, 
{help sem} and {help gsem} (score bootstrap only). (To work with {cmd:boottest}, an iterative optimization command must accept
the {opt const:raints()}, {opt iter:ate()}, {opt from()}, and {opt sc:ore} options.)

{pstd}
{cmd:boottest} is designed in partial analogy with {help test}. Like {help test}, {cmd:boottest} can jointly or separately test multiple hypotheses expressed as linear constraints on 
parameters. {cmd:boottest} deviates in syntax from {help test} in the specification of the null hypothesis. In fact, it offers two syntaxes. In the first, 
now deprecated, one first expresses the null in 
one or more {help estimation options##constraints():constraints}, which are then listed by number in {cmd:boottest}'s {opt h0()} option. All constraints are tested 
jointly. In the second, modern syntax, one places the constraint expressions directly in the {cmd:boottest} command line before the comma. Each expression must conform to the syntax
of {help constraint:constraint define}, meaning a list of parameters (all of which are implicitly hypothesized to equal zero) or an equation in the form 
{it:{help exp}} {cmd:=} {it:{help exp}}. To jointly test several such expressions, list them all, placing each in parentheses. To independently test several such hypotheses, or joint groups
of hypotheses, list them all, placing each in braces.

{pstd}
Omitting both syntaxes implies {cmd:h0(1)}, except in three cases in which no hyptheses need be explicitly stated: 1. {opt ar} is specified, in which case {cmd:boottest}
performs the Anderson-Rubin test that all coefficients on instrumented variables are zero; 2. {opt margins} is specified, in which case the hypothesis that effects
just computed with {cmd:margins} are jointly 0; or 3. {cmd:boottest} is
run after {help didregress} or {help xtdidregress}, in which case the hypothesis defaults to the treatment effect being 0.

{pstd}
When testing multiple independent hypotheses, the {opt madj:ust()} option requests the Bonferroni or Sidak correction for multiple hypothesis testing.

{pstd}
{cmd:boottest} supports multi-way error clustering (Cameron, Gelbach, and Miller 2006). Using this feature forces a choice of which clustering variable(s) to {it:bootstrap}
on, a choice expressed with the {opt bootcl:uster()} option.

{pstd}
When multiway clustering is combined with {cmdab:sm:all}, 
the finite-sample correction multiplier is a component-specific (G/(G-1)*(N-1)/(N-k), as described in Cameron, Gelbach, and Miller (2006, pp. 8-9) and simulated therein. In
contrast, {stata ssc describe ivreg2:ivreg2} uses one multiplier for all components, based on the clustering variable with the lowest G. Thus after estimation with
{cmd:ivreg2} with multi-way clustering, {cmd:waldtest} produces slightly different results from {cmd:test}, which relies purely on {cmd:ivreg2}'s computed covariance matrix.

{pstd}
Because {cmd:boottest} has its own {opt r:obust}, {opt cl:uster()}, {opt sm:all}, and {opt nosm:all} options, you can override the choices made in running the 
original estimate. In particular, you can perform inference with multi-way clustered errors after all the estimation commands that are compatible with
{cmd:boottest}, even though few can themselves multi-way cluster. Those include many ML-based estimators, after which {cmd:boottest} performs the score bootstrap.

{pstd}
By default, the null is imposed before bootstrapping (Fisher and Hall 1990; Davidson and MacKinnon 1999; Cameron, Gelbach, and Miller 2008). The {opt nonul:l} option overrides this behavior. With IV
estimation, the null is imposed only on the second-stage equation. Thus, after {cmd:ivregress 2sls Y X1 (X2 = Z)}, imposing the null of X1 = 0 results in the equivalent of 
{cmd:ivregress 2sls Y (X2 = X1 Z)}, not {cmd:ivregress 2sls Y (X2 = Z)}.

{pstd}
The wild and score bootstraps multiply residuals or scores by weights drawn randomly for each replication. {cmd:boottest} offers five weight distributions:

{p 4 6 0}
* The default Rademacher 
weights are +/-1 with equal probability. In the wild bootstrap, that means that in each replication, and in each cluster (or each observation in non-clustered
estimation), the synthetic dependent variable is XB +/- E, where XB and E are the fitted values and residuals from the base regression. Since
Rademacher weights have mean 0 and variance 1, multiplying E by them preserves the variance of the base regression's residuals.

{p 4 6 0}
* Mammen (1993)
weights improve theoretically on Rademacher weights by having a third moment of 1, thus preserving skewness. Letting phi=(1+sqrt(5))/2, the 
golden ratio--the Mammen weights are 1-phi with probability phi/sqrt(5) and phi otherwise.

{p 4 6 0}
* A disadvantage of the Rademacher and Mammen distributions is that 
they have only two mass points. So, for instance, an estimate with 5 clusters can only have 2^5 = 32 possible combinations of weight draws. Performing more than 32 replications in this 
case, as in some Cameron, Gelbach, and Miller (2008) examples,
creates spurious precision, since some replications will be duplicates. Webb (2014) weights greatly reduce this problem with a uniform 6-point distribution that closely matches Rademacher
in the first four moments. The 6 values are +/-sqrt(3/2), +/-1, +/-sqrt(1/2).

{p 4 6 0}
* The fourth weight type is the normal distribution.

{p 4 6 0}
* The fifth weight type is the gamma distribution with shape parameter 4 and scale parameter 0.5, as suggested by Liu (1988). Much like the Mammen distribution, 
it improves theoretically on the normal, having third moment equal to 1 as well.

{pstd}
Despite the seeming superiority of the asymmetric Mammen and gamma distributions, symmetric distributions such as the Rademacher and Webb have performed better
in Monte Carlo simulations, in the sense of yielding tests of more accurate size (Davidson and Flachaire 2008; Kline and Santos 2012; Finlay and Magnusson 2019).

{pstd}
The {opt r:eps(#)} option sets the number of bootstrap replications. 999 is the default but values of 9999 and higher are often feasible. Since bootstrapping
involves drawing pseudorandom numbers, the exact results depend on the starting value of the random number generator and the version of the generator. See 
{help set_seed:set seed}.

{pstd}
When testing a one-dimensional hypothesis after linear estimation (OLS, 2SLS, etc.), {cmd:boottest} by default derives and plots a confidence curve and a confidence set for the 
right-hand-side of the hypothesis. (This adds run time and can be prevented with the {opt noci} option.) For example,
if the hypothesis is "X + Y = 1", meaning that the coefficients on X and Y sum to 1, then {cmd:boottest} will estimate the set of all potential values for this sum that cannot be rejected
at, say, p = 0.05. This set might consist of disjoint pieces. The standard {opt l:evel(#)} option controls the coverage of the confidence set. By default, p value 
computation is symmetric; {opt ptype(equaltail)} overrides. For instance, if the level is 95, then the symmetric p value is less than 0.05 if the square (or 
absolute value) of the test statistic is in the top 5 centiles of the corresponding bootstrapped distribution. The equal-tail p value is less than 0.05 if the test statistic is in the top or
bottom 2.5 centiles of the (un-squared) distribution. Davidson and MacKinnon (2010) find that in estimation with weak instruments, when the estimator is often asymmetrically 
distributed, equal-tail p values are more reliable.

{pstd}
To find the confidence set, {cmd:boottest} starts by choosing lower and upper bounds for the search range, which can be overriden by the {opt gridmin(#)} and {opt gridmax(#)} 
options. Then it tests potential values at equally spaced intervals within this range--by default 25, but this too is subject to override, via
{opt gridpoints(#)}. If it discovers that, for example X + Y = 2 is rejected at 0.04 and X + Y = 3 is rejected at 0.06, it then seeks to zero in on the value in between
that is rejected at 0.05, in order to bound the confidence set. The confidence curve is then plotted at all the grid points as well as the detected crossover points and the
original point estimate. The graph may look coarse with only 25 grid points, but the confidence set bounds will nevertheless be computed precisely. Specifying 
{cmd:level(100)} suppresses this entire search process while still requesting a plot of the confidence curve.

{pstd}
Similarly, when testing a two-dimensional hypothesis after linear estimation, {cmd:boottest} automatically renders the p value surface with a {help twoway contour:contour plot}. In
this case, it does not attempt to numerically describe the boundary of the confidence set. But by default, the contour plot has shading breaks at 0.05, 0.1, ...,, 0.95, making the 
boundary easy to perceive. The {opt gridmin()}, {opt gridmax()}, and {opt gridpoints()} options, if included, now should provide two numbers each, for the first and second
dimensions of the hypothesis. But any entry may be missing (".") to accept {cmd:boottest}'s best guess at a good boundary (for {opt gridmin()} and {opt gridmax()}) or fixed default
(25, for {opt gridpoints()}). To override the default formatting of the contour plot, include {help twoway contour} options inside a {cmd:boottest} {opt graphopt()} option.


{title:Including results in estimation tables}

{pstd}The easiest way to add {cmd:boottest} results to estimation tables is to first store them in the relevant e() results using the {cmd:estadd} command in the
{stata ssc describe estout:estout} package. For example, after a {cmd:boottest} command, {cmd:estadd scalar p = r(p)} saves the {it:p} value as e(p). {cmd:estadd local CIstr "`r(CIstr)'"} 
saves the string describing the bootstrap confidence set as e(CIstr). (Use {cmd:boottest}'s {cmdab:f:ormat()} option to control the number display in this 
string.) Then, commands such as {help table}, {stata ssc describe estout:esttab}, and {stata ssc describe outreg2:outreg2} can access the results
as they build tables. 


{marker options}{...}
{title:Options}

{phang}{opt weight:type(rademacher | mammen | webb | normal | gamma)} specifies the type of random weights to apply to the residuals or scores from the base regression, when
bootstrapping. The default is {it:rademacher}. However if the number of replications exceeds 2^(# of clusters)--that is, the number of possible
Rademacher draws--{cmd:boottest} will take each possible draw once. It will not do that with Mammen weights even though the same issue arises. In all such cases,
Webb weights are probably better.

{phang}{opt boot:type(wild | score)} specifies the bootstrap type. After ML estimation, {it:score} is the default and only option. Otherwise, the wild or wild 
restricted efficient bootstrap is the default, which {cmd:boottype(score)} overrides in favor of the score bootstrap.

{phang}{opt jack:knife} or {opt jk} requests jackknifing of the bootstrap data-generating process for OLS or linear IV estimates. In the 
inital model fit, the one subject to the null unless {cmdab:nonul:l} is specified, the fit within each bootstrapping cluster is computed using only the data from all
the other clusters. For OLS, MacKinnon, Nielsen, and Webb (2023) dubs this process WCU/WCR-S. For IV, it corresponds to the jackknifed wild bootstrap described in Young (2002). The 
Julia implementation (invoked with the {cmd:julia}) option does not offer the jackknife after instrumental variables estimation, unless running the Anderson-Rubin test 
(invoked with the {cmd:ar} option).

{phang}{opt stat:istic(t | c)} specifies the boostrapped statistic. The default, {it:t}, invokes the bootstrap-t, meaning the bootstrapping of
distributions for t, z, F, or chi2 statistics. The alternative, {it:c}, requests the bootstrap-c.

{phang}{opt r:eps(#)} sets the number of bootstrap replications. The default is 999. Especially when clusters are few, increasing this number costs little in run 
time. {opt r:eps(0)} requests a Wald test or--if {opt boottype(score)} is also specified and {opt nonul:l} is not--a Rao test. The wrappers {cmd:waldtest}
and {cmd:scoretest} facilitate this usage.

{phang}{opt nonul:l} suppresses the imposition of the null before bootstrapping. This is rarely a good idea.

{phang}{opt marg:ins} instructs {cmd:boottest} to treat results from a call to {cmd:margins}, which must just have been generated, as a linear combination of parameters,
and test the independent hypotheses that each is 0. {cmd:boottest} extracts the coefficients of these linear combinations from the r(Jacobian) return value of
{cmd:margins}. When using this option, do not include any hypotheses before the comma 
(or in the deprecated {cmd:h0()} option). This option only works for margins that are linear predictions, such as average predicted outcome by subgroup after {cmd:regress}.

{phang}{opt madj:ust(bonferroni | sidak)} requests the Bonferroni or Sidak adjustment for multiple hypothesis tests. The Bonferroni correction is
min(1, n*p) where p is the unadjusted probability and n is the number of hypotheses. The Sidak correction is 1 - (1 - p) ^ n.

{phang}{opt noci} prevents computation of a confidence interval for the constant term of a single constraint. For example, if the 
confidence level is 95% and the null is expressed in a constraint as X + Y = 1, 
{cmd:boottest} will iteratively search for the high and low values U and L such that the bootstrapped two-tailed p values of the 
hypotheses X + Y = U and X + Y = L are 0.05. See Cameron and Miller (2015, section VIC.2). This option is only relevant when testing a 
one-costraint hypothesis after OLS/2SLS/GMM/LIML, for only then is the confidence interval derived anyway.

{phang}{opt l:evel(#)} specifies the confidence level, in percent, for the confidence interval; see {help level:help level}. The
default is controlled by {help level:set level} and is usually 95. Setting it to 100 suppresses computation and plotting of the confidence 
set while still allowing plotting of the confidence curve.

{phang}{opt ptol:erance(#)} specifies the precision of identification of confidence set bounds. The default is 1e-6. This means that
if, in searching for the boundaries of a confidence set, {cmd:boottest}'s last two bracketing guesses for a bound have a relative difference less than 
1e-6, then convergence is declared. This option is useful if the identification of 
bounds is time consuming. To identify confidence set bounds, {cmd:boottest} first computes the {it:p} value at the evenly spaced
grid points (see options just below). Then it determines between which grid points the {it:p} value crosses the 
specified confidence level, usually 0.05, and iteratively searches for exact cross-over points.

{phang}{opt gridmin(# [#])}, {opt gridmax(# [#])}, {opt gridpoints(# [#])} override the default lower and upper bounds and the resolution of the grid search,
as described above. By default, {cmd:boottest} picks the lower and upper bounds by working
with the bootstrapped distribution, and uses 25 grid points.

{phang}{opt graphopt(string)} allows the user to pass formatting options to the {help graph} command, in order to control the appearance of the p value plot.

{phang}{cmd:graphname(}{it:name}[{cmd:, replace}]{cmd:)} names any resulting graphs. If testing multiple independent hypotheses, {it:name} will be used as a stub,
producing {it:name}_1, {it:name}_2, etc.

{phang}{opt nogr:aph} prevents graphing of the confidence function but not the derivation of confidence sets.

{phang}{cmdab:f:ormat(}fmt{cmd:)} sets the {help format:numerical format} for confidence set bounds. This affects the 
confidence curve plots and the construction of the string destription of the condifence set returned in {cmd:r(CIstr)}. The
default is %5.0g.

{phang}{opt p:type(symmetric | equaltail | lower | upper)} sets the p value type. The option applies only to unary hypotheses, ones involving a single 
equality. The default, {it:symmetric}, has the p value derived from the
square of the {it:t}/{it:z} statistic, or, equivalently, the absolute value. {it:equaltail} performs a two-tailed test using the {it:t}/{it:z} statistic. For example, 
if the confidence level is 95, then the symmetric p value is less than 0.05 if the square of the test statistic is in the top 5 centiles of the corresponding bootstrapped 
distribution. The equal-tail p value is less than 0.05 if the test statistic is in the top or bottom 2.5 centiles. In addition, {it:lower} and {it:upper} allow
one-sided tests.

{phang}{cmdab:svm:at}[{cmd:(}{it:t} {cmd:|} {it:numer}{cmd:)}] requests that the bootstrapped quasi-t/z distribution be saved in return value {cmd:r(dist)}. This 
can be diagnostically useful, since it allows scrutiny of the simulated distribution that is inferred from. An example is below. Or, 
if {cmd:svmat(numer)} is specified, over-riding the default, only the numerators are returned. If the null hypothesis is that a coefficient is zero, then these numerators
are the estiamtes of that coefficient in all the bootstrap replications.

{phang}{cmd:svv} requests that the matrix of wild weights be saved in return value {cmd:r(v)}. Warning: The wild weight matrix is very large under some 
circumstances: it has one row for each bootstrapping cluster and one column for each bootstrap replication. If it is large, then this option may bring Stata to its knees. If
the {opt matsize:gb(#)} option is also invoked (see below), then only the last chunk of the wild weight matrix will be returned.

{phang}{opt sm:all} requests finite-sample corrections even after estimates that do not make them, which includes essentially all ML-based Stata 
commands. Its impact on bootstrap-based tests is merely cosmetic because it scales the test statistic and all the replicated test statistics by the same
value, such as N/(N-1), so that the place of the test statistic in the simulated distribution does not change. It substantively affects Rao and Wald tests.

{phang}{opt nosm:all} prevents finite-sample corrections even after estimates that make them, such as {cmd:regress}. This is rarely useful.

{phang}{opt r:obust} and {opt cl:uster(varlist)} have the traditional meanings, but serve a nontraditional function, which is to override the settings
used in the estimation.

{phang}{opt bootcl:uster(varlist)} specifies which clustering variable or variables to boostrap on. If the option 
includes more than one variable, then for the bootstrap observations are grouped by intersections of all the variables in the option. The default is to cluster the bootstrap on all
the {cmdab:cl:uster()} variables. Simulations in MacKinnon, Nielsen, and Webb (2017) tend to favor clustering the bootstrap just on the one variable with the smallest
number of clusters. However, MacKinnon and Webb (2018) show that in the extreme case of a treatment model with very few (un)treated clusters, it can be better to 
to perform a "subcluster" bootstrap, such as bootstrapping at the individual observation level.

{phang}{opt ar} requests the Anderson-Rubin test. It applies only to instrumental variables estimation. If the null is specified explicitly, it must fix
all coefficients on instrumented variables, and no others.

{phang}{opt seed(#)} sets the initial state of the random number generator. See {help set seed}.

{phang}{opt qui:etly}, with Maximum Likelihood-based estimation, suppresses display of initial re-estimation with null imposed.

{phang}{opt matsize:gb(#)} limits the size of the wild weight matrix, in a gigabytes, when memory limits are a concern. More precisely,
the option directs {cmd:boottest} to divide the matrix into chunks of the specified size, and work with one at a time. Ordinarily,
{cmd:boottest} draws all of the wild weights at once and stores them in a single matrix with one row for each
bootstrapping cluster and one column for each bootstrap replication. Normally there are few bootstrapping
clusters, so this matrix does not require much memory. But applications with many bootstrapping clusters can demand a lot
of memory. (Each entry of a real matrix in Mata requires 8 bytes.) If phyical memory limits are exceeded, the operating system will start
caching virtual memory to disk, which can drastically degrade performance. If you are concerned that this is happening,
monitor memory usage and disk activity while {cmd:boottest} runs. This option can reduce the memory demand. It
makes {cmd:boottest} computationally less efficient---especially so when constructing confidence intervals, when it must repeatedly 
create and destroy chunks of the same matrix of wild weights. But if memory is tight, speed will probably still improve overall.

{phang}{opt cmd:line(string)} provides {cmd:boottest} with the command line just used to generate the estimates. This is needed only when performing the 
Kline-Santos score bootstrap after estimation with the {help ml model} command, and only when imposing the null. In order to impose the null on an ML estimate,
{cmd:boottest} needs to rerun the estimation with a null constraint applied. And in order to do that, it needs access to the exact command line that generated the 
results. Most Stata estimation commands save the full command line in the {cmd:e(cmdline}} return macro, which {cmd:boottest} looks for. However, if you perform estimation
directly with Stata's {cmd:ml model} command, perhaps with a custom likelihood evaluator, no {cmd:e(cmdline}} is saved. The {opt cmd:line(string)} option provides a work-around, by allowing you
to pass the estimation command line manually. If you run {cmd:ml} in interactive mode, with a separate {cmd:ml max} call, pass the earlier {cmd:ml model} command line;
{cmd:boottest} will automatically append a {cmd:maximize} option to it. An example appears below.

{phang}{opt julia} requests the use of the Julia implementation, which can be much faster for hard problems. See {help boottest##julia:{it:Using Julia}}.

{phang}{opt float(#)} specifies the numerical precision of computation when using Julia. May be {cmd:float(32)} or the default {cmd:float(64)}. {cmd:float(32)}--single-precision--will
often arrive at same results in less time. However, when estimation needs high precision, such as when regressors are nearly collinear, {cmd:float(32)} can cause {cmd:boottest}
to misestimate the base regression. To check this possibility, compare the test statistic reported by {cmd:boottest} to the corresponding result from {cmd:test}.
You may need to take the square root of an {it:F} or chi2 statistic from {cmd:test} and compare it to a {it:t} or {it:z} statistic from {cmd:boottest}.

{phang}
{cmd:h0}({it:{help estimation options##constraints():constraints}}{cmd:)} (deprecated) specifies the numbers of the stored constraints that jointly express
the null. The argument is a {help numlist}, so it can look like "1 4" or "2/5 6 7". The default is "1". 


{marker julia}
{title:Using Julia}

{pstd}{cmd:boottest} has two back ends: one written in Stata's Mata language, which is the default; and one written in Julia, which is requested through
the {cmd:julia} option. Results from the two will usually not match exactly since they use different random number generators; but they should converge
as the number of bootstrap replications rises.

{pstd}The Julia implementation is usually an order of magnitude faster, once it gets going. But it comes with significant overhead. The first time it is run within a Stata session,
or with the {cmd:float(32)} option for single-precision, or in order to request a different kind of test such as the WCR after OLS or the WRE after 2SLS, 15-20 seconds may pass while code is 
compiled. Julia uses just-in-time compilation, but sometimes it feels just-not-in-time. In addition, on each invocation, data is temporarily copied from Stata to Julia, which takes 
time. If {cmd:boottest} already feels fast in your applications, the {cmd:julia} option will probably not improve your life.

{pstd}However, for hard problems, such as ones involving the subcluster bootstrap, or multiway clustering in which all-cluster intersections are numerous, the Julia implementation
can be much faster.

{pstd}To use the Julia back end, you need to install several things. Because there is no direct software channel between Stata and Julia, {cmd:boottest} makes the 
connection by way of Python. The requirements list may therefore look intimidating. But set-up should be straightforward! The requirements:

{p 4 6 0}
* Stata 16 or newer.

{p 4 6 0}
* {browse "https://www.python.org/downloads/":Python} (free), with Stata {browse "https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python/":configured to use it}.

{p 4 6 0}
* Julia 1.7.0 or newer (free), {browse "https://julialang.org/downloads/platform":installed so that it is accessible through the system path}.

{p 4 6 0}
* Packages {browse "https://numpy.org/install":NumPy} and
{browse "https://pyjulia.readthedocs.io/en/stable/installation.html":PyJulia} for Python and {browse "https://github.com/JuliaRandom/StableRNGs.jl":StableRNGs} 
and {browse "https://github.com/droodman/WildBootTests.jl":WildBootTests} for Julia (all free). {cmd:boottest} should automatically install these when needed.

{pstd}The creators of Julia {browse "https://docs.julialang.org/en/v1.7/stdlib/Random/":do not guarantee} that the built-in algorithms for generating random numbers will
remain unchanged as Julia changes. To guarantee replicability of results, {cmd:boottest} therefore relies on the 
{browse "https://github.com/JuliaRandom/StableRNGs.jl":StableRNGs} package, which does make this guarantee. For the same reason, on each call, {cmd:boottest} initializes 
the Julia StableRNG with a seed extracted from the Stata random-number generator (RNG), so that seeding the Stata RNG will deterministically seed the Julia one.


{title:Stored results}

{pstd}
{cmd:boottest} stores the following in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(reps)}}number of bootstrap replications{p_end}
{synopt:{cmd:r(repsFeas)}}number of bootstrap replications producing feasible (non-missing) test statistics{p_end}
{synopt:{cmd:r(F)}}test statistic if making small-sample correction{p_end}
{synopt:{cmd:r(chi2)}}test statistic if not making small-sample correction{p_end}
{synopt:{cmd:r(t)}}appropriately signed square root of {cmd:r(F)}, if testing one null constraint{p_end}
{synopt:{cmd:r(z)}}appropriately signed square root of {cmd:r(chi2)}, if testing one null constraint{p_end}
{synopt:{cmd:r(df)}}test degrees of freedom{p_end}
{synopt:{cmd:r(df_r)}}residual degrees of freedom if making small-sample correction{p_end}
{synopt:{cmd:r(p)}}test p value{p_end}
{synopt:{cmd:r(padj)}}p value adjusted for multiple hypothesis testing, if requested{p_end}
{synopt:{cmd:r(null)}}indicates whether null imposed{p_end}
{synopt:{cmd:r(level)}}statistical signficance level for confidence interval, if any{p_end}
{synopt:{cmd:r(ptol)}}precision tolerance for identification of confidence set bounds{p_end}
{synopt:{cmd:r(NH0s)}}number of independent null hypotheses tested{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(seed)}}value of {opt seed(#)} option, if any, or else c(seed) at command invocation{p_end}
{synopt:{cmd:r(boottype)}}bootstrapping type{p_end}
{synopt:{cmd:r(weighttype)}}bootstrapping weight type{p_end}
{synopt:{cmd:r(robust)}}indicates robust/clustered test{p_end}
{synopt:{cmd:r(clustvars)}}clustering variables for test, if any{p_end}
{synopt:{cmd:r(CIstr)}}confidence set statement in string form{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(CI)}}bounds of confidence set; if disjoint, one row per piece{p_end}
{synopt:{cmd:r(plot)}}data for p value plot{p_end}
{synopt:{cmd:r(dist)}}t/z distribution, if requested with {opt svm:at}{p_end}
{synopt:{cmd:r(v)}}wild weight matrix, if requested with {opt svv}{p_end}
{synopt:{cmd:r(b)}}numerator of test statistic{p_end}
{synopt:{cmd:r(V)}}denominator (variance matrix) of test statistic{p_end}

{pstd}
If more than one independent hypotheses is tested, many return values listed above will be supplied
separately for each hypothesis, using suffixes _1, _2, ....


{title:Author}

{p 4}David Roodman{p_end}
{p 4}david@davidroodman.com{p_end}


{title:Citation}

{p 4 8 2}{cmd:boottest} is not an official Stata command. It is a free contribution to the research community.
Please cite: {p_end}
{p 8 8 2}Roodman, D., J. MacKinnon, M. Nielsen, and M. Webb. 2019. Fast and wild: bootstrap inference in Stata using boottest. {it:Stata Journal} 19(1): 
4-60. DOI: 10.1177/1536867X19830877.{p_end}

{title:Errata}
{p 4}Appendix A of Roodman et al. (2019) contains these errors:

{p 4 6 0}
* The right side of (57) is missing a {bf:T}_1 on the far left and a {bf:T}_1' on the far right.

{p 4 6 0}
* In the second expression in (60), the colsum() operator should be inside the sum operation rather than outside. The {bf:J}_{it:c} matrices differ in height and so are
not conformable before colsum() is applied.

{p 4 6 0}
* In the second term of (64), the second {it:c} subscript needs a * superscript, just as in (62).

{p 4 6 0}
* In appendix A.2, the mathematical statement of linearity, {bf:P + Qr}, is technically incorrect, because it is meant to represent a linear map from vectors to matrices,
not merely vectors to vectors. A more precise expression is vec({bf:P}) + vec({bf:Q}){bf:r}.

{title:Donate?}

{pstd}
Has {cmd:boottest} improved your career or marriage? Consider
giving back through a {browse "http://j.mp/1iptvDY":donation} to support the work of its author, {browse "http://davidroodman.com":David Roodman}.


{title:Examples}

{phang}. {stata "use https://raw.githubusercontent.com/droodman/boottest/master/data/collapsed"}{p_end}

{phang}. {stata regress hasinsurance selfemployed post post_self, cluster(year)}{p_end}
{phang}. {stata boottest post_self=.04} // wild bootstrap, Rademacher weights, null imposed, 999 replications{p_end}
{phang}. {stata boottest post_self=.04, weight(webb) noci} // wild bootstrap, Webb weights, null imposed, 999 replications, no graph or CI{p_end}
{phang}. {stata boottest post_self=.04, weight(webb) noci jk} // same, but jackknifed{p_end}
{phang}. {stata scoretest post_self=.04}{space 18} // Rao score/Lagrange multipler test of same{p_end}

{phang}. {stata boottest post_self post, reps(9999) weight(webb)} // wild bootstrap test of joint null, Webb weights, null imposed, 9,999 replications{p_end}
{phang}. {stata boottest (post_self) (post), reps(9999) weight(webb)} // same{p_end}
{phang}. {stata boottest {post_self=.04} {post}} // separate tests, no correction for multiple hypotheses{p_end}
{phang}. {stata boottest {(post) (post_self=.04)} {(post) (post_self=.08)}, madj(sidak)} // separate tests, Sidak correction for multiple hypotheses{p_end}

{phang}. {stata webuse nlsw88}{p_end}

{phang}. {stata regress wage tenure ttl_exp collgrad, cluster(industry)}{p_end}
{phang}. {stata boottest tenure, svmat}{space 8} // wild bootstrap test of joint null, Rademacher weights, null imposed, saving simulated distribution{p_end}
{phang}. {stata mat dist = r(dist) }{p_end}
{phang}. {stata svmat dist}{p_end}
{phang}. {stata histogram dist1, xline(`r(t)')} // histogram of bootstrapped t statistics{p_end}

{phang}. {stata constraint 1 ttl_exp = .2} {p_end}
{phang}. {stata cnsreg wage tenure ttl_exp collgrad, constr(1) cluster(industry)}{p_end}
{phang}. {stata boottest tenure} // wild bootstrap test of tenure=0, conditional on ttl_exp=2, Rademacher weights, null imposed, 999 replications{p_end}

{phang}. {stata regress wage tenure ttl_exp collgrad south#union, cluster(industry)} {p_end}
{phang}. {stata margins south}{p_end}
{phang}. {stata boottest, margins}  // bootstrap CI of average predicted wage for south = 0 and 1{p_end}
{phang}. {stata margins, dydx(south)}{p_end}
{phang}. {stata boottest, margins graphopt(xtitle(Average effect of south))}  // bootstrap CI of average impact in sample of changing south from 0 to 1{p_end}

{phang}. {stata ivregress 2sls wage ttl_exp collgrad (tenure = union), cluster(industry)}{p_end}
{phang}. {stata boottest tenure, ptype(equaltail) seed(987654321)} // Wald test, wild restricted efficient bootstrap, Rademacher weights, null imposed, 999 reps{p_end}
{phang}. {stata boottest tenure, ptype(equaltail) seed(987654321) jk} // same but using jackknife to construct residuals for bootstrap{p_end}
{phang}. {stata boottest, ar} // Anderson-Rubin test (much faster){p_end}
{phang}. {stata scoretest tenure} // Rao/LM test of same{p_end}
{phang}. {stata waldtest tenure} // Wald test of same{p_end}

{phang}. {stata ivregress liml wage (tenure = collgrad ttl_exp), cluster(industry)}{p_end}
{phang}. {stata boottest tenure, noci} // WRE bootstrap, Rademacher weights, 999 replications{p_end}
{phang}. {stata cmp (wage = tenure) (tenure = collgrad ttl_exp), ind(1 1) qui nolr cluster(industry)}{p_end}
{phang}. {stata boottest tenure} // reasonable match on test statistic and p value{p_end}

{phang}. {stata ivreg2 wage collgrad smsa race age (tenure = union married), cluster(industry) fuller(1)}{p_end}
{phang}. {stata boottest tenure, seed(934871) format(%5.2f) nograph}  // Wald test, WRE bootstrap, Rademacher weights, 999 replications{p_end}
{phang}. {stata estadd local CIstr "`r(CIstr)'"}  // Store string description of confidence set as e(CIstr){p_end}
{phang}. {stata boottest, nograph ar} // same, but Anderson-Rubin (faster, but CI misleading if instruments invalid){p_end}

{phang}. {stata ivregress liml wage (collgrad tenure = ttl_exp union), cluster(industry)}{p_end}
{phang}. {stata boottest, ar} // Anderson-Rubin test, with contour plot of p value surface{p_end}
{phang}. {stata boottest collgrad tenure, gridpoints(10 10)} // WRE boostrap also with contour plot{p_end}

{phang}. {stata regress wage ttl_exp collgrad tenure, cluster(industry)}{p_end}
{phang}. {stata waldtest collgrad tenure, cluster(industry age)} // multi-way-clustered tests after estimation command not offering such{p_end}
{phang}. {stata boottest tenure, cluster(industry age) bootcluster(industry) gridmin(-.2) gridmax(.2)}{p_end}

{phang}. {stata areg wage ttl_exp collgrad tenure [aw=hours] if occupation<., cluster(age) absorb(industry)}{p_end}
{phang}. {stata boottest tenure, cluster(age occupation) bootcluster(occupation) seed(999) nograph} // override estimate's clustering{p_end}
{phang}. {stata reg wage ttl_exp collgrad tenure i.industry [aw=hours] if occupation<., cluster(age)}{p_end}
{phang}. {stata boottest tenure, cluster(age occupation) bootcluster(occupation) seed(999) nograph} // should match previous result{p_end}

{phang}. {stata probit c_city tenure wage ttl_exp collgrad, cluster(industry)}{p_end}
{phang}. {stata boottest tenure}{space 25} // score bootstrap, Rademacher weights, null imposed, 999 replications{p_end}
{phang}. {stata boottest tenure, cluster(industry age) bootcluster(industry) small} // multi-way-clustered, finite-sample-corrected test with score bootstrap{p_end}

{phang}. {stata gsem (c_city <- tenure wage ttl_exp collgrad), vce(cluster industry) probit} // same probit estimate as previous{p_end}
{phang}. {stata boottest tenure}{space 60} // requires Stata 14.0 or later {p_end}
{phang}. {stata boottest tenure, cluster(industry age) bootcluster(industry) small}{space 9} // requires Stata 14.0 or later{p_end}

{phang}. {stata sysuse auto}{p_end}
{phang}. {stata program myprobit} // custom likelihood evaluator{p_end}
{phang}. {stata 	args lnf theta}{p_end}
{phang}. {stata 	quietly replace `lnf' = lnnormal((2*$ML_y1-1) * `theta')}{p_end}
{phang}. {stata end}{p_end}
{phang}. {stata ml model lf myprobit (foreign = mpg weight)} // define model{p_end}
{phang}. {stata ml max} // estimate{p_end}
{phang}. {stata boottest mpg, cmdline(ml model lf myprobit (foreign = mpg weight))} // score bootstrap; pass the model definition since {cmd:ml} doesn't save it in {cmd:e(cmdline)}{p_end}

{title:References}

{p 4 8 2}Anderson, T.W., and H. Rubin. 1949. Estimation of the parameters of a single equation
in a complete system of stochastic equations. {it:Annals of Mathematical Statistics} 20: 46-63.{p_end}
{p 4 8 2}Baum, C.F., M.E. Schaffer, and S. Stillman. 2007. Enhanced routines for instrumental variables/GMM estimation and 
testing. {it:Stata Journal} 7(4): 465-506.{p_end}
{p 4 8 2}Cameron, A.S., J.B. Gelbach, and D.L. Miller. 2006. Robust inference with multi-way clustering. NBER technical working paper 327.{p_end}
{p 4 8 2}Cameron, A.C., J.B. Gelbach, and D.L. Miller. 2008. Bootstrap-based improvements for inference with clustered errors.
{it:The Review of Economics and Statistics} 90(3): 414-27.{p_end}
{p 4 8 2}Cameron, A.C., and D.L. Miller. 2015. A practitioner’s gtuide to cluster-robust
inference. {it:Journal of Human Resources} 50(2): 317-72.{p_end}
{p 4 8 2}Chandrupatla, T.R. 1997. A new hybrid quadratic-bisection algorithm for finding the zero of a nonlinear function without using 
derivatives. {it:Advances in Engineering Software} 28(3): 145-49.{p_end}
{p 4 8 2}Davidson, R., and E. Flachaire. 2008. The wild bootstrap, tamed at last. {it:Journal of Econometrics} 146: 162-69.{p_end}
{p 4 8 2}Davidson, R., and J.G. MacKinnon. 1999. The size distortion of bootstrap tests. {it:Econometric Theory} 15: 361-76.{p_end}
{p 4 8 2}Davidson, R., and J.G. MacKinnon. 2010. Wild bootstrap tests for IV regression. {it:Journal of Business & Economic Statistics} 28(1): 128-44.{p_end}
{p 4 8 2}Finlay, K., and L. Magnusson. 2019. Two applications of wild bootstrap methods to improve
inference in cluster-IV models. DOI: 10.1002/jae.2710.{p_end}
{p 4 8 2}Fisher, N.I., and P. Hall. 1990. On bootstrap hypothesis testing. {it:Australian Journal of Statistics} 32(2): 177-90.{p_end}
{p 4 8 2}Kline, P., and Santos, A. 2012. A score based approach to wild bootstrap 
inference. {it:Journal of Econometric Methods} 1(1): 23-41.{p_end}
{p 4 8 2}Liu, R. Y. 1988. Bootstrap procedures under some non-I.I.D. models. {it:Annals of Statistics} 16: 1696-1708.{p_end}
{p 4 8 2}MacKinnon, J.G., M.O. Nielsen, and M.D. Webb. 2017. Bootstrap and asymptotic inference with multiway clustering. Queen's Economics Department Working Paper No. 1386.{p_end}
{p 4 8 2}MacKinnon, J.G., M.O. Nielsen, and M.D. Webb. 2023. Fast and Reliable Jackknife and Bootstrap Methods for Cluster-Robust Inference. Queen's Economics Department Working Paper No. 1485.{p_end}
{p 4 8 2}MacKinnon, J.G., and M.D. Webb. 2018. The wild bootstrap for few (treated) clusters. {it:Econometrics Journal} 21: 114-35.{p_end}
{p 4 8 2}Mammen, E. 1993. Bootstrap and wild bootstrap for high dimensional linear models. {it:Annals of Statistics} 21: 255-85.{p_end}
{p 4 8 2}Rao, C.R. 1948. Large sample tests of statistical hypotheses concerning several parameters with applications to problems of
estimation. {it:Proc. Cambridge Philos. Soc.} 44: 50-57.{p_end}
{p 4 8 2}Roodman, D., J. MacKinnon, M. Nielsen, and M. Webb. 2019. Fast and wild: bootstrap inference in Stata using boottest. {it:Stata Journal} 19(1): 4-60.{p_end}
{p 4 8 2}Wald, A. 1943. Tests of statistical hypotheses concerning several parameters when the number of observations is
large. {it:Transactions of the American Mathematical Society} 54: 426-82.{p_end}
{p 4 8 2}Wang, W. 2021. Wild Bootstrap for Instrumental Variables Regression with Weak Instruments and Few Clusters. https://mpra.ub.uni-muenchen.de/106227.{p_end}
{p 4 8 2}Webb, M.D. 2014. Reworking wild bootstrap based inference for clustered errors. Queen's Economics Department Working Paper No. 1315.{p_end}
{p 4 8 2}Wu, C.F.J. 1986. Jackknife, bootstrap and other resampling methods in regression analysis (with discussions). {it:Annals of Statistics}
14: 1261-1350.{p_end}
{p 4 8 2}Young, A. 2022. Consistency without inference: Instrumental variables in practical application. {it:European Economic Review} 147.{p_end}
