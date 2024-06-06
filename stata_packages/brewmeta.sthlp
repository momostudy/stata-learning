{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
Command to look up meta characteristics for colors/palettes available to {help brewscheme}
{hline}

{title:help for brewmeta}

{p 4 4 8}{hi:brewmeta {hline 2}} A Stata interface to color property palettes developed 
by Cynthia Brewer ({browse "http://colorbrewer.org/":Color Brewer}). {p_end}

{title:Syntax}

{p 4 4 4}{cmd:brewmeta} {it:palette name}, {cmd:colorid(}{it:integer}{opt )} 
[ {cmd:colors(}{it:integer}{opt )} {cmdab:prop:erties(}{it:"", "all", "colorblind", "lcd", "print", "photocopy", "meta"}{cmd:)} ] {p_end}

{title:Description}

{p 4 4 4}{cmd:brewmeta} is used to look-up the available meta data on the 
"friendliness" properties of the various color palettes and includes an option 
to look up those meta data on the fly.   {p_end}

{title:Options}

{p 4 4 8}{cmd:colorid} is a required argument indicating the number of the colors  
within the palette for which you would like to know about the meta data 
properties. For additional control, users may specify a specific number of colors 
within a palette to look up these values.{break}

{p 4 4 8}{cmd:colors} is an optional argument indicating the maximum number of 
colors from the specified palette from which to look up the properties of the 
color identified by {cmd:colorid}. If no value is passed to this argument, the 
maximum number of colors available in the palette are assumed. {it:Note: this is particularly important for divergent color palettes where colors may be added/subtracted from the palette in order to preserve balance across the palette.}  {break}
 
{p 4 4 8}{cmdab:prop:erties} is an optional arguement used to look up a specific property for the 
color palette.  If nothing is specified, the program will assume you would like 
to see the results for all of the properties. The table below illustrates the 
types of results that can be expected to be retrieved from this functionality: {break}{p_end}

    {hline 80}
{p2colset 8 30 30 8}{p2col:Argument}Result{p_end}
    {hline 80}
{p2colset 8 30 30 8}{p2col:all{hi:*}}Displays all information below{p_end}
{p2colset 8 30 30 8}{p2col:colorblind{hi:*}}Colorblind friendliness indicator{p_end}
{p2colset 8 30 30 8}{p2col:lcd{hi:*}}LCD friendliness indicator{p_end}
{p2colset 8 30 30 8}{p2col:print{hi:*}}Print friendliness indicator{p_end}
{p2colset 8 30 30 8}{p2col:photocopy{hi:*}}Photocopier friendliness indicator{p_end}
{p2colset 8 30 30 8}{p2col:meta{hi:*}}Additional information about colors/palette{p_end}
    {hline 80}
{p 4 4 8}{hi:* }{it:Information is displayed if available for the given color/palette}{p_end}
	
{marker examples}{title:Examples}

{p 4 4 4} Determine if a color palette with 9 colors (of a potential 12 total) 
from the paired ColorBrewer palette is colorblind, lcd, print, or photocopy 
friendly and also identify the type of scale the palette is used for: {p_end}

{p 8 8 12}brewmeta "paired", colorid(9) colors(12) {p_end}

{p 4 4 4}Using a 15" early 2013 MacBook Pro w/Retina with a 2.8 GHz Intel Core 
i7 chipset, 16 GB 1600 MHz DDR3, and Intel HD Graphics 4000 1024 MB graphics 
card running Stata MP8, the command will typically take < 5 seconds with a 
decent Wi-Fi connection.  The first time the look up table is built and when the 
refresh option are used, you should expect to see the performance dip slightly.  
Look ups take < 1 second on my system and will likely take a similar amount of 
time on others as well. {p_end}

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
