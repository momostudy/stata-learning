*! 绘制股价棒状图
*! 程振兴 2018年7月13日
*! stkpv2 2
cap prog drop stkpv2
prog def stkpv2
	syntax anything(name = code), [Start(string) End(string) Stock Index]
	cap preserve
	clear all
	if "`end'" == "" local end: disp %dCYND date("`c(current_date)'","DMY")
	if "`start'" == "" local start: disp %dCYND (date("`end'","YMD")-60)
	qui cntrade2 `code', s(`start') e(`end') `stock' `index'
	replace name = subinstr(name, " ", "", .)
	qui sum volume
	if `r(max)' <= 100{
		tw rspike high low date || line close date, xtitle(日期) ytitle("股价-最高价&最低价-收盘价", place(top)) name(hilo, replace) xscale(off) legend(off) nodraw ylabel(, angle(0))
		tw bar volume date, xtitle(日期) ytitle("交易量（股）") name(vol, replace) ylabel(#4, angle(0)) fysize(35) nodraw xlabel(#4)
		graph combine hilo vol, cols(1) imargin(b = 0 t = 0)
	}
	if `r(max)' > 100 & `r(max)' <= 1000{
		replace volume = volume/10
		tw rspike high low date || line close date, xtitle(日期) ytitle("股价-最高价&最低价-收盘价", place(top)) name(hilo, replace) xscale(off) legend(off) nodraw ylabel(, angle(0))
		tw bar volume date, xtitle(日期) ytitle("交易量（十股）") name(vol, replace) ylabel(#4, angle(0)) fysize(35) nodraw xlabel(#4)
		graph combine hilo vol, cols(1) imargin(b = 0 t = 0)
	}
	if `r(max)' > 1000 & `r(max)' <= 10000{
		replace volume = volume/100
		tw rspike high low date || line close date, xtitle(日期) ytitle("股价-最高价&最低价-收盘价", place(top)) name(hilo, replace) xscale(off) legend(off) nodraw ylabel(, angle(0))
		tw bar volume date, xtitle(日期) ytitle("交易量（百股）") name(vol, replace) ylabel(#4, angle(0)) fysize(35) nodraw xlabel(#4)
		graph combine hilo vol, cols(1) imargin(b = 0 t = 0)
	}
	if `r(max)' >= 10000 & `r(max)' < 100000{
		qui replace volume = volume/1000
		tw rspike high low date || line close date, xtitle(日期) ytitle("股价-最高价&最低价-收盘价", place(top)) name(hilo, replace) xscale(off) legend(off) nodraw ylabel(, angle(0))
		tw bar volume date, xtitle(日期) ytitle("交易量（千股）") name(vol, replace) ylabel(#4, angle(0)) fysize(35) nodraw xlabel(#4)
		graph combine hilo vol, cols(1) imargin(b = 0 t = 0)
	}
	if `r(max)' >= 100000 & `r(max)' < 1000000{
		qui replace volume = volume/10000
		tw rspike high low date || line close date, xtitle(日期) ytitle("股价-最高价&最低价-收盘价", place(top)) name(hilo, replace) xscale(off) legend(off) nodraw ylabel(, angle(0))
		tw bar volume date, xtitle(日期) ytitle("交易量（万股）") name(vol, replace) ylabel(#4, angle(0)) fysize(35) nodraw xlabel(#4)
		graph combine hilo vol, cols(1) imargin(b = 0 t = 0)
	}
	if `r(max)' >= 1000000 & `r(max)' < 10000000{
		qui replace volume = volume/100000
		tw rspike high low date || line close date, xtitle(日期) ytitle("股价-最高价&最低价-收盘价", place(top)) name(hilo, replace) xscale(off) legend(off) nodraw ylabel(, angle(0))
		tw bar volume date, xtitle(日期) ytitle("交易量（十万股）") name(vol, replace) ylabel(#4, angle(0)) fysize(35) nodraw xlabel(#4)
		graph combine hilo vol, cols(1) imargin(b = 0 t = 0)
	}
	if `r(max)' >= 10000000 & `r(max)' < 100000000{
		qui replace volume = volume/1000000
		tw rspike high low date || line close date, xtitle(日期) ytitle("股价-最高价&最低价-收盘价", place(top)) name(hilo, replace) xscale(off) legend(off) nodraw
		tw bar volume date, xtitle(日期) ytitle("交易量（百万股）") name(vol, replace) ylabel(#4, angle(0)) fysize(35) nodraw xlabel(#4) ylabel(, angle(0))
		graph combine hilo vol, cols(1) imargin(b = 0 t = 0)
	}
	else{
		qui replace volume = volume/10000000
		tw rspike high low date || line close date, xtitle(日期) ytitle("股价-最高价&最低价-收盘价", place(top)) name(hilo, replace) xscale(off) legend(off) nodraw ylabel(, angle(0))
		tw bar volume date, xtitle(日期) ytitle("交易量（千万股）") name(vol, replace) ylabel(#4, angle(0)) fysize(35) nodraw xlabel(#4) 
		graph combine hilo vol, cols(1) imargin(b = 0 t = 0)
	}
end
