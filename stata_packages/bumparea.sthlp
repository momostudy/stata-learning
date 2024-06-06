{smcl}
{* 25Jul2023}{...}
{hi:help bumparea}{...}
{right:{browse "https://github.com/asjadnaqvi/stata-bumparea":bumparea v1.2 (GitHub)}}

{hline}

{title:bumparea}: A Stata package for bump area or ribbon plots. 


{marker syntax}{title:Syntax}
{p 8 15 2}

{cmd:bumparea} {it:y x} {ifin}, {cmd:by}(varname) 
		{cmd:[} {cmd:top}({it:num}) {cmdab:dropo:ther} {cmd:smooth}({it:num}) {cmd:palette}({it:str}) {cmd:labcond}({it:str}) {cmd:offset}({it:num}) {cmd:alpha}({it:num}) 
		  {cmdab:lc:olor}({it:str}) {cmdab:lw:idth}({it:str}) {cmd:percent} {cmd:format}({it:fmt}) {cmdab:rec:enter}(mid|top|bot) {cmd:colorby}({it:name}) {cmd:colorvar}({it:var}) {cmdab:colo:ther}({it:str})
		  {cmd:xlabel}({it:str}) {cmd:xtitle}({it:str}) {cmd:ytitle}({it:str}) {cmd:title}({it:str}) {cmd:subtitle}({it:str}) {cmd:note}({it:str}) 
		  {cmd:ysize}({it:num}) {cmd:xsize}({it:num}) {cmd:scheme}({it:str}) {cmd:name}({it:str}) {cmd:saving}({it:str}) {cmd:]}


{p 4 4 2}
The options are described as follows:

{synoptset 36 tabbed}{...}
{synopthdr}
{synoptline}

{p2coldent : {opt bumparea y x, by(group)}}The command requires a numeric {it:y} variable and a numeric {it:x} variable. The x variable is usually a time variable.
The {opt by()} variable defines the groupings.{p_end}

{p2coldent : {opt top(num)}}The number of rows to show in the graph. The default option is {opt top(50)}. Non {opt top()} values are grouped in an "Others" category.{p_end}

{p2coldent : {opt dropo:ther}}Drop the "Others" category from the graph and just show the {opt top()} categories.{p_end}

{p2coldent : {opt smooth(num)}}The smoothing parameter that ranges from 1-8. The default value is {opt smooth(4)}. A value of 1 shows straight lines,
while a value of 8 shows almost vertical jumps.{p_end}

{p2coldent : {opt palette(str)}}Color name is any named scheme defined in the {stata help colorpalette:colorpalette} package. Default is {stata colorpalette tableau:{it:tableau}}.{p_end}

{p2coldent : {opt colorby(name)}}Color by alphabetical values. This option is still beta and only takes only one argument. This option is highly useful when
making several bumparea plots for comparison to assign the same color to the same {opt by()} category. Otherwise, the color order is determined by the rank
order.{p_end}

{p2coldent : {opt colorvar(var)}}Color by a predefined variable. Define a color variable that takes on values in increments of one. This is to fully control and customize the 
colors assigned.{p_end}

{p2coldent : {opt colo:ther(var)}}Color of the other category. Default is {opt colo(gs12)}}.{p_end}

{p2coldent : {opt alpha(num)}}The transparency of area fills. The default is {opt alpha(80)} for 80% transparency.{p_end}

{p2coldent : {opt offset(num)}}Extends the x-axis range to accommodate labels. The default value is {it:15} for 15% of {it:xmax-xmin}.{p_end}

{p2coldent : {opt rec:enter(options)}}This option changes where the graph is recentered. The default option is {opt rec:enter(middle)}. Additional options are {opt rec:enter(top)} 
or {opt rec:enter(bottom)}. For brevity, the following can be specified: {it:middle} = {it:mid} = {it:m}, {it:top} = {it:t}, {it:bottom} = {it:bot} = {it:b}.{p_end}

{p2coldent : {opt percent}}Shows the percentage share for the {opt by()} categories. Default is actual values.{p_end}

{p2coldent : {opt format(fmt)}}Format the values of the {opt by()} categories. Default value is {opt format(%12.0fc)} for actual values and {opt format(%5.2f)} for the {opt percent} option.{p_end}

{p2coldent : {opt lw:idth(str)}}The line width of the area stroke. The default is {opt lw(0.2)}.{p_end}

{p2coldent : {opt lc:olor(str)}}The line color of the area stroke. The default is {opt lc(white)}.{p_end}

{p2coldent : {opt labs:ize(str)}}Size of the {opt by()} category labels. Default value is {opt labs(2.8)}.{p_end}

{p2coldent : {opt xlabs:ize(str)}}Size of the x-axis labels. Default value is {opt xlabs(2.5)}.{p_end}

{p2coldent : {opt xlaba:ngle(str)}}Angle of the x-axis labels. Default is {opt xlaba(0)} for zero degrees or horizontal orientation.{p_end}

{p2coldent : {opt xtitle, ytitle, xsize, ysize}}These are standard twoway graph options.{p_end}

{p2coldent : {opt title, subtitle, note, name, saving}}These are standard twoway graph options.{p_end}

{p2coldent : {opt scheme(string)}}Load the custom scheme. Above options can be used to fine tune individual elements.{p_end}

{synoptline}
{p2colreset}{...}


{title:Dependencies}

The {browse "http://repec.sowi.unibe.ch/stata/palettes/index.html":palette} package (Jann 2018, 2022) is required:

{stata ssc install palettes, replace}
{stata ssc install colrspace, replace}

Even if you have these installed, it is highly recommended to check for updates: {stata ado update, update}

{title:Examples}

See {browse "https://github.com/asjadnaqvi/stata-bumparea":GitHub}.

{hline}


{title:Package details}

Version      : {bf:bumparea} v1.2
This release : 25 Jul 2023
First release: 10 Apr 2023
Repository   : {browse "https://github.com/asjadnaqvi/stata-bumparea":GitHub}
Keywords     : Stata, graph, bump chart, ribbon plot
License      : {browse "https://opensource.org/licenses/MIT":MIT}

Author       : {browse "https://github.com/asjadnaqvi":Asjad Naqvi}
E-mail       : asjadnaqvi@gmail.com
Twitter      : {browse "https://twitter.com/AsjadNaqvi":@AsjadNaqvi}


{title:Feedback}

Please submit bugs, errors, feature requests on {browse "https://github.com/asjadnaqvi/stata-alluvial/issues":GitHub} by opening a new issue.

{title:References}

{p 4 8 2}Jann, B. (2018). {browse "https://www.stata-journal.com/article.html?article=gr0075":Color palettes for Stata graphics}. The Stata Journal 18(4): 765-785.

{p 4 8 2}Jann, B. (2022). {browse "https://ideas.repec.org/p/bss/wpaper/43.html":Color palettes for Stata graphics: An update}. University of Bern Social Sciences Working Papers No. 43. 


{title:Other visualization packages}

{psee}
    {helpb arcplot}, {helpb alluvial}, {helpb bimap}, {helpb bumparea}, {helpb bumpline}, {helpb circlebar}, {helpb circlepack}, {helpb clipgeo}, {helpb delaunay}, {helpb joyplot}, 
	{helpb marimekko}, {helpb sankey}, {helpb schemepack}, {helpb spider}, {helpb streamplot}, {helpb sunburst}, {helpb treecluster}, {helpb treemap}
