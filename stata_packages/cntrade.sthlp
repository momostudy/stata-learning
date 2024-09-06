{smcl}
{* 24Jul2017}{...}
{cmd:help cntrade}{right: }
{hline}

{title:Title}


{phang}
{bf:cntrade} {hline 2} Downloads historical Market Quotations for a list of stock codes or index codes from Net Ease (a web site providing financial information in China, http://money.163.com/).


{title:Syntax}

{p 8 18 2}
{cmdab:cntrade} {it: codelist} {cmd:,} [{it:options}]

{marker description}{...}
{title:Description}

{pstd}{it:codelist} is a list of stock codes or index codes to be downloaded from Net. They are separated by spaces. For each code, there will be one stata format data file as an output containing all the trading information for that stock.
The code will be the file name, with .dta as the extension. In China, stocks are identified by a six digit numbers, not tickers as in the United States. Examples of codes and the names are as following: {p_end}

{pstd} {hi:Stock Codes and Stock Names:} {p_end}
{pstd} {hi:000001} Pingan Bank  {p_end}
{pstd} {hi:000002} Vank Real Estate Co. Ltd. {p_end}
{pstd} {hi:600000} Pudong Development Bank {p_end}
{pstd} {hi:600005} Wuhan Steel Co. Ltd. {p_end}
{pstd} {hi:900901} INESA Electron Co.,Ltd. {p_end}

{pstd} {hi:Index Codes and Index Names:} {p_end}
{pstd} {hi:000001} The Shanghai Composite Index. {p_end}
{pstd} {hi:000300} CSI 300 Index. {p_end}
{pstd} {hi:399001} Shenzhen Component Index. {p_end}

{pstd}The leading zeros in each code can be omitted. {p_end}

{pstd}{it:path} specifies the folder where the output .dta files are to be saved. {p_end}
{pstd} The folders can be either existed or a new folder.  {p_end}
{pstd} If the folder specified does not exist, {cmd: cntrade} will create it automatically. {p_end}

{marker options}{...}
{title:Options for cntrade}

{phang}
{opt path(foldername)}: specify a folder where output .dta files will be saved in.{p_end}

{phang}
{opt stock}: specify that the list of codes are stock codes, which is the default choice.{p_end}

{phang}
{opt index}: specify that the list of codes are index codes.{p_end}


{title:Examples}

{phang}
{stata `"cntrade 600000"'}
{p_end}
{phang}
{stata `"cntrade 2, stock"'}
{p_end}
{phang}
{stata `"cntrade 600000, path(c:/temp/)"'}
{p_end}
{phang}
{stata `"cntrade 2, path(c:/temp/)"'}
{p_end}
{phang}
{stata `"cntrade 600000 000001 600810"'}
{p_end}
{phang}
{stata `"cntrade 600000 000001 600810, path(c:/temp/)"'}
{p_end}
{phang}
{stata `"cntrade 1, index"'}
{p_end}
{phang}
{stata `"cntrade 1 300, index"'}
{p_end}

{title:Authors}

{pstd}Xuan Zhang{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}zhangx@zuel.edu.cn{p_end}

{pstd}Chuntao Li{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}chtl@zuel.edu.cn{p_end}

{pstd}Yuan Xue{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}
{pstd}xueyuan19920310@163.com{p_end}

{pstd}Yiming Zhou{p_end}
{pstd}China Stata Club(爬虫俱乐部){p_end}
{pstd}Wuhan, China{p_end}

{title:Also see}

{p 4 14 2}
Article: {it:Stata Journal}, volume 14, number 2: {browse "http://www.stata-journal.com/article.html?article=dm0074":dm0074}
