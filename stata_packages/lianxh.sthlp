{smcl}
{* *! version 1.2  17nov2023}{...}
{cmd:help lianxh {stata "help lianxh_cn": 中文版}}
{hline}

{title:Title}

{p2colset 5 16 16 2}{...}
{p2col:{hi: lianxh} {hline 2}}search blogs of {browse "https://www.lianxh.cn/":lianxh.cn}, and show results in Stata's {bf:Results Window} in format of Plain text, Markdown or TeX.
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
{title:Description}

{pstd}
{opt lianxh} makes it easy for users to search blog posts and useful links from within Stata Command Window. It is primarily designed for Chinese users. One can also list common Stata resource links, including Stata official website, Stata 
{browse "https://www.stata.com/support/faqs/":FAQs}, {browse "https://www.statalist.org/forums/":Statalist},
{browse "https://www.stata-journal.com/":Stata Journal},
{browse "https://www.princeton.edu/~otorres/Stata/":Stata online tutorial}, {browse "https://www.lianxh.cn/details/232.html":replication data & programs} etc. 
 
{pstd} If no additional options are specified, {cmd:lianxh} will present the query results in the Stata results window.

{pstd} By setting options such as {cmd:md}, {cmd:text}, etc., you can display the search results in Markdown or txt format, making it convenient for personal notes or sharing with others via WeChat/email.

{pstd} When combined with options such as {opt hot(#)}, {opt new(#)}, {opt fromto()}, you can filter tweets within a specific time range, or present the "most hot" or the "latest" tweets. 
	

{marker syntax}{...}
{title:Syntax}

{p 8 14 2}
{cmd:lianxh}
{bind:[{it:keywords},}
{cmd:options}]

{phang}Note 1: {it:keywords} represents the keywords to be searched and can include multiple keywords. If {it:keywords} is empty, all tweets will be presented. {p_end}

{phang2}o '{it:k1 k2 k3}' indicates that the search terms include '{it:k1}', {bf:or} '{it:k2}', {bf:or} '{it:k3}'; {p_end}
{phang2}o '{it:k1 k2 k3 +}' indicates that the search terms {bf:simultaneously} include '{it:k1}', '{it:k2}', {bf:and} '{it:k3}'.{p_end}

{phang}Note 2: The {cmdab:f:ields(varlist)} and {cmdab:exf:ields(varlist)} options are used to control the inclusion or exclusion of fields in the search.

{phang2}o Available fields include: {cmdab:a:uthor}, {cmdab:t:itle}, {cmdab:k:eyword}, {cmdab:c:atname}, representing the author, title, keyword, and category of tweets, respectively. {p_end}
{phang2}o If the user enters the {cmd:lianxh DID RDD} command without specifying the {cmdab:f:ields(varlist)} and {cmdab:exf:ields(varlist)} options, {cmd:lianxh} will search for the specified keywords in the 
{cmdab:a:uthor}, {cmdab:t:itle}, {cmdab:k:eyword} fields simultaneously. {p_end}


{marker options}{...}
{title:Options}

{p 8 14 2}

{col 5}{hline 80}
{col 5} {bf:Option} {col 28}{bf:Description}
{col 5}{hline 80}
{col 5}Searching Fields and Time Range
{col 5}{hline 32} 			 
{col 7}{cmdab:f:ields(varlist)}    {col 28}Searching Fields, including: {cmdab:a:uthor}, {cmdab:c:atname}, {cmdab:t:itle}, {cmdab:k:eyword}
{col 7}{cmdab:ex:clude(string)}   {col 28}Keywords to be excluded, e.g., {cmd:ex(Python)}; {cmd:ex(py matlab +)}
{col 7}{cmdab:exf:ields(varlist)} {col 28}Fields where the excluded keywords are located, see {cmdab:f:ields(varlist)}
{col 7}{cmdab:h:ot(#)}            {col 28}Top # tweets by clicktimes; conflict with {cmd:new(#)}
{col 7}{cmdab:n:ew(#)}            {col 28}Newest # tweets
{col 7}{cmdab:fr:omto(string)}    {col 28}Time range, e.g., {cmd:from(2022)}, {cmd:from(2021-10 2023-1)}
{col 7}{cmdab:up:data}            {col 28}Force update local data (takes 2-3 seconds)
{col 30}automatically takes effect when {cmd:new(#)} is set.

{col 5}Show click times and date 
{col 5}{hline 26}  
{col 7}{cmdab:c:licktimes}        {col 28}display click times
{col 7}{cmdab:d:ate}              {col 28}display publish date  

{col 5}Style of output
{col 5}{hline 14}        
{col 7}{cmdab:s:imple}            {col 28}Minimalistic style. Displays only tweet titles.
{col 7}{cmdab:num:list}           {col 28}Show tweet numbers. Automatically loads the {bf:nocat} option when set.
{col 7}{cmdab:br:owse}            {col 28}Display search results directly in the browser.
{col 7}{cmdab:gs:ortby(varlist)}  {col 28}Sort search results according to {help gsort} {it:varlist}.
{col 30}{it:varlist} can be one or more of: {cmdab:cl:ick}/{cmdab:v:iew}, {cmdab:d:ate}, {cmdab:a:uthor}, {cmdab:cat:name}, {cmdab:t:itle}
{col 7}{cmdab:m:d}                {col 28}Markdown: {it:- Author, Year, [title](URL), jname No.#. }
{col 7}{cmd:md0}                  {col 28}Markdown: - [Author](url), Year, [title](URL), jname No.#.         
{col 7}{cmd:md1}                  {col 28}Markdown: - [title](URL)
{col 7}{cmd:md2}                  {col 28}Markdown: - Author, Year, [title](URL)
{col 7}{cmd:mdc}                  {col 28}Markdown citation: Author([Year](url_blog))
{col 7}{cmd:mdca}                 {col 28}Markdown citation: [Author](author_link)([Year](url_blog))   
{col 7}{cmdab:l:atex}             {col 28}TeX format: Author, Year, \href{URL}{title}, jname No.#.
{col 7}{cmd:lac}                  {col 28}TeX citation format: Author(\href{url_blog}{Year})
{col 7}{cmdab:w:eixin}            {col 28}WeChat format: Author, Year, title, URL
{col 7}{cmdab:t:ext}              {col 28}Plain text format, same as {bf:weixin}
{col 7}{cmdab:v:iew}              {col 28}view Markdown / text documents
{col 7}{cmdab:j:name(string)}     {col 28}set the name of blog series.

{col 5}Control and Save
{col 5}{hline 10}        
{col 7}{cmd:cls}                  {col 28}clears the Results window first
{col 7}{cmdab:noc:at}             {col 28}Do not display classification information for tweets  
{col 7}{cmdab:nor:ange}           {col 28}Do not display 'time range' information (Rarely used)
{col 7}{cmdab:nop:reserve}        {col 28}When excute lianxh, do not execute {help preserve} and {help restore}
{col 30}Note: Data in current memory will be cleared (Rarely used)
{col 7}{cmdab:save:topwd}         {col 28}Save [_lianxh_temp_out_.md] at current directory. Default: [../PLUS]
{col 7}{cmd:savedta(string)}      {col 28}Save the results as Stata's {bf:.dta} file. (Rarely used)
{col 5}{hline 80} 
  

{marker Examples}{...}
{title:Examples}

{pstd}

{col 3}{ul:{bf:o Basic Usage}}

{pstd}Search for tweets containing the keyword 'RDD'{p_end}
{phang2}. {stata "lianxh RDD"}{p_end}

{pstd}Search for tweets containing either 'RDD' {bf:or} '断点'{p_end}
{phang2}. {stata "lianxh RDD 断点"}{p_end}

{pstd}Search for tweets containing both 'RDD' {bf:and} '断点' (the '+' can be placed anywhere in the search query){p_end}
{phang2}. {stata "lianxh RDD 断点 +"}{p_end}

{pstd}Display some commonly used resource links, including: paper reproduction websites, online courses, etc.{p_end}
{phang2}. {stata "lianxh, links"}{p_end}

{col 3}{ul:{bf:o Set Fields and Time Range}}

{pstd}Search for the keyword 'DID' only in the 'Title' field{p_end}
{phang2}. {stata "lianxh DID, field(title)"}{p_end}
{phang2}Note: By default, searches are conducted in the {author title keywords} fields simultaneously.{p_end}

{pstd}Search for tweets published by authors with the surname '张'{p_end}
{phang2}. {stata "lianxh 张, f(a)"}{p_end}
{phang2}Note: {cmd:f(a)} is shorthand for {it:field(author)}.

{pstd}Display tweets containing the keyword '面板数据,' excluding those with '动态' and '空间' in the {Author} and {keywords} fields{p_end}
{phang2}. {stata "lianxh 面板数据, ex(动态 空间) exfield(t k)"}{p_end}

{pstd}Time Range: Since January 1, 2022{p_end}
{phang2}. {stata "lianxh DID, fromto(2022) d"}{p_end}

{pstd}Time Range: Specify start and end dates{p_end}
{phang2}. {stata "lianxh 数据, fromto(2023-5-1 2023/10/31)"}{p_end}

{col 3}{ul:{bf:o Newest, Hottest, Sorting, Click-through Rate, and Publication Time}}

{pstd}Display the ten latest tweets{p_end}
{phang2}. {stata "lianxh, new(10)"}{p_end}

{pstd}Display search results in chronological order{p_end}
{phang2}. {stata "lianxh DID RDD, new(200)"}{p_end}

{pstd}Display the ten tweets with the highest click-through rate{p_end}
{phang2}. {stata "lianxh, hot(10)"}{p_end}

{pstd}Display search results sorted by click-through rate, showing click times ({cmdab:c:licktimes}) and publication date ({cmdab:d:ate}){p_end}
{phang2}. {stata "lianxh 动态面板, gsort(-click) c d"}{p_end}

{pstd}Sort by year and click-through rate in descending order, others as above{p_end}
{phang2}. {stata "lianxh      DID, gsort(-year -click) c d"}{p_end}

{col 3}{ul:{bf:o Output in Markdown, Text, and LaTeX Formats}}

{pstd}Display search results in Markdown format (click the blue 'View' link in the results window for easier copying){p_end}

{phang2}. {stata "lianxh PSM, md"}{p_end}
{phang2}. {stata "lianxh PSM, md0"}{p_end}
{phang2}. {stata "lianxh PSM, mdc"}{p_end}
{phang2}. {stata "lianxh PSM, mdca"}{p_end}

{pstd}Change the series name of tweets{p_end}

{phang2}. {stata "lianxh PSM, md nocat jname(我最喜欢的推文)"}{p_end}

{pstd}When sharing tweet information via email or WeChat, use the {cmdab:w:eixin} or {cmdab:t:ext} options{p_end}

{phang2}. {stata "lianxh binscatter, w"}{p_end}
{phang2}. {stata "lianxh binscatter, t nocat"}{p_end}

{col 3}{ul:{bf:o Other}}

{pstd}Clear the screen and display search results{p_end}

{phang2}. {stata "lianxh DID, cls"}{p_end}

{pstd}Force update local data{p_end}

{phang2}. {stata "lianxh DID, updata"}{p_end}

{phang2}Note: By default, {cmd:lianxh} downloads data from {browse "lianxh.cn":https://www.lianxh.cn} daily and stores it in the local [../PLUS/l] folder. Subsequent searches use local data, significantly improving search speed. To update to the latest version of local dataset, use the {cmd:updata} option. Hint: It's not 'update,' but 'updata.'{p_end}


{title:Authors}

{phang}
{cmd:Yujun Lian* (连玉君)} Lingnan College, Sun Yat-Sen University, China.{break}
E-mail: {browse "mailto:arlionn@163.com":arlionn@163.com} {break}
Blog: {browse "https://www.lianxh.cn":lianxh.cn} {break}
{p_end}

{phang}
{cmd:Junjie Kang (康峻杰)} Shanghai Jiaotong University, China.{break}
E-mail: {browse "mailto:642070192@qq.com":642070192@qq.com} {break}
{p_end}

{phang}
{cmd:Ruihan Liu (刘芮含)} National University of Singapore, Singapore.{break}
E-mail: {browse "mailto:2428172451@qq.com":2428172451@qq.com} {break}
{p_end}


{title:Questions and Suggestions}

{p 4 4 2}
If you encounter any issues or have suggestions while using the tool, we will address them promptly. Please email us at:
{browse "mailto:arlionn@163.com":arlionn@163.com}.

{p 4 4 2}
You can also submit your suggestions by filling out {browse "https://github.com/arlionn/lianxh/issues/":Issues} in the project's {browse "https://github.com/arlionn/lianxh":GitHub repository}.


{title:Also see}

{psee} 
Online:  
{help songbl} (if installed),  
{help cnssc} (if installed),  
{help lxhuse} (if installed)
