{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
Query color sight impairment values that were previously computed and return in macros.
{hline}

{title:help for brewsearch}

{p 4 4 4}{hi:brewsearch {hline 2}} is a program used to query {help brewscheme} 
data sources to retrieve RGB values and/or simulated RGB values for different forms 
of color sight impairment.  {p_end}

{title:Syntax}

{p 4 4 4}{cmd:brewsearch} {it:RGB_varname} {break}

{title:Description}

{p 4 4 4}{cmd:brewsearch} is a simple program used to search for a color by RGB 
value or the name of the color and will return the local macros: rgb, achromatopsia, 
protanopia, deuteranopia, and tritanopia. {p_end}

{marker examples}{title:Examples}{break}
{p 4 4 4} Install the XKCD named colors and search for an XKCD named color{p_end}

{p 8 8 12}brewcolors xkcd, make install {p_end}{break}
{p 8 8 12}brewsearch "baby shit brown" {p_end}{break}

{p 4 4 4} You can also search using an RGB tuple{p_end}

{p 8 8 12}brewsearch "255 127 14"{p_end}{break}

{marker retval}{title:Returned Values}

    {hline 80}
{p2colset 8 30 30 8}{p2col:Macro Name}Contents{p_end}
    {hline 80}
{p2colset 8 30 30 8}{p2col:r(rgb)}RGB value looked up by command{p_end}	
{p2colset 8 30 30 8}{p2col:r(achromatopsia)}Achromatopsia simulated RGB value{p_end}	
{p2colset 8 30 30 8}{p2col:r(protanopia)}Protanopia simulated RGB value{p_end}	
{p2colset 8 30 30 8}{p2col:r(deuteranopia)}Deuteranopia simulated RGB value{p_end}	
{p2colset 8 30 30 8}{p2col:r(tritanopia)}Tritanopia simulated RGB value{p_end}	
    {hline 80}
	
{title:Author}{break}
{p 4 4 8}William R. Buchanan, Ph.D.{p_end}
{p 4 4 8}Data Scientist{p_end}
{p 4 4 8}{browse "http://mpls.k12.mn.us":Minneapolis Public Schools}{p_end}
{p 4 4 8}William.Buchanan at mpls [dot] k12 [dot] mn [dot] us{p_end}
