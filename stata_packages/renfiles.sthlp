{smcl}
{* *! version 2.1  2011-12-22}{...}
{cmd:help renfiles} (vs2.0: 2011-07-19) (vs2.1: 2011-12-22)
{hline}

{title:Title}

{p2colset 5 19 21 2}{...}
{bf:renfiles} {hline 2} Renaming matched files by replacing specified sign/substring with another sign/substring.
{p2colreset}{...}


{title:Syntax}

{p 4 16 2}
{opt renfiles} [{cmd:,} {opt folder}({it:string}) {opt match}({it:string}) {opt subs}({it:string}) {opt insign}({it:string}) {opt outsign}({it:string}) {opt erase} {opt oldstx}]



{title:Description}

{pstd}
{cmd:renfiles} 
is a program that helps to rename files in a quite generally applicable fashion - 
changes applied to all matched filenames in a stated directory, and also - if selected -
in all matched subdirectories. The simplest syntax is purely based on defaults. All options are optional. 

{pstd}
If the sign
to-be-replaced is a dot, the last dot is not changed (keeping file-suffix).



{title:Options}

{pstd}
{opt folder}({it:string}) Defines the directory from within where to look for files. 
The default directory is the current working directory (cwd; '.').

{pstd}
{opt match}({it:string}) Defines the matching criterion used in order to select files 
from the selected directory {bf:folder}, and - if selected - matched (by {bf: subs}) subdirectories. 
The default is all files in the directory/directories ('*').

{pstd}
{opt subs}({it:string}) Defines whether, or not, matched files (by {bf:match}) in corresponding matched 
subdirectories (recursively; based on here defined matching criterion) also should be affected. 
(Matching must be present at all levels.)

{pstd}
{opt insign}({it:string}) The sign to be replaced when applying the used criterion {bf:match} 
with respect to the files in the directory {bf:folder}, and - if selected - matched (by {bf: subs}) subdirectories.  
Is case-sensitive if option {bf: oldstx} is not selected. The default is the dot sign ('.').

{pstd}
{opt outsign}({it:string}) The sign to be replacing (the to-be-replaced sign {bf:insign}) when 
applying the used criterion {bf:match} with respect to the files in the directory {bf:folder},
and - if selected - matched (by {bf: subs}) subdirectories. To remove the sign {bf:insign}, 
i.e. replacing it with an empty space, use string {it:null}. The default is the underscore sign ('_').

{pstd}
{opt erase} An indicator for whether, or not, the original matched (but unchanged) files should be removed from
the directory. 

{pstd}
{opt oldstx} An indicator for whether, or not, Stata 9 syntax (as compared to Stata 11 syntax) should be assumed
with respect to extended macro functions. If stated, matching will not be case-sensitive and hence all matching 
strings {it:string} should be entered in lower case.


{title:Examples}

    {hline}

{pstd} 1. Remove dots from all files in current working directory and replace them with underscores. {p_end}
{phang2}{cmd:. renfiles}{p_end}

    {hline}

{pstd} 2. Remove dots from all files with prefix {it:name} located in cwd-subdirectory {it:data} and replace them with dashes. {p_end}
{phang2}{cmd:. renfiles , folder(".\data") match("name*") outsign("-")}{p_end}

    {hline}

{pstd} 3. Same as Example 2, but in this case all matched, original, files are also to be erased. {p_end}
{phang2}{cmd:. renfiles , folder(".\data") match("name*") outsign("-") erase}{p_end}

    {hline}

{pstd} 4. Remove all occurrences of {it:file} and replace them with abbreviation {it:f} in all files with filenames including string-part {it:proj3} located in cwd-subdirectory {it:results}.{p_end}
{phang2}{cmd:. renfiles , folder(".\results") match("*proj3*") insign("file") outsign("f")}{p_end}

    {hline}

{pstd} 5. Same as Example 4, but in this case all Denmark-specific letters ('å', 'æ' and 'ø') are removed (replaced with anglofied counterparts) in a sequential manner; original/temporary files are erased.{p_end}
{phang2}{cmd:. renfiles , folder(".\results") match("*proj3*") insign("å") outsign("aa") erase}{p_end}
{phang2}{cmd:. renfiles , folder(".\results") match("*proj3*") insign("æ") outsign("ae") erase}{p_end}
{phang2}{cmd:. renfiles , folder(".\results") match("*proj3*") insign("ø") outsign("oe") erase}{p_end}

    {hline}

{pstd} 6. Same as Example 4, but in this case all present empty spaces, within matched filenames, are removed (replaced with null space; see note above).{p_end}
{phang2}{cmd:. renfiles , folder(".\results") match("*proj3*") insign(" ") outsign("null")}{p_end}

    {hline}

{pstd} 7. Same as Example 4, but in this case corresponding actions are also performed with respect to all subdirectories 
(recursively, see note above) with names starting with string {it:2011}.{p_end}
{phang2}{cmd:. renfiles , folder(".\results") match("*proj3*") subs("2011*") insign("file") outsign("f")}{p_end}

    {hline}

{pstd} 8. Same as Example 7, but in this case using the old syntax, leading to case-insensitive matching. 
For example, all files including strings {it: PROJ3} or {it: Proj3} will also be matched in this case. Use lower case, see note above.{p_end}
{phang2}{cmd:. renfiles , folder(".\results") match("*proj3*") subs("2011*") insign("file") outsign("f") oldstx}{p_end}

    {hline}


{title:Requires}

{pstd} Stata 9; newer versions needed when option {bf: oldstx} is not used.


{title:Author}

{pstd} Lars Ängquist {break}
       Lars.Henrik.Angquist@regionh.dk {break}
       lars@angquist.se


{title:Acknowledgements}

{pstd} Testing assistance by Birgit Marie Nielsen (Thanks Birgit! /  LÄ)


{title:Related commands (downloadable on SSC)}

{pstd} {help mvfiles} - moving set of matched files{break}
       {help rmfiles} - removing set of matched files{break}
       {help use10save9} - save Stata 10/11 files as Stata 9 counterparts (also from within Stata 9) {break}
       {help excelsave} - exporting set of matched files to Excel (.xls or .xlsx)


{title:Also see}

{psee}
{space 2}Help:  [help pages on] {help extended_fcn}, {help dir}, {help copy}, {help erase}.
{p_end}
