{smcl}
{* *! version 1.0.4 16sep2022}{...}
{viewerjumpto "Syntax" "bacondecomp##syntax"}{...}
{viewerjumpto "Description" "bacondecomp##description"}{...}
{viewerjumpto "Options" "bacondecomp##options"}{...}
{viewerjumpto "Examples" "bacondecomp##examples"}{...}
{viewerjumpto "Saved results" "bacondecomp##saved_results"}{...}
{title:Title}

{phang}
{bf:bacondecomp} {hline 2} shows a {bf: Bacon decomposition} of difference-in-differences estimation with variation in treatment timing

{marker syntax}{title:Syntax}

{p 8 17 2}
{cmdab:b:acondecomp}
{varlist} {ifin} [{it:weight}]
[{cmd:,} {it:options}]

{pstd}
where {it:varlist} is
{p_end}
		{it:outcome treatment_indicator [controls] }

{synoptset 30 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{cmdab:gro:pt}(string)} options to pass to graph command{p_end}
{synopt:{cmd:stub}(string)} specify a prefix for variables to be created holding decomp results{p_end}
{synopt:{cmd:ddetail}} option for more detailed decomposition (allowed without weights or controls){p_end}
{synopt:{it: other options}} options to pass to {help xtreg} command{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:bacondecomp} implements a {bf: Bacon decomposition} of a difference-in-differences (DD)
estimator with variation in treatment timing, based on Goodman-Bacon (2018). The
two-way fixed effects DD model is a weighted average of all possible
two-group/two period DD estimators. The command generates a scatterplot of 2x2
difference-in-difference estimates and their associated weights. The data must 
be {help xtset} and the variable list must include an outcome as the first item,
and a treatment that can only turn from zero to one during the time period examined as its second item.
{p_end}

{pstd}
{cmd:bacondecomp} by default produces a graph for all comparisons and shows up to three types of two-group/two period comparisons, 
which differ by control group: (1) Timing groups, or groups whose treatment stated at different times can serve as each other's
controls groups in two ways: those treated later serves as the control
group for an earlier treatment group and those treated earlier serve as the 
control group for the later group; (2) Always treated, a group treated prior to the 
start of the analysis serves as the control group; and (3) Never treated, a group which never receives the 
treatment serves as the control group. Also shown are the component due to variation in controls across
always treated and never treated groups, and the "within" residual component.

{p_end}

{pstd}
Without weights or controls, and with the {cmd:ddetail} option specified,
{cmd:bacondecomp} shows up to four types of two-group/two period comparisons, 
which differ by control group: (1) A group treated later serves as the control
group for an earlier treatment group; (2) A group treated earlier serves as the 
control group for a later treatment group; (3) A group which never receives the 
treatment serves as the control group; and (4) A group treated prior to the 
start of the analysis serves as the control group.
{p_end}

{marker options}{...}
{title:Detail on Options}

{phang}
{opt msymbols(symbolstylelist)} specifies an ordered list of symbols for each
DD comparison type.

{phang}
{opt mcolors(colorstylelist)} specifies an ordered list of colors for each
DD comparison type.

{phang}
{opt msizes(markersizestylelist)} specifies an ordered list of sizes for each 
DD comparison type.

{phang}
{opt ddline(linesuboptions)} allows added line suboptions to be passed to the 
line that shows the (overall) two-way fixed effects DD estimate.

{phang}
{opt noline} removes the added line showing the (overall) two-way fixed effects
DD estimate.
{p_end}

{phang}
{opt gropt} ({help twoway_options}): can be used to control the graph {help title options:titles},
{help legend option:legends}, {help axis options:axes}, 
added {help added line options:lines} and {help added text options:text},
{help region options:regions}, {help name option:name}, 
{help aspect option:aspect ratio}, etc.
{p_end}

{phang}{help xtreg} options: Any unrecognized options added to {cmd:bacondecomp} are appended to the end 
of the {help xtreg} commands which generate estimates.
{p_end}


{marker examples}{...}
{title:Real-World Example}

{pstd}Load data that replicates Stevenson and Wolfers' (2006) analysis of 
no-fault divorce reforms and female suicide.{p_end}
{phang2}. {stata "use http://pped.org/bacon_example.dta, clear": use http://pped.org/bacon_example.dta, clear}{p_end}

{pstd}Estimate a two-way fixed effect DD model of female suicide on no-fault 
divorce reforms.{p_end}
{phang2}. {stata xtreg asmrs post pcinc asmrh cases i.year, fe robust}{p_end}

{pstd}Apply the DD decomposition theorem in Goodman-Bacon (2018) to the two-way
fixed effects DD model.{p_end}
{phang2}. {stata bacondecomp asmrs post pcinc asmrh cases, stub(Bacon_) robust}{p_end}

{pstd}Request the detailed decomposition of the DD model.{p_end}
{phang2}. {stata bacondecomp asmrs post pcinc asmrh cases, ddetail}{p_end}

{title:Simulated Example}

{pstd}Create fake data that illustrates problems with heterogeneous time-varying treatment effects.{p_end}
{phang2}. {stata "clear": clear}{p_end}
{phang2}. {stata "range i 1 4 4": range i 1 4 4}{p_end}
{phang2}. {stata "expand 10": expand 10}{p_end}
{phang2}. {stata "sort i": sort i}{p_end}
{phang2}. {stata "g id=_n": g id=_n}{p_end}
{phang2}. {stata "expand 10": expand 10}{p_end}
{phang2}. {stata "bys id: g t=_n": bys id: g t=_n}{p_end}
{phang2}. {stata "g ttime=(i==1)*(-2)+(i==2)*3+(i==3)*5+(i==4)*15": g ttime=(i==1)*(-2)+(i==2)*3+(i==3)*5+(i==4)*15}{p_end}
{phang2}. {stata "g d=(t>ttime)": g d=(t>ttime)}{p_end}
{phang2}. {stata "g te=(10-i)*(t-ttime)*d": g te=(10-i)*(t-ttime)*d}{p_end}
{phang2}. {stata "set seed 214215": set seed 214215}{p_end}
{phang2}. {stata "drawnorm x e": drawnorm x e}{p_end}
{phang2}. {stata "g y=te+t+x+e": g y=te+t+x+e}{p_end}
{phang2}. {stata "xtset id t": xtset id t}{p_end}
{phang2}. {stata "xtreg y d i.t if inlist(i,2,3) & t>3, i(id) fe": xtreg y d i.t if inlist(i,2,3) & t>3, i(id) fe}{p_end}
{phang2}. {stata "xtreg y d i.t if inlist(i,2,3) & t<6, i(id) fe": xtreg y d i.t if inlist(i,2,3) & t<6, i(id) fe}{p_end}
{phang2}. {stata "ba y d, stub(b_) ddetail nograph": ba y d, stub(b_) ddetail nograph}{p_end}
{phang2}. {stata "ba y d x, stub(bx_) ddetail nograph": ba y d x, stub(bx_) ddetail nograph}{p_end}
{phang2}. {stata "l b_T b_C b_B b_cgroup if !mi(b_T)": l b_T b_C b_B b_cgroup if !mi(b_T)}{p_end}
{phang2}. {stata "l bx_T bx_C bx_B bx_cgroup if !mi(bx_T)": l bx_T bx_C bx_B bx_cgroup if !mi(bx_T)}{p_end}


{marker saved_results}{...}
{title:Saved Results}


{pstd}
{cmdab:ba:condecomp} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrix}{p_end}
{synopt:{cmd:e(b)}}overall difference-in-difference estimate{p_end}
{synopt:{cmd:e(V)}}variance estimate of overall difference-in-difference estimate{p_end}
{synopt:{cmd:e(dd)}}estimates for timing group comparisons{p_end}
{synopt:{cmd:e(wt)}}weights for timing group comparisons{p_end}
{synopt:{cmd:e(sumdd)}}summary of timing group comparisons by group (aggregate effect and weight){p_end}

{marker references}{...}
{title:References}

{pstd}Goodman-Bacon, Andrew. 2018.
{browse "http://pped.org/Bacon2019.pdf":"Differences-in-differences with variation in treatment timing"}.
{it:Working paper}.{p_end}

{pstd}Stevenson, Betsey and Justin Wolfers. 2006. {browse "https://doi.org/10.1093/qje/121.1.267":"Bargaining in the Shadow of the Law: Divorce Laws and Family Distress"}. {it:The Quarterly Journal of Economics} 121(1):267-288.{p_end}


{marker author}{...}
{title:Authors}

{pstd}Andrew Goodman-Bacon{p_end}
{pstd}andrew.j.goodman-bacon@vanderbilt.edu{p_end}

{pstd}Thomas Goldring{p_end}
{pstd}thomasgoldring@gmail.com{p_end}

{pstd}Austin Nichols{p_end}
{pstd}austinnichols@gmail.com{p_end}

{marker citation}{...}
{title:Citation of {cmd:bacondecomp}}

{p}{cmd:bacondecomp} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Goodman-Bacon, Andrew, Thomas Goldring, and Austin Nichols. 2019. 
bacondecomp: Stata module for Decomposing difference-in-differences estimation with variation in treatment timing.
{browse "https://ideas.repec.org/c/boc/bocode/s458676.html":https://ideas.repec.org/c/boc/bocode/s458676.html}{p_end}

{title:Contact for support}

    Austin Nichols
    Washington, DC, USA
    {browse "mailto:austinnichols@gmail.com":austinnichols@gmail.com}

{marker seealso}{...}
{title:Also see}

{p 1 14}Manual:  {hi:[U] 23 {help est: Estimation} and {help postest: post-estimation} commands}{p_end}
{p 10 14}{manhelp areg R}{p_end}
{p 10 14}{manhelp xtreg R}{p_end}

{p 1 10}On-line: help for {help xtivreg2}, {help xtoverid}
{p_end}
