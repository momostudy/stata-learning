{smcl}
{* *! version 1.0.3  1 Mar 2010}{...}
{cmd:help dea} {right: ({browse "http://www.stata-journal.com/article.html?article=st0193":SJ10-2: st0193})}
{hline}

{title:Title}

{p2colset 5 12 14 2}{...}
{p2col :{hi:dea} {hline 2}}Data envelopment analysis{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 11 2}
{cmd:dea} {it:ivars} {cmd:=} {it:ovars} {ifin} 
[{cmd:,} {it:options}]

{synoptset 22 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{cmd:rts(crs}|{cmd:vrs}|{cmd:drs}|{cmd:nirs)}}specify the returns to scale; default is {cmd:rts(crs)}{p_end}
{synopt:{cmd:ort(}{cmdab:i:n}|{cmdab:o:ut)}}specify the orientation; default is {cmd:ort(in)}{p_end}
{synopt:{cmd:stage(1}|{cmd:2)}}specify the way to identify all efficiency slacks; default is {cmd:stage(2)}{p_end}
{synopt:{opt trace}}save all sequences and results from Results window to {cmd:dea.log}
{p_end}
{synopt:{opt sav:ing(filename)}}save results to {it:filename}; save statistics in double precision; save results to {it:filename} every {it:#} replications{p_end}
{synoptline}
{p2colreset}{...}


{title:Description}

{pstd} The {cmd:dea} command requires an initial dataset that contains the
input and output variables for observed units.  {cmd:dea} selects the input and
output variables from the user-designated data file or the dataset currently
in memory and solves data envelopment analysis (DEA) models with the options
specified.

{pstd} Variable names must be identified in {it:ivars} for input variables and
in {it:ovars} for output variables so that {cmd:dea} can identify and handle
the multiple input-output dataset.  In the output of the {cmd:dea} command,
the prefix {cmd:dmu:} precedes decision-making unit (DMU) names.

{pstd} {cmd:dea} has the ability to accommodate an unlimited number of inputs
and outputs with an unlimited number of DMUs.  The only limitation is the
available computer memory.

{pstd} The resulting file reports information including reference points and
slacks in DEA models.  This information can be used to analyze the inefficient
units, for example, the source of the inefficiency and how an inefficient unit
could be improved to the desired level.

{pstd} The {opt saving(filename)} option creates a {it:filename}{cmd:.dta} file
that contains the results of {cmd: dea}, including information about the DMU,
input and output the data used, ranks of DMUs, efficiency
scores, reference sets, and slacks.

{pstd}
The log file, {cmd:dea.log}, will be created in the working directory.


{title:Options}

{phang}{cmd:rts(crs}|{cmd:vrs}|{cmd:drs}|{cmd:nirs)} specifies the returns to
scale.  The default, {cmd:rts(crs)}, specifies constant returns to scale.
{cmd:rts(vrs)}, {cmd:rts(drs)}, and {cmd:rts(nirs)} specify variable returns
to scale, decreasing returns to scale, and nonincreasing returns to scale,
respectively.

{phang} {cmd:ort(in}|{cmd:out)} specifies the orientation.  The default is
{cmd:ort(in)}, meaning input-oriented DEA.  {cmd:ort(out)} is output-oriented
DEA.

{phang} {cmd:stage(1}|{cmd:2)} specifies the way to identify all efficiency
slacks.  The default is {cmd:stage(2)}, meaning two-stage DEA.  {cmd:stage(1)}
is single-stage DEA.

{phang} {cmd:trace} specifies that all the sequences displayed in the Results
window also be saved in the {cmd:dea.log} file.  The default is to save the
final results in the {cmd:dea.log} file.

{phang} {opt saving(filename)} specifies that the results be saved in
{it:filename}{cmd:.dta}.  If {it:filename}{cmd:.dta} already exists, the
existing data will be moved to the file
{it:filename}{cmd:_bak_}{it:DMYhms}{cmd:.dta} before the new data are saved in
{it:filename}{cmd:.dta}.


{title:Examples}

{phang}{cmd:. use coelli_table6.4.dta}

{phang}{cmd:. dea i_x = o_q}

{phang}{cmd:. dea i_x = o_q, rts(vrs)}

{phang}{cmd:. dea i_x = o_q, rts(vrs) ort(out)}

{phang}{cmd:. dea i_x = o_q, rts(vrs) ort(out) stage(2)}

{phang}{cmd:. dea i_x = o_q, rts(vrs) ort(out) stage(2) saving(dea1_result)}


{title:Saved results}

{pstd}{cmd:dea} saves the following in {cmd:r()}:

{synoptset 13 tabbed}{...}
{p2col 5 13 17 2: Matrices}{p_end}
{synopt:{cmd: r(dearslt)}}results of {cmd:dea} that have observation rows
of DMUs and variable columns with input data, output data, efficiency scores,
references, slacks, and more depending on the model specified.{p_end}
{p2colreset}{...}


{title:Authors}

{pstd}
Yong-bae Ji{p_end}
{pstd}
Korea National Defense University{p_end}
{pstd}
Seoul, Republic of Korea{p_end}

{pstd}
Choonjoo Lee{p_end}
{pstd}
Korea National Defense University{p_end}
{pstd}
Seoul, Republic of Korea{p_end}
{pstd}
sarang90@kndu.ac.kr; sarang64@snu.ac.kr; bloom.rambike@gmail.com
{p_end}


{title:Also see}

{psee}
Article:  {it:Stata Journal}, volume 10, number 2: {browse "http://www.stata-journal.com/article.html?article=st0193":st0193}{p_end}
