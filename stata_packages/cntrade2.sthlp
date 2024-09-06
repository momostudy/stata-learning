{smcl}
{* 2018年7月21日}{...}
{cmd:help cntrade2}{right: }
{hline}

{title:简介}

{p2colset 5 25 27 2}{...}
{p2col:{hi: cntrade2} {hline 2}}从网易财经获取股票交易数据。
{p_end}
{p2colreset}{...}


{title:语法}

{p 8 18 2}
{cmdab:cntrade2} {it: codelist}{cmd:,}
[{opt s:tart}{cmd:(}{it:string}{cmd:)} {opt e:nd}{cmd:(}{it:string}{cmd:)} {opt s:tock} {opt i:ndex}]

{pstd}{it:codelist} 一列股票代码，使用空格分割。 
对于每一个股票代码会输出一个Stata数据集文件；
输出的数据集中包含了该股票的交易数据；
输出数据集的名字是上市公司的股票代码；
中国上市公司的股票代码为六位数字，这不同与纽约证券交易所。
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
{phang} {bf: {opt i:ndex}}:指定代码为股票指数代码。{p_end}

{title:示例}
{phang}
{stata `"cntrade2 1, start(20180101) end(20180701)"'}
{p_end}
{phang}
{stata `"cntrade2 1, start(20180101) end(20180701) index"'}
{p_end}

{title:作者}

{pstd}程振兴{p_end}
{pstd}暨南大学·经济学院·金融学{p_end}
{pstd}中国·广州{p_end}
{pstd}{browse "http://www.czxa.top":个人网站}{p_end}
{pstd}Email {browse "mailto:czxjnu@163.com":czxjnu@163.com}{p_end}

{title:备注}

{pstd}这个命令是对李春涛的cntrade的修改，主要是通过修改变量的名称使之更方便使用。{p_end}
