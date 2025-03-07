{smcl}
{* 24Nov2020}{...}
{cmd:help for {hi:ttable3}}{right: ({browse "https://www.lianxh.cn/blogs/22":blog})}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{hi: ttable3} {hline 2}}Mean or Median Comparison for a lot of variables between two groups with formatted table output
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 19 2}
{cmdab:ttable3} {varlist} {ifin}, {opth by:(varlist:groupvar)} 
[
{cmdab:f:ormat:}{cmd:(%}{it:{help format:fmt}}{cmd:)}
{opt une:qual}
{opt w:elch}
{opt med:ian}
{opt r:owname}
{opt not:itle}
{opt nos:tar}
{opt t:value}
{opt p:value}
]


{title:Description}

{pstd}
The official command {help ttest} tests that a single variable has the same mean
within the two groups defined by {it:{help varlist:groupvar}}, 
while another official command {help median} do similar things for group medians.
{opt ttable3} performs {help ttest} for a group of variables specified in {it:varlist} 
with formatted table output. When {opt median} is specified, it performs {help median} test. 

{title:Options}

{phang}
{opth by:(varlist:groupvar)} specifies the {it:groupvar} that defines the two
groups that {opt ttable3} will use to test the hypothesis that their means (medians) are
equal.  Specifying {opt by(groupvar)} implies an unpaired (two sample) t test or median test.

{pstd} {opt format}{cmd:(%}{it:{help format:fmt}}{cmd:)}
specify the display format for group means and their difference; default format is {cmd:%8.3f}.{p_end}

{phang}
{opt unequal} specifies that the unpaired data not be assumed to have equal
   variances.

{phang}
{opt welch} specifies that the approximate degrees of freedom for the test
   be obtained from Welch's formula
   ({help ttest##W1947:1947}) rather than Satterthwaite's approximation
   formula ({help ttest##S1946:1946}), which is the default when {opt unequal}
   is specified.  Specifying {opt welch} implies {opt unequal}.

{phang}
{opt median} causes {opt ttable3} to perform a nonparametric 2-sample test on the equality of medians.  
    It tests the null hypothesis that the two samples were drawn
    from populations with the same median.  
	For two samples, the chi-squared test statistic is computed both with and without a
    continuity correction. see {manhelp median R}

{phang}
{opt notitle} suppress title in the table header. It is helpful when {help logout} is used to export results to Excel or Word format.	

{phang}
{opt nostar} will not display stars(*) on the screen if it is specified

{phang}
{opt tvalue/pvalue} specifies whether Stata will report the {opt t-value}/{opt p-value} or not
   
{title:Examples}

{result}{dlgtab:The auto data}{text}

{phang2} * t-test {p_end}
{phang2}{inp:.} {stata "sysuse auto,clear":sysuse auto,clear}{p_end}
{phang2}{inp:.} {stata "ttable3 price wei len mpg, by(foreign)":ttable3 price wei len mpg, by(foreign)}{p_end}
{phang2}{inp:.} {stata "ttable3 price wei len mpg, by(foreign) f(%6.2f)":ttable3 price wei len mpg, by(foreign) f(%8.2f)}{p_end}

{phang2} * Median test {p_end}
{phang2}{inp:.} {stata "ttable3 price wei len mpg, by(foreign)":ttable3 price wei len mpg, by(foreign) median}{p_end}

{phang2} * Restrict to two-groups {p_end}
{phang2}{inp:.} {stata "tab rep78":tab rep78}{p_end}
{phang2}{inp:.} {stata "ttable3 price wei len mpg if rep78==3|rep78==4, by(rep78)":ttable3 price wei len mpg if rep78==3|rep78==4, by(rep78)}{p_end}

{phang2} * Report t-value and ommit the satrs {p_end}
{phang2}{inp:.} {stata "ttable3 price wei len mpg, by(foreign) nostar tvalue":ttable3 price wei len mpg, by(foreign) nostar tvalue}{p_end}

{result}{dlgtab: Save in Excel or Word}{text}

{pstd}you can use the user-written {help logout} command to export the results into Excel or Word:{p_end}

{phang2}{inp:.} {stata "logout, save(Tab2_corr) excel replace: ttable3 price wei len mpg, by(foreign) notitle":logout, save(Tab2_corr) excel replace: ttable3 price wei len mpg, by(foreign) notitle}{p_end}

{title: Acknowledgements}

{pstd}   
codes from {help ttable2} by Xuan Zhang and Chuntao Li have been incorporated for t-test. {break}
Any comments will be appreciated
{p_end}

{title:Author}

{phang}
{cmd:Yujun,Lian (arlionn)} Department of Finance, Lingnan College, Sun Yat-Sen University.{break}
E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com}. {break}
Blog: {browse "https://www.lianxh.cn":https://www.lianxh.cn} {break}
{p_end}

{pstd}   {p_end}

{title:Also see}

{pstd} Online: {manhelp ttest R} {manhelp median R}  {p_end}

{title:Also see}

{p 4 13 2}
Online:  
{help ttest}, 
{help median}, 
{help ttable2} (if installed),
{help covbal} (if installed), 
{help dmout} (if installed), 
{help t2docx} (if installed), 
{help baselinetable} (if installed)

{pstd}   {p_end}
