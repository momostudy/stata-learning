*! 下载沪深股票的交易数据
*! 修改自李春涛的cntrade
*! 程振兴 2018年7月13日
cap prog drop cntrade2
prog def cntrade2
	version 14.0
	syntax anything(name = tickers), [Start(string) End(string) Stock Index]
	clear all
	di "正在下载......"
	if "`stock'" != "" & "`index'" != "" {
		disp as error "不能同时指定'stock'和'index'"
		exit 198
	}
	local address "http://quotes.money.163.com/service/chddata.html"
	if "`index'" == "" local field "TCLOSE;HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;TURNOVER;VOTURNOVER;VATURNOVER;TCAP;MCAP"
	else local field "TCLOSE;HIGH;LOW;TOPEN;LCLOSE;CHG;PCHG;VOTURNOVER;VATURNOVER"
	if "`start'" == "" local start 19900101
	if "`end'" == "" local end: disp %dCYND date("`c(current_date)'","DMY")
	foreach name in `tickers' {
		if length("`name'") > 6 {
			disp as error `"`name'不是一个有效的股票代码！"'
			exit 601
		}
		while length("`name'") < 6 {
			local name = "0"+"`name'"
		}
		if "`index'" == "" {
			if `name' >= 600000 local url "`address'?code=0`name'&start=`start'&end=`end'&fields=`field'"
			else local url "`address'?code=1`name'&start=`start'&end=`end'&fields=`field'"
		}
		else {
			if `name'<=1000 local url "`address'?code=0`name'&start=`start'&end=`end'&fields=`field'"
			else local url "`address'?code=1`name'&start=`start'&end=`end'&fields=`field'"
		}
		qui cap copy `"`url'"' tempcsvfile.csv, replace
		local times = 0
		while _rc ~= 0 {
			local times = `times' + 1
			sleep 1000
			qui cap copy `"`url'"' tempcsvfile.csv, replace
			if `times' > 10 {
				disp as error "网络速度过慢！"
				exit 601
			}
		}
		clear
		qui{
			utrans tempcsvfile.csv
			insheet using tempcsvfile.csv, clear
			if `=_N' == 0 {
				disp as error `"`name'不是一个有效的股票代码！"'
				clear
				cap erase tempcsvfile.csv
				exit 601
			}
			if "`index'" == "" {
				gen date = date(日期, "YMD")
				drop 日期
				format date %dCY-N-D
				label var date "日期"
				rename 股票代码 code
				capture destring code, replace force ignor(')
				label var code "股票代码"
				rename 名称 name
				label var name "股票名称"
				rename 收盘价 close
				label var close "收盘价"
				drop if close == 0
				rename 最高价 high
				label var high  "最高价"
				rename 最低价 low
				label var low "最低价"
				rename 开盘价 open
				label var open "开盘价"
				destring 涨跌幅, replace force
				rename 涨跌幅 rit
				replace rit = 0.01 * rit
				label var rit "日收益率"
				rename 换手率 turnover
				label var turnover "换手率"
				rename 成交量 volume
				label var volume "交易量"
				rename 成交金额 transaction
				label var transaction "交易额(RMB)"
				rename 总市值 tcap
				label var tcap "总市值"
				rename 流通市值 mcap
				label var mcap "流通市值"
				drop 前收盘 涨跌额
				order code date
			}
			else {
				gen date = date(日期, "YMD")
				drop 日期
				format date %dCY-N-D
				label var date "日期"
				rename 股票代码 code
				capture destring code, replace force ignor(')
				label var code "指数代码"
				rename 名称 name
				label var name "指数名称"
				rename 收盘价 close
				label var close "收盘价"
				drop if close == 0
				rename 最高价 high
				label var high  "最高价"
				rename 最低价 low
				label var low "最低价"
				rename 开盘价 open
				label var open "开盘价"
				destring 涨跌幅, replace force
				rename 涨跌幅 rmt
				replace rmt = 0.01*rmt
				label var rmt "日收益率"
				rename 成交量 volume
				label var volume "交易量"
				rename 成交金额 transaction
				label var transaction "交易额(RMB)"
				drop 前收盘 涨跌额
				order code date
			}
			gsort date
		}
		noi di in yellow "数据来源：网易财经"
		noi di in yellow "下载已完成！"
		cap erase tempcsvfile.csv
	}
end 
