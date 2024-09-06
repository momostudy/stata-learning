{smcl}
{* 2017年12月21日}
{hline}
{cmd:help stkd}{right: }
{hline}

{title:标题}

{phang}
{bf:stkd} {hline 2} 根据输入的股票代码查询股票的详细信息。{p_end}

{title:语法}

{p 4 18 2}
{cmdab:stkd} {cmd: codelist} {cmd:,} [{cmd:path(}{it:string}{cmd:)} {cmd:{opt s:tore}} {cmd:{opt i:term}}{cmd:(}{it:string}{cmd:)} {cmd:{opt f:mt}}{cmd:(}{it:string}{cmd:)} {cmd: {opt c:ite}}]

{marker description}{...}
{title:描述}

{pstd}{cmd:codelist} 是一列你想要查询详细信息的股票代码列表。如果不足六位，该命令会自动在代码前面加0补齐至六位。如果股票代码多于一个，系统会自动保存信息文件。{p_end}

{marker options}{...}
{title:选项}

{phang}
{cmd:path(}{it:string}{cmd:)}: 指定保存文件的路径，默认为当前工作目录。{p_end}

{phang}
{cmd:{opt s:tore}}: 选择是否要储存股票信息文件，默认不保存。{p_end}

{phang}
{cmd:{opt i:term}}{cmd:(}{it:string}{cmd:)}: 选择要储存股票信息文件的格式，默认为txt格式，指定该选项时会自动保存。{p_end}

{phang}
{opt c:ite}: 如果你需要引用该命令，加上该选项可以显示引用格式。{p_end}

{phang}
{cmd:{opt f:mt}}{cmd:(}{it:string}{cmd:)}: 选择要直接显示出来的股票信息，默认会显示股票的名称。有一下选择，很容易发现，这些都是对应股票信息的拼音缩写：{p_end}

{pstd}{space 1}可选选选项主要分为基础信息、工商信息、经营范围、证券信息、联系方式以及公司简介六类，使用这六个词的拼音缩写就会显示该类别的所有信息，另外可以使用_all选项显示所有的信息。{p_end}

{pstd} {space 2} {hi:_all} 全部信息 {p_end}

{pstd} {space 2} {hi:jcxx} 【基础信息】 {p_end}

{pstd} {space 4} {hi:gpdm} 股票代码 {p_end}
{pstd} {space 4} {hi:gsqc} 公司全称 {p_end}
{pstd} {space 4} {hi:gsywmc} 公司英文名称 {p_end}
{pstd} {space 4} {hi:cym} 曾用名 {p_end}
{pstd} {space 4} {hi:clrq} 成立日期 {p_end}
{pstd} {space 4} {hi:sshy} 所属行业 {p_end}
{pstd} {space 4} {hi:ssgn} 所属概念 {p_end}
{pstd} {space 4} {hi:ssdy} 所属地域 {p_end}
{pstd} {space 4} {hi:fddbr} 法定代表人 {p_end}
{pstd} {space 4} {hi:dlds} 独立董事 {p_end}
{pstd} {space 4} {hi:zxfwjg} 咨询服务机构 {p_end}
{pstd} {space 4} {hi:kjssws} 会计师事务所 {p_end}
{pstd} {space 4} {hi:zqswdb} 证券事务代表 {p_end}

{pstd} {space 2} {hi:jyfw} 【经营范围】 {p_end}

{pstd} {space 4} {hi:jyfw} 经营范围 {p_end}

{pstd} {space 2} {hi:zqxx} 【证券信息】 {p_end}

{pstd} {space 4} {hi:ssrq} 上市日期 {p_end}
{pstd} {space 4} {hi:ssjys} 上市交易所 {p_end}
{pstd} {space 4} {hi:zqlx} 证券类型 {p_end}
{pstd} {space 4} {hi:ltgb} 流通股本 {p_end}
{pstd} {space 4} {hi:zgb} 总股本 {p_end}
{pstd} {space 4} {hi:zcxs} 主承销商 {p_end}
{pstd} {space 4} {hi:fxj} 发行价 {p_end}
{pstd} {space 4} {hi:sssrkpj} 上市首日开盘价 {p_end}
{pstd} {space 4} {hi:sssrzdf} 上市首日涨跌幅 {p_end}
{pstd} {space 4} {hi:sssrhsl} 上市首日换手率 {p_end}
{pstd} {space 4} {hi:tbclhts} 特别处理和退市 {p_end}
{pstd} {space 4} {hi:fxsyl} 发行市盈率 {p_end}
{pstd} {space 4} {hi:zxsyl} 最新市盈率 {p_end}

{pstd} {space 2} {hi:lxfs} 【联系方式】 {p_end}

{pstd} {space 4} {hi:lxdhdm} 联系电话（董秘） {p_end}
{pstd} {space 4} {hi:gscz} 公司传真 {p_end}
{pstd} {space 4} {hi:dzyx} 电子邮箱 {p_end}
{pstd} {space 4} {hi:gswz} 公司网站 {p_end}
{pstd} {space 4} {hi:lxr} 联系人 {p_end}
{pstd} {space 4} {hi:yzbm} 公司邮编 {p_end}

{pstd} {space 2} {hi:gsjj} 【公司简介】 {p_end}

{pstd} {space 4} {hi:gsjj} 公司简介 {p_end}

{marker options}{...}
{title:返回值}

{pstd}在运行完stkd后运行下面的命令可以查看返回值。{p_end}

{phang}
{space 4}{stata `"return list"'}
{p_end}

{pstd}上面所列的每一条信息都储存在返回值里。可以使用r()进行调用。 {p_end}


{title:示例}

{phang}
{stata `"stkd 1"'}
{p_end}
{phang}
{stata `"stkd 2, i(jyfw)"'}
{p_end}
{phang}
{stata `"stkd 4, s"'}
{p_end}
{phang}
{stata `"stkd 5, path(~/Desktop) s"'}
{p_end}
{phang}
{stata `"stkd 6, fmt(dta)"'}
{p_end}
{phang}
{stata `"stkd 7, c"'}
{p_end}
{phang}
{stata `"stkd 1 2 4 7"'}
{p_end}
{phang}
{stata `"stkd 1 2 4 5, fmt(dta)"'}
{p_end}

{title:作者}

{pstd}程振兴{p_end}
{pstd}暨南大学·经济学院·金融学{p_end}
{pstd}中国·广州{p_end}
{pstd}{browse "http://www.czxa.top":个人网站}{p_end}
{pstd}Email {browse "mailto:czxjnu@163.com":czxjnu@163.com}{p_end}

{title:Also see}
{phang}
{stata `"help stkd"'}
{p_end}
