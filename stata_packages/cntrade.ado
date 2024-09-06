* Authors:
* Xuan Zhang, China Stata Club(爬虫俱乐部)(zhangx@zuel.edu.cn)
* Chuntao Li, Ph.D. , China Stata Club(爬虫俱乐部)(chtl@zuel.edu.cn)
* Yuan Xue, China Stata Club(爬虫俱乐部)(xueyuan19920310@163.com)
* Yiming Zhou, China Stata Club(爬虫俱乐部)
* Updated on July 31th, 2023
* Fix some bugs
* Please do not use this code for commerical purpose

program define cntrade

        if _caller() < 17.0 {
			disp as error "this is version `=_caller()' of Stata; it cannot run version 17.0 programs"
            exit 9
        }

        syntax anything(name = tickers), [path(string) stock index]
		
		if "`stock'" != "" & "`index'" != "" {
			disp as error "you can not specify both 'stock' and 'index'"
            exit 198
        }
		
		if "`path'" != "" {
			cap mkdir `"`path'"'
        }
        else {
            local path `"`c(pwd)'"'
            di `"`path'"'
        }
        if regexm("`path'", "(/|\\)$") { 
            local path = regexr("`path'", ".$", "")
        }
		
		qui{
			if "`index'" == "" {
				clear
				foreach name in `tickers' {
					if length("`name'") > 6 {
						disp as error `"`name' is an invalid stock code"'
						exit 601
					} 
					while length("`name'") < 6 {
						local name = "0" + "`name'"
					}
					
					
					if substr("`name'", 1, 1) == "6" {
						clear
						set obs 1
						gen v = fileread("http://27.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery351024246993129812155_1678685405378&secid=1.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=0&end=20500101&lmt=1000000&_=1678685405397")
						if index(v, `""data":null"') {
							disp as error `"`name' is an invalid stock code"'
							clear
							exit 601
						}
						else{
							replace v = ustrregexs(1) if ustrregexm(v, `""data":\{(.*?)\}\}"')
							gen 股票代码 = ustrregexs(1) if ustrregexm(v, `""code":"(.*?)""')
							gen 股票名称 = ustrregexs(1) if ustrregexm(v, `""name":"(.*?)""')
							rename 股票代码 stkcd
							label var stkcd "Stock Code"
							drop v
							save `"`path'/cntrade1`name'name+code"' ,replace
							clear
							set obs 1
							gen v = fileread("http://27.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery351024246993129812155_1678685405378&secid=1.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=0&end=20500101&lmt=1000000&_=1678685405397")
							replace v = ustrregexs(1) if ustrregexm(v, `""data":\{(.*?)\}\}"')
							replace v = ustrregexs(1) if ustrregexm(v, `""klines":\[(.*?)\]"')
							mata sprexdata()
							replace v = subinstr(v, `"""', "", .)
							split v, p(",")
							drop v
							rename (v1-v11) (日期 开盘价 收盘价 最高价 最低价 成交量 成交额_元 振幅 涨跌幅 涨跌额 换手率)
							gen 股票代码 = "`name'"
							rename 股票代码 stkcd
							label var stkcd "Stock Code"
							merge m:n stkcd using `"`path'/cntrade1`name'name+code"'
							drop _merge
							rename 股票名称 stknme
							label var stknme "Stock Name"
							gen date = date(日期, "YMD")
							drop 日期 
							format date %dCY-N-D
							label var date "Trading Date"
							rename 收盘价 clsprc
							label var clsprc "Closing Price"
							rename 最高价 hiprc
							label var hiprc  "Highest Price"
							rename 最低价 lowprc
							label var lowprc "Lowest Price"
							rename 开盘价 opnprc
							label var opnprc "Opening Price"
							destring 涨跌幅, replace force
							rename 涨跌幅 rit
							replace rit = 0.01 * rit
							label var rit "Daily Return"
							destring 换手率, replace force
							rename 换手率 turnover
							label var turnover "Turnover rate"
							rename 成交量 volume
							label var volume "Trading Volume"
							rename 成交额_元 transaction
							label var transaction "Trading Amount in RMB"
							rename 振幅 amplitude
							label var amplitude "Stock Amplitude"	
							order date, before(opnprc)
							order stkcd, before(date)
							order stknme, before(date)
							drop 涨跌额
							destring stkcd clsprc hiprc lowprc opnprc rit turnover volume transaction amplitude, replace
							save `"`path'/`name'"', replace
							erase `"`path'/cntrade1`name'name+code.dta"'
							noi disp as text `"file `name'.dta has been saved"'
						}
					}
					else if substr("`name'", 1, 1) == "3" | substr("`name'", 1, 1) == "0" {
						clear
						set obs 1
						gen v = fileread("http://19.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery3510056958582213559206_1678685522475&secid=0.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=0&end=20500101&lmt=1000000&_=1678685522488")
						if index(v, `""data":null"') {
							disp as error `"`name' is an invalid stock code"'
							clear
							exit 601
						}
						else{
							replace v = ustrregexs(1) if ustrregexm(v, `""data":\{(.*?)\}\}"')
							gen 股票代码 = ustrregexs(1) if ustrregexm(v, `""code":"(.*?)""')
							gen 股票名称 = ustrregexs(1) if ustrregexm(v, `""name":"(.*?)""')
							rename 股票代码 stkcd
							label var stkcd "Stock Code"
							drop v
							save `"`path'/cntrade1`name'name+code"',replace
							clear
							set obs 1
							gen v = fileread("http://19.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery3510056958582213559206_1678685522475&secid=0.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=0&end=20500101&lmt=1000000&_=1678685522488")
							replace v = ustrregexs(1) if ustrregexm(v, `""data":\{(.*?)\}\}"')
							replace v = ustrregexs(1) if ustrregexm(v, `""klines":\[(.*?)\]"')
							mata sprexdata()
							replace v = subinstr(v, `"""', "", .)
							split v, p(",")
							drop v
							rename (v1-v11) (日期 开盘价 收盘价 最高价 最低价 成交量 成交额_元 振幅 涨跌幅 涨跌额 换手率)
							gen 股票代码 = "`name'"
							rename 股票代码 stkcd
							label var stkcd "Stock Code"
							merge m:n stkcd using `"`path'/cntrade1`name'name+code"'
							drop _merge
							rename 股票名称 stknme
							label var stknme "Stock Name"
							gen date = date(日期, "YMD")
							drop 日期 
							format date %dCY-N-D
							label var date "Trading Date"
							rename 收盘价 clsprc
							label var clsprc "Closing Price"
							rename 最高价 hiprc
							label var hiprc  "Highest Price"
							rename 最低价 lowprc
							label var lowprc "Lowest Price"
							rename 开盘价 opnprc
							label var opnprc "Opening Price"
							destring 涨跌幅, replace force
							rename 涨跌幅 rit
							replace rit = 0.01 * rit
							label var rit "Daily Return"
							destring 换手率, replace force
							rename 换手率 turnover
							label var turnover "Turnover rate"
							rename 成交量 volume
							label var volume "Trading Volume"
							rename 成交额_元 transaction
							label var transaction "Trading Amount in RMB"
							rename 振幅 amplitude
							label var amplitude "Stock Amplitude"
							order date, before(opnprc)
							order stkcd, before(date)
							order stknme, before(date)
							drop 涨跌额
							destring stkcd clsprc hiprc lowprc opnprc rit turnover volume transaction amplitude, replace
							save `"`path'/`name'"', replace
							erase `"`path'/cntrade1`name'name+code.dta"'
							noi disp as text `"file `name'.dta has been saved"'
						}
					}
					else{
						clear
						set obs 1
						gen v = fileread("http://84.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery3510968727779669946_1678686173887&secid=0.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=0&beg=0&end=20500101&smplmt=460&lmt=1000000&_=1678686173909")
						if index(v, `""data":null"') {
							disp as error `"`name' is an invalid stock code"'
							clear
							exit 601
						}
						else{
							replace v = ustrregexs(1) if ustrregexm(v, `""data":\{(.*?)\}\}"')
							gen 股票代码 = ustrregexs(1) if ustrregexm(v, `""code":"(.*?)""')
							gen 股票名称 = ustrregexs(1) if ustrregexm(v, `""name":"(.*?)""')
							rename 股票代码 stkcd
							label var stkcd "Stock Code"
							drop v
							save `"`path'/cntrade1`name'name+code"',replace
							clear
							set obs 1
							gen v = fileread("http://84.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery3510968727779669946_1678686173887&secid=0.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=0&beg=0&end=20500101&smplmt=460&lmt=1000000&_=1678686173909")
							replace v = ustrregexs(1) if ustrregexm(v, `""data":\{(.*?)\}\}"')
							replace v = ustrregexs(1) if ustrregexm(v, `""klines":\[(.*?)\]"')
							mata sprexdata()
							replace v = subinstr(v, `"""', "", .)
							split v, p(",")
							drop v
							rename (v1-v11) (日期 开盘价 收盘价 最高价 最低价 成交量 成交额_元 振幅 涨跌幅 涨跌额 换手率)
							gen 股票代码 = "`name'"
							rename 股票代码 stkcd
							label var stkcd "Stock Code"
							merge m:n stkcd using `"`path'/cntrade1`name'name+code"'
							drop _merge
							rename 股票名称 stknme
							label var stknme "Stock Name"
							gen date = date(日期, "YMD")
							drop 日期 
							format date %dCY-N-D
							label var date "Trading Date"
							rename 收盘价 clsprc
							label var clsprc "Closing Price"
							rename 最高价 hiprc
							label var hiprc  "Highest Price"
							rename 最低价 lowprc
							label var lowprc "Lowest Price"
							rename 开盘价 opnprc
							label var opnprc "Opening Price"
							destring 涨跌幅, replace force
							rename 涨跌幅 rit
							replace rit = 0.01 * rit
							label var rit "Daily Return"
							destring 换手率, replace force
							rename 换手率 turnover
							label var turnover "Turnover rate"
							rename 成交量 volume
							label var volume "Trading Volume"
							rename 成交额_元 transaction
							label var transaction "Trading Amount in RMB"
							rename 振幅 amplitude
							label var amplitude "Stock Amplitude"
							order date, before(opnprc)
							order stkcd, before(date)
							order stknme, before(date)
							drop 涨跌额
							destring stkcd clsprc hiprc lowprc opnprc rit turnover volume transaction amplitude, replace
							save `"`path'/`name'"', replace
							erase `"`path'/cntrade1`name'name+code.dta"'
							noi disp as text `"file `name'.dta has been saved"'
						}
					}
				}
			}
			else {
				clear
				foreach name in `tickers' {
					if length("`name'") > 6 {
						disp as error `"`name' is an invalid index code"'
						exit 601
					} 
					while length("`name'") < 6 {
						local name = "0" + "`name'"
					}
					local name = upper("`name'")
					
					if substr("`name'", 1, 1) == "0"{
						clear
						set obs 1
						gen v = fileread("http://48.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery351033576689053281017_1678698715543&secid=1.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=1&end=20500101&lmt=1000000&_=1678698715599")
						if index(v, `""data":null"') {
							replace v = fileread("http://24.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery351048262960307484604_1678860581048&secid=2.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=1&end=20500101&lmt=1000000&_=1678860581084")
							if index(v, `""data":null"') {
							disp as error `"`name' is an invalid index code"'
							clear
							exit 601
							}
						}
						replace v = ustrregexs(1) if ustrregexm(v, `""data":\{(.*?)\}\}"')
						gen 股票代码 = ustrregexs(1) if ustrregexm(v, `""code":"(.*?)""')
						gen 股票名称 = ustrregexs(1) if ustrregexm(v, `""name":"(.*?)""')
						rename 股票代码 indexcd
						label var indexcd "Index Code"
						drop v
						save `"`path'/cntrade1index`name'name+code"' ,replace
						clear
						set obs 1
						gen v = fileread("http://48.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery351033576689053281017_1678698715543&secid=1.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=1&end=20500101&lmt=1000000&_=1678698715599")
						if index(v, `""data":null"') {
							replace v = fileread("http://24.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery351048262960307484604_1678860581048&secid=2.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=1&end=20500101&lmt=1000000&_=1678860581084")
							if index(v, `""data":null"') {
							disp as error `"`name' is an invalid index code"'
							clear
							exit 601
							}
						}
						replace v = ustrregexs(1) if ustrregexm(v, `""data":\{(.*?)\}\}"')
						replace v = ustrregexs(1) if ustrregexm(v, `""klines":\[(.*?)\]"')
						mata sprexdata()
						replace v = subinstr(v, `"""', "", .)
						split v, p(",")
						drop v
						rename (v1-v11) (日期 开盘价 收盘价 最高价 最低价 成交量 成交额_元 振幅 涨跌幅 涨跌额 换手率)
						gen 股票代码 = "`name'"
						rename 股票代码 indexcd
						label var indexcd "Index Code"
						merge m:n indexcd using `"`path'/cntrade1index`name'name+code"'
						drop _merge
						rename 股票名称 indexnme
						label var indexnme "Index Name"
						gen date = date(日期, "YMD")
						drop 日期 
						format date %dCY-N-D
						label var date "Trading Date"
						rename 收盘价 clsprc
						label var clsprc "Closing Price"
						rename 最高价 hiprc
						label var hiprc  "Highest Price"
						rename 最低价 lowprc
						label var lowprc "Lowest Price"
						rename 开盘价 opnprc
						label var opnprc "Opening Price"
						destring 涨跌幅, replace force
						rename 涨跌幅 rmt
						replace rmt = 0.01 * rmt
						label var rmt "Daily Return"
						destring 换手率, replace force
						rename 换手率 turnover
						label var turnover "Turnover rate"
						rename 成交量 volume
						label var volume "Trading Volume"
						rename 成交额_元 transaction
						label var transaction "Trading Amount in RMB"
						rename 振幅 amplitude
						label var amplitude "Stock Amplitude"	
						order date, before(opnprc)
						order indexcd, before(date)
						order indexnme, before(date)
						drop 涨跌额
						destring indexcd clsprc hiprc lowprc opnprc rmt turnover volume transaction amplitude, replace
						save `"`path'/index`name'"', replace
						erase `"`path'/cntrade1index`name'name+code.dta"'
						noi disp as text `"file index`name'.dta has been saved"'
					}
					else {
						if substr("`name'", 1, 1) == "3" & substr("`name'", 1, 2) != "39" {
							disp as error `"`name' is an invalid index code"'
							clear
							exit 601
						}
						else if substr("`name'", 1, 1) == "4" & substr("`name'", 1, 2) <= "46" {
							disp as error `"`name' is an invalid index code"'
							clear
							exit 601
						}
						else if substr("`name'", 1, 1) == "9" & substr("`name'", 1, 2) <= "92" {
							disp as error `"`name' is an invalid index code"'
							clear
							exit 601
						}
						else {
							clear
							set obs 1
							gen v = fileread("http://60.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery35103438952136795024_1678862753156&secid=0.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=1&end=20500101&lmt=1000000&_=1678862753211")
							if index(v, `""data":null"') {
								replace v = fileread("http://13.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery351030565369962624667_1678861304295&secid=2.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=1&end=20500101&lmt=1000000&_=1678861304488")
								if index(v, `""data":null"') {
									disp as error `"`name' is an invalid index code"'
									clear
									exit 601
								}
							}
							replace v = ustrregexs(1) if ustrregexm(v, `""data":\{(.*?)\}\}"')
							gen 股票代码 = ustrregexs(1) if ustrregexm(v, `""code":"(.*?)""')
							gen 股票名称 = ustrregexs(1) if ustrregexm(v, `""name":"(.*?)""')
							rename 股票代码 indexcd
							label var indexcd "Index Code"
							drop v
							save `"`path'/cntrade1index`name'name+code"',replace
							clear
							set obs 1
							gen v = fileread("http://60.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery35103438952136795024_1678862753156&secid=0.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=1&end=20500101&lmt=1000000&_=1678862753211")
							if index(v, `""data":null"') {
								replace v = fileread("http://13.push2his.eastmoney.com/api/qt/stock/kline/get?cb=jQuery351030565369962624667_1678861304295&secid=2.`name'&ut=fa5fd1943c7b386f172d6893dbfba10b&fields1=f1,f2,f3,f4,f5,f6&fields2=f51,f52,f53,f54,f55,f56,f57,f58,f59,f60,f61&klt=101&fqt=1&end=20500101&lmt=1000000&_=1678861304488")
								if index(v, `""data":null"') {
								disp as error `"`name' is an invalid index code"'
								clear
								exit 601
								}
							}
							replace v = ustrregexs(1) if ustrregexm(v, `""data":\{(.*?)\}\}"')
							replace v = ustrregexs(1) if ustrregexm(v, `""klines":\[(.*?)\]"')
							mata sprexdata()
							replace v = subinstr(v, `"""', "", .)
							split v, p(",")
							drop v
							rename (v1-v11) (日期 开盘价 收盘价 最高价 最低价 成交量 成交额_元 振幅 涨跌幅 涨跌额 换手率)
							gen 股票代码 = "`name'"
							rename 股票代码 indexcd
							label var indexcd "Index Code"
							merge m:n indexcd using `"`path'/cntrade1index`name'name+code"'
							drop _merge
							rename 股票名称 indexnme
							label var indexnme "Index Name"
							gen date = date(日期, "YMD")
							drop 日期 
							format date %dCY-N-D
							label var date "Trading Date"
							rename 收盘价 clsprc
							label var clsprc "Closing Price"
							rename 最高价 hiprc
							label var hiprc  "Highest Price"
							rename 最低价 lowprc
							label var lowprc "Lowest Price"
							rename 开盘价 opnprc
							label var opnprc "Opening Price"
							destring 涨跌幅, replace force
							rename 涨跌幅 rmt
							replace rmt = 0.01 * rmt
							label var rmt "Daily Return"
							destring 换手率, replace force
							rename 换手率 turnover
							label var turnover "Turnover rate"
							rename 成交量 volume
							label var volume "Trading Volume"
							rename 成交额_元 transaction
							label var transaction "Trading Amount in RMB"
							rename 振幅 amplitude
							label var amplitude "Stock Amplitude"	
							order date, before(opnprc)
							order indexcd, before(date)
							order indexnme, before(date)
							drop 涨跌额
							destring indexcd clsprc hiprc lowprc opnprc rmt turnover volume transaction amplitude, replace
							save `"`path'/index`name'"', replace
							erase `"`path'/cntrade1index`name'name+code.dta"'
							noi disp as text `"file index`name'.dta has been saved"'
						}
					}
				}
			}	
		}
end


mata
void function sprexdata() {
    
    string matrix A
        string matrix B
        
        A = st_sdata(., "v", .)
        B = substr(A, 1, strpos(A, `"",""') - 1)
        A = subinstr(A, B + `"",""', "", 1)
        do {
			B = B, substr(A, 1, strpos(A, `"",""') - 1)
			A = subinstr(A, B[1, cols(B)] + `"",""', "", 1)
        } while (strpos(A, `"",""') != 0)
        B = B, A
        stata("drop in 1")
        st_addobs(cols(B))
        st_sstore(., "v", B')
}
end
