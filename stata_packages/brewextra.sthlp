{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
Command used to build data set containing additional color palettes used by {help brewscheme}.
{hline}

{title:help for brewextra}

{hi:brewextra {hline 2}} A utility for {help brewscheme} that allows users to add data to their local {help brewscheme} database for use creating new {help scheme files}.

{title:Syntax}

{p 4 4 4}{cmd:brewextra} [, {cmd:files(}{it:string}{opt )} {cmdab:rep:lace} ] {break}

{title:Description}

{p 4 4 4}{cmd:brewextra} is used to build a look-up table of RGB values for 
palettes as part of the {browse "http://www.ColorBrewer2.org":Color Brewer} 
research.  Additionally, the program also parses the available meta data on the 
"friendliness" properties of the various color palettes and includes an option 
to look up those meta data on the fly.  Additionally, the program will 
automatically call the {help brewextra} program to add the other available 
research-based color palettes to the file when constructed. {p_end}

{title:Options}

{p 4 4 8}{cmd:files} is an optional argument used to pass filenames to the 
program to be added to the local {help brewscheme} data base.  The program also 
includes some simple validation to hopefully prevent breaking the functionality 
of {help brewscheme}.  Below is the file specification that should guide your 
construction of files to add to the brewscheme database. {p_end}{break}

{col 5}{hline 100}
{col 5}variable   {col 15}storage {col 25} display {col 35} value {col 50} 
{col 5} name 	  {col 15} type   {col 25} format  {col 35} label {col 50} variable label 
{col 5}{hline 100}
{col 5}palette{col 15} str11  {col 25} %11s   {col 35} {col 50} Name of Color Palette
{col 5}colorblind{col 15} byte	  {col 25} %10.0g {col 35} colorblind {col 50} Colorblind Indicator
{col 5}print {col 15} byte{col 25} %10.0g {col 35} print {col 50} Print Indicator
{col 5}photocopy {col 15} byte {col 25} %10.0g {col 35} photocopy {col 50} Photocopy Indicator
{col 5}lcd {col 15} byte {col 25} %10.0g {col 35} lcd {col 50} LCD/Laptop Indicator
{col 5}colorid {col 15} byte {col 25} %10.0g {col 35} {col 50} Within pcolor ID for individual color look ups
{col 5}pcolor {col 15} byte {col 25} %10.0g {col 35} {col 50} Palette by Colors Selected ID
{col 5}rgb {col 15} str11 {col 25} %11s   {col 35} {col 50} Red-Green-Blue Values to Build Scheme Files
{col 5}maxcolors {col 15} byte {col 25} %10.0g {col 35} {col 50} Maximum number of colors allowed for the palette
{col 5}seqid {col 15} str13 {col 25} %13s   {col 35} {col 50} Sequential ID for property lookups
{col 5}meta {col 15} str13 {col 25} %13s   {col 35} {col 50} Meta-Data Palette Characteristics 
{col 5}{hline 100}
{break}

{p 4 4 8}{cmdab:rep:lace} is an optional argument used to rebuild and overwrite 
the brewextras.dta file containing the additional palettes used by {help brewscheme}.{p_end}

{marker examples}{title:Examples}

{p 4 4 4} Rebuild the additional palettes included in {help brewscheme} {p_end}

{p 8 8 12}brewextra, rep {p_end}

{title:Author}{break}
{p 4 4 8}William R. Buchanan, Ph.D.{p_end}
{p 4 4 8}Data Scientist{p_end}
{p 4 4 8}{browse "http://mpls.k12.mn.us":Minneapolis Public Schools}{p_end}
{p 4 4 8}William.Buchanan at mpls [dot] k12 [dot] mn [dot] us{p_end}

