{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
Simulating color sight impairments on one or more colors
{hline}

{title:help for brewcbsim}

{p 4 4 4}{hi:brewcbsim {hline 2}} a program to simulate how a given color would 
be perceived by individuals with achromatopsia, protanopia, deuteranopia, or 
tritanopia.{p_end}

{title:Syntax}

{p 4 4 4}{cmd:brewcbsim} {it:red green blue} {hi:|} {it:named color style} {break}

{title:Description}

{p 4 4 4}{cmd:brewcbsim} is used to simulate how a given color (specified as an RGB tuple in [0, 255]) would be perceived by individuals with color sight impairments.{p_end}

{marker examples}{title:Examples}{break}
{p 4 4 4} Green channel dominant color. {p_end}

{p 8 8 12}brewcbsim 63 210 142{p_end}

{p 4 4 4}Blue channel dominant color.{p_end}

{p 8 8 12}brewcbsim 8 151 233{p_end}

{p 4 4 4}Red channel dominant color{p_end}

{p 8 8 12}brewcbsim 182 33 43{p_end}

{p 4 4 4}These examples can be viewed {browse "http://wbuchanan.github.io/brewscheme/brewcbsim/":here}.{p_end}{break}

{marker retvals}{title:Returned Values}{break}
  {hline 100}
{p2colset 8 30 30 8}{p2col:Macro}Value{p_end}
  {hline 100}
{p2colset 8 30 30 8}{p2col:r(original#)}The RGB value for the nth color passed to the command{p_end}
{p2colset 8 30 30 8}{p2col:r(achromatopsic#)}Transformed RGB value for the nth color (Complete Color Vision Loss){p_end}
{p2colset 8 30 30 8}{p2col:r(protanopic#)}Transformed RGB value for the nth color (Red Color Impairment){p_end}
{p2colset 8 30 30 8}{p2col:r(deuteranopic#)}Transformed RGB value for the nth color (Green Color Impairment){p_end}
{p2colset 8 30 30 8}{p2col:r(tritanopic#)}Transformed RGB value for the nth color (Blue Color Impairment){p_end}
  {hline 100}

{marker refs}{title:{ul:References}}{break}
{marker wickline}{p 4 8 8}Wickline, M. (2014). {it:Color.Vision.Simulate, Version 0.1}.  Retrieved from: 
{browse "http://galacticmilk.com/labs/Color-Vision/Javascript/Color.Vision.Simulate.js"}. 
Retrieved on: 24nov2015.{p_end} 
{marker mg}{p 4 8 8}Meyer, G. W., & Greenberg, D. P. (1988). Color-Defective Vision and Computer Graphics Displays. 
{it:Computer Graphics and Applications, IEEE 8(5)}, pp. 28-40.{p_end}

{marker sp}{p 4 8 8}Smith, V. C., & Pokorny, J. (2005).  Spectral sensitivity of the foveal cone photopigments between 400 and 500nm.  
{it:Journal of the Optical Society of America A, 22(10),} pp. 2060-2071.{p_end}

{marker lindbloom}{p 4 8 8}Lindbloom, B. (2001).  RGB working space information. Retrieved from: {browse "http://www.brucelindbloom.com/WorkingSpaceInfo.html"}.  Retrieved on 24nov2015.{p_end}

{title:Author}{break}
{p 4 4 8}William R. Buchanan, Ph.D.{p_end}
{p 4 4 8}Data Scientist{p_end}
{p 4 4 8}{browse "http://mpls.k12.mn.us":Minneapolis Public Schools}{p_end}
{p 4 4 8}William.Buchanan at mpls [dot] k12 [dot] mn [dot] us{p_end}

