{smcl}
{right:version:  2.3.9.5}
{cmd:help asdoc} {right:April 10, 2021}
{hline}
{viewerjumpto "asdoc_Options" "asdoc##asdoc_options"}{...}
{viewerjumpto "Summary Stats" "asdoc##summary"}{...}
{viewerjumpto "Correlations" "asdoc##3Correlation"}{...}
{viewerjumpto "Regressions" "asdoc##4Regressions"}{...}
{viewerjumpto "Frequency Tables" "asdoc##5Freq"}{...}
{viewerjumpto "Tabstat" "asdoc##6tabstat"}{...}
{viewerjumpto "Flexibel Tables" "asdoc##7flextable"}{...}
{viewerjumpto "T-tests" "asdoc##8ttest"}{...}
{viewerjumpto "Means" "asdoc##9tmeans"}{...}
{viewerjumpto "Tabsum" "asdoc##9tmeans"}{...}
{viewerjumpto "List" "asdoc##list"}{...}
{viewerjumpto "Matrix" "asdoc##matrix"}{...}
{vieweralsosee "other programs" "asdoc##also"}{...}


{title:Title}

{p 4 8}{cmd:asdoc}  - An easy way of creating publication quality tables from Stata commands {p_end}


{title:Syntax}

{p 4 6 2}
[{it:bysort varname}:] {cmd:asdoc} Stata_Commands, [Stata_command_options asdoc_options] 

{marker TableContents}
{title:Table of contents}

{bf:{help asdoc##asdoc_options:1. Commands for controlling asdoc}}
{help asdoc##1_1replace:1.1 Replace / append}
{help asdoc##1_2rowappend:1.2 appending similar rows (rowappend)}
{help asdoc##1_2Save:1.3 Output file name (save)}
{help asdoc##1_3title:1.4 Table title (title)}
{help asdoc##1_5fhrfhc:1.5 Format row and column headers  (fhr and fhc)}
{help asdoc##14:1.6 Font size (fs)}
{help asdoc##14_2:1.7 Font style (font)}
{help asdoc##15:1.8 Decimal points (dec)}
{help asdoc##16:1.9 Adding lines / paragraphs (text)}
{help asdoc##17:1.10 Hide Stata output (hide)}
{help asdoc##18:1.11 Getting Stata commands in output files (cmd)}
{help asdoc##19:1.12 Abbreviate variable names (abb)}
{help asdoc##20:1.13 Report labels instead of variable names (label)}
{help asdoc##12tzok:1.14 Always report equal decimal points (tzok)}
{help asdoc##rtfdir:1.15 RTF control words on the go)}

{bf:{help asdoc##summary:2. Summary statistics}}
{help asdoc ##2_1Simplesummary:2.1 Basic summary statistics}
{help asdoc ##2_2detailSummary:2.2 Detailed Summary statistics}
{help asdoc ##2_3CustomSummary:2.3 Customized summary statistics}
{help asdoc ##2_4BySummary:2.4 By-groups summary statistics}

{bf:{help asdoc##3Correlation:3. Correlations}}
{help asdoc ##3_1Simplecor:3.1 Simple correlations}
{help asdoc ##3_2pwcorr:3.2 Pairwise / correlations with significance level}
{help asdoc ##3_3PartialCor:3.3 Partial correlations}
{help asdoc ##3_4InterclasslCor:3.4 Interclass correlation}
{help asdoc ##3_5TetraCor:3.5 Tetrachoric correlation}
{help asdoc ##3_6Spearman:3.6 Spearman correlation}

{bf:{help asdoc##4Regressions:4. Regressions}}
{help asdoc ##4_1DetRegression:4.1 Full regression tables}
{help asdoc ##4_2NestedRegression:4.2 Compact / nested tables (publication quality)}
{help asdoc##WideReg:4.3 Wide regression tables} 
{help asdoc##Byreg:4.4 Regression over groups using bysort} 


{bf:{help asdoc##5Freq:5. Frequency tables}}
{help asdoc##5_1Freq:5.1 One-way tabulation (tabulate1)}
{help asdoc##5_2Freq:5.2 Two-way tabulation (tabulate2)}
{help asdoc##5_3tabsum:5.3 One- and two-way tables of summary statistics (tabsum)}
{help asdoc##5_4tab1:5.4 Multiple-way tables (tab1)}
{help asdoc##5_5tab2:5.5 All-possible two-way tables (tab2)}

{bf:{help asdoc##6tabstat:6. Compact tables ({opt tabstat})}}
{help asdoc##61:6.1 Without groups}
{help asdoc##62:6.1 With groups}

{bf:{help asdoc##7flextable:7. Flexible table of statistics ({opt table})}}
{help asdoc##71:7.1 One-way table}
{help asdoc##72:7.2 Two-way table}
{help asdoc##73:7.3 Three-way table}
{help asdoc##74:7.4 Four-way table}

{bf:{help asdoc##8ttest:8. T-tests ({opt ttest})}}
{help asdoc##81:8.1 one-sample t-test}
{help asdoc##82:8.2 two-sample using groups}
{help asdoc##83:8.3 two-sample using variables}
{help asdoc##84:8.4 paired t-test}

{bf:{help asdoc##9tmeans:9. Table of means, std., and frequencies ({opt tabsum})}}

{bf:{help asdoc##10means:10. Means ({opt ameans})}}
{help asdoc##101:10.1 Arithmetic / harmonic / geometric means}
{help asdoc##propertions:10.2 Proportions}
{help asdoc##103:10.3 Ratio}
{help asdoc##104:10.4 Total}

{bf:{help asdoc##list:11. Export data to file ({opt list})}}

{bf:{help asdoc##matrix:12. Writing matrix to file ({opt wmat})}}

{bf:{help asdoc##svy:13. The survey prefix command ({opt svy}:)}}

{bf:{help asdoc##aslist:14. aslist - Create a list of unique values ({opt aslist})}}

{bf:{help asdoc##describe:15. Describe - Export variable names and their labels ({opt describe})}}

{bf:{help asdoc##row:16. Creating tables row by row ({opt row})}}

{bf:{help asdoc##accum:17. Accumulating text and statistics ({opt accum})}}

{bf:{help asdoc##other:18. Other Stata Commands}}

{bf:{help asdoc##cite:19. How to cite}}

{bf:{help asdoc##online:20. Index to blog entries and Videos}}

{bf:{help asdoc##future:21. Future Plans for asdoc}}


{title:DESCRIPTION}

{p 4 4 2} asdoc sends Stata output to Word / RTF format. asdoc creates high-quality, publication-ready tables from 
various Stata commands such as summarize, correlate, pwcorr, tab1, tab2, tabulate1, tabulate2, tabstat, ttest, 
regress, table, amean, proportions, means, and many more. Using asdoc is pretty easy.
We need to just add asdoc as a prefix to Stata commands. asdoc has several built-in routines for dedicated 
calculations and making nicely formatted tables.   

{marker asdoc_options}
{title:1. ASDOC OPTIONS}


{p 4 4 2} {cmd: How to enter asdoc options and Stata_command options}: {break}  
Both the asdoc options and Stata_command specific options should be entered after
comma. asdoc will parse both the option itself. For example, the following command
has both types of options.

{p 8 8 2} asdoc sum, detail replace dec(3)

{p 4 4 2} option {opt detail} belongs to {help sum} command of Stata, whereas options
{opt replace} and {opt dec(3)} are asdoc options.

{p 4 4 2} Following options are used for controlling the
behavior of asdoc:

{marker 1_1replace}
{p 4 4 2} {cmd: 1.1 Replace / append}: {break}  
We shall use option  {opt replace} when an existing output file needs to be replaced. On the other hand, we shall use
option  {opt append} if we want to append results to the existing file. Both the options are optional. Therefore,
if none of these options are used, asdoc will first determine whether a file with a similar name exists in 
the current directory. If it exists, asdoc will assume an append option. If the file does not exist, it
will create a new file with the default name "Myfile.doc" 

{p 4 8 8} {ul on} Example 1 : running asdoc without replace or append (first time){ul off}{break}  
`{break}
{stata "sysuse auto" : sysuse auto} {break}  
{stata "asdoc sum" : asdoc sum} {break}  

{p 4 4 2} The above lines of code will generate a new file with the name {it: Myfile.doc}. Next, if we estimate
a table of correlation, we can replace the existing file {cmd: Myfile.doc} or append to it. Again, if we do not use any
of these options, option append will be assumed. So;

{p 4 8 2} {ul on} Example 2 : running asdoc without replace or append (second time){ul off} {break}
`{break}
{stata "asdoc cor" : asdoc cor} {break}  OR {break} 
{stata "asdoc cor, append" : asdoc cor, append }

{p 4 8 2}Both of the above commands serve the same purpose. The file {it: Myfile.doc} will now contain a table 
of summary statistics, followed by a table of correlations. However, had we typed the following, then the
file would contain only table of correlations.{break}
`{break}
{stata "asdoc cor, replace" : asdoc cor, replace} {break} 

{marker 1_2rowappend}
{p 4 4 2} {opt 1.2 rowappend}: {break}  
To develop a table row by row from different runs of the asdoc, we need to use option {opt rowappend}.
This option can be used with ttests [{help asdoc##example53:see example here}], customized summary statistics 
[{help asdoc##row:see examples here}] or 
[{browse "https://fintechprofessor.com/2018/09/12/asdoc-using-option-row-for-creating-customized-tables-row-by-row-in-stata-ms-word/" :read more examples on our website here }], 
or in other instances where the table headers and structure do not change and appendable statistics have
similar structure as those already in the table. 

{marker 1_2Save}
{p 4 4 2} {opt 1.3 save(file_name)}: {break}  
Option {opt save(file_name)} is an optional option. This option is used to specify the name of the output
file. If left blank, the default name will be used, that is {it: Myfile.doc}. If {opt .doc} extension is
not preferred, then option save will have to be used with the desired extension, such as {opt .rtf} 

{p 4 8 2} {ul on}Example 3 : Naming the output file {break}{ul off}
`{break}
{stata "asdoc sum, save(summary.doc)" : asdoc sum, save(summary.doc)} {break}  OR {break} 
{stata "asdoc sum, save(summary.rtf)" : asdoc sum, save(summary.rtf) }{break}

{marker 1_3title}
{p 4 4 2} {opt 1.4 title(table_title)}: {break}  
Option {opt title(table_title)} is an optional option. This option is used to specify table title.
If left blank, a default table title will be used.{break}  
{stata "asdoc sum, save(summary.doc) title(Descriptive statistics)" : asdoc sum, save(summary.doc) title(Descriptive statistics)}

{p 8 8 2} {opt 1.4.1 title not needed}: {break}  
If table title is not needed, we can use an empty title using {opt title(\i)}{break} 
{stata "asdoc sum, save(summary.doc) title(\i)" : asdoc sum, save(summary.doc) title(\i)}


{marker 1_5fhrfhc}
{p 4 4 2} {opt 1.5 Format row and column headers fhr() and fhc()}: {break}  
Option {opt fhr()} is used to format the row headers, i.e. the data given in the
first column of each row. Option {opt fhc()} is used to format the column headers, i.e.,
the data given in the top cells of each column. Both the {opt fhr()} and {opt fhc()}
will pass RTF control words to the final document. See the following examples.

{p 4 4 2} {hline 60}{break}  
{bf: Objective}{space 35} {bf:Code to use}{break}  
{hline 60}{break}
Format column headers as bold {space 13} {opt fhc(\b)}{break}  
Format column headers as italic {space 11} {opt fhc(\i)}{break}  
Format column headers as bold and italic {space 2} {opt fhc(\b \i)}{break}  
Format row headers as bold {space 16} {opt fhr(\b)}{break}  
Format row headers as italic {space 14} {opt fhr(\b)}{break}                
Format row headers as bold and italic {space 5} {opt fhr(\b \i)}{break}  
{hline 60}{break}

{p 4 4 2} So to make a table of descriptive statistics with column hdeaders in bold
and row headers in italic font, the code would be:{break}
{stata "asdoc sum, fhr(\i) fhc(\b) replace" : asdoc sum, fhr(\i) fhc(\b) replace}


{marker 14}
{p 4 4 2} {opt 1.6 Font size} i.e. {opt fs(#)} {break}  
The default font size of asdoc is 10 pt. Option fs(#) can be used to change it.
For example, fs(12) or fs(8), etc.

{marker 14_2}
{p 4 4 2} {opt 1.7 Font style} i.e. {opt font(font_name)} {break}  
The default font style is Garamond in asdoc. Option font(font_name) can be used to change it.
For example, font(Arial) or font(Century), etc.


{marker 15}
{p 4 4 2} {opt 1.8 Decimal points} i.e. {opt dec(#)} {break}  
The default decimal points in many commands are 3. In some commands, the decimal points
are borrowed from the Stata output and hence they cannot be changed. In several
commands, it is possible to change decimal points with option dec(#).
For example, dec(2) or dec(4), etc.

{marker 16}
{p 4 4 2} {opt 1.9 Adding text lines to the output file} i.e. {opt text(text lines)} {break}  
We can write text to our output file with option {opt text(text lines)}.
This is useful when we want to add details or comments with the Stata output. In fact, this option
makes asdoc really flexible in terms of adding tables and paragraph at the same time.
We never have to leave the Stata interface to add comments or interpretation with the
results. One trick that we can play is to use option {help asdoc##14:fs()} to change
font size and mark headings and sub-headings in the document. Consider the following examples
[I have copied some text from www.wikipedia.org for this example]

{p 4 8 2}{ul on}1. Write a heading "Details on Cars" in our document{ul off}{break}   
asdoc, text(Details on Cars) fs(16) replace

{p 4 8 2}{ul on}2. Now add some text{ul off}{break} 
asdoc, text(A car is a wheeled motor vehicle used for transportation) append fs(10){break} 
asdoc, text(Most definitions of car say they run primarily on roads, seat one ) append fs(10){break} 
asdoc, text(to eight people, have four tires, and mainly transport people.) append fs(10){break} 

{p 4 8 2}{ul on}3. Now add some statistics{ul off}{break}  
sysuse auto, clear{break}  
asdoc sum, append fs(10)

{marker 17}
{p 4 8 2} {opt 1.10 Hide Stata output with option {opt hide}} {break}  
We can suppress Stata output with option {opt hide}. It is important to mention that
option hide might not work with some of the Stata commands (asdoc creates output
from log files in some cases).

{marker 18}
{p 4 8 2} {opt 1.11 Getting Stata commands in output files (cmd)} {break}  
If we need to report the Stata command in the output file, we can use the option {opt cmd}.

{marker 19}
{p 4 8 2} {opt 1.12 Abbreviate variable names with option} ({opt abb(#)}) {break}  
In case variable names are lengthy, they can be abbreviated in the output file with
option {opt abb(#)}. For example, {opt abb(8)}. In many cases, the default value is
10. However, when option {bf:label} is used, this value is set to {bf:= abb + 22}.
If abbreviation is not needed, we can use {opt abb(.)}

{marker 12tzok}
{p 4 8 2} {opt 1.13 Report variable labels with option} ({opt label}) {break}  
Several commands allow reporting variable labels instead of variable names. For example,
the most commonly used commands for reporting statistics are {help correlate} and {help summarize}. 
Both of these commands allow option {opt label}. For example :

{p 8 8 2} asdoc cor, label {break} 
asdoc sum, label

{p 4 8 2} {opt 1.14 Always report equal decimal points (tzok)} {break}  
The default for report decimal points is to drop trailing zeros and report only
valid decimal points. However, we can use the option {opt tzok} i.e. trailing zeros OK, 
to report equal decimal points for all values even if the trailing values are zero. 
Therefore, using option {opt dec(4)} for reporting 4 decimal points, the value 2.1 will be reported as follows with and 
without option {opt tzok}.

{p 8 8 2}Default style {bf: 2.1} {break} 
with tzok option {bf: 2.1000} {break} 


{marker rtfdir}
{p 4 8 2} {opt 1.15 RTF control words on the go} {break}  
It is pretty easy to pass on RTF control words with the sub-commands {help asdoc##16:text} 
and {help asdoc##row:row}, and option {opt title} of asdoc. See the following examples.

{p 8 8 2}  {opt Write text in italics} {break}  
asdoc, text(\i A car is a wheeled motor vehicle used for transportation) {break} 

{p 8 8 2}  {opt Write text in bold} {break}  
asdoc, text(\b A car is a wheeled motor vehicle used for transportation) {break} 

{p 8 8 2}  {opt Write only the selected text "wheeled motor" in bold} : The text
formating can be turned off by adding zero to the control word. Therefore, to turn
off the boldfacing, the control word is \b0 {break}  
asdoc, text(A car is a \b wheeled motor \b0 vehicle used for transportation) {break} 

{p 8 8 2}  {opt Write text in bold and italics}{break}  
asdoc, text(\b \i A car is a wheeled motor vehicle used for transportation) {break} 

{p 8 8 2}  {opt Write text as a new paragraph}{break}  
asdoc, text(\par A car is a wheeled motor vehicle used for transportation) {break} 

{p 8 8 2} For more on RTF control words, see {browse "http://www.biblioscape.com/rtf15_spec.htm":this pag}.


{help asdoc##TableConents:Go to Table of Contents}



{marker summary}
{title:2. SUMMARY STATISTICS}

{p 4 4 2} {cmd: asdoc} creates excellent tables of summary statistics such as 
mean, standard deviation, minimum, maximum, etc. {cmd: asdoc} offers four
different methods of creating tables of summary statistics. These are discussed
below with examples and relevant options. {break}

{marker 2_1Simplesummary}
{p 4 4 2} {cmd: 2.1 Simple tables of summary statistics}: {break}  
To create a simple table of summary statistics, we normally type {it:summarize} or {it:sum}
command in Stata. To send output from {it:sum} command to a Word document, we shall
type the following:

{p 4 8 2} {ul on} Example 4 : Summary / descriptive statistics for all numeric variables{ul off} {break}
`{break}
{stata "sysuse auto" : sysuse auto} {break}  
{stata "asdoc sum" : asdoc sum} {break}  

{p 4 8 2} {ul on} Example 5 : Summary / descriptive statistics for selected variables, reporting variable labels{ul off} {break}
`{break}
{stata "asdoc sum price mpg rep78 headroom trunk, label replace " : asdoc sum price mpg rep78 headroom trunk, label replace} {break}  


{p 4 8 2} {ul on} Example 6 : Summary / descriptive statistics with [if] [in] conditions{ul off} {break}
`{break}
{stata "asdoc sum price mpg rep78 headroom trunk if price>4000 " : asdoc sum price mpg rep78 headroom trunk if price>4000} {break}  

{p 4 8 2} {ul on} Example 7 : Reporting customized decimal points{ul off} {break}
`{break}
{stata "asdoc sum, dec(2)" : asdoc sum, dec(2)} {break}  


{marker 2_2detailSummary}
{p 4 4 2} {cmd: 2.2 Detailed summary statistics}: {break}  
To find detailed summary statistics, we normally type {it:summarize, detail} or {it:sum, detail}
command in Stata. To make a table of detailed summary statistics, we shall just add {it:detail} after comma 
to the {it:asdoc sum} command. Using this option, the following statistics are added to the table : observations,
mean, standard deviation, minimum, maximum, 1st percentile, 99th percentile, skewness, and kurtosis. If 
additional statistics or a specific combination of statistics are required, then we can use the customized
statistics option [see {help asdoc##2_3CustomSummary:Section 2.3 below}]. Following are some examples:

{p 4 8 2} {ul on} Example 8: Detailed Summary statistics for all numeric variables{ul off} {break}
`{break}
{stata "sysuse auto" : sysuse auto} {break}  
{stata "asdoc sum, detail" : asdoc sum, detail} {break}  

{p 4 8 2} {ul on} Example 9 : Detailed Summary statistics, write to file named {it:Summary stats.doc}{ul off} {break}
`{break}
{stata "asdoc sum, detail save(Summary stats.doc)" : asdoc sum, detail save(Summary stats.doc)} {break}  

{marker 2_3CustomSummary}
{p 4 4 2} {cmd: 2.3 Custom summary statistics}: {break}  
To make a table of a specific combination of statistics, we shall use the option {opt stat:istics()}
with {it: asdoc sum} command. Let us discuss option statistics first. {p_end}  

{p 8 8 2} {opt 2.3.1} {opt stat:istics()}
Option statistics allows the following statistics: N sd mean semean median count sum range min max var cv skewness kurtosis iqr p1 p5 p10 p25 p50 p75 p99 tstat

{dlgtab:Statistics}
{p2colset 8 18 19 2}{...}
{p2col : {opt N}} Number of observations{p_end}
{p2col : {opt mean}} Arithmetic mean {p_end}
{p2col : {opt sd}} Standard deviation {p_end}
{p2col : {opt semean}} Stanard error of the mean {p_end}
{p2col : {opt  sum}} Sum / total {p_end}
{p2col : {opt  range}} 	Range {p_end}
{p2col : {opt min}} The smallest value {p_end}
{p2col : {opt max}} The largest value  {p_end}
{p2col : {opt count}} Counts the number of non-missing observations {p_end}
{p2col : {opt var}} Variance {p_end}
{p2col : {opt cv}} 	Coefficient of variation {p_end}
{p2col : {opt skewness}} Skewness {p_end}
{p2col : {opt kurtosis}} Kurtosis {p_end}
{p2col : {opt iqr}} Interquartile  range {p_end}
{p2col : {opt p1}} 1st percentile {p_end}
{p2col : {opt p5}} 5th percentile {p_end}
{p2col : {opt p10}} 10th percentile {p_end}
{p2col : {opt p25}} 25th percentile {p_end}
{p2col : {opt p50}} Median or the 50 percentile {p_end}
{p2col : {opt p75}} 75th percentile {p_end}
{p2col : {opt p99}} 99th percentile {p_end}
{p2col : {opt tstat}} t-statistics that the given variable == 0 {p_end}
{hline}

{p 4 8 2} {ul on} Example 10 : Mean SD, t-value 1st and 99th percentiles{ul off} {break}
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}  
{stata "asdoc sum, stat(N mean sd tstat p1 p99)" : asdoc sum, stat(N mean sd tstat p1 p99)} {break}  

{p 4 8 2} {ul on} Example 11 : Replace existing file, decimal point 5{ul off} {break}
`{break}
{stata "asdoc sum, stat(N mean sd tstat p1 p99) replace dec(5)" : asdoc sum, stat(N mean sd tstat p1 p99) replace dec(5)} {break}  

{marker 2_4BySummary}
{p 4 4 2} {cmd: 2.4 Summary statistics over a grouping variable}: {break}  
To find summary statistics separately  for each category of a grouping variable,
we can use {help by(varname)} or the prefix {help bysort varname}: with asdoc. 

{p 4 8 2} {ul on} Example 12 : For each category of foreign{ul off}: display Mean SD, t-value 1st and 99th percentiles {break}
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}  
{stata "asdoc sum, stat(N mean sd tstat p1 p99) by(foreign)" : asdoc sum, stat(N mean sd tstat p1 p99) by(foreign)} {break}  
OR {break}  
{stata "bys foreign: asdoc sum, stat(N mean sd tstat p1 p99)" : bys foreign: asdoc sum, stat(N mean sd tstat p1 p99)} {break} 

{help asdoc##TableConents:Go to Table of Contents}

{marker 3Correlation}

{title:3. CORRELATIONS}

{p 4 4 2} {cmd: asdoc} can create tables almost for all Stata commands related to
correlations such as simple correlations, pairwise and partial correlations, 
interclass correlation, and tetrachoric correlation. The following syntax is 
used for asdoc {help cor} command:

{p 4 4 2} {it: {bf: SYNTAX}}

{p 8 4 2} {cmd: asdoc cor [{help varlist}] {ifin}, [nonum label {opt dec(#)} {help asdoc##asdoc_options:asdoc_options}]}


{p 4 4 2} {cmd: nonum} : By default, asdoc writes the column header as (1), (2), ... (n) while creating a table of correlations.
Option {cmd: nonum} will force asdoc to write variable names as column headers.

{p 4 4 2} {cmd: label} : By default, asdoc writes variable names as the row
headers of the correlation table. Option label can be used to use variable labels
instead of variable names. 

{p 4 4 2} The {opt dec(#)} can be used to specify the number of decimal points to be reported. For example, {opt dec(2)} will
report correlation coefficients with two decimal points.

{p 4 4 2} Other asdoc options are acceptable with correlation commands [See {help asdoc##asdoc_options:Section 1} for more details]. 
Specifically, these options are frequently used with correlation commands: {opt save(filename)}, {opt replace}, {opt append}, {opt dec(#)}, {opt title(table_title)} 
and {opt fs(#)} 


{marker 3_1Simplecor}
{p 4 4 2} {cmd: 3.1 Simple correlations} {break}  
To make a table of correlation, we need to just add asdoc to the beginning of cor command.

{p 4 8 2} {ul on} Example 13 : Correlations among all numeric variables{ul off}{break}
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}  
{stata "asdoc cor" : asdoc cor} {break}  

{p 4 8 2} {ul on} Example 14 : Correlations among selected variables, use variable labels{ul off}{break}
`{break}
{stata "asdoc cor price trunk length weight, replace label" : asdoc cor price trunk length weight, replace label} {break}  

{p 4 8 2} {ul on} Example 15 : Selected variables, write to file corr.doc, table title 'Correlation'{ul off}{break}
`{break}
{stata "asdoc cor price trunk length weight, save(corr.doc) title(Correlation)" : asdoc cor price trunk length weight, save(corr.doc) title(Correlation)} {break}  

{marker 3_2pwcorr}
{p 4 4 2} {cmd: 3.2 Pairwise correlation} {break}  

{p 4 8 2} {ul on} Example 16 : Add significance level to each entry{ul off}{break} 
`{break}
{stata "asdoc pwcorr price headroom mpg displacement, sig" : asdoc pwcorr price headroom mpg displacement, sig} {break}  

{p 4 8 2} {ul on} Example 17 : Add stars to correlations significant at the 1% level after Bonferroni adjustment{ul off}{break}  
`{break}
{stata "asdoc pwcorr price headroom mpg displacement, star(.01) bonferroni" : asdoc pwcorr price headroom mpg displacement, star(.01) bonferroni} {break}  

{marker 3_3PartialCor}
{p 4 4 2} {cmd: 3.3 Partial and semipartial correlations} {break}  

{p 4 8 2} {ul on} Example 18 : Partial and semipartial correlations{ul off}{break} 
`{break}
{stata "asdoc pcorr price mpg weight foreign" : asdoc pcorr price mpg weight foreign} {break}  

{marker 3_4InterclasslCor}
{p 4 4 2} {cmd: 3.4 Intraclass correlation coefficients} {break}  

{p 4 8 2} {ul on} Example 19 : Calculate ICCs for one-way random-effects model{ul off}{break} 
`{break}
{stata "webuse judges" : webuse judges} {break}  
{stata "asdoc icc rating target" : asdoc icc rating target} {break}  

{p 4 8 2} {ul on} Example 20 : Same as above but test whether ICCs equal 0.5{ul off}{break} 
`{break}
{stata "asdoc icc rating target, testvalue(.5)" : asdoc icc rating target, testvalue(.5)} {break}  

{p 4 8 2} {ul on} Example 21 : Calculate ICCs for two-way random-effects model{ul off}{break} 
`{break}
{stata "asdoc icc rating target judge" : asdoc icc rating target judge} {break}  

{marker 3_5TetraCor}
{p 4 4 2} {cmd: 3.5 Tetrachoric correlations for binary variables} {break} 

{p 4 8 2} {ul on} Example 22 :  Correlations produced by tetrachoric{ul off}{break} 
`{break}
{stata " webuse familyvalues" :  webuse familyvalues} {break}  
{stata "asdoc tetrachoric RS074 RS075 RS076" : asdoc tetrachoric RS074 RS075 RS076} {break}  

{marker 3_6Spearman}
{p 4 4 2} {cmd: 3.6 Spearman's and Kendall's correlations} {break} 

{p 4 8 2}  Example{break} 
`{break}
{stata "webuse states2" :  webuse states2} {break}  
{stata "asdoc spearman mrgrate divorce_rate medage" : asdoc spearman mrgrate divorce_rate medage} {break}  


{help asdoc##TableConents:Go to Table of Contents}

{marker 4Regressions}

{title:4. REGRESSIONS}

{p 4 4 2} {cmd: asdoc} can create three types of regression tables. The first type is
the {help asdoc##4_1DetRegression:detailed table} that combines key statistics from the Stata's regression output with some additional statistics such as
mean and standard deviation of the dependent variable etc. This table is the default option in asdoc. 
The second table is the {help asdoc##4_2NestedRegression:nested table} that nests more than one regressions in one table.
The third table is the {help asdoc##WideReg: wide table} that reports regression components in a wide or row format. Since {help asdoc##WideReg: wide table}
offers more than 10 options, it is discussed in {help asdoc##WideReg:this separate section} with relevant examples. The following options are available when exporting 
regression tables with asdoc. 

{p 8 8 2} {cmd: 4.1 }{opt nest:ed}  {break}  
This option invokes the creation of nested regression tables. Without this option, the default (detailed regression) 
table is created by asdoc. 

{p 8 8 2} {opt 4.2 rep({t | se})}  {break}  
This option is used in combination with option {opt nest} for reporting t-values (t) or standard errors (se) with each of the 
regression coefficient. The default for this option is standard errors. Please note that  option {opt rep(t)} will work only 
when used at the start of the nested table. This is the case either (i) when option {opt replace} is used or (ii) the nested table is started
for the first time.

{p 8 8 2} {opt 4.3 append}  {break}  
{opt append} and {opt replace} are alternatives and are optional options. If left blank, option append is assumed, which
will write the results to the existing file.

{p 8 8 2} {opt 4.4} {opt reset}  {break}  
Option {opt reset} causes asdoc to make a new nested table, i.e. instead of appending to the existing nested table,
option reset will start a new table in the existing file. 

{p 8 8 2} {opt 4.5} {opt title(table title)}  {break}  
Option {opt title()} is used to write table title.  For example, {opt title(Table 1 - Fixed effects model)}

{p 8 8 2} {opt 4.6} {opt cnames(Column title)}  {break}  
Option {opt cnames()} is used to write column title while making a nested table. By default, each column
title is named as the name of the dependent variable in nested tables. We can change this name to our desired
name with option cnames, e.g., cnames(OLS) or cnames(FE), etc. 

{p 8 8 2} {opt 4.7} {opt dec(#)}  {break}  
Option {opt dec()} is used to specify the number of decimal points.  For example, {opt dec(3)}

{marker 37add}
{p 8 8 2} {opt 4.8} {opt add(text1, text2 | text3, text4...)} {break}
This option adds text legends to the bottom cells of the nested regression table. This option is usually
used to show the presence or absence of some variables in the respective regression models. For example,
we might include firm, year or industry dummies in a regression model and just indicate with 'yes' or 'no' the 
presence of these dummies. This version of asdoc supports up to a maximum of three categories of legends. The
text legends should be added in pairs of two, each one separated by a comma. For example: {p_end}
{p 12 12 2} 
{opt add(Year dummies, yes)} {break}
{opt add(Year dummies, yes, industry dummies, yes)} {break}
{opt add(Year dummies, yes, industry dummies, yes, country dummies, no)} {break}


{p 8 8 2} {opt 4.9} {opt keep(varlist)} (used only with option {opt nest}){break}
{opt keep(varlist)} and {opt drop(varlist)} are alternatives; they specify coefficients to be included or omitted from the table.  The default is to
display all coefficients.

{p 8 8 2} {opt 4.10} {opt stat(stats from e())} (used only with option {opt nest}){break}
{opt stat()} can be used to report additional regression statistics that are stored in macro e(). For example {break}
{opt stat(rmse, rss)}. Please note that each statistic should be separated by the character comma. Some of the most commonly used {help e()} statistics
of regression models are as follows:

{dlgtab:Statistics}
{p2colset 8 18 19 2}{...}
{p2col : {opt N}} Number of observations. Reported by asdoc as default {p_end}
{p2col : {opt r2}} R-squared. Reported by asdoc as default  {p_end}
{p2col : {opt r2_a}} Adjusted r-squared {p_end}
{p2col : {opt F}} F-statistics {p_end}
{p2col : {opt rmse}} RMSE {p_end}
{p2col : {opt  rss}} Residual sum of squares {p_end}
{p2col : {opt  ll}} Log-likelihood {p_end}
{p2col : {opt chi2}} Chi-square value {p_end}
{hline}

{p 8 8 2} {opt 4.11} {bf: Set custom significance level for stars}{break}
The default significance levels for reporting stars are set at : *** for p-values 
<=0.01; ** for p-values <=0 .05, and * for p-values <=0.1. However, we can 
set our own levels for statistical significance using option {opt setstars()}. An example 
of setstars option looks like:{break}
{opt setstars(***@.01, **@.05, *@.1)}{break}
As we can see from the above line, setstars separates each argument by a comma. 
Each argument has three components. The first component is the symbol (in our case it is {opt *}) 
which will be reported for the given significance level. The second component is
the {opt @} sign that connects the significance level with the symbol. And the third 
component is the value at which the significance level is set. So if we want
to report stars such that

{p 8 8 2}{opt *} for p-value .001 or less{break}
{opt **} for p-value .01 or less{break}
{opt ***} for p-value .05 or less{break}

{p 8 8 2}We shall write the option setstars as{break}

{p 8 8 2}{opt setstars(*@.001, **@.01, ***@.05)}{break}

{p 8 8 2}An example would be:
asdoc reg price mpg rep78 headroom trunk weight length turn , replace setstars(*@.001, **@.01, ***@.05)


{p 8 8 2} {opt 4.12} {bf: Suppressing stars} [used with detailed regression tables]{break}
If we are not interested in reporting significance stars, we can use option {opt nostars} 


{p 8 8 2} {opt 4.13} {bf: Suppressing confidence intervals} [used with detailed regression tables]{break}
If confidence intervals are not needed, we can use option {opt noci} 

{p 8 8 2} {opt 4.14} {bf: Confidence intervals at 99%} [used with detailed regression tables]{break}
asdoc follows the Stata's default to report confidence intervals at 95% level. However, 
one can change the level using the option {opt level(##)}. So to use the cofidence internal at 99%:{break}
`{break}
{stata "sysuse auto, clear" :  sysuse auto, clear} {break}  
{stata "asdoc reg price mpg rep78 headroom, level(99)" : asdoc reg price mpg rep78 headroom,  level(99)} {break}  

{p 8 8 2} {opt 4.15 eform} [exponentiated coefficients]{break}
Option {opt eform} can be used to exponentiate coefficients or convert them to odd ratios in some regressions
such as logit, etc.{break}


{marker 4_1DetRegression}
{title:Examples : Detailed tables}

{p 4 8 2} {ul on} Example 23 :  Single table for each regression (detailed tables) {ul off}{break} 
`{break}
{stata "sysuse auto, clear" :  sysuse auto, clear} {break}  
{stata "asdoc reg price mpg rep78 headroom, save(Table_1.doc)" : asdoc reg price mpg rep78 headroom, save(Table_1.doc)} {break}  

{p 4 8 2} {ul on} Example 24 :  Same as above, table add table title and use option append {ul off}{break} 
`{break}
{stata "sysuse auto, clear" :  sysuse auto, clear} {break}  
{stata "asdoc reg price mpg rep78 headroom, save(Table_1.doc) title(Table 1: Regression results)  append" : asdoc reg price mpg rep78 headroom, title(Table 1: Regression results)  save(Table_1.doc) append} {break}  

{marker 4_2NestedRegression}
{title:Examples : Nested regression tables}

{p 4 8 2} {ul on} Example 25 : Make a nested table of four regressions {ul off}{break} 
`{break}
{stata "sysuse auto, clear" :  sysuse auto, clear} {break}  
{stata "asdoc reg price mpg rep78,  nest replace" : asdoc reg price mpg rep78,  nest replace} {break}  

{p 4 8 2} {ul on} Add variable headroom and then nest with existing table {ul off}{break} 
`{break}
{stata "asdoc reg price mpg rep78 headroom,  nest append" : asdoc reg price mpg rep78 headroom,  nest append} {break}  

{p 4 8 2} {ul on} Add variable weight and then nest with existing table {ul off}{break} 
`{break}
{stata "asdoc reg price mpg rep78 headroom weight,  nest append" : asdoc reg price mpg rep78 headroom weight,  nest append} {break}  

{p 4 8 2} {ul on} Adding text legend with option add(Foreign, yes) and drop the coefficient of foreign from table {ul off}{break} 
`{break}
{stata "asdoc reg price mpg rep78 weight foreign,  nest append add(Foreign dummy, yes) drop(foreign)" : asdoc reg price mpg rep78 weight foreign,  nest append text(Foreign dummy, yes) drop(foreign)} {break}  

{title:Video examples}

{p 4 8 2} Video example of exploring more options of asdoc for reporting regression tables can be accessed at our 
website {browse "www.FinTechProfessor.com": www.FinTechProfessor.com} or at our {browse "https://www.youtube.com/channel/UCXYdNPOmk6BdW1RwrxswLfQ":Youtube channel} 

{marker WideReg}

{title:4.3 Wide Regression tables}: {break}  

{p 4 4 2} Option {opt wide} can be used with regression commands for making wide regression tables.
Such tables can have functional usefulness to accommodate many regressions and can look great. Wide tables can be used in many circumstances; however, I mention one of them
below:  

{p 4 4 2} { bf: Portfolios / industry / country type regressions}. Let's say that we have
20 portfolios and want to regress each portfolio returns on the same risk factors, 
that might include MKTrf, SMB, and HML. The only variable that change in each 
regression is the portfolio returns. These 20 regressions can be aesthetically shown
using wide regression table where each regression is reported in a row. All regressions
are stacked over one another.

{p 4 4 2} The following options are available with the option {opt wide}. 
These options are further explained with the help of examples in the following section.

{p 8 8 2} {help asdoc##wide1:4.3.1. Without reporting t-values or se}  {break}  
{help asdoc##wide1:4.3.2. Reporting t-values / se below the coefficients ({opt t|se(below)})}{break}  
{help asdoc##wide2:4.3.3. Reporting t-values / se side-ways ({opt t|se(side)})}{break} 
{help asdoc##wide3:4.3.3.1 Using bracket / parenthesis around t-values / sd ({opt bracket})}{break} 
{help asdoc##wide4:4.3.3.2 Suppressing the t-values / se text in the header row ({opt notse})}{break} 
{help asdoc##wide5:4.3.4. Reporting stars for significance  ({opt stars})}{break} 
{help asdoc##wide6:4.3.5. Reporting additional regression statistics ({opt stat(stat_options)})} {break}  
{help asdoc##wide7:4.3.6. Suppressing r-squared ({opt nor2})}{break} 
{help asdoc##wide8:4.3.7. Adding customized row headers ({opt add(text)})}{break} 
{help asdoc##wide9:4.3.8. Adding customized column headers ({opt canems(text)})}{break} 
{help asdoc##wide10:4.3.9. Starting a new table within the same file ({opt newtable})} {break}  
{help asdoc##wide11:4.3.10. Ending a table ({opt end})}{break}  
{help asdoc##wide12:4.3.11. Using parenthesis as a text (opt btp)}




{marker wide1}
{p 4 8 2} { bf:4.3.1. Without Reporting t-values or p-values} {break} 

{p 8 8 2} {ul on}Example 26 : Default output style for wide regressions {ul off}{break} 

{p 8 8 2} {stata "sysuse auto" : sysuse auto} {break}  
{stata "asdoc reg price mpg rep78, wide replace" : asdoc reg price mpg rep78, replace wide } {break}  

{p 8 8 2} Add another regression where the dependent variable is trunk {break}  
{stata "asdoc reg trunk mpg rep78, wide" : asdoc reg trunk mpg rep78, wide} {break}  

{p 8 8 2} Add third regression where the dependent variable is weight {break}  
{stata "asdoc reg weight mpg rep78, wide" : asdoc reg weight mpg rep78, wide} {break}  


{marker wide2}
{p 4 4 2} { bf:4.3.2. Reporting se / t-values below coefficients}

{p 8 8 2} {ul on}Example 27 {ul off}{break} 

{p 8 8 2} {stata "sysuse auto" : sysuse auto} {break}  
{stata "asdoc reg price mpg rep78, wide t(below) replace" : asdoc reg price mpg rep78, wide replace t(below)} {break}  

{p 8 8 2} Add another regression where the dependent variable is trunk {break}  
{stata "asdoc reg trunk mpg rep78, wide t(below)" : asdoc reg trunk mpg rep78, wide t(below)} {break}  

{p 8 8 2} Add third regression where the dependent variable is weight {break}  
{stata "asdoc reg weight mpg rep78, wide t(below)" : asdoc reg weight mpg rep78, wide t(below)} {break}  

{p 4 8 2}  Note: we can report standard errors (se) instead of t-values by replacing {it: t(below)} with {it: se(below)} in the above examples. 

{marker wide3}
{p 4 4 2} { bf:4.3.3. Reporting se / t-values side-ways}

{p 8 8 2} {ul on}Example 28 {ul off}{break} 

{p 8 8 2} {stata "sysuse auto" : sysuse auto} {break}  
{stata "asdoc reg price mpg rep78, wide t(side) replace" : asdoc reg price mpg rep78, wide replace t(side)} {break}  

{p 8 8 2} Add another regression where the dependent variable is trunk {break}  
{stata "asdoc reg trunk mpg rep78, wide t(side)" : asdoc reg trunk mpg rep78, wide t(side)} {break}  

{p 8 8 2} Add third regression where the dependent variable is weight {break}  
{stata "asdoc reg weight mpg rep78, wide t(side)" : asdoc reg weight mpg rep78, wide t(side)} {break}  

{p 8 8 2}  Note: we can report standard errors (se) instead of t-values by replacing {it: t(side)} with {it: se(side)} in the above examples. 

{marker wide31}
{p 8 8 2} { bf:4.3.3.1 Option {it:bracket}}{break}  
The default is to use parenthesis around standard errors / t-values. However, 
we can use option {opt bracket} to use square bracket around these values.

{marker wide32}
{p 8 8 2} { bf:4.3.3.2 Option {it:notse}}{break}  
The default is to report {it: t-values} or {it: se} text in each alternate row when option {opt t(below)} or {opt se(below)} is used.
This text can be suppressed with option {opt notse}. 

{marker wide4}
{p 4 8 2} { bf: 4.3.4. Reporting stars for significance} {break} 

{p 8 8 2}Option {opt stars} adds asterisks with regression coefficients such that {bf:***} are added
for {bf:1%}, {bf:**} for {bf:5%}, and {bf:*} for {bf:10%} level of significance. 

{p 8 8 2} {ul on}Example 29 {ul off}{break} 

{p 8 8 2} {stata "sysuse auto" : sysuse auto} {break}  
{stata "asdoc reg price mpg rep78, wide replace stars" : asdoc reg price mpg rep78, wide replace stars  } {break}  

{p 8 8 2} Add another regression where the dependent variable is trunk {break}  
{stata "asdoc reg trunk mpg rep78, wide stars" : asdoc reg trunk mpg rep78, wide stars} {break}  


{marker wide5}
{p 4 8 2} { bf:4.3.5. Reporting Additional regression statistics} {break}
Option {opt stat()} can be used to report additional regression statistics that are stored in macro help {help e()}}.
For example, to report RMSE and RSS of a regression, we shall add option {opt stat(rmse, rss)}. Some of the most commonly used {help e()} statistics
of regression models are as follows. Please note that any other statistics from macro e() can be reported in addition to the following.

{dlgtab:Additional regression statistics to report}

{p2colset 8 18 19 2}{...}
{p2col : {opt N}} Number of observations. Reported by asdoc as default {p_end}
{p2col : {opt r2}} R-squared. Reported by asdoc as default  {p_end}
{p2col : {opt r2_a}} Adjusted r-squared {p_end}
{p2col : {opt F}} F-statistics {p_end}
{p2col : {opt rmse}} RMSE {p_end}
{p2col : {opt  rss}} Residual sum of squares {p_end}
{p2col : {opt  ll}} Log-likelihood {p_end}
{p2col : {opt chi2}} Chi-square value {p_end}
{hline}



{p 4 8 2} { bf:Report N, adjusted R2, and RMSE}{break}  

{p 8 8 2} {ul on}Example 30 {ul off}{break} 

{p 8 8 2}{stata "asdoc reg price mpg rep78, wide  stat(N rmse r2_a) replace" : asdoc reg price mpg rep78, wide  stat(N rmse r2_a) replace}

{marker wide6}
{p 4 8 2} {bf:4.3.6. Suppressing R2} {break}

{p 8 8 2}With option wide, the r-squared (R2) is reported by default. However, it can be
suppressed by option {opt nor2}. For example:

{p 8 8 2} {ul on}Example 31 {ul off}{break} 

{p 8 8 2}{stata "asdoc reg price mpg rep78, wide  nor2 replace" : asdoc reg price mpg rep78, wide  nor2 replace}

{marker wide7}
{p 4 8 2} { bf: 4.3.7. Adding customized row text} {break} 

{p 8 8 2}Option {opt add(text)} can be used to specify the text that appears in the first cell of each row. 
By default, asdoc reports name of the dependent variable in the first cell of each row.  See the following examples where the
dependent variables are {it:price} and {it:trunk} in the two regressions, respectively. We shall report the text {it: Regression 1} and {it: Regression 2} instead.

{p 8 8 2} {ul on}Example 32 {ul off}{break} 

{p 8 8 2} {stata "sysuse auto" : sysuse auto} {break}  
{stata "asdoc reg price mpg rep78, wide replace add(Regression 1)" : asdoc reg price mpg rep78, wide replace add(Regression 1)  } {break}  

{p 8 8 2} Add another regression where dependent variable is trunk {break}  
{stata "asdoc reg trunk mpg rep78, wide add(Regression 2)" : asdoc reg trunk mpg rep78, wide add(Regression 2)} {break}  


{marker wide8}
{p 4 8 2} { bf: 4.3.8. Adding customized column text} {break} 

{p 8 8 2}Option {opt cnames(text)} can be used to specify the text that appears in the header column. 
By default, asdoc reports name of the independent variable in the header column.  If we were to use a different text, we shall use option cnames(text1 text2 ...).
For example{break}
{stata "asdoc reg price, wide cnames(Abnormal_ret)" : asdoc reg price, wide cnames(Abnormal_ret)} {break}  

{marker wide9}
{p 4 8 2} { bf: 4.3.9. Starting a new table within the same file} {break} 

{p 8 8 2} Using option {opt newtable}, we can start a new table within the existing file. So let us write two regressions to Table 1 and two more regressions to Table 2 in the same
file. 

{p 8 8 2} {ul on}Example 33 {ul off}{break} 

{p 8 8 2} {stata "sysuse auto" : sysuse auto} {break}  
{stata "asdoc reg price mpg rep78, wide replace" : asdoc reg price mpg rep78, wide replace} {break}  
{stata "asdoc reg trunk mpg rep78, wide " : asdoc reg trunk mpg rep78, wide } {break}  


{p 4 8 2} Start a new table within the same file, this time we are not using option {opt replace}. Please note the first line that works as a title for the new table. 
The option {opt fs(14)} actually makes the font size bigger than the normal text, that has a default value of 10. Please also
note the RTF control word {bf:\par} at end of the sentence, that marks a new paragraph in the document and ends the previously started table.{break}  

{p 8 8 2} {ul on}Example 34 {ul off}{break} 
{stata "asdoc, text(My New Table \par) fs(14)" : asdoc, text(My New Table \par) fs(14)} {break}  
{stata "asdoc reg length mpg rep78, wide newtable" : asdoc reg length mpg rep78, wide newtable} {break}  
{stata "asdoc reg trunk mpg rep78, wide " : asdoc reg trunk mpg rep78, wide } {break}  

{marker wide10}
{p 4 8 2} { bf: 4.3.10. Ending a table} {break} 
Using option {opt end}, asdoc will add the following text after the last row of the table. {break}
a. If option {opt t()} is used, then the text "{hi:{it:t-statistics are parentheses}}" will be added. {break}
b. If option {opt se()} is used, then the text "{hi:{it:Standard errors are in parentheses}}  will be added." {break}
c. If option {opt stars} is used, then the text "{hi:{it:*** p<0.01, ** p<0.05, * p<0.1}}  will be added." {break}
If option {opt end} is not used, asdoc will still report complete table, however, the above text will not be added to the end of the table.

{marker wide11}
{p 4 8 2} { bf:4.3.11. Using parenthesis as a text with option {opt btp}} {break}
Since asdoc uses parenthesis "()" as parsing characters, it can be tricky to use them as simple text.
Option {opt btp} allows converting square brackets to parentheses when they are written to the Word file.
For example, if we use option {opt add(text)} and use parenthesis inside this option, this will confuse the parsing process. 
Therefore, we shall play a trick to first use square brackets in the text and then convert them back to parentheses. Therefore, if we write the text 

{p 8 8 2} {ul on}Example 35 {ul off}{break} 

{p 8 8 2} {stata "asdoc reg mpg price trunk, wide add(Millege[mpg]) replace btp" : asdoc reg mpg price trunk, wide add(Millege[mpg]) replace btp}

{p 8 8 2} The Word file will contain text {bf:Millege(mpg)} in the first cell of the first row, instead of {bf:Millege[mpg]}. This
option also works with option {help asdoc##text:text}. 




{help asdoc##TableConents:Go to Table of Contents}


{marker Byreg}

{title:4.4 Regression over groups using the {it:bysort} prefix} {break}  

{p 4 4 2} In version 2.0 of asdoc, I have worked on the {help bysort} functionality
to work with all types of regression  tables i.e. 
{help asdoc##4_1DetRegression:detailed regressions}, 
{help asdoc##4_2NestedRegression: nested regressions}, and
{help asdoc##WideReg: wide regression} tables. Following are few examples to
show the basic syntax:

{p 4 4 2} {cmd: Example dataset} : Let us
use the {it: grunfeld} panel dataset. It has 10 companies 
identified by the grouping variable {it: companies} and has 20 years of data
for each company. We shall run a regression separately for each company
and write the results to {bf: MyFile.doc}. 


{p 4 8 2} {ul on} Example 36 : Detailed regression table  {ul off}{break} 
`{break}
{stata "webuse grunfeld, clear" :  webuse grunfeld, clear} {break}  
{stata "bys company: asdoc reg invest mvalue kstock, replace" : bys company: asdoc reg invest mvalue kstock, replace } {break}


{p 4 8 2} {ul on} Example 37 : Nested regression table  {ul off}{break} 
`{break}
{stata "bys company: asdoc reg invest mvalue kstock, nested replace" : bys company: asdoc reg invest mvalue kstock, nested replace } {break}


{p 4 8 2} {ul on} Example 38 : Wide regression table  {ul off}{break} 
`{break}
{stata "bys company: asdoc reg invest mvalue kstock, wide replace" : bys company: asdoc reg invest mvalue kstock, wide replace } {break}


{help asdoc##TableConents:Go to Table of Contents}

{marker 5Freq}

{title:5. FREQUENCY TABLES}

{p 4 4 2} As with other commands, we need to just add asdoc as a prefix to the tabulation commands that includes tabulate, tabulate1 tabulate2, tab1, tab2, etc.
Since frequency tables in Stata can assume different structures, asdoc writes these tables from log files. We can use the following options of asdoc to control asdoc behavior.
(1){help asdoc##1_1replace: replace / append} (2) {help asdoc##1_2save: save(filename)} (3) {help asdoc##1_3title: title(text)} 
(4){help asdoc##1_4fs: fs(#)} (5) {help asdoc##1_7hide:hide}. These options
are discussed in detail in {help asdoc##asdoc_options: Section 1.}

{marker 5_1Freq}
{p 4 4 2} {cmd: 5.1 One-way table} {break}  

{p 4 8 2} asdoc generally follows the syntax structure and options of the tab command. 
Yet, asdoc offers one additional option (the option is { opt nocf}) of suppressing the cumulative 
frequencies' column of the tab command. {break} 

{p 4 8 2} {ul on} Example 39 :  One-way table {ul off}{break} 
`{break}
{stata "sysuse auto, clear" :  sysuse auto, clear} {break}  
{stata "asdoc tabulate rep78, replace " : asdoc tabulate rep78, replace } {break}

{p 4 4 2} Please note that replace is asdoc option to replace the existing file.{p_end}
{p 4 8 2}If we were to write to the existing file, we would then use option append, instead of replace.{break} 

{p 4 8 2} {ul on} Example 39.1 :  One-way table with no cumulative frequencies {ul off}{break} 
`{break}
{stata "asdoc tabulate rep78, replace nocf " : asdoc tabulate rep78, replace nocf } {break}

{p 4 8 2} {cmd: 5.2 Two-way table of frequencies} {break} 

{p 4 8 2} {ul on} Example 40 : Two-way table of frequencies {ul off}{break} 
`{break}
{stata "webuse citytemp2, clear" :  webuse citytemp2, clear} {break}  
{stata "asdoc tabulate region agecat, replace  " : asdoc tabulate region agecat, replace } {break}

{p 4 8 2} {ul on} Example 41 : Include row percentages {ul off}{break} 
`{break}
{stata "asdoc tabulate region agecat, row replace nokey" : asdoc tabulate region agecat , nokey row replace } {p_end}
{p 4 8 2} {bf:Note} {it:nokey} suppresses the display of a key above two-way tables.

{p 4 8 2} {ul on} Example 42 : Include column percentages {ul off}{break} 
`{break}
{stata "asdoc tabulate region agecat, column nokey replace" : asdoc tabulate region agecat , nokey column replace } {break}

{p 4 8 2} {ul on} Example 43 : Include row percentages, suppress frequency counts {ul off}{break} 
`{break}
{stata "asdoc tabulate region agecat, row nofreq nokey replace" : asdoc tabulate region agecat, nokey row nofreq replace } {break}

{marker 5_3tabsum}
{p 4 4 2} {cmd: 5.3 One- and two-way tables of summary statistics} {break} 

{p 4 8 2} {ul on} Example 44 : One-way tabulation with summary statistics {ul off}{break} 
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}
{stata "asdoc tabulate rep78, summarize(mpg) replace" : asdoc tabulate rep78, summarize(mpg) replace} {break}

{p 4 8 2} {ul on} Example 45 : Two variables tabulation with summary statistics {ul off}{break} 
`{break}
{stata "generate wgtcat = autocode(weight, 4, 1760, 4840)" :  generate wgtcat = autocode(weight, 4, 1760, 4840)} {break}  
{stata "asdoc tabulate wgtcat foreign, summarize(mpg) replace" : asdoc tabulate wgtcat foreign, summarize(mpg) replace} {break}

{p 4 8 2} {ul on} Example 46 : Suppress frequencies {ul off}{break} 
`{break}
{stata "asdoc tabulate wgtcat foreign, summarize(mpg) nofreq replace" : asdoc tabulate wgtcat foreign, summarize(mpg) nofreq replace} {break}


{marker 5_4tab1}
{p 4 4 2} {cmd: 5.4 Multiple-way tabulation (tab1)} {break} 
{help tab1} produces a one-way tabulation for each variable specified in varlist. 

{p 4 8 2} {ul on} Example 47 : Multiple-way tabulation {ul off}{break} 
`{break}
{stata "sysuse nlsw88, clear" : sysuse nlsw88, clear} {break}
{stata "asdoc tab1 race married grade, replace" : asdoc tab1 race married grade, replace} {break}

{marker 5_5tab2}
{p 4 4 2} {cmd: 5.5 Two-way for all possible combinations (tab2)} {break} 

{p 4 8 2} {ul on} Example 48 : Two variables tabulation with summary statistics {ul off}{break} 
`{break}
{stata "asdoc tab2 race south, replace" : asdoc tab2 race south, replace} {break}

{help asdoc##TableConents:Go to Table of Contents}

{marker 6tabstat}

{title:6. COMPACT TABLES (TABSTAT)}

{p 4 4 2}asdoc makes some elegant tables when used with tabstat command. There are several
custom-made routines in asdoc that create clean tables from tabstat command. 
asdoc fully supports the tabstat command structure and its options. And, yes
asdoc allows one additional statistics, that is, t-statistics alongside the
allowed statistics in tabstat. For reporting purposes, asdoc categorizes
tabstat commands in two groups: (1) stats without a grouping variable (2) stats over a grouping variable.

{marker 61}
{p 4 4 2} {cmd: 6.1 Tabstat Without-by} {break} 

If statistics are less than variables, the table is transposed, i.e. statistics are shown in columns, while variables are shown in rows

{p 4 8 2} {ul on} Example 49 : One variable, many stats, including t-statistics {ul off}{break} 
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}
{stata "asdoc tabstat price , stat(min max mean sd median p1 p99 tstat) replace" :  asdoc tabstat price , stat(min max mean sd median p1 p99 tstat) replace}

{p 4 8 2} {ul on} Example 50 : Many variables, one statistic{ul off}{break} 
`{break}
{stata "asdoc tabstat price mpg rep78 headroom trunk weight length foreign , stat( mean) replace" :  asdoc tabstat price mpg rep78 headroom trunk weight length foreign , stat( mean) replace}

{p 4 8 2} {ul on} Example 51 : Many variables, many statistics{ul off}{break} 
`{break}
{stata "asdoc tabstat price mpg rep78 headroom trunk weight length foreign , stat(max mean sd median p1 p99 tstat) replace":  asdoc tabstat price mpg rep78 headroom trunk weight length foreign , stat( max mean sd median p1 p99 tstat) replace}


{marker 62}
{p 4 8 2} {cmd: 6.2 Tabstat with-by} {break} 

{p 4 8 2} {ul on} Example 52 :{ul off}{break} 
`{break}
{stata "bysort foreign: asdoc tabstat price mpg rep78 headroom trunk weight length, stat(mean) replace": bysort foreign: asdoc tabstat price mpg rep78 headroom trunk weight length, stat(mean) replace}
{break} OR {break} 
{stata "asdoc tabstat price mpg rep78 headroom trunk weight length, stat(mean) by(foreign) replace" : asdoc tabstat price mpg rep78 headroom trunk weight length, stat(mean) by(foreign) replace}

{p 4 8 2} {ul on} Example 53 : By with many variables and many statistics{ul off}{break} 
`{break}
{stata "bysort foreign: asdoc tabstat price mpg rep78 headroom trunk weight length, stat(mean sd p1 p99 tstat) replace": bysort foreign: asdoc tabstat price mpg rep78 headroom trunk weight length, stat(mean sd p1 p99 tstat) replace}

{help asdoc##TableConents:Go to Table of Contents}


{marker 7flextable}
{title:7. FLEXIBLE TABLE OF SUMMARY STATS (TABLE)}

{p 4 4 2} Exporting tables from {help table} command was the most challenging part in asdoc
programming. Nevertheless, asdoc does a pretty good job in exporting table from table
command. asdoc accepts almost options with table command, except cellwidth(#), stubwidth(#),
and  csepwidth(#). 

{marker 71}
{p 4 8 2} {cmd: 7.1 One-way table} {break} 

{p 4 8 2} {ul on} Example 54 : One-way table; frequencies shown by default{ul off}{break} 
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}
{stata "asdoc table rep78, title(Table of Freq. for Repair) replace": asdoc table rep78, title(Table of Freq. for Repairs) replace} {break}

{p 4 8 2} {ul on} Example 55 : One-way table; show count of non-missing observations for mpg}{ul off}{break}
`{break}
{stata "asdoc table rep78, contents(n mpg) replace" : asdoc table rep78, contents(n mpg) replace}


{p 4 8 2} {ul on} Example 56 : One-way table; multiple statistics on mpg requested{ul off}{break}
`{break}
{stata "asdoc table rep78, c(n mpg mean mpg sd mpg median mpg) replace" : asdoc table rep78, c(n mpg mean mpg sd mpg median mpg) replace}


{p 4 8 2} {ul on} Example 57 : Add formatting{ul off}{break}
`{break}
{stata "asdoc table rep78, c(n mpg mean mpg sd mpg median mpg) format(%9.2f) replace" : asdoc table rep78, c(n mpg mean mpg sd mpg median mpg) format(%9.2f) replace}

{marker 72}
{p 4 8 2} {cmd: 7.2 Two-way table} {break} 

{p 4 8 2} {ul on} Example 58 : Two-way table; frequencies shown by default{ul off}{break}
`{break}
{stata "asdoc table rep78 foreign, replace" : asdoc table rep78 foreign, replace}

{p 4 8 2} {ul on} Example 59 : Two-way table; show means of mpg for each cell{ul off}{break}
`{break}
{stata "asdoc table  rep78 foreign, c(mean mpg) replace" : asdoc table  rep78 foreign, c(mean mpg) replace}


{p 4 8 2} {ul on} Example 60 : Add formatting{ul off}{break}
`{break}
{stata "asdoc table rep78 foreign, c(mean mpg) format(%9.2f) center replace" : asdoc table rep78 foreign, c(mean mpg) format(%9.2f) center replace}


{p 4 8 2} {ul on} Example 61 : Add row and column totals{ul off}{break}
`{break}
{stata "asdoc table rep78 foreign, c(mean mpg) format(%9.2f) center row col replace" : asdoc table rep78 foreign, c(mean mpg) format(%9.2f) center row col replace}

{marker 73}
{p 4 8 2} {cmd: 7.3 Three-way table} {break} 

{p 4 8 2} {ul on} Example 62 : Three-way table{ul off}{break} 
`{break}
{stata "webuse byssin, clear" : webuse byssin, clear} {break}
{stata "asdoc table workplace smokes race [fw=pop], c(mean prob) replace": asdoc table workplace smokes race [fw=pop], c(mean prob) replace} {break}

{p 4 8 2} {ul on} Example 63 : Add formatting{ul off}{break}
`{break}
{stata "asdoc table workplace smokes race [fw=pop], c(mean prob) format(%9.3f) replace": asdoc table workplace smokes race [fw=pop], c(mean prob) format(%9.3f) replace} {break}


{p 4 8 2} {ul on} Example 64 : Request supercolumn totals{ul off}{break}
`{break}
{stata "asdoc table workplace smokes race [fw=pop], c(mean prob) format(%9.3f) sc replace": asdoc table workplace smokes race [fw=pop], c(mean prob) format(%9.3f) sc replace} {break}


{marker 74}
{p 4 8 2} {cmd:7.4 Four-way table} {break} 

{p 4 8 2} {ul on} Example 65 : Four-way table{ul off}{break} 
`{break}
{stata "webuse byssin1, clear" : webuse byssin1, clear} {break}
{stata "asdoc table workplace smokes race [fw=pop], by(sex) c(mean prob) format(%9.3f) replace": asdoc table workplace smokes race [fw=pop], by(sex) c(mean prob) format(%9.3f) replace} {break}


{p 4 8 2} {ul on} Example 66 : Four-way table with supercolumn, row, and column totals{ul off}{break} 
`{break}
{stata "asdoc table workplace smokes race [fw=pop], by(sex) c(mean prob) format(%9.3f) sc col row replace": asdoc table workplace smokes race [fw=pop], by(sex) c(mean prob) format(%9.3f) sc col row replace} {break}

{help asdoc##TableConents:Go to Table of Contents}

{marker 8ttest}
{title:8. T-TESTS (TTEST)}

{p 4 4 2} The primary challenge in reporting results of the {help ttest} command is 
what statistics to report and in which format to report. The format should be such that
it occupies minimum space possible. Over many other possibilities, I preferred the
format of a single line for all types of t-tests. Therefore, whether it is one-sample
t-test or two-sample or other forms, asdoc manages to report the results line by line
for each test. asdoc also allows accumulating results from different runs of t-tests. 
For this purpose, the option {help asdoc##rowappend:rowappend} of asdoc really comes handy. 
With {help ttest} command, we can use the following options of asdoc to control asdoc behavior.
(1){help asdoc##1_1replace: replace / append} (2) {help asdoc##1_2save: save(filename)} (3) {help asdoc##1_3title: title(text)} 
(4){help asdoc##1_4fs: fs(#)} (5) {help asdoc##1_7hide:hide}. (6) {help asdoc##stattest: stats()} (7) {help asdoc##rowappned:rowappend}. These options
are discussed in detail in {help asdoc##asdoc_options: Section 1.}. Option stats and rowappend are discussed below:

{marker stattest}
{p 8 8 2}{opt 6.}{opt stat(mean se df obs t p sd dif)} : Without stat() option, asdoc reports 
number of observations (obs), mean, standard error, t-value, and p-value with t-tests.
However, you can select all or few statistics using the stat option. 

{dlgtab:Statistics}
{p2colset 8 16 19 2}{...}
{p2col : {opt n}} Number of observations{p_end}
{p2col : {opt mean}} Arithmetic mean {p_end}
{p2col : {opt se}} Standard error {p_end}
{p2col : {opt  df}} degrees of freedom {p_end}
{p2col : {opt  obs}} Number of observations {p_end}
{p2col : {opt t}} t-value {p_end}
{p2col : {opt p}} p-value  {p_end}
{p2col : {opt sd}} standard deviation {p_end}
{p2col : {opt dif}} difference in means if two-sample t-test {p_end}

{marker rowappned}
{p 8 8 2}{cmd:7. rowappned} : ttest tables can be constructed in steps by adding results
of different t-tests to an existing table one by one using option {opt rowappend}. There is only
one limitation that the t-tests are performed and asdoc command applied without writing
any other results to the file in-between.  See the following example:

{marker 81}
{p 4 8 2} {cmd:8.1 One-sampel t-test} {break} 

{marker example53}
{p 4 8 2} {ul on} Example 67 : Appending t-test results with rowappend option{ul off}{break} 
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}
{stata "asdoc ttest rep78==0, replace title(T-test results : H1: mean = 0)": asdoc ttest rep78==0, replace title(T-test results : mean == 0)} {break}
{stata "asdoc ttest price==0, rowappend": asdoc ttest price==0, rowappend} {break}
{stata "asdoc ttest mpg==0, rowappend": asdoc ttest mpg==0, rowappend} {break}
{stata "asdoc ttest turn==0, rowappend": asdoc ttest turn==0, rowappend} {break}
{stata "asdoc ttest weight==0, rowappend": asdoc ttest weight==0, rowappend} {break}
{stata "asdoc ttest length==0, rowappend": asdoc ttest length==0, rowappend} {break}


{p 4 8 2} {ul on} Example 68 : Repeat the above tests, requesting specific statistics{ul off}{break} 
{stata "sysuse auto, clear" : sysuse auto, clear} {break}
{stata "asdoc ttest rep78==0, replace title(T-test results : H1: mean = 0) stat(obs mean se df t)": asdoc ttest rep78==0, replace title(T-test results : mean == 0) stat(obs mean se df t)} {break}
{stata "asdoc ttest price==0, rowappend stat(obs mean se df t)": asdoc ttest price==0, rowappend stat(obs mean se df t)} {break}
{stata "asdoc ttest mpg==0, rowappend stat(obs mean se df t)": asdoc ttest mpg==0, rowappend stat(obs mean se df t)} {break}
{stata "asdoc ttest turn==0, rowappend stat(obs mean se df t)": asdoc ttest turn==0, rowappend stat(obs mean se df t)} {break}
{stata "asdoc ttest weight==0, rowappend stat(obs mean se df t)": asdoc ttest weight==0, rowappend stat(obs mean se df t)} {break}
{stata "asdoc ttest length==0, rowappend stat(obs mean se df t)": asdoc ttest length==0, rowappend stat(obs mean se df t)} {break}

{marker 82}
{p 4 8 2} {cmd:8.2 Two-sample t-test using groups i.e. with option the by()} {break} 

{p 4 8 2} {ul on} Example 69: Two-sample t-test using groups i.e. with the option by() {ul off}{break} 
`{break}
{stata "asdoc ttest mpg, by(foreign) replace" : asdoc ttest mpg, by(foreign) replace}

{marker 83}
{p 4 8 2} {cmd:8.3 Two-sample t-test using variables} {break} 

{p 4 8 2} {ul on} Example 70: Two-sample t-tes using variables {ul off}{break} 
`{break}
{stata "asdoc ttest mpg==price, replace" : asdoc ttest mpg==price,  replace}{break} 

{p 4 8 2} And to add similar tests to the same table, we can use rowappend

{p 4 8 2} {ul on} Example 71: append more tests {ul off}{break} 
`{break}
{stata "asdoc ttest trunk==price, rowappend" : asdoc ttest trunk==price, rowappend}

{marker 84}
{p 4 8 2} {cmd:8.4 Two sample test over groups} {break} 

{p 4 8 2} {ul on} Example 72: Two sample test over groups {ul off}{break} 
`{break}
{stata "bysort foreign: asdoc ttest mpg == price , replace" : bysort foreign: asdoc ttest mpg == price, replace}

{help asdoc##TableConents:Go to Table of Contents}

{marker 9tmeans}
{title:9. TABLE OF MEANS (TABSUM)}
{p 4 8 2} The {help tabsum} can be implemented using tabulate command. Therefore, 
see sub-section {help asdoc##5_3tabsum:5.3 tabsum} for more details.

{marker 10means}
{title:10. MEANS, PROPORTIONS, RATIO, TOTAL} {marker 101}

{p 4 8 2} {ul on} Example 73: Arithmetic, geometric, and harmonic means{ul off}{break} 
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}
{stata "asdoc ameans price trunk, replace" :asdoc ameans price trunk, replace} {break}

{marker 102}
{p 4 8 2} {ul on} Example 74: Proportions{ul off}{break} 
`{break}
{stata "asdoc  proportion rep78, replace" :asdoc  proportion rep78, replace} {break}

{p 4 8 2} {ul on} Example 75: Estimate proportions over values of foreign{ul off}{break} 
`{break}
{stata "asdoc  proportion rep78, over(foreign) replace" :asdoc  proportion rep78, over(foreign) replace} {break}

{marker 103}
{p 4 8 2} {ul on} Example 76:  Estimate ratio of mpg1 to mpg2{ul off}{break} 
`{break}
{stata "webuse fuel, clear" : webuse fuel, clear} {break}
{stata "asdoc  ratio mpg1/mpg2, replace" :asdoc  ratio mpg1/mpg2, replace} {break}

{p 4 8 2} {ul on} Example 77: Estimate ratio of death to pop and ratio of marriage to pop{ul off}{break} 
`{break}
{stata "webuse census2, clear" : webuse census2, clear} {break}
{stata "asdoc ratio ( death/pop) ( marriage/pop), replace" :asdoc ratio ( death/pop) ( marriage/pop), replace} {break}
Please note that the use of the colon is not allowed as asdoc uses color for parsing bysort prefix.

{marker 104}
{p 4 8 2} {ul on} Example 78: Estimate totals over values of sex, using swgt as pweights {ul off}{break} 
`{break}
{stata "webuse census2, clear" : webuse census2, clear} {break}
{stata "asdoc ratio (death/pop) (marriage/pop), replace" :asdoc ratio ( death/pop) ( marriage/pop), replace} {break}

{marker list}
{title:11. EXPORTING DATASET (LIST)}

{p 4 4 2} Stata's {help list} command displays the values of variables. asdoc can
export these values to a file in form of a nicely formatted table. asdoc implements
the most basic version of list command and might not accept some of its options such 
as mean, sum, etc. However, the {ifin} qualifiers are accepted. 

{p 4 8 2} {ul on} Example 79: List and export values of varlist for first 10 observations{ul off}{break} 
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}
{stata "asdoc list price trunk mpg turn in 1/10 , replace" :asdoc list price trunk mpg turn in 1/10 , replace} {break}

{p 4 8 2} {ul on} Example 80: List and export values all variables if foregin==1{ul off}{break} 
`{break}
{stata "asdoc list if foreign==1, replace" :asdoc  list if foreign==1, replace} {break}


{marker matrix}
{title:12. EXPORTING A MATRIX}

{p 4 4 2} asdoc can export a Stata's matrix to a file in form of a nicely formatted table. 
The syntax is given below :

{p 4 4 2} {cmd:asdoc wmat}, {opt mat:rix(matrix_name)} [{opt rnames(row names)} {opt cnames(column names)} replace append other_options] 

{p 4 4 2} {hi: Description} : {cmd: wmat} is the command name - an abbreviation for
{it:writing matrix}. Option {opt mat:rix()} is a required option to get name of an existing matrix.
Option {opt rnames()} and {opt cnames()} are optional options to specify row names 
and column names of the matrix. If these options are left blank, existing row and column names
of the matrix are used. Other options of asdoc can also be used with {cmd: wmat}. For example, 
{cmd: replace} will replace an existing output file, while {cmd:append} will append to the existing  file. 
{cmd:fs()} sets the font size, while option {opt title()} can be used to specify title of the matrix in
the output file.

{p 4 8 2} {ul on} Example 81: Make a matrix of uniform numbers{ul off}{break} 
`{break}
{stata "mat A = matuniform(10, 5)" : mat A = matuniform(10, 5)} {break}

{p 4 8 2} {ul on} Example 82: Write matrix to file{ul off}{break} 
`{break}
{stata "asdoc wmat, mat(A) replace" : asdoc wmat, mat(A) replace} {break}

{p 4 8 2} {ul on} Example 83: Append another matrix to existing file, with custom column and row names{ul off}{break} 
`{break}
{stata "mat B = matuniform(4, 6)" : mat B = matuniform(4, 6)} {break}
{stata "asdoc wmat, mat(B) append rnames(Sugar Honey Muffin Pie) cnames(Chili Diablo Pepper Capsicum Kambuzi Malagueta)"  : asdoc wmat, mat(B) append rnames(Sugar Honey Muffin Pie) cnames(Chili Diablo Pepper Capsicum Kambuzi Malagueta)}


{marker svy}
{title:13. The survey prefix command}

{p 4 4 2} asdoc can also work with the survey prefix command {help svy}. Just like with other Stata commands, the word
{bf:asdoc} needs to be added before the {bf:svy:} prefix. See the following examples:

{p 4 8 2} {ul on} Example 84: svy: mean {ul off}{break} 
`{break}
{stata "webuse nhanes2f, clear" : webuse nhanes2f, clear} {break}
{stata "svyset psuid [pweight=finalwgt], strata(stratid)" : svyset psuid [pweight=finalwgt], strata(stratid)}{break} 
{stata "asdoc svy: mean zinc" : asdoc svy: mean zinc} {break}

{p 4 8 2} {ul on} Example 85: svy: regress {ul off}{break} 
`{break}
{stata "webuse nhanes2f, clear" : webuse nhanes2f, clear} {break}
{stata "svyset psuid [pweight=finalwgt], strata(stratid)" : svyset psuid [pweight=finalwgt], strata(stratid)}{break} 
{stata "asdoc svy: regress zinc age age2 weight female black orace rural, replace" : asdoc svy: regress zinc age age2 weight female black orace rural, replace} {break}


{p 4 8 2} {ul on} Example 86: If we were to nest svy: regressions {ul off}{break} 
`{break}
{stata "webuse nhanes2f, clear" : webuse nhanes2f, clear} {break}
{stata "svyset psuid [pweight=finalwgt], strata(stratid)" : svyset psuid [pweight=finalwgt], strata(stratid)}{break} 
{stata "asdoc svy: regress zinc age age2 weight female black orace rural, replace nest" : asdoc svy: regress zinc age age2 weight female black orace rural, replace nest} {break}


{p 4 8 2} {ul on} Example 87: If we were to nest svy: regressions {ul off}{break} 
`{break}
{stata "webuse nhanes2f, clear" : webuse nhanes2f, clear} {break}
{stata "svyset psuid [pweight=finalwgt], strata(stratid)" : svyset psuid [pweight=finalwgt], strata(stratid)}{break} 
{stata "asdoc svy: regress zinc age age2 weight female black orace rural, replace nest" : asdoc svy: regress zinc age age2 weight female black orace rural, replace nest} {break}
{stata "asdoc svy: regress zinc age age2 weight female black  , append nest" : asdoc svy: regress zinc age age2 weight female black  , append nest} {break}
{stata "asdoc svy: regress zinc age age2 weight female  , append nest" : asdoc svy: regress zinc age age2 weight female   , append nest} {break}


{p 4 8 2} {ul on} Example 88: Report additional regression statistics from macro e() {ul off}{break} 
`{break}
{stata "webuse nhanes2f, clear" : webuse nhanes2f, clear} {break}
{stata "svyset psuid [pweight=finalwgt], strata(stratid)" : svyset psuid [pweight=finalwgt], strata(stratid)}{break} 
{stata "asdoc svy: regress zinc age age2 weight female black orace rural, replace nest stat(N_strata, N_psu)" : asdoc svy: regress zinc age age2 weight female black orace rural, replace nest stat(N_strata, N_psu)} {break}
{stata "asdoc svy: regress zinc age age2 weight female black  , append nest stat(N_strata, N_psu)" : asdoc svy: regress zinc age age2 weight female black  , append nest stat(N_strata, N_psu)} {break}
{stata "asdoc svy: regress zinc age age2 weight female  , append nest stat(N_strata, N_psu)" : asdoc svy: regress zinc age age2 weight female   , append nest stat(N_strata, N_psu)} {break}

{marker aslist}
{title:14. ASLIST : LIST OF UNIQUE VALUES}

{p 4 4 2} To report one value per group or unique values for varlist, we can use
aslist command after asdoc. See the following examples:

{p 4 8 2} {ul on} Example 89: List unique categories of race and married {ul off}{break} 
`{break}
{stata "sysuse nlsw88.dta, clear" : sysuse nlsw88.dta, clear}{break}
{stata "decode race, gen(race2)" : decode race, gen(race2)}{break}
{stata "asdoc aslist race2 married, replace" : asdoc aslist race2 married, replace}{break}

{marker describe}
{title:15. DESCRIBE : EXPORT VARIABLE NAMES AND LABELS}

{p 4 4 2} To use asdoc with {opt des:cribe} command, we shall just add asdoc as a prefix
to {opt des:cribe}. We can also use the following options to add details to the output
file in addition to the variable name and label.

{dlgtab:describe options}
{p2colset 8 19 19 2}{...}
{p2col : {opt position}}  a column containing the numeric position of the original variable (1, 2, 3, ...){p_end}
{p2col : {opt type}} a column containing the storage type of the original variable, such as "str18", "int", "float", .... {p_end}
{p2col : {opt isnumeric}} a column equal to 1 if the original variable was numeric and equal to 0 if it was string. {p_end}
{p2col : {opt  format}} a column containing the display format of the original variable, such as "%-18s", "%8.0gc", .... {p_end}
{p2col : {opt  vallab}} a column containing the name of the value label associated with the original variable, if any. {p_end}

{p 4 8 2} {ul on} Example 90: Describe names and varlabel {ul off}{break} 
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}
{stata "asdoc des , replace" :asdoc des , replace} {break}

{p 4 8 2} {ul on} Example 91: Add variable position {ul off}{break} 
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}
{stata "asdoc des, position replace" :asdoc des, position replace} {break}

{p 4 8 2} {ul on} Example 92: With all possible options{ul off}{break} 
`{break}
{stata "sysuse auto, clear" : sysuse auto, clear} {break}
{stata "asdoc des, position type isnumeric format vallab replace" :asdoc des, position type isnumeric format vallab replace} {break}

{marker row}
{title:16. BUILDING TABLES ROW BY ROW ({opt row})}

{p 4 4 2} Option {opt row}, allows building a table row by row from text and statistics.  In each run of asdoc with option {opt row}, 
a row is added to the output table. This is a useful feature when statistics are collected from different Stata commands to build customized tables. The syntax for using this option is given below:

{p 4 4 2} {bf: Syntax:} 

{p 4 4 2} {opt asdoc}, {opt row(data1, data2, data3, data4, data5, ...)} [{opt dec(#)} {opt replace} {opt cs(#)} {opt title(text)}]

{p 4 4 2} As shown above, we shall type nothing after the word {opt asdoc}. Therefore, all other arguments of the command come after the comma.

{p 4 4 2} 16.1. The first required option is {opt row(data1, data2, ...)}. Here {hi:{it: data1, data2, ...}} can be either a numeric value, string, or both. Within
the brackets after option {opt row}, each piece of data should be separated by the character comma and hence it will be written
to a separate cell in the output table. 

{p 4 4 2} 16.2.The optional options include {opt dec()} that specifies the number of decimal points if the
data is numeric in nature. For example, for reporting two decimal points, the option dec will look like {opt dec(2)}. If left empty, the default value for dec is three.

{p 4 4 2} 16.3. Next optional option is {opt cs(#)} that specifies the cell width. It can take values from 1 to 10. It is the horizontal width of cells in the output table.
A bigger cell width is required to accommodate more data. If this option is not specified, asdoc will use its default
cell width that is calculated on the basis of a number of characters in the data and number of data items supplied through the option {opt row}.

{p 4 4 2} 16.4. Other options of asdoc can also be used with option {opt row} such as {help asdoc#replace:replace} that will replace the existing file; {help asdoc##append:append} (can be left blank) to append to the existing
file; {opt title(title of the table)}, etc.

{p 4 8 2} { ul on}Example 93: Collect statistics from dfuller command} {ul off}{break}  

{p 8 8 2} {stata "webuse air2, clear" : webuse air2, clear} {break}  
{stata "asdoc, row( Variables, Z, p-value, lags) title(Table: Dfuller test results) replace" : asdoc, row(Variables, Z, p-value, lags) title(Table: Dfuller test results) replace} {break}  
{stata "dfuller air" : dfuller air} {break} 
{stata "asdoc, row( Air1, `r(Zt)', `r(p)', `r(lags)') dec(3)" : asdoc, row( Air1, `r(Zt)', `r(p)', `r(lags)') dec(3) } {break}  

{p 8 8 2}In the first line, we downloaded the {it:air2} data from the StataCorp server. Then, we wrote the title row of the table. In the third line, we applied Dicky-Fuller test to the variable {it: air}. 
And in the 4th line, we collected the required statistics
i.e. the Z-test value, p-value, and the number of lags and sent these stats to a word table. These statistics are left behind by the {help dfuller}
test in r() macros. We can keep on adding rows to this table. Let us create another variable, apply {help dfuller} test, and send these statistics to the same MS Word file.

{p 8 8 2} {stata "gen air2 = air+air[_n-1]/2" : gen air2 = air+air[_n-1]/2} {break}  
{stata "dfuller air2" : dfuller air2} {break} 
{stata "asdoc, row( Air2, `r(Zt)', `r(p)', `r(lags)') dec(3)" : asdoc, row( Air1, `r(Zt)', `r(p)', `r(lags)') dec(3) } {break}  

{title:17. ACCUMULATING TEXT AND STATISTICS ({opt accum})}

{p 8 8 2} As discussed above in {help asdoc##row:Section 16}, we can create table from text and 
statistics that are collected from different Stata commands. There is one challenge to developing flexible
tables with option {opt row} - that a given row has to be written in one go. So once a row is written,
no further cells can be appended to the same row. This means that we need to first collect all
the required bits of information before writing  a row. Collecting and holding these bits of information
can be tricky or too time-consuming. To facilitate this process, asdoc offers option {opt accum(data1, data2, ...)}.
The word {opt accum} is an abbreviation that I use for {opt accumulate}. The syntax of this option is given below:

{p 8 8 2} {opt asdoc}, {opt accum(data1, data2, data3, data4, data5, ...)} [ {opt dec(#)} {opt show} ]

{p 8 8 2} Actually, the above command can be run as long as the limit of gloabal macro to hold data is not reached. 
The above command will accumulate text and statistics from different runs of asdoc and hold them in the global macro
{opt ${accum}}. Once we have accumulated all the needed bits of information in the global macro, then its contents 
can be written to the Word table with option {opt row}. Option {opt show} can be used to show contents of the global
macro {bf: ${accum}}.

{p 8 8 2} Assume that we want to build an odd table
that presents the number of observations, mean, and standard deviation for two variables in two different time periods.
The researcher wants to follow the following format:

----------------------------------------------------------------------
{bf:invest				kstocks}
------------------------------------------------------------
Period		N	Mean	SD		  N	Mean	SD
----------------------------------------------------------------------

1935-40	110	108.49	147.62	         110	156.24	124.59

1941-45	90	191.74	273.17	         90	422.40	379.87

----------------------------------------------------------------------

{p 8 8 2} { ul on}Example 94{ul off}{break}  

{p 8 8 2} {stata "webuse grunfeld, clear" :webuse grunfeld, clear}{break} 

{p 8 8 2} {stata "asdoc, row( \i, \i, invest, \i, \i, kstock,\i) replace" :asdoc, row( \i, \i, invest, \i, \i, kstock,\i) replace}{break} 
{stata "asdoc, row( Periods, N, Mean, SD, N, Mean, SD)" :asdoc, row( Periods, N, Mean, SD, N, Mean, SD)}{break} 

{p 8 8 2} {stata "sum invest if inrange(year , 1935, 1945)" :sum invest if inrange(year , 1935, 1945)}{break} 
{stata "asdoc, accum(`r(N)', `r(mean)', `r(sd)')" :asdoc, accum(`r(N)', `r(mean)', `r(sd)')}{break} 
{stata "sum kstock if inrange(year , 1935, 1945)" :sum kstock if inrange(year , 1935, 1945)}{break} 
{stata "asdoc, accum(`r(N)', `r(mean)', `r(sd)')" :asdoc, accum(`r(N)', `r(mean)', `r(sd)')}{break} 
{stata "asdoc, row( 1935-1945, $accum)" :asdoc, row( 1935-1945, $accum)}{break} 


{p 8 8 2} {bf: Explanation:}{break}
1. The second row of our required table reveals that a total of 7 cells are needed, this is why we created 7 cells in the first 
line of code. The text "{bf: \i,}" is a way of entering an empty cell. We entered empty cells so that the variables names 
{bf: invest} and {bf: kstocks} are written in the middle of the table. {break} 
2. The second line of code writes the table header row.{break} 
3. The third line finds summary statistics. We shall collect our required statistics from the macros that are left behind in r() by the {help sum} command. {break}
4. The fourth line accumulates the required statistics for our first variable {bf: invest}{break}
5. We are not yet writing the accumulated statistics to the Word file. So we find statistics for our second variable {bf: kstocks} in the fifth line.{break}
6. We again accumulate the needed statistics for our second variable in the sixth line.{break}
7. Since our row of required statistics  is now complete, we write the accumulated statistics  and the first row label, i.e, {bf:1935-1945} to our Word file.{break}


{p 8 8 2} Let us write one more row to the table. This time, the statistics are based on years 1946-1954

{p 8 8 2}{stata "sum invest if inrange(year , 1946, 1954)" :sum invest if inrange(year , 1946, 1954)}{break} 
{stata "asdoc, accum(`r(N)', `r(mean)', `r(sd)')" :asdoc, accum(`r(N)', `r(mean)', `r(sd)')}{break} 
{stata "sum kstock if inrange(year , 1946, 1954)" :sum kstock if inrange(year , 1946, 1954)}{break} 
{stata "asdoc, accum(`r(N)', `r(mean)', `r(sd)')" :asdoc, accum(`r(N)', `r(mean)', `r(sd)')}{break} 
{stata "asdoc, row( 1946-1954, $accum)" :asdoc, row( 1946-1954, $accum)}{break} 


{marker other}
{title:18. OTHER Stata COMMANDS}

{p 4 4 2} Stata commands that have some output in the result window can also
be used with asdoc. Even when a command does not have an output, asdoc can be 
added as a prefix. In such cases, asdoc just passes the commands to Stata without
generating any output. asdoc might come up with a less than pretty output if it is used 
with a Stata command that does not have a standard table format. If a user-written command that
estimates regression model is used with asdoc, option {opt isreg} can be used to tell asdoc
that the command is a regression command. Another way is to add the command name to the REG macro
in the sub-program {opt getcmd}. In order for asdoc to work with a regression program, it is 
necessary that the given program is rclass and leaves behind standard r(table). Following
are few examples in this category:

{p 4 8 2} {ul on} Example 95: Other Stata commands with asdoc: the case of mvtest{ul off}{break} 
`{break}
{stata " webuse iris, clear" :  webuse iris, clear} {break}
{stata "asdoc mvtest normality pet* sep*, bivariate univariate stats(all) replace" :asdoc mvtest normality pet* sep*, bivariate univariate stats(all) replace} {break}


{marker cite}
{title:19. HOW TO CITE }

{p 4 4 2} {bf: In-text citation style} : You can mention the following in the footnotes with tables generated by asdoc:

{p 4 4 2} {bf: These tables were created with asdoc program, written by Shah (2018).}

{p 4 4 2} {bf: Bibliography citation style} :

{p 4 4 2} Shah, A. (2018). "asdoc:  Create high-quality tables in MS Word from Stata output"


{marker online}
{title:20. INDEX TO VIDEOS and BLOG ENTRIES on asdoc}

{p 4 4 2} YouTube video : {browse "https://www.youtube.com/watch?v=zdI65G6AhdU&t=" : Creating descriptive statistics with asdoc}{break}
YouTube video : {browse "https://www.youtube.com/watch?v=guhBH1sqeO0" : Create tabs and cross-tabs with asdoc}{break}
YouTube video : {browse "https://www.youtube.com/watch?v=XHBl6PHfOzs&t=" : Create publication quality table of correlation in Stata with asdoc}{break}
YouTube video : {browse "https://www.youtube.com/watch?v=61ks3cMPz3c&t=" : Create publication quality regression tables in Stata with asdoc}{break}
YouTube video : {browse "https://www.youtube.com/watch?v=rkUU7UiygBU" : Regression over groups in Stata | asdoc | export tables to MS Word or in RTF}{break}
YouTube video : {browse "https://www.youtube.com/watch?v=cwH2EqtUa2o&t=" : Writing all stats to a single Word file}{break}

{p 4 4 2} Blog post : {browse "https://fintechprofessor.com/2018/02/23/use-asdoc-basic-example" : A simple example to get started with asdoc}{break}
Blog post : {browse "https://fintechprofessor.com/2018/03/05/export-high-quality-table-correlations-stata-ms-word" : How to export high-quality table of correlations from Stata to MS Word}{break}
Blog post : {browse "https://fintechprofessor.com/2018/06/18/exporting-tabs-and-cross-tabs-to-ms-word-from-stata-with-asdoc" : Exporting tabs and cross-tabs to MS Word from Stata with asdoc}{break}
Blog post : {browse "https://fintechprofessor.com/2019/01/31/ordering-variables-in-a-nested-regression-table-of-asdoc-in-stata/" : Ordering variables in a nested regression table of asdoc in Stata}{break}
Blog post : {browse "https://fintechprofessor.com/2018/12/19/asdoc-cutomizing-the-regression-output-ms-word-from-stata-confidence-interval-adding-stars-etc/" : Customizing the regression output Confidence Interval, adding stars, etc.}{break}
Blog post : {browse "https://fintechprofessor.com/2018/12/12/asdoc-export-stata-dta-file-to-ms-word/" : Export Stata dta file to MS Word}{break}
Blog post : {browse "https://fintechprofessor.com/2018/09/20/asdoc-exporting-customized-descriptive-statistics-from-stata-to-ms-word-rtf/" : Exporting customized descriptive statistics from Stata to MS Word}{break}




{title:21. WANNA SAY THANKS? }

{p 4 4 2} This is the biggest program I have ever written. asdoc took more than 12 months
to complete (average 14 hours per day in the first stage of development, that was around 3 months). 
It has more than 50 functions written in Mata language and more than 20 programs
written in the Stata language. All these programming efforts span over 9800 lines of 
codes, 1310 IF statements, and 544 ELSE statements. If you like it and find it useful,
please do cite it in your research work [{help asdoc##cite:See how to cite it}] and send your thanks and 
comments to attaullah.shah@imsciences.edu.pk. If you think that you can thank me
otherwise, then my {bf:Paypal} account address is {bf:attaullah.shah@imsciences.edu.pk} 
A small token of thanks will suffice.  

{marker future}
{title:22. FUTURE PLANS}

{p 4 4 2} It is now almost three years in developing asdoc and constantly adding features to it. 
With the addition of {help _docx} and {help xl()} classes to Stata, it is high time to add support
for native docx and xlsx output to asdoc. Also, given that there exists a significant
number of LaTeX users, asdoc should be able to create LaTeX documents.  
It gives me immense pleasure to annouce {browse "https://fintechprofessor.com/asdocx/" : asdocx} 
that is not only more flexible in making customized tables, but also creates documents
in native docx, xlsx, rtf, and .tex formats. If you have enjoyed and find asdoc useful, please
consider buying a copy of asdocx to support its development. Details related to asdocx 
can be found on {browse "https://fintechprofessor.com/asdocx/" : this page}. 

{title:Author}


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: *
*                                                                   *
*            Dr. Attaullah Shah                                     *
*            Institute of Management Sciences, Peshawar, Pakistan   *
*            Email: attaullah.shah@imsciences.edu.pk                *
*           {browse "www.FinTechProfessor.com": www.FinTechProfessor.com}                               *
*           {browse "www.OpenDoors.Pk": www.OpenDoors.Pk}                                       *
*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*


{marker also}{...}
{title:Also see}

{psee}
{browse "http://www.opendoors.pk/home/paid-help-in-empirical-finance/stata-program-to-construct-j-k-overlappy-momentum-portfolios-strategy": asm    : for momentum portfolios}   {p_end}
{psee}{stata "ssc desc astile":astile : for creating fastest quantile groups} {p_end}
{psee}{stata "ssc desc asreg":asgen : for weighted average mean} {p_end}
{psee}{stata "ssc desc asrol":asrol : for rolling-window statistics} {p_end}
{psee}{stata "ssc desc asreg":asreg : for rolling-window, by-group, and Fama and MacBeth regressions} {p_end}
{psee}{stata "ssc desc ascol":ascol : for converting asset returns and prices from daily to a weekly, monthly, quarterly, and yearly frequency}{p_end}
{psee}{stata "ssc desc searchfor":searchfor : for searching text in data sets} {p_end}



