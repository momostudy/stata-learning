{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
A command to preview one or more brewscheme color palettes
{hline}

{title:help for brewviewer}

{p 4 4 8}{hi:brewviewer {hline 2}} A utility for {help brewscheme} to preview color palettes available.{p_end}

{title:Syntax}

{p 4 4 4}{cmd:brewviewer} {it:palette names} [, {cmdab:c:olors(}{it:numlist}{opt )} 
{cmdab:comb:ine} {cmdab:s:eq} {cmdab:im:paired} ] {p_end}

{title:Description}

{p 4 4 4}{cmd:brewviewer} is a utility for the {help brewscheme} program that 
provides you with a way to preview different combinations of palettes and numbers of 
colors.{p_end}

{title:Options}

{p 4 4 8}{cmdab:c:olors} is a required argument and is used to specify the number 
of colors to preview.  If a single argument is passed it is used for all palettes.  
If the number of color values passed is the same as the number of palettes the 
program will treat the values as being specific to the corresponding palette 
specified.  If there are fewer colors than palettes, the maximum value of the colors 
parameter will be used for the graphs if the {cmdab:s:eq} option is passed, else 
the same colors are recycled for each of the graphs.  Lastly, if the number of 
colors passed is greater than the number of palettes, it will override the 
{cmdab:s:eq} option and treat each of the numbers as discrete for all palettes. {p_end}{break}

{p 4 4 8}{cmdab:comb:ine} is an optional argument used to generate a single combined 
graph with each of the graphs combined in a single image. {p_end}

{p 4 4 8}{cmdab:s:eq} is an optional argument used to tell the program that you 
want to treat the number of colors as the maximum number of sequences to graph.  
For example, if a value of 5 is passed to {cmdab:c:olors} and {cmdab:s:eq} is selected, 
the resulting graph will contain columns showing colors 1-3, 1-4, and 1-5.  If this 
option is not selected, it will only show a single column of colors from 1-5.{p_end}

{p 4 4 8}{cmdab:im:paired} is an optional argument to display the palette(s) along with 
color sight impaired transformations of the colors. {p_end}

{marker examples}{title:Examples}

{p 4 4 4} See the {browse "http://github.com/wbuchanan/brewscheme":GitHub Repository} for 
brewscheme for examples of this program.{p_end}


{marker acknowledgements}{title:Acknowledgements}

{p 4 4 8}This subroutine for {help brewscheme} was inspired and influenced by {browse "http://github.com/matthieugomez/stata-colorscheme":Mattieu Gomez's} program stata-colorscheme.{p_end}

{title:Author}{break}
{p 4 4 8}William R. Buchanan, Ph.D.{p_end}
{p 4 4 8}Data Scientist{p_end}
{p 4 4 8}{browse "http://mpls.k12.mn.us":Minneapolis Public Schools}{p_end}
{p 4 4 8}William.Buchanan at mpls [dot] k12 [dot] mn [dot] us{p_end}

