{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
Command to build local dataset of named colors and simulated color values
{hline}

{title:help for brewcolordb}

{p 4 4 4}{hi:brewcolordb {hline 2}} is a program to build a database of locally 
installed colors defined by StataCorp.  It includes the RGB values for each color 
as well as transformed RGB values that simulate varying forms of color sight impairments.{p_end}

{title:Syntax}

{p 4 4 4}{cmd:brewcolordb} [, {cmdab:dis:play} {cmdab:rep:lace} {cmdab:over:ride} ] {break}

{title:Description}

{p 4 4 4}{cmd:brewcolordb} builds a local database of named RGB colors on the 
user's system.  It also includes transformed RGB values for different forms of 
color sight impairments.{p_end}

{title:Options}

{p 4 4 8}{cmdab:dis:play} is an optional argument to display the color information in the results window during the program's execution.{p_end}

{p 4 4 8}{cmdab:rep:lace} is an optional argument used to overwrite an existing copy of the library. {p_end}

{p 4 4 8}{cmdab:over:ride} is an optional argument used to override a user prompt before clearing data from memory. {p_end}

{marker examples}{title:Examples}

{p 4 4 4}Build the database and display the results{p_end}

{p 8 8 12}brewcolordb, dis{p_end}

{title:Author}{break}
{p 4 4 4}William R. Buchanan, Ph.D.{p_end}
{p 4 4 4}Data Scientist{p_end}
{p 4 4 4}{browse "http://mpls.k12.mn.us":Minneapolis Public Schools}{p_end}
{p 4 4 4}William.Buchanan at mpls [dot] k12 [dot] mn [dot] us{p_end}
