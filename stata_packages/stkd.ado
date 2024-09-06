*! 0.0.0.9000 程振兴 2017年12月22日
program drop _all
program define stkd, rclass
	version 14.0
	syntax anything(name = firms),[ path(string) Store Iterm(string) Fmt(string) Cite]
	if index("`firms'", " "){
		local store = "store"
	}
	if "`iterm'" == ""{
		local iterm = "gsjc"
	}
	if "`fmt'" != ""{
		local store = "store"
	}
	if "`fmt'" == ""{
		local fmt = "txt"
	}
	if "`fmt'" != "dta" & "`fmt'" != "txt"{
		di "你只能选择txt和dta两种输出格式"
	}
	if "`iterm'" == "jcxx"{
		local iterm = "基础信息"
	}
	if "`iterm'" == "gpdm"{
		local iterm = "股票代码"
	}
	if "`iterm'" == "gsqc"{
		local iterm = "公司全称"
	}
	if "`iterm'" == "gsywmc"{
		local iterm = "公司英文名称"
	}
	if "`iterm'" == "cym"{
		local iterm = "曾用名"
	}
	if "`iterm'" == "clrq"{
		local iterm = "成立日期"
	}
	if "`iterm'" == "sshy"{
		local iterm = "所属行业"
	}
	if "`iterm'" == "ssgn"{
		local iterm = "所属概念"
	}
	if "`iterm'" == "ssdy"{
		local iterm = "所属地域"
	}
	if "`iterm'" == "fddbr"{
		local iterm = "法定代表人"
	}
	if "`iterm'" == "dlds"{
		local iterm = "独立董事"
	}
	if "`iterm'" == "zxfwjg"{
		local iterm = "咨询服务机构"
	}
	if "`iterm'" == "kjsws"{
		local iterm = "会计师事务所"
	}
	if "`iterm'" == "zqswdb"{
		local iterm = "证券事务代表"
	}
	if "`iterm'" == "gsxx"{
		local iterm = "工商信息"
	}
	if "`iterm'" == "zczb"{
		local iterm = "注册资本"
	}
	if "`iterm'" == "zcdz"{
		local iterm = "注册地址"
	}
	if "`iterm'" == "sdsl"{
		local iterm = "所得税率"
	}
	if "`iterm'" == "bgdz"{
		local iterm = "办公地址"
	}
	if "`iterm'" == "zycp"{
		local iterm = "主要产品(业务)"
	}
	if "`iterm'" == "jyfw"{
		local iterm = "经营范围"
	}
	if "`iterm'" == "zqxx"{
		local iterm = "证券信息"
	}
	if "`iterm'" == "ssrq"{
		local iterm = "上市日期"
	}
	if "`iterm'" == "ssjys"{
		local iterm = "上市交易所"
	}
	if "`iterm'" == "zqlx"{
		local iterm = "证券类型"
	}
	if "`iterm'" == "ltgb"{
		local iterm = "流通股本"
	}
	if "`iterm'" == "zgb"{
		local iterm = "总股本"
	}
	if "`iterm'" == "zcxs"{
		local iterm = "主承销商"
	}
	if "`iterm'" == "fxj"{
		local iterm = "发行价"
	}
	if "`iterm'" == "sssrkpj"{
		local iterm = "上市首日开盘价"
	}
	if "`iterm'" == "sssrzdf"{
		local iterm = "上市首日涨跌幅"
	}
	if "`iterm'" == "sssrhsl"{
		local iterm = "上市首日换手率"
	}
	if "`iterm'" == "tbclhts"{
		local iterm = "特别处理和退市"
	}
	if "`iterm'" == "fxsyl"{
		local iterm = "发行市盈率"
	}
	if "`iterm'" == "zxsyl"{
		local iterm = "最新市盈率"
	}
	if "`iterm'" == "lxfs"{
		local iterm = "联系方式"
	}
	if "`iterm'" == "lxdhdm"{
		local iterm = "联系电话(董秘)"
	}
	if "`iterm'" == "gscz"{
		local iterm = "公司传真"
	}
	if "`iterm'" == "dzyx"{
		local iterm = "电子邮箱"
	}
	if "`iterm'" == "gswz"{
		local iterm = "公司网址"
	}
	if "`iterm'" == "lxr"{
		local iterm = "联系人"
	}
	if "`iterm'" == "yzbm"{
		local iterm = "邮政编码"
	}
	if "`iterm'" == "gsjj"{
		local iterm = "公司简介"
	}
	clear 
	qui set more off, permanently
	* 我要永远地为你设置set more off
	local itermtemp = "`iterm'"
	foreach stkcode in `firms'{
		local iterm = "`itermtemp'"
		clear
		while length("`stkcode'") < 6{
			local stkcode = "0" + "`stkcode'"
		}
		if length("`stkcode'") > 6{
			di as error "你输入的`stkcode'并不是一个有效的股票代码！"
			exit 601
		}
		if index("`path'", " "){
			local path = subistr("`path'", " ", "_")
			cap mkdir `path'
		}
		if "`path'" != ""{
			cap mkdir `path'
		}
		if "`path'" == ""{
			local path = "`c(pwd)'"
			di "你当前的工作目录为`path'。"
		}
		qui cap copy "http://stockdata.stock.hexun.com/gszl/s`stkcode'.shtml" temp.txt, replace
		local times = 0
		while _rc != 0 {
			local times = `times' + 1
			sleep 1000
			qui cap copy "http://stockdata.stock.hexun.com/gszl/s`stkcode'.shtml" temp.txt, replace
			if `times' > 10 {
				disp as error "错误！：因为你的网络速度贼慢或输入的代码`stkcode'不是一个有效的代码，无法获得数据"
				exit 601
			}
		}
		cap unicode encoding set gb18030
		cap unicode translate temp.txt
		cap unicode erasebackups, badidea
		qui infix strL v 1-20000 using temp.txt, clear
		if `=_N' == 0 {
			disp as error `"错误！：`name'是一个无效的股票代码"'
			clear
			cap erase temp.txt
			if _rc != 0 {
				! del temp.txt /F
			}
			exit 601
		}
		qui{
			keep if index(v, "<td") | index(v, `"<p class="text_x">"') | index(v, `"<h5 class="tit02">"') | index(v, "table cellspacing")
			replace v  = ustrregexs(1) if ustrregexm(v, ">(.*)<")
			replace v  = ustrregexs(1) if ustrregexm(v, ">(.*)<")
			gen v1 = ""
			replace v1 = v[_n+1] if mod(_n, 2) == 1
			drop if v1 == ""
			format v %-15s
			format v1 %-25s
			split v1 if index(v1, "<a href"), parse(</a> "_blank" >)
			foreach i of varlist _all{
				levelsof `i', local(a)
				if ustrregexm(`a',"[\u4e00-\u9fa5]+") == 0 & "`i'" != "v" & "`i'" != "v1"{
					drop `i'
				}	
			}
			drop v11
			replace v1 = ustrregexs(0) if ustrregexm(v1,"[\u4e00-\u9fa5]+") & index(v1, "<a href")
			foreach i of varlist _all{
				replace `i' = subinstr(`i'," ","",.)
				if "`i'" != "v" & "`i'" != "v1"{
					format `i' %-8s
				}
			}
			replace v1 = "" if v1 == `"<tablecellspacing="0"cellpadding="0"class="tab_xtable">"'
			foreach m of varlist _all{
				if "`m'" != "v" & "`m'" != "v1"{
					replace v1 = v1 + " " + `m'
					drop `m'
				}
			}
			replace v = "【基础信息】" if v == "基础信息"
			replace v = "【工商信息】" if v == "工商信息"
			replace v = "【经营范围】" if v == "经营范围"
			replace v = "【联系方式】" if v == "联系方式"
			replace v = "【证券信息】" if v == "证券信息"
			replace v = "【公司简介】" if v == "公司简介"
			compress	
		}
		rename v 项目
		rename v1 信息

		if "`store'" != ""{
			if "`fmt'" == "txt"{
				qui outfile using "`path'/`stkcode'.txt", replace noq nol
				di "`stkcode'.`fmt'文件已经被保存在`path'下"
			}
			if "`fmt'" == "dta"{
				qui save "`path'/`stkcode'.dta", replace
				di "`stkcode'.`fmt'文件已经被保存在`path'下"
			}
		}
		if "`iterm'" == "基础信息"{
			local iterm = "【基础信息】 股票代码 公司全称 公司英文名称 曾用名 成立日期 所属行业 所属概念 所属地域 法定代表人 独立董事 咨询服务机构 会计师事务所 证券事务代表"
		}
		if "`iterm'" == "工商信息"{
			local iterm = "【工商信息】 注册资本 注册地址 所得税率 办公地址 主要产品(业务)"
		}
		if "`iterm'" == "经营范围"{
			local iterm = "【经营范围】"
		}
		if "`iterm'" == "证券信息"{
			local iterm = "【证券信息】上市日期
 上市交易所 证券类型 流通股本 总股本 主承销商 发行价 上市首日开盘价 上市首日涨跌幅 上市首日换手率 特别处理和退市 发行市盈率 最新市盈率"
		}
		if "`iterm'" == "联系方式"{
			local iterm = "【联系方式】联系电话(董秘) 公司传真 电子邮箱 公司网址 联系人 邮政编码"
		}
		if "`iterm'" == "公司简介"{
			local iterm = "【公司简介】"
		}
		if "`iterm'" == "_all"{
			local iterm = "【基础信息】 股票代码 公司全称 公司英文名称 曾用名 成立日期 所属行业 所属概念 所属地域 法定代表人 独立董事 咨询服务机构 会计师事务所 证券事务代表 【工商信息】 注册资本 注册地址 所得税率 办公地址 主要产品(业务) 【经营范围】【证券信息】上市日期 上市交易所 证券类型 流通股本 总股本 主承销商 发行价 上市首日开盘价 上市首日涨跌幅 上市首日换手率 特别处理和退市 发行市盈率 最新市盈率 【联系方式】联系电话(董秘) 公司传真 电子邮箱 公司网址 联系人 邮政编码 【公司简介】"
		}
		local iterm = "公司简称 `iterm'"
		forval i = 1/`=_N'{
			foreach j in `iterm'{
				if 项目[`i'] == "`j'"{
					global information = 信息[`i'] 
					di "`j': $information"
				}
			}
		}
		global allvar = "公司简称 股票代码 公司全称 公司英文名称 曾用名 成立日期 所属行业 所属概念 所属地域 法定代表人 独立董事 咨询服务机构 会计师事务所 证券事务代表 注册资本 注册地址 所得税率 办公地址 主要产品(业务) 【经营范围】 上市日期 上市交易所 证券类型 流通股本 总股本 主承销商 发行价 上市首日开盘价 上市首日涨跌幅 上市首日换手率 特别处理和退市 发行市盈率 最新市盈率 联系电话(董秘) 公司传真 电子邮箱 公司网址 联系人 邮政编码 【公司简介】"
		forval i = 1/`=_N'{
			foreach j in $allvar{
				if 项目[`i'] == "`j'"{
					local temp = 信息[`i']
					if "`j'" == "【经营范围】"{
						local j = "经营范围"
					}
					if "`j'" == "【公司简介】"{
						local j = "公司简介"
					}
					return local `j' = "`temp'"
				}
			}
		}
	}
	if "`cite'" != ""{
		di as yellow "程振兴. stkdetail: 根据输入的股票代码查询股票的详细信息. version: 0.0.0.9000 2017.12.22"
	}
	cap erase temp.txt
end
