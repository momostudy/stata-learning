{smcl}
{* *! Help file version 1.5 written by Mead Over (mover@cgdev.org) 18Dec2018}{...}
{vieweralsosee "[R] estimates" "mansection R estimates"}{...}
{vieweralsosee "[R] estimates table" "mansection R estimatestable"}{...}
{vieweralsosee "[P] ereturn" "mansection P ereturn"}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "estimates" "help estimates"}{...}
{vieweralsosee "estimates store" "help  estimates_store"}{...}
{vieweralsosee "estimates table" "help  estimates_table"}{...}
{vieweralsosee "ereturn" "help ereturn"}{...}
{vieweralsosee "outreg" "help outreg"}{...}
{vieweralsosee "outreg2" "help outreg2"}{...}
{vieweralsosee "xml_tab" "help xml_tab"}{...}
{vieweralsosee "esttab" "help esttab"}{...}
{vieweralsosee "estout" "help estout"}{...}
{vieweralsosee "erepost" "help erepost"}{...}
{viewerjumpto "Syntax" "addest##syntax"}{...}
{viewerjumpto "Description" "addest##description"}{...}
{viewerjumpto "Options" "addest##options"}{...}
{viewerjumpto "Examples" "addest##examples"}{...}
{viewerjumpto "Author" "addest##author"}{...}
{title:Title}

{p2colset 5 22 26 2}{...}
{p2col :{cmd:addest} {hline 2}}Add scalar, vector, matrix or text information to estimation results{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmd:addest}
[
{cmd:,}
    {cmdab:n:ame(}{it:charstring}{cmd:)}
    {cmdab:v:alue(}{it:numeric value}{cmd:)}
    {cmdab:b:vector(}{it:vector name}{cmd:)}
    {cmdab:vce:matrix(}{it:matrix name}{cmd:)}
    {cmdab:rename}
    {cmdab:augb:vector(}{it:number}{cmd:)}
    {cmdab:augvce:matrix(}{it:number}{cmd:)}
    {cmdab:augc:oefname(}{it:string}{cmd:)}
    {cmdab:auge:qname(}{it:string}{cmd:)}
    {cmdab:textn:ame(}{it:string}{cmd:)}
    {cmdab:texts:tring(}{it:string}{cmd:)}
    {cmdab:matn:ame(}{it:ematrix_name}{cmd:)}
    {cmdab:matr:ix(}{it:existing_matrix}{cmd:)}
    {cmdab:findomitted}
    {cmdab:buildfv:info}
    {cmdab:post}
    {cmdab:repost}
	{cmd:*}
]

{marker description}{...}
{title:Description}

{p 4 4 2}
{cmd:addest} augments the capabilities of STATA's {help ereturn} command
and of the post-estimation commands that use the estimation results
stored in {help ereturn} by allowing the user to add items to those stored 
with a set of estimation results.

{p 4 4 2}
Every estimation command leaves its results behind in memory.  
The user can then view these saved results by typing {cmd:ereturn list} and 
use any of the stored results in subsequent calculations 
by referring specifically to any element stored in this space.  
For example, the user may access the sample size of the
most recent estimation command by typing:

{p 4 4 2}
{cmd:display e(N)}

{p 4 4 2}
Furthermore, {help post-estimation} commands provided by Stata or
contributed by users rely on the contents of {help ereturn} for further analysis.
Examples include Stata's powerful {help margins} and {help marginsplot} commands
as well as its more prosaic {help estimates table} command.   
The {help estimates table} command is useful for presenting the results
of several estimated models side by side.  More powerful programs to display
the estimation results of several models in a similar table include 
{help esttab}, {help xml_tab}, {help outreg} and {help outreg2}.  

{p 4 4 2}
This {cmd:addest} command addresses the situation that arises if the user wishes 
that a {help post-estimation} command would display or manipulate
some characteristic of the original estimated model that is not part of the stored
results.  

{marker options}{...}
{title:Options}

{cmdab:n:ame(}{it:charstring}{cmd:))} {cmdab:v:alue(}{it:numeric value}{cmd:)}
{p 4 4 2}
These two options are a pair and must be specified together.  
The {cmdab:n:ame} option specifies the name of the scalar to be added to the {help ereturn} space.
The {it:charstring} designating the {cmd:name} cannot contain spaces or special characters, 
because it becomes the name of a Stata {help macro}. 
If the user specifies a name that already exists, its value is overwritten.

{cmdab:b:vector(}{it:vector name}{cmd:)} {cmdab:vce:atrix(}{it:matrix name}{cmd:)}
{p 4 4 2}
These two options are also a pair.  
They enable a user to replace the vector of estimated coefficients and its variance-covariance matrix.
The new coefficient vector and variance-covariance matrix must have the same 
numbers of rows and columns as those currently in the {help ereturn} space.

{cmd:rename} 
{p 4 4 2}
{cmd:rename} is allowed only with the {cmdab:b:vector(}{it:vector name}{cmd:)} 
{cmdab:vce:atrix(}{it:matrix name}{cmd:)} syntax
and tells Stata to use the names obtained from the
specified {it:b} vector as the labels for both the {cmd:b} and {cmd:V}
estimation matrices.  These labels are subsequently used in the output
produced by {cmd:ereturn display} or {cmd:estimates table}.

{cmdab:augb:vector(}{it:number}{cmd:)} {cmdab:augvce:atrix(}{it:number}{cmd:)} {cmdab:augc:oefname(}{it:string}{cmd:)} {cmd:[ }{cmdab:auge:qname(}{it:string}{cmd:) ]}
{p 4 4 2}
These four options are also a set.  The first three should always be specified together.
The fourth, which specifies an equation name for the added coefficient estimate,
is only needed if the e(b) and e(V) results already stored in e(return) include equation names.
These options enable a user to add a single estimated coefficient to the coefficient vector, e(b), 
and to add it's estimated variance to the estimated variance-covariance matrix 
of coefficients, e(V). 

{cmdab:textn:ame(}{it:string_with_no_blanks}{cmd:)} {cmdab:texts:tring(}{it:string_with_no_blanks}{cmd:)}
{p 4 4 2}
These two options are a pair and must be specified together.  They can be used to add
an arbitrary character string as a macro in the e(return) results.

{cmdab:matn:ame(}{it:ematrix_name}{cmd:)} {cmdab:matr:ix(}{it:existing_matrix}{cmd:)}
{p 4 4 2}
These two options are a pair and must be specified together.  
They load a previously created Stata matrix named {it:existing_matrix}
into the {help ereturn} space as a matrix named {it:ematrix_name}. 
The {it:ematrix_name} cannot contain spaces or special characters. 
If the user specifies a name that already exists in the {help ereturn} space, 
its value is overwritten.

{cmd:post} or {cmd:repost} 
{p 4 4 2}
When changing or updating estimation results in the {help ereturn} space,
{cmd:addest} selects by default the {cmd:repost} option.  When updating or adding
to other parts of the {help ereturn} space, {cmd:addest} selects the {cmd:post}
option by default.  Optionally, the user can override these defaults by explicitly 
specifying {cmd:post} or {cmd:repost}. 

{cmd:findomitted}
{p 4 4 2}
specified with {cmd:ereturn post} and {cmd:ereturn repost}.
Adds the omit operator {cmd:o.} to variables in the column
names corresponding to zero-valued diagonal elements of {cmd:e(V)}. 
This option is passed direclty to {help ereturn repost}. 

{cmdab:buildfv:info}
{p 4 4 2}
specified with {cmd:ereturn post} and {cmd:ereturn repost}
computes the {cmd:H} matrix that postestimation commands
{helpb contrast},
{helpb margins}, and
{helpb pwcompare} use for determining estimable functions.
This option is passed directly to {help ereturn repost}.

{cmd:* ({it:other options})} 
{p 4 4 2}
Any other options are passed through to either {help ereturn post} or {help ereturn repost}.


{marker examples}{...}
{title:Example of the use of the {cmdab:n:ame(}{cmd:)} and {cmdab:v:alue(}{cmd:)} options}

{p 4 4 2}
For this example, we use Galton's original data set on the heights of children,
which he used to show that children's hieight can be accurately, though not
exactly, predicted from the height of their parents.  For purposes of this example,
the original data has been supplemented with data on the ages of the children.
(In reality Galton only used data from adult children.)  The supplemented data
set is called galton.dta and can be downloaded with this program.

{p 4 4 2}
Suppose one estimates a model that predicts height based on 
the father's height, {cmd:fheight}, the mother's height {cmd:mheight} and the child's age, 
where age is only available as a set of three dummy variables defined respectively as:

{p 4 4 2}
Dage5 = 1 if age > 5, 0 otherwise.
 
{p 4 4 2}
Dage10 = 1 if age >10, 0 otherwise. 

{p 4 4 2}
Dage15 = 1 if age>15, 0 otherwise.

{p 4 4 2}
All three dummies would be zero if the child is less than or equal to 5 years old.

{p 4 4 2}
First load the data in memory with the command:

use galton, clear
  
{p 4 4 2}
Then run a regression of the child's height only on the father's height and 
the age dummies with the regression command:

regress height fheight Dage5 Dage10 Dage15

{p 4 4 2}
One might want to test the hypothesis that age is statistically significant with an F-test
computed by the command:

test Dage5 Dage10 Dage15

{p 4 4 2}
It would be convenient if a command that displays the results of a regression in tabular form
like {help estimates table}, {help outreg} or {help xml_tab}, would display the results of 
this F-test in the appropriate column. From a Stata {help do file} one cannot add to
the contents of the {help ereturn} macros.

{p 4 4 2}
Using {cmd: addest}, the solution to this problem is as follows:

regress height fheight Dage5 Dage10 Dage15
  test Dage5 Dage10 Dage15
    addest, name("F_of_age") value(`r(F)')
    addest, name("p_of_age") value(`r(p)')
  est store onlyfather

regress height mheight Dage5 Dage10 Dage15
  test Dage5 Dage10 Dage15
    addest, name("F_of_age") value(`r(F)')
    addest, name("p_of_age") value(`r(p)')
  est store onlymother

regress height fheight mheight Dage5 Dage10 Dage15
  test Dage5 Dage10 Dage15
    addest, name("F_of_age") value(`r(F)')
    addest, name("p_of_age") value(`r(p)')
  test fheight=mheight
    addest, name("F_of_M_eq_F") value(`r(F)')
    addest, name("p_of_M_eq_F") value(`r(p)')
  est store both
.
.	<other code>
.
est table onlyfather onlymother both, stat("F_of_age" "p_of_age" "F_of_M_eq_F" "p_of_M_eq_F" F N r2) 

{p 4 4 2}
The output of the above {cmd:estimates table} command is:

-----------------------------------------------------
    Variable | onlyfather   onlymother      both     
-------------+---------------------------------------
     fheight |  .39378776                 .37366497  
       Dage5 |  2.5092039    2.8483203    2.5705705  
      Dage10 |  2.1560442    2.0992155    2.1577627  
      Dage15 |  1.5592282    1.6260293    1.5430182  
     mheight |               .31865049    .28892303  
       _cons |  35.971966    42.515225    18.790657  
-------------+---------------------------------------
    F_of_age |  55.871601    55.114653    58.924464  
    p_of_age |  4.201e-33    1.088e-32    9.309e-35  
 F_of_M_eq_F |                            1.7621445  
 p_of_M_eq_F |                            .18469688  
           F |  63.657074    52.551367    61.476023  
           N |        898          898          898  
          r2 |  .22187349    .19054063    .25628248  
-----------------------------------------------------

{p 4 4 2}
The user-written table-making commands {help esttab}, {help outreg} and {help xml_tab} 
can also now access and display these new statistics.
   

{title:Example of the use of the options to augment e(b) and e(V)}

----  To be added  ----

{marker author}{...}
{title:Author}

{p 4 8 20} 
{browse "http://www.cgdev.org/expert/mead-over/":Mead Over},
Center for Global Development, Washington, DC 20036 USA. 
Email: {browse "mailto:mover@cgdev.org":MOver@CGDev.Org} if you observe any problems. 


{* version 1.2 5June2014}
{* version 1.3 Oct 5, 2015: Change r(F) and r(p) to `r(F)' and `r(p)' }
{* version 1.4 Aug 23, 2016: Add the -matname()- and -matrix- options }
{* version 1.5 Dec. 18, 2018: Add the findomitted and  buildfvinfo options}
{* version 1.6 Jan. 10, 2019: Add the post/repost options to allow user to choose}
{* 		This help file should be updated to recognize Jann's erepost command and point out similarities and differences}
{* 		Differences include the options here in -addest- of augbvector(number) augvceatrix(number) augcoefname(string) [ augeqname(string) ]} 
{*		Also -rename- is useful.  }
