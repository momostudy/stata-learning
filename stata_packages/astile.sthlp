{smcl}
{right:version:  3.2.2}
{cmd:help astile} {right:April 17, 2018}
{hline}
{viewerjumpto "Options" "astile##astile_options"}{...}
{viewerjumpto "qc" "astile##qc"}{...}

{title:Title}

{p 4 8}{cmd:astile}  -  Creates variable containing quantile categories {p_end}


{title:Syntax}

{p 8 15 2}
{cmd:astile}
{newvar} {cmd:=} {it:{help exp}}
{ifin}
[{cmd:,} {it:{help astile##astile_options:nquantiles(#)}}
{it:{help astile##astile_qc:qc(string)}}
{it:{help by}}({it:varlist})]


{title:Description}

{p 4 4 2} {cmd: astile} creates a new variable that categorizes exp by its quantiles. For example, we might be interested in making 10 firm size-based
portfolios. This will involve placing the smallest 10% firms in portfolio 1, next 10% in portolio 2, and so on.{cmd: astile} creates
a new variable as specified in the {newvar} option from the existing variable which is specified in the {cmd:=} {it:{help exp}}. Values of the {newvar}
ranges from 1, 2, 3, ... up to n, where n is the maximum number of quantile groups
specified in the {cmd: nq} option. For example, if we want to make 10 portfolios, values of the {newvar} will range from 1 to 10.
{p_end}


{p 4 4 2} {cmd: astile} is faster than Stata official {help xtile}. It's speed efficiency matters more in larger data sets or when the quantile 
categories are created multiple times, e.g, we might want to create portfolios in each year or each month. Unlike Stata's
official {help xtile}, {cmd: astile} is {help byable}. {cmd: astile} handles groupwise calculations super efficiently. For example, the difference in time when 
used with {help bys} and without {help bys} is usually few seconds in a million observations and 1000 groups. {p_end}

{marker astile_options}{...}
{title:Options}

{p 4 4 2} 
{cmd:astile} has the following three optional options. {p_end}

{p 4 4 2} 1. {opt nq:uantiles} : The {cmd: nq}(#) option specifies the number of quantiles. For example, nq(4) will create quratiles, making 4 equal groups of the data 
based on the values of the selected variable. The default value of {cmd:nq} is 2, that is the median.{p_end}
		
{p 4 4 2} 2. {opt by} : {cmd:astile} is {help byable}. Hence, it can be run on groups as specified by option {opt by}({it:varlist}). 		

{marker astile_qc}{...}
{p 4 4 2} 3. {opt qc(string)} : {opt qc} is an abbreviation for qunatiles criterion. This option can be used if the qunatile breakpoints need to be based on a subset of the data, and then observations 
in the entire data set (off course in the toused sample as created by the {ifin} options) are assigned to these break points. 
		

 
{title:Example 1: Create 10 groups of firms based on thier market value}
 {p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 {p 4 8 2}{stata "astile size10=mvalue, nq(10)" :. astile size10=mvalue, nq(10)} {p_end}


 {title:Example 2: Create 5 groups of firms based on thier market value in each year} 
 {p 4 8 2}{stata "webuse grunfeld" :. webuse grunfeld}{p_end}
 {p 4 8 2}{stata "astile size5=mvalue, nq(5) by(year)" :. astile size5=mvalue, nq(5) by(year)} {p_end}
 {p 4 8 2} OR {p_end}
 {p 4 8 2}{stata "bys year: astile size5=mvalue, nq(5)" :. bys year: astile size5=mvalue, nq(5)} {p_end}

 
  {title:Example 3: Use option qc:  breakpoints ared based on prices of foreign}
  {p 4 4 2} Let use use the auto data set and make 10-qunatile breakpoints based on values of the variable  {it:{hi:price}} where the made is {it:{hi:foreign}}, and then  
 assign observations in the entire data set to these breakpoints. {p_end}
 
 {p 4 8 2}{stata "sysuse auto" :. sysuse auto}{p_end}
 {p 4 8 2}{stata "astile P10 = price, nq(10) qc(foreign == 1)" :. astile P10 = price, nq(10) qc(foreign == 1)} {p_end}

 {title:Example 4: Use option qc with string variables}
  {p 4 4 2} {opt qc} accepts both numeric and string variables or other general Stata expressions. For example, if foreign was coded as a string variable in the
  previous example, we could have typed:{p_end}
 
 {p 4 8 2}{stata "decode foreign , gen(foreign2)" :. decode foreign , gen(foreign2)}{p_end}
 {p 4 8 2}{stata `"astile Ps102 = price, nq(10) qc(foreign2=="Foreign")"' :. astile Ps102 = price, nq(10) qc(foreign2=="Foreign")} {p_end}


 
 {title:Author}


::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::: *
*                                                                   *
*            Dr. Attaullah Shah                                     *
*            Institute of Management Sciences, Peshawar, Pakistan   *
*            Email: attaullah.shah@imsciences.edu.pk                *
*           {browse "www.OpenDoors.Pk": www.OpenDoors.Pk}                                       *
*           {browse "www.StataProfessor.com": www.StataProfessor.com}                                 *

*:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::*


{marker also}{...}
{title:Also see}

{psee}
{stata "ssc desc fastxtile":fastxtile}, 
{stata "ssc desc egenmore":egenmore}, 
{stata "help xtile":xtile}, 
{stata "ssc desc asreg":asreg},
{stata "ssc desc asrol":asrol},
{stata "ssc desc searchfor":searchfor}





