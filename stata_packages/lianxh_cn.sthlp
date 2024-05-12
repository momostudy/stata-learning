{smcl}
{* *! version 1.2  17nov2023}{...}
{cmd:help lianxh {stata "help lianxh": English Version}}
{hline}

{title:Title}

{p2colset 5 16 16 2}{...}
{p2col:{hi: lianxh}   {hline 2}}在 Stata 中快速搜索 {browse "https://www.lianxh.cn/":lianxh.cn} 推文，并采用多种方式呈现和输出。
{p_end}
{p2colreset}{...}


{marker quickexample}{...}
{title:Quick examples}

{phang}. {stata "lianxh DID"}{p_end}
{phang}. {stata "lianxh DID 多 +"}{p_end}
{phang}. {stata "lianxh, new(10)"}{p_end}
{phang}. {stata "lianxh, hot(10)"}{p_end}
{phang}. {stata "lianxh 张 李, f(author) gsort(-click) hot(20) c d"}{p_end}


{marker description}{...}
{title:简介}

{pstd}
{opt lianxh} 是连享会编写的一个小程序,
目的在于让用户可以便捷地从 Stata 窗口中使用关键词检索
 {browse "https://www.lianxh.cn":[连享会]} 发布的推文。
 
{pstd}若不附加任何选项，{cmd:lianxh} 会在 Stata 结果窗口中呈现查询结果。 
 
{pstd}通过设定 {cmd:md}, {cmd:text} 等选项，你可以呈现检索结果的 Markdown 文本或 txt 文本，以便插入个人笔记或通过微信/邮件分享给他人。

{pstd}若辅以 {opt hot(#)}, {opt new(#)}, {opt fromto()} 等选项，可以筛选出特定时间段内、包含特定关键词的「点击量最高」, 「最新发布」的推文。

{pstd}
同时，使用 {cmd:lianxh, links} 可列出常用的 Stata 资源链接，包括 Stata 官网地址，Stata 官方
 {browse "https://www.stata.com/support/faqs/":[FAQs]}，
Stata 论坛 {browse "https://www.statalist.org/forums/":[Statalist]}，
{browse "https://www.lianxh.cn/news/12ffe67d8d8fb.html":[Stata Journal]}，
{browse "https://www.princeton.edu/~otorres/Stata/":Stata online tutorial}，
{browse "https://www.lianxh.cn/details/232.html":[论文重现资料]} 等。
	

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:lianxh}
{bind:[{it:keywords},}
{cmd:options}]

{phang}Note 1：{it:keywords} 表示待检索的关键词，可以包含多个关键词。
若 {it:keywords} 为空，则呈现所有推文。{p_end}

{phang2}o '{it:k1 k2 k3}' 表示检索词中包含 '{it:k1}' {bf:或} '{it:k2}' {bf:或} '{it:k3}'; {p_end}
{phang2}o '{it:k1 k2 k3 +}' 表示检索词中{bf:同时}包含 '{it:k1}', '{it:k2}' {bf:和} '{it:k3}'{p_end}

{phang}Note 2：{cmdab:f:ields(varlist)} 和 {cmdab:exf:ields(varlist} 选项用于控制检索或排除字段。

{phang2}o 可用字段包括: {cmdab:a:uthor}, {cmdab:t:itle}, {cmdab:k:eyword}, {cmdab:c:atname}，分别表示推文作者，推文标题，推文关键词和推文类别。{p_end}
{phang2}o 若用户输入 {cmd:lianxh DID RDD} 命令，但不设定 {cmdab:f:ields(varlist)} 和 {cmdab:exf:ields(varlist} 选项，{p_end}
{phang3}则 {cmd:lianxh} 会同时在 {cmdab:a:uthor}, {cmdab:t:itle}, {cmdab:k:eyword} 三个字段中检索指定关键词。{p_end}    


{marker options}{...}
{title:Options}
{p 8 14 2}

{col 5}{hline 80}
{col 5} {bf:Option} {col 28}{bf:Description}
{col 5}{hline 80}
{col 5}检索字段和时间范围
{col 5}{hline 18} 			 
{col 7}{cmdab:f:ields(varlist)}    {col 28}检索字段, 包括: {cmdab:a:uthor}, {cmdab:c:atname}, {cmdab:t:itle}, {cmdab:k:eyword}
{col 7}{cmdab:ex:clude(string)}   {col 28}需要排除的关键词, e.g. {cmd:ex(Python)}; {cmd:ex(py matlab +)}
{col 7}{cmdab:exf:ields(varlist}  {col 28}需要排除的关键词所在的检索字段, 同 {cmdab:f:ields(varlist)} 选项
{col 7}{cmdab:h:ot(#)}            {col 28}点击次数最多的 # 条, 不能与 {cmd:new(#)} 同时用
{col 7}{cmdab:n:ew(#)}            {col 28}最新的 # 条
{col 7}{cmdab:fr:omto(string)}    {col 28}时间范围, e.g. {cmd:from(2022)}, {cmd:from(2021-10 2023-1)}
{col 7}{cmdab:up:data}            {col 28}强制更新本地数据, 设定 {cmd:new(#)} 选项时自动生效, 耗时 2-3 秒

{col 5}输出内容 
{col 5}{hline 14}  
{col 7}{cmdab:c:licktimes}        {col 28}显示点击次数
{col 7}{cmdab:d:ate}           {col 28}显示发布时间

{col 5}输出风格
{col 5}{hline 14}       
{col 7}{cmdab:s:imple}            {col 28}极简风格. 仅呈现推文标题
{col 7}{cmdab:num:list}           {col 28}显示推文序号. 设定此选项时自动加载 {bf:nocat} 选项
{col 7}{cmdab:br:owse}            {col 28}在浏览器中直接显示检索结果
{col 7}{cmdab:gs:ortby(varlist)}  {col 28}检索结果按照 {help gsort} {it:varlist} 排序. 
{col 30}{it:varlist} 可以是: {cmdab:cl:ick}/{cmdab:v:iew}, {cmdab:d:ate}, {cmdab:a:uthor}, {cmdab:cat:name}, {cmdab:t:itle}
{col 7}{cmdab:m:d}                {col 28}Markdown 格式: {it:- Author, Year, [title](URL), jname No.#. }
{col 7}{cmd:md0}                  {col 28}Markdown 格式: - [Author](url), Year, [title](URL), jname No.#.         
{col 7}{cmd:md1}                  {col 28}Markdown 格式: - [title](URL)
{col 7}{cmd:md2}                  {col 28}Markdown 格式: - Author, Year, [title](URL)
{col 7}{cmd:mdc}                  {col 28}Markdown 正文引用: Author([Year](url_blog))
{col 7}{cmd:mdca}                 {col 28}Markdown 正文引用: [Author](author_link)([Year](url_blog))   
{col 7}{cmdab:l:atex}             {col 28}TeX 格式: Author, Year, \href{URL}{title}, jname No.#.
{col 7}{cmd:lac}                  {col 28}TeX 正文引用: Author(\href{url_blog}{Year})
{col 7}{cmdab:w:eixin}            {col 28}微信格式: Author, Year, title, URL
{col 7}{cmdab:t:ext}              {col 28}普通文本格式, 与 {bf:weixin} 选项等价
{col 7}{cmdab:v:iew}              {col 28}查看存放检索结果的文档 ({bf:.md} 或 {bf:.txt} 格式) 
{col 7}{cmdab:j:name(string)}     {col 28}设定推文专题名称. 默认值：连享会.  
{col 30}e.g. 孔亦泽, 2023, 拟合优度：R2知多少？. 连享会 No.1281.
{col 5}控制和保存 
{col 5}{hline 10}        
{col 7}{cmd:cls}                  {col 28}清屏后显示结果
{col 7}{cmdab:noc:at}             {col 28}不呈现推文分类信息  
{col 7}{cmdab:nor:ange}           {col 28}不呈现检索时段 (很少用)
{col 7}{cmdab:nop:reserve}        {col 28}运行 lianxh 时，不执行 {help preserve} 和 {help restore}。
{col 30}注意：当前内存中的数据会被替换为 lianxh.ado 产生的数据 (很少用)
{col 7}{cmdab:save:topwd}         {col 28}将自动生成的 [_lianxh_temp_out_.md] 文件保存至当前工作路径，否则存入 PLUS 文件夹 (很少用)。
{col 7}{cmd:savedta(string)}      {col 28}保存检索结果原始数据为 Stata 数据文件 (很少用)。
{col 5}{hline 80} 
  

{marker Examples}{...}
{title:Examples}

{pstd}

{col 3}{ul:{bf:o 基本用法}}

{pstd}搜索包含关键词 'RDD' 的推文{p_end}
{phang2}. {stata "lianxh RDD"}{p_end}

{pstd}搜索包含关键词 'RDD' {bf:或} '断点' 的推文{p_end}
{phang2}. {stata "lianxh RDD 断点"}{p_end}

{pstd}搜索包含关键词 'RDD' {bf:和} '断点' 的推文 ('+' 可以放在检索式的任何位置)){p_end}
{phang2}. {stata "lianxh RDD 断点 +"}{p_end}

{pstd}呈现一些常用资源链接，包括：论文重现网站、在线课程等{p_end}
{phang2}. {stata "lianxh, links"}{p_end}

{col 3}{ul:{bf:o 设定检索字段和时间范围}}

{pstd}仅在 '标题' 中检索关键词 'DID'{p_end}
{phang2}. {stata "lianxh DID, field(title)"}{p_end}
{phang2}Note: 默认情况下，同时在 {author title keywords} 三个字段中进行检索。{p_end}

{pstd}搜索所有 '张' 姓作者发表的推文{p_end}
{phang2}. {stata "lianxh 张, f(a)"}{p_end}
{phang2}Note: {cmd:f(a)} 是 {it:field(author)} 的简写。

{pstd}呈现包含关键词 '面板数据'，但 {Author} 和 {keywords} 字段中不包含关键词 '动态' 和 '空间' 的推文{p_end}
{phang2}. {stata "lianxh 面板数据, ex(动态 空间) exfield(t k)"}{p_end}

{pstd}时间范围：2022/1/1 以来{p_end}
{phang2}. {stata "lianxh DID, fromto(2022) d"}{p_end}

{pstd}时间范围：指定起始和结束日期{p_end}
{phang2}. {stata "lianxh 数据, fromto(2023-5-1 2023/10/31)"}{p_end}

{col 3}{ul:{bf:o 最新、最热、排序、点击量和发布时间}}

{pstd}呈现最新发表的十篇推文{p_end}
{phang2}. {stata "lianxh, new(10)"}{p_end}

{pstd}按时间顺序呈现检索结果{p_end}
{phang2}. {stata "lianxh DID RDD, new(200)"}{p_end}

{pstd}呈现点击量最大的十篇推文{p_end}
{phang2}. {stata "lianxh, hot(10)"}{p_end}

{pstd}按点击量大小呈现检索结果{p_end}
{phang2}. {stata "lianxh DID RDD, hot(200)"}{p_end}

{pstd}按点击量由大到小排序，且显示点击次数 ({cmdab:c:licktimes}) 和发布时间 ({cmdab:d:ate}){p_end}
{phang2}. {stata "lianxh 动态面板, gsort(-click) c d"}{p_end}

{pstd}依次按年份和点击量由大到小排序，其它同上{p_end}
{phang2}. {stata "lianxh      DID, gsort(-year -click) c d"}{p_end}

{col 3}{ul:{bf:o 以 Markdown、Text 和 LaTeX 格式输出}}

{pstd}以 Markdown 格式呈现搜索结果 (点击结果窗口中的蓝色 View 链接，复制更方便){p_end}

{phang2}. {stata "lianxh PSM, md"}{p_end}
{phang2}. {stata "lianxh PSM, md0"}{p_end}
{phang2}. {stata "lianxh PSM, mdc"}{p_end}
{phang2}. {stata "lianxh PSM, mdca"}{p_end}

{pstd}更改推文系列名称{p_end}

{phang2}. {stata "lianxh PSM, md nocat jname(我最喜欢的推文)"}{p_end}

{pstd}通过邮件或微信分享推文信息时，可以使用 {cmdab:w:eixin} 或 {cmdab:t:ext} 选项{p_end}

{phang2}. {stata "lianxh binscatter, w"}{p_end}
{phang2}. {stata "lianxh binscatter, t nocat"}{p_end}

{col 3}{ul:{bf:o 其它}}

{pstd}清屏后显示检索结果{p_end}

{phang2}. {stata "lianxh DID, cls"}{p_end}

{pstd}强制更新本地数据{p_end}

{phang2}. {stata "lianxh DID, updata"}{p_end}

{phang2}Note: 默认情况下，{cmd:lianxh} 每天从 {browse "lianxh.cn":https://www.lianxh.cn} 下载一份数据，存储到本地 [../PLUS/l] 文件夹中。随后的检索均使用本地数据，这样可以大幅提高检索速度。
若想更新到最新版，则可以使用 {cmd:updata} 选项。注意：不是 'update'，而是 'updata'。{p_end}

{pstd}{ul:安装最新版}{p_end}

{phang2}. 方式 1：{stata "cnssc install lianxh, replace"}{p_end}

{phang2}. 方式 2：{stata `"net install lianxh, from("https://gitee.com/arlionn/lianxh/raw/master/src/") replace"'}{p_end}


{title:作者}

{phang}
{cmd:Yujun, Lian* (连玉君)} Lingnan College, Sun Yat-Sen University, China.{break}
E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com} {break}
Blog: {browse "https://www.lianxh.cn":lianxh.cn} {break}
{p_end}

{phang}
{cmd:Junjie, Kang (康峻杰)} Shanghai Jiaotong University, China.{break}
E-mail: {browse "mailto:642070192@qq.com":642070192@qq.com} {break}
{p_end}

{phang}
{cmd:Ruihan, Liu (刘芮含)} National University of Singapore, Singapore.{break}
E-mail: {browse "mailto:2428172451@qq.com":2428172451@qq.com} {break}
{p_end}


{title:问题和建议}

{p 4 4 2}
使用中有任何蹩脚之处，我们都会第一时间修改，请电邮至：
{browse "mailto:arlionn@163.com":arlionn@163.com}. 

{p 4 4 2}
你也可以在项目的 {browse "https://github.com/arlionn/lianxh":Github 仓库} 中填写 {browse "https://github.com/arlionn/lianxh/issues/":Issues} 来提交你的建议。


{title:Also see}

{psee} 
Online:  
{help songbl} (if installed),  
{help cnssc} (if installed),  
{help lxhuse} (if installed)
