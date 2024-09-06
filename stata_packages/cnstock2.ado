*! 爬取沪市、深市或两市所有上市公司基本情况数据
*! 程振兴 2018年8月10日
*! 用法：
*! 		下载两市所有公司：cnstock2
*! 		下载沪市的：cnstock2, m(SH)
*! 		下载深市的：cnstock2, m(SZ)
*! 沪市：http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=3000&on=2&titType=null&page=1&callback=hxbase_json15
*! 深市：http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=2000&on=1&titType=null&page=1&callback=hxbase_json15
*! 全市场：http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=5000&titType=null&page=1&callback=hxbase_json15
cap prog drop cnstock2
prog def cnstock2
version 14.0
	syntax [, Market(string)]
	if "`market'" == "SH" local url "http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=3000&on=2&titType=null&page=1&callback=hxbase_json15"
	if "`market'" == "SZ" local url "http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=2000&on=1&titType=null&page=1&callback=hxbase_json15"
	if "`market'" == "" local url "http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=5000&titType=null&page=1&callback=hxbase_json15"
	qui{
		if "`c(os)'"=="Windows"{
			!curl "http://stockdata.stock.hexun.com/gszl/data/jsondata/jbgk.ashx?count=5000&titType=null&page=1&callback=hxbase_json15" -o my.txt
			!sed -i "s/{/\n/g" my.txt
		}
		else{
			!curl `url' | tr "{" "\n" > my.txt
		}
		utrans my.txt
		infix strL v 1-20000 using my.txt, clear
		drop in 1/2
		split v, parse(,)
		drop v
		keep v1 v3 v4 v5 v6 v7 v8 v9 v12 v13 v14
		replace v1 = ustrregexs(1) if ustrregexm(v1, `"'(.*)'"')
		label var v1 "序号"
		ren v1 number
		gen code = ustrregexs(1) if ustrregexm(v3, `"\((.*)\)"')
		order number code
		replace v3 = ustrregexs(1) if ustrregexm(v3, `"'(.*)\("')
		label var v3 "公司名称"
		ren v3 name 
		label var code "公司代码"
		replace v4 = ustrregexs(1) if ustrregexm(v4, `"'(.*)'"')
		label var v4 "总股本(亿股)"
		ren v4 total_stock_num
		replace v5 = ustrregexs(1) if ustrregexm(v5, `"'(.*)'"')
		replace v6 = ustrregexs(1) if ustrregexm(v6, `"'(.*)'"')
		replace v7 = ustrregexs(1) if ustrregexm(v7, `"'(.*)'"')
		replace v8 = ustrregexs(1) if ustrregexm(v8, `"'(.*)'"')
		replace v9 = ustrregexs(1) if ustrregexm(v9, `">(.*)<"')
		replace v12 = ustrregexs(1) if ustrregexm(v12, `"">(.*)</a>"')
		replace v13 = ustrregexs(1) if ustrregexm(v13, `"">(.*)</a>"')
		replace v14 = ustrregexs(1) if ustrregexm(v14, `"'(.*)'"')
		replace v14 = ustrregexs(1) if ustrregexm(v12, `"'(.*)'"')
		replace v12 = "" if index(v12, "price")
		replace v13 = "" if index(v13, "view")
		compress
		label var v5 "流通股本(亿股)"
		ren v5 outstanding_stock_num
		label var v6 "流通市值(亿元)"
		ren v6 outstanding_stock_value
		label var v7 "注册资本(万元)"
		ren v7 registered_capital
		label var v8 "市盈率"
		ren v8 pe_ratio
		label var v9 "所属行业"
		ren v9 industry
		label var v12 "所属概念"
		ren v12 concept
		label var v13 "所属地域"
		ren v13 area
		label var v14 "收盘价"
		ren v14 close
		foreach i of varlist _all{
			cap replace `i' = "" if `i' == "--"
		}
		destring number total_stock_num outstanding_stock_num outstanding_stock_value registered_capital pe_ratio close, replace
	}
	di "下载完成！"
	di "数据来源：和讯网"
	erase my.txt
end
