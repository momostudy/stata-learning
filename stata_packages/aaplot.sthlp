{smcl}
{* 22may2011}{...}
{cmd:help aaplot} 
{hline}

{title:Scatter plot with linear and/or quadratic fit, automatically annotated}


{title:Syntax}

{p 8 18 2}
{cmd:aaplot} {it:yvar xvar} 
{ifin} 
[{cmd:,}
{cmdab:quad:ratic} 
{cmd:both}
{cmd:lopts(}{it:lfitoptions}{cmd:)} 
{cmd:qopts(}{it:qfitoptions}{cmd:)} 
{cmd:aformat(}{it:format}{cmd:)}
{cmd:bformat(}{it:format}{cmd:)}
{cmd:cformat(}{it:format}{cmd:)}
{cmd:rsqformat(}{it:format}{cmd:)}
{cmd:rmseformat(}{it:format}{cmd:)}
{cmd:abbrev(}{it:#}{cmd:)}
{cmd:backdrop(}{it:addplot_option}{cmd:)} 
{cmd:addplot(}{it:addplot_option}{cmd:)} 
{it:scatter_options} 
]


{title:Description}

{pstd}
{cmd:aaplot} graphs a scatter plot for {it:yvar} versus {it:xvar} with
linear and/or quadratic fit superimposed.  The equation(s) and R-square
statistics of the fits shown are also shown at the top of the graph. If
just one fit is shown, the subtitle is used. The sample size and RMSE(s)
are shown in a note. 


{title:Remarks}

{pstd}
{cmd:aaplot} is indicative, not definitive. Some tastes might run to
showing (for example) standard errors, t statistics and P-values instead
of, or in addition to, the results shown.  Users so inclined should feel
free to clone {cmd:aaplot} and should feel compelled to use their own
different program name. 


{title:Options}

{phang}
{cmd:quadratic} specifies plotting of quadratic fit only. 

{phang}
{cmd:both} specifies plotting of linear and quadratic fit. The equation
and R-square for the quadratic fit are displayed in the subtitle and
those for the linear fit in the t1title. 

{phang}
{cmd:lopts()} are options of {help twoway lfit} to tune the rendering of
the linear fit. 

{phang}
{cmd:qopts()} are options of {help twoway qfit} to tune the rendering of
the quadratic fit. 

{phang}
{cmd:aformat()}, {cmd:bformat()}, {cmd:cformat()}, {cmd:rsqformat()} and
{cmd:rmseformat()} tune the display format of the constant, the
coefficient of the linear term, the coefficient of the quadratic term
(if any), the R-square statistic (given as a percent) and the RMSE.  The
defaults are, respectively, %7.0g,
%7.0g, %7.0g, %3.1f and the display format of {it:yvar}. 
See help on {help format} for guidance. 

{phang}
{cmd:abbrev()} tunes the abbreviation of longer variable names. By
default such names are abbreviated in the subtitle using 
{cmd:abbrev(, 10)}. Users may change the length shown from 10. 

{phang}
{cmd:backdrop(}{it:addplot_option}{cmd:)} provides a way to add other
plots to the generated graph, but as backdrop plotted before and below 
all other plots. For example, many users 
like to draw shaded areas showing confidence intervals, but showing all 
data points too. 
See {it:{help addplot_option}}.

{phang}
{cmd:addplot(}{it:addplot_option}{cmd:)} provides a way to add other
plots to the generated graph.  See {it:{help addplot_option}}.

{phang}
{it:scatter_options} are any options allowed for {help scatter}
excluding {opt by()}.  These include the options for titling the graph
(see {it:{help title_options}}), for tuning the display of data points
and for saving the graph to disk (see {it:{help saving_option}}).


{title:Examples} 

{phang}{cmd:. sysuse auto, clear}{p_end}
{phang}{cmd:. gen gpm = 1000 / mpg}{p_end}
{phang}{cmd:. label var gpm "Gallons per thousand miles"}{p_end}
{phang}{cmd:. aaplot gpm weight, name(g1)}{p_end}
{phang}{cmd:. aaplot gpm weight, lopts(lc(blue)) aformat(%04.3f) bformat(%06.5f) rmseformat(%4.3f) name(g2)}{p_end}
{phang}{cmd:. aaplot gpm weight, quadratic qopts(lc(pink)) name(g3)}{p_end}
{phang}{cmd:. aaplot gpm weight, both name(g4)}{p_end}
{phang}{cmd:. aaplot gpm weight, both backdrop(lfitci gpm weight, color(gs12)) name(g5)}{p_end}


{title:Author} 

{pstd}Nicholas J. Cox, Durham University{break} 
      n.j.cox@durham.ac.uk 


{title:Acknowledgments}

{pstd}This problem was suggested by Alona Armstrong. 
Kit Baum, Eric Booth and Ariel Linden made helpful suggestions.


{title:Also see}

{psee}
Manual:  {bf:[R] regress postestimation}, {bf:[G] graph twoway}

