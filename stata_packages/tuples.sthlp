{smcl}
{* 9aug2021}{...}
{cmd:help tuples}
{hline}

{title:Title}

{phang}
{cmd:tuples} {hline 2} Select tuples from a list


{title:Syntax}

{p 8 16 2}
{cmd:tuples} 
{help tuples##list:{it:list}}
[ {cmd:,} {it:options} ]


{marker list}{...}
{p 4 10 2}
where {it:list}, if it is a {varlist}, is {help unab:unabbreviated}. If 
items in {it:list} contain spaces, these items must be enclosed in double 
quotes. 

{synoptset 24 tabbed}{...}
{marker opts}{...}
{synopthdr}
{synoptline}
{syntab:List}
{synopt:{opt asis}}treat {it:list} as is; do not unabbreviate
{p_end}
{synopt:{opt var:list}}treat {it:list} as {it:varlist}; issue an 
error if it is not
{p_end}

{syntab:Selection}
{synopt:{opt max(#)}}specify maximum number of items in a tuple
{p_end}
{synopt:{opt min(#)}}specify minimum number of items in a tuple
{p_end}
{synopt:{opt cond:itionals(string)}}eliminate tuples according 
to specified conditions
{p_end}

{syntab:Reporting}
{synopt:{opt di:splay}}show created tuples
{p_end}

{syntab:Method}
{synopt:{opt nopy:thon}}do not use {help python:Python}; seldom used
{p_end}
{synopt:{opt nom:ata}}do not use {help mata:Mata}; seldom used
{p_end}
{synopt:{opt nos:ort}}do sort tuples; seldom used
{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd}
{cmd:tuples} produces a set of {help macro:local macros}, each containing 
a list of the items defining a tuple selected from a given list. 

{pstd}
By default the given list is tried as a variable list, but if it is not a 
variable list any other kind of list is acceptable, except that no other 
kind of expansion takes place. 

{pstd}
More details are discussed in the {help tuples##remarks:Remarks} section.


{title:Options} 

{dlgtab:List}

{phang}
{opt asis} specifies that the list supplied should be treated as is, 
and thus not {help unab:unabbreviated} as a {help varlist}. {opt asis} 
may not be combined with {opt varlist}.

{phang}
{opt varlist} specifies that the list supplied should be a {help varlist}, 
so that it is an error if the list is not in fact a varlist. {opt varlist} 
may not be combined with {opt asis}.  

{dlgtab:Selection}

{phang}
{opt max(#)} specifies a maximum value for the number of items in a 
tuple. Default {it:#} is {it:n}, i.e., the number of items in the supplied 
list.

{phang}{opt min(#)} specifies a minimum value for the number of items 
in a tuple. Default {it:#} is {cmd:1}. 

{phang}
{cmd:conditionals()} specifies conditional statements to eliminate possible 
tuples according to the rule(s) specified. 

{p 8 8 2}
{cmd:conditionals()} accepts the {help operator:logical operators} {cmd:&} 
for intersections or "and" statements, {cmd:|} for unions or "or" statements, 
{cmd:()} for binding statements and giving statements priority, and {cmd:!} for complements or "not" statements.  

{p 8 8 2}
Other than the foregoing logical operators, {cmd:conditionals()} only accepts 
positional arguments. That is, to refer to the first element of the list, use 
{cmd:1}; to refer to the second element, use {cmd:2}; and so forth. Inapplicable 
positional arguments (e.g., referring to {cmd:4} in a list of size 3) will 
produce an error.  

{p 8 8 2}
Spaces are used to separate conditional statements with {cmd:conditionals()}. A 
single statement must, then, contain no spaces.

{p 8 8 2}
For a worked example, see: {help tuples##conditionals:Using conditionals()}.

{p 8 8 2}
{cmd:conditionals()} is not allowed with Stata based 
{help tuples##methods:methods to produce tuples}.

{dlgtab:Reporting}

{phang}
{cmd:display} specifies that tuples should be displayed.

{dlgtab:Method} 

{phang}
{opt nopython} does not call Python to produce the tuples. This option 
is implied for Stata versions prior to version 16 or if Python is not 
available. {cmd:nopython} is seldom used.

{phang}
{opt nomata} produces tuples outside of the {help mata:Mata} 
environment. This option is implied for Stata versions prior to 
version 10 or for Stata versions greater or equal to version 16 
with {help python:Python} installed. If combined with {opt nopython}, 
{opt nomata} is generally slow; {opt nomata} is seldom used. 

{phang}
{opt nosort} does not sort the produced tuples. By default, {cmd:tuples} 
first produces all singletons, starting with the last item in the list, 
then all distinct pairs, and so on. {opt nosort}, if specified with the 
{help tuples##methods:default method}, produces tuples in a different 
sort order. The exact sort order depends on other options; specifying 
{opt nosort} implies that the exact sort order is irrelevant. The speed 
gain, if any, is typically trivial, unless {opt nopython} and {opt nomata} 
are also specified or implied. In general, {opt nosort} is seldom used.


{marker remarks}{...}
{title:Remarks} 

{pstd}
Remarks are presented under the following headings

{phang2}{help tuples##intro:Introduction}{p_end}
{phang2}{help tuples##conditionals:Using conditionals()}{p_end}
{phang2}{help tuples##methods:Methods to produce tuples}{p_end}

{marker:intro}{...}
{title:Introduction}

{pstd} 
Given a list of {it:n} items, {cmd:tuples} by default produces 2^{it:n} - 1 
macros, named {cmd:tuple1} upwards, which are all possible distinct singletons 
(each individual item); all possible distinct pairs; and so forth. Thus 
given {cmd:frog toad newt}, local macros {cmd:tuple1} through {cmd:tuple7} 
contain 

{phang2}
{...}{break}
{cmd:newt}{break}
{cmd:toad}{break} 
{cmd:frog}{break}
{cmd:toad newt}{break}
{cmd:frog newt}{break}
{cmd:frog toad}{break}
{cmd:frog toad newt}{break}
{p_end}

{pstd}
Here {it:n} = 3, 2^{it:n} - 1 = 7 = {cmd:comb(3,1) + comb(3,2) + comb(3,3)}; 
see {help comb:comb()}.

{pstd}
By default the set of created macros is complete, other than the tuple 
containing no selections. Users wishing to cycle over a set of tuples 
including the empty tuple can exploit the fact that the local macro 
{cmd:tuple0} is undefined, and so empty (unless the user has previously 
defined it explicitly), so that {cmd:tuple0} can be invoked with the correct 
result. 

{pstd} 
Remember that the number of possible macros will explode with the number
of items supplied. For example, if 10 items are supplied, there will be
1,023 macros, 15 items will result in 32,767, and 20 items imply 1,048,575 
macros. The number of macros created by {cmd:tuples} is returned in local 
macro {cmd:ntuples}. 

{pstd}
As of January 2011, {cmd:tuples} is declared to supersede Nicholas
J. Cox's {cmd:selectvars}. 

{marker conditionals}{...}
{title:Using conditionals()}

{pstd}
{cmd:conditionals()} is useful for eliminating potential tuples with 
combinations of the items from the list based on logical statements.

{pstd}
What is most important to remember about the use of {cmd:conditionals()} 
is that the conditional statements apply across {it:all} tuples.  Thus, 
{cmd:conditionals(1)} will force {it:all} tuples to contain the first 
element in the list.

{pstd}
For example, {cmd:conditionals()} can be used to eliminate combinations of 
variables to model in an estimation command that contain products without 
first-order (linear) terms (see {help tuples##example2:Example 2} and
{help tuples##example4:Example 4} below). To do so, consider what is to be 
done.  Imagine 2 variables and their product: {cmd:A}, {cmd:B}, and 
{cmd:A#B} (using {help fvvarlist:factor variable notation}). Assume they 
are listed as

{pstd}
{cmd: A B A#B}

{pstd}
in the list offered to {cmd:tuples}. You need to make sure that {cmd:A#B} 
never appears without both {cmd:A} and {cmd:B}. The challenge is then 
translating that language into a logical statement. 

{pstd}
Begin with an easy component: 
"{hi}...{cmd:A#B} never appears without both {cmd:A} and {cmd:B}{txt}" 
contains 
"{hi}{cmd:A} and {cmd:B}{txt}" 
which can be represented as
"{hi}{cmd:A}&{cmd:B}{txt}" 
or {c -} because {cmd:conditionals()} requires a
positional statement {c -} "{hi}1&2{txt}". Thus, you are left with
"{hi}...{cmd:A#B} never appears without both 1&2{txt}".

{pstd}
In addition, 
"{hi}...{cmd:A#B} never appears without both 1&2{txt}" 
contains the term "{hi}both{txt}". The "{hi}both{txt}"
implies that "{hi}1&2{txt}" is a unit and, therefore, should be put in
parentheses, leading to 
"{hi}...{cmd:A#B} never appears without (1&2){txt}".  
Next, consider the word "{hi}without{sf}" which can be
represented as a "{hi}and not{txt}" statement. Including the 
"{hi}and not{txt}" statement,  
"{hi}...{cmd:A#B} never appears &!(1&2)){txt}".

{pstd}
Finally, the most tricky component: you need to represent the
fact that {cmd:A#B} and not both {cmd:A} and {cmd:B} cannot be allowed.
Hence, the language "{hi}appears{txt}" can be translated first into a
statement binding the positional statement for {cmd:A#B} to the existing
logical statement, producing "{hi}...never 3&!(1&2){txt}". The last
component is simpler, as the "{hi}never{txt}" is clearly a
"{hi}not{txt}" statement.  Because that "{hi}never{txt}" refers to the
notion of {cmd:A#B} appearing with {cmd:A} and {cmd:B}, the
statement must be bound in parentheses, then negated. Incorporating the
last component results in "{hi}!(3&!(1&2)){txt}". Note that there are no 
spaces in the statement.

{pstd}
In most cases, eliminating specific sets of combinations will
require the skillful use of the "{hi}!{txt}" operator.

{marker methods}{...}
{title:Methods to produce tuples}

{pstd}
This section is technical and it is of little practical relevance. 

{pstd}
For Stata versions 16 or higher, {cmd:tuples} is implemented as a 
{help python:Python} {help python:script file} in terms of the 
{browse "https://docs.python.org/3/library/itertools.html#itertools.combinations":combinations()} 
method from the 
{browse "https://docs.python.org/3/library/itertools.html":itertools} 
module. Note that {cmd:tuples} has only been tested in Python versions 3.6 
through 3.9 and, if Python has not been initialized prior to using {cmd:tuples}, {cmd:tuples} will initialize the Python environment as configured in 
{help python:{bf:python query}}.

{pstd}
For Stata versions prior to version 16, or if Python is not available, 
{cmd:tuples} is implemented in {help mata:Mata} as a variation of 
algorithm AS 88 (Gentleman, 1975).

{pstd}
For Stata versions prior to version 10, {cmd:tuples} is implemented in 
terms of nested {help forvalues} loops in Stata. The Stata implementation 
is generally slow.

{pstd}
Earlier implementations of {cmd:tuples} used different methods to produce 
the tuples. These methods are still available as options. The available 
methods are

{p2colset 9 20 20 2}{...}
{p2col:{opt noncr}}combined with {opt nopython} creates an 
{it:n} x (2^{it:n}-1) indicator matrix to produce the tuples
{p_end}
{p2col:{opt kronecker}}implements a method based on staggered 
{help [M-2] op_kronecker:Kronecker} products
{p_end}
{p2col:{opt cvp}}implements a method based on permutations; see 
{help [M-5] cvpermute():cvpermute()}
{p_end}
{p2col:{opt naive}}implements the Stata based method in Mata
{p_end}
{p2colreset}{...}

{pstd}
These alternative methods are typically slower than the default methods and 
sometimes require more memory; the respective options are rarely ever used.


{title:Examples}

{pstd}
{cmd:Example 1}

{pstd}
Obtain all possible tuples from a list 

{phang2}{cmd:. tuples a b c d, asis}{p_end}

{marker example2}{...}
{pstd}
{cmd:Example 2}

{pstd}
Obtain tuples where two words ("the" and "car") appear in all tuples while 
two synonyms ("big" and "large") are not to appear together in any tuple 

{phang2}{cmd:. tuples the big large red fast car, asis conditionals(1&6 !(2&3))}

{pstd}
{cmd:Example 3}

{pstd}
Use {cmd:tuples} to collect and display {cmd:e(r2)} following 
{cmd:regress}

{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. generate rsq = .}{p_end}
{phang2}{cmd:. generate predictors = ""}{p_end}
{phang2}{cmd:. tuples headroom trunk length displacement}{p_end}
{phang2}{cmd:. quietly forvalues i = 1/`ntuples' {c -(}}{p_end}
{phang2}{cmd:. {space 8}regress mpg `tuple`i''}{p_end}
{phang2}{cmd:. {space 8}replace rsq = e(r2) in `i'}{p_end}
{phang2}{cmd:. {space 8}replace predictors = "`tuple`i''" in `i'}{p_end}
{phang2}{cmd:. {c )-}}{p_end}
{phang2}{cmd:. generate p = wordcount(predictors) if predictors != ""}{p_end}
{phang2}{cmd:. sort p rsq}{p_end}
{phang2}{cmd:. list predictors rsq in 1/`ntuples'}
{p_end}

{marker example4}{...}
{pstd}
{cmd:Example 4}

{pstd}
Extension of Example 3, with AIC and an interaction using
{cmd:conditionals()}

{phang2}{cmd:. sysuse auto, clear}{p_end}
{phang2}{cmd:. generate aic = .}{p_end}
{phang2}{cmd:. generate predictors = ""}{p_end}
{phang2}{cmd:. tuples headroom trunk length displacement c.trunk#c.length, conditionals(!(5&!(2&3)))}{p_end}
{phang2}{cmd:. quietly forvalues i = 1/`ntuples' {c -(}}{p_end}
{phang2}{cmd:. {space 8}regress mpg `tuple`i''}{p_end}
{phang2}{cmd:. {space 8}estat ic}{p_end}
{phang2}{cmd:. {space 8}mata: st_store(`i', "aic",  st_matrix("r(S)")[1,5])}{p_end}
{phang2}{cmd:. {space 8}replace predictors = "`tuple`i''" in `i'}{p_end}
{phang2}{cmd:. {c )-}}{p_end}
{phang2}{cmd:. generate p = wordcount(predictors) if predictors != ""}{p_end}
{phang2}{cmd:. sort p aic}{p_end}
{phang2}{cmd:. list predictors aic in 1/`ntuples'}{p_end}


{title:Acknowledgments} 

{pstd}
Sebastian Orbe, Dejin Xie, Fred Lee, and Raymond Zhang reported problems 
that led to bug fixes. 

{pstd}
Volodymyr Vovchack suggested including the {cmd:min()} option. 

{pstd}
E-mail communication 
with William Buchanan and a discussion with John Mullahy on 
{browse "https://www.statalist.org/forums/forum/general-stata-discussion/general/1526657-using-tuples-to-generate-combinations":Statalist}
led to the implementation of the new default {opt nopython} method to produce 
the tuples. Mike Lacy pointed to algorithm AS 88 (Gentleman, 1975) and shared 
code on which the default {opt nopython} implementation is based. 

{pstd}
Thanks to Regina Chua for assistance in testing {cmd:tuples} version 4.0. 


{title:References}

{pstd}
Gentleman, J. F. 1975. Algorithm AS 88: Generation of All NCR Combinations 
by Simulating Nested Fortran DO Loops. Journal of the Royal Statistical 
Society. Series C (Applied Statistics), 24(3), pp. 374--376.


{title:Authors}

{pstd}
Joseph N. Luchman, Fors Marsh Group LLC{break}
jluchman@forsmarshgroup.com

{pstd}
Daniel Klein, Universit{c a:}t Kassel{break}
klein.daniel.81@gmail.com

{pstd}
Nicholas J. Cox, Durham University{break} 
n.j.cox@durham.ac.uk


{title:Also see}

{psee}
Online: {helpb foreach}, {helpb mata}, {helpb python}
{p_end}

