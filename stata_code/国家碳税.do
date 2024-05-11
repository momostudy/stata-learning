import exc APPENDIX1, first clear
save temp, replace
*
import delim "CO2 per capita 1988 2020.csv", clear
drop co2*
ren cou Country
merge 1:m Cou using temp, nogen
replace cod = "CZE" if regexm(Cou,"Cze") & mi(cod)
replace cod = "SVK" if regexm(Cou,"Slov") & mi(cod)
replace cod = "KOR" if regexm(Cou,"Kor") & mi(cod)
*drop if mi(Car) & mi(E)
so c
save temp2, replace
*
use temp2, clear
drop E
drop if mi(Ca)
duplicates drop 
save E, replace
*
use temp2, clear
drop Ca
drop if mi(E)
duplicates drop 
save Ca, replace
*
use temp2, clear
keep Co c 
duplicates drop c, force 
merge 1:1 c using E, nogen 
merge 1:1 c using Ca, nogen 
so c
save K, replace
*
foreach i in Ca E{
use K, clear
keep Co c `i'
forv j = 1990/2022{
g y`j' = `j' >= `i'
}
gather y* 
g year = substr(var,2,.)
destring y, force replace
ren val d`i'
drop var `i'
save `i', replace
}
*
use Ca, clear
merge 1:1 c y using E, nogen 
ren (dC dE) (CO2Tax ETS)
la var CO 是否征收碳税
la var E  是否加入排放交易计划（ETS）
order y
save 国家碳税, replace
d
ta y CO
su 
*
use 国家碳税, clear
collapse (sum) CO E, by(y)
su
tw (line CO y) (line E y)