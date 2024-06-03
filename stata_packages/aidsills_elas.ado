program aidsills_elas, eclass
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
	
	/* Calculate elasticities */
	
	tempname b_ela V_ela
	local dat `prices' `expenditure' `intercept'
	local wgt "`_tempw'"
	mata: aidsills_XMAT = st_data(., tokens(st_local("dat")))
	mata: aidsills_WMAT = st_data(., tokens(st_local("wgt")))
	mata: aidsills_elas("`b'", "`V'", "`b_ela'", "`V_ela'")
	mata: mata drop aidsills_XMAT
	mata: mata drop aidsills_WMAT
	mat coln `b_ela' = `shares'
	mat coln `V_ela' = `shares'
	
	/* Display results */
	
	tempname be Ve
	local intit shares budget u_price c_price `prices' `prices'
	
	local i = 1
	while `i' <= 4 {
		local var : word `i' of `intit'
		mat `be' = `b_ela'[`i',1..`n']
		mat `Ve' = diag(`V_ela'[`i',1..`n'])
		ereturn post `be' `Ve'
		qui eststo `var'
		local i = `i'+1
	}
	esttab *, cell(b(star fmt(3)) se(par fmt(3))) star(* 0.1 ** 0.05 *** 0.01)		///
	title(PREDICTED SHARES, BUDGET AND (UN)COMPENSATED OWN-PRICE ELASTICITIES)		///
	noobs legend mtitles nonumbers compress
	eststo clear
	
	local i = 5
	local at_i = `n'+`i'-1
	while `i' <= `at_i' {
		local var : word `i' of `intit'
		mat `be' = `b_ela'[`i',1..`n']
		mat `Ve' = diag(`V_ela'[`i',1..`n'])
		ereturn post `be' `Ve'
		qui eststo `var'
		local i = `i'+1
	}
	esttab *, cell(b(star fmt(3)) se(par fmt(3))) star(* 0.1 ** 0.05 *** 0.01)		///
	title(UNCOMPENSATED CROSS-PRICE ELASTICITIES)		///
	noobs legend mtitles nonumbers compress
	eststo clear
	
	local i = `n'+5
	local at_i = `n'+`i'-1
	while `i' <= `at_i' {
		local var : word `i' of `intit'
		mat `be' = `b_ela'[`i',1..`n']
		mat `Ve' = diag(`V_ela'[`i',1..`n'])
		ereturn post `be' `Ve'
		qui eststo `var'
		local i = `i'+1
	}
	esttab *, cell(b(star fmt(3)) se(par fmt(3))) star(* 0.1 ** 0.05 *** 0.01)		///
	title(COMPENSATED CROSS-PRICE ELASTICITIES)		///
	noobs legend mtitles nonumbers compress
	eststo clear
	
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
function aidsills_elas(string scalar b_s, 
					   string scalar V_s, 
					   string scalar b_elas, 
					   string scalar V_elas)
{	
	external aidsills_XMAT
	external aidsills_WMAT
	n = strtoreal(st_local("n"))
	nx = strtoreal(st_local("nx"))
	nv = strtoreal(st_local("nv"))
	nint = strtoreal(st_local("nint"))
	nobs = strtoreal(st_local("nobs"))
	a_0 = strtoreal(st_local("alpha_0"))
	ndat = cols(aidsills_XMAT)
	real matrix t, vt
	
	b = st_matrix(b_s)'
	b = rowshape(b,n)'
	v = st_matrix(V_s)
	nvar = rows(b)
	
	prices = ln(aidsills_XMAT[|1,1\nobs,n|])
	totexp = ln(aidsills_XMAT[|1,n+1\nobs,n+1|])
	X = prices,totexp
	if (nint > 1) {
		X = X,aidsills_XMAT[|1,n+2\nobs,ndat|]
	}
	wgt = aidsills_WMAT
	X = mean(X,wgt)
	
	prices = X[|1\n|]'
	totexp = X[|n+1\n+1|]'
	intcpt = 1
	if (nint > 1) {
		intcpt = (X[|n+1+1\ndat|],intcpt)'
	}
	alpha = intcpt'*b[|n+nx+nv+1,1\nvar,n|]
	gama = b[|1,1\n,n|]
	beta = b[|n+1,1\n+1,n|]
	
	_alpha0 = a_0
	a_p = _alpha0 + alpha*prices + .5*prices'*gama*prices
	lx = totexp-a_p
	w = alpha' + gama'*prices + beta':*lx
	
	if (nx > 1) {
		b_p = exp(beta*prices)
		lambda = b[|n+2,1\n+2,n|]
		lx2 = (lx^2):/b_p
		w = w + lambda':*lx2
	}
	
	dw_dx =  beta'
	if (nx > 1) {
		dw_dx = dw_dx + 2*(lambda':*lx)/b_p
	}
	er = 1 :+ (dw_dx:/w)
	ep = gama' - dw_dx#(alpha + .5*prices'*(gama+gama'))
	if (nx > 1) {
		ep = ep - lambda'#(lx2:*beta)
	}
	ep = -I(n) + ep:/w
	epc = ep + er#w'
	t = w\er\diagonal(ep)\diagonal(epc)\vec(ep)\vec(epc)
	
	b0 = vec(b)
	ab0 = abs(b0)
	if (colsum(b0) != 0) {
		dab0 = b0:/ab0
	}
	else {
		dab0 = 1
	}
	e = (1e-8)*rowmax((ab0, (1e-2)*J(rows(b0),1,1))):*dab0
	be = b0+e
	e = be-b0
	k = 1
	i = 1
	while (i <= cols(b)) {
		j = 1
		while (j <= rows(b)) {
			be = b
			be[j,i] = b[j,i]-e[k]
			
			alpha = intcpt'*be[|n+nx+nv+1,1\nvar,n|]
			gama = be[|1,1\n,n|]
			beta = be[|n+1,1\n+1,n|]
			
			_alpha0 = a_0
			a_p = _alpha0 + alpha*prices + .5*prices'*gama*prices
			lx = totexp-a_p
			w = alpha' + gama'*prices + beta':*lx
			
			if (nx > 1) {
				b_p = exp(beta*prices)
				lambda = be[|n+2,1\n+2,n|]
				lx2 = (lx^2)/b_p
				w = w + lambda':*lx2
			}
			
			dw_dx =  beta'
			if (nx > 1) {
				dw_dx = dw_dx + 2*(lambda':*lx)/b_p
			}
			er = 1 :+ (dw_dx:/w)
			ep = gama' - dw_dx#(alpha + .5*prices'*(gama+gama'))
			if (nx > 1) {
				ep = ep - lambda'#(lx2:*beta)
			}
			ep = -I(n) + ep:/w
			epc = ep + er#w'
			te = w\er\diagonal(ep)\diagonal(epc)\vec(ep)\vec(epc)
			
			dtk = (te-t):/e[k]
			if (k == 1) {
				dt = dtk
				vt = v[1,1]#(dtk:^2)
			}
			else {
				vt = vt + 2*dtk:*(dt*v[|1,k\k-1,k|]) + v[k,k]#(dtk:^2)
				dt = dt,dtk
			}
			j = j+1
			k = k+1
		}
		i = i+1
	}
	
	t = colshape(t',cols(b))
	vt = colshape(vt',cols(b))
	
	st_matrix(b_elas,t)
	st_matrix(V_elas,vt)
}
end

exit
