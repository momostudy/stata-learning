*************************************************************************
* PROGRAM "tvdiff"
*************************************************************************
*! tvdiff, v12, G.Cerulli-M.Ventura, 08nov2018
capture program drop tvdiff
program tvdiff, eclass sortpreserve
version 14
#delimit;     
syntax varlist(numeric ts fv) [if] [in] [aweight fweight pweight] ,
model(string)
pre(numlist max=1 integer)
post(numlist max=1 integer)
[
test_tt
vce(string)
save_graph(string)
graph
];
#delimit cr
********************************************************************************
marksample touse
tokenize `varlist'
local y `1'  // outcome
local D `2'  // treatment
macro shift
macro shift
local xvars `*'
replace `touse'=1 if `y'==.
********************************************************************************
* Labels
********************************************************************************
la var `D' "Binary treatment variable"
la var `y' "Outcome variable"
********************************************************************************
* Warning 1
********************************************************************************
preserve // preserve the original dataset
keep if `touse' // consider just the subsample identified by the "if"
qui count if `D'==1 & `touse'
local N1=r(N)
qui count if `touse'
local N=r(N)
qui sum `D' if `touse'
if r(mean)!=(`N1'/`N'){
di as text in red  ""
di as text in red  ""
di as text in red  "{hline}"
di as text in red  "{bf:******************************************************************************}"
di as text in red  "{bf:********* WARNING: The treatment variable must be binary 0/1 *****************}"
di as text in red  "{bf:******************************************************************************}"
exit
}
********************************************************************************
* Warning 2
********************************************************************************
if ("`model'"!="ols" & "`model'"!="fe") {
di _newline(2)
di as result in red "********************************************************"
di as result in red "Warning: only one of the following models must be   "
di as result in red "declared into the option 'model()': 'ols', 'fe'"
di as result in red "********************************************************"
exit
}
********************************************************************************
* Generation of lags and leads of the binary treatment 
********************************************************************************
xtset `r(panelvar)' `r(timevar)'
local lag `post' 
local lead `pre'  
* 1. LAGS:
local lags
forvalues i=1/`lag'{
cap drop _D_L`i'
gen _D_L`i'=L`i'.`D' if `touse'
local lags "`lags' _D_L`i'"
}
*sum `lags'
* 2. LEADS:
local leads
forvalues i=`lead'(-1)1{
cap drop _D_F`i'
gen _D_F`i'=F`i'.`D' if `touse'
local leads "`leads' _D_F`i'" 
}
*sum `leads'
*di "`xvars'"
********************************************************************************
* Baseline regression - Overall sample (fixed effects)
******************************************************************************** 
else if "`model'"=="ols"{
reg `y' `leads' `D' `lags' `xvars' [`weight' `exp'] if `touse' , vce(`vce')  noomitted // ols
ereturn scalar ate=_b[`D']
qui count if `touse'
ereturn scalar N=r(N)
qui count if `D'==1 & `touse'
ereturn scalar N1=r(N)
qui count if `D'==0 & `touse'
ereturn scalar N0=r(N)
}
else if "`model'"=="fe"{
xtreg `y' `leads' `D' `lags' `xvars' [`weight' `exp'] if `touse' , vce(`vce') fe  noomitted // fixed effects
ereturn scalar ate=_b[`D']
qui count if `touse'
ereturn scalar N=r(N)
qui count if `D'==1 & `touse'
ereturn scalar N1=r(N)
qui count if `D'==0 & `touse'
ereturn scalar N0=r(N)
}
tempname B C
mat `B' = e(b)
mat `C' = `B''
local M=`lag'+`lead'+1
mat `C' =`C'[1..`M',1...]
*mat list `C'
cap drop `C'1
svmat `C'
tempvar id2
gen `id2'=_n
* Labels for lags
local sum_lags
forvalues i=1/`lag'{
local sum_lags `sum_lags' _D_L`i'=t+`i'
}
*di "`sum_lags'"
* Labels for leads
local sum_leads
forvalues i=`lead'(-1)1{
local sum_leads `sum_leads' _D_F`i' = t-`i'
}
local myD "`D'=t"
********************************************************************************
* TESTS
********************************************************************************
di as text ""
di as text ""
di as text "{hline}"
di as text "{bf:******************************************************************************}"
di as text "{bf:**************** Test for 'parallel trend' using the 'leads' *****************}"
di as text "{bf:******************************************************************************}"
test `leads'
if r(p)>=0.05{
di as text ""
di as result "RESULT: 'Parallel-trend' passed"
}
else{
di as result "RESULT: 'Parallel-trend' not passed"
}
di as text ""
di as text "{bf:******************************************************************************}"
di as text ""
********************************************************************************
* GRAPH
********************************************************************************
if "`graph'"!="" & "`save_graph'"!=""{
coefplot . , vertical drop(_cons) yline(0) msymbol(d) mcolor(white) ///
title("" , size(medium))  ///
levels(99 95 90 80 70) ciopts(lwidth(3 ..) lcolor(*.2 *.4 *.6 *.8 *1)) addplot(line `C'1 `id2') keep(`leads' `D' `lags') ///
legend(order(1 "99" 2 "95" 3 "90" 4 "80" 5 "70") row(1)) ///
coeflabels(`sum_leads' `myD' `sum_lags')
qui graph save `save_graph' , replace
}
else if "`graph'"!="" & "`save_graph'"==""{
coefplot . , vertical drop(_cons) yline(0) msymbol(d) mcolor(white) ///
title("" , size(medium))  ///
levels(99 95 90 80 70) ciopts(lwidth(3 ..) lcolor(*.2 *.4 *.6 *.8 *1)) addplot(line `C'1 `id2') keep(`leads' `D' `lags') ///
legend(order(1 "99" 2 "95" 3 "90" 4 "80" 5 "70") row(1)) ///
coeflabels(`sum_leads' `myD' `sum_lags')
}
********************************************************************************
* TEST OF COMMON TREND AS IN AP (2009, P. 238-239)
********************************************************************************
if "`test_tt'"!=""{
qui xtset `r(panelvar)' `r(timevar)'
tempvar T
bys `r(panelvar)': gen `T'=_n
gen _DT=`D'*`T'
qui xtreg `y' `D' `T' `xvars'  _DT [`weight' `exp'] if `touse' , vce(`vce') fe  // fixed effects
di as text ""
di as text "{hline}"
di as text "{bf:******************************************************************************}"
di as text "{bf:************ Test for 'parallel trend' using the 'time-trend' ****************}"
di as text "{bf:******************************************************************************}"
di as text ""
di as text "Test for the null hypothesis 'Ho: d=0' in the following fixed-effect regression"
di as text "             y_it = a + b*t + c*D + d*(D*t) + f*x + g_t + h_i + error          "
di as text "where D*t is the interaction between the treatment D and the time variable t   "
di as text ""
********************************************************************************
test _DT
if r(p)>=0.05{
di as text ""
di as result "RESULT: 'Parallel-trend' passed"
}
else{
di as result "RESULT: 'Parallel-trend' not passed"
}
di as text ""
di as text "{bf:******************************************************************************}"
di as text ""
di as text "{hline}"
} 
********************************************************************************
qui{
tempfile newdata
xtset `r(panelvar)' `r(timevar)'
keep `r(panelvar)' `r(timevar)' _D_L* _D_F*
save `newdata' , replace
restore // restore the original dataset
cap drop _merge
merge 1:1 `r(panelvar)' `r(timevar)' using `newdata'
cap drop _merge
}
end
********************************************************************************
* END of "tvdiff"
********************************************************************************
