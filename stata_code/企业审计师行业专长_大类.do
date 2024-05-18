cd C:\Download
u ar_listcompaudit_2022, clear 
keep Stkcd year PersonID
drop if mi(P)
ren P P 
split P, p(,)
drop P 
g n=_n 
gather P* 
drop n var 
drop if mi(v)
duplicates drop 
drop if regexm(v,"N")
joinby S y using 行业代码_2022
keep S y v IndustryC
replace I = substr(I,1,1)
ren v Afid
ren y Year  
sa _, replace 
*
u _, clear 
keep A Y I 
duplicates drop 
sa _0, replace 
*
forv i=1/2{
u _0, clear 
replace Y = Y+`i' 
sa _`i', replace 
}
ap using _0 _1 
duplicates drop 
g Range_N = 0
collapse (count) R, by(A Y)
replace R = ln(1+R)
sa N, replace 
*
forv i=0/2{
u _, clear 
replace Y = Y+`i' 
sa _`i', replace 
}
ap using _0 _1 
g n = 0
collapse (count) n, by(A Y I)
bys A Y: egen m = sum(n)
g P2 = (n/m)^2
collapse (sum) P, by(A Y)
g Range_H = 1 - P
drop P 
sa H, replace 
*
u _2, clear 
ap using _0 _1 
g n = 0
collapse (count) n, by(A Y I)
bys A Y: egen m = sum(n)
g P = n/m
g Range_E = P*ln(1/P)
collapse (sum) R, by(A Y)
sa E, replace 
*
u _, clear 
foreach i in N H E{
merge m:1 Y A using `i', nogen 
}
collapse (mean) R*, by(S Y)
ren Y year 
keep if inrange(y,.,2022)
la var Range_N 企业审计师行业专长：对数
la var Range_H 企业审计师行业专长：赫芬达尔指数
la var Range_E 企业审计师行业专长：熵指数
sa 企业审计师行业专长_大类, replace 
d
ta y 
cor R*
mkdensity R*