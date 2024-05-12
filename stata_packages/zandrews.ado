*! zandrews 1.0.5 cfb 31jul2015
* 1.0.5   30jul2015 guard against zero variance 
* 1.0.4   26oct2013 correct crit01 (model A), add crit10
* 1.0.3.1 29nov2009 correct time labeling 
* 1.0.2   16jul2004 implement onepanel
* 1.0.1   28jan2004
program define zandrews, rclass
	version 8
syntax varname(ts) [if] [in] [ , Break(string) Lagmethod(string) Generate(string) Maxlags(numlist min=1 max=1 >0 integer) level(real 0.10)  trim(real 0.15) graph ]

local var `varlist'
if "`break'"==""{
	local brtype "intercept"
	local obr "intercept"
// Table 2, Model A
		local crit01= -5.34
		local crit05= -4.80
		local crit10= -4.58
		}
if "`break'" ~="" {
	if "`break'"=="intercept" {
		local brtype = "intercept"
		local obr "intercept"
		local crit01= -5.34
		local crit05= -4.80
		local crit10= -4.58
		}
	else if "`break'"=="trend" {
// Table 3, Model B
		local brtype= "trend"
		local obr "trend"
		local crit01= -4.93
		local crit05= -4.42
		local crit10= -4.11
		}
	else if "`break'"=="both" {
// Table 4, Model C
		local brtype = "both"
		local obr "both intercept and trend"
		local crit01= -5.57
		local crit05= -5.08
		local crit10= -4.82
		}
	else {
		di as err "Error: break must be intercept, trend, or both."
		exit 198
		}
	}
*	di "break: `brtype'"

		
local lagtype "TTest"
if "`lagmethod'"~= "" {
	if "`lagmethod'" == "input" {
			local lagtype = "input"
			}
	else if "`lagmethod'" == "AIC" {
			local lagtype = "AIC"
			}
	else if "`lagmethod'" == "BIC" {
			local lagtype = "BIC"
			}
	else if "`lagmethod'" == "TTest" {
			local lagtype = "TTest"
			}
	else{
			di as err "Error: lagmethod must be input, AIC, BIC, or TTest."
			exit 198
			}
		}
		
local gen "`generate'"
if "`gen'" !=""{
	confirm new variable gen
	qui gen `gen'=.
	}

local siglevel 0.10
if `level' ~= . {
	if `level'> 0 & `level' <  0.25 {
		local siglevel = `level'
		}
	else {
		di as err "Error: Level must be a real number between 0 and 0.25."
		exit 198
		}
	}
*	di "level: `siglevel'"

local grph "`graph'"
*	di "graph: `grph'"

local fraction 0.15
if `trim' ~= . {
	if `trim' > =0 & `trim' < 0.25 {
		local fraction = `trim'
		}
	else {
		di as err "Error: Trim must be a positive real number greater than 0 and less than 0.25"
		exit 198
		}
	}  
 *       di "trim: `fraction'"

	marksample touse
* guard against bozos analyzing a constant
	summ `varlist' if `touse', mean
	if `r(max)' == `r(min)' {
		di as err _n "Error: variable `varlist' has no variance."
		exit 198
	}
* handle onepanel case
*	_ts timevar, sort
    _ts timevar panelvar if `touse', sort onepanel
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "Sample may not contain gaps"
		exit
	}
	qui tsset
	local rts=r(tsfmt)
	tempvar count samp dy trend lagout breakint breaktrend breakstats en
	qui gen `count'= sum(`touse')
	local nobs= `count'[_N]
	local ntrim=int(`trim'* `nobs'+0.49)
		
	local maxl= int(`nobs'^0.25)
	if "`lagtype'"=="input" {
		if  "`maxlags'" == "" {
			di as err "Error: If lagmethod=input you must provide a value for maxlags."
			exit 198
			}
		else {
			local maxl= `maxlags'
			local bestlag= `maxl'
			}
		}
	*	di "maxl: `maxl'"
		
		qui gen `lagout'= `touse'
		qui replace `lagout'=0 if `count'<= `maxl'+1
		qui gen double `dy'= D.`var' if `touse'
		qui gen `trend'= _n if `touse'
		if "`lagtype'"~="input" {
			local icmult= log(`nobs')/ `nobs'
			if "`lagtype'"=="AIC" {
				local icmult= 2.0/`nobs'
				}
* di "icmult `icmult' maxl `maxl'"
			*baseline regression -- no lagged dys
* su `lagout'
			qui reg `dy' `trend' L.`var' if `lagout'
			local ic= log(e(rss)/e(N)) + `icmult'* (e(df_m)+1)
			local icmin = `ic'
*	di in r "lag, ic, icmin `lag' `ic' `icmin'"
			local bestlag 0
			forv lag= `maxl'(-1)1 {
				qui reg `dy' `trend' L.`var' L(1/`lag').`dy' if `lagout'
				if "`lagtype'"=="TTest" {
					local b= _b[L`lag'.`dy']
					local se= _se[L`lag'.`dy']
					local tee= abs(`b'/`se')
					local ndf= e(df_m)
					local tsig= ttail(`ndf',`tee')
					if `tsig' <= `siglevel' {
						local bestlag= `lag'
						continue, break
						}
					}
				else {
*		
					local ic= log(e(rss)/e(N)) +`icmult'* (e(df_m)+1) 
*		di in r "lag, ic, icmin `lag' `ic' `icmin'"
					if `ic'< `icmin' {
						local icmin= `ic'
						local bestlag= `lag'
						}
					}
					}
				}
*		di "bestlag via `lagtype':`bestlag'"	
				
		qui gen `breakint'=.
		qui gen `breaktrend'=.
		local others `trend'
		if `bestlag' >0{
			local others "`others' L(1/`bestlag').`dy'"
			}
		if "`brtype'"~="intercept"{
			local others "`others' `breaktrend'"
			}
		if"`brtype'"~="trend"{
			local others "`others' `breakint'"
			}
	
		qui replace `lagout'=`touse'
		qui replace `lagout'= 0 if `count' <= `bestlag'
// get obs nr of first obs in touse
		qui gen `en' = _n
 		su `en' if `touse', mean
		local mint = r(min) - 1
		qui gen `samp'= `lagout'
		qui replace `samp' = 0 if `count' <= `ntrim'+`bestlag' | `count' > `nobs' - `ntrim'
		summ `count' if `samp', meanonly 			
// correct time indicator for original calendar
		local tstart = r(min) + `mint' 
		local tend   = r(max) + `mint'
		qui gen `breakstats' = . in `tstart'/`tend'
		local minbreak= 1.0e10

// di _n "tstart, tend, timevar: `tstart' `tend'"

		forv time = `tstart'/`tend'{
*			qui replace `breakint' = (_n >= `time')  if `touse'
			qui replace `breakint' = (`count' + `mint' >= `time')  if `touse'
			qui replace `breaktrend' = 0  if `touse'
*			qui replace `breaktrend' = _n+1 - `time' if _n+1- `time'>0 
			qui replace `breaktrend' = `count' + `mint' +1 - `time' ///
			    if `count'+ `mint' + 1 -`time' > 0 & `touse'
			qui reg `dy' L.`var' `others' if `lagout'
		*		if `time'<=`tstart'+2 | `time'>=`tend'-2 {
		*		list `others' if `lagout'
		*		regress
		*		}
		local b = _b[L.`var']
		loca se = _se[L.`var']
		local tee = `b'/`se'
	qui replace `breakstats'=`tee' in `time'/`time'
		if `tee' < `minbreak'{
			local minbreak = `tee'
			local minent   = `time'
			}
		}
	local enn = e(N)
	if "`gen'" != ""{
		qui replace `gen'=`breakstats' in `tstart'/`tend'
				}

	local minb = string(`timevar'[`minent'], "`rts'")	
	if "`grph'" != ""{
		label var `breakstats' "Breakpoint t-statistics"
		local minp = string(`timevar'[`tstart'],"`rts'")
		local maxp = string(`timevar'[`tend'],"`rts'")
		tsline `breakstats' if `touse', ti("Zivot-Andrews test for `var', `minp'-`maxp'") ///
		       t2("Min breakpoint at `minb'") ylab(,angle(0))
		}
//  di _n "minent: `minent'"

	di _n "Zivot-Andrews unit root test for {result: `var'}"
	di _n "Allowing for break in {result:`obr'}"
	di _n "Lag selection via {result:`lagtype'}: lags of D.`var' included = `bestlag'"
	scalar dminobs= `timevar'[`minent']
//	di _n "Minimum t-statistic " %6.3f `minbreak' " at " `rts' dminobs " (obs `minent')"
	di _n "Minimum t-statistic " %6.3f `minbreak' " at `minb'  (obs `minent')"
	di _n "Critical values: 1%: " %5.2f `crit01' " 5%: " %5.2f `crit05' " 10%: " %5.2f `crit10'
	return local breaktype= "`brtype'"
	return scalar tmin=`minbreak'
	return scalar crit01 = `crit01'
	return scalar crit05 = `crit05'
	return scalar crit10 = `crit10'
	return local cmd= "zandrews"
	return scalar tminobs=`minent'
	return local var="`var'"
	return local nobs=`enn'
	return local trim=`trim'
	return local lagtype="`lagtype'"
	return local bestlag="`bestlag'"
		
		end
		exit
