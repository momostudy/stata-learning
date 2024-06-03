program aidsills, eclass
	version 11
	if replay() {
		if "`e(cmd)'" != "aidsills" {
			error 301
		}
		Replay `0'
	}
	else {
		Estimate `0'
	}
end

program Estimate, eclass
	syntax varlist [if] [in] [fweight aweight/],		///
		PRIces(varlist numeric)		///
		EXPenditure(varlist min=1 max=1 numeric) [		///
		INTercept(varlist numeric)		///
		IVPrices(varlist numeric)		///
		IVExpenditure(varlist numeric)		///
		QUAdratic		///
		HOMogeneity		///
		SYMmetry		///
		NOFirst		///
		TOLerance(real 1e-5)		///
		ITeration(integer 50)		///
		ALpha_0(real 0)		///
		Level(integer `c(level)') ]
	
	local shares `varlist'
	local opt allexog nocnsreport nofooter level(`level')
	
	tempvar _tempw
	if "`exp'" != "" {
		gen `_tempw' = `exp'
    	local wexp "[`weight' = `_tempw']"
	}
	else {
	    gen `_tempw' = 1
		local wexp ""
	}
	
	/* Replace null prices and expenditure by missing values */
	
	local n : word count `shares'
	local np : word count `prices'
	if `n' != `np' {
		di as error "Specify `n' variables in prices"
		exit
	}
	
	local i = 1
	while `i' <= `n' {
		local vari : word `i' of `prices'
		qui replace `vari' = . if `vari' == 0
		qui su `vari'
		if r(min) < 0 {
			di as error "Variable `vari' in prices has negative observations"
			di as error "This is not allowed"
			exit
		}
		local i = `i'+1
	}
	qui replace `expenditure' = . if `expenditure' == 0
	qui su `expenditure'
	if r(min) < 0 {
		di as error "Variable `expenditure' in expenditure has negative observations"
		di as error "This is not allowed"
		exit
	}
	
	/* Mark the estimation sample and drop missing data */
	
	marksample touse
	markout `touse' `prices' `expenditure' `intercept' `ivprices' `ivexpenditure'
	
	preserve
	qui keep if `touse'
	local nobs = _N
	if `nobs' == 0 {
		di as error "No observations"
		exit
	}
	
	/* Check that IVs are correctly specified */
	
	if "`ivprices'" != "" {
		local np : word count `ivprices'
		if `np' < `n' {
			di as error "Specify at least `n' variables in ivprices"
			exit
		}
		if "`ivexpenditure'" != "" {
			local ne : word count `ivexpenditure'
			local i = 1
			while `i' <= `ne' {
				local vari : word `i' of `ivexpenditure'
				local j = 1
				while `j' <= `np' {
					local varj : word `j' of `ivprices'
					if "`vari'" == "`varj'" {
						di as error "Variable `varj' cannot enter both ivprices and ivexpenditure"
						exit
					}
					local j = `j'+1
				}
				local i = `i'+1
			}	
		}
	}
	
	/* Check that IVs do not perfectly correlate to endogenous variables */
	
	local lnp
	local i = 1
	while `i' <= `n' {
		local vari : word `i' of `prices'
		tempvar ln`vari'
		qui gen double `ln`vari'' = ln(`vari')
		local lnp `lnp' `ln`vari''
		local i = `i'+1
	}
	
	if "`ivprices'" != "" {
		local np : word count `ivprices'
		local i = 1
		while `i' <= `np' {
			local vari : word `i' of `ivprices'
			local j = 1
			while `j' <= `n' {
				local varj : word `j' of `prices'
				local vark : word `j' of `lnp'
				qui cor `vari' `vark'
				local cor = 1-r(rho)
				if `cor' < 1e-5 {
					di as error "Variable `vari' in ivprices perfectly correlates to logged-price ln(`varj')"
					di as error "This is not allowed"
					exit
				}
				local j = `j'+1
			}
			local i = `i'+1	
		}
	}
	
	tempvar ln`expenditure'
	qui gen double `ln`expenditure'' = ln(`expenditure')
	
	if "`ivexpenditure'" != "" {
		local ne : word count `ivexpenditure'
		local i = 1
		while `i' <= `ne' {
			local vari : word `i' of `ivexpenditure'
			qui cor `vari' `ln`expenditure''
			local cor = 1-r(rho)
			if `cor' < 1e-5 {
				di as error "Variable `vari' in ivexpenditure perfectly correlates to logged-expenditure ln(`expenditure')"
				di as error "This is not allowed"
				exit
			}
			local i = `i'+1
		}
	}
	
	/* Run IV regressions and construct control functions */
	
	local v
	local nv = 0
	local nz = 0
	local ivvar `ivprices' `ivexpenditure'
	if "`ivvar'" != "" {
		local nz : word count `ivvar'
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
		if "`nofirst'" == "" {
			di
			di "INSTRUMENTAL REGRESSION(S)"
		}
	}
	
	if "`ivprices'" != "" {
		local i = 1
		while `i' <= `n' {
			local vari : word `i' of `prices'
			qui reg `ln`vari'' `exvar' `wexp'
			tempvar v`vari'
			qui predict `v`vari'', r
			local nv = `nv'+1
			local v `v' `v`vari''
			if "`nofirst'" == "" {
				tempname b V
				reg `ln`vari'' `exvar' `wexp', notable
				mat `b' = e(b)
				mat `V' = e(V)
				mat coln `b' = `varn'
				mat coln `V' = `varn'
				mat rown `V' = `varn'
				ereturn post `b' `V', depname(ln`vari')
				ereturn display
			}
			local i = `i'+1
		}
	}
	
	if "`ivexpenditure'" != "" {
		qui reg `ln`expenditure'' `exvar' `wexp'
		tempvar v`expenditure'
		qui predict `v`expenditure'', r
		local nv = `nv'+1
		local v `v' `v`expenditure''
		if "`nofirst'" == "" {
			tempname b V
			reg `ln`expenditure'' `exvar' `wexp', notable
			mat `b' = e(b)
			mat `V' = e(V)
			mat coln `b' = `varn'
			mat coln `V' = `varn'
			mat rown `V' = `varn'
			ereturn post `b' `V', depname(ln`expenditure')
			ereturn display
		}
	}
	
	/* Construct independent variables */
	
	tempvar stone
	local lnrel
	local varr : word `n' of `prices'
	qui gen double `stone' = 0
	local i = 1
	while `i' <= `n' {
		local vars : word `i' of `shares'
		local varp : word `i' of `prices'
		qui su `vars' `wexp'
		qui replace `stone' = `stone'+(r(mean)*`ln`varp'')
		if `i' != `n' {
			qui replace `ln`varp'' = `ln`varp''-ln(`varr')
		}
		if `i' != `n' {
			local lnrel `lnrel' `ln`varp''
		}
		else {
			local lnref `ln`varp''
		}
		local i = `i'+1
	}
	
	tempvar lnx
	qui gen double `lnx' = `ln`expenditure''-`stone'
	qui drop `ln`expenditure'' `stone'
	local envar `lnx'
	local nx = 1
	local model "AIDS"
	if "`quadratic'" != "" {
		tempvar lnx2
		qui gen double `lnx2' = `lnx'^2
		local envar `envar' `lnx2'
		local nx = `nx'+1
		local model "QU`model'"
	}
	
	/* Define (QU)AIDS and constraints */
	
	local nint : word count `intercept'
	local nint = `nint'+1
	local lnp `lnrel'
	local n1 = `n'-1
	if "`homogeneity'" == "" & "`symmetry'" == "" {
		local const "UN"
		local lnp `lnp' `lnref'
		local n1 = `n'
	}
	local sys
	local indvar `lnp' `envar' `v' `intercept'
	local nvar = `n1'+`nx'+`nv'+`nint'
	local i = 1
	while `i' <= `n'-1 {
		local depvar : word `i' of `shares'
		local eq`i' "`depvar' `indvar'"
		local sys `sys' (`eq`i'')
		local i = `i'+1
	}
	
	if "`homogeneity'" != "" | "`symmetry'" != "" {
		local const "HOMOGENEITY "
		local sym
		local i = 1
		local j = 1
		while `j' <= `n'-1 {
			local k = `j'+1
			while `k' <= `n'-1 {
				local varsj : word `j' of `shares'
				local varsk : word `k' of `shares'
				local varpj : word `j' of `lnp'
				local varpk : word `k' of `lnp'
				local s`i' "[`varsj']`varpk' = [`varsk']`varpj'"
				constraint define `i' `s`i''
				local sym `sym' (`s`i'')
				local i = `i'+1
				local k = `k'+1
			}
			local j = `j'+1
		}
		if "`symmetry'" != "" {
			local nc = (`n'-1)*(`n'-2)/2
			local const "`const'AND SYMMETRY "
		}
	}
	
	/* Estimate the linearized version */
	
	if `iteration' == 0 {
		tempname b
		if "`symmetry'" == "" {
			qui reg3 `sys' `wexp', `opt'
		}
		else {
			qui reg3 `sys' `wexp', constr(1/`nc')
		}
		mat `b' = e(b)
	}
	
	/* Estimate the full version */
	
	if `iteration' > 0 {
		di
		tempname b0 b
		tempvar a_p
		local ok = 1
		local it = 0
		while `ok' == 1 {
			if `it' > 0 {
				qui gen double `a_p' = .
				local dat `lnrel' `lnref' `envar' `v' `intercept'
				mata: aidsills_XMAT = st_data(., tokens(st_local("dat")))
				mata: aidsills_pidx1("`b'", "`a_p'")
				qui replace `lnx' = ln(`expenditure')-`a_p'
				qui drop `a_p'
				if "`quadratic'" != "" {
					tempvar b_p
					qui gen double `b_p' = .
					mata: aidsills_pidx2("`b'", "`b_p'")
					qui replace `lnx2' = (`lnx'^2)/`b_p'
					qui drop `b_p'
				}
				mata: mata drop aidsills_XMAT
			}
			qui reg3 `sys' `wexp', `opt'
			if `it' > 0 {
				mat `b' = e(b)
				local dif = mreldif(`b',`b0')
				di as text "Iteration = " `it' _col(21) "Criterion = " as res `dif'
				if `it' > `iteration' | `dif' <= `tolerance' {
					local ok = 0
				}
				mat `b0' = `b'
			}
			else {
				mat `b0' = e(b)
				mat `b' = e(b)
			}
			local it = `it'+1
		}
		if "`symmetry'" != "" {
			qui reg3 `sys' `wexp', constr(1/`nc') `opt'
			mat `b' = e(b)
		}
	}
	
	/* Calculate the asymptotic variance */
	
	tempname V
	local dat `shares' `lnrel' `lnref' `envar' `v' `intercept' `ivvar'
	local wgt `_tempw'
	mata: aidsills_XMAT = st_data(., tokens(st_local("dat")))
	mata: aidsills_WMAT = st_data(., tokens(st_local("wgt")))
	mata: aidsills_asvar("`b'", "`V'")
	mata: mata drop aidsills_XMAT
	mata: mata drop aidsills_WMAT
	local varn : colfullnames `b'
	mat coln `V' = `varn'
	mat rown `V' = `varn'
	
	cap ereturn repost b=`b' V=`V'
	if _rc!=0 {
		di as error "Missing values in b and/or V; check your specification (perfect colinearity, etc.)"
		exit
	}
	
	/* Test the constraints */
	
	if "`symmetry'" == "" {
		if "`homogeneity'" == "" {
			qui test `lnref'
		}
		else {
			qui test `sym'
		}
		local chi = r(chi2)
		local df = r(df)
		local pv = r(p)
	}
	
	/* Recover last equation estimates */
	
	mat `b' = e(b)
	mat `V' = e(V)
	
	tempname bfull vfull
	mata: aidsills_bfull("`b'", "`V'", "`bfull'", "`vfull'")
	mat `b' = `bfull'
	mat `V' = `vfull'
	mat coln `b' = `shares'
	
	mat rown `b' = `indvar' "_cons"
	mat `b' = vec(`b')'
	local varn : colfullnames `b'
	mat coln `V' = `varn'
	mat rown `V' = `varn'
	mat drop `bfull' `vfull'
	
	/* Recover absolute price effects from relative */
	
	tempname babs vabs
	mata: aidsills_babs("`b'", "`V'", "`babs'", "`vabs'")
	mat `b' = `babs'
	mat `V' = `vabs'
	mat coln `b' = `shares'
	
	local varp
	local i = 1
	while `i' <= `n' {
		local vari : word `i' of `prices'
		local varp `varp' gamma_ln`vari'
		local i = `i'+1
	}
	local varn `varp' beta_lnx
	if "`quadratic'" != "" {
		local varn `varn' lambda_lnx2
	}
	if `nv' != 0 {
		local varv
		if "`ivprices'" != "" {
			local i = 1
			while `i' <= `n' {
				local vari : word `i' of `prices'
				local varv `varv' rho_v`vari'
				local i = `i'+1
			}
		}
		if "`ivexpenditure'" != "" {
			local varv `varv' rho_v`expenditure'
		}
		local varn `varn' `varv'
	}
	local i = 1
	while `i' <= `nint' {
		local varp : word `i' of `intercept' "cons"
		local varn `varn' alpha_`varp'
		local i = `i'+1
	}

	mat rown `b' = `varn'
	mat `b' = vec(`b')'
	local varn : colfullnames `b'
	mat coln `V' = `varn'
	mat rown `V' = `varn'
	mat drop `babs' `vabs'
	
	/* Prepare matrices to be returned */
	
	tempname alpha gamma beta lambda rho
	mata: aidsills_bret("`b'", "`alpha'", "`gamma'", "`beta'", "`lambda'", "`rho'")
	mat coln `alpha' = `shares'
	mat rown `alpha' = `intercept' "_cons"
	mat coln `gamma' = `shares'
	mat rown `gamma' = `varp'
	mat coln `beta' = `shares'
	mat rown `beta' =  lnx
	if "`quadratic'" != "" {
		mat coln `lambda' = `shares'
		mat rown `lambda' =  lnx2
	}
	if `nv' != 0 {
		mat coln `rho' = `shares'
		mat rown `rho' =  `varv'
	}
	
	/* Display overall statistics */
	
	if `iteration' == 0 {
		di
		di "`model' - LINEARIZED WITH STONE PRICE INDEX"
	}
	if `iteration' > 0 {
		di
		di "`model' - PROPER ESTIMATION WITH FIXED ALPHA_0 = `alpha_0'"
	}
	di as text "`const'CONSTRAINED ESTIMATES"
	
	local nvar = `n'+`nx'+`nv'+`nint'
	local df1 = `nvar'-1
	local df2 = `nobs'-`nvar'
	di
	di "{hline 78}"
	di as text "Equation          Obs  Parms        RMSE    "  _quote "R-sq" _quote "    F(" %3.0f `df1' "," %6.0f `df2' ")   Prob > F"
	di "{hline 78}"
	local i = 1
	while `i' <= `n' {
		local depvar : word `i' of `shares'
		qui reg `depvar' `indvar' `wexp'
		local f = e(F)
		local pvf = 1-F(`df1', `df2', `f')
		di as res abbrev(e(depvar),12) _col(15) %7.0g e(N) %7.0g `df1'  "   " %9.0g e(rmse) %10.4f e(r2) "        "    %8.2f `f' "  " %10.4f `pvf'
		local i = `i'+1
	}
	di "{hline 78}"
	di
	if "`symmetry'" == "" {
		if "`homogeneity'" == "" {
			di as text "HOMOGENEITY TEST:   Chi2(" %3.0f `df' ") = " %8.2f as res `chi' as text "    Prob > chi2 = " %8.4f as res `pv'
		}
		else {
			di as text "SYMMETRY TEST:      Chi2(" %3.0f `df' ") = " %8.2f as res `chi' as text "    Prob > chi2 = " %8.4f as res `pv'
		}
		di
	}
	
	/* Restore data */
	
	restore
	
	/* Display parameter estimates */
	
	ereturn post `b' `V', esample(`touse')
	ereturn display
	
	/* Returns */
	
	eret matrix alpha = `alpha'
	eret matrix gamma = `gamma'
	eret matrix beta = `beta'
	if "`quadratic'" != "" {
		eret matrix lambda = `lambda'
	}
	if `nv' != 0 {
		eret matrix rho = `rho'
	}
	
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
	
	eret local wtype "`weight'"
	eret local wvar "`exp'"
	
	eret local cmd "aidsills"

end

program Replay
	syntax [, Level(integer `c(level)')]
	
	di
	if `e(iteration)' == 0 {
		di e(model) " - LINEARIZED WITH STONE PRICE INDEX"
	}
	if `e(iteration)' > 0 {
		di e(model) " - PROPER ESTIMATION WITH FIXED ALPHA_0 = " e(alpha_0)
	}
	di as text e(const) "CONSTRAINED ESTIMATES"
	di
	_coef_table, level(`level')
	
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

mata:
function aidsills_asvar(string scalar b_s, 
						string scalar V_s)
{	
	external aidsills_XMAT
	external aidsills_WMAT
	n = strtoreal(st_local("n"))
	n1 = strtoreal(st_local("n1"))
	nx = strtoreal(st_local("nx"))
	nz = strtoreal(st_local("nz"))
	nv = strtoreal(st_local("nv"))
	nint = strtoreal(st_local("nint"))
	nobs = strtoreal(st_local("nobs"))
	iter = strtoreal(st_local("iteration"))
	ndat = cols(aidsills_XMAT)
	real matrix V
	
	b = st_matrix(b_s)'
	b = rowshape(b,n-1)'
	nvar = rows(b)
	
	b = b,((J(nvar-1,1,0)\1)-rowsum(b))
	
	shares = aidsills_XMAT[|1,1\nobs,n|]
	prices = aidsills_XMAT[|1,n+1\nobs,n+n|]
	lx = aidsills_XMAT[|1,n+n+1\nobs,n+n+1|]
	g = prices[|1,1\nobs,n1|],lx
	if (nx > 1) {
		beta = b[|n1+1,1\n1+1,n-1|]
		b_p = exp(prices[|1,1\nobs,n-1|]*beta')
		lx2 = aidsills_XMAT[|1,n+n+2\nobs,n+n+2|]
		g = g,lx2
	}
	if (nv != 0) {
		instr = aidsills_XMAT[|1,ndat-nz+1\nobs,ndat|]
		v = aidsills_XMAT[|1,n+n+nx+1\nobs,n+n+nx+nv|]
		g = g,v
	}
	intcpt = J(nobs,1,1)
	if (nint > 1) {
		intcpt = aidsills_XMAT[|1,n+n+nx+nv+1\nobs,ndat-nz|],intcpt
	}
	wgt = aidsills_WMAT
	g = g,intcpt
	gg = cross(g,wgt,g)
	
	if (iter > 1) {
		i = 1
		while (i <= n-1) {
			beta = b[|n1+1,i\n1+1,i|]
			ki = 1
			while (ki <= n-1) {
				y1 = (0.5*prices[|1,1\nobs,n1|]),J(nobs,nx+nv,0),intcpt
				y2 = prices[|1,ki\nobs,ki|]:*y1
				if (i == ki) {
					Je = gg-beta'*cross(g,wgt,y2)
				}
				else {
					Je = -beta'*cross(g,wgt,y2)
				}
				if (nx > 1) {
					lambda = b[|n1+2,i\n1+2,i|]
					y1 = (prices[|1,1\nobs,n1|]:*(lx:/b_p)),lx2,J(nobs,1+nv,0),(2*intcpt:*(lx:/b_p))
					y2 = prices[|1,ki\nobs,ki|]:*y1
					Je = Je-lambda'*cross(g,wgt,y2)
				}
				if (ki == 1) {
					Jr = Je
				}
				else {
					Jr = Jr,Je
				}
				ki = ki+1
			}
			if (i == 1) {
				J = Jr
			}
			else {
				J = J\Jr
			}
			i = i+1
		}
	}
	else {
		J = I(n-1)#gg
	}
	
	ss = cross(shares,wgt,shares)
	gs = cross(g,wgt,shares)
	sse = ss-b'*gs
	s = sse/nobs
	sigma = s[|1,1\n-1,n-1|]#gg
	if (nv != 0) {
		z = instr,intcpt
		if (nv == 1) {
			z = prices,z
		}
		zz = cross(z,wgt,z)
		zzi = invsym(zz)
		D = cross(g,wgt,z)
		R = b[|n1+nx+1,1\n1+nx+nv,n-1|]
		vv = cross(v,wgt,v)
		O = (R'*(vv/nobs))*R
		sigma = sigma+O#(D*zzi*D')
	}
	Ji = luinv(J)
	V = Ji*sigma*Ji'
	
	i = 1
	while (i <= cols(V)) {
		V[.,i] = V[i,.]'		/* get rid of 1e-nth precision errors */
		i = i+1
	}
	
	st_matrix(V_s,V)
}
end

mata:
function aidsills_bfull(string scalar b_s, 
						string scalar V_s, 
						string scalar bfull_s, 
						string scalar vfull_s)
{	
	n = strtoreal(st_local("n"))
	n1 = strtoreal(st_local("n1"))
	nx = strtoreal(st_local("nx"))
	nv = strtoreal(st_local("nv"))
	nint = strtoreal(st_local("nint"))
	nvar = n1+nx+nv+nint
	real matrix b, v

	b = st_matrix(b_s)'
	b = rowshape(b,n-1)'
	b = b,((J(nvar-1,1,0)\1)-rowsum(b))
	
	v = st_matrix(V_s)
	ii = J(1,n-1,-1)#I(nvar)
	v = ((v\ii*v),(v*ii'\ii*v*ii'))
	
	st_matrix(bfull_s,b)
	st_matrix(vfull_s,v)
}
end

mata:
function aidsills_babs(string scalar b_s, 
						string scalar V_s, 
						string scalar babs_s, 
						string scalar vabs_s)
{	
	n = strtoreal(st_local("n"))
	n1 = strtoreal(st_local("n1"))
	nx = strtoreal(st_local("nx"))
	nv = strtoreal(st_local("nv"))
	nint = strtoreal(st_local("nint"))
	nvar = n1+nx+nv+nint
	real matrix b, v
	
	b = st_matrix(b_s)'
	b = rowshape(b,n)'
	v = st_matrix(V_s)
	
	ic = range(1,n1,1)
	ig = range(n1+1,nvar,1)
	ic = vec(ic:+J(rows(ic),1,1)#range(0,nvar*(n-1),nvar)')
	ig = vec(ig:+J(rows(ig),1,1)#range(0,nvar*(n-1),nvar)')
	i = ic\ig
	
	if (n1 == n) {		/* recovers g1,g2,g3 from g1,g2,g1+g2+g3 */
		R1 = (I(n-1),J(n-1,1,0))\(J(1,n-1,-1),1)
		R1 = I(n)#R1
		k = (nvar-n)*n
		X = (R1,J(rows(R1),k,0))\(J(k,cols(R1),0),I(k))
		X = X[invorder(i),invorder(i')]
	}
	else {				/* recovers g1,g2,g3 from g1,g2 */
	    R1 = I(n1)\J(1,n1,-1)
		R1 = I(n)#R1
		k = (nvar-n1)*n
		X = (R1,J(rows(R1),k,0))\(J(k,cols(R1),0),I(k))
		X = X[.,invorder(i')]
		
		ic = range(1,n,1)
		ig = range(n+1,nvar+1,1)
		ic = vec(ic:+J(rows(ic),1,1)#range(0,(nvar+1)*(n-1),nvar+1)')
		ig = vec(ig:+J(rows(ig),1,1)#range(0,(nvar+1)*(n-1),nvar+1)')
		i = ic\ig
		X = X[invorder(i),.]
	}
	
	b = X*vec(b)
	b = rowshape(b,n)'
	v = X*v*X'
	
	st_matrix(babs_s,b)
	st_matrix(vabs_s,v)
}
end

mata:
function aidsills_bret(string scalar b_s, 
						string scalar alpha_s, 
						string scalar gamma_s, 
						string scalar beta_s, 
						string scalar lambda_s, 
						string scalar rho_s)
{
	n = strtoreal(st_local("n"))
	nx = strtoreal(st_local("nx"))
	nv = strtoreal(st_local("nv"))
	nint = strtoreal(st_local("nint"))
	nvar = n+nx+nv+nint
	real matrix alpha, gamma, beta, lambda, rho
	
	b = st_matrix(b_s)'
	b = rowshape(b,n)'
	
	gamma = b[|1,1\n,n|]
	beta = b[|n+1,1\n+1,n|]
	if (nx > 1 ) {
		lambda = b[|n+nx,1\n+nx,n|]
	}
	else {
		lambda = 0
	}
	if (nv != 0) {
		rho = b[|n+nx+1,1\n+nx+nv,n|]
	}
	else {
		rho = 0	
	}
	alpha = b[|n+nx+nv+1,1\nvar,n|]
	
	st_matrix(gamma_s,gamma)
	st_matrix(beta_s,beta)
	st_matrix(lambda_s,lambda)
	st_matrix(rho_s,rho)
	st_matrix(alpha_s,alpha)
}
end

exit
