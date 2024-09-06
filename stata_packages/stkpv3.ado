*! 绘制股价蜡烛图
*! 程振兴 2018年7月13日
*! stkpv3 2
cap prog drop stkpv3
prog def stkpv3
	syntax anything(name = code), [Start(string) End(string) Stock Index]
	cap preserve
	clear all
	if "`end'" == "" local end: disp %dCYND date("`c(current_date)'","DMY")
	if "`start'" == "" local start: disp %dCYND (date("`end'","YMD")-60)
	cntrade2 `code', s(`start') e(`end') `stock' `index'
	gen col = 2
	qui{
		replace col = open < close if _n != 1
		drop if col == 2
		sum volume
	}
	local max = `r(max)'
	if `max' < 100{
		graphcandelsticks, yti(交易量(股)) c(`=name[`=_N']')
	}
	if `max' >= 1000 & `max' <= 10000{
		replace volume = volume/100
		graphcandelsticks, yti(交易量(百股)) c(`=name[`=_N']')
	}
	if `max' >= 10000 & `max' < 100000{
		qui replace volume = volume/1000
		graphcandelsticks, yti(交易量(千股)) c(`=name[`=_N']')
	}
	if `max' >= 100000 & `max' < 1000000{
		qui replace volume = volume/10000
		graphcandelsticks, yti(交易量(万股)) c(`=name[`=_N']')
	}
	if `max' >= 1000000 & `max' < 10000000{
		qui replace volume = volume/100000
		graphcandelsticks, yti(交易量(十万股)) c(`=name[`=_N']')
	}
	if `max' >= 10000000 & `max' < 100000000{
		qui replace volume = volume/1000000
		graphcandelsticks, yti(交易量(百万股)) c(`=name[`=_N']')
	}
	if `max' >= 100000000{
		qui replace volume = volume/10000000
		graphcandelsticks, yti(交易量(千万股)) c(`=name[`=_N']')
	}
end

prog def graphcandelsticks
	syntax, YTItle(string) Caption(string)
	tw ///
	rspike high low date if col == 1, color(red*0.8) || ///
	rspike high low date if col == 0, color(green*0.8) || ///
	rbar open close date if col == 0, color(green*0.8) || ///
	rbar open close date if col == 1, color(red*0.8) ||, ///
	yla(#4) yti("股价(元)") name(hilo, replace) xscale(off) leg(off) nodraw sch(plotplain)
	tw ///
	bar volume date if col == 0, bc(green*0.8) || ///
	bar volume date if col == 1, bc(red*0.8) ||, ///
	xti(日期) yti("`ytitle'") name(vol, replace) yla(#6, angle(0)) fysize(35) nodraw xla(#6) leg(off) note("红涨绿跌") caption("公司：	`caption'") sch(plotplain)
	graph combine hilo vol, cols(1) imargin(b = 0 t = 0) 
end
