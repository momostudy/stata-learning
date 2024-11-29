{smcl}
{* *! cmp 8.7.8 18 March 2024}{...}
{cmd:help cmp}
{hline}{...}

{title:Title}

{pstd}
Conditional mixed process estimator with multilevel random effects and coefficients{p_end}

{title:Syntax}

{phang}
{cmd:cmp setup}

{phang}
- or -

{phang}
{cmd:cmp} {it:eq} [{it:eq ...}] {ifin} {weight} {cmd:,} {cmdab:ind:icators}({it:{help exp:exp}} [{it:{help exp:exp} ...}])
		[{opt level(#)}
		{opt qui:etly}
		{opt nolr:test}
		{opt init(vector)} {opt from(vector)} {opt noest:imate} {break} {opt cov:ariance}({it:covopt} [{it:covopt} ...])
		{break}{cmdab:intp:oints(}# [# ...]{cmd:)} {cmdab:intm:ethod(}[{cmdab:g:hermite} | {cmdab:mva:ghermite}] {cmd:,} [{cmdab:tol:erance(}#{cmd:)} {cmdab:iter:ate(}#{cmd:)}]{cmd:)}
		{break}{cmdab:red:raws(}# [# ...]{cmd:)},
		[{opt type(halton | hammersley | ghalton | random)} {opt anti:thetics} {opt st:eps(#)} {opt scr:amble}[{opt (sqrt | negsqrt | fl)}]{cmd:)}
		{break}{cmdab:ghkd:raws(}[#]{cmd: , }[{opt type(halton | hammersley | ghalton | random)} {opt anti:thetics} {opt scr:amble}[{opt (sqrt | negsqrt | fl)}]]{cmd:)}
		{break}{opt nodr:op} {opt inter:active} 
		{opt struc:tural} {opt rev:erse} {opt ps:ampling(# #)}
		{opt result:sform(structural | reduced)}
		{opt lf}
		{it:{help cmp##ml_opts:ml_opts}}
		{opt svy} {it:{help cmp##svy_opts:svy_opts}}
		{it:{help ml##display_options:display_opts}} {it:{help ml##eform_option:eform_opts}}]

{phang}
- or (after the above) -

{phang}
{cmd:cmp} [{cmd:,} [{it:{help ml##display_options:display_opts}} {it:{help ml##eform_option:eform_opts}} {opt level(#)} {opt result:sform(structural | reduced)}]]

{phang}
where {it:covopt} is one of

{phang2}
{cmdab:un:structured | }{cmdab:ex:changeable | }{cmdab:ind:ependent}

{phang}
and {it:eq} is

{phang2}
[{it:fe_equation}] [{cmd:||} {it:re_equation}] [{cmd:||} {it:re_equation} ...]

{phang}
Each {it:fe_equation} is an equation to be estimated, defined largely according to the {help ml model:ml model} {it:eq} syntax. That is, {it:fe_equation} is enclosed in 
parentheses, optionally prefixed with a name for the equation:

{p 8 8 2}
{cmd:(}
	[{it:eqname}{cmd::}]
	{help varname:{it:depvar}} [{help varname:{it:depvar2}}] {cmd:=}
	[{it:indepvars}]
	[{cmd:,} {opt nocons:tant} {opth off:set(varname:varname_o)} {opth exp:osure(varname:varname_e)} {opt trunc:points(exp exp)} {opt iia}]
{cmd:)}

{phang}{it:indepvars} may include factor variables; see {help fvvarlist}. Importantly, {it:indepvars} may also include the linear predictors associated with
any equations in the model. Such references should be by {it:eqname} rather than {it:depvar}, if the two differ, and suffixed with a {cmd:#}. This feature 
allows dependent variables to depend on each other in their continuous and perhaps
incompletely observed form. It also allows for simultaneous, as distinct from strictly recursive, systems of equations.{p_end}

{phang}{help varname:{it:varname_y2}} is included only for interval-censored data, in a syntax analogous to that of 
{help intreg:intreg}. {opt trunc:points(exp exp)} is allowed for equations involving all model types except mulitnomial and rank-ordered probit. {opt iia} is meaningful only for
multinomial probit models without alternative-specific regressors.{p_end}

{phang}
Each {it:exp} in the required {cmdab:ind:icators()} option is an {help exp:expression} that evaluates to a {cmd:cmp} {it:indicator variable}, which communicates required observation-level
information about the dependent variable(s) in the corresponding equation, and can be a constant, a variable name, or a complex mathematical expression. It can contain spaces 
or parentheses if it is double-quoted.
Each {it:exp} must evaluate to 0, 1, 2, 3, 4, 5, 6, 7, 8, or 9, potentially varying by observation. For a multinomial probit equation group with alternative-specific regressors,
the corresponding indicator expressions should all evaluate to 0's and 6's, and should be enclosed in an additional pair of parentheses. The same goes for 
rank-ordered probit groups, except with 9's instead of 6's.

{phang}
In random effect/coefficent models, each {it:re_equation} specifies the effects, potentially at multiple levels, according to the syntax 

{p 8 8 2}
{it:{help varname:levelvar}}{cmd::} [{it:varlist}] [{cmd:,} {opt nocons:tant} {opt cov:ariance}({it:covopt})] {weight}

{phang}
where {it:covopt} is as defined above. In these models, the optional {opt intp:oints} and {opt red:raws()} options are relevant.

{pstd}
{cmd:cmp} may be prefixed with {help svy:svy ... :}. However, using the {cmd:svy} {it:option} instead is recommended because it will result in more-informative results display.

{phang}{cmd:pweight}s, {cmd:fweight}s, {cmd:aweight}s, and {cmd:iweight}s are allowed at all levels; see help {help weights}. Group-level, 
weights, specificed in the {it:re_equation} syntax above, should be constant within groups. Weights for a given level need be specified in just one 
equation.

{pstd}
The syntax of {help predict} following {cmd:cmp} is{p_end}

{phang}{cmd:predict} [{it:type}] {c -(}{it:newvarname}{c |}{it:stub*}{c |}{it:newvarlist}{c )-} [{cmd:if} {it:exp}] [{cmd:in} {it:range}] 
[{cmd:,} {it:statistic} {cmdab:eq:uation(}[{cmd:#}{it:eqno}|{it:eqname} {cmd:#}{it:eqno}|{it:eqname}...]{cmd:)}
{opt o:utcome}{cmd:(}{it:outcome}{cmd:)} {opt nooff:set} {opt red:ucedform} {cmdab:cond:ition(}{it:a b} [, {cmdab:eq:uation(#}{it:eqno}|{it:eqname}{cmd:)}]{cmd:)}]

{phang}where {it:statistic} is {opt xb}, {opt stdp}, {opt stddp}, {opt re:siduals}, {opt lnl}, {opt sc:ores}, 
{cmd:pr}[{cmd:(}{it:a b}{cmd:)}], {cmd:e}[{cmd:(}{it:a b}{cmd:)}], or {cmd:ystar(}{it:a b}{cmd:)}; and {it:a} and {it:b} 
may be numbers or variables; {it:a} missing ({it:a} {ul:>} {cmd:.}) means minus infinity, and {it:b} missing ({it:b} {ul:>} {cmd:.}) means plus infinity; see {help missing}.

{pstd}{cmd:cmp} shares features of all estimation commands; see help {help estcom}.

{title:UPDATES}

{pstd}Major features have been added to {cmd:cmp} since Roodman (2011), and are documented only here. They include:

{p 4 6 0}
* The rank-ordered probit model is available. It generalizes the multinomial probit model to fit ranking data. See {help asroprobit:asroprobit}.

{p 4 6 0}
* The fractional probit model is available. It uses the quasi-likelihood method of Papke and Wooldridge (1996). See {help fracreg}.

{p 4 6 0}
* Truncation is now a general modeling feature rather than a regression type. This allows modeling of a pre-censoring truncation process in
all models except multinomial and rank-ordered probit.

{p 4 6 0}
* References to any equation's linear predictor (XB) can appear on the right side of any equation, even when it is modeled as latent (not fully observed), and
even if the resulting equation system is simultaneous rather than recursive.

{p 4 6 0}
* Multilevel random effects and coefficients can now be modeled, using simulation or (adaptive) quadrature. These 
can be correlated within and across equations. For such multidimensional effects, quadrature is done on "sparse grids" for efficiency (Heiss and Winschel 2008). 

{pstd} Versions of {cmd:cmp} back to 7.1.0 are {browse "https://github.com/droodman/cmp/releases":on GitHub}. In Stata 13 or later, they can be installed with
{cmd:net install cmp, replace from(https://raw.github.com/droodman/cmp/vX.Y.Z)} where {cmd:X.Y.Z} is the version number.

{pstd} Versions 8.0.0 and 8.2.0, released in mid-2017 and early 2018, include changes that can somewhat affect results in hierarchical models. The previous version, 7.1.0,
avoids these changes.

{pstd} Versions 8.6.2, released in June 2021, requires Stata 13 or later. Previous versions work in Stata 11 and 12 too.

{title:Donate?}

{pstd}
Has {cmd:cmp} improved your expertise, career, or marriage?
Consider giving back through a {browse "http://j.mp/1iptvDY":donation} to support the work of its author, {browse "http://davidroodman.com":David Roodman}.

{title:Description}

{pstd}
{cmd:cmp} fits a large family of multi-equation, multi-level, conditional mixed-process estimators. Right-side references to left-side variables must together have
a recursive structure when those references are to the observed, censored variables; but references to the (latent) linear predictors may be 
collectively simultaneous. The various terms in that description can be defined as follows:

{p 4 6 0}
* "Multi-equation" means that {cmd:cmp} can fit Seemingly Unrelated (SUR), instrumental variables (IV) systems, and some simultaneous-equation systems. Single-equation models can be fit too.

{p 4 6 0}
* "Multi-level" means that random coefficients and effects (intercepts) can be modeled at
various levels in hierarchical fashion, the classic example being a model of education outcomes with unobserved school and class effects. Since the models
can also be multi-equation, random effects at a given level are allowed by default to be correlated across equations. E.g., school and class 
effects may be correlated across outcomes such as math and readings scores. Effects at different levels, however, are assumed uncorrelated
with each other, with the observation-level errors, and with the regressors.{p_end}

{p 4 6 0}
* "Mixed process" means that different equations can have different kinds of 
dependent variables (response types). The choices, all generalized linear models with a Gaussian error distribution, are: continuous and unbounded (the classical linear regression 
model), tobit (left-, right-, or bi-censored), interval-censored, probit, ordered probit, multinomial 
probit, rank-ordered probit, and fractional probit. Pre-censoring truncation can be modeled for most response types. A dependent variable in one equation can appear on the right side of another equation.

{p 4 6 0}
* "Conditional" means that the model can vary by observation. An equation can be dropped for observations for which it is not relevant--if, say, a worker
retraining program is not offered in a city then the determinants of uptake cannot be modeled there. The type of a dependent variable can even vary by 
observation. In this sense, the model is conditional on the data.

{p 4 6 0}
* "Recursive" means, however, that when censored dependent variables appear in each others' equations, these references must break the equations into
stages. If {it:A}, {it:B}, {it:C}, and {it:D} are all binary dependent variables, modeled as probits, then {it:A} and {it:B} could be modeled 
determinants of {it:C} and {it:C} as a determinant of {it:D}--but {it:D} could not then be a 
modeled determinant of {it:A}, {it:B}, or {it:C}.

{p 4 6 0}
* "Simultaneous" means that that recursivity is {it:not} required in the references to the (latent) linear predictors of dependent variables. If {it:A*}, {it:B*}, {it:C*}, and {it:D*}
are the hypothesized, unobserved linear predictors behind the observed {it:A}, {it:B}, {it:C}, and {it:D}--e.g., if {it:A}=0 when {it:A*}<0 and {it:A}=1 when {it:A*}>=0,
etc.--then {it:D*} can appear in any of the equations even though {it:D} cannot. The same holds even if D* is {it:completely} censored, i.e., completely unobserved.

{pstd}
Broadly, {cmd:cmp} is appropriate for two classes of models: 1) those in which the posited data-generating process is fully modeled; and 2) those in which
some equations are structural, while others are reduced form, providing instruments for identification of the parameters in the structural equations, 
as in two-stage least squares. In the first case, {cmd:cmp} is a full-information maximum likelihood (FIML) estimator, and all estimated
parameters are structural. In the latter, it is a limited-information (LIML) estimator, and only the final stage's or stages' coefficients are structural.

{pstd}
{cmd:cmp}'s modeling framework embraces those of the official Stata commands {help probit}, {help ivprobit}, {help treatreg}, 
{help biprobit}, {help tetrachoric}, {help oprobit:oprobit}, {help mprobit}, {help asmprobit}, {help asroprobit}, {help tobit}, {help ivtobit}, 
{help cnreg}, {help intreg}, {help truncreg}, {help fracreg}, {help heckman}, {help heckprob}, {help heckoprobit}, 
{help xtreg}, {help xtprobit}, {help xttobit}, {help xtintreg}, {help xtheckman}, {help meintreg}, {help meprobit}, {help meoprobit}, {help metobit}, {help metobit}, 
{help eprobit}; to lesser degrees {help regress}, {help sureg}, 
and {help reg3}; and user-written {stata findit ssm:ssm}, {stata findit polychoric:polychoric}, {stata findit triprobit:triprobit}, 
{stata findit mvprobit:mvprobit}, {stata findit bitobit:bitobit}, 
{stata findit mvtobit:mvtobit}, {stata findit oheckman:oheckman}, {stata findit switch_probit:switch_probit}, {stata findit reoprob:reoprob}, 
{stata findit cdsimeq:cdsimeq}, and {stata findit bioprobit:bioprobit}.

{pstd}
While lacking the specialized post-estimation features in many of those packages, {cmd:cmp} 
goes beyond them in the generality of model specification. Thanks to the flexibility of {help ml:ml}, on which it is built, it accepts linear coefficient {help constraint:constraints}
as well as all weight types, vce types (robust, cluster, etc.), and {cmd:svy} settings. And it offers 
more flexibility in model construction. For example, one can regress a continuous variable on two endogenous variables, 
one binary and the other sometimes left-censored, instrumenting each with additional variables. And {cmd:cmp} usually allows the model to vary by observations.
Equations can have different samples, overlapping or non-overlapping. Heckman selection modeling can be incorporated into a wide variety of models through auxilliary
probit equations. In some cases, the gain is consistent estimation where it was difficult before. Sometimes the gain is in efficiency.
For example if {it:C} is continuous, {it:B} is a sometimes-left-censored determinant of {it:C}, and {it:A} is an instrument, then the effect of {it:B} on {it:C} can be
consistently estimated with 2SLS (Kelejian 1971). However, a {cmd:cmp} estimate that uses the information that {it:B} is censored will be more efficient if it is based
on a more accurate model.

{pstd}
To inform {cmd:cmp} about the natures of the dependent variables and about which equations apply to which observations, the user must include the 
{cmdab:ind:icators()} option after the comma in the {cmd:cmp} command line. This must contain one expression for each equation. The expression can 
be a constant, a variable name, or a formula. Formulas that contain spaces or parentheses should be enclosed in 
quotes. For each observation, each expression must evaluate to one of the following codes, with the meanings shown:

{pin} 0 = observation is not in this equation's sample{p_end}
{pin} . = observation is in this equation's sample but dependent variable unobserved for this observation{p_end}
{pin} 1 = equation is "continuous" for this observation, i.e., is linear with Gaussian error or is an uncensored observation in a tobit equation{p_end}
{pin} 2 = observation is left-censored for this (tobit) equation at the value stored in the dependent variable{p_end}
{pin} 3 = observation is right-censored at the value stored in the dependent variable{p_end}
{pin} 4 = equation is probit for this observation{p_end}
{pin} 5 = equation is ordered probit for this observation{p_end}
{pin} 6 = equation is multinomial probit for this observation{p_end}
{pin} 7 = equation is interval-censored for this observation{p_end}
{pin} {it:8 = equation is truncated on the left and/or right} (obsolete because truncation is now a general modeling feature){p_end}
{pin} 9 = equation is rank-ordered probit for this observation{p_end}
{pin}10 = equation is frational probit for this observation{p_end}

{pstd}
For clarity, users can execute the {cmd:cmp setup} subcommand, which defines global macros that can then be used in {cmd:cmp} command lines:

{pin}$cmp_out = 0{p_end}
{pin}$cmp_missing = .{p_end}
{pin}$cmp_cont = 1{p_end}
{pin}$cmp_left = 2{p_end}
{pin}$cmp_right = 3{p_end}
{pin}$cmp_probit = 4{p_end}
{pin}$cmp_oprobit = 5{p_end}
{pin}$cmp_mprobit = 6{p_end}
{pin}$cmp_int = 7{p_end}
{pin}$cmp_trunc = 8 (deprecated){p_end}
{pin}$cmp_roprobit = 9{p_end}
{pin}$cmp_frac = 10{p_end}

{pstd}
Equations are specified according to the {cmd:ml model} 
syntax. This means that for instrumented regressions, {cmd:cmp} differs from {help ivregress:ivregress}, {help ivprobit:ivprobit}, 
{help ivtobit:ivtobit}, and similar commands
in not automatically including exogenous regressors (included instruments) from the second stage in the first stage. So you must arrange for this 
yourself. For example, {cmd:ivreg y x1 (x2=z)} corresponds to {cmd:cmp (y=x1 x2) (x2=x1 z), ind($cmp_cont $cmp_cont)}.

{pstd}
At its heart {cmd:cmp} is an SUR (seemingly unrelated regressions) estimator. With major exceptions explained just below, it treats the equations as related to each other only in 
having errors that jointly normally distributed. Mathematically, the likelihood it computes is conditioned on observing {it:all} right-side
variables, including those that also appear on the left side of equations. However, Maximum likelihood (ML) SUR estimators are appropriate for 
many multi-equation models that are not SUR, meaning ones in which endogenous variables appear on the right side of other equations. Models of this 
kind for which ML SUR is consistent must satisfy two criteria: 

{pin}
1) They are recursive. In other words, the equations can be arranged so that the matrix of coefficients of
the dependent variables in each others' equations is triangular. As emphasized above, this means the models have clearly defined stages, though there can be more than one
equation per stage.

{pin}
2) They are "fully observed." Dependent 
variables in one stage enter subsequent stages only as observed. Returning to the example in the first paragraph, if {it:C} is a categorical 
variable modeled as ordered probit, then {it:C}, not the latent variable underlying it, call it {it:C*}, must figure in the model for {it:D}. 

{pstd}
As an illustration of the ideas here, some Stata estimation commands have wider applicability than many realize. {cmd:sureg (X=Y) (Y=Z), isure} typically 
matches {cmd:ivregress 2sls X (Y=Z)} exactly even though 
the documentation does not describe {help sureg:sureg} as an instrumental variables (IV) estimator. 
(Iterated SUR is not a true ML estimator, but it converges to the same solution as ML-based SUR, as implemented, for example, in the demonstration command 
{browse "http://www.stata-press.com/data/ml3.html":mysureg}. See Pagan (1979) on the LIML/iterated SUR connection.) And 
{cmd:biprobit (X=Y) (Y=Z)} will consistently estimate an IV model in which {it:X} and {it:Y} are binary.

{pstd}
Version 6 of cmp, introduced in 2013, can handle violations of both conditions. This it does using the standard technique for estimating simultaneous-equation systems, which transforms
a simultaneous system into an SUR one. Condition 2 is no longer required: models may refer to latent 
variables, using a # suffix. {cmd:cmp (y1 = y2# x1) (y2 = x2), ind($cmp_probit $cmp_probit)} models y1 and y2 as probit and y1 as depending on the unobserved
linear predictor behind y2. The #-suffixed references should be to names of equations rather than dependent variables, though these are the same by default. So, 
equivalent to the previous example is {cmd:cmp (eq1:y1 = eq2# x1) (eq2:y2 = x2), ind($cmp_probit $cmp_probit)}. In addition, references to (latent) linear predictors
need not satisfy condition 1. So {cmd:cmp (y1 = y2# x1) (y2 = y1# x2), ind($cmp_probit $cmp_probit)} is acceptable. References to {it:censored} variables must still be recursive:
{cmd:cmp (y1 = y2 x1) (y2 = y1 x2), ind($cmp_probit $cmp_probit)} will not work as intended. Fortunately, this requirement is not as restrictive as it seems because 
many models with non-recursive dependencies on censored variables are logically impossible (see discussion in Roodman 2011).

{pstd}
When fitting simultaneous linear (uncensored) systems, you must #-suffix enough references so that those not suffixed relate recursively. So 
{cmd:cmp (y1 = y2 x1) (y2 = y1 x2), ind($cmp_cont $cmp_cont)} will fail, but {cmd:cmp (y1 = y2 x1) (y2 = y1# x2), ind($cmp_cont $cmp_cont)} and 
{cmd:cmp (y1 = y2# x1) (y2 = y1# x2), ind($cmp_cont $cmp_cont)} will work and produce the same results (the latter a bit more slowly).

{pstd}
In order to model random coefficients and effects, {cmd:cmp} borrows syntax from {help xtmixed:xtmixed}. It is best explained with 
examples. This {it:eq} fragment specifies an equation with two levels of random effects corresponding to groups defined by the variables {cmd:school} and 
{cmd:class}:

{pin}(math = age || school: || class:)

{pstd}
Coming first, {cmd:school} is understood to be "above" {cmd:class} in the hierarchy. At a given level, random effects can be 
assumed present in some equations and not others. Those in more than one equation at a given level are assumed to be (potentially) correlated
across equations (an assumption that can be overridden through constraints or the {opt cov:ariance()} option). This specifies a school effect only for math but not reading scores,
and potentially correlated class effects for both:

{pin}(math = age || school: || class:) (reading = age || class:){p_end}

{pstd}
This adds random coefficients on age at the class level in both equations. The two new coefficients are potentially correlated with each other and with the random intercepts at the same level:

{pin}(math = age || school: || class: age) (reading = age || class: age){p_end}

{pstd}
Weights of various types may be specified at each level. These should be defined by variables or expressions that are constant within each group
of the given level. Within a given group, {cmd:aweight}s and {cmd:pweight}s are rescaled to sum to the number of groups in the next level 
down (or number of observations if it is the bottom level). {cmd:pweight}s imply {cmd:vce(cluster {it:groupvar})} where 
{it:groupvar} defines the highest level in the hierarchy having 
{cmd:pweight}s. {cmd:iweight}s and {cmd:fweight}s are not rescaled; the latter affect the reported sample size. Since weights must be the same 
across equations, they need be specified only once for each level. So these are equivalent:

{pin}(math = age || school: || class: [pw=weightvar1]) (reading = age || class:){p_end}
{pin}(math = age || school: || class: [pw=weightvar1]) (reading = age || class: [pw=weightvar1]){p_end}

{pstd}
and the contradiction here would cause an error:

{pin}(math = age || school: || class: [pw=weightvar1]) (reading = age || class: [pw=weightvar2]){p_end}

{pstd}
Like {help xtreg:xtreg}, {help xtprobit:xtprobit}, {help xttobit:xttobit}, {help xtintreg:xtintreg}, {help xtheckman:xtheckman}, and {help xtmixed:xtmixed},
{cmd:cmp} uses adaptive quadrature by default to integrate likelihoods over the unobserved random effects (see {manhelp xtmixed R}). Quadrature estimates these 
integrals by evaluating the integrands at a few strategically chosen points (12 by default), and summing using particular weights. It is extremely efficient for computing
one-dimensional integrals, but unreliable. {it:Adaptive} quadrature is more reliable, but slower. It iteratively adjusts the points 
through a change of variables in order to concentrate them near the main mass of the integrated
function.

{pstd}
The traditional generaization of quadrature to multidimensional integrals, such as arise with correlated random effects and coefficients,
is inefficient. A {it:d}-dimensional integral with 12 integration points for each dimension will take 12^{it:d} evaluations. Heiss and Winschel (2008) put forward an alternative called sparse-grid integration
that reduces the number of evaluations needed for a given level of accuracy. {cmd:cmp} uses this method by default for multidimensional random
effects/coefficients problems. Still, despite the reduction, for higher-dimensional problems, practicality may still require the user to reduce the precision of the grid below the default
of 12, using the {cmdab:intp:oints()} option.

{pstd}
{cmd:cmp} also offers a competing method for computing these integrals: simulation. This differs in taking a large, representative set of draws from the hypothesized distributions,
evaluating the integrand at each, and taking the simple average (Train 2009; Greene 2011, 
chap 15). {bf:In the author's experience, despite the innovation of sparse grids, adaptive quadrature under-performs simulation on multidimensional random effects/coefficients.} That
is, simulation tends to achieve higher precision for a given runtime, sometimes especially when used
with the DFP search algorithm (invoked with {cmd:tech(dfp)}). {bf:Adaptive quadrature appears superior for single-effect models}; and for it, the default Berndt-Hall-Hall-Hausman
search method often works best.

{pstd}
To trigger simulation, include the {cmdab:red:raws()} option. This sets the number of draws per observation
at each level, along with
the type of sequence (Halton, Hammersley, generalized Halton, pseudorandom), whether antithetics are also drawn, and, in the Halton and Hammersley cases,
whether and how the sequences should be scrambled. (See Gates 2006 for more on all these concepts except scrambling, for which see Kolenikov 2012.)
For (generalized) Halton and Hammersley sequences, it is preferable to make the number of draws prime, to insure more variable coverage of the
distribution from observation to observation, making coverage more uniform overall. Increasing the 
number of draws increases precision at the expense of time. In a bid for speed {cmd:cmp} can begin by estimating
with just 1 draw per observation per random effect (plus the antithetics if specified). It can then use the result of this rough search as the starting point for an
estimate with more draws, then repeat, multiplying by a fixed amount each time until reaching the specified number of draws. The {opt st:eps(#)} suboption 
of {cmdab:red:raws()} can override the default number of steps, which is just 1. {cmd:redraws(50 50)} would 
specify immediate estimation with the full 50
draws per observation in a three-level model (with two levels of random effects). See {help cmp##options:options} below for more. 

{pstd}
Estimation problems with observations that are censored in three or more equations, 
such as a trivariate probit, require calculation of cumulative 
joint normal distributions of dimension three or higher. This is a non-trivial problem. The preferred technique again involves simulation: the method of
Geweke, Hajivassiliou, and Keane (GHK). (Greene 2011; Cappellari and Jenkins 2003; Gates 2006). {cmd:cmp} accesses the algorithm 
through the separately available Mata function {stata findit ghk2:ghk2()}, which must be installed for {cmd:cmp} to work. Modeled 
on the built-in {help mf_ghk:ghk()} and {help mf_ghkfast:ghkfast()}, {stata findit ghk2:ghk2()} gives users choices about the length and nature of the 
sequences generated for the simulation,
which choices {cmd:cmp} largely passes on through the optional {cmdab:ghkd:raws()} option, which includes {cmd:type()}, {cmdab:anti:thetics}, {cmdab:scr:amble()} 
suboptions. See {help cmp##options:options}
below for more.

{pstd}
{cmd:cmp} starts by fitting each equation separately in order to obtain a good starting point for the full model fit. Sometimes in this preparatory step, 
convergence difficulties make a reported parameter covariance matrix singular, yielding missing 
standard errors for some regressors. Or variables are found to be collinear. In order to maximize the chance of convergence, {cmd:cmp} ordinarily 
drops such regressors from the equations in which they cause trouble, reruns the single-equation fit, and then leaves them out for the full model too. The 
{opt nodr:op} option prevents this behavior.

{title:On estimation with interval-censored or truncated equations}

{pstd}
For equations with interval-censored observations, list two variables before the {cmd:=}, somewhat following the syntax of {help intreg:intreg}. For 
example, {cmd:cmp (y1 y2 = x1 x2), ind($cmp_int)} indicates that the dependent variable is censored to intervals whose lower bounds are in y1 and upper
bounds are in y2. Missing values in y1 are treated as -infinity and those in y2 are treated as +infinity. For observations in which y1 and y2 coincide, there
is no censoring, and the likelihood is the same as for {cmd:$cmp_cont}.

{pstd}
For equations with truncated distributions--which can be any model type besides multinomial and rank-ordered probit--use the {opt trunc:points(exp exp)} option within the specification for the 
given equation to provide truncation points. Like indicator expressions, the truncation points can be constants,
expressions, or variable names, with missing values interpreted as above. Observations in which the observed value lies outside the truncation 
range are automatically dropped for that equation. An example is below.

{marker mprobit}{...}
{title:On estimation with multinomial probit equations}

{pstd}
Multinomial probits can be specified with two different syntaxes, roughly corresponding to the Stata commands {help mprobit:mprobit} and 
{help asmprobit:asmprobit}. In
the first syntax, the user lists a single equation, just as for other dependent variable types, and puts a 6 ({cmd:$cmp_mprobit}) in the
{cmdab:ind:icators()} list. The dependent variable holds the choice made in each case. Like 
{help mprobit:mprobit}, {cmd:cmp} treats all regressors as determinants of choice for all alternatives. In particular,
it expands the specified equation to a group with one "utility" equation for each possible choice. All equations in the group include all regressors, except for the first, 
which has none. This one corresponds to the lowest value of the dependent variable, which is taken as the base alternative. The next, corresponding to the 
second-lowest value, is the "scale alternative," meaning that to normalize results, the variance of its error term is fixed. (The value it is fixed at
depends on whether the {opt struc:tural} option is invoked, on which see below.) In the first syntax, 
the single {it:eq} can contain an {opt iia} option after the comma so that {cmd:cmp}, like {help mprobit:mprobit}, will impose the Independence of 
Irrelevant Alternatives assumption. I.e., {cmd:cmp} will assume
that errors in the utility equations are uncorrelated and have unit variance.

{pstd}
Such models, ones without exclusion restrictions and without the IIA assumption, are formally identified as long as at least one regressor varies over 
alternatives (Keane 1992). However, Keane emphasizes that fits for such models tend to be unstable if there are no exclusion 
restrictions. There are two ways to impose exclusion restrictions with {cmd:cmp}. First, as with {help mprobit:mprobit}, you can use {help constraint:constraints}.

{pstd}
Second, you can use {cmd:cmp}'s other multinomial
probit syntax. In this "alternative-specific" syntax, you list one equation in the {cmd:cmp} command line for each alternative, including the base alternative. Different equations may include different
regressors. Unlike {help asmprobit:asmprobit}, {cmd:cmp} does not force regressors that appear in more than one equation 
to have the same coefficient across alternatives, although again this restriction can be imposed through {help constraint:constraints}. When using
the alternative-specific syntax, the dependent variables listed should be a set of {it:dummies}, as can be generated with {help xi:xi, noomit} from the 
underlying choice variable. The first equation is always treated as the base alternative, so here you can control which alternative is the base alternative
by reordering the equations. In 
general, regressors that appear in all other equations should be excluded from the base alternative. Otherwise, unless a constraint is imposed to reduce the degrees
of freedom, the model will not be identified. ({cmd:cmp} automatically excludes the constant from the base alternative equation.) Variables that are specific 
to the base alternative, however, or to a strict subset of alternatives, can be included in the base alternative equation.  In the second syntax, the IIA is not 
assumed, nor available through an option. It can still be imposed through constraints.

{pstd}
To specify an alternative-specific multinomial probit group, include expressions in the {cmdab:ind:icators()} that evaluate to 0 or 6 
({cmd:$cmp_out} or {cmd:$cmp_mprobit}) for each equation (0 indicating that the choice is not available for given observations). Enclose the 
whole list in 
an additional set of parentheses. Note that unlike with {help asmprobit:asmprobit}, there should be still be one row in the data set per case, not per case and
alternative. So instead of variables that vary by alternative, there must be a version of that variable for each
alternative--not a single travel time variable that varies by mode of travel, but an air travel time variable, a bus travel time variable, and so 
on. An alternative-specific multinomial example is also below.

{pstd}
In a multinomial probit model with J choices, each possible choice has its own structural equation, including an error term. These error terms have some 
covariance structure. It is impossible, however, to estimate all the entries of the JxJ covariance matrix (Train 2003; 
{browse "http://books.google.com/books?id=kbrIEvo_zawC&printsec=frontcover":Long and Freese (2006)}). What is used
in the computation of the likelihood is the (J-1)x(J-1) covariance matrix of the differences of the non-base-alternative errors from the base-alternative error. So by 
default, {cmd:cmp}, much like {help asmprobit:asmprobit}, interprets the sigma and rho parameters relating to these equations as characterizing these 
{it:differenced} errors. To eliminate an excessive degree of scaling freedom, it constrains
the error variance of the first non-base-alternative equation (the "scaling alternative") to 2, which it would be anyway if the errors for the first two 
structural equations were i.i.d. standard normal (so that their difference has variance 2). 

{pstd}
The disadvantage of this parameterization is that it is hard to think about if you want to impose additional constraints on it. As an alternative,
{cmd:cmp}, like {help asmprobit:asmprobit}, offers a {opt struc:tural} option. When this is included, {cmd:cmp} creates a full set of parameters
to describe the covariance of the J structural errors. To remove the excessive degrees of freedom, it then constrains the base alternative error to have 
variance 1 and no correlation with the other errors; and constrains the error for the second, scaling alternative to also have variance 1. To impose the
IIA under this option, one would then constrain various "atanhrho" and "lnsig" parameters to 0. An example below shows how to estimate the same IIA model
with and without the structural parameterization.

{pstd}
The intuitiveness of the structural parameterization comes at a cost, however (Bunch (1991); 
{browse "http://books.google.com/books?id=kbrIEvo_zawC&printsec=frontcover":Long and Freese (2006)}, pp. 325-29). Though the particular set of 
constraints imposed seems innocent, it actually results in a mapping from the space of allowed structural covariances to the space of possible 
covariance matrices for the relative-differenced errors that is not {it:onto}. That is, there are positive definite (J-1)x(J-1) matrices,
valid candidates for the covariance of the relative-differenced errors, which are not compatible with the assumptions that the first two alternatives'
structural errors have variance one {it:and} that the first, base alternative's error is uncorrelated with all other structural errors. So the {opt struc:tural}
option can prevent {cmd:cmp} from reaching the maximum-likelihood 
fit. {browse "http://books.google.com/books?id=kbrIEvo_zawC&printsec=frontcover":Long and Freese (2006)} describe how changing which 
alternatives are the base and scaling alternatives, by reording the equations, can sometimes free an estimator to find the true maximum within the {opt struc:tural}
parametrization.

{marker roprobit}{...}
{title:On estimation with rank-ordered probit equations}

{pstd}
Specification and treatment of rank-ordered probit equations is nearly identical to that in the second syntax for multinomial probits described just
above. Equations must be listed for every alternative. Indicators for these equations must be either 0 or 9 ({cmd:$cmp_out} or {cmd:$cmp_roprobit}) for 
each observation, and grouped in an extra set of parentheses. Constraints defining the base and scale alternatives are automatically imposed in the same way. The {cmd:structural} option too
works identically. One option relating specifically to rank-ordered probit is {cmd:reverse}. It instructs {cmd:cmp} to interpret lower-numbered
rankings as higher instead of lower.

{marker tips}{...}
{title:Tips for achieving and speeding convergence}

{pstd}
If you are having trouble achieving (or waiting for) convergence with {cmd:cmp}, these techniques might help:

{phang2}1. Changing the search techniques using {cmd:ml}'s {help ml##model_options:technique()} option, or perhaps the search parameters, through its
{help ml##ml_maxopts:maximization options}. {cmd:cmp} accepts all these and passes them on to {cmd:ml}. The default Newton-Raphson search method 
usually works very well once {cmd:ml} has found a concave region. The DFP algorithm ({cmd:tech(dfp)}) often works better before then, and the two
can be mixed, as with {cmd:tech(dfp nr)}. See the details of the {cmd:technique()} option at {help ml}.{p_end}
{phang2}2. If the estimation problem requires the GHK algorithm (see above), change the number of draws per observation in the simulation sequence using 
the {opt ghkd:raws()} option. By default, {cmd:cmp} uses twice the square root of the number of observations for which the 
GHK algorithm
is needed, i.e., the number of observations that are censored in at least three equations. Raising simulation accuracy by increasing the number of 
draws is 
sometimes necessary for convergence and can even speed it by improving search precision. On the other hand, especially when the number of observations is
high, convergence can be achieved, at some loss in precision, with remarkably few draws per observations--as few as 5 when the sample size is 10,000 (Cappellari and Jenkins
2003). And taking fewer draws can slash execution time.{p_end}
{phang2}3. Under the same circumstances, in Stata 15 or later, you can also specify {cmdab:ghkd:raws(0)}. This tells {cmd:cmp} to dispense with the GHK algorithm
for computing cumulative multivariate normal distributions and instead use quadrature, as implemented by the built-in {help mf_mvnormal:mvnormal()} family
of functions. When it works, this can run much faster. However, for cumulative probabilities that are close to zero, the functions sometimes return zero or small negative 
values, which have undefined log likelihoods. If this happens, {cmd:cmp} will fail with the "initial values not feasible" message.{p_end}
{phang2}4. If getting many "(not concave)" messages, try the {opt diff:icult} option, which instructs {cmd:ml} to 
use a different search algorithm in non-concave regions.{p_end}
{phang2}5. If the search appears to be converging in likelihood--if the log likelihood is hardly changing in each iteration--and yet fails to converge, try 
adding a {opt nrtol:erance(#)} or {opt nonrtol:erance} option to the command line after the comma. These are {cmd:ml} options that control when convergence is declared. (See
{help cmp##ml_opts:ml_opts}, below.) By default, {cmd:ml} declares convergence when the log likelihood is changing very little with successive iterations (within
tolerances adjustable with the {opt tol:erance(#)} and {opt ltol:erance(#)} options) {it:and} when the calculated gradient vector is close enough to zero. 
In some difficult problems, such as ones with nearly collinear regressors, the imprecision of floating point numbers prevents {cmd:ml} from quite satisfying the second criterion. 
It can be loosened by using the {opt nrtol:erance(#)} to set the scaled gradient tolerance to a value larger than its default of 1e-5, or eliminated altogether
with {opt nonrtol:erance}. Because of the risks of collinearity, {cmd:cmp} warns when the condition number of an equation's regressor matrix exceeds 20 (Greene 2000, p. 40).{p_end}
{phang2}6. Try {cmd:cmp}'s interactive mode, via the {opt inter:active} option. This
allows the user to interrupt maximization by hitting Ctrl-Break or its equivalent, investigate and adjust the current solution, and then restart
maximization by typing {help ml:ml max}. Techniques for exploring and changing the current solution include displaying the current coefficient and gradient vectors 
(with {cmd:mat list $ML_b} or {cmd:mat list $ML_g}) and running {help ml:ml plot}. See {help ml:help ml}, {bf:[R] ml}, and 
{browse "http://books.google.com/books?id=tNhbjQIOKVYC&printsec=frontcover":Gould, Pitblado, and Sribney (2006)} for
details. {cmd:cmp} is slower in interactive mode.
 

{marker options}{...}
{title:Options}

{phang}{cmdab:ind:icators}({it:{help exp:exp}} [{it:{help exp:exp} ...}]) is required. It should pass a list of expressions that evaluate to 0, 1, 2, 3, 
4, 5, 6, 7, 8, or 9 for every 
observation, with one expression for each equation and in the same order. Expressions can be constants, variable names, or 
formulas. Individual formulas that contain spaces or parentheses should be enclosed in quotes.

{phang}{opt l:evel(#)} specifies the confidence level, in percent,
for confidence intervals of the coefficients; see {help level:help level}. The
default is controlled by {help set level} and is usually 95.

{phang}{cmdab:result:sform(}{cmdab:struct:ural} | {cmdab:red:uced)} affects how results are stored and displayed after fitting models with
#-suffixed references. {cmdab:result:sform(}{cmdab:struct:ural)}, the default, displays results
corresponding to the specified model. {cmdab:result:sform(}{cmdab:red:uced)} switches to the reduced form, in which #-suffixed references
are substituted out. After estimation,
you can switch between the two forms by typing {cmd:cmp, {cmdab:result:sform}{cmd:(}{cmdab:red:uced}{cmd:)}} and 
{cmd:cmp, {cmdab:result:sform}{cmd:(}{cmdab:struct:ural}{cmd:)}}. The main value of this option is that it allows {cmd:predict} 
and {cmd:margins} to be executed against the reduced-form 
results, which capture direct and indirect effects of exogenous regressors on endogenous ones, as they cascade through the #-references. (Effects 
transmitted through censored variables or through uncensored ones
not referred to with the # suffix are still left out.) In the case of {cmd:predict}, the same result can be achieved on the fly by adding a 
{cmdab:red:ucedform} option to that command
(see {help cmp##predict:below} for more); this switches to the reduced form just long enough to generate predictions. {cmd:margins}, however,
can be confused by this sleight of hand--as in {cmd:margins, predict(reducedform)}--and return no results. To apply this option in {cmd:svy}
estimation, it is usually best to use {cmd:cmp}'s {cmd:svy} option after the comma (described below) rather than to prefix the {cmd:cmp}
command with {cmd:svy :}.

{phang}{opt qui:etly} suppresses most output: the results from any single-equation initial fits and the iteration log during the full model fit.

{phang}{opt nolr:test} suppresses calculation and reporting of the likelihood ratio (LR) test of overall model fit, relative to
a constant(s)-only model. This has no effect if data are {cmd:pweight}ed or errors are {cmd:robust} or {cmd:cluster}ed.
In those cases, the likelihood function does not reflect the non-sphericity of the errors, and so is a pseudolikelihood. The
LR test is then invalid and is not run anyway.

{phang}{cmdab:intp:oints(}# [# ...]{cmd:)} Sets the precision level for quadrature-based modelling of random effects and coefficients. The default is 12 and the maximum 25. In one-dimensional cases,
such as a single-equation random effects model, this sets the number of integration points in the standard Gaussian-Hermite quadrature algortihm. In higher-dimensional
problems--with more than one random effect or coefficient within or accross equations--it sets the precision level, which in turn determines the number of inegration points. As in the
one-dimensional case, a precision level of {it:k} means that polynomial integrands (which do not arise in {cmd:cmp}) would be exactly estimated if they have degree {it:2k-1} or 
less (Heiss and Winschel 2008). The option should list one number (#) for each level of the model above the base (e.g., two numbers in a three-level model).

{phang}{cmdab:intm:ethod(}[{cmdab:g:hermite} | {cmdab:mva:ghermite}] {cmd:,} [{cmdab:tol:erance(}#{cmd:)} {cmdab:iter:ate(}#{cmd:)}]{cmd:)} is also relevant only for quadrature-based 
modelling of random effects and coefficients. {cmd:ghermite} specifies
classic, non-adaptive Gauss-Hermite quadrature, which is extremely fast, but can be unreliable especially when groups have many observations or subgroups (Rabe-Hesketh, Skrondal, and 
Pickles 2002). {cmd:mvaghermite}, the default, specifies adaptive quadrature using the method developed by Naylor and Smith and first applied in Stata by Rabe-Hesketh, Skrondal, and 
Pickles in {stata findit gllamm:gllamm}. The {cmdab:tol:erance(}#{cmd:)} option sets the tolerance for determining convergence of adaptation; the default is 
1e-3. (Before cmp version 8.0.0, the default was 1e-8, but it was found that increasing the tolerance saved time while hardly affecting 
results.)  {cmdab:iter:ate(}#{cmd:)} sets the the maximum number of iterations that are allowed before giving up on convergence; its default is 1001.

{phang}{cmdab:red:raws(}# [# ...] , [{opt type(halton | hammersley | ghalton | random)} {opt anti:thetics} {opt st:eps(#)} {opt scr:amble(sqrt | negsqrt | fl)}]{cmd:)} is
relevant for random coefficient/effects models, and triggers simulation- rather than quadrature-based modelling. The option 
should begin with one number (#) for each level of the model above the base (e.g., two numbers
in a three-level model); these specify the number of draws per observation from the simulated distributions of the random effects. The optional 
{opt type()} suboption sets the sequence type; the default is halton. The optional {opt anti:thetics} suboption doubles the number of draws
at all levels by including antithetics. For more on these concepts, see See Drukker and Gates (2006). The optional {opt st:eps(#)} 
suboption sets the number of times to fit the model as the number of draws
at each level is geometrically increased to the specified final values. Under this option, the preliminary runs all use the Newton-Raphson search algorithm
and {help ml:ml}'s {cmd:nonrtolerance tolerance(0.1)} options in order to accept coarse fits. This stepping is meant 
only to increase speed by using fewer draws until the search is close to the maximum. The optional {opt scr:amble()} option "scrambles"
the digit sequences to reduce cross-sequence correlations (Kolenikov 2012). The square-root scrambler {opt scramble(sqrt)} multiplies each digit in the
sequence for prime {it:p} by floor(sqrt(p)), modulo p. {opt scramble(negsqrt)} multiples by the negative square root. {opt scramble(fl)} multplies
by the number specific to {it:p} recommended by Faure and Lemieux (2009). {opt scramble(sqrt)} and {opt scramble(lr)} have no effect for models with
at most two random effect/coefficient components because for primes 2 and 3, their multipliers are 1.

{phang}{opt lf} makes {cmd:cmp} use its lf-method evaluator instead of the lf0-method one. (See {help ml:help ml}.) This forces Stata's Maximum Likelihood estimation package 
to compute the first derivatives of the likelihood numerically instead of using {cmd:cmp} to compute them analytically. This substantially slows 
estimation but occassionally improves convergence.

{phang}{cmdab:ghkd:raws(}[#]{cmd: , }[{opt type(halton | hammersley | ghalton | random)} {opt anti:thetics} {opt scr:amble(sqrt | negsqrt | fl)} ]{cmd:)} governs the draws used in GHK simulation of 
higher-dimensional cumulative multivariate normal distributions--or specifies using quadrature rather than the GHK algorithm. It is similar to the {opt red:raws} option. However, it takes at most one number;
if it, or the entire option, is omitted, the number of draws is set rather arbitrarily to twice the square root of the number of observations 
for which the simulation is needed. (Simulated maximum likelihood is consistent as long as the number of draws rises with the square root of the 
number of observations. In practice, a higher number of observations often reduces the number of draws per observation needed
for reliable results. Train 2009, p. 252.) As in the {cmdab:red:raws()} option, the optional {opt type(string)} suboption specifies the type of sequence in 
the GHK simulation, {cmd:halton} being the default;
{opt anti:thetics} requests antithetic draws; and {opt scr:amble()} applies a scrambler.

{pmore}In Stata 15 and later, {cmdab:ghkd:raws(0)} instructs {cmd:cmp} to discard
the GHK algorithm in favor of quadrature, as implemented in the built-in {help mf_mvnormal:mvnormal()} family
of functions. When it works, this can run much faster. However, for cumulative probabilities that are close to zero, the functions sometimes return zero or small negative 
values, which have undefined log likelihoods. If this happens, {cmd:cmp} will fail with the "initial values not feasible" message.

{phang}{opt nodr:op} prevents the dropping of regressors from equations in which they receive missing standard errors in initial single-equation 
fits. It also prevents the removal of collinear variables.

{phang}{opt cov:ariance}({it:covopt} [{it:covopt} ...]) offers a shorthand for constraining the {it:cross-equation} correlation structure of the errors at each 
level--shorthand, that is, compared to using {help constraint:constraint}. There should be one {it:covopt} for each level in the model, ordered from highest to lowest, the
lowest being observation-level. Each {it:covopt} can be {cmdab:un:structured}, {cmdab:ex:changeable}, or {cmdab:ind:ependent}. {cmdab:un:structured}, the default, imposes no 
constraint. {cmdab:ex:changeable} specifies that all correlations between random effects, coefficients, or residual errors in different equations, within a given level, are the same;
and likewise for all the variances of all these areas. {cmdab:ind:ependent} sets all cross-equation correlations at a given level to zero. Above the base level, the default {cmdab:un:structured}, 
while theoretically meaningful, may make the model infeasible. Try fitting with (for a two-level example) {cmd:cov(indep unstruct)}. Separately, the {it:re_equation}
syntax documented above also includes a {opt cov:ariance()} option. With the same choices and defintitions, it controls variances and covariances {it:within} a given equation at a given level.

{phang}{opt inter:active} makes {cmd:cmp} fit the full model in {help ml:ml}'s interactive mode.
This allows the user to interrupt the model fit with Ctrl-Break or its equivalent, view and adjust the trial solution with such 
commands as {help ml:ml plot}, then restart optimization by typing {help ml:ml max}. See {help ml:help ml}, {bf:[R] ml}, and 
{browse "https://www.amazon.com/Maximum-Likelihood-Estimation-Stata-Third/dp/1597180122":Gould, Pitblado, and Sribney (2006)} for 
details. {cmd:cmp} runs more slowly in interactive mode.

{phang}{opt init(vector)} and {opt from(vector)} are synonyms. They pass a row vector of user-chosen starting values for the full model fit, in the manner of the {help ml: ml init, copy} 
command. The vector must contain exactly one element for each parameter {cmd:cmp} will estimate, and in the same order as {cmd:cmp} reports the parameter estimates
in the output. Thus, at the end will be the initial guesses for the lnsig_{it:i} parameters, then those for the atanhrho_{it:ij}, then those
for any ordered-probit cuts. ({cmd:cmp} normally also 
reports sig_{it:i}'s and rho_{it:ij}'s, but these are not additional parameters, merely transformed versions of underlying ones, and should be ignored in building
the vector of starting values.) The names of the row and columns of the vector do
not matter.

{phang}{opt noest:imate} simplifies the job of constructing an initial vector for the {opt init()} option. It instructs {cmd:cmp} to stop before fitting the full model and
leave behind an e(b) return vector with one labeled entry for each free parameter. To view this vector, type {stata "mat list e(b)"}. You can copy or edit this vector, such as 
with "mat b=e(b)", then pass it back to {cmd:cmp} with the {opt init()} option.

{phang}{opt struc:tural} forces the structural covariance parameterization for all multinomial and rank-ordered equation groups. See {help cmp##mprobit:above} for more.

{phang}{opt rev:erse} instructs {cmd:cmp} to interpret lower-numbered ranks in rank-ordered probit equations as being higher.

{phang}{opt ps:ampling(# #)} makes {cmd:cmp} perform "progressive sampling," which can speed estimation on large data sets. First it estimates on 
a small subsample, then a larger one, etc., until reaching the full sample. Each iteration uses the previous one's estimates as a starting point.
The first argument in the option sets the initial sample size, either in absolute terms (if it is at least 1) or as a fraction of 
the full sample (if it is less than 1). The second argument is the factor by which the sample should grow in each iteration. This process is 
analogous to but distinct from the stepping that occurs by default in simulating random effects.

{marker ml_opts}{...}
{phang}{it:ml_opts}: {cmd:cmp} accepts the following standard {help ml} options, which affect the full-model and initial, single-equation fits: {opt tr:ace}
	{opt grad:ient}
	{opt hess:ian}
	{cmd:showstep}
	{opt tech:nique(algorithm_specs)}
	{cmd:vce(}{cmd:oim}|{cmdab:o:pg}|{cmdab:r:obust}|{cmdab:cl:uster}{cmd:)}
	{opt iter:ate(#)}
	{opt tol:erance(#)}
	{opt ltol:erance(#)}
	{opt gtol:erance(#)}
	{opt nrtol:erance(#)}
	{opt nonrtol:erance}
	{opt shownrt:olerance}
	{cmdab:dif:ficult}
	{cmdab:const:raints(}{it:{help numlist}}{c |}{it:matname}{cmd:)}

{phang}{it:display_opts}: {cmd:cmp} accepts the following standard {help ml##mldisplay:ml display} options, which affect how results are presented: {opt noh:eader}
{opt nofoot:note}
{opt neq(#)}
{opt showeq:ns}
{opt pl:us}
{opt nocnsr:eport}
{opt noomit:ted}
{opt vsquish}
{opt noempty:cells}
{opt base:levels}
{opt allbase:levels}
{opth cformat(%fmt)}
{opth pformat(%fmt)}
{opth sformat(%fmt)}
{opt nolstretch}
{opt coefl:egend}

{phang}{it:eform_opts}: {cmd:cmp} accepts the following {help ml##eform_option:ml eform} options:
{opth ef:orm(strings:string)}
{opt ef:orm}
{opt hr}
{opt shr}
{opt ir:r}
{opt or}
{opt rr:r}

{phang}{opt svy} indicates that {cmd:ml} is to pick up the {opt svy} settings set
by {cmd:svyset} and use the robust variance estimator. This option
requires the data to be {helpb svyset}. {opt svy} may
not be specified with {cmd:vce()} or {help weight}s. See {help svy estat:help svy estat}.

{phang}{it:svy_opts}: Along with {cmd:svy}, users may also specify any of these related {help ml:ml} options, which affect how the svy-based
variance is estimated:
	{cmdab:nosvy:adjust}
	{cmdab:sub:pop:(}{it:subpop_spec}{cmd:)}
	{cmdab:srs:subpop}. And users may specify any of these {help ml:ml} options, which affect output display: {cmd:deff}
	{cmd:deft}
	{cmd:meff}
	{cmd:meft}
	{cmdab:ef:orm}
	{cmdab:p:rob}
	{cmd:ci}. See {help svy estat:help svy estat}. 

{marker predict}{...}
{title:On {help predict:predict} and {help margins:margins} after cmp}

{pstd}Options for {cmd:predict} after {cmd:cmp} are:

{synoptset 42 tabbed}{...}
{synopt :{cmdab:eq:uation(}[{cmd:#}{it:eqno}|{it:eqname} {cmd:#}{it:eqno}|{it:eqname}...]{cmd:)}}specify equation(s) for predictions{p_end}
{synopt :{opt xb}}linear prediction{p_end}
{synopt :{opt stdp}}standard error of linear prediction{p_end}
{synopt :{opt stddp}}standard error of difference in linear predictions{p_end}
{synopt :{opt lnl}}observation-level log likelihood (in hierarchical models, averaged over groups){p_end}
{synopt :{opt sc:ores}}derivative of the log likelihood with respect to xb or parameter{p_end}
{synopt :{opt re:siduals}}residuals relative to linear prediction{p_end}
{synopt :{cmd:pr}[{cmd:(}{it:a b}{cmd:)}]}probability of positive outcome (probit) or given outcome (ordered probit, multinomial) or linear predictor being in given range (otherwise). Omitting {cmd:(}{it:a b}{cmd:)} defaults to {cmd:(0 .)}{p_end}
{synopt :{cmd:e}[{cmd:(}{it:a b}{cmd:)}]}truncated expected value: E[y|{it:a}<y<{it:b}]. Omitting {cmd:(}{it:a b}{cmd:)} defaults to {cmd:(. .)}, meaning unbounded{p_end}
{synopt :{cmd:ystar(}{it:a b}{cmd:)}}censored expected value: E(y*), y* = max({it:a}, min(y, {it:b})){p_end}
{synopt :{cmdab:cond:ition(}{it:c d} [, {cmdab:eq:uation(#}{it:eqno}|{it:eqname}{cmd:)}]{cmd:)}}condition a {cmd:pr}, {cmd:e}, or {cmd:ystar} statistic on bounding another equation's (latent) linear predictor between {it:c} and {it:d}{p_end}
{synopt :{opt o:utcome}{cmd:(}{it:outcome}{cmd:)}}specify outcome(s), for ordered probit only{p_end}
{synopt :{opt nooff:set}}ignore any {opt offset()} or {opt exposure()} variable{p_end}
{synopt :{opt red:ucedform}}predict based on reduced form; relevant for linear systems{p_end}

{pstd}
The {cmd:pr}[{cmd:(}{it:a b}{cmd:)}], {cmd:e}[{cmd:(}{it:a b}{cmd:)}], {cmd:ystar(}{it:a b}{cmd:)}, and {cmdab:cond:ition()} options should not include a comma between the 
bounds. In all cases, a missing value means negative infinity in the first bound and positive infinity in the second.

{pstd}
All the above options can also be used in the {cmd:predict()} option of {help margins} to obtain marginal effects on them.

{pstd}
{cmd:cmp}'s most unusual {cmd:predict} option is {cmdab:cond:ition()}. It allows computed probabilities and expectations for one equation's outcome to be conditioned
on the bounding of another equation's outcome (or latent variable). E.g., one can use the option to predict the probability of a student's math score being between 5 and 10 if her reading
score is between 4 and 8 (with something like {cmd: pr(5 10) eq(math) cond(4 8, eq(reading))}), or her expected math score conditioned the same way
({cmd:e eq(math) cond(4 8, eq(reading))}), or even her expected math score when both variables are so bounded ({cmd:e(5 10) eq(math) cond(4 8, eq(reading))}). Probability
estimates for (ordered) probit equations can be conditioned too. To condition on a censored variable being within a certain range, refer to the associated cut points for its hypothesized
latent variable, whether it is fixed (in probit, tobit, and interval regressions) or estimated (ordered probit). For example, to condition on a probit-modeled outcome
{it:x} being 0 or 1, respectively, use {cmd:cond(. 0, eq(x))} or {cmd:cond(0 ., eq(x))}. The Heckman selection model examples below illustrate.

{pstd}
{it:eqno} can be an equation name (if not set explicitly, an equation's name is that of its dependent variable). Or it can be an equation number preceded by a 
{cmd:#}. The default equation is #1, unless the provided variable list has one entry for each equation, or takes the form {it:stub*}. These request 
prediction variables for all equations, with names as given or as automatically generated beginning with {it:stub}. 

{pstd}
In contrast, for ordered probit equations, if {cmd:pr} is specified, {cmd:predict} will by default compute probability variables for all outcomes. The
names for these variables will be automatically generated using a provided variable name as a stub. This stub may be directly provided in the command line--in which case
it should {it:not} include a {cmd:*}--or may itself be automatically generated by a cross-equation {it:stub*}. Thus it is possible to generate probabilities
for all outcomes in all ordered probit equations with a single, terse command. Alternatively, the {opt o:utcome}{cmd:(}{it:outcome}{cmd:)}
option can be used to request probabilities for just one outcome. {it:outcome} can be a value for the dependent variable, or a category number preceded by a {cmd:#}. 
For example, if the categorical dependent variable takes the values 0, 3, and 4, then {cmd:outcome(4)} and {cmd:outcome(#3)} are synonyms. ({cmd:outcome()}
also implies {cmd:pr}.)

{pstd}
In explaining the multi-equation and multi-outcome behavior of {help predict:predict} after {cmd:cmp}, {help cmp##predict_egs:examples} are worth a thousand words.

{pstd}
The flexibility of {cmd:cmp} affects the use of {help predict:predict} and {help margins:margins} after estimation. Because the censoring type (probit, tobit, etc.) can technically
vary by observation, the default statistic for {help predict:predict} is always {cmd:xb}, linear fitted values. This is unlike for {help probit:probit} and {help oprobit:oprobit}, after which
the default is {cmd:pr}, predicted probabilities of outcomes. So to obtain probilities predicted by (ordered) probit equations, remember to include the 
{cmd:pr} option in the {help predict:predict} command line or {cmd:predict(pr)} in the {help margins:margins} command line. (For ordered probit equations, 
an {cmd:outcome()} option will also imply {cmd:pr}.)

{pstd}
When using {help margins:margins} to estimate marginal effects for a {cmd:cmp} estimate,
users may need to include the {cmd:force} and/or {cmd:noestimcheck} options in the {cmd:margins} command line, because
of a bug in some versions of {cmd:margins}. Also, in some cases {cmd:cmp} may first need to be run with the {cmdab:result:sform(}{cmdab:red:uced)}
option (see above) in order to produce any results.

{pstd}
For non-hierarchical models, to compute marginal effects on the probability of a particular outcome, such as (1,1) from a bivariate probit model, you can preserve the data, set the outcome variables to the values of interest,
run {cmd:margins} on the exponential of the predicted log likelihood, using the option {cmd:expression(exp(predict(lnl)))}, then restore the original data set. The method is slow
but intuitive and effective. Examples are below for bivariate probit and multinomial probit models.

{pstd}When non-final-stage equations are uncensored, {cmd:predict}'s {cmdab:red:ucedform} option affects how predictions are made. Suppose we estimate:

{pin}sysuse auto{p_end}
{pin}cmp (price = foreign#) (foreign = mpg), ind($cmp_cont $cmp_probit){p_end}

{pstd}
Of necessity, since foreign# is not observed, {cmd:predict pricehat} will effectivly first predict values for {cmd:foreign} using the second equation, then use 
those to predict values for {cmd:price} in the first equation. That is, it will use the reduced-form coefficients. Now suppose that we treat the second equation
as uncensored:

{pin}cmp (price = foreign#) (foreign = mpg), ind($cmp_cont $cmp_cont){p_end}

{pstd}
In this case, {cmd:predict pricehat, reducedform} will predict as in the previous case. {cmd:predict pricehat} will instead predict values for 
{cmd:price} based on the observed values of {cmd:foreign}. 

{pstd}
Examples of {help predict:predict} and {help margins:margins} after {cmd:cmp} are below.

{title:Citation}

{p 4 8 2}{cmd:cmp} is not an official Stata command. It is a free contribution to the research community.
Please cite it as such: {p_end}
{p 8 8 2}Roodman, D. 2011. Estimating fully observed recursive mixed-process models with cmp. {it:Stata Journal} 11(2): 159-206.{p_end}

{title:Published examples}
{p 4 8 2}See {browse "https://scholar.google.com/scholar?cites=18327562785544861015":Google Scholar}.

{title:Introductory examples}

{pstd}The purpose of {cmd:cmp} is not to match standard commands. But replications 
are the best way to introduce how to use {cmd:cmp} (colored text is clickable):

{phang}{cmd:* Define indicator macros for clarity.}{p_end}
{phang}. {stata cmp setup}{p_end}

{phang}. {stata webuse laborsup}{p_end}

{phang}. {stata regress kids fem_inc male_educ}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ), ind($cmp_cont) quietly}{p_end}

{phang}. {stata sureg (kids = fem_inc male_educ) (fem_work = male_educ), isure}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ) (fem_work = male_educ), ind($cmp_cont $cmp_cont) quietly}{p_end}

{phang}. {stata mvreg  fem_educ male_educ = kids other_inc fem_inc}{p_end}
{phang}. {stata cmp (fem_educ = kids other_inc fem_inc) (male_educ = kids other_inc fem_inc), ind(1 1) qui}{p_end}

{phang}. {stata ivreg fem_work fem_inc (kids = male_educ), first}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ) (fem_work = kids fem_inc), ind($cmp_cont $cmp_cont) qui}{p_end}

{phang}. {stata ivregress liml fem_work (kids = male_educ other_inc fem_inc)}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ other_inc) (fem_work = kids), ind($cmp_cont $cmp_cont) qui}{p_end}

{phang}. {stata probit kids fem_inc male_educ}{p_end}
{phang}. {stata predict p}{p_end}
{phang}. {stata margins, dydx(*)}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ), ind($cmp_probit) qui}{p_end}
{phang}. {stata predict p2, pr}{p_end}
{phang}. {stata margins, dydx(*) predict(pr)}{p_end}

{phang}. {stata oprobit kids fem_inc male_educ}{p_end}
{phang}. {stata margins, dydx(*) predict(outcome(#2))}{p_end}
{phang}. {stata cmp (kids = fem_inc male_educ), ind($cmp_oprobit) qui}{p_end}
{phang}. {stata margins, dydx(*) predict(eq(#1) outcome(#2) pr)}{p_end}

{phang}. {stata gen byte anykids = kids > 0}{p_end}
{phang}. {stata biprobit (anykids = fem_inc male_educ) (fem_work = male_educ)}{p_end}
{phang}. {stata margins, dydx(fem_inc) predict(p11)}{p_end}
{phang}. {stata cmp (anykids = fem_inc male_educ) (fem_work = male_educ), ind($cmp_probit $cmp_probit)}{p_end}
{phang}. {stata preserve}{p_end}
{phang}. {stata replace anykids=1}{p_end}
{phang}. {stata replace fem_work=1}{p_end}
{phang}. {stata margins, dydx(fem_inc) expression(exp(predict(lnl))) force} // marginal effect on probability of (1,1){p_end}
{phang}. {stata restore}{p_end}

{phang}. {stata tetrachoric anykids fem_work}{p_end}
{phang}. {stata cmp (anykids = ) (fem_work = ), ind($cmp_probit $cmp_probit) nolr qui}{p_end}

{phang}. {stata ivprobit fem_work fem_educ kids (other_inc = male_educ), first}{p_end}
{phang}. {stata "version 13: margins, predict(pr) dydx(*)"}{p_end}
{phang}. {stata cmp (fem_work = other_inc fem_educ kids) (other_inc = fem_educ kids male_educ), ind($cmp_probit $cmp_cont)}{p_end}
{phang}. {stata margins, predict(pr) dydx(*) force}{p_end}

{phang}. {stata treatreg other_inc fem_educ kids, treat(fem_work  = male_educ)}{p_end}
{phang}. {stata cmp (other_inc = fem_educ kids fem_work) (fem_work  = male_educ), ind($cmp_cont $cmp_probit) qui}{p_end}

{phang}. {stata tobit fem_inc kids male_educ, ll}{p_end}
{phang}. {stata margins, dydx(*) predict(pr(17,.))}{p_end}
{phang}. {stata cmp (fem_inc = kids male_educ), ind("cond(fem_inc>10, $cmp_cont, $cmp_left)") qui}{p_end}
{phang}. {stata margins, dydx(*) predict(pr(17 .))}{p_end}

{phang}. {stata ivtobit fem_inc kids (male_educ = other_inc fem_work), ll first}{p_end}
{phang}. {stata cmp (fem_inc=kids male_educ) (male_educ=kids other_inc fem_work), ind("cond(fem_inc>10,$cmp_cont,$cmp_left)" $cmp_cont)}{p_end}

{phang}. {stata webuse intregxmpl}{p_end}
{phang}. {stata intreg wage1 wage2 age age2 nev_mar rural school tenure}{p_end}
{phang}. {stata cmp (wage1 wage2 = age age2 nev_mar rural school tenure), ind($cmp_int) qui}{p_end}

{phang}. {stata webuse laborsub}{p_end}
{phang}. {stata truncreg whrs kl6 k618 wa we, ll(0)}{p_end}
{phang}. {stata cmp (whrs = kl6 k618 wa we, trunc(0 .)), ind($cmp_cont) qui}{p_end}

{phang}. {stata webuse 401k}{p_end}
{phang}. {stata fracreg probit prate mrate ltotemp age i.sole}{p_end}
{phang}. {stata margins, dydx(mrate)}{p_end}
{phang}. {stata cmp (prate = mrate ltotemp age i.sole), ind($cmp_frac) qui}{p_end}
{phang}. {stata margins, dydx(mrate) predict(pr)}{p_end}

{phang}. {stata webuse fitness}{p_end}
{phang}. {stata churdle linear hours age i.smoke distance i.single, select(commute whours age) ll(0)}{p_end}
{phang}. {stata gen byte hours_pos = hours > 0}{p_end}
{phang}. {stata cmp (hours = age i.smoke distance i.single, trunc(0 .)) (hours_pos = commute whours age), nolr ind("cond(hours_pos, $cmp_cont, $cmp_out)" $cmp_probit) covar(indep) qui}{p_end}

{phang}. {stata webuse sysdsn3}{p_end}
{phang}. {stata mprobit insure age male nonwhite site2 site3}{p_end}
{phang}. {stata margins, dydx(nonwhite) predict(outcome(2))}{p_end}
{phang}. {stata cmp (insure = age male nonwhite site2 site3, iia), nolr ind($cmp_mprobit) qui}{p_end}
{phang}. {stata margins, dydx(nonwhite) predict(eq(#2) pr)}{p_end}

{phang}. {stata webuse travel}{p_end}
{phang}. {stata asmprobit choice travelcost termtime, casevars(income) case(id) alternatives(mode) struct}{p_end}
{phang}. {stata predict pr, pr} // probability of choosing each outcome in each case{p_end}
{phang}. {stata drop invehiclecost traveltime partysize}{p_end}
{phang}. {stata reshape wide choice termtime travelcost pr, i(id) j(mode)}{p_end}
{phang}. {stata constraint 1 [air]termtime1 = [train]termtime2}{p_end}
{phang}. {stata constraint 2 [train]termtime2 = [bus]termtime3}{p_end}
{phang}. {stata constraint 3 [bus]termtime3 = [car]termtime4}{p_end}
{phang}. {stata constraint 4 [air]travelcost1 = [train]travelcost2}{p_end}
{phang}. {stata constraint 5 [train]travelcost2 = [bus]travelcost3}{p_end}
{phang}. {stata constraint 6 [bus]travelcost3 = [car]travelcost4}{p_end}
{phang}. {stata "cmp (air:choice1=t*1) (train: choice2=income t*2) (bus: choice3=income t*3) (car: choice4=income t*4), ind((6 6 6 6)) constr(1/6) nodrop struct tech(dfp) ghkd(200)"}{p_end}
{phang}. {stata predict cmppr1, eq(air) pr}{p_end}
{phang}. {stata predict cmppr2, eq(train) pr}{p_end}
{phang}. {stata predict cmppr3, eq(bus) pr}{p_end}
{phang}. {stata predict cmppr4, eq(car) pr}{p_end}

{phang}. {stata webuse wlsrank}{p_end}
{phang}. {stata asroprobit rank high low, casevars(female score) case(id) alternatives(jobchar) reverse}{p_end}
{phang}. {stata predict pr, pr1} // probability of ranking each outcome first in each case{p_end}
{phang}. {stata reshape wide rank high low pr, i(id) j(jobchar)}{p_end}
{phang}. {stata constraint 1 [esteem]high1=[variety]high2}{p_end}
{phang}. {stata constraint 2 [esteem]high1=[autonomy]high3}{p_end}
{phang}. {stata constraint 3 [esteem]high1=[security]high4}{p_end}
{phang}. {stata constraint 4 [esteem]low1=[variety]low2}{p_end}
{phang}. {stata constraint 5 [esteem]low1=[autonomy]low3}{p_end}
{phang}. {stata constraint 6 [esteem]low1=[security]low4}{p_end}
{phang}. {stata "cmp (esteem:rank1=high1 low1)(variety:rank2=female score high2 low2)(autonomy:rank3=female score high3 low3)(security:rank4=female score high4 low4),ind((9 9 9 9)) tech(dfp) ghkd(200, type(hammersley)) rev constr(1/6)"}{p_end}
{phang}. {stata predict cmppr1, eq(esteem) pr}{p_end}
{phang}. {stata predict cmppr2, eq(variety) pr}{p_end}
{phang}. {stata predict cmppr3, eq(autonomy) pr}{p_end}
{phang}. {stata predict cmppr4, eq(security) pr}{p_end}

{phang}. {stata webuse class10}{p_end}
{phang}. {stata eprobit graduate income i.roommate, endogenous(hsgpa = income i.hscomp) entreat(program = i.campus i.scholar income) vce(robust)}{p_end}
{phang}. {stata "cmp (graduate = program#(c.income roommate c.hsgpa) program income roommate hsgpa) (program = i.campus i.scholar income) (hsgpa = income i.hscomp), vce(robust) ind(4 4 1) qui nolr":cmp (graduate = program##(c.income roommate c.hsgpa)) (program = i.campus i.scholar income) (hsgpa = income i.hscomp), vce(robust) ind($cmp_probit $cmp_probit $cmp_cont) qui nolr}{p_end}

{pstd}{hilite:* Heckman selection models}

{phang}. {stata webuse womenwk}{p_end}
{phang}. {stata gen selectvar = wage<.}{p_end}
{phang}. {stata heckman wage education age, select(married children education age) mills(heckman_mills)}{p_end}
{phang}. {stata margins, dydx(*) predict(ycond)}{p_end}
{phang}. {stata margins, dydx(*) predict(yexpected)}{p_end}
{phang}. {stata cmp (wage = education age) (selectvar = married children education age), ind(selectvar $cmp_probit) nolr qui}{p_end}
{phang}. {stata margins, dydx(*) predict(e eq(wage) condition(0 ., eq(selectvar)))}{p_end}
{phang}. {stata margins, dydx(*) expression(predict(e eq(wage) cond(0 ., eq(selectvar))) * predict(pr eq(selectvar))  )}{p_end}
{phang}. {stata predict xb, eq(selectvar) xb}{p_end}
{phang}. {stata predict e, eq(selectvar) e(0 .)}{p_end}
{phang}. {stata gen cmp_mills = e - xb}{p_end}

{phang}. {stata gen wage2 = wage > 20 if wage < .}{p_end}
{phang}. {stata heckprob wage2 education age, select(married children education age)}{p_end}
{phang}. {stata margins, dydx(*) predict(pcond)}{p_end}
{phang}. {stata cmp (wage2 = education age) (selectvar = married children education age), ind(selectvar*$cmp_probit $cmp_probit) qui}{p_end}
{phang}. {stata margins, dydx(*) predict(pr eq(wage2) condition(0 ., eq(selectvar)))}{p_end}

{phang}. {stata gen wage3 = (wage > 10)+(wage > 30) if wage < .}{p_end}
{phang}. {stata heckoprobit wage3 education age, select(married children education age)}{p_end}
{phang}. {stata cmp (wage3 = education age) (selectvar = married children education age), ind(selectvar*$cmp_oprobit $cmp_probit) nolr qui}{p_end}

{pstd}{hilite:* Simultaneous equation and latent variable models}

{phang}. {stata sysuse auto}{p_end}

{phang}. {stata cmp (price = foreign#) (foreign = mpg), ind($cmp_cont $cmp_cont) nolr}{p_end}
{phang}. {stata predict pricehat1}{p_end}
{phang}. {stata predict pricehat2, reducedform}{p_end}

{phang}. {stata cmp (price = foreign#) (foreign = mpg), ind($cmp_cont $cmp_probit)}{p_end}

{phang}. {stata replace foreign = . in 1/20}{p_end}
{phang}. {stata cmp (price = foreign#) (foreign = mpg), ind($cmp_cont $cmp_probit)} // sample does not shrink{p_end}

{phang}. {stata webuse klein}{p_end}
{phang}. {stata reg3 (consump wagepriv wagegovt) (wagepriv consump govt capital1), ireg3}{p_end}
{phang}. {stata cmp (consump = wagepriv# wagegovt) (wagepriv = consump# govt capital1), ind($cmp_cont $cmp_cont) nolr tech(dfp) qui}{p_end}

{phang}. {stata webuse supDem}{p_end}
{phang}. {stata "reg3 (qDemand: quantity price pcompete income) (qSupply: quantity price praw), endog(price) first"}{p_end}
{phang}. {stata cmp (price = quantity#  pcompete income) (quantity  = price#  praw), ind($cmp_cont $cmp_cont) nolr tech(dfp) qui}{p_end}
{phang}. {stata cmp, resultsform(reduced)}{p_end}
{phang}. {stata margins, dydx(*) predict(eq(quantity))}{p_end}

{phang}. {stata egen priceO = cut(price), at(25 27 31 33 35 37 39) icodes}{p_end}
{phang}. {stata egen quantityO = cut(quantity), at(5 7 9 11 13 15 17 19 21) icodes}{p_end}
{phang}. {stata "cmp (price: priceO = quantity# pcompete income) (quantity: quantityO = price# praw), ind($cmp_oprobit $cmp_oprobit) nolr qui tech(dfp)"}{p_end}
{phang}. {stata cmp, resultsform(reduced)}{p_end}
{phang}. {stata margins, dydx(praw) predict(outcome(3) eq(quantity) pr)}{p_end}

{pstd}{hilite:* Hierarchical/random effects models}

{phang}. {stata webuse union}{p_end}
{phang}. {stata "xtprobit union age grade not_smsa south south#c.year" :xtprobit union age grade not_smsa south##c.year}{p_end}
{phang}. {stata "gsem (union <- age grade not_smsa south south#c.year M[idcode]@1), probit intp(12)":gsem (union <- age grade not_smsa south##c.year M[idcode]@1), probit intp(12)}{p_end}
{phang}. {stata "cmp (union = age grade not_smsa south south#c.year || idcode:), ind($cmp_probit) qui" :cmp (union = age grade not_smsa south##c.year || idcode:), ind($cmp_probit) qui}{p_end}

{phang}. {stata webuse nlswork3}{p_end}
{phang}. {stata xttobit ln_wage union age grade not_smsa south south#c.year, ul(1.9)}{p_end}
{phang}. {stata "gsem (ln_wage <- union age grade not_smsa south south#c.year M[idcode]@1), family(gaussian, rcensored(1.9)) intp(12)"}{p_end}
{phang}. {stata replace ln_wage = 1.9 if ln_wage > 1.9}{p_end}
{phang}. {stata `"cmp (ln_wage = union age grade not_smsa south south#c.year || idcode:), ind("cond(ln_wage<1.899999, $cmp_cont, $cmp_right)") nolr qui"'}{p_end}

{phang}. {stata webuse nlswork5}{p_end}
{phang}. {stata xtintreg ln_wage1 ln_wage2 union age grade south south#c.year occ_code}{p_end}
{phang}. {stata "gsem (ln_wage1 <- union age grade south south#c.year occ_code M[idcode]@1), family(gaussian, udepvar(ln_wage2)) intp(12)"}{p_end}
{phang}. {stata "cmp (ln_wage1 ln_wage2 = union age grade south south#c.year occ_code || idcode:), ind($cmp_int) nolr qui"}{p_end}

{phang}. {stata webuse tvsfpors}{p_end}
{phang}. {stata "meoprobit thk prethk cc#tv || school: || class:"}{p_end}
{phang}. {stata "cmp (thk = prethk cc#tv || school: || class:), ind($cmp_oprobit) intpoints(7 7) nolr qui"}{p_end}

{phang}. {stata webuse productivity}{p_end}
{phang}. {stata "xtmixed gsp private emp hwy water other unemp || region: || state:"}{p_end}
{phang}. {stata "cmp (gsp = private emp hwy water other unemp || region: || state:), nolr ind($cmp_cont)"}{p_end}

{phang}. {stata webuse womenhlthre}{p_end}
{phang}. {stata gen byte goodhlth = health > 3}{p_end}
{phang}. {stata xteprobit goodhlth exercise grade, entreat(insured = grade i.workschool)}{p_end}
{phang}. {stata "cmp (goodhlth = insured#c.(exercise grade) exercise grade insured || personid:) (insured = grade i.workschool || personid:), ind($cmp_probit $cmp_probit) intp(7) nolr":cmp (goodhlth = insured##c.(exercise grade) || personid:) (insured = grade i.workschool || personid:), ind($cmp_probit $cmp_probit) intp(7) nolr}{p_end}

{phang}. {stata webuse wagework}{p_end}
{phang}. {stata xtheckman wage age tenure, select(working = age market)}{p_end}
{phang}. {stata "cmp (wage = age tenure || personid:) (working = age market || personid:), ind(working*$cmp_cont $cmp_probit) intp(7) nolr"}{p_end}

{pstd}These examples go beyond standard commands (though {help gsem} can do some):

{phang}. {stata webuse laborsup}{p_end}

{phang}{hilite:* Trivariate seemingly unrelated ordered probit}{p_end}
{phang}. {stata gen byte kids2 = kids + int(uniform()*3)}{p_end}
{phang}. {stata gen byte kids3 = kids + int(uniform()*3)}{p_end}
{phang}. {stata cmp (kids=fem_educ) (kids2=fem_educ) (kids3=fem_educ), ind($cmp_oprobit $cmp_oprobit $cmp_oprobit) nolr qui}{p_end}

{phang}{hilite:* Regress an unbounded, continuous variable on an instrumented, binary one. 2SLS is consistent but less efficient.}{p_end}
{phang}. {stata cmp (other_inc = fem_work) (fem_work = kids), ind($cmp_cont $cmp_probit) qui robust}{p_end}
{phang}. {stata ivreg other_inc (fem_work = kids), robust}{p_end}

{phang}{hilite:* Now regress it on a left-censored one, female income, which is only modeled for observations in which the woman works.}{p_end}
{phang}. {stata gen byte ind2 = cond(fem_work, cond(fem_inc, $cmp_cont, $cmp_left), $cmp_out)}{p_end}
{phang}. {stata cmp (other_inc=fem_inc kids) (fem_inc=fem_educ), ind($cmp_cont ind2)}{p_end}

{phang}{hilite:* Correlated random coefficient and random effect}{p_end}
{phang}. {stata "use http://www.stata-press.com/data/mlmus3/gcse"}{p_end}
{phang}. {stata "cmp (gcse = lrt || school: lrt), ind($cmp_cont) nolr"}{p_end}
 
{phang}{hilite:* Multinomial probit with heterogeneous preferences (random effects by individual)}{p_end}
{phang}. {stata "use http://fmwww.bc.edu/repec/bocode/j/jspmix.dta"}{p_end}
{phang}. {stata "cmp (tby = sex, iia || scy3:), ind($cmp_mprobit) nolr"}{p_end}

{phang}{hilite:* Random effects probit dependent on latent first stage}{p_end}
{phang}. {stata webuse union}{p_end}
{phang}. {stata "cmp (union = age not_smsa black# || idcode:) (black = south#c.year), ind($cmp_probit $cmp_probit) nolr"}{p_end}

{marker predict_egs}{...}
{pstd}These illustrate subtleties of {help predict:predict} after {cmd:cmp}:

{phang}. {stata webuse laborsup}{p_end}

{phang}{hilite:* Bivariate seemingly unrelated ordered probit}{p_end}
{phang}. {stata gen byte kids2 = kids + int(uniform()*3)}{p_end}
{phang}. {stata cmp (kids=fem_educ) (kids2=fem_educ), ind($cmp_oprobit $cmp_oprobit) nolr tech(dfp) qui}{p_end}
{phang}{hilite:* Predict fitted values. Fitted values are always the default, as is equation #1}{p_end}
{phang}. {stata predict xbA}{p_end}
{phang}{hilite:* Two ways to predict fitted values for all equations}{p_end}
{phang}. {stata predict xbB*}{p_end}
{phang}. {stata predict xbC xbD}{p_end}
{phang}{hilite:* Get scores for all equations and parameters}{p_end}
{phang}. {stata predict sc*, score}{p_end}
{phang}{hilite:* Get observation-level log-likelihoods }{p_end}
{phang}. {stata predict lnl, lnl}{p_end}
{phang}{hilite:* Two ways to predict kids=0, using (default) first equation}{p_end}
{phang}. {stata predict prA, pr outcome(0)}{p_end}
{phang}. {stata predict prB, outcome(#1)}{p_end}
{phang}{hilite:* Predict kids2=4, using second equation}{p_end}
{phang}. {stata predict prC, outcome(4) eq(kids2)}{p_end}
{phang}{hilite:* Predict all outcomes, all equations.}{p_end}
{phang}. {stata predict prD*, pr}{p_end}
{phang}{hilite:* Same but resulting variable names for the two equations start with prE and prF respectively.}{p_end}
{phang}. {stata predict prE prF, pr}{p_end}
{phang}{hilite:* Predict all outcomes, equation 2. Generates variables prG_Y where Y is outcome number (not outcome value).}{p_end}
{phang}. {stata predict prG, eq(#2) pr}{p_end}

{title:References}

{p 4 8 2}Bunch, D.S. 1991. Estimability in the multinomial probit model. Transportation Research. 25B(1): 1-12.{p_end}
{p 4 8 2}Cappellari, L., and S. Jenkins. 2003. Multivariate probit regression using simulated maximum likelihood.
{it:Stata Journal} 3(3): 278-94.{p_end}
{p 4 8 2}Drukker, D.M., and R. Gates. 2006. Generating Halton sequences using Mata. {it:Stata Journal} 6(2): 214-28. {browse "http://www.stata-journal.com/article.html?article=st0103"}{p_end}
{p 4 8 2}Faure, H., and C. Lemieux. 2009. Generalized Halton Sequences in 2008: A Comparative Study. {it:ACM Transactions on Modeling and Computer Simulation } 19(4): article 15.{p_end}
{p 4 8 2}Gates, R. 2006. A Mata Geweke-Hajivassiliou-Keane multivariate normal simulator. {it:Stata Journal} 6(2): 190-213. {browse "http://www.stata-journal.com/article.html?article=st0102"}{p_end}
{p 4 8 2}Gould, W., J. Pitblado, and W. Sribney. 2006. Maximum Likelihood Estimation with Stata. 3rd ed. College Station: Stata Press.{p_end}
{p 4 8 2}Greene, W.H. 2002. {it:Econometric Analysis}, 5th ed. Prentice-Hall.{p_end}
{p 4 8 2}Greene, W.H. 2011. {it:Econometric Analysis}, 7th ed. Prentice-Hall.
{browse "http://pages.stern.nyu.edu/~wgreene/DiscreteChoice/Readings/Greene-Chapter-17.pdf":Chapter 15}{p_end}
{p 4 8 2}Heiss, F., and V. Winschel. 2008. Likelihood approximation by numerical integration on sparse grids. {it:Journal of Econometrics} 144(1): 62-80.{p_end}
{p 4 8 2}Keane, M.P. 1992. A note on identification in the multinomial probit model. {it:Journal of Business and Economics Statistics} 10(2): 193-200.{p_end}
{p 4 8 2}Kelejian, H.H. 1971. Two-stage least squares and econometric systems linear in parameters but nonlinear in the endogenous variables. 
{it:Journal of the American Statistical Association} 66(334): 373-74.{p_end}
{p 4 8 2}Kolenikov, S. 2012. Scrambled Halton sequences in Mata. {it:Stata Journal} 12(1): 29-44.{p_end}
{p 4 8 2}Long, J. S., and J. Freese. 2006. Regression models for categorical dependent variables using Stata. 2nd ed. College Station, TX: Stata Press.{p_end}
{p 4 8 2}Naylor, J.C., and A.F.M. Smith. 1982. Applications of a method for the efficient computation of posterior distributions. {it:Applied Statistics} 31(3): 214-25.{p_end}
{p 4 8 2}Pagan. A. 1979. Some consequences of viewing LIML as an iterated Aiken estimator. Economics Letters 3:369-372.{p_end}
{p 4 8 2}Papke, L. E., and J. M. Wooldridge. 1996. Econometric methods for fractional response variables with an application
to 401(k) plan participation rates. {it:Journal of Applied Econometrics} 11: 619–32.{p_end}
{p 4 8 2}Pitt, M.M., and S. R. Khandker. 1998. The impact of group-based credit programs on poor households in Bangladesh: Does the gender of participants matter?
{it:Journal of Political Economy} 106(5): 958-96.{p_end}
{p 4 8 2}Rabe-Hesketh, S., A. Skrondal, and A. Pickles. 2002. Reliable estimation of generalized linear mixed models using adaptive quadrature. {it:Stata Journal} 2(1):1-21.{p_end}
{p 4 8 2}Rivers, D., and Q. Vuong. 1988. Limited information estimators and exogeneity tests for simultaneous probit models. {it:Journal of Econometrics} 39: 347-66.{p_end}
{p 4 8 2}Roodman, D. 2011. Estimating fully observed recursive mixed-process models with cmp. {it:Stata Journal} 11(2): 159-206.{p_end}
{p 4 8 2}Smith, R.J., and R.W. Blundell. 1986. An exogeneity test for a simultaneous equation tobit model with an application
to labor supply. {it:Econometrica} 54(3): 679-85.{p_end}
{p 4 8 2}Train, K. 2009. {it:Discrete Choice Methods with Simulation.} 2nd ed. Cambridge University Press. {browse "http://elsa.berkeley.edu/books/choice2.html"}

{title:Author}

{p 4}David Roodman{p_end}
{p 4}david@davidroodman.com{p_end}

{title:Acknowledgements}

{pstd}Thanks to Kit Baum, David Drukker, Arne Hole, Stanislaw Kolenikov, and Mead Over for comments, and to Florian Heiss and Viktor Winschel for permission to adapt
their sparse grid Mata code.{p_end}
