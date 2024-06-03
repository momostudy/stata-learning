{smcl}
{* *! version 1.0.6  06feb2023}{...}
{title:Title}

{phang}
{bf:ardl}   {hline 2}   Autoregressive distributed lag regression model

{* foldend}{* foldbeg}{* * * SYNTAX * * *}{marker syntax}
{title:Syntax}

{p 8 17 2}
{cmd:ardl} {depvar} [{indepvars}] {ifin} [{cmd:,} {it:options}]

{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{help ardl##model:Model}}
{synopt:{opth la:gs(numlist)}}set lag lengths{p_end}
{synopt:{opt ec}}estimate with {it:depvar} in first differences and display output in error-correction form{p_end}
{synopt:{opt ec1}}like option {opt ec}, but parameterizes long-run coefficients as of time t-1{p_end}
{synopt:{opt e:xog(exogvars)}}exogenous variables in regression{p_end}
{synopt:{opt noc:onstant}}suppress constant term{p_end}
{synopt:{opt tr:endvar}[{bf:(}{it:trendvarname}{bf:)}]}add time trend to the model{p_end}
{synopt:{opt res:tricted}}restrict constant or trend term (see {help ardl##deterministiccomponents:Deterministic components}){p_end}
{synopt:{opt r:egstore(storename)}}stores estimation results from underlying {cmd:regress} command as {it:storename}{p_end}
{synopt:{opt per:fect}}do not check for collinearity{p_end}

{syntab:{help ardl##lagselection:Lag selection}}
{synopt:{opth m:axlags(numlist)}}set maximum lag lengths{p_end}
{synopt:{opt maxc:ombs(combnum)}}set maximum number of lag permutations for lag selection to {it:combnum}; default: 100000{p_end}
{synopt:{opt aic}}use AIC as information criterion{p_end}
{synopt:{opt bic}}use BIC as information criterion; the default{p_end}
{synopt:{opt matcr:it(lagcombmat)}}save combinations of lags across which lag selection has searched in matrix {it:lagcombmat}; includes the information criterion for each lag specification{p_end}
{synopt:{opt nofast}}use slow method for finding the optimal lag structure{p_end}

{syntab:{help ardl##reporting:Reporting}}
{synopt:{opt dot:s}}display one dot for each 1% progress of optimal lag selection{p_end}
{synopt:{opt noct:able}}do not display coefficient table{p_end}
{synopt:{opt nohe:ader}}do not display coefficient table header{p_end}
{synopt:{it:{help ardl##display_options:display_options}}}control column formats, row spacing, line width, and display of omitted variables{p_end}

{syntab:{help ardl##other:Other}}
{* {synopt:{opt nosign}}do not sign estimation sample{p_end}}{...}
{synopt:{it:{help ardl_legacy:legacy_options}}}Legacy, out-of-date options of former versions of the command that continue to work{p_end}
{synoptline}
{p 4 6 2}You must {cmd:tsset} your data before using {cmd:ardl}; see {helpb tsset:[TS] tsset}.{p_end}
{p 4 6 2}{cmd:by} is allowed; see {manhelp by D}.{p_end}
{p 4 6 2}{it:depvar} and {it:indepvars} may NOT contain time-series operators.{p_end}
{p 4 6 2}See {help ardl postestimation} for features available after estimation.{p_end}


{* foldend}{* foldbeg}{* * * DESCRIPTION * * *}{marker description}{...}
{title:Description}

{pstd}
{cmd:ardl} fits a linear regression model of {depvar} on {indepvars} with lagged {it:depvar} and {it:indepvars} as additional regressors.
Information criteria are used to find the optimal lag lengths, if those are not pre-specified via option {opt lags()}.
Estimation output is delivered either in levels form or in error-correction form.


{* foldend}{* foldbeg}{* * * ABBREVIATIONS * * *}{marker abbreviations}{...}
{title:Abbreviations and definitions used in the help entries of the {cmd:ardl} package}

{p2colset 5 20 20 0}{...}
{p2col:Abbreviations:}{p_end}
{p2col:}{p_end}
{p2col:ARDL:}auto-regressive distributed lag{p_end}
{p2col:CV:}critical value{p_end}
{p2col:KS:}{help ardl##KS2020:Kripfganz and Schneider (2020)}{p_end}
{p2col:NAR:}{help ardl##N2005:Narayan (2005)}{p_end}
{p2col:PSS:}{help ardl##PSS2001:Pesaran, Shin, and Smith (2001)}{p_end}
{p2col:VECM:}vector error-correction model{p_end}
{pstd}
See also the remarks section on {help ardl##terminology:terminology} below.


{* foldend}{* foldbeg}{* * * OPTIONS * * *}{marker options}{...}
{title:Options}

{marker model}{...}
{dlgtab:Model}

{phang}
{opth la:gs(numlist)} specifies the number of lags for some or all regressors.
The first number specifies the lag length for {depvar} that has to be larger than 0; the following numbers specify the lag lengths for the independent variables in the order they appear in {indepvars}.
0 lags is possible for the long-run regressor variables but never for the lag order of the dependent variable.
Missing values indicate lags that are not pre-specified.
Information criteria are used to determine them.
For example, {cmd:lags(. . 4)} requires the second independent variable to enter with 4 lags while the lags of the dependent variable and the first independent variable are to be determined by an information criterion.

{pmore} The number of elements in {it:numlist} (positive integers or dots) must be equal to the number of variables specified in the command line ({it:depvar} + {it:indepvars}).
Alternatively, {it:numlist} may only contain one element, in which case this number applies to all variables in {it:depvar} and {it:indepvars}.

{phang}
{opt ec} will estimate the model in 'first-difference' form (see the remarks section on {help ardl##terminology:Terminology} below) and display the output in error-correction form.
Long-run coefficients are parameterized as of time t.

{phang}
{opt ec1} works like option {opt ec} but uses a parameterization of the model that writes the long-run coefficient regressors as of time t-1.
The two parameterizations will yield identical coefficient values, with the exception of the first first-difference term of each long-run regressor.

{pmore}
Note that it is still possible to have a lag order of zero for one or more regressors.
In this case the covariance matrix will not have full rank.
For more details on the different parameterizations, see the remarks section {help ardl##longruncoefficients:Long-run coefficients expressed in time t or t-1}.

{phang}
{opth e:xog(exogvars)} specifies additional variables to be tagged on to the regression.

{phang}
{opt noc:onstant} suppresses the constant term in the model.

{phang}
{opt tr:endvar}{bf:[}({it:trendvarname}){bf:]} lets you add a time trend term to your model.
{it:trendvarname} must exist in the data set before execution of {cmd:ardl} and it must be collinear with {it:timevar}, where {it:timevar} is the time variable set by {help tsset}.
You may omit {it:trendvarname}: Specifying just {opt tr:endvar} is equivalent to {opt trendvar(timevar)}.

{phang}
{opt res:tricted} will restrict either the constant term or the time trend, if any of the two are specified.
See {help ardl##deterministiccomponents:Deterministic components} below.

{pmore}
If no deterministics are in the model, {opt restricted} will cause an error.

{phang}
{opt r:egstore(storename)} will store the estimation results from the underlying regress command.
See {help estimates}.

{pmore}
In many cases, you do not have to use option {opt regstore()} to perform model
diagnostics that relate to the underlying {cmd:regress} command of {cmd:ardl}
since that normally works immediately after {cmd:ardl}.
See {help ardl postestimation}.
However, if the latter procedure fails for some reason, {opt regstore()} provides an alternative.

{pmore}
Another potential use for {opt regstore()} is to access the regression on which
the output for the error-correction form (option {opt ec} or {opt ec1}) is based.
The equation that is actually estimated was called the "first-difference equation"
in section {help ardl##terminology:terminology}.
The output shown corresponds to the "error-correction equation".
Compare equations (FDF0) to (ECF0) (or equations (FDF1) to (ECF1))
in the section on {help ardl##longruncoefficients:long-run coefficients}
to see the difference between the estimated and
presented equations for an ARDL(1,1) model.

{pmore}
Note that if an estimation results set called {it:storename} already exists option {opt regstore()} will overwrite it without warning.

{phang}
{opt per:fect} omits the check for collinearity among the regressors.

{marker lagselection}{...}
{dlgtab:Lag selection}

{phang}
{opt m:axlags(numlist)} specifies the maximum lag order used for optimal lag selection.
The first number specifies the maximum lag length for {depvar} that has to be larger than 0; the following numbers specify the maximum lag lengths for the independent variables in the order they appear in {indepvars}.
The default maximum lag order is 4.

{pmore}
Since {opt maxlags} only deals with optimal lag order selection, values for all or some of its elements are ignored if {opt lags()} indicates pre-specified lags for some or all variables.

{pmore} The number of elements in {it:numlist} (positive integers or dots) must be equal to the number of variables specified in the command line ({it:depvar} + {it:indepvars}).
 Alternatively, {it:numlist} may only contain one element, in which case this number applies to all variables in {it:depvar} and {it:indepvars}.

{phang}
{opt maxc:ombs(combnum)} specifies the maximum number of lag permutations allowed for the optimal lag selection.
If the number of lag permutations required to find the optimal lag lengths exceeds {it:combnum}, {cmd:ardl} errors out.
The default for {it:combnum} is 100,000.
You can set {it:combnum} to higher values.
If you use option {opt nofast}, the default for {it:combnum} is 500.

{pmore}
If you have to specify a large number for {opt maxcombs()}, say 1,000,000, the computations will take some time.
You will always be able to hit the break key if you want to interrupt execution.

{phang}
{opt bic} and {opt aic} specify which information criterion is used.

{phang2}
{opt aic} is used to determine the optimal lag lengths with the Akaike information criterion.

{phang2}
{opt bic} is used to determine the optimal lag lengths with the Bayesian information criterion.

{pmore}
{opt bic} is the default.
You may not use both options at the same time.

{pmore}
Information on the information criterion is only necessary if optimal lag order
selection is performed or if you use option {opt matcrit()}.
If these options are not used, any specification
of {opt bic} and/or {opt aic} is ignored.

{phang}
{opt matcr:it(lagcombmat)} saves the combinations of lags across which lag selection has searched in matrix {it:lagcombmat}.
The matrix also shows the information criterion value for each lag specification.

{pmore}
Before version 0.7.0 of {cmd:ardl}, this matrix was saved automatically in {bf:e(lagcombs)}.
Since the necessary matrix copy operations slow down command execution noticably for large numbers of lag combinations, this has been abandoned.
You have to ask for the creation of this matrix explicitly by using option {opt matcrit()}.

{pmore}
Potentially, {it:lagcombmat} has a large number of rows.
Note that {cmd:ardl} will perform its calculations and define {it:lagcombmat} regardless of what your
current size limit for Stata matrices is
(see {help matsize} for Stata 15 and lower versions and {help limits} for Stata 16 and higher versions).
While you will always be able to display {it:lagcombmat}, many matrix operations on it
(like matrix indexing) may result in Stata errors if its number of rows exceeds your Stata matrix limit.

{phang}
{opt nofast} uses {cmd:regress} instead of Mata code to perform auxiliary regressions for finding the optimal lag lengths.
This is much slower but in rare cases may be more robust in terms of computer numerics.

{marker reporting}{...}
{dlgtab:Reporting}

{phang}
{opt dot:s} displays information on the progress of the optimal lag selection.
This is useful if the selection procedure considers higher lag orders for a larger number of regressors.
Each dot displayed represents a 1% progress in the calculation of all models considered.

{phang}
{opt noct:able} suppresses the display of the coefficient table.

{phang}
{opt nohe:ader} suppresses the display of the coefficient table header.

{marker display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opth cformat(%fmt)},
{opt pformat(%fmt)},
{opt sformat(%fmt)}, and (Stata 12+ only)
{opt nolstretch};
    see {helpb estimation options##display_options:[R] estimation options}.

{marker other}{...}
{dlgtab:Other}
{* {opt nosign} skips signing the estimation sample. The latter is only necessary if you plan on using postestimation commands that are normally used after {cmd:regress}.}{...}
{* See {help regress postestimation:here} and {help regress postestimation ts:here}. Specifying {opt nosign} provides a small speed advantage that should normally not be noticeable.}{...}

{phang}
{it:{help ardl_legacy:legacy_options}} consist of options of former versions of
the command. They are out-of-date but continue to work
in order to not break existing user code.
If you have not used them before, consider them irrelevant, since the current
implementation of the command provides better alternatives.{p_end}


{* foldend}{* foldbeg}{* * * REMARKS * * *}{marker remarks}{...}
{title:Remarks}

{pstd}
Remarks are presented under the following headings:

    {help ardl##introduction:Introduction}
    {help ardl##terminology:Terminology}
    {help ardl##lagspecification:Lag specification}
    {help ardl##deterministiccomponents:Deterministic components}
    {help ardl##longruncoefficients:Long-run coefficients expressed in time t or t-1}
    {help ardl##errorcorrectionterm:The error-correction term}
    {help ardl##boundstest:Bounds test for a level relationship}
    {help ardl##pureAR:Pure autoregressive processes}

{* foldend}{* foldbeg}{* * * REMARKS INTRODUCTION * * *}{marker introduction}{...}
{title:Introduction}

{pstd}
A autoregressive distributed lag (ARDL) model of order {it:p} and {it:q}, denoted ARDL({it:p},{it:q}) regresses the dependent variable on {it:p} of its own lags and on {it:q} lags of one or more additional regressors.
Multiple regressors are allowed to have different lag orders, in which case the model becomes an ARDL(p, q_1, ..., q_k) model, where  k is the number of non-deterministic regressors.
ARDL models can, among other things, be used for the estimation and testing of level relationships.

{pstd}
Key contributions in this area are {help ardl##PS1999:Pesaran and Shin (1999)} and {help ardl##PSS2001:Pesaran, Shin and Smith (1999)}.
For an exposition of the econometrics of ARDL models and their implementation in this command, see {help ardl##KS2022:Kripfganz and Schneider (2022)}.
For a succinct exposition of ARDL models in the context of cointegration, see {help ardl##HW2005:Hassler and Wolters (2005, 2006)}.

{* foldend}{* foldbeg}{* * * REMARKS TERMINOLOGY * * *}{marker terminology}{...}
{title:Terminology}

{pstd}
The regression equation in the sense of the preceding paragraph is referred to as the {cmd:levels equation}.
This equation can be rewritten such that the differenced {it:depvar} is expressed in terms of the lagged {it:depvar}, levels of {it:indepvars}, and differenced terms of ({it:depvar}, {it:indepvars}) up to orders (p-1, q_1-1, ...,q_k-1).
This way of writing the ARDL model is referred to here as the {cmd:first-difference form} or equation, although this is a slight abuse of terminology since it is a mere reparameterization of the levels equation.
Dividing the coefficient for the levels regressors by the coefficient of the lagged {it:depvar} and appropriately accounting for model deterministics then yields the {cmd:error-correction form}.
It separates the adjustment coefficient to deviations from long-run equilibrium, long-run coefficients, and short-run coefficients.

{pstd}
The remarks section {help ardl##longruncoefficients:Long-run coefficients expressed in time t or t-1} shows the different parameterizations for the case of an ARDL(1,1) model.

{pstd}
{cmd:ardl} without option {opt ec} will run a regression of the levels equation, save the dependent variable and the regressors in the macros e(depvar) and e(regressors) and in the matrix e(b), and display a corresponding table of estimates.
If option {opt ec} (or {opt ec1}) is used, {cmd:ardl} will run a regression corresponding to the first-difference equation and save the dependent variable and the regressors in the macros e(depvar) and e(regressors).
The coefficient output table and e(b) will be in terms of the error-correction form.

{* foldend}{* foldbeg}{* * * REMARKS LAGSPECIFICATION * * *}{marker lagspecification}{...}
{title:Lag specification}

{pstd}
Lags specified in options {opt lags} and {opt maxlags} refer to lags in the levels equation, whether option {opt ec} is used or not.
For example, if you use {cmd:lags(2 4 4)}, the dependent variable will have two lags in the levels regression and the two independent variables will have four lags in the levels regression.
The lag length of the first differences in the first-difference equation will be one less for each variable.

{pstd}
In a similar fashion, any lag information saved in {bf:e()} will refer to the levels equation.

{* foldend}{* foldbeg}{* * * REMARKS DETERMINISTICCOMPONENTS * * *}{marker deterministiccomponents}{...}
{title:Deterministic components}

{pstd}
In the vector error-correction model (VECM) literature, it is common to distinguish five different cases of model deterministics:

{p2colset 8 18 18 0}{...}
{p2col:{it:casenum}}{it:description}{p_end}
{p2line}
{p2col:1}no constant, no trend{p_end}
{p2col:2}restricted constant, no trend{p_end}
{p2col:3}unrestricted constant, no trend{p_end}
{p2col:4}unrestricted constant, restricted trend{p_end}
{p2col:5}unrestricted constant, unrestricted trend{p_end}
{p2colreset}{...}

{pstd}
Rewriting the levels equation in first-difference form yields restrictions on the constant term and the linear trend.
Cases 2 and 4 impose the implied restriction.
If these restrictions are ignored (cases 3 and 5), a constant term in the first-difference equation can generate a linear trend in the levels equation.
Likewise, an unrestricted trend in the first-difference equation can generate a quadratic trend in the levels equation.
For a more detailed exposition, see for example {help ardl##L2005:Luetkepohl (2005)}, section 6.4, or {manlink TS vec}.

{pstd}
Stata's {help vec} command, which estimates VECMs, distinguishes between the same five cases through its {opt trend} option.
The following table provides a mapping between case numbers and {cmd:vec} syntax.

{p2colset 8 18 18 0}{...}
{p2col:{it:casenum}}{cmd:vec} {it:syntax}{p_end}
{p2line}
{p2col:1}trend(none){p_end}
{p2col:2}trend(rconstant){p_end}
{p2col:3}trend(constant){p_end}
{p2col:4}trend(rtrend){p_end}
{p2col:5}trend(trend){p_end}
{p2colreset}{...}

{pstd}
The {cmd:ardl} syntax for determining the {it:casenum} is different from {cmd:vec} but close to standard Stata syntax for linear regressions.
A constant term can be omitted by using option {opt noconstant}.
To include a time trend, generate a separate trend variable and include it in option {opt trendvar}.
If you want to have a linear time trend and your time series variable is named {it:timevar}, you can simply use {cmd:trendvar({it:timevar})}.
The table below provides a mapping between case numbers and {cmd:ardl} options.
Note that a constant is included in the model by default which is why the option {opt constant} below is in brackets.
It is redundant to specify this option explicitly.

{p2colset 8 18 18 0}{...}
{p2col:{it:casenum}}{cmd:ardl} options{p_end}
{p2line}
{p2col:1}noconstant{p_end}
{p2col:2}[constant] restricted{p_end}
{p2col:3}[constant]{p_end}
{p2col:4}[constant] trendvar({it:trendvarname}) restricted{p_end}
{p2col:5}[constant] trendvar({it:trendvarname}){p_end}
{p2colreset}{...}

{pstd}
Whereas the specification of deterministics has considerable implications for the estimation procedures of VECMs, this is not so for ARDL models.
In the conditional ARDL modelling approach proposed by PSS, for example, cases 2 and 3 and cases 4 and 5 are based on identical linear regressions of the first-difference equation.
The distinction within each case-pair concerns the interpretation of the deterministic terms, i.e. whether they are considered to be part of the long-run relationship or not.
Accordingly, the asymptotic distribution for the test for a levels-relationship advanced in PSS is different for each case.
{help ardl##KS2022:Kripfganz and Schneider (2022, section 2.4)} discuss model deterministics
in the context of ARDL modelling.

{* foldend}{* foldbeg}{* * * REMARKS LONGRUNCOEFFICIENTS * * *}{marker longruncoefficients}{...}
{title:Long-run coefficients expressed in time t or t-1}

{pstd}
It is possible to write the error-correction form with levels regressors expressed in time t or in time t-1.
These are just different parameterizations.
We show the two parameterizations for an ARDL(1,1) model.
Equations shown refer to the different forms explained in the remarks section on {help ardl##terminology:Terminology}.
In the equation labels below, read "LE" as "levels equation", "FDF" as "first-difference form", and
"ECF" as "error-correction" form.
Equations (FDF0)-(ECF0) and (FDF1)-(ECF1) express the regressors in the long-run relationship in time t and in time t-1, respectively.
The long-run relationship term appears in brackets.

{pmore}
(LE){space 3} y(t) = c + a_1 * y(t-1) + b_0 * x(t) + b_1 * x(t-1) + e(t)

{pmore}
(FDF0) dy(t) = c + (a_1 - 1) * y(t-1) + (b_0 + b_1) * {error:x(t)}{space 2} {error:- b_1} * dx(t) + e(t){break}
(ECF0) dy(t) = c - (1 - a_1) * {bf:[}y(t-1) - (b_0 + b_1) / (1 - a_1) * {error:x(t)}{space 2}{bf:]} {error:- b_1} * dx(t) + e(t)

{pmore}
(FDF1) dy(t) = c + (a_1 - 1) * y(t-1) + (b_0 + b_1) * {error:x(t-1)} {error:+ b_0} * dx(t) + e(t){break}
(ECF1) dy(t) = c - (1 - a_1) * {bf:[}y(t-1) - (b_0 + b_1) / (1 - a_1) * {error:x(t-1)}{bf:]} {error:+ b_0} * dx(t) + e(t)

{pstd}
You can estimate (ECF0) using option {opt ec} and (ECF1) using option {opt ec1}.
Note that (ECF0) and (ECF1) feature identical coefficient expressions in the long-run relationship.

{pstd}
Note that it is possible to estimate a model with zero lag regressors and express it in (ECF1).
The resulting covariance matrix of the estimates is singular, however.
With a lag order of zero for the x-regressor (ARDL(1,0)), the above equations become:

{pmore}
(FDF0b) dy(t) = c + (a_1 - 1) * y(t-1) + b_0 * {error:x(t)} + e(t){break}
(ECF0b) dy(t) = c - (1 - a_1) * {bf:[}y(t-1) - b_0 / (1 - a_1) * {error:x(t)}{bf:]} + e(t)

{pmore}
(FDF1b) dy(t) = c + (a_1 - 1) * y(t-1) + b_0 * {error:x(t-1)} + b_0 * {error:dx(t)} + e(t){break}
(ECF1b) dy(t) = c - (1 - a_1) * {bf:[}y(t-1) - b_0 / (1 - a_1) * {error:x(t-1)}{bf:]} + b_0 * {error:dx(t)} + e(t)

{pstd}
(FDF0b) and (FDF1b) are identical equations since b_0 * x(t) = b_0 * x(t-1) + b_0 * x(t) - b_0 * x(t-1) = b_0 * x(t-1) + b_0 * dx(t).

{pstd}
Presenting a model in error-correction form (options {opt ec} or {opt ec1}) takes virtually no
computational time, except for the case of equations like (ECF1b), i.e., when using the
error-correction form with the long-run coefficients expressed in time t-1 (option {opt ec1})
{it:and} when there is at least one zero-lag regressor. The internal reformulation of (FDF0b) as (FDF1b)
currently carries some computational cost for models with many regressors and lags.

{* foldend}{* foldbeg}{* * * REMARKS ERRORCORRECTIONTERM * * *}{marker errorcorrectionterm}{...}
{title:The error-correction term}

{pstd}
The error-correction term or long-run relationship is the term in brackets in equations (ECF0) (or (ECF1)) of the previous section.
The signs of the long-run coefficients in the regression output table, however, are inverted with respect to (ECF0) (or (ECF1)).
That is, they follow the convention of showing the long-run relation as a separate equation:

{pmore}
from (ECF0): {bf:[}y(t-1) {error:=} (b_0 + b_1) / (1 - a_1) * x(t){bf:]}{break}
from (ECF1): {bf:[}y(t-1) {error:=} (b_0 + b_1) / (1 - a_1) * x(t-1){bf:]}

{pstd}
For example, look at:

{phang2}{stata webuse lutkepohl2:. webuse lutkepohl2}{p_end}
{phang2}{stata ardl ln_consump ln_inc , lags(1) ec:. ardl ln_consump ln_inc , lags(1) ec}{p_end}

    {it:(output omitted)}
    ---------------------------------------------------------------
    D.ln_consump | Coef.  Std. Err.      t   P>|t|  [95% Conf. Int]
    -------------+-------------------------------------------------
    ADJ          |
      ln_consump |
             L1. |-0.297     0.058   -5.099  0.000  -0.412  -0.181
    -------------+-------------------------------------------------
    LR           |
          ln_inc |
             --. | 0.964     0.006  168.227  0.000   0.952   0.975
    -------------+-------------------------------------------------
    {it:(output omitted)}

{pstd}
The regression table displays the long-run relationship L.ln_consump = 0.964 * ln_inc.
Option {opt ec} of {cmd:predict}, by contrast, calculates L.ln_consump - 0.964 * ln_inc.
See {help ardl_postestimation:ardl postestimation}.
The adjustment term in this example is (a_1 - 1) = -(1 - a_1) = -0.297

{* foldend}{* foldbeg}{* * * REMARKS BOUNDSTEST * * *}{marker boundstest}{...}
{title:Bounds test for a level relationship}

{pstd}
For testing using critical values and approximate p-values based on response surface regressions from
{help ardl##KS2020:KS} for the PSS bounds testing procedure, use {cmd:estat ectest};
see {help ardl_postestimation##ectest:ardl postestimation}.
{help ardl##KS2022:Kripfganz and Schneider (2022, section 2.4)} provide a discussion
and step-by-step guide for the bounds test.

{pstd}
The superseded command {cmd:estat btest} displays CVs using tabulations
from {help ardl##PSS2001:PSS} and {help ardl##N2005:NAR}.
See {help ardl_legacy##btest:ardl legacy}.

{* foldend}{* foldbeg}{* * * REMARKS PUREAR * * *}{marker pureAR}{...}
{title:Pure autoregressive processes}

{pstd}
You may omit the specification of {it:indepvars}, in which case the process reduces to a pure autoregressive one.
Consequently, you can use {cmd:ardl} for the optimal lag selection of pure autoregressive processes.
See Stata's {help varsoc} for an alternative way of doing this. Furthermore, after the estimation of a pure
autoregressive process with {cmd:ardl} and using the option {opt ec},
you can run the {cmd:estat ectest} postestimation command in order to perform an
augmented {help ardl##DF1979:Dickey and Fuller (1979)} unit-root test with the improved, accurate finite-sample
{help ardl##KS2020:Kripfganz and Schneider (2020)} critical values and corresponding approximate p-values.
The F-statistic in this situation is the square of the t-statistic.
Below is a short illustration of the two approaches.

{phang}{stata webuse lutkepohl2:. webuse lutkepohl2}{p_end}

{phang}{stata ardl ln_inv, ec trend aic maxlag(8):. ardl ln_inv, ec trend aic maxlag(8)}{p_end}
{phang}{stata estat ectest:. estat ectest}{p_end}

{pstd}
Before we can compare results to {cmd:dfuller}, we have to determine the optimal lag order using {cmd:varsoc}.
In {cmd:ardl} this was done automatically.

{phang}{stata varsoc ln_inv, exog(qtr) maxlag(8):. varsoc ln_inv, exog(qtr) maxlag(8)}{p_end}
{phang}{stata dfuller ln_inv if e(sample), trend lags(4) regress:. dfuller ln_inv if e(sample), trend lags(4) regress}{p_end}

{pstd}
The regression results and the value of the t-statistic are identical.
The critical values and approximate p-values are very similar.

{pstd}
Note that for pure autoregressive processes the critical values returned
by {cmd:estat ectest} should be identical for the I(0) and I(1) cases.
Since these values are currently based on separate response surface regressions,
slight deviations may occur.

{* foldend}{* foldbeg}{* * * EXAMPLES * * *}{marker examples}{...}
{title:Examples}

{pstd}
Besides this example section, you may also refer to {help ardl##KS2022:Kripfganz and Schneider (2022)}
who discuss the empirical example given in {help ardl##PSS2001:PSS} by re-estimating it using {cmd:ardl}.

{phang}
Here we use Stata's example data set 'lutkepohl2' that contains quarterly data for German aggregate income,
investment, and consumption. We estimate an ARDL model in levels-form using the optimal number of lags according to BIC.

{phang2}{stata webuse lutkepohl2:. webuse lutkepohl2}{p_end}
{phang2}{stata ardl ln_inv ln_inc ln_consump, lags(. . 4) maxlag(3 3 3):. ardl ln_inv ln_inc ln_consump, lags(. . 4) maxlag(3 3 3)}{p_end}

{pmore}
Lags for ln_inv and ln_inc are optimally selected.
ln_consump is pre-specified to receive a lag order of 4.
Here the maxlag setting of 3 is ignored.
The lags chosen are indicated in the output table header and also saved as a matrix.

{phang2}{stata matrix list e(lags):. matrix list e(lags)}{p_end}

{pmore}
For the next model estimates, we do not specify the {opt maxlag()} option, so the default of a maximum lag of 4 applies to all regressors.
Since we also do not specify the {opt lags()} option, lags are selected optimally for all regressors.

{phang2}{stata ardl ln_inv ln_inc ln_consump:. ardl ln_inv ln_inc ln_consump}

{pmore}
To estimate the error-correction coefficients, use option {opt ec}.

{phang2}{stata ardl ln_inv ln_inc ln_consump, ec :. ardl ln_inv ln_inc ln_consump, ec}{p_end}

{pmore}
{cmd:predict} works as usual:

{phang2}{stata predict yhat if e(sample), xb:. predict yhat if e(sample), xb}{p_end}

{pmore}
Since we have used option {opt ec} in the {cmd:ardl} estimation, the predicted values refer to the first difference of ln_inv, not to the level:

{phang2}{stata tsline yhat d.ln_inv:. tsline yhat d.ln_inv}{p_end}


{phang}
To give an example which is more meaningful from an economic perspective, we now want to examine a potential levels relationship between consumption and income.
The unrestricted constant in the model below is capable of generating the upward drift in the variables that is visible from their time-series graphs.

{phang2}{stata ardl ln_consump ln_inc, lags(4) ec:. ardl ln_consump ln_inc, lags(4) ec}{p_end}

{pmore}
The long-run coefficient on income is close to 1 and has a tight confidence intervall.
To check whether a long-run relationship between consumption and income can be statistically confirmed, we use the postestimation command {cmd:estat ectest}, which displays results of the PSS bounds testing procedure.

{phang2}{stata estat ectest:. estat ectest}{p_end}

{pmore}
The output shows that we cannot confirm the existence of a levels relationship.
Neither the F-statistic nor the t-statistic reject the null hypothesis of no levels relationship.


{* foldend}{* foldbeg}{* * * STOREDRESULTS * * *}{marker storedresults}{...}
{title:Saved results}

{pstd}
{cmd:ardl} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(df_r)}}residual degrees of freedom{p_end}
{synopt:{cmd:e(mss)}}model sum of squares{p_end}
{synopt:{cmd:e(rss)}}residual sum of squares{p_end}
{synopt:{cmd:e(rmse)}}root mean squared error{p_end}
{synopt:{cmd:e(r2)}}R-squared{p_end}
{synopt:{cmd:e(r2_a)}}adjusted R-squared{p_end}
{synopt:{cmd:e(ll)}}log likelihood under additional assumption of i.i.d. normal errors{p_end}
{synopt:{cmd:e(N_gaps)}}number of gaps in sample (note: not number of missings){p_end}
{synopt:{cmd:e(tmin)}}first time period in sample{p_end}
{synopt:{cmd:e(tmax)}}last time period in sample{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:}{p_end}
{synopt:if optimal lag selection was performed:}{p_end}
{synopt:{cmd:e(numcombs)}}number of lag combinations included in the optimal lag selection procedure{p_end}
{synopt:}{p_end}
{synopt:if option {opt ec} or {opt ec1} was used:}{p_end}
{synopt:{cmd:e(case)}}{it:casenum} for model deterministics{p_end}
{synopt:{cmd:e(F_pss)}}F-statistic, bounds test for {it:casenum}{p_end}
{synopt:{cmd:e(t_pss)}}t-statistic, bounds test for {it:casenum}{p_end}
{synopt:}{p_end}
{synopt:if option {opt ec} or {opt ec1} was not used:}{p_end}
{synopt:{cmd:e(F)}}F statistic of the model{p_end}
{synopt:}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:ardl}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(cmdversion)}}version of the {cmd:ardl} command that generated the estimates{p_end}
{synopt:{cmd:e(model)}}{cmd:level} or {cmd:ec}{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(estat_cmd)}}program used to implement {cmd:estat}{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(tsfmt)}}format for the current time variable{p_end}
{synopt:{cmd:e(tvar)}}time variable{p_end}
{synopt:{cmd:e(tmins)}}formatted minimum time{p_end}
{synopt:{cmd:e(tmaxs)}}formatted maximum time{p_end}
{synopt:{cmd:e(regressors)}}full set of regressors in the ARDL model, as estimated by {help regress}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}
{synopt:}{p_end}
{synopt:if option {opt ec} or {opt ec1} was used:}{p_end}
{synopt:{cmd:e(det)}}deterministic terms in the model, but not in the long-run relationship{p_end}
{synopt:{cmd:e(exogvars)}}exogenous variables{p_end}
{synopt:{cmd:e(srvars)}}short-run (differenced) regressors{p_end}
{synopt:{cmd:e(lrdet)}}deterministic term in the long-run relationship{p_end}
{synopt:{cmd:e(lrxvars)}}non-deterministic regressors in the long-run relationship{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector of the linear regression model{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators in the linear regression model{p_end}
{synopt:{cmd:e(maxlags)}}vector with maximum lag lengths of {depvar} and {indepvars} in the levels representation used for optimal lag selection{p_end}
{synopt:{cmd:e(lags)}}vector with number of lags of {depvar} and {indepvars} in the levels representation{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{* foldend}{* foldbeg}{* * * AUTHORS * * *}{marker authors}{...}
{title:Authors}

{pstd}
Sebastian Kripfganz, University of Exeter Business School, S.Kripfganz@exeter.ac.uk

{pstd}
Daniel C. Schneider, Max Planck Institute for Demographic Research, schneider@demogr.mpg.de


{* foldend}{* foldbeg}{* * * REFERENCES * * *}{marker references}{...}
{title:References}

{marker DF1979}{...}
{phang}
Dickey, D. A. and W. A. Fuller (1979). Distribution of the estimators for autoregressive
time series with a unit root. Journal of the American Statistical Association, 74 (366), 427-431.

{marker HW2005}{...}
{phang}
Hassler, U. and J. Wolters (2006): Autoregressive Distributed Lag Models and Cointegration.
Allgemeines Statistisches Archiv, 90, 59-74.

{phang}
Hassler, U. and J. Wolters (2005): Autoregressive Distributed Lag Models and Cointegration.
Freie Universitaet Berlin, Working Paper No.2005/22.

{marker KS2020}{...}
{phang}
Kripfganz, S. and D. Schneider (2020): Response surface regressions for critical value
bounds and approximate p-values in equilibrium correction models.
Oxford Bulletin of Economics and Statistics, 82 (6), 1456-1481. DOI: {browse "https://doi.org/10.1111/obes.12377":10.1111/obes.12377}

{marker KS2022}{...}
{phang}
Kripfganz, S. and D. Schneider (2022) ardl: Estimating autoregressive distributed lag and equilibrium correction models. Research Center for Policy Design Discussion Paper TUPD-2022-006, Tohoku University.
Available at {browse "https://www2.econ.tohoku.ac.jp/~PDesign/dp/TUPD-2022-006.pdf"}

{marker L2005}{...}
{phang}
Luetkepohl, H. (2005): New Introduction to Multiple Time Series Analysis.
Berlin, Heidelberg: Springer Verlag.

{marker M1991}{...}
{phang}
MacKinnon, J. G. (1991). Critical values for cointegration tests. In: R. F. Engle and
C. W. J. Granger (Eds.): Long-Run Economic Relationships: Readings in Cointegration,
Chapter 13, pp. 267-276. Oxford, UK: Oxford University Press.

{marker M1996}{...}
{phang}
MacKinnon, J. G. (1996). Numerical distribution functions for unit root and cointegration
tests. Journal of Applied Econometrics, 11 (6), 601-618.

{marker N2005}{...}
{phang}
Narayan, P.K. (2005): The Saving and Investment Nexus for China:
Evidence from Cointegration Tests.
Applied Economics, 37 (17), 1979-1990.

{marker PS1999}{...}
{phang}
Pesaran, M.H. and Y. Shin (1999): An Autoregressive Distributed Lag Modelling Approach to Cointegration Analysis.
In: Strom, S. (Ed.): Econometrics and Economic Theory in the 20th Century: The Ragnar Frisch Centennial Symposium.
Cambridge, UK: Cambridge University Press.

{marker PSS2001}{...}
{phang}
Pesaran, M.H., Shin, Y. and R.J. Smith (2001): Bounds Testing Approaches to the Analysis of Level Relationships.
Journal of Applied Econometrics, 16 (3), 289-326.


{* foldend}{* foldbeg}{* * * ALSOSEE * * *}{marker alsosee}{...}
{title:Also see}

{psee}
Help: {manhelp regress R:regress}, {manhelp vec TS:vec}

{psee}
Other commands of the {cmd:ardl} package: {help ardlbounds}

{* foldend}
