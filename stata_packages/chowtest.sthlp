{smcl}
{cmd:help chowtest}{right: (version 2011-August-23)}
{hline}


{title:Title}

{p2colset 3 15 20 2}{...}
{p2col:{hi: chowtest} {hline 2}} Chow test for structure break
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 4 19 2}
{cmdab:chowtest} {varlist} {ifin}, {cmdab:g:roup:}{cmd:(varname)}
[
{cmdab:r:estrict:}{cmd:(varlist)}
{opt h:et}
{opt d:etail}
]

{synoptset 24 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt g:roup(varname)}}specify the group variable{p_end}
{synopt :{opt r:estrict}}independents which are restriced to have constant coefficients {p_end}
{synopt :{opt h:et}}heteroskedasticy {p_end}
{synopt :{opt d:etail}}display regression result {p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}{varlist} are dependent variable and unrestriced independent variables.{p_end}

{title:Example} 

{result}{dlgtab:The auto.dta data}{text}

{phang2}{inp:.} {stata "sysuse auto,clear":sysuse auto,clear}{p_end}
{phang2}{inp:.} {stata "chowtest price wei mpg, group(foreign)":chowtest price wei mpg, group(foreign)}{p_end}
{phang2}{inp:.} {stata "chowtest price wei mpg, group(foreign) restrict(headroom)":chowtest price wei mpg, group(foreign) restrict(headroom)}{p_end}
{phang2}{inp:.} {stata "chowtest price wei mpg, group(foreign) het":chowtest price wei mpg, group(foreign) het }{p_end}

{title:Acknowledgements}

{pstd}   
Thanks for helpul suggestions of Lian Yujun in Sun Yat-sen University 
({browse "mailto:arlionn@163.com":arlionn@163.com}, {browse "http://www.peixun.net/author/3.html":http://www.peixun.net/author/3.html}). 
{p_end}

{title:Author}

{pstd}   
{cmd:Qunyong, Wang,} Institute of Statistics and Econometrics, Nankai University.{break}
E-mail: {browse "mailto:QunyongWang@outlook.com":QunyongWang@outlook.com}. {break}
Homepage: {browse "http://economics.nankai.edu.cn/level2/ProfileTeacherInfo.aspx?id=229":http://economics.nankai.edu.cn/level2/ProfileTeacherInfo.aspx?id=229}. {break}
{p_end}

