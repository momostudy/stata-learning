*! cusum9 cloned from cusum6  cfb 27sep2020
*! cusum6 V1.0 cloned from Becketti cusum.ado and _getrres.ado  C F Baum 0301
*! corr options v1.1.1 0A09
* 1.1.0 graphics hacks NJC 3 March 2000 
* requires Becketti _cu_c0.ado

program define cusum9, rclass
//	version 6.0
	version 9
	syntax varlist(ts min=2) [if] [in] [,noConstant noPlot CS(str) CS2(str) RR(str) UW(str) UWW(str) LW(str) LWW(str) SQline(str)]  
	tempvar resid hat 
	if ("`cs'"!="") { 
		confirm new var `cs' 
		}
	else { 
		tempvar cs 
		}
	if ("`cs2'"!="") {
		confirm new var `cs2' 
		}
	else {
		tempvar cs2 
		}
	if ("`rr'"!="") { 
		confirm new var `rr' 
		}
	else { 
		tempvar rr 
		}	
	qui gen double `rr' = .
	if ("`uw'"!="") { 
		confirm new var `uw' 
		}
	else { 
		tempvar uw 
		}
	if ("`uww'"!="") { 
		confirm new var `uww' 
		}
	else { 
		tempvar uww 
		}
	if ("`lw'"!="") { 
		confirm new var `lw' 
		}
	else { 
		tempvar lw 
		}
	if ("`lww'"!="") { 
		confirm new var `lww' 
		}
	else { 
		tempvar lww 
		}
	if ("`sqline'"!="") { 
		confirm new var `sqline' 
		}
	else { 
		tempvar sqline 
		}
	qui tsset		
	if r(timevar)=="" {
		di in red "time series data required"
		exit
	}
   	marksample touse
			/* get time variables */
	_ts timevar, sort
	markout `touse' `timevar'
	tsreport if `touse', report
	if r(N_gaps) {
		di in red "sample may not contain gaps"
		exit
	}

	_crcnuse `touse'
	local gaps $S_2
	local first $S_3
	local last $S_4
	qui regress `varlist' if `touse' , `constant'
	local T=e(N)
	local K=e(df_m)
	local i = `first' + `K' + 1
	while (`i'<`last') {
		local j = `i' + 1
			qui {
			reg `varlist' if `touse' in `first'/`i', `constan'
			predict `resid', resid
			predict `hat', hat
			replace `rr' = `resid'/sqrt(1+`hat') in `j'
			drop `resid' `hat'
			}
		local i = `j'
	}
	lab var `rr' "Recursive residuals"
	local first = `first' + `K'+2
	qui replace `touse' = . if _n < `first'
	local in  "in `first'/`last'"
	qui sum `rr' `if' `in'
	local TK = r(N)
	local vsd = r(sd)
	qui gen float `cs' = sum(`rr')/`vsd' `if' `in'
	lab var `cs' "CUSUM"
	qui{
	gen float `cs2' = sum(`rr'*`rr') `if' `in'
	replace `cs2' = `cs2'/`cs2'[`last']
	}
	lab var `cs2' "CUSUM squared"
		
*	Display the CUSUM graphs.

	qui {
	local critval = 0.948		/* 5% critical value */
	local step = 2*`critval'/sqrt(`TK')
	gen float `uw' = `critval'*sqrt(`TK') + sum(cond(`touse',`step',0)) `in'
	gen float `lw' = -`uw'
	_cu_c0 `T' `K'
	local critval = $S_1		/* 5% critical value */
	gen float `sqline' = 0 `in'
	local step = 1/(`TK'-1)
	local fp1 = `first' + 1
	replace `sqline' = sum(cond(`touse',`step',0)) in `fp1'/`last'
	gen float `uww' = `sqline' + `critval' `in'
	gen float `lww' = `sqline' - `critval' `in'
	global S_1 = `T'
	global S_2 = `K'
	global S_3 = `critval'
	if "`plot'"!="" { 
		exit 
	}
	tsset
	local tv= r(timevar)
	}
	tsline `cs' `lw' `uw', yline(0) ylab(,angle(0)) yti("CUSUM") name(gr1, replace) legend(off)
	tsline  `cs2' `lww' `uww' `sqline', ylab(,angle(0)) yti("CUSUM^2") name(gr2, replace) legend(off)
*	gph open
*        gr `cs' `lw' `uw' `tv', yline(0) ylab(0) rlab(0) c(lll) s(oii) pen(344) /*  
*        */ bbox(0,0,23063,15700,923,444,0) gap(3) 
*        gr `cs2' `lww' `uww' `sqline' `tv', ylab(0) rlab(1) c(llll) s(oiii)  pen(3441) /* 
*	*/  bbox(0,16300,23063,32000,923,444,0) gap(3)
*        gph close
end

