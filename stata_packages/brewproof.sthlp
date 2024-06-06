{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
Prefix command to create color sight impairment proofs of a graph.
{hline}

{title:help for brewproof}

{p 4 4 4}{hi:brewproof {hline 2}} is a program to generate a proof copy of a graph 
to simulate how the image would be viewed by individuals with achromatopsia, 
protanopia, deuteranopia, and tritanopia.{p_end}

{title:Syntax}

{p 4 4 4}{cmd:brewproof, scheme{c 40}}{it:brewscheme scheme file}{cmd:{c 41}{c 58}}{it: graph command} {break}

{title:Description}

{p 4 4 4}{cmd:brewproof} is used to simulate the appearance of the specified 
graph as seen if the viewer suffered from achromatopsia, protanopia, deuteranopia, 
or tritanopia.  This is a prefix type command that wraps the user-specified 
graph file to generate separate simulated graphs as well as a proof copy with 
all four of the color impaired versions of the graph on a single image.  {p_end}

{marker examples}{title:Examples}

{p 4 4 4} Generate a graph with {browse "http://github.com/hadley/ggplot2":ggplot2} styled aesthetics. {p_end}

{p 8 8 12}{stata sysuse auto.dta, clear}{p_end}
{p 8 8 12}brewproof, scheme(ggtest2) : tw lowess mpg weight, || scatter mpg weight if rep78 == 1 || scatter mpg weight if rep78 == 2 || scatter mpg weight if rep78 == 3 || scatter mpg weight if rep78 == 4 || scatter mpg weight if rep78 == 5, legend(order(2 "1978 Repair Record = 1" 3 "1978 Repair Record = 2" 4 "1978 Repair Record = 3" 5 "1978 Repair Record = 4" 6 "1978 Repair Record = 5")){p_end}

{marker refs}{title:References}

{marker wickline}{p 4 8 8}Wickline, M. (2014). {it:Color.Vision.Simulate, Version 0.1}.  Retrieved from: 
{browse "http://galacticmilk.com/labs/Color-Vision/Javascript/Color.Vision.Simulate.js"}. Retrieved on: 24nov2015.{p_end} 
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



