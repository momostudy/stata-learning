cd C:\Download
*
forv x = 1/2{
use stk_ma_involvedparty_2023, clear
keep if TradingPositionID == "S310`x'"
keep EventID Symbol
drop if S == ""
ren S Stkcd_S310`x'
duplicates drop E, force
save stk_ma_involvedparty_2023_S310`x', replace
}
* 
use stk_ma_underlying_2023, clear
forv x = 1/2{
merge m:1 EventID using stk_ma_involvedparty_2023_S310`x', nogen keep(1 3)
}
keep EventID Stkcd* Exp
destring EventID Stkcd*, force replace
drop if Stkcd_S3101 == . & Stkcd_S3102 == .
duplicates drop EventID, force
save Stkcds, replace
*
use stk_ma_tradingmain_2023new, clear
duplicates drop EventID, force 
merge 1:1 EventID using Stkcds, nogen keep(1 3)
cap g year = substr(FirstDeclareDate,1,4)
destring year, force replace
order Stkcd* year EventID
keep Stkcd* year EventID
drop if Stkcd_S3101 == . & Stkcd_S3102 == .
save Stkcds_year, replace
*
use Stkcds, clear
merge 1:1 EventID using Stkcds_year, nogen keep(1 3)
drop if year == .
g MA = 1
g GreenMA = 0
foreach i in 脱硫 脱销 污水 废气 除尘 节能 绿色 可持续 清洁 环保 低碳 环境 减排 循环 节约 生态 污染 保护{
replace G = 1 if regexm(Ex, "`i'")
}
save Green, replace
*
use Green, clear
keep if Stkcd_S3101 != .
drop Stkcd Stkcd_S3102
ren S Stkcd
ren M MA_Buyer
ren G GreenMA_Buyer
save _1, replace
*
use Green, clear
keep if Stkcd_S3102 != .
drop Stkcd Stkcd_S3101
ren S Stkcd
ren M MA_Seller
ren G GreenMA_Seller
save _2, replace
*
use Green, clear
keep Ev
merge 1:1 Ev using _1, nogen keep(1 3)
merge 1:1 Ev using _2, nogen keep(1 3)
foreach v of var *er{
replace `v' = 0 if `v' == .
}
la var MA_Buyer       是否为并购买方
la var MA_Seller      是否为并购卖方
la var GreenMA_Buyer  是否为绿色并购买方
la var GreenMA_Seller 是否为绿色并购卖方
save 企业绿色并购_2023, replace
d
ta Green*
ta y