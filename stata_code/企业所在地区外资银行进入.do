cd C:\Download
import exc 41267_2024_693_MOESM1_ESM, clear 
drop in 1 
nrow 1 
compress 
keep B E 
destring *, replace 
replace B = subinstr(B," City","",.)
export exc _, replace 
* translate manually 
import exc __, clear 
keep B C 
g c2 = substr(C,1,6)
keep B c 
sa ___, replace 
*
u 地理信息_2022, clear 
keep Stkcd year CITY 
bys S: fillmissing C 
g c2 = substr(C,1,6)
merge m:1 c using ___, nogen keep(1 3)
replace B = 9999 if mi(B)
g ForeBankEntry = y >= B 
keep S y F
la var F 企业所在地区外资银行进入
sa 企业所在地区外资银行进入, replace 
d
ta y F 