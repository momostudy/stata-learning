{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
Command used to generate .theme files used by {help brewscheme}
{hline}

{title:help for brewtheme}

{p 4 4 4}{hi:brewtheme {hline 2}} a program to generate theme files containing 
scheme file entries for graph independent aesthetics. {p_end}

{title:Syntax}

{p 4 4 4}{cmd:brewtheme} {it:themeName} [, {help btabovebelow:{ul:abo}vebelow}{hi:(}{it:string}{hi:)}
{help btanglestyle:{ul:anglesty}le}{hi:(}{it:string}{hi:)}
{help btareastyle:{ul:areasty}le}{hi:(}{it:string}{hi:)}
{help btarrowstyle:{ul:arrowsty}le}{hi:(}{it:string}{hi:)}
{help btaxisstyle:{ul:axissty}le}{hi:(}{it:string}{hi:)}
{help btbarlabelpos:{ul:barlabelp}os}{hi:(}{it:string}{hi:)}
{help btbarlabelstyle:{ul:barlabelsty}le}{hi:(}{it:string}{hi:)}
{help btbarstyle:{ul:barsty}le}{hi:(}{it:string}{hi:)}
{help btbygraphstyle:{ul:bygraphsty}le}{hi:(}{it:string}{hi:)}
{help btclegendstyle:{ul:clegendsty}le}{hi:(}{it:string}{hi:)}
{help btclockdir:{ul:clock}dir}{hi:(}{it:string}{hi:)}
{help btcolor:{ul:col}or}{hi:(}{it:string}{hi:)}
{help btcompass2dir:{ul:compass2}dir}{hi:(}{it:string}{hi:)}
{help btcompass3dir:{ul:compass3}dir}{hi:(}{it:string}{hi:)}
{help btconnectstyle:{ul:connectsty}le}{hi:(}{it:string}{hi:)}
{help btdottypestyle:{ul:dottypesty}le}{hi:(}{it:string}{hi:)}
{help btgraphsize:{ul:graphsi}ze}{hi:(}{it:string}{hi:)}
{help btgraphstyle:{ul:graphsty}le}{hi:(}{it:string}{hi:)}
{help btgridlinestyle:{ul:gridlinesty}le}{hi:(}{it:string}{hi:)}
{help btgridringstyle:{ul:gridringsty}le}{hi:(}{it:string}{hi:)}
{help btgridstyle:{ul:gridsty}le}{hi:(}{it:string}{hi:)}
{help btgsize:{ul:gsize}}{hi:(}{it:string}{hi:)}
{help bthorizontal:{ul:horiz}ontal}{hi:(}{it:string}{hi:)}
{help btlabelstyle:{ul:labelsty}le}{hi:(}{it:string}{hi:)}
{help btlegendstyle:{ul:legendsty}le}{hi:(}{it:string}{hi:)}
{help btlinepattern:{ul:linepat}tern}{hi:(}{it:string}{hi:)}
{help btlinestyle:{ul:linesty}le}{hi:(}{it:string}{hi:)}
{help btlinewidth:{ul:linew}idth}{hi:(}{it:string}{hi:)}
{help btbtmargin:{ul:marg}in}{hi:(}{it:string}{hi:)}
{help btmedtypestyle:{ul:medtypesty}le}{hi:(}{it:string}{hi:)}
{help btnumstyle:{ul:numsty}le}{hi:(}{it:string}{hi:)}
{help btnumticks:{ul:numticks}}{hi:(}{it:string}{hi:)}
{help btpiegraphstyle:{ul:piegraphsty}le}{hi:(}{it:string}{hi:)}
{help btpielabelstyle:{ul:pielabelsty}le}{hi:(}{it:string}{hi:)}
{help btplotregionstyle:{ul:plotregionsty}le}{hi:(}{it:string}{hi:)}
{help btrelativepos:{ul:relativep}os}{hi:(}{it:string}{hi:)}
{help btrelsize:{ul:relsi}ze}{hi:(}{it:string}{hi:)}
{help btspecial:{ul:spec}ial}{hi:(}{it:string}{hi:)}
{help btstarstyle:{ul:starsty}le}{hi:(}{it:string}{hi:)}
{help btsunflowerstyle:{ul:sunflowersty}le}{hi:(}{it:string}{hi:)}
{help btsymbol:{ul:symb}ol}{hi:(}{it:string}{hi:)}
{help btsymbolsize:{ul:symbolsi}ze}{hi:(}{it:string}{hi:)}
{help btorientstyle:{ul:orientsty}le}{hi:(}{it:string}{hi:)}
{help bttextboxstyle:{ul:textboxsty}le}{hi:(}{it:string}{hi:)}
{help bttickposition:{ul:tickp}osition}{hi:(}{it:string}{hi:)}
{help bttickstyle:{ul:ticksty}le}{hi:(}{it:string}{hi:)}
{help btticksetstyle:{ul:ticksetsty}le}{hi:(}{it:string}{hi:)}
{help btverticaltext:{ul:verticalt}ext}{hi:(}{it:string}{hi:)}
{help btyesno:{ul:yesn}o}{hi:(}{it:string}{hi:)}
{help btzyx2rule:{ul:zyx2r}ule}{hi:(}{it:string}{hi:)}
{help btzyx2style:{ul:zyx2sty}le}{hi:(}{it:string}{hi:)} ]{break}

{marker bttop}{title:Description}

{p 4 4 4}{cmd:brewtheme} is used to create a file with scheme entries that are 
primarily used to control/define graph independent/global aesthetic properties 
for Stata graphs (with a few exceptions related to bar graphs and/or pie graphs).  
Given the number of potential arguments for some of these options, they are each 
described below briefly and in greater detail in their respective helpfiles.{p_end}

{p 4 4 4}Additionally, when developing new schemes/themes, it is important to 
follow the guidance provided in the {help scheme_files##remarks6:scheme files} 
help documentation.  Notably: {p_end}

{p 8 8 12}It is critical that you issue the {help discard} command each time 
before you reissue your graph command.  {help discard} reinitializes the 
graphics system, and that includes clearing the graphics scheme.  If you do not 
type {help discard}, {hi graph} will note that you are using the same scheme 
each time and will use the already loaded scheme - ignoring the
changes you made in the scheme file.{p_end}

{p 4 4 4}For additional information about the different options and entries that 
are used in scheme files, see {help scheme entries}.  If you try a value that 
does not work when creating a {hi .theme} file, {browse "https://github.com/wbuchanan/brewscheme/issues":submit an issue} 
to the project's repository or you can modify the corresponding help file for 
that option noting that the value didn't work and submit a pull request to 
merge your changes with the project's repository.  The entries on the topic 
specific help files below are my best guesses regarding the set of possible 
values.  {p_end}

{title:Options}

{p 4 4 4}The links below point to topic specific help files.  These are still a 
work in progress, but will contain information about specific entries and as 
much information as possible about how their values effect the appearance of 
graphs.{p_end}

{p 4 4 4}{it:The options below are listed with the 'bt' prefix to differentiate them from cases where there may be official Stata help files with the same namespace.}{p_end}

{col 15}{hline 55}
{p2colset 20 50 50 20}{p2col:{title: {help btabovebelow}}}{title: {help btanglestyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btareastyle}}}{title: {help btarrowstyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btaxisstyle}}}{title: {help btbarlabelpos}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btbarlabelstyle}}}{title: {help btbarstyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btbygraphstyle}}}{title: {help btclegendstyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btclockdir}}}{title: {help btcolor}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btcompass2dir}}}{title: {help btcompass3dir}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btconnectstyle}}}{title: {help btdottypestyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btgraphsize}}}{title: {help btgraphstyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btgridlinestyle}}}{title: {help btgridringstyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btgridstyle}}}{title: {help btgsize}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help bthorizontal}}}{title: {help btlabelstyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btlegendstyle}}}{title: {help btlinepattern}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btlinestyle}}}{title: {help btlinewidth}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btmargin:margin}}}{title: {help btmedtypestyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btnumstyle}}}{title: {help btnumticks}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btpiegraphstyle}}}{title: {help btpielabelstyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btplotregionstyle}}}{title: {help btrelativepos}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btrelsize}}}{title: {help btspecial}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btstarstyle}}}{title: {help btsunflowerstyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btsymbol}}}{title: {help btsymbolsize}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help bttextboxstyle}}}{title: {help bttickposition}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help bttickstyle}}}{title: {help btticksetstyle}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btverticaltext}}}{title: {help btyesno}}{p_end}
{p2colset 20 50 50 20}{p2col:{title: {help btzyx2rule}}}{title: {help btzyx2style}}{p_end}
{col 15}{hline 55}

{title:Author}{break}
{p 4 4 8}William R. Buchanan, Ph.D.{p_end}
{p 4 4 8}Data Scientist{p_end}
{p 4 4 8}{browse "http://mpls.k12.mn.us":Minneapolis Public Schools}{p_end}
{p 4 4 8}William.Buchanan at mpls [dot] k12 [dot] mn [dot] us{p_end}
