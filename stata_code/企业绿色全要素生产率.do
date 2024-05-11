*** 企业绿色全要素生产率
use 行业代码_2022, clear
merge 1:1 Stkcd year using 地理信息_2022, nogen keep(1 3)
merge 1:1 Stkcd year using csr_finidx, nogen keep(1 3) keepus(Outcap)
merge 1:1 Stkcd year using fs_combas_annual_consolidate_new, nogen keep(1 3) keepus(A001212000)
merge 1:1 Stkcd year using cg_ybasic, nogen keep(1 3) keepus(Y0601b)
merge 1:1 Stkcd year using mnmapr_accruals, nogen keep(1 3) keepus(B110101)
foreach v of var O A B{
replace `v' = . if `v' < 0
bys S: fillmissing `v'
}
su
foreach v of var Y{
replace `v' = . if `v' <= 0
bys S: fillmissing `v'
}
*
xtset S y
bys S: egen my = min(y)
g Z = O if my == y
loc d = 0.15
g G = D.O/L.O
bys S: egen g = mean(G)
g k = Z/(`d'+g)
bys S: fillmissing Z
g K = k if my == y
qui forv i=1/30{
xtset S y
replace K = (1-`d')*L.K + Z if mi(K)
}
replace K = . if K <= 0
drop m Z G g k
la var K 资本投资（永续盘存法）
compress
save d1, replace
***
use 城市面板数据库, clear
keep id 
duplicates drop 
forv i = 2000/2022{
g Y`i' = .
}
gather Y*
drop val
ren v year
replace y = substr(y,2,.)
destring y, force replace
save id, replace
*
use id, clear
merge 1:1 id year using 城市面板数据库, nogen keep(1 3)
bys id: fillmissing P Ci
keep id year Province City 工业二氧化硫排放量 工业废水排放量 工业烟尘排放量 全年用电量 地区生产总值
ren id Ctnm_id
ren (工业二氧化硫排放量 工业废水排放量 工业烟尘排放量 全年用电量 地区生产总值) (SO2 Water Dust Elect GDP)
merge 1:1 Ctnm_id year using 分城市工业, nogen keep(1 3) keepus(Inct02)
g CityCode = Ctnm_id
g SgnYear = year
merge 1:1 CityCode SgnYear using urc_urblpgcy_new, nogen keep(1 3) keepus(TotalGasSup)
ren TotalGasSup Lpgcy
merge 1:1 CityCode SgnYear using urc_urbnaturalgascy_new, nogen keep(1 3) keepus(TotalGasSup)
ren TotalGasSup Naturalgascy
drop CityCode SgnYear
*
xtset Ctnm_id year
qui forv i=1/5{
foreach c of var G{
bys Ctnm_id: ipolate `c' year,g(`c'_new) epolate
drop `c'
ren `c'_new `c'
replace `c' = . if `c' < 0
}
}
su 
qui forv i=1/5{
foreach c of var S W D I E N L{
cap g r_`c' = `c' / G
bys Ctnm_id: ipolate r_`c' year, g(`c'_new) epolate
drop r_`c'
ren `c'_new r_`c'
replace `c' = r_`c' * G if mi(`c')
replace `c' = . if `c' < 0
}
} 
drop r* G
bys Ctnm_id: fillmissing S W D I E N L
for @ in any S W D I E N L: replace @ = 0 if mi(@)
for @ in any S W D I E N L: replace @ = round(@,1) 
g coef = 0
foreach i in 京 津 山 河北{
replace c = 0.8843 if regexm(P,"`i'")
}
foreach i in 黑 吉 辽{
replace c = 0.7769 if regexm(P,"`i'")
}
foreach i in 上 苏 福 浙 安{
replace c = 0.7035 if regexm(P,"`i'")
}
foreach i in 河南 湖 江 川 重{
replace c = 0.5257 if regexm(P,"`i'")
}
foreach i in 新 甘 青 宁 陕{
replace c = 0.6671 if regexm(P,"`i'")
}
foreach i in 云 贵 广 海南{
replace c = 0.5271 if regexm(P,"`i'")
}
replace c = (0.8843+0.7769)/2 if regexm(P,"内")
g e = coef*E
g pc = 2.1622*N + 3.1013*L + e
la var p 能源消费
compress
save d2, replace
***
use d1, clear
ren CITYCODE Ctnm_id
merge m:1 Ctnm_id year using d2, nogen keep(3) keepus(S W D I p)
so Stkcd year 
ren Y L 
g E = pc * Inct02 / B
foreach v of var SO2 Water Dust{
g `v'_ = `v' * Inct02 / B
}
ren B Y
foreach v of var K L E Y SO2_ Water_ Dust_{
g ln`v' = ln(`v'+1)
}
g gk=-1*lnK
g gl=-1*lnL
g ge=-1*lnE
g gy=1*lnY
g gb1=-1*lnSO2_ 
g gb2=-1*lnWater_
g gb3=-1*lnDust_
encode IndustryCode, g(i)
save d3, replace 
d
***
use d3, clear
qui su i
loc max = r(max)
forv i = 1/`max'{
use d3, clear
keep if i == `i'
gtfpch lnK lnL lnE = lnY : lnSO2_ lnWater_ lnDust_, ///
       dmu(Stkcd) gx(gk gl ge) gy(gy) gb(gb1 gb2 gb3) ///
       global sav(GTFP_`i'.dta, replace)
use GTFP_`i',clear
split Pdwise,p(~)
drop Pdwise1
ren Pdwise2 year
destring year, replace
ren (TFPCH TECH TECCH) (GTFP GTEC GTC)
save GTFP_merge_`i',replace
}
***
use d3, clear
qui su i
loc max = r(max)
clear
forv i = 1/`max'{
append using GTFP_merge_`i', force
}
drop R P
order S y
save 企业绿色全要素生产率, replace
d
su
ta y
mkdensity G*