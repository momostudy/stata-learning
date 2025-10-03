{smcl}
{* *! version 1.0.07  15jan2019}{...}
{cmd:help cvlasso}{right: ({browse "https://doi.org/10.1177/1536867X20909697":SJ20-1: st0594})}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: cvlasso} {hline 2}}Program for cross-validation using lasso,
square-root lasso, elastic net, adaptive lasso, and postordinary least-squares
estimators{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 4} Full syntax

{p 8 14 2}
{cmd:cvlasso}
{it:depvar} {it:regressors} 
{ifin}
{bind:[{cmd:,}} {cmdab:alp:ha(}{it:numlist}{cmd:)}
{cmdab:alphac:ount(}{it:int}{cmd:)}
{cmd:sqrt}
{cmdab:ada:ptive}
{cmdab:adal:oadings(}{it:string}{cmd:)}
{cmdab:adat:heta(}{it:real}{cmd:)}
{cmd:ols}
{cmdab:l:ambda}{cmd:(}{it:numlist}{cmd:)}
{cmdab:lc:ount}{cmd:(}{it:int}{cmd:)}
{cmdab:lminr:atio}{cmd:(}{it:real}{cmd:)}
{cmd:lmax}{cmd:(}{it:real}{cmd:)}
{cmd:lopt}
{cmd:lse}
{cmdab:notp:en(}{it:varlist}{cmd:)}
{cmdab:par:tial(}{it:varlist}{cmd:)}
{cmdab:pload:ings(}{it:matrix}{cmd:)}
{cmdab:unitl:oadings}
{cmdab:pres:td}
{cmd:fe}
{cmd:noftools}
{cmdab:nocon:stant}
{cmdab:tolo:pt}{cmd:(}{it:real}{cmd:)}
{cmdab:tolz:ero}{cmd:(}{it:real}{cmd:)}
{cmdab:maxi:ter}{cmd:(}{it:int}{cmd:)}
{cmdab:nf:olds}{cmd:(}{it:int}{cmd:)}
{cmdab:foldv:ar}{cmd:(}{it:varname}{cmd:)}
{cmdab:savef:oldvar}{cmd:(}{it:varname}{cmd:)}
{cmdab:roll:ing}
{cmd:h}{cmd:(}{it:int}{cmd:)}
{cmdab:or:igin}{cmd:(}{it:int}{cmd:)}
{cmdab:fixedw:indow}
{cmd:seed}{cmd:(}{it:real}{cmd:)}
{cmd:plotcv}
{cmd:plotopt}{cmd:(}{it:string}{cmd:)}
{cmd:omitgrid}
{bind:{cmd:saveest}{cmd:(}{it:string}{cmd:)}]}

{p 8 14 2}
Note: The {opt fe} option will take advantage of the {cmd:ftools} package
(Correia {help cvlasso##SG2016:2016}) (if installed) for the fixed-effects
transformation; the speed gains using this package can be large.  See
{rnethelp "http://fmwww.bc.edu/RePEc/bocode/f/ftools.sthlp":{cmd:ftools}} or
click on {bf:{stata "ssc install ftools"}} to install.

{synoptset 23}{...}
{p2coldent :Estimators}Description{p_end}
{synoptline}
{synopt:{cmdab:a:lpha(}{it:numlist}{cmd:)}}a scalar elastic-net parameter or
an ascending list of elastic-net parameters;
if the number of alpha values is larger than 1,
cross-validation is conducted over alpha (and lambda);
the default is {cmd:alpha(1)}, which corresponds to the lasso estimator;
the elastic-net parameter controls the degree of L1-norm (lasso-type) 
to L2-norm (ridge-type) penalization;
each alpha value must be in the interval [0,1]{p_end}
{synopt:{cmdab:alphac:ount(}{it:int}{cmd:)}}number of alpha values used for
cross-validation across alpha; by default, cross-validation is conducted only
across lambda but not over alpha; ignored if {cmd:alpha()} is specified{p_end}
{synopt:{cmd:sqrt}}square-root lasso estimator{p_end}
{synopt:{cmdab:ada:ptive}}adaptive lasso estimator;
the penalty loading for predictor j is set to 1/abs(beta0(j))^theta,
where beta0(j) is the ordinary least-squares (OLS) estimate or univariate OLS
estimate if p>n; theta is the adaptive exponent and can be controlled using
the {cmd:adatheta(}{it:real}{cmd:)} option{p_end}
{synopt:{cmdab:adal:oadings(}{it:string}{cmd:)}}alternative initial estimates,
beta0, used for calculating adaptive loadings;
for example, this could be the vector {cmd:e(b)} from an initial {helpb lasso2}
estimation; the elements of the vector are raised to the power -theta (note
the minus); see the {cmdab:adaptive} option{p_end}
{synopt:{cmdab:adat:heta(}{it:real}{cmd:)}}exponent for calculating adaptive
penalty loadings; see the {cmdab:adaptive} option; default is
{cmd:adatheta(1)}{p_end}
{synopt:{cmd:ols}}postestimation OLS; note that cross-validation using OLS
will in most cases lead to no unique optimal lambda (because the mean squared
prediction error [MSPE] is a step function over lambda){p_end}
{synoptline}
{p2colreset}{...}
{pstd}
See overview of {help lasso2##estimators:estimation methods}.

{synoptset 23 tabbed}{...}
{p2coldent :Lambda(s)}Description{p_end}
{synoptline}
{synopt:{cmdab:l:ambda}{cmd:(}{it:numlist}{cmd:)}}a scalar lambda value or list of descending lambda values; each lambda value must be greater than 0; if not specified, the default list is used, which is given by {cmd:exp(rangen(log(lmax),log(lminratio*lmax),lcount))} (see {helpb mata range():mf_range()}){p_end}
{p2coldent :{c 0134} {cmdab:lc:ount}{cmd:(}{it:int}{cmd:)}}number of lambda values for which the solution is obtained; default is
{cmd:lcount(100)}{p_end}
{p2coldent :{c 0134} {cmdab:lminr:atio}{cmd:(}{it:real}{cmd:)}}ratio of
minimum to maximum lambda; {cmd:lminratio} must be between 0 and 1;
default is {cmd:lminratio(1/1000)}{p_end}
{p2coldent :{c 0134} {cmd:lmax}{cmd:(}{it:real}{cmd:)}}maximum lambda value;
default is {cmd:lmax(2*max(X'y))}, and {cmd:lmax(max(X'y))} in the case of the square-root lasso
(where X is the prestandardized regressor matrix and y is the vector of the response variable){p_end}
{synopt:{cmd:lopt}}after cross-validation, fit model with lambda that
minimizes the MSPE{p_end}
{synopt:{cmd:lse}}after cross-validation, fit model with the largest lambda that is within one
standard deviation from {cmd:lopt}{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
{c 0134} Not applicable if {cmd:lambda()} is specified.

{synoptset 23}{...}
{p2coldent :Loadings/standardization}Description{p_end}
{synoptline}
{synopt:{cmdab:notp:en(}{it:varlist}{cmd:)}}set penalty loadings to zero for
predictors in {it:varlist};
unpenalized predictors are always included in the model{p_end}
{synopt:{cmdab:par:tial(}{it:varlist}{cmd:)}}partial out variables in {it:varlist} prior to estimation{p_end}
{synopt:{cmdab:pload:ings(}{it:matrix}{cmd:)}}row vector of penalty loadings; overrides the default standardization
loadings (in the case of the lasso, =sqrt[avg(x^2)]);
the size of the vector should equal the number of predictors (excluding
partialed-out variables and excluding the constant){p_end}
{synopt:{cmdab:unitl:oadings}}penalty loadings set to a vector of ones;
overrides the default standardization loadings (in the case of the lasso,
=sqrt[avg(x^2)]){p_end}
{synopt:{cmdab:pres:td}}standardized dependent variable and predictors prior to estimation 
rather than "on the fly" using penalty loadings;
see {help lasso2##standardization:here} for more details;
by default, the coefficient estimates are unstandardized (that is, returned in original units){p_end}
{synoptline}
{p2colreset}{...}
{pstd}
See {help lasso2##standardization:discussion of standardization} in the {helpb lasso2} help file.  Also see section {it:{help cvlasso##transform:Data transformations in cross-validation}} below.

{synoptset 23}{...}
{p2coldent :FE and constant}Description{p_end}
{synoptline}
{synopt:{cmd:fe}}within transformation is applied prior to estimation; requires data to be
{cmd:xtset}{p_end}
{synopt:{opt noftools}}do not use the {cmd:ftools} package for fixed-effects
transformation (slower; rarely used){p_end}
{synopt:{cmdab:nocon:stant}}suppress constant from estimation; default behavior is to partial the constant out (that is, to center the regressors){p_end}
{synoptline}
{p2colreset}{...}

{synoptset 23}{...}
{p2coldent :Optimization}Description{p_end}
{synoptline}
{synopt:{cmdab:tolo:pt}{cmd:(}{it:real}{cmd:)}}tolerance for lasso shooting
algorithm; default is {cmd:tolopt(1e-10)}{p_end}
{synopt:{cmdab:tolz:ero}{cmd:(}{it:real}{cmd:)}}minimum below which coefficients are
rounded down to zero; default is {cmd:tolzero(1e-4)}{p_end}
{synopt:{cmdab:maxi:ter}{cmd:(}{it:int}{cmd:)}}maximum number of iterations
for the lasso shooting algorithm; default is {cmd:maxiter(10000)}{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 22 tabbed}{...}
{p2coldent :Fold-variable options}Description{p_end}
{synoptline}
{synopt:{cmd:nfolds(}{it:int}{cmd:)}}number of folds used for K-fold cross-validation; default is
{cmd:nfolds(10)}{p_end}
{synopt:{cmd:foldvar(}{it:varname}{cmd:)}}user-specified variable with fold
IDs ranging from 1 to #folds; by default, fold IDs are randomly generated such that each fold is of approximately equal size{p_end}
{synopt:{cmd:savefoldvar(}{it:varname}{cmd:)}}save the fold ID variable; 
not supported in combination with {cmd:rolling}{p_end}
{synopt:{cmdab:roll:ing}}use rolling h-step-ahead cross-validation; 
requires the data to be
{cmd:tsset}{p_end}
{p2coldent :{c 0135} {cmd:h(}{it:int}{cmd:)}}change the forecasting horizon; default is {cmd:h(1)}{p_end}
{p2coldent :{c 0135} {cmdab:or:igin(}{it:int}{cmd:)}}control the number of observations in the first training dataset{p_end}
{p2coldent :{c 0135} {cmdab:fixedw:indow}}ensure that the size of the training dataset is always the same{p_end}
{synopt:{cmd:seed(}{it:real}{cmd:)}}set seed for the generation of a random
fold variable; relevant only if the fold variable is randomly generated{p_end}
{synoptline}
{p2colreset}{...}
{pstd}
{c 0135} Applicable only with the {opt rolling} option.

{marker plottingopts}{...}
{synoptset 23}{...}
{p2coldent :Plotting options}Description{p_end}
{synoptline}
{synopt:{cmdab:plotcv}}plot the estimated MSPE as a function of ln(lambda){p_end}
{synopt:{cmdab:plotopt(}{it:string}{cmd:)}}overwrite the default plotting options; all options are passed to {helpb line}{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 23}{...}
{p2coldent :Display options}Description{p_end}
{synoptline}
{synopt:{cmd:omitgrid}}suppress the display of MSPEs{p_end}
{synoptline}
{p2colreset}{...}

{synoptset 23}{...}
{p2coldent :Store lasso2 results}Description{p_end}
{synoptline}
{synopt:{cmd:saveest(}{it:string}{cmd:)}}save {helpb lasso2} results from each
step of the cross-validation in {it:string}{cmd:1}, ..., {it:stringK}, where
{it:K} is the number of folds;
intermediate results can be restored using {helpb estimates restore}{p_end}
{synoptline}
{p2colreset}{...}

{pstd}
{opt cvlasso} may be used with time-series or panel data, in which case the
data must be {cmd:tsset} or {cmd:xtset} first; see {helpb tsset} or
{helpb xtset}.

{pstd}
All {it:varlist}s may contain time-series operators or factor variables; see
{varlist}.

{pstd}
Replay syntax

{p 8 14 2}
{cmd:cvlasso}
{bind:[{cmd:,}}
{cmd:lopt}
{cmd:lse}
{cmdab:postres:ults}
{cmd:plotcv}
{bind:{cmdab:ploto:pt}{cmd:(}{it:string}{cmd:)}]}

{synoptset 23}{...}
{p2coldent :Replay options}Description{p_end}
{synoptline}
{synopt:{cmd:lopt}}show estimation results using the model corresponding to lambda={cmd:e(lopt)}{p_end}
{synopt:{cmd:lse}}show estimation results using the model corresponding to lambda={cmd:e(lse)}{p_end}
{synopt:{cmdab:postres:ults}}post {helpb lasso2} estimation results (to be used in combination with {cmd:lse} or {cmd:lopt}){p_end}
{synopt:{cmd:plotcv}}see {help cvlasso##plottingopts:plotting options} above{p_end}
{synopt:{cmdab:ploto:pt}{cmd:(}{it:string}{cmd:)}}see {help cvlasso##plottingopts:plotting options} above{p_end}
{synoptline}
{p2colreset}{...}

{phang}
Postestimation:

{p 8 14 2}
{cmd:predict} {dtype} {newvar} {ifin} [{cmd:,} 
{cmd:xb}
{cmdab:r:esiduals}
{cmd:lopt}
{cmd:lse}
{bind:{cmdab:noi:sily}]}

{synoptset 23}{...}
{p2coldent :Predict options}Description{p_end}
{synoptline}
{synopt:{cmd:xb}}compute predicted values; the default{p_end}
{synopt:{cmdab:r:esiduals}}compute residuals{p_end}
{synopt:{cmd:lopt}}use lambda that minimizes the MSPE{p_end}
{synopt:{cmd:lse}}use the largest lambda that is within one standard deviation from {cmd:lopt}{p_end}
{synopt:{cmdab:noi:sily}}show estimation output if reestimation is required{p_end}
{synoptline}
{p2colreset}{...}


{title:Contents}

{phang}{help cvlasso##description:Description}{p_end}
{phang}{help cvlasso##folds:Partitioning of folds}{p_end}
{phang2}{help cvlasso##kfoldcv:K-fold cross-validation}{p_end}
{phang2}{help cvlasso##rollinghstep:Rolling h-step-ahead cross-validation}{p_end}
{phang}{help cvlasso##transform:Data transformations in cross-validation}{p_end}
{phang}{help cvlasso##examples:General introduction using K-fold cross-validation}{p_end}
{phang2}{help cvlasso##dataset:Dataset}{p_end}
{phang2}{help cvlasso##examples_general:General demonstration}{p_end}
{phang2}{help cvlasso##fit_full_model:Fit the full model}{p_end}
{phang2}{help cvlasso##cv_lambda_alpha:Cross-validation over lambda and alpha}{p_end}
{phang2}{help cvlasso##plotting:Plotting}{p_end}
{phang2}{help cvlasso##prediction:Prediction}{p_end}
{phang2}{help cvlasso##store_intermediate_steps:Store intermediate steps}{p_end}
{phang}{help cvlasso##time_series:Time-series example using rolling h-step-ahead cross-validation}{p_end}
{phang}{help cvlasso##panel_data:Panel-data example using rolling h-step-ahead cross-validation}{p_end}
{phang}{help cvlasso##stored_results:Stored results}{p_end}
{phang}{help cvlasso##references:References}{p_end}
{phang}{help cvlasso##website:Website}{p_end}
{phang}{help cvlasso##installation:Installation}{p_end}
{phang}{help cvlasso##acknowledgment:Acknowledgment}{p_end}
{phang}{help cvlasso##citation:Citation of cvlasso}{p_end}
{phang}{help cvlasso##authors:Authors}{p_end}
{phang}{help cvlasso##alsosee:Also see}{p_end}


{marker description}{...}
{title:Description}

{pstd}
{opt cvlasso} implements K-fold cross-validation and h-step-ahead rolling
cross-validation for the following estimators: lasso, square-root lasso,
adaptive lasso, ridge regression, and elastic net.  See {helpb lasso2} for
more information about these estimators.

{pstd}
The purpose of cross-validation is to assess the out-of-sample prediction
performance of the estimator.

{pstd}
The steps for K-fold cross-validation over lambda can be summarized as follows:

{phang2}
1.  Split the data into K groups, referred to as folds, of approximately equal
size.  Let n(k) denote the number of observations in the kth data partition
with k = 1,...,K.

{phang2}
2.  The first fold is treated as the validation dataset, and the remaining K-1
parts constitute the training dataset.  The model is fit to the training data
for a given value of lambda.  The resulting estimate is denoted as
betahat(1,lambda).  The MSPE for group 1 is computed as

		MSPE(1,lambda)=1/n(1)*sum([y(i) - x(i)'betahat(1,lambda)]^2)
	
{pmore2}
for all i in the first data partition.
	
{pmore2}
The procedure is repeated for k = 2,...,K.  Thus, MSPE(2,lambda), ...,
MSPE(K,lambda) are calculated.

{phang2}
3.  The K-fold cross-validation estimate of the MSPE, which serves as a measure
of prediction performance, is

		CV(lambda)=1/K*sum{MSPE(k,lambda)}

{phang2}
4.  Steps 2 and 3 are repeated for a range of lambda values.

{pstd}
h-step-ahead rolling cross-validation proceeds similarly, except that the
partitioning of training and validation accounts for the time-series
structure.  Specifically, the training window is iteratively extended (or
moved forward) by one step.  See below for more details.


{marker folds}{...}
{title:Partitioning of folds}

{pstd}
{cmd:cvlasso} supports K-fold cross-validation and cross-validation using
rolling h-step-ahead forecasts.  K-fold cross-validation is the standard
approach and relies on a fold ID variable.  Rolling h-step-ahead
cross-validation is applicable with time-series data or panels with a large
time dimension.


{marker kfoldcv}{...}
    {title:K-fold cross-validation}

{pstd}
The fold ID variable marks the observations that are used as validation data.
For example, a fold ID variable (with three folds) could have the following
structure:

	    {c TLC}{hline 7}{c -}{hline 7}{c -}{hline 2}{c TRC}
	    {c |} {res}fold   y      x  {txt}{c |}
	    {c LT}{hline 7}{c -}{hline 7}{c -}{hline 2}{c RT}
	    {c |} {res} 3     y1     x1 {txt}{c |}
	    {c |} {res} 2     y2     x2 {txt}{c |}
	    {c |} {res} 1     y3     x3 {txt}{c |}
	    {c |} {res} 3     y4     x4 {txt}{c |}
	    {c |} {res} 1     y5     x5 {txt}{c |}
	    {c |} {res} 2     y6     x6 {txt}{c |}
	    {c BLC}{hline 7}{c -}{hline 7}{c -}{hline 2}{c BRC}

{pstd}
It is instructive to illustrate the cross-validation process implied by the
above fold ID variable.  Let T denote a training observation and V denote a
validation point.  The division of folds can be summarized as follows: 

      		 Step
					
      		1  2  3  
              {c TLC}{c -}       {c -}{c TRC}
            1 {c |} T  T  V {c |} 
            2 {c |} T  V  T {c |}
            3 {c |} V  T  T {c |} 
        i   4 {c |} T  T  V {c |}
            5 {c |} V  T  T {c |}
            6 {c |} T  V  T {c |}
              {c BLC}{c -}       {c -}{c BRC}

{pstd}
In the first step, the third and fifth observations are in the validation
dataset, and the remaining data constitute the training dataset.  In the
second step, the validation dataset includes the second and sixth
observations, etc.

{pstd}
By default, the fold ID variable is randomly generated such that each fold is
of approximately equal size.  The default number of folds is equal to 10 but
can be changed using the {cmd:nfolds()} option.


{marker rollinghstep}{...}
    {title:Rolling h-step-ahead cross-validation}

{pstd}
To allow for time-series data, {cmd:cvlasso} supports cross-validation using
rolling h-step forecasts (the option {cmd:rolling}); see Hyndman
({help cvlasso##Hyndman2016:2016}).  To use rolling cross-validation, the data
must be {cmd:tsset} or {cmd:xtset}.  The options {cmd:h()} and {cmd:origin()}
control the forecasting horizon and the starting point of the rolling
forecast, respectively.

{pstd}
The following matrix illustrates the division between training and validation
data over the course of the cross-validation for the case of 1-step-ahead
forecasting (the default when {cmd:rolling} is specified).

      		    Step
					
      		1  2  3  4  5
              {c TLC}{c -}             {c -}{c TRC}
            1 {c |} T  T  T  T  T {c |} 
            2 {c |} T  T  T  T  T {c |}
            3 {c |} T  T  T  T  T {c |} 
        t   4 {c |} V  T  T  T  T {c |}
            5 {c |} .  V  T  T  T {c |}
            6 {c |} .  .  V  T  T {c |}
            7 {c |} .  .  .  V  T {c |}
            8 {c |} .  .  .  .  V {c |}
              {c BLC}{c -}             {c -}{c BRC}

{pstd}
In the first iteration (illustrated in the first column), the first 3
observations are in the training dataset, which corresponds to
{cmd:origin(3)}.  The option {cmd:h()} controls the forecasting horizon used
for cross-validation (the default is 1).  If {cmd:h(2)} is specified, which
corresponds to 2-step-ahead forecasting, the structure changes to

      		    Step
					
      		1  2  3  4  5
              {c TLC}{c -}             {c -}{c TRC}
            1 {c |} T  T  T  T  T {c |} 
            2 {c |} T  T  T  T  T {c |}
            3 {c |} T  T  T  T  T {c |} 
            4 {c |} .  T  T  T  T {c |} 
        t   5 {c |} V  .  T  T  T {c |}
            6 {c |} .  V  .  T  T {c |}
            7 {c |} .  .  V  .  T {c |}
            8 {c |} .  .  .  V  . {c |}
            9 {c |} .  .  .  .  V {c |}
              {c BLC}{c -}             {c -}{c BRC}
              
{pstd}
The {cmd:fixedwindow} option ensures that the size of the training dataset is
always the same.  In this example (using {cmd:h(1)}), each step uses three
data points for training: 

      		    Step
					
      		1  2  3  4  5
              {c TLC}{c -}             {c -}{c TRC}
            1 {c |} T  .  .  .  . {c |} 
            2 {c |} T  T  .  .  . {c |}
            3 {c |} T  T  T  .  . {c |} 
        t   4 {c |} V  T  T  T  . {c |}
            5 {c |} .  V  T  T  T {c |}
            6 {c |} .  .  V  T  T {c |}
            7 {c |} .  .  .  V  T {c |}
            8 {c |} .  .  .  .  V {c |}
              {c BLC}{c -}             {c -}{c BRC}


{marker transform}{...}
{title:Data transformations in cross-validation}

{pstd}
An important principle in cross-validation is that the training dataset should
not contain information from the validation dataset.  This mimics the
real-world situation where out-of-sample predictions are made despite the true
response being unknown.  The principle applies not only to individual
observations (the training and validation data do not overlap) but also to
data transformations.  Specifically, data transformations applied to the
training data should not use information from the validation data or full
dataset.  In particular, standardization using the full sample violates this
principle.

{pstd}
{opt cvlasso} implements this principle for all data transformations supported
by {helpb lasso2}: data standardization, fixed effects, and partialing out.
In most applications using the estimators supported by {opt cvlasso},
predictors are standardized to have mean zero and unit variance.  The above
principle means that the standardization applied to the training data is based
only on observations in the training data; further, the standardization
transformation applied to the validation data will also be based only on the
means and variances of the observations in the training data.  The same
applies to the fixed-effects transformation: the group means used to implement
the within transformation to both the training data and the validation data
are calculated using only the training data.  Similarly, the projection
coefficients used to "partial out" variables are estimated using only the
training data and are applied to both the training dataset and the validation
dataset.


{marker examples}{...}
{title:General introduction using K-fold cross-validation}


{marker dataset}{...}
    {title:Dataset}

{pstd}
The dataset is available through Hastie, Tibshirani, and Wainwright
({help lasso2##Hastie2015:2015}) on the
{browse "https://web.stanford.edu/~hastie/ElemStatLearn/":authors' website}.
The following variables are included in the dataset of 97 men:

{synoptset 10 tabbed}{...}
{p2col 5 19 23 2: Predictors}{p_end}
{synopt:{cmd:lcavol}}log(cancer volume){p_end}
{synopt:{cmd:lweight}}log(prostate weight){p_end}
{synopt:{cmd:age}}patient age{p_end}
{synopt:{cmd:lbph}}log(benign prostatic hyperplasia amount){p_end}
{synopt:{cmd:svi}}seminal vesicle invasion{p_end}
{synopt:{cmd:lcp}}log(capsular penetration){p_end}
{synopt:{cmd:gleason}}Gleason score{p_end}
{synopt:{cmd:pgg45}}percentage Gleason scores 4 or 5{p_end}

{synoptset 10 tabbed}{...}
{p2col 5 19 23 2: Outcome}{p_end}
{synopt:{cmd:lpsa}}log(prostate specific antigen){p_end}

{pstd}Load prostate cancer data.{p_end}
{phang2}
{bf:. {stata "insheet using https://web.stanford.edu/~hastie/ElemStatLearn/datasets/prostate.data, tab"}}{p_end}


{marker examples_general}{...}
    {title:General demonstration}

{pstd}
Ten-fold cross-validation across lambda.  The lambda value that minimizes the
MSPE is indicated by an asterisk (*).  A hat (^) marks the largest lambda at
which the MSPE is within one standard error of the minimal MSPE.  The former
is returned in {cmd:e(lopt)}, and the latter is returned in {cmd:e(lse)}.  We
use {cmd:seed(123)} throughout this demonstration for replicability of
folds.{p_end}
{phang2}
{bf:. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123)"}}{p_end}
{phang2}
{bf:. {stata "display e(lopt)"}}{p_end}
{phang2}
{bf:. {stata "display e(lse)"}}{p_end}


{marker fit_full_model}{...}
    {title:Fit the full model}

{pstd}
Fit the full model with either {cmd:e(lopt)} or {cmd:e(lse)}.  {cmd:cvlasso}
internally calls {helpb lasso2} with lambda={cmd:lopt} or {cmd:lse},
respectively.{p_end}
{phang2}
{bf:. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, lopt seed(123)"}}{p_end}
{phang2}
{bf:. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, lse seed(123)"}}{p_end}

{pstd}
The same as above can be achieved using the replay syntax.{p_end}
{phang2}
{bf:. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123)"}}{p_end}
{phang2}
{bf:. {stata "cvlasso, lopt"}}{p_end}
{phang2}
{bf:. {stata "cvlasso, lse"}}{p_end}

{pstd}
If {cmd:postresults} is specified, {cmd:cvlasso} posts the {helpb lasso2}
estimation results.{p_end}
{phang2}
{bf:. {stata "cvlasso, lopt postres"}}{p_end}
{phang2}
{bf:. {stata "ereturn list"}}{p_end}


{marker cv_lambda_alpha}{...}
    {title:Cross-validation over lambda and alpha}

{pstd}
{cmd:alpha()} can be a scalar or list of elastic-net parameters.  Each alpha
value must lie in the interval [0,1].  If {cmd:alpha()} is a list longer than
1, {cmd:cvlasso} cross-validates over lambda and alpha.  The table at the end
of the output indicates the alpha value that minimizes the empirical
MSPE.{p_end}
{phang2}
{bf:. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, alpha(0 0.1 0.5 1) lc(10) seed(123)"}}{p_end}

{pstd}
Alternatively, the {cmd:alphacount()} option can be used to control the number
of alpha values used for cross-validation.{p_end}
{phang2}
{bf:. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, alphac(3) lc(10) seed(123)"}}{p_end}


{marker plotting}{...}
    {title:Plotting}

{pstd}
We can plot the estimated MSPE over lambda.  Note that the plotting feature is
not supported if we cross-validate over alpha.{p_end}
{phang2}
{bf:. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123) plotcv"}}{p_end}


{marker prediction}{...}
    {title:Prediction}

{pstd}
The {cmd:predict} postestimation command allows one to obtain predicted values
and residuals for lambda={cmd:e(lopt)} or lambda={cmd:e(lse)}.{p_end}
{phang2}
{bf:. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123)"}}{p_end}
{phang2}
{bf:. {stata "capture drop xbhat1"}}{p_end}
{phang2}
{bf:. {stata "predict double xbhat1, lopt"}}{p_end}
{phang2}
{bf:. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123)"}}{p_end}
{phang2}
{bf:. {stata "capture drop xbhat2"}}{p_end}
{phang2}
{bf:. {stata "predict double xbhat2, lse"}}{p_end}


{marker store_intermediate_steps}{...}
    {title:Store intermediate steps}

{pstd}
{cmd:cvlasso} calls {helpb lasso2} internally.  To see intermediate estimation
results, we can use the {cmd:saveest}{cmd:(}{it:string}{cmd:)} option.{p_end}
{phang2}
{bf:. {stata "cvlasso lpsa lcavol lweight age lbph svi lcp gleason pgg45, seed(123) nfolds(3) saveest(step)"}}{p_end}
{phang2}
{bf:. {stata "estimates dir"}}{p_end}
{phang2}
{bf:. {stata "estimates restore step1"}}{p_end}
{phang2}
{bf:. {stata "estimates replay step1"}}{p_end}


{marker time_series}{...}
{title:Time-series example using rolling h-step-ahead cross-validation}

{pstd}Load airline passenger data.{p_end}
{phang2}
{bf:. {stata "webuse air2, clear"}}{p_end}

{pstd}
There are 144 observations in the sample.  {cmd:origin()} controls the sample
range used for training and validation.  In this example, {cmd:origin(130)}
implies that data up to and including t=130 are used for training in the first
iteration.  Data points t=131 to t=144 are successively used for validation.
The notation "a-b (v)" indicates that data a to b are used for estimation
(training), and data point v is used for forecasting (validation).  Note that
the training dataset starts with t=13 because 12 lags are used as
predictors.{p_end}
{phang2}
{bf:. {stata "cvlasso air L(1/12).air, rolling origin(130)"}}{p_end}

{pstd}
The optimal model includes lags 1, 11, and 12.{p_end}
{phang2}
{bf:. {stata "cvlasso, lopt"}}{p_end}

{pstd}
The option {cmd:h()} controls the forecasting horizon (default=1).{p_end}
{phang2}
{bf:. {stata "cvlasso air L(1/12).air, rolling origin(130) h(2)"}}{p_end}

{pstd}
In the above examples, the size of the training dataset increases by one data
point each step.  To keep the size of the training dataset fixed, specify
{cmd:fixedwindow}.{p_end}
{phang2}
{bf:. {stata "cvlasso air L(1/12).air, rolling origin(130) fixedwindow"}}{p_end}

{pstd}
Cross-validation over alpha with alpha={0, 0.1, 0.5, 1}.{p_end}
{phang2}
{bf:. {stata "cvlasso air L(1/12).air, rolling origin(130) alpha(0 0.1 0.5 1)"}}{p_end}

{pstd}
Plot MSPEs against ln(lambda).{p_end}
{phang2}
{bf:. {stata "cvlasso air L(1/12).air, rolling origin(130)"}}{p_end}
{phang2}
{bf:. {stata "cvlasso, plotcv"}}{p_end}


{marker panel_data}{...}
{title:Panel-data example using rolling h-step ahead cross-validation}

{pstd}
Rolling cross-validation can also be applied to panel data.  For
demonstration, load Grunfeld data.{p_end}
{phang2}
{bf:. {stata "webuse grunfeld, clear"}}{p_end}

{pstd}
Apply 1-step ahead cross-validation.{p_end}
{phang2}
{bf:. {stata "cvlasso mvalue L(1/10).mvalue, rolling origin(1950)"}}{p_end}

{pstd}
The model selected by cross-validation:{p_end}
{phang2}
{bf:. {stata "cvlasso, lopt"}}{p_end}

{pstd}
Same as above with fixed size of training data.{p_end}
{phang2}
{bf:. {stata "cvlasso mvalue L(1/10).mvalue, rolling origin(1950) fixedwindow"}}{p_end}


{marker stored_results}{...}
{title:Stored results}

{pstd}
{cmd:cvlasso} stores the following in {cmd:e()}:

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}sample size{p_end}
{synopt:{cmd:e(nfolds)}}number of folds{p_end}
{synopt:{cmd:e(lmax)}}largest lambda{p_end}
{synopt:{cmd:e(lmin)}}smallest lambda{p_end}
{synopt:{cmd:e(lcount)}}number of lambdas{p_end}
{synopt:{cmd:e(sqrt)}}{cmd:1} if sqrt-lasso, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(adaptive)}}{cmd:1} if adaptive loadings are used, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(ols)}}{cmd:1} if postestimation OLS, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(partial_ct)}}number of partialed-out predictors{p_end}
{synopt:{cmd:e(notpen_ct)}}number of not penalized predictors{p_end}
{synopt:{cmd:e(prestd)}}{cmd:1} if prestandardized, {cmd:0} otherwise{p_end}
{synopt:{cmd:e(nalpha)}}number of alphas{p_end}
{synopt:{cmd:e(h)}}forecasting horizon for rolling forecasts (returned only if {opt rolling} is specified){p_end}
{synopt:{cmd:e(origin)}}number of observations in first training dataset
(returned only if {opt rolling} is specified){p_end}
{synopt:{cmd:e(lopt)}}optimal lambda (may be missing if there is no unique minimum MSPE){p_end}
{synopt:{cmd:e(lse)}}lambda se (may be missing if there is no unique minimum MSPE){p_end}
{synopt:{cmd:e(mspemin)}}minimum MSPE{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:cvlasso}{p_end}
{synopt:{cmd:e(depvar)}}dependent variable{p_end}
{synopt:{cmd:e(method)}}indicates which estimator is used (for example, lasso, elastic net){p_end}
{synopt:{cmd:e(cvmethod)}}indicates whether K-fold or rolling cross-validation is used{p_end}
{synopt:{cmd:e(varXmodel)}}predictors (excluding partialed-out variables){p_end}
{synopt:{cmd:e(varX)}}predictors{p_end}
{synopt:{cmd:e(partial)}}partialed-out predictors{p_end}
{synopt:{cmd:e(notpen)}}not penalized predictors{p_end}
		
{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Matrices}{p_end}
{synopt:{cmd:e(lambdamat)}}column vector of lambda values{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}estimation sample{p_end}


{pstd}
In addition, if {cmd:cvlasso} cross-validates over alpha and lambda:

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Scalars}{p_end}
{synopt:{cmd:e(alphamin)}}optimal alpha, that is, the alpha that minimizes the empirical MSPE{p_end}
			
{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Macros}{p_end}
{synopt:{cmd:e(alphalist)}}list of alpha values{p_end}
			
{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Matrices}{p_end}
{synopt:{cmd:e(mspeminmat)}}minimum MSPE for each alpha{p_end}


{pstd}
In addition, if {cmd:cvlasso} cross-validates over lambda only:
 
{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Scalars}{p_end}
{synopt:{cmd:e(alpha)}}elastic-net parameter{p_end}

{synoptset 19 tabbed}{...}
{p2col 5 19 23 2: Matrices}{p_end}
{synopt:{cmd:e(mspe)}}matrix of MSPEs for each fold and lambda, where 
each column corresponds to one lambda value and each row corresponds to one fold{p_end}
{synopt:{cmd:e(mmspe)}}column vector of MSPEs for each lambda{p_end}
{synopt:{cmd:e(cvsd)}}column vector standard deviation of MSPE (for each lambda){p_end}
{synopt:{cmd:e(cvupper)}}column vector equal to MSPE +1 standard deviation{p_end}
{synopt:{cmd:e(cvlower)}}column vector equal to MSPE -1 standard deviation{p_end}


{marker references}{...}
{title:References}

{marker SG2016}{...}
{phang}
Correia, S. 2016.
ftools: Stata module to provide alternatives to common Stata commands
optimized for large datasets. Statistical Software Components S458213,
Department of Economics, Boston College.
{browse "https://ideas.repec.org/c/boc/bocode/s458213.html"}.

{marker Hastie2015}{...}
{phang}
Hastie, T., R. Tibshirani, and M. Wainwright. 2015. 
{it:Statistical Learning with Sparsity: The Lasso and Generalizations}.
Boca Raton, FL: CRC Press.

{marker Hyndman2016}{...}
{phang}
Hyndman, R. J. 2016. Cross-validation for time series. Hyndsight Blog.
{browse "https://robjhyndman.com/hyndsight/tscv/"}.

{phang}
See {helpb lasso2##references:lasso2} for further references.


{marker website}{...}
{title:Website}

{pstd}
Please check our website {browse "https://statalasso.github.io/"} for more
information.


{marker installation}{...}
{title:Installation}

{pstd}
To get the latest stable version of {cmd:lassopack} from our website, 
check the installation instructions at
{browse "https://statalasso.github.io/installation/"}.  We update the stable
website version more frequently than the Statistical Software Components
version.

{pstd}
To verify that {cmd:lassopack} is correctly installed, click on or type
{bf:{stata "whichpkg lassopack"}} (which requires {helpb whichpkg} to be
installed; {bf:{stata "ssc install whichpkg"}}).


{marker acknowledgment}{...}
{title:Acknowledgment}

{pstd}
Thanks to Sergio Correia for advice on the use of the {cmd:ftools}
package.{p_end}


{marker citation}{...}
{title:Citation of cvlasso}

{pstd}
{opt cvlasso} is not an official Stata command.  It is a free contribution
to the research community, like an article.  Please cite it as such:

{phang2}
Ahrens, A., C. B. Hansen, M. E. Schaffer. 2018.
lassopack: Stata module for lasso, square-root lasso, elastic net, ridge,
adaptive lasso estimation and cross-validation. Statistical Software
Components S458458, Department of Economics, Boston College.
{browse "http://ideas.repec.org/c/boc/bocode/s458458.html"}.

{phang2}
------. 2020.
{browse "https://doi.org/10.1177/1536867X20909697":lassopack: Model selection and prediction with regularized regression in Stata}.
{it:Stata Journal} 20: 176-235.


{marker authors}{...}
{title:Authors}

{pstd}
Achim Ahrens{break}
The Economic and Social Research Institute{break}
Dublin, Ireland{break}
achim.ahrens@esri.ie

{pstd}
Christian B. Hansen{break}
University of Chicago{break}
Chicago, IL{break}
Christian.Hansen@chicagobooth.edu

{pstd}
Mark E. Schaffer{break}
Heriot-Watt University{break}
Edinburgh, UK{break}
m.e.schaffer@hw.ac.uk


{marker alsosee}{...}
{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 20, number 1: {browse "https://doi.org/10.1177/1536867X20909697":st0594}{p_end}

{p 7 14 2}
Help:  {helpb lasso2}, {helpb lassologit}, {helpb rlasso} (if installed){p_end}
