{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
Command to create new named color styles and add to existing color dataset.
{hline}

{title:help for brewcolors}

{p 4 4 4}{hi:brewcolors {hline 2}} is a program used to create new named color 
styles and/or add colors to the color dataset.  The program includes sub-commands 
to create these colors manually or to add colors from the 
{browse "http://xkcd.com/color/rgb.txt":XKCD color survey}. {p_end}

{title:Syntax}

{p 4 4 4}{cmd:brewcolors} {it:xkcd}|{it:new} [, {cmdab:ma:ke} {cmdab:inst:all} 
{cmdab:col:ors(}{it:string}{opt )} {cmdab:rep:lace} {cmdab:over:ride} ] {break}

{title:Description}

{p 4 4 4}{cmd:brewcolors} builds a local database of named RGB colors on the 
user's system.  It also includes transformed RGB values for different forms of 
color sight impairments.{p_end}

{title:Options}

{p 4 4 8}{cmdab:ma:ke} is an optional argument used to append the resulting 
color dataset to the master colordata set used by {help brewscheme}.{p_end}

{p 4 4 8}{cmdab:inst:all} is an optional argument used to create each of the 
named color style files and place them on the ADOPATH to be accessible in 
Stata.{p_end}

{p 4 4 8}{cmdab:col:ors} is an optional argument used to pass the color name 
and RGB values when using the new subcommand.{p_end}

{p 4 4 8}{cmdab:rep:lace} is an optional argument used to overwrite an 
existing version of the color dataset being created.{p_end}

{p 4 4 8}{cmdab:over:ride} is an optional argument used to suppress the warning 
message printed to the console by {help brewcolordb}.{p_end}

{marker examples}{title:Examples}

{p 4 4 4}Creates the dataset with all of the XKCD colors and installs them 
as named color styles for Stata to use.{p_end}

{p 8 8 12}brewcolors xkcd, mk inst over rep {p_end}

{title:Author}{break}
{p 4 4 4}William R. Buchanan, Ph.D.{p_end}
{p 4 4 4}Data Scientist{p_end}
{p 4 4 4}{browse "http://mpls.k12.mn.us":Minneapolis Public Schools}{p_end}
{p 4 4 4}William.Buchanan at mpls [dot] k12 [dot] mn [dot] us{p_end}
