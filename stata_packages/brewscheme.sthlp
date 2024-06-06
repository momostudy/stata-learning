{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
Command to generate customized scheme files.
{hline}

{marker brewtitle}{title:help for brewscheme}

{p 4 4 4}{hi:brewscheme {hline 2}} A program for easy generation of customized graph 
scheme files. {p_end}

{marker brewsyn}{title:Syntax}

{p 4 4 4}{cmd:brewscheme} , {cmdab:scheme:name(}{it:scheme name}{opt )} 
[ {cmdab:refr:esh} {break} {cmdab:allst:yle(}{it:string}{cmd:)} {cmdab:allc:olors(}{it:real 3}{cmd:)} 
{cmdab:allsat:uration(}{it:real 100}{cmd:)} {break} {cmdab:somest:yle(}{it:string}{cmd:)} 
{cmdab:somec:olors(}{it:real 3}{cmd:)} {cmdab:somesat:uration(}{it:real 100}{cmd:)} {break} 
{cmdab:barst:yle(}{it:string}{cmd:)} {cmdab:barc:olors(}{it:real 3}{cmd:)} 
{cmdab:barsat:uration(}{it:real 100}{cmd:)} {break} {cmdab:scatst:yle(}{it:string}{cmd:)} 
{cmdab:scatc:olors(}{it:real 3}{cmd:)} {cmdab:scatsat:uration(}{it:real 100}{cmd:)} {break} 
{cmdab:areast:yle(}{it:string}{cmd:)} {cmdab:areac:olors(}{it:real 3}{cmd:)} 
{cmdab:areasat:uration(}{it:real 100}{cmd:)} {break} {cmdab:linest:yle(}{it:string}{cmd:)} 
{cmdab:linec:olors(}{it:real 3}{cmd:)} {cmdab:linesat:uration(}{it:real 100}{cmd:)} {break} 
{cmdab:boxst:yle(}{it:string}{cmd:)} {cmdab:boxc:olors(}{it:real 3}{cmd:)} 
{cmdab:boxsat:uration(}{it:real 100}{cmd:)} {break} {cmdab:dotst:yle(}{it:string}{cmd:)} 
{cmdab:dotc:olors(}{it:real 3}{cmd:)} {cmdab:dotsat:uration(}{it:real 100}{cmd:)}  {break} 
{cmdab:piest:yle(}{it:string}{cmd:)} {cmdab:piec:olors(}{it:real 3}{cmd:)} 
{cmdab:piesat:uration(}{it:real 100}{cmd:)} {break} {cmdab:sunst:yle(}{it:string}{cmd:)} 
{cmdab:sunc:olors(}{it:real 4}{cmd:)} {cmdab:sunsat:uration(}{it:real 100}{cmd:)}  {break} 
{cmdab:histst:yle(}{it:string}{cmd:)} {cmdab:histc:olors(}{it:real 3}{cmd:)} 
{cmdab:histsat:uration(}{it:real 100}{cmd:)} {break} {cmdab:cist:yle(}{it:string}{cmd:)} 
{cmdab:cic:olors(}{it:real 3}{cmd:)} {cmdab:cisat:uration(}{it:real 100}{cmd:)}  {break} 
{cmdab:matst:yle(}{it:string}{cmd:)} {cmdab:matc:olors(}{it:real 3}{cmd:)} 
{cmdab:matsat:uration(}{it:real 100}{cmd:)} {break} {cmdab:reflst:yle(}{it:string}{cmd:)} 
{cmdab:reflc:olors(}{it:real 3}{cmd:)} {cmdab:reflsat:uration(}{it:real 100}{cmd:)}  {break} 
{cmdab:refmst:yle(}{it:string}{cmd:)} {cmdab:refmc:olors(}{it:real 3}{cmd:)} 
{cmdab:refmsat:uration(}{it:real 100}{cmd:)} {break} {cmdab:const:art(}{it:string}{cmd:)} 
{cmdab:cone:nd(}{it:string}{cmd:)} {cmdab:consat:uration(}{it:real 100}{cmd:)} 
{cmdab:themef:ile(}{it:string}{cmd:)}] {p_end}

{marker brewdesc}{title:Description}

{p 4 4 4}{cmd:brewscheme} is a tool to facilitate Stata users developing 
graph schemes using research-based color palettes.  Unlike other uses of the 
color palettes developed by Brewer (see {help brewscheme##refs:References} 
below), this program allows users to specify the number of colors from any of 
the 35 color palettes they would like to use and allows users to mix/combine 
different palettes for the various graph types available in Stata.  Additionally, 
as a way of creating a centralized source for the Stata community to work from, 
palettes from outside of ColorBrewer are being added to boost the capabilities 
of the program.  {p_end}

{marker palettes}{title:Available Palettes}

{col 5}{hline 75}
{col 5}{hi:Qualitative} {col 55}{hi: Divergent}
{col 5}{hline 75}
{col 5}{hi:accent}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:brbg}{col 55}{help brewscheme##brewer: Brewer (2002)}
{col 5}{hi:dark2}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:piyg}{col 55}{help brewscheme##brewer: Brewer (2002)}
{col 5}{hi:paired}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:prgn}{col 55}{help brewscheme##brewer: Brewer (2002)}
{col 5}{hi:pastel1}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:puor}{col 55}{help brewscheme##brewer: Brewer (2002)}
{col 5}{hi:pastel2}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:rdbu}{col 55}{help brewscheme##brewer: Brewer (2002)}
{col 5}{hi:set1}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:rdgy}{col 55}{help brewscheme##brewer: Brewer (2002)}
{col 5}{hi:set2}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:rdylbu}{col 55}{help brewscheme##brewer: Brewer (2002)}
{col 5}{hi:set3}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:rdylgn}{col 55}{help brewscheme##brewer: Brewer (2002)}
{col 40}{hi:spectral}{col 55}{help brewscheme##brewer: Brewer (2002)} 
{col 5}{hline 75}
{col 5}{hi:Sequential}{col 55}{hi:Non-ColorBrewer Palettes}
{col 5}{hline 75}
{col 5}{hi:blues}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:tableau}{col 55}{help brewscheme##linetal: Lin et al (2013)} 
{col 5}{hi:bugn}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:fruita}{col 55}{help brewscheme##linetal: Lin et al (2013)} 
{col 5}{hi:bupu}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:fruite}{col 55}{help brewscheme##linetal: Lin et al (2013)} 
{col 5}{hi:gnbu}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:veggiesa}{col 55}{help brewscheme##linetal: Lin et al (2013)} 
{col 5}{hi:greens}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:veggiese}{col 55}{help brewscheme##linetal: Lin et al (2013)} 
{col 5}{hi:greys}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:drinksa}{col 55}{help brewscheme##linetal: Lin et al (2013)}
{col 5}{hi:orrd}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:drinkse}{col 55}{help brewscheme##linetal: Lin et al (2013)}
{col 5}{hi:oranges}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:brandsa}{col 55}{help brewscheme##linetal: Lin et al (2013)} 
{col 5}{hi:pubu}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:brandse}{col 55}{help brewscheme##linetal: Lin et al (2013)} 
{col 5}{hi:pubugn}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:fooda}{col 55}{help brewscheme##linetal: Lin et al (2013)}
{col 5}{hi:purd}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:foodt}{col 55}{help brewscheme##linetal: Lin et al (2013)}
{col 5}{hi:purples}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:carsa}{col 55}{help brewscheme##linetal: Lin et al (2013)}
{col 5}{hi:rdpu}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:carst}{col 55}{help brewscheme##linetal: Lin et al (2013)}
{col 5}{hi:reds}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:featuresa}{col 55}{help brewscheme##linetal: Lin et al (2013)}
{col 5}{hi:ylgn}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:featurest}{col 55}{help brewscheme##linetal: Lin et al (2013)}
{col 5}{hi:ylgnbu}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:activitiesa}{col 55}{help brewscheme##linetal: Lin et al (2013)}
{col 5}{hi:ylorbr}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:activitiest}{col 55}{help brewscheme##linetal: Lin et al (2013)}
{col 5}{hi:ylorrd}{col 18}{help brewscheme##brewer: Brewer (2002)}{col 40}{hi:mdebar}{col 55}{browse "http://www.mde.k12.ms.us"} 
{col 40}{hi:mdepoint}{col 55}{browse "http://www.mde.k12.ms.us"} 
{col 5}{hline 75}
{col 5}{hi:Ordinal}{col 55}{hi:{help brewscheme##bostock: D3js}}
{col 5}{hline 75}
{col 5}{hi:category10}{col 18}{help brewscheme##bostock: D3}{col 40}{hi:category20}{col 55}{help brewscheme##bostock: D3} 
{col 5}{hi:category20b}{col 18}{help brewscheme##bostock: D3}{col 40}{hi:category20c}{col 55}{help brewscheme##bostock: D3} 
{col 5}{hline 75}

{marker brewopts}{title:Options}

{p 4 4 8}{cmdab:scheme:name} is used to name the scheme that will be created by 
the program.  {it:Unless absolutely necessary, I highly recommend avoiding embedded spaces in these file names.}{p_end}
 
{p 4 4 8}{cmdab:refr:esh} if the source dataset containing the color palettes 
is not found or the user specifies the {cmdab:refr:esh} option, {cmd: colorbrewscheme} 
will rebuild the source data set to generate the scheme files.{p_end}
{marker brewdefaults}
{dlgtab 4 8:Single Color Palettes and Default Color Palettes}{break}

{p 4 4 8}{cmdab:allst:yle} The lower-cased name of a color palette to be used for 
all graph types.{p_end}

{p 4 4 8}{cmdab:allc:olors} The maximum number of colors to use from the palette 
specifed by the {cmdab:allst:yle} option.{p_end}

{p 4 4 8}{cmdab:allsat:uration} Used to set the color intensity for all graph types.{p_end}

{p 4 4 8}{cmdab:somest:yle} The lower-cased name of a color palette to be used for 
graph types without specified color palettes.{p_end}

{p 4 4 8}{cmdab:somec:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:somest:yle} option.{p_end} 

{p 4 4 8}{cmdab:somesat:uration} Used to set the color intensity for graph 
types without specified color palettes.{p_end}

{p 4 4 8}{cmdab:themef:ile} Is an optional argument used to supply {help brewscheme} with a theme file created by {help brewtheme}.  Theme files are used to control global aesthetic properties (e.g., background/foreground colors, text sizes, symbol sizes, etc...) that are typically independent of the data being visualized. {p_end}

{dlgtab 4 8:Individual Graph Types}{break}
{marker brewbar}{dlgtab 8 8:Bar Graphs}{break}
{p 14 14 14}{cmdab:barst:yle} The lower-cased name of a color palette that will be 
used to define colors for bar graphs.{p_end}

{p 14 14 14}{cmdab:barc:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:barst:yle} option.{p_end}

{p 14 14 14}{cmdab:barsat:uration} Used to set the color intensity for bar graphs.{p_end}

{marker brewscat}{dlgtab 8 8:Scatterplots}{break}
{p 14 14 14}{cmdab:scatst:yle} The lower-cased name of a color palette that will be 
used for scatter plots.{p_end}

{p 14 14 14}{cmdab:scatc:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:scatst:yle} option.{p_end}

{p 14 14 14}{cmdab:scatsat:uration} Used to set the color intensity for scatterplots.{p_end}

{marker brewarea}{dlgtab 8 8:Area Graphs}{break}
{p 14 14 14}{cmdab:areast:yle} The lower-cased name of a color palette to be used for 
area graphs{p_end}

{p 14 14 14}{cmdab:areac:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:areast:yle} option.{p_end}

{p 14 14 14}{cmdab:areasat:uration} Used to set the color intensity for area graphs.{p_end}

{marker brewline}{dlgtab 8 8:Line Graphs}{break}
{p 14 14 14}{cmdab:linest:yle} The lower-cased name of a color palette to be used for 
line graphs.{p_end}

{p 14 14 14}{cmdab:linec:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:linest:yle} option.{p_end}

{p 14 14 14}{cmdab:linesat:uration} Used to set the color intensity for line graphs.{p_end}

{marker brewbox}{dlgtab 8 8:Box Plots}{break}
{p 14 14 14}{cmdab:boxst:yle} The lower-cased name of a color palette to be used for 
box plots.{p_end}

{p 14 14 14}{cmdab:boxc:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:allst:yle} option.{p_end}

{p 14 14 14}{cmdab:boxsat:uration} Used to set the color intensity for box plots.{p_end}

{marker brewdot}{dlgtab 8 8:Dot Plots}{break}
{p 14 14 14}{cmdab:dotst:yle} The lower-cased name of a color palette to be used for 
dot plots.{p_end}

{p 14 14 14}{cmdab:dotc:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:dotst:yle} option.{p_end}

{p 14 14 14}{cmdab:dotsat:uration} Used to set the color intensity for dot plots.{p_end}

{marker brewpie}{dlgtab 8 8:Pie Graphs}{break}
{p 14 14 14}{cmdab:piest:yle} The lower-cased name of a color palette to be used for 
pie graphs.{p_end}

{p 14 14 14}{cmdab:piec:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:piest:yle} option.{p_end}

{p 14 14 14}{cmdab:piesat:uration} Used to set the color intensity for pie graphs.{p_end}

{marker brewsun}{dlgtab 8 8:Sunflower Plots}{break}
{p 14 14 14}{cmdab:sunst:yle} The lower-cased name of a color palette to be used for 
sunflower plots.  {it:Note, only the first four colors will be used.}{p_end}

{p 14 14 14}{cmdab:sunc:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:sunst:yle} option.{p_end}

{p 14 14 14}{cmdab:sunsat:uration} Used to set the color intensity for sunflower plots.{p_end}

{marker brewhist}{dlgtab 8 8:Histograms}{break}
{p 14 14 14}{cmdab:histst:yle} The lower-cased name of a color palette to be used for
histograms.{p_end}

{p 14 14 14}{cmdab:histc:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:histst:yle} option.{p_end}

{p 14 14 14}{cmdab:histsat:uration} Used to set the color intensity for histograms.{p_end}

{marker brewci}{dlgtab 8 8:Confidence Intervals}{break}
{p 14 14 14}{cmdab:cist:yle} The lower-cased name of a color palette to be used for 
graphs containing confidence intervals.{p_end}

{p 14 14 14}{cmdab:cic:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:cist:yle} option.{p_end}

{p 14 14 14}{cmdab:cisat:uration} Used to set the color intensity for confidence intervals.{p_end}

{marker brewmat}{dlgtab 8 8:Scatterplot Matrices}{break}
{p 14 14 14}{cmdab:matst:yle} The lower-cased name of a color palette to be used for 
scatter plot matrices.{p_end}

{p 14 14 14}{cmdab:matc:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:matst:yle} option.{p_end}

{p 14 14 14}{cmdab:matsat:uration} Used to set the color intensity for scatterplot matrices.{p_end}

{marker brewrline}{dlgtab 8 8:Reference Lines}{break}
{p 14 14 14}{cmdab:reflst:yle} The lower-cased name of a color palette to be used for 
reference lines.{p_end}

{p 14 14 14}{cmdab:reflc:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:reflst:yle} option.{p_end}

{p 14 14 14}{cmdab:reflsat:uration} Used to set the color intensity for reference lines.{p_end}

{marker brewrmark}{dlgtab 8 8:Reference Markers}{break}
{p 14 14 14}{cmdab:refmst:yle} The lower-cased name of a color palette to use for 
reference markers.{p_end}

{p 14 14 14}{cmdab:refmc:olors} The maximum number of colors to use from the 
palette specifed by the {cmdab:refmst:yle} option.{p_end}

{p 14 14 14}{cmdab:refmsat:uration} Used to set the color intensity for reference markers.{p_end}

{marker brewcontour}{dlgtab 8 8:Contour Plots}{break}
{p 14 14 14}{cmdab:const:art} Defines the starting color to be used for contour 
plots using standard {help colorstyle:colorstyles} from Stata.{p_end} 

{p 14 14 14}{cmdab:cone:nd} Defines the ending color to be used for contour 
plots using standard {help colorstyle:colorstyles} from Stata.{p_end}

{marker ex}{title:Examples}

{p 8 8 8} Generate a graph scheme using the set1 color brewer palette for all 
graphs.  Use the first five colors of the palette and set the color intensity to 
80 for each of the graphs.{p_end}

{p 10 10 10}{stata brewscheme, scheme(set1) allst(set1) allc(5) allsat(80):brewscheme, scheme(set1) allst(set1) allc(5) allsat(80)}{p_end}

{p 8 8 8} Generate a graph scheme using the set1 color brewer palette for 
scatterplots, pastel1 for bar graphs, and brown to blue-green for all other 
graph types.  Use the default values of colors and intensity for each.{p_end}

{p 10 10 10}{stata brewscheme, scheme(mixed1) scatst(set1) barst(pastel1) somest(brbg):brewscheme, scheme(mixed1)  scatst(set1) barst(pastel1) somest(brbg)}{p_end}

{p 8 8 8}{hi: Note, this program only creates the scheme file.  To achieve the intended effect, you must use the scheme file in your subsequent graph commands:}{p_end}

{p 10 10 10}{stata sysuse auto.dta, clear}{p_end}
{p 10 10 10}{stata gr box mpg, over(rep78) scheme(mixed1)}{p_end}

{marker refs}{title:References}

{marker bostock}{p 4 8 8}Bostock, M., Ogievetsky, V., & Heer, J. (2011).  D3: data driven documents. {it: IEEE Transactions on Visualization & Computer Graphics. 17(12)} pp 2301 - 2309. Retrieved from 
{browse "http://vis.stanford.edu/papers/d3":Stanford Vis Group}.{p_end}  

{marker brewer}{p 4 8 8}Brewer, C. A. (2002) {browse "http://colorbrewer.org/":Color Brewer 2} [Computer Software]. State College, PA: Cynthia Brewer, Mark Harrower, and The Pennsylvania State University.{p_end}

{marker linetal}{p 4 8 8}Lin, S., Fortuna, J., Kulkarni, C., Stone, M., {c 38} Heer, J. (2013).{browse "http://vis.stanford.edu/files/2013-SemanticColor-EuroVis.pdf":  Selecting Semantically-Resonant Colors for Data Visualization}. In 
{it:Computer Graphics Forum} (Vol. 32, No. 3pt4, pp. 401-410).  Blackwell Publishing Ltd.{p_end}

{marker license}{title:License}

{p 4 4 4}Please view {browse "http://www.personal.psu.edu/cab38/ColorBrewer/ColorBrewer_updates.html": section 4} 
of the ColorBrewer copyright notice for additional information pertaining to the licensing and redistribution of ColorBrew intellectual property.{p_end}

{title:Author}{break}
{p 4 4 8}William R. Buchanan, Ph.D.{p_end}
{p 4 4 8}Data Scientist{p_end}
{p 4 4 8}{browse "http://mpls.k12.mn.us":Minneapolis Public Schools}{p_end}
{p 4 4 8}William.Buchanan at mpls [dot] k12 [dot] mn [dot] us{p_end}

{marker notes}{title:Notes}

{p 4 4 4}Development of this program began while I was a Strategic Data Fellow at the {browse "http://mde.k12.ms.us":Mississippi Department of Education}.{p_end}

