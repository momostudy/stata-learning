program aidsills_pred, eclass
	version 11
	
	syntax newvarname [if] [in],		///
		EQuation(varlist min=1 max=1 numeric) [		///
		Residuals ]
	
	if "`e(cmd)'" != "aidsills" {
		error 301
	}
	
	local model `e(model)'
	local const `e(const)'
	local shares `e(shares)'
	local prices `e(prices)'
	local expenditure `e(expenditure)'
	local ivprices `e(ivprices)'
	local ivexpenditure `e(ivexpenditure)'
	local intercept `e(intercept)'
	local alpha_0 = `e(alpha_0)'
	local iteration = `e(iteration)'
	
	local wtype `e(wtype)'
	local wvar `e(wvar)'
	
	tempvar _tempw
	if "`wvar'" != "" {
		gen `_tempw' = `wvar'
		local wexp "[`wtype' = `_tempw']"
	}
	else {
	    gen `_tempw' = 1
		local wexp ""
	}
	
	/* Replace null prices and expenditure by missing values */
	
	local n : word count `shares'
	local i = 1
	while `i' <= `n' {
		local vari : word `i' of `prices'
		qui replace `vari' = . if `vari' == 0
		local i = `i'+1
	}
	qui replace `expenditure' = . if `expenditure' == 0

	/* Mark the estimation sample and drop missing data */
	
	marksample touse, novarlist
	markout `touse' `shares' `prices' `expenditure' `intercept' `ivprices' `ivexpenditure'
	
	preserve
	qui keep if `touse'
	
	/* Set b, V and locals */
	
	tempname b V
	mat `b' = e(b)
	mat `V' = e(V)
	
	local nx = 1
	if "`model'" == "QUAIDS" {
		local nx = `nx'+1
	}
	local nv = 0
	if "`ivprices'" != "" {
		local nv = `nv'+`n'
	}
	if "`ivexpenditure'" != "" {
		local nv = `nv'+1
	}
	local nint : word count `intercept'
	local nint = `nint'+1
	
	local nvar = `n'+`nx'+`nv'+`nint'
	local nobs = _N
	
	/* Check the argument of equation() */
	
	local ok = 0
	local i = 1
	while `i' <= `n' {
		local vars : word `i' of `shares'
		if "`vars'" == "`equation'" {
			local eqn = `i'
			local ok = 1
		}
		local i = `i'+1
	}
	if `ok' == 0 {
		di as error "In equation(), specify one of these: `shares'"
		exit
	}
	
	/* Recover control functions if any */
	
	local v
	local ivvar `ivprices' `ivexpenditure'
	if "`ivvar'" != "" {
		tempvar ln`expenditure'
		qui gen double `ln`expenditure'' = ln(`expenditure')
		local lnp
		local i = 1
		while `i' <= `n' {
			local vari : word `i' of `prices'
			tempvar ln`vari'
			qui gen double `ln`vari'' = ln(`vari')
			local lnp `lnp' `ln`vari''
			local i = `i'+1
		}
		local exvar `ivvar'
		if "`ivprices'" == "" {
			local exvar `lnp' `exvar'
		}
		if "`ivexpenditure'" == "" {
			local exvar `exvar' `ln`expenditure''
		}
		local exvar `exvar' `intercept'
		
		if "`ivprices'" != "" {
			local i = 1
			while `i' <= `n' {
				local vari : word `i' of `prices'
				qui reg `ln`vari'' `exvar' `wexp'
				tempvar v`vari'
				qui predict `v`vari'', r
				local v `v' `v`vari''
				local i = `i'+1
			}
		}
		
		if "`ivexpenditure'" != "" {
			qui reg `ln`expenditure'' `exvar' `wexp'
			tempvar v`expenditure'
			qui predict `v`expenditure'', r
			local v `v' `v`expenditure''
		}
	}
	
	/* Load data into Mata */
	
	local dat `prices' `expenditure' `v' `intercept'
	mata: aidsills_XMAT = st_data(., tokens(st_local("dat")))
	
	/* Restore data */
	
	restore
	
	/* Calculate the prediction */
	
	qui gen double `varlist' = .
	mata: aidsills_pred("`b'", "`varlist'", "`touse'")
	mata: mata drop aidsills_XMAT
	
	if "`residuals'" != "" {
		qui replace `varlist' = `equation' - `varlist' if `touse'
	}
	
	/* Returns */
	
	qui replace `touse' = e(sample)
	ereturn post `b' `V', esample(`touse')
	eret local iteration = `iteration'
	eret local alpha_0 = `alpha_0'
	eret local N = `nobs'
	
	eret local model "`model'"
	eret local const "`const'"
	
	eret local prices "`prices'"
	eret local expenditure "`expenditure'"
	eret local ivprices "`ivprices'"
	eret local ivexpenditure "`ivexpenditure'"
	eret local intercept "`intercept'"
	eret local shares "`shares'"
	
	eret local wtype "`wtype'"
	eret local wvar "`wvar'"
	
	eret local cmd "aidsills"

end

mata:
function aidsills_pred(string scalar b_s, string scalar P_s, string scalar TOUSE_s)
{	
	external aidsills_XMAT
	n = strtoreal(st_local("n"))
	nx = strtoreal(st_local("nx"))
	nv = strtoreal(st_local("nv"))
	nint = strtoreal(st_local("nint"))
	nobs = strtoreal(st_local("nobs"))
	a_0 = strtoreal(st_local("alpha_0"))
	eqn = strtoreal(st_local("eqn"))
	ndat = cols(aidsills_XMAT)
	
	b = st_matrix(b_s)'
	b = rowshape(b,n)'
	nvar = rows(b)
	
	prices = ln(aidsills_XMAT[|1,1\nobs,n|])
	totexp = ln(aidsills_XMAT[|1,n+1\nobs,n+1|])
	if (nv != 0) {
		v = aidsills_XMAT[|1,n+1+1\nobs,n+1+nv|]
	}
	intcpt = J(nobs,1,1)
	if (nint > 1) {
		intcpt = aidsills_XMAT[|1,n+1+nv+1\nobs,ndat|],intcpt
	}
	
	alpha = intcpt*b[|n+nx+nv+1,1\nvar,n|]
	gama = b[|1,1\n,n|]
	beta = b[|n+1,1\n+1,n|]
	
	_alpha0 = J(nobs,1,a_0)
    a_p = _alpha0 + rowsum(prices[|1,1\nobs,n|]:*alpha) + .5*rowsum((prices*gama):*prices[|1,1\nobs,n|])
	lx = totexp-a_p
	w = alpha + prices*gama + beta#lx
	if (nx > 1) {
		b_p = exp(prices[|1,1\nobs,n|]*beta')
		lambda = b[|n+2,1\n+2,n|]
		lx2 = (lx:^2):/b_p
		w = w + lambda#lx2
	}
	if (nv != 0) {
		w = w + v*b[|n+nx+1,1\n+nx+nv,n|]
	}
	P = w[.,eqn]
	
	st_store(.,P_s,TOUSE_s,P)
}
end

exit
