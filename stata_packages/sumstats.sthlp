{smcl}
{* Dec 31st 2019}
{hline}
Help for {hi:sumstats}
{hline}

{title:Description}

{p}{cmd:sumstats} easily generates a table of summary statistics with various {help if}-restrictions
and prints them to a specified output file using {help putexcel}.

{title:Syntax}

{phang}{cmd:sumstats} ({it:varlist_1} [{help if}]) [({it:varlist_2} [{help if}])] [...]
{break}	{help using} {it:"/path/to/output.xlsx"} [{help weight}]
{break} , stats({it:{help tabstat##statname:stats_list}})
{break}  [replace] [sheet({it:sheetname} [, replace])] {p_end}

{title:Instructions}

{p}{cmd:sumstats} will print to Excel the requested statistics for the specified variables in each list with the specified conditions for that list.
Specify with {help using} the desired file path (and, optionally, a sheet name in {bf:sheet()} using {help putexcel} syntax) for the {help putexcel} output. {bf:aweights} and {bf:fweights} are allowed; statistics are calculated with {help tabstat}.

{title:Example}

{p 2}{stata sysuse auto.dta , clear:sysuse auto.dta , clear}{p_end}
{p 2 4}{stata sumstats (price mpg if foreign == 0)(price displacement length if foreign == 1) using "test.xlsx" , replace stats(mean sd):sumstats}  ///
{break}(price mpg if foreign == 0) ///
{break}(price displacement length if foreign == 1) ///
{break}using "test.xlsx" , replace stats(mean sd)
{p_end}

{title:Author}

Benjamin Daniels
bbdaniels@gmail.com

{title:Contributing}

{p}{bf: sumstats} is open for development on {https://github.com/bbdaniels/sumstats":GitHub}.
Submit bugs and feature requests {browse "https://github.com/bbdaniels/sumstats/issues":here}.
If you like {bf:sumstats}, be sure to visit my {browse "http://www.benjaminbdaniels.com":homepage}.{p_end}
