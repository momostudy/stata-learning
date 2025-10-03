*! 从中国债券信息网获取2002年以来的各个期限的中债国债到期收益率数据。
*! 程振兴 2018年8月4日
cap prog drop ctbc2
prog def ctbc2
	version 14.0
	clear all
	di "正在下载和整理数据······"
	qui{
		copy "http://yield.chinabond.com.cn/cbweb-mn/yc/downYearBzqx?year=2018&&wrjxCBFlag=0&&zblx=txy&&ycDefId=2c9081e50a2f9606010a3068cae70001&&locale=zh_CN" 2018.xlsx, replace
		import excel "2018.xlsx", sheet("sheet1") allstring clear
		drop if A == "日期"
		gen date = date(A, "YMD")
		format date %tdCY-N-D
		drop A
		ren B stterm
		ren C term
		ren D rate
		reshape wide term rate, i(date) j(stterm) string
		drop term*
		destring, replace
		append using "http://www.czxa.top/cuse/c/ctbc2.dta", force
		gsort date
		order date rate0d rate1m rate2m rate3m rate6m rate9m rate1y rate2y rate3y rate4y rate5y rate6y rate7y rate8y rate9y rate10y rate15y rate20y rate30y rate40y rate50y
		erase 2018.xlsx
	}
	di "数据来源：中国债券信息网"
	di "已完成！"
end
