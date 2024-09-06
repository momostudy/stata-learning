{smcl}
{* 2018年8月10日}
{hline}
{cmd:help cnstock2}{right: }
{hline}

{title:标题}

{phang}
{bf:cnstock2} {hline 2} 爬取沪市、深市或两市所有上市公司基本情况数据。{p_end}

{title:语法}

{p 8 18 2}
{cmdab:cnstock2}[, {opt m:arket(string)}]

{title:示例}

{phang}下载两市所有上市公司的基本情况数据：{p_end}
{phang}
{stata `"cnstock2"'}
{p_end}
{phang}下载沪市所有上市公司的基本情况数据：{p_end}
{phang}
{stata `"cnstock2, m(SH)"'}
{p_end}
{phang}下载深市所有上市公司的基本情况数据：{p_end}
{phang}
{stata `"cnstock2, m(SZ)"'}
{p_end}

{title:作者}

{pstd}程振兴{p_end}
{pstd}暨南大学·经济学院·金融学{p_end}
{pstd}中国·广州{p_end}
{pstd}{browse "http://www.czxa.top":个人网站}{p_end}
{pstd}Email {browse "mailto:czxjnu@163.com":czxjnu@163.com}{p_end}
