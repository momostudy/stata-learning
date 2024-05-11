{smcl}
{* 27may2014}{...}
{hline}
{cmd:help for renvarlab}{right:Version 1.0}
{hline}

{title:Title}

{pstd}{cmd: renvarlab} {hline 2}  Renames variables, with option of using variable labels to create new variable names{p_end}

{title:Syntax}

{p 8 17 2}{cmd:renvarlab} [{it:varlist}] {cmd:\} {it:newvarlist} [ {cmd:,}
{cmdab:d:isplay} {cmd:test} {cmdab:lab:el} ]

{p 8 17 2}{cmd:renvarlab} [{it:varlist}] {cmd:,} {it:transformation_option}
[ {cmdab:d:isplay} {cmd:test} {cmdab:sy:mbol(}{it:str}{cmd:)} {cmdab:lab:el}]

{p 8 17 2}{cmd:renvarlab} [{it:varlist}] {cmd:,} {cmdab:lab:el}
[ {cmdab:d:isplay} {cmd:test}  ]


{p 12 12 2}where {it:transformation_option} is one of

{col 16}{cmdab:u:pper}{col 40}{cmdab:l:ower}

{col 16}{cmdab:pref:ix(}{it:str}{cmd:)}{col 40}{cmdab:postf:ix(}{it:str}{cmd:)} (synonym {cmdab:suff:ix(}{it:str}{cmd:)})

{col 16}{cmdab:pres:ub(}{it:str1 str2}{cmd:)}{col 40}{cmdab:posts:ub(}{it:str1 str2}{cmd:)}

{p 15}{cmdab:sub:st(}{it:str1 str2}{cmd:)}{p_end}

{col 16}{cmdab:pred:rop(}{it:#}{cmd:)}{col 40}{cmdab:postd:rop(}{it:#}{cmd:)}

{p 15}{cmdab:t:rim(}{it:#}{cmd:)}

{p 15}{cmdab:trime:nd(}{it:#}{cmd:)}

{p 15}{cmdab:m:ap(}{it:string exp}{cmd:)}


{title:Description}

{p 4 4 2}{cmd:renvarlab} renames the variables listed in {it:varlist}.  
If not specified, {it:varlist} defaults to {cmd:_all}.  It has all of the
options as its predecessor, {cmd:renvars} (available from {ado ssc install renvars:SSC}), but with the additional ability
to use variable labels to construct new names for variables.

{p 4 4 2}{cmd:renvarlab} [{it:varlist}] {cmd:\} {it:newvarlist}  renames each 
variable to the corresponding new name in {it:newvarlist}.

{p 4 4 2}{cmd:renvarlab} [{it:varlist}] {cmd:,} {it:transformation_option}  
applies the
transformation specified to each variable name in {it:varlist}.

{p 4 4 2}{cmd:renvarlab} will not rename any variable unless all of the resulting new names
specified are acceptable as new variable names. Transformations that result
in a name that is the same as the old name are ignored. 
Variable labels, value labels, formats, and characteristics are maintained.


{title:Options}

{p 4 4 2}One of the following {it:transformation_options} may be specified:

{p 4 25}{cmd:upper}{space 15}
 converts the variable names to uppercase{p_end}
{*}{...}
{p 4 25}{cmd:lower}{space 15}
 converts the variable names to lowercase{p_end}
{*}{...}
{p 4 25}{cmd:prefix(}{it:str}{cmd:)}{space 9}
 prefixes variable names with {it:str}{p_end}
{*}{...}
{p 4 25}{cmd:postfix(}{it:str}{cmd:)}{space 8}
 postfixes variable names with {it:str}.  {cmd:suffix(}{it:str}{cmd:)}
 is an exact synonym{p_end}
{*}{...}
{p 4 25}{cmd:presub(}{it:str1 str2}{cmd:)}{space 3}
 replaces the leading string {it:str1} by {it:str2} in variable
 names.  {bind:{it:str2} may be empty}{p_end}
{*}{...}
{p 4 25}{cmd:postsub(}{it:str1 str2}{cmd:)}{space 2}
 replaces the trailing string {it:str1} by {it:str2} in variable
 names.  {bind:{it:str2} may be empty}{p_end}
{*}{...}
{p 4 25}{cmd:subst(}{it:str1 str2}{cmd:)}{space 4}
 substitutes (all occurrences of) {it:str1} by {it:str2} in variable
 names.  {bind:{it:str2} may be empty}{p_end}
{*}{...}
{p 4 25}{cmd:predrop(}{it:#}{cmd:)}{space 10}
 removes the first {it:#} characters from variable names{p_end}
{*}{...}
{p 4 25}{cmd:postdrop(}{it:#}{cmd:)}{space 9}
 removes the last {it:#} characters from variable names{p_end}
{*}{...}
{p 4 25}{cmd:trim(}{it:#}{cmd:)}{space 13}
 keeps (at most) the first {it:#} characters from variable names,
 dropping the remaining characters{p_end}
{*}{...}
{p 4 25}{cmd:trimend(}{it:#}{cmd:)}{space 10}
 keeps (at most) the last {it:#} characters from variable names,
 dropping the remaining characters{p_end}
{*}{...}
{p 4 25}{cmd:map(}{it:string_exp}{cmd:)}{space 5}
 specifies a rule for building new variable names from existing
 names.  By default, {cmd:@} is the placeholder for existing names.
 This placeholder can be changed by specifying {cmd:symbol()}.

{p 4 8 2}{cmd:display} specifies that each change is displayed.

{p 4 8 2}{cmd:test} specifies that each change is displayed but not
performed.

{p 4 8 2}{cmd:symbol(}{it:str}{cmd:)} specifies a symbol to be used as a
placeholder for the existing name in the map expression.  The
default is {cmd:@}.  The symbol used should not include characters
used in existing variable names.  It is difficult to imagine why
you might want to use this option.

{p 4 8 2}{cmd:label} specifies that the variable label should be used 
to construct the new variable name.  If {cmd:label} is specified 
without any other transformations, the label is converted to a 
valid Stata variable name using the {help strtoname} function (i.e., all 
characters that are not allowed in a Stata name are converted to an underscore
and the result is truncated to 32 characters).

{title:Examples}

{p 4 8 2}{cmd:. renvarlab v1-v4 \ id  time income status}

{p 4 8 2}{cmd:. renvarlab MYVAR1 MYVAR2 MYVAR3, lower}

{p 4 8 2}{cmd:. renvarlab v1-v10, upper}

{p 4 8 2}{cmd:. renvarlab, pref(X) test}

{p 4 8 2}{cmd:. renvarlab, subs(X Y)}

{p 4 8 2}{cmd:. renvarlab, predrop(1)}

{p 4 8 2}{cmd:. renvarlab, map("D_" + substr("@", 1, 6))}

{p 4 8 2}{cmd:. renvarlab v1-v10, upper label}

{p 4 8 2}{cmd:. renvarlab v1-v10, label}


{title:Known Bugs}

{p 4 4 2}This program cannot (as yet) account for situations where two variables have
labels which are the same as the name of the other variable.  For example, suppose
variable v1 has label "v2" and variable v2 has label "v1" and we run {cmd: renvarlab, label}. 
The final result (v1 and v2 retaining their old names) should be acceptable, but because 
{cmd:renvarlab} checks to see if v1 and v2 are valid as {it:new} variable names, an error is
returned.  This presumably rare situation will be addressed in a future version. 

{title:Historical Note}

{p 4 4 2}Much of {cmd:renvars} was made obsolete by the introduction of the {help rename group} features 
in Stata 12.  However, Stata's new rename.ado contains 4000 lines of Mata code and modifying it
to use variable labels is a much more daunting task than modifying {cmd:renvars}.  Perhaps
a future version of {cmd:renvarlab} will use Stata's rename.ado code.

{title:Acknowledgment} 

{p 4 4 2}The code and help for this program are borrowed almost entirely from
 {cmd:renvars} by Nicholas J. Cox and Jeroen Weesie.  Their work
 on {cmd:renvars} is most appreciated.  Any errors in this program
 are entirely my own.


{title:Author}

{pstd}
Joseph Canner{break}
Johns Hopkins University School of Medicine{break}
Department of Surgery{break}
Center for Surgical Trials and Outcomes Research{break}

{pstd}
Email {browse mailto:jcanner1@jhmi.edu}

{title:Also see}

{p 4 13 2}Manual:  {hi:[U] 14.3 Naming conventions}

{p 4 13 2}Online:  {helpb rename}{space 3}specify the new name of a variable{p_end}
{p 4 13 2}{space 9}{helpb foreach}{space 2}for loops over a varlist
{p_end}