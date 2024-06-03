program aidsills_vif, eclass
	version 11
	
	syntax [if] [in]
	
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
	if "`const'" != "UN" {
		local const "`const' "
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
	
	local lnp
	local i = 1
	while `i' <= `n' {
		local vari : word `i' of `prices'
		tempvar ln`vari'
		qui gen double `ln`vari'' = ln(`vari')
		local lnp `lnp' `ln`vari''
		local i = `i'+1
	}
	tempvar ln`expenditure'
	qui gen double `ln`expenditure'' = ln(`expenditure')
	
	local v
	local ivvar `ivprices' `ivexpenditure'
	if "`ivvar'" != "" {
		local exvar `ivvar'
		local varn
		local i = 1
		if "`ivprices'" == "" {
			while `i' <= `n' {
				local vari : word `i' of `prices'
				local varn `varn' ln`vari'
				local i = `i'+1
			}
			local exvar `lnp' `exvar'
		}
		local varn `varn' `ivvar'
		if "`ivexpenditure'" == "" {
			local varn `varn' ln`expenditure'
			local exvar `exvar' `ln`expenditure''
		}
		local varn `varn' `intercept' "_cons"
		local exvar `exvar' `intercept'
		di
		di "VIFs INSTRUMENTAL REGRESSION(S)"
		di
		di "{hline 22}"
		di as text "Variable          VIFs"
		di "{hline 22}"
		local nz : word count `exvar'
		local ind
		local vari
		local i = 1
		while `i' <= `nz' {
			local dep : word `i' of `exvar'
			local vni : word `i' of `varn'
			local vari `vari' `dep'
			local j = `i'+1
			while `j' <= `nz' {
				local varj : word `j' of `exvar'
				local ind `ind' `varj'
				local j = `j'+1
			}
			qui reg `dep' `ind' `wexp'
			di as res abbrev("`vni'",12) _col(15) %8.2f 1/(1-e(r2))
			local ind `vari'
			local i = `i'+1
		}
		di "{hline 22}"
	}
	
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
	
	/* Construct independent variables */
	
	tempvar stone
	local varr : word `n' of `prices'
	qui gen double `stone' = 0
	local i = 1
	while `i' <= `n' {
		local vars : word `i' of `shares'
		local varp : word `i' of `prices'
		tempvar a`vars'
		qui egen double `a`vars'' = mean(`vars')
		qui replace `stone' = `stone'+(`a`vars''*`ln`varp'')
		qui drop `a`vars''
		local i = `i'+1
	}
	
	tempvar lnx
	qui gen double `lnx' = `ln`expenditure''-`stone'
	qui drop `ln`expenditure'' `stone'
	local envar `lnx'
	if "`model'" == "QUAIDS" {
		tempvar lnx2
		qui gen double `lnx2' = `lnx'^2
		local envar `envar' `lnx2'
	}
	
	local n1 = `n'
	local nb = `nvar'*(`n'-1)
	tempname bi
	mat `bi' = `b'[1,1..`nb']
	local indvar `lnp' `envar' `v' `intercept'
	if `iteration' > 0 {
		tempvar a_p
		qui gen double `a_p' = .
		local dat `indvar'
		mata: aidsills_XMAT = st_data(., tokens(st_local("dat")))
		mata: aidsills_pidx1("`bi'", "`a_p'")
		qui replace `lnx' = ln(`expenditure')-`a_p'
		qui drop `a_p'
		if "`model'" == "QUAIDS" {
			tempvar b_p
			qui gen double `b_p' = .
			mata: aidsills_pidx2("`bi'", "`b_p'")
			qui replace `lnx2' = (`lnx'^2)/`b_p'
			qui drop `b_p'
		}
		mata: mata drop aidsills_XMAT
	}
	
	local varn
	local i = 1
	while `i' <= `n' {
		local vari : word `i' of `prices'
		local varn `varn' ln`vari'
		local i = `i'+1
	}
	local varn `varn' "lnx"
	if "`model'" == "QUAIDS" {
		local varn `varn' "lnx2"
	}
	if "`ivprices'" != "" {
		local i = 1
		while `i' <= `n' {
			local vari : word `i' of `prices'
			local varn `varn' v`vari'
			local i = `i'+1
		}
	}
	if "`ivexpenditure'" != "" {
		local varn `varn' v`expenditure'
	}
	local varn `varn' `intercept' "_cons"
	if `iteration' == 0 {
		di
		di "VIFs `model' - LINEARIZED WITH STONE PRICE INDEX"
	}
	if `iteration' > 0 {
		di
		di "VIFs `model' - PROPER ESTIMATION WITH FIXED ALPHA_0 = `alpha_0'"
	}
	di as text "`const'CONSTRAINED ESTIMATES"
	di
	di "{hline 22}"
	di as text "Variable          VIFs"
	di "{hline 22}"
	local nz : word count `indvar'
	local ind
	local vari
	local i = 1
	while `i' <= `nz' {
		local dep : word `i' of `indvar'
		local vni : word `i' of `varn'
		local vari `vari' `dep'
		local j = `i'+1
		while `j' <= `nz' {
			local varj : word `j' of `indvar'
			local ind `ind' `varj'
			local j = `j'+1
		}
		qui reg `dep' `ind' `wexp'
		di as res abbrev("`vni'",12) _col(15) %8.2f 1/(1-e(r2))
		local ind `vari'
		local i = `i'+1
	}
	di "{hline 22}"
	
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
function aidsills_pidx1(string scalar b_s, 
						string scalar a_p)
{
	external aidsills_XMAT
	n = strtoreal(st_local("n"))
	n1 = strtoreal(st_local("n1"))
	nx = strtoreal(st_local("nx"))
	nv = strtoreal(st_local("nv"))
	nint = strtoreal(st_local("nint"))
	nobs = strtoreal(st_local("nobs"))
	a_0 = strtoreal(st_local("alpha_0"))
	ndat = cols(aidsills_XMAT)
	
	b = st_matrix(b_s)'
	b = rowshape(b,n-1)'
	nvar = rows(b)
	
	prices = aidsills_XMAT[|1,1\nobs,n|]
	intcpt = J(nobs,1,1)
	if (nint > 1) {
		intcpt = aidsills_XMAT[|1,n+nx+nv+1\nobs,ndat|],intcpt
	}
	
	_alpha0 = J(nobs,1,a_0)
	alpha = intcpt*b[|n1+nx+nv+1,1\nvar,n-1|]
	if (n1 != n) {
		gama = b[|1,1\n1,n-1|]\J(1,n-1,0)
	}
	else {
		gama = b[|1,1\n,n-1|]
	}
    a = _alpha0 + prices[|1,n\nobs,n|] + rowsum(prices[|1,1\nobs,n-1|]:*alpha) + .5*rowsum((prices*gama):*prices[|1,1\nobs,n-1|])
	
	st_store(.,a_p,.,a)
}
end

mata:
function aidsills_pidx2(string scalar b_s, 
						string scalar b_p)
{
	external aidsills_XMAT
	n = strtoreal(st_local("n"))
	n1 = strtoreal(st_local("n1"))
	nx = strtoreal(st_local("nx"))
	nv = strtoreal(st_local("nv"))
	nint = strtoreal(st_local("nint"))
	nobs = strtoreal(st_local("nobs"))
	ndat = cols(aidsills_XMAT)
	
	b = st_matrix(b_s)'
	b = rowshape(b,n-1)'
	nvar = rows(b)
	
	prices = aidsills_XMAT[|1,1\nobs,n|]
	beta = b[|n1+1,1\n1+1,n-1|]
	b = exp(prices[|1,1\nobs,n-1|]*beta')
	
	st_store(.,b_p,.,b)
}
end

exit
