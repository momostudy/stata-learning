{smcl}
{* 2018年9月17日}{...}
{cmd:help stkpv2}{right: }
{hline}

{title:简介}

{p2colset 5 25 27 2}{...}
{p2col:{hi: stkpv2} {hline 2}}绘制股价棒状图。
{p_end}
{p2colreset}{...}


{title:语法}

{p 8 18 2}
{cmdab:stkpv2} {it: code}{cmd:,}
[{opt s:tart}{cmd:(}{it:string}{cmd:)} {opt e:nd}{cmd:(}{it:string}{cmd:)} {opt s:tock} {opt i:ndex}]

{pstd}{it:code} 股票代码{p_end}

{pstd}中国上市公司的股票代码为六位数字，这不同与纽约证券交易所。
例如: {p_end}
{pstd} {hi:000001} 平安银行  {p_end}
{pstd} {hi:000002} 万科 {p_end}
{pstd} {hi:600000} 浦发银行 {p_end}
{pstd} {hi:600005} 武钢股份 {p_end}

{pstd}开头的0是可以被省略的。{p_end}

{marker options}{...}
{title:选项}

{phang} {bf: {opt s:tart}(}{it:string}{bf:)}:数据起始日期；{p_end}
{phang} {bf: {opt e:nd}(}{it:string}{bf:)}:数据截止日期；{p_end}
{phang} {bf: {opt s:tock}}:指定代码为股票代码，这是默认的；{p_end}
{phang} {bf: {opt i:ndex}}:指定代码为股票指数代码；{p_end}

{title:示例}
{phang}
{stata `"stkpv2 1, start(20180101) end(20180701)"'}
{p_end}
{phang}
{stata `"stkpv2 1, start(20180101) end(20180701) index"'}
{p_end}

{title:作者}

{pstd}程振兴{p_end}
{pstd}暨南大学·经济学院·金融学{p_end}
{pstd}中国·广州{p_end}
{pstd}{browse "http://www.czxa.top":个人网站}{p_end}
{pstd}Email {browse "mailto:czxjnu@163.com":czxjnu@163.com}{p_end}
