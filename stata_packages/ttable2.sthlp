{smcl}
{* 3jan2013}{...}
{cmd:help ttable2}{right: }
{hline}

{title:Title}

{p2colset 5 18 20 2}{...}
{p2col:{hi: ttable2} {hline 2}}Mean Comparison for a lot of variables between two groups with formatted table output
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 19 2}
{cmdab:ttable2} {varlist} {ifin}, {opth by:(varlist:groupvar)} {cmdab:f:ormat:}{cmd:(%}{it:{help format:fmt}}{cmd:)}

{pstd} {varlist} is a list of numerical variables to be tested. {p_end}

{pstd} For each of those variables, we need to perform a standard t-test to compare it's mean difference 
between two groups specified by option {opth by:(varlist:groupvar)}.  
{it:groupvar} must be a dichotomous variable for the sample 
specified by {hi: [if] and [in]}. {hi:{it:groupvar}} maybe either numerical or string, provided that it only takes two different values for the sample. 
{p_end}

{pstd} {opt format}{cmd:(%}{it:{help format:fmt}}{cmd:)}
specify the display format for group means and their difference; default format is {cmd:%8.3f}.{p_end}



{title:Examples}

{result}{dlgtab:The auto data}{text}

{phang2}{inp:.} {stata "sysuse auto,clear":sysuse auto,clear}{p_end}
{phang2}{inp:.} {stata "ttable2 price wei len mpg, by(foreign)":ttable2 price wei len mpg, by(foreign)}{p_end}
{phang2}{inp:.} {stata "ttable2 price wei len mpg, by(foreign) f(%6.2f)":ttable2 price wei len mpg, by(foreign) f(%6.2f)}{p_end}

{phang2}{inp:.} {stata "tab rep78":tab rep78}{p_end}
{phang2}{inp:.} {stata "ttable2 price wei len mpg if rep78==3|rep78==4, by(rep78)":ttable2 price wei len mpg if rep78==3|rep78==4, by(rep78)}{p_end}

{result}{dlgtab:Save in Excel or Word}{text}

{pstd}you can use the user-written {help logout} command to export the results into Excel or Word:{p_end}

{phang2}{inp:.} {stata "logout, save(Tab2_corr) excel replace: ttable2 price wei len mpg, by(foreign)":logout, save(Tab2_corr) excel replace: ttable2 price wei len mpg, by(foreign)}{p_end}


{title:Authors}

{pstd}Xuan Zhang{p_end}
{pstd}Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}
{pstd}zhangx@znufe.edu.cn{p_end}

{pstd}Chuntao Li{p_end}
{pstd}Zhongnan University of Economics and Law{p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@znufe.edu.cn{p_end}

and updated by:

{phang}
{cmd:Yujun,Lian (Arlion)} Department of Finance, Lingnan College, Sun Yat-Sen University.{break}
E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com}. {break}
Blog: {browse "http://blog.cnfol.com/arlion":http://blog.cnfol.com/arlion}. {break}
Homepage: {browse "http://www.lingnan.net/intranet/teachinfo/dispuser.asp?name=lianyj":http://www.lingnan.net/intranet/teachinfo/dispuser.asp?name=lianyj}. {break}
{p_end}


{pstd}   {p_end}
{pstd}   {p_end}
