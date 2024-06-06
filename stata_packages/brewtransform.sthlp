{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
Command to transform a variable of RGB strings into color sight impaired variables
{hline}

{title:help for brewtransform}

{p 4 4 4}{hi:brewtransform {hline 2}} a program to transform a Stata formatted RGB string 
into RGB values that simulate the conditions of achromatopsia, protanopia, deuteranopia, and tritanopia.{p_end}

{title:Syntax}

{p 4 4 4}{cmd:brewtransform} {it:RGB_varname} {break}

{title:Description}

{p 4 4 4}{cmd:brewtransform} is used to create four variables containing Stata 
formatted RGB strings that simulate complete color blindness and red, green, and 
blue color perception impairments.  The program takes a single variable formatted 
as str11 as the sole argument and creates/returns four variables: achromatopsia, 
protanopia, deuteranopia, and tritanopia. {p_end}

{marker examples}{title:Examples}

{p 4 4 4} Transform the RGB Strings contained in the variable rgb. {p_end}

{p 8 8 12}brewtransform rgb{p_end}{break}

{marker refs}{title:{ul:References}}

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
