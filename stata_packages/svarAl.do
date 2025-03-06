**# Start of Program for the Local Projections

capture log close _all                                
log using svarAl.log, name(svarAl) text replace

**#  ***** Analysing geopolitical risks on commo price *********

set scheme Cleanplots
graph set window fontface "Arial Narrow"

cls
clear

version 18.5
set more off

// Please change the path with your own folder

/*
cd "C:\Users\jamel\Dropbox\latex\PROJECTS"
cd "24-09-commo-geopolitical-risks"
cd "Data and command"
*/

import excel data.xlsx,/*
*/ sheet("Feuil1") firstrow clear

generate period = tm(1985m1) + _n-1
format %tm period

tsset period

des

*ssc install labvars

labvars GPR GPRT GPRA GECON GINF GRATE Al Cu Sn Ni Zn Pt ///
 "Geopolitical Risks" "Geopolitical Threats" ///
 "Geopolitical Acts" "Global Economic Conditions" ///
 "Global Inflation" "Global Interest Rates" ///
 "Aluminium Price" "Copper Price" ///
 "Tin Price" "Nickel Price" ///
 "Zinc Price" "Platinium Price"
 
tsline GPR GPRA GPRT, name(GPR, replace) 
tsline GECON d.GINF, name(ECO, replace) 
tsline Al Cu Sn Ni Zn Pt, name(CMO, replace) 

foreach i in GPR ECO CMO {
 gr dis `i' 
 gr export `i'.png, as(png) width(4000) replace
 }

/* Source: 
 GECON: Review of Economics and Statistics, 104(4), July 2022, 828-844.
 GPR: American Economic Review, 112(4), 1194-1225.
 CMO: World Bank Commodity Price Data (The Pink Sheet)
 */

gen LGPR = log(GPR)
gen LGPRA = log(GPRA)
gen LGPRT = log(GPRT) 
gen LGINF = log(GINF) 
gen LAl = log(Al)
 
order period, first

save dataset.dta, replace
	   
matrix A = (1,0,0,0\.,1,0,0\.,.,1,0\.,.,.,1)
matlist A

matrix B = (.,0,0,0\0,.,0,0\0,0,.,0\0,0,0,.) 
matlist B

varsoc LGPR GECON LGINF LAl, maxlag(12)

svar LGPR GECON LGINF LAl, aeq(A) beq(B) ///
lags(1/12) 

/* compute the inv(B)*A matrix */
matrix A=e(A)
matrix B=e(B)
matrix BA = inv(B)*A
/* compute reduced form epsilon_t residuals */
var LGPR GECON LGINF LAl
capture drop epsilon*
predict double epsilon1,residual eq(#1)
predict double epsilon2,residual eq(#2)
predict double epsilon3,residual eq(#3)
predict double epsilon4,residual eq(#4)
/* store the epsilon* variables in the epsilon matrix */
mkmat epsilon*, matrix(epsilon) 
/* compute e_t matrix of structural shocks */
matrix e = (BA*epsilon')'
/* store columns of e as variables e1, e2, and e3 */  
svmat double e

label variable epsilon1 "Reduced-form shocks Al - GPR"
label variable e1 "Structural shocks Al - GPR"

**# Plot the shocks
twoway (tsline e1) ///
 (tsline epsilon1, yaxis(1)), ///
 name(G1Al, replace) legend(position(6)) ///
 graphregion(margin(r+5))
 
graph export "G1Al.png", as(png) width(4000) replace

irf set comparemodels.irf, replace
quietly lpirf GECON LGINF LAl, step(50) lags(1/12) ///
  exog(L(0/12).e1) vce(robust)
irf create lpmodel 

/*
quietly var GECON LGINF LAl, lags(1/12) ///
  exog(L(0/12).e1)
irf create varmodel, step(50)
*/

irf graph dm, impulse(e1) response(LAl) ///
  irf(lpmodel) level(95) ///
  xlabel(0(12)48,grid) name(G2Al, replace) ///
  xsize(4)
	
graph export "G2Al.png", as(png) width(4000) replace

save datasetAl.dta, replace

****************************************************************

use comparemodels.irf

log close _all
exit

**# End of Program for the Local Projections