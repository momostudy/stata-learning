{smcl}
{hline}
help for {cmd:bspline}, {cmd:frencurv} and {cmd:flexcurv} {right:(STB-57: sg151; Roger Newson)}
{hline}


{title:{it:B}-splines and splines parameterized by their values at reference points}


{p 8 21 2}
{cmd:bspline} [{help newvarlist:{it:newvarlist}}] {ifin} , {cmdab:x:var(}{varname}{cmd:)}
  [ {opt p:ower(#)}
    {cmdab:k:nots}{cmd:(}{help numlist:{it:numlist}}{cmd:)} {cmd:no}{opt exk:not}
    {opt g:enerate(prefix)} {cmdab:t:ype}{cmd:(}{help datatype:{it:type}}{cmd:)}
    {cmdab:lab:fmt}{cmd:(}{help format:{it:format}}{cmd:)}
    {cmdab:labp:refix}{cmd:(}{it:string}{cmd:)}
  ]

{p 8 21 2}
{cmd:frencurv} [{help newvarlist:{it:newvarlist}}] {ifin} , {cmdab:x:var(}{varname}{cmd:)}
  [ {opt p:ower(#)}
    {cmdab:r:efpts}{cmd:(}{help numlist:{it:numlist}}{cmd:)} {cmd:no}{opt exr:ef} {opt om:it(#)} {opt ba:se(#)}
    {cmdab:k:nots}{cmd:(}{help numlist:{it:numlist}}{cmd:)} {cmd:no}{opt exk:not}
    {opt g:enerate(prefix)} {cmdab:t:ype}{cmd:(}{help datatype:{it:type}}{cmd:)}
    {cmdab:lab:fmt}{cmd:(}{help format:{it:format}}{cmd:)}
    {cmdab:labp:refix}{cmd:(}{it:string}{cmd:)}
  ]

{p 8 21 2}
{cmd:flexcurv} [{help newvarlist:{it:newvarlist}}] {ifin} , {cmdab:x:var(}{varname}{cmd:)}
  [ {opt p:ower(#)}
    {cmdab:r:efpts}{cmd:(}{help numlist:{it:numlist}}{cmd:)} {opt om:it(#)} {opt ba:se(#)}
    {cmdab:inc:lude}{cmd:(}{help numlist:{it:numlist}}{cmd:)} {cmdab:kru:le}{cmd:(}{it:knot_rule}{cmd:)}
    {opt g:enerate(prefix)} {cmdab:t:ype}{cmd:(}{help datatype:{it:type}}{cmd:)}
    {cmdab:lab:fmt}{cmd:(}{help format:{it:format}}{cmd:)}
    {cmdab:labp:refix}{cmd:(}{it:string}{cmd:)}
  ]

{pstd}
where {it:knot_rule} is

{pstd}
{cmdab:r:egular} | {cmdab:i:nterpolate}


{title:Description}

{pstd}
The {cmd:bspline} package contains 3 commands, {cmd:bspline}, {cmd:frencurv} and {cmd:flexcurv}.
{cmd:bspline} generates a basis of {it:B}-splines in the {it:X}-variate based on a list of knots,
for use in the design matrix of a regression model.
{cmd:frencurv} generates a basis of reference splines,
for use in the design matrix of a regression model,
with the property that the parameters fitted will be values of the spline at a list of reference points.
{cmd:flexcurv} is an easy-to-use version of {cmd:frencurv},
and generates reference splines with regularly-spaced knots,
or with knots interpolated between the reference points.
{cmd:frencurv} and {cmd:flexcurv} have the additional option of generating an incomplete basis of reference splines,
which can be completed by the addition of the standard constant variable used in regression models.
The splines are either given the names in the {help newvarlist:{it:newvarlist}} (if present),
or (more usually) generated as a list of numbered variables,
prefixed by the {cmd:generate()} option.
Usually (but not always),
the regression command is called using the {cmd:noconst} option.


{title:Options for use with {cmd:bspline} and {cmd:frencurv}}

{p 4 8 2}
{cmd:xvar(}{varname}{cmd:)} specifies the {it:X}-variate on which the splines are based.

{p 4 8 2}
{opt power(#)} (a non-negative integer) specifies the power (or degree) of the splines.
Examples are zero for constant, 1 for linear, 2 for quadratic, 3 for cubic, 4 for quartic or 5 for quintic.
If absent, zero is assumed.

{p 4 8 2}
{cmd:knots(}{help numlist:{it:numlist}}{cmd:)} specifies a list of at least 2 knots,
on which the splines are based.
If {cmd:knots()} is absent,
then {cmd:bspline} will initialize the list to the minimum and maximum of the {cmd:xvar()} variable,
and {cmd:frencurv} will create a list of knots equal to the reference points
(in the case of odd-degree splines such as a linear, cubic or quintic)
or midpoints between reference points (in the case of even-degree splines such as constant, quadratic or quartic).
{cmd:flexcurv} does not have the {cmd:knots()} option,
as it automatically generates a list of knots,
containing the required number of knots "sensibly" spaced on the {cmd:xvar()} scale.

{p 4 8 2}
{cmd:noexknot} specifies that the original knot list is not to be extended.
If {cmd:noexknot} is not specified,
then the knot list is extended on the left and right by a number of extra knots on each side specified by {cmd:power()},
spaced by the distance between the first and last 2 original knots, respectively.
{cmd:flexcurv} does not have the {cmd:noexknot} option,
as it specifies the knots automatically.

{p 4 8 2}
{opt generate(prefix)} specifies a prefix for the names of the generated splines,
which (if there is no {help newvarlist:{it:newvarlist}})
will be named as {it:prefix}{hi:1}...{it:prefix}{hi:N} where {hi:N} is the number of splines.

{p 4 8 2}
{cmd:type(}{help datatype:{it:type}}{cmd:)} specifies the storage type of the splines generated
({cmd:float} or {cmd:double}).
If {cmd:type()} is given as anything else (or not given), then it is set to {cmd:float}.

{p 4 8 2}
{cmd:labfmt(}{help format:{it:format}}{cmd:)} specifies the format to be used in the variable labels for the generated splines.
If absent, then it is set to the format of the {cmd:xvar()} variable.

{p 4 8 2}
{cmd:labprefix(}{it:string}{cmd:)} specifies the prefix to be used
in the variable labels for the generated splines.
If absent, then it is set to {cmd:"Spline at "} for {cmd:flexcurv} and {cmd:frencurv},
and to {cmd:"B-spline on "} for {cmd:bspline}.


{title:Options for use with {cmd:frencurv}}

{p 4 8 2}
{cmd:refpts(}{help numlist:{it:numlist}}{cmd:)} specifies a list of at least 2 reference points,
with the property that, if the splines are used in a regression model,
then the fitted parameters will be values of the spline at those points.
If {cmd:refpts()} is absent, then the list is initialized to a list of two points,
equal to the minimum and maximum of the {cmd:xvar()} variable.
If the {cmd:omit()} option is specified with {cmd:flexcurv} or {cmd:frencurv},
and the spline corresponding to the omitted reference point
is replaced with a standard constant term in the regression model,
then the fitted parameters will be relative values of the spline (differences or ratios),
compared to the value of the spline at the omitted reference point.

{p 4 8 2}
{cmd:noexref} specifies that the original reference list is not to be extended.
If {cmd:noexref} is not specified, then the reference list is extended on the left and right
by a number of extra reference points on each side equal to {cmd:int(}{it:power}{cmd:/2)},
where {it:power} is the value of the {cmd:power()} option,
spaced by the distance between the first and last 2 original reference points, respectively.
If {cmd:noexref} and {cmd:noexknot} are both specified,
then the number of knots must be equal to the number of reference points plus {it:power}{cmd:+1}.
{cmd:flexcurv} does not have the {cmd:noexref} option,
as it automatically chooses the knots and does not extend the reference points.

{p 4 8 2}
{cmd:omit(#)} specifies a reference point,
which must be present in the {cmd:refpts()} list (after any extension requested by {cmd:frencurv}),
and whose corresponding reference spline will be omitted from the set of generated splines.
If the user specifies {cmd:omit()},
then the set of generated splines will not be a complete basis
of the set of splines with the specified power and knots,
but can be completed by the addition of a constant variable,
equal to 1 in all observations.
If the user then uses the generated splines as predictor variables for a regression command,
such as {helpb regress} or {helpb glm},
then the {cmd:noconst} option should usually not be used,
and, if the omitted reference point is in the completeness region of the basis,
then the intercept parameter {cmd:_cons} will be the value of the spline at the omitted reference point,
and the model parameters corresponding to the generated reference splines
will be differences
between the values of the spline at the corresponding reference points
and the value of the spline at the omitted reference point.
If {cmd:omit()} is not specified,
then the generated reference splines form a complete basis
of the set of splines with the specified power and knots.
If the user then uses the generated splines as predictor variables for a regression command,
such as {helpb regress} or {helpb glm},
then the {cmd:noconst} option should be used,
and the fitted model parameters corresponding to the generated splines
will be the values of the spline at the corresponding reference points.

{p 4 8 2}
{cmd:base(#)} is an alternative to {cmd:omit()}
for use in {help version:Stata Versions 11 or higher}.
It specifies a reference point,
which must be present in the {cmd:refpts()} list (after any extension requested by {cmd:frencurv}),
and whose corresponding reference spline will be set to zero.
If the user specifies {cmd:base()},
then the set of generated splines will not be a complete basis
of the set of splines with the specified power and knots,
but can be completed by the addition of a constant variable,
equal to 1 in all observations.
The generated splines can then be used in the design matrix by an estimation command
in {help version:Stata Versions 11 or higher}.


{title: Options for use with {cmd:flexcurv} only}

{p 4 8 2}
Note that {cmd:flexcurv} also uses all the options available to {cmd:frencurv},
except for {cmd:knots()}, {cmd:noexknot}, and {cmd:noexref}.

{p 4 8 2}
{cmd:include(}{help numlist:{it:numlist}}{cmd:)} specifies a list of additional numbers
to be included within the boundaries of the completeness region of the spline basis,
in addition to the available values of the {cmd:xvar()} variable
and the {cmd:refpts()} values (if provided).
This allows the user to specify a non-default supremum and/or infimum
for the completeness region of the spline basis.
If {cmd:include()} is not provided,
then the completeness region will extend from the minimum to the maximum
of the values either available in the {cmd:xvar()} variable
or specified in the {cmd:refpts()} list.

{p 4 8 2}
{cmd:krule(}{it:knot_rule}{cmd:)} specifies a rule for generating knots,
based on the reference points,
which may be {cmd:regular} (the default) or {cmd:interpolate}.
If {cmd:regular} is specified,
then the knots are spaced regularly over the completeness region of the spline.
If {cmd:interpolate} is specified,
then the knots are interpolated between the reference points,
in a way that produces the same knots as {cmd:krule(regular)}
if the reference points are regularly spaced.
Whichever {cmd:krule()} option is specified,
any extra knots to the left of the completeness region are regularly spaced
with a spacing equal to that between the first 2 knots of the completeness region,
and any extra knots to the right of the completeness region are regularly spaced
with a spacing equal to that between the last 2 knots of the completeness region.
Therefore, {cmd:krule(regular)} specifies that all knots will be regularly spaced,
whether or not the reference points are regularly spaced,
whereas {cmd:krule(interpolate)} specifies that the knots will be interpolated
between the reference points
in a way that will cause reference splines to be definable,
even if the reference points are not regularly spaced.


{title:Remarks}

{pstd}
The splines generated are intended for use in the varlist of an estimation
command (eg {helpb regress} or {helpb glm}), typically with a {cmd:noconst} option
(except if the {cmd:omit()} or {cmd:base()} option is specified with {cmd:frencurv} or {cmd:flexcurv}).
The rules look complicated,
but they are designed to give simple defaults for most users
(especially if {cmd:flexcurv} is used),
and also a powerful choice of options for programmers and advanced users.
The principles and definitions of {it:B}-splines are given in de Boor (1978) and Ziegler (1969).
{cmd:frencurv} and {cmd:flexcurv} calculate the reference splines by calling {cmd:bspline}
to calculate {it:B}-splines based on the reference points, the {cmd:xvar()} variable,
and the {cmd:include()} option (if supplied to {cmd:flexcurv}),
and then invert the matrix of the {it:B}-splines for the reference points to generate a transformation matrix,
which is then used to transform the {it:B}-splines to reference splines.
The principles and definitions of reference splines are given in detail in
Newson (2012), Newson (2011), Newson (2001) and Newson (2000).

{pstd}
Full documentation of the {cmd:bspline} package (including Methods and Formulas)
is provided in the file {cmd:bspline.pdf},
which is distributed with the {cmd:bspline} package as an ancillary file
(see help for {helpb net}).
It can be viewed using the Adobe Acrobat Reader, which can be downloaded from
{browse "http://www.adobe.com/products/acrobat/readermain.html"}.


{title:Examples}

{pstd}
These examples demonstrate the fitting of a spline model of {cmd:mpg} with respect to {cmd:weight}
in the {helpb datasets:auto} dataset shipped with official Stata.

{pstd}
Set-up:

{phang2}{inp:. sysuse auto, clear}{p_end}
{phang2}{inp:. describe}{p_end}

{pstd}
The following example demonstrates the use of {cmd:flexcurv}
to define a basis of cubic reference splines in {cmd:weight},
with regularly-spaced knots and regularly-spaced reference points.
We then use {helpb regress}, with the {cmd:noconst} option,
to fit a spline regression model,
whose parameters ({cmd:cs1} to {cmd:cs5})
are the values of the spline at the reference points,
each equal to the estimated conditional mean of {cmd:mpg}
for cars with {cmd:weight} equal to the corresponding reference point.
Differences between conditional means can then be estimated (with confidence limits),
using {helpb lincom}.
Finally, we use {helpb predict} to compute the predicted values of {cmd:mpg} for all cars,
and plot the observed and fitted values of {cmd:mpg} against {cmd:weight}.

{phang2}{inp:. flexcurv, xvar(weight) refpts(1760(770)4840) gen(cs) power(3)}{p_end}
{phang2}{inp:. describe cs*}{p_end}
{phang2}{inp:. regress mpg cs*, robust noconst}{p_end}
{phang2}{inp:. lincom cs3-cs5}{p_end}
{phang2}{inp:. predict mpghat3}{p_end}
{phang2}{inp:. scatter mpg weight, msym(circle_hollow) || line mpghat3 weight, sort ||, xlab(1760(770)4840) ylab(0(5)45) legend(row(1))}{p_end}

{pstd}
The following example demonstrates the use of {cmd:flexcurv} with the {cmd:omit()} option
to fit the same model as the previous example,
generating an incomplete basis of reference splines
by omitting the reference spline for a {cmd:weight} of 1760 US pounds.
We then use {helpb regress} without the {cmd:noconst} option
to fit the spline model.
The parameters, in this case, are the constant term {cmd:_cons},
equal to the conditional mean {cmd:mpg} for cars with the omitted {cmd:weight} of 1760 US pounds,
and the cubic spline parameters {cmd:cs2} to {cmd:cs5},
equal to the difference, in conditional means of {cmd:mpg},
between cars with a {cmd:weight} equal to the corresponding reference point
and cars with a {cmd:weight} equal to the omitted reference point of 1760 US pounds.
Again, we can use {cmd:lincom} to estimate differences between means for non-omitted reference points,
and we can use {cmd:predict} to compute the fitted values of {cmd:weight},
which are the same as in the previous example.

{phang2}{inp:. flexcurv, xvar(weight) refpts(1760(770)4840) omit(1760) gen(ics) power(3)}{p_end}
{phang2}{inp:. describe ics*}{p_end}
{phang2}{inp:. regress mpg ics*, robust}{p_end}
{phang2}{inp:. lincom ics3-ics5}{p_end}
{phang2}{inp:. predict mpghat3a}{p_end}
{phang2}{inp:. scatter mpg weight, msym(circle_hollow) || line mpghat3a weight, sort ||, xlab(1760(770)4840) ylab(0(5)45) legend(row(1))}{p_end}

{pstd}
The following example demonstrates the use of {cmd:frencurv}
to fit the same model again,
this time with reference points equal to the knots
in and around the completeness region of the spline.
This has the consequence that the list of reference points
is extended on the left and on the right
by adding 2 reference points outside the completeness region,
whose corresponding spline parameters represent the behavior of the spline
as it converges back to zero outside its completeness region.
These 2 extra parameters are not easy to explain to non-mathematicians.

{phang2}{inp:. frencurv, xvar(weight) refpts(1760 3300 4840) gen(kcs) power(3)}{p_end}
{phang2}{inp:. describe kcs*}{p_end}
{phang2}{inp:. regress mpg kcs*, robust noconst}{p_end}
{phang2}{inp:. predict mpghat3b}{p_end}
{phang2}{inp:. scatter mpg weight, msym(circle_hollow) || line mpghat3b weight, sort ||, xlab(1760 3300 4840) ylab(0(5)45) legend(row(1))}{p_end}

{pstd}
The following example uses {cmd:frencurv} to fit the same model as the previous example,
using the {cmd:omit()} option to omit the reference
spline corresponding to the reference point (and knot) at 1760 US pounds.
This time, the parameter {cmd:_cons} represents the mileage at 1,760 uS pounds,
the parameters {cmd:ikcs2} and {cmd:ikcs3} represents the differences
between the mileages at 3,300 and 4,840 US pounds (respectively)
and the mileage at 1,760 pounds,
and the parameters {cmd:ikcs1} and {cmd:ikcs5} represent the behavior of the spline
as it converges back to zero outside its completeness region.

{phang2}{inp:. frencurv, xvar(weight) refpts(1760 3300 4840) omit(1760) gen(ikcs) power(3)}{p_end}
{phang2}{inp:. describe ikcs*}{p_end}
{phang2}{inp:. regress mpg ikcs*, robust}{p_end}
{phang2}{inp:. predict mpghat3c}{p_end}
{phang2}{inp:. scatter mpg weight, msym(circle_hollow) || line mpghat3c weight, sort ||, xlab(1760 3300 4840) ylab(0(5)45) legend(row(1))}{p_end}

{pstd}
The following example demonstrates the use of {cmd:bspline}
to fit the same model as the previous examples,
generating a basis of Schoenberg {it:B}-splines.
We then use {helpb regress} with the {cmd:noconst} option
to fit the spline model.
The parameters, in this case, correspond to the {it:B}-splines,
and are again expressed in units of the {it:Y}-variable {cmd:mpg}.
They are not easy to interpret in a way that non-mathematicians will understand,
and nor are the differences between parameters that might be estimated using {cmd:lincom}.
However, we can still use {helpb predict} to compute fitted values for {cmd:mpg},
which (together with the observed values) can be plotted against {cmd:weight} exactly as before.

{phang2}{inp:. bspline,xvar(weight) knots(1760 3300 4840) gen(bs) power(3)}{p_end}
{phang2}{inp:. describe bs*}{p_end}
{phang2}{inp:. regress mpg bs*, robust noconst}{p_end}
{phang2}{inp:. predict mpghat3d}{p_end}
{phang2}{inp:. scatter mpg weight, msym(circle_hollow) || line mpghat3d weight, sort ||, xlab(1760 3300 4840) ylab(0(5)45) legend(row(1))}{p_end}


{title:Saved results}

{pstd}
{cmd:bspline}, {cmd:frencurv} and {cmd:flexcurv} save the following results in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(xsup)}}upper bound of completeness region{p_end}
{synopt:{cmd:r(xinf)}}lower bound of completeness region{p_end}
{synopt:{cmd:r(nincomp)}}number of {it:X}-values out of completeness region{p_end}
{synopt:{cmd:r(nknot)}}number of knots{p_end}
{synopt:{cmd:r(nspline)}}number of splines{p_end}
{synopt:{cmd:r(power)}}power (or degree) of splines{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(knots)}}final list of knots{p_end}
{synopt:{cmd:r(splist)}}{it:varlist} of generated splines{p_end}
{synopt:{cmd:r(labfmt)}}format used in spline variable labels{p_end}
{synopt:{cmd:r(labprefix)}}prefix used in spline variable labels{p_end}
{synopt:{cmd:r(type)}}storage type of splines ({cmd:float} or {cmd:double}){p_end}
{synopt:{cmd:r(xvar)}}{it:X}-variable specified by {cmd:xvar()} option{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(knotv)}}row vector of knots{p_end}
{p2colreset}{...}

{pstd}
{cmd:frencurv} and {cmd:flexcurv} save all of the above results in {cmd:r()}, and also the following:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(omit)}}omitted reference point specified by {cmd:omit()}{p_end}
{synopt:{cmd:r(base)}}base reference point specified by {cmd:base()}{p_end}

{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(refpts)}}final list of reference points{p_end}

{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(refv)}}row vector of reference points{p_end}
{p2colreset}{...}

{pstd}
The result {cmd:r(nincomp)} is the number of values of the {cmd:xvar()} variable
outside the completeness region of the space of splines defined by the reference splines or {it:B}-splines.
The number lists {cmd:r(knots)} and {cmd:r(refpts)} are the final lists
after any left and right extensions carried out by {cmd:bspline}, {cmd:frencurv} or {cmd:flexcurv},
and the vectors {cmd:r(knotv)} and {cmd:r(refv)} contain the same values in double precision
(mainly for programmers).
The scalars {cmd:r(xinf)} and {cmd:r(xsup)} are knots,
such that the completeness region is {cmd:r(xinf)} {it:<= x <=} {cmd:r(xsup)} for positive-degree splines
and {cmd:r(xinf)} {it:<= x <} {cmd:r(xsup)} for zero-degree splines.

{pstd}
In addition, {cmd:bspline}, {cmd:frencurv} and {cmd:flexcurv} save {help char:variable characteristics}
for the output spline basis variables.
The characteristic {it:varname}{cmd:[xvar]} is set by {cmd:bspline}, {cmd:frencurv} and {cmd:flexcurv}
to be equal to the input {it:X}-variable name set by {cmd:xvar()}.
The characteristics {it:varname}{cmd:[xinf]} and {it:varname}{cmd:[xsup]}
are set by {cmd:bspline} to be equal to the infimum and supremum, respectively,
of the interval of {it:X}-values for which the {it:B}-spline is non-zero.
The characteristic {it:varname}{cmd:[xvalue]} is set by {cmd:frencurv} and {cmd:flexcurv}
to be equal to the reference point on the {it:X}-axis corresponding to the reference spline.
The characteristic {it:varname}{cmd:[basestat]} is set by {cmd:frencurv} and {cmd:flexcurv}
to be 1 if the reference point on the {it:X}-axis corresponding to the reference spline
is equal to the {cmd:base()} option,
and to be 0 otherwise.


{title:Author}

{pstd}
Roger Newson, King's College London, UK.
Email: {browse "mailto:roger.newson@kcl.ac.uk":roger.newson@kcl.ac.uk}


{title:References}

{phang}
de Boor C.  1978.
{it:A Practical Guide to Splines.}
New York: Springer Verlag.

{phang}
Newson R. B.  2012.
Sensible parameters for univariate and multivariate splines.
{it:The Stata Journal} 12(3): 479-504.
Download from
{browse "http://www.stata-journal.com/article.html?article=sg151_2"}.

{phang}
Newson R. B.  2011.
Sensible parameters for polynomials and other splines.
Presented at the 17th UK Stata User Meeting, 15-16 September, 2011.
Download from
{browse "http://ideas.repec.org/p/boc/usug11/01.html"}.

{phang}
Newson R.  2001.
Splines with parameters that can be explained in words to non-mathematicians.
Presented at the 7th UK Stata User Meeting, 14–15 May, 2001.
Download from
{browse "http://ideas.repec.org/p/boc/usug01/11.html"}.

{phang}
Newson R.  2000.
sg151: {it:B}-splines and splines parameterized by their values at reference points on the {it:X}-axis.
{it:Stata Technical Bulletin} 57: 20-27.
Reprinted in {it:Stata Technical Bulletin Reprints}, vol. 10, pp. 221-230.
Download from
{browse "http://www.stata.com/products/stb/journals/stb57.html"}.

{phang}
Ziegler Z.  1969.
One-Sided L_1-Approximation by Splines of an Arbitrary Degree.
In: Schoenberg I. J. (ed.)  1969.
{it:Approximations with Special Emphasis on Spline Functions.}
New York: Academic Press.


{title:Also see}

{p 4 13 2}
{bind: }Manual: {hi:[R] mkspline}
{p_end}
{p 4 13 2}
On-line: help for {helpb mkspline}
{break} help for {helpb spline}, {helpb spbase}, {helpb sp_adj} if installed
{p_end}

