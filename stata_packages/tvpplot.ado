// Package for Time-Varying-Parameter Regression
// Author: Atsushi Inoue, Barbara Rossi, Yiru Wang, Lingyun Zhou

program define tvpplot
	version 17.0
	
	syntax [if] [in] [, plotcoef(string) plotvarirf(string) PLOTNHORizon(string) PLOTConst period(string) movavg(real 1) noci TItle(string) YTItile(string) XTItile(string) name(string) TVPLegend(string) CONSTLegend(string) BANDLegend(string) SHADELegend(string) PERIODLegend(string) nolegend SCHeme(string) TVPColor(string) CONSTColor(string)]
	
	if ("`e(cmd)'" != "tvpreg") {
		di as err "tvpreg estimate not found."
		exit
	}
	if (("`plotcoef'" == "") & ("`plotvarirf'" == "")) {
		if ("`e(model)'" != "var") di as err "plotcoef() option required."
		else di as err "plotcoef() or plotvarirf() option required."
		exit
	}
	if (("`plotcoef'" != "") & ("`plotvarirf'" != "")) {
		di as err "plotcoef() and plotvarirf() cannot be specified together."
		exit
	}
	if (("`e(model)'" != "var") & ("`plotvarirf'" != "")) {
		di as err "TVP-VAR estimates required."
		exit
	}
	
	cap tsset
    loc timevar  "`r(timevar)'"
	preserve
	tempname check
	qui gen check = e(sample)
	qui sum check
	if (r(mean) > 0) qui keep if e(sample)
	else {
		marksample touse
		if (inlist("`e(model)'","ols","newey")) markout `touse' `e(depvar)' `e(indepvar)'
		else if (inlist("`e(model)'","2sls","weakiv","gmm")) markout `touse' `e(depvar)' `e(instd)' `e(insts)' 
		else markout `touse' `e(depvar)'
		qui keep if `touse'
	}
	
	* dimensions
	if ("`plotnhorizon'" == "") {
		if (("`e(model)'" == "var") & ("`plotcoef'" != "")) loc plotnhorizon = 0
		else loc plotnhorizon `e(horizon)'
	}
	loc minh = e(T)
	loc maxh = 0
	foreach hh in `e(horizon)' {
		loc minh = min(`minh',`hh')
		loc maxh = max(`maxh',`hh')
	}
	loc maxploth = 0
	foreach hh of numlist `plotnhorizon' {
		loc maxploth = max(`maxploth',`hh')
		loc Nh = `Nh' + 1
		if (`Nh' == 1) loc hlist `hh'
		else loc hlist "`hlist' \ `hh'"
	}
	loc T = e(T)
	loc q = e(q)
	loc Nl = wordcount("`e(varlag)'")
	loc n2 = wordcount("`e(depvar)'")
	loc n1 = wordcount("`e(instd)'")
	loc k2 = wordcount("`e(exexog)'")
	if (inlist("`e(model)'","ols","newey")) loc k1 = wordcount("`e(indepvar)'")
	else if ("`e(model)'" == "var") loc k1 = `Nl' * `n2' 
	else loc k1 = wordcount("`e(inexog)'")
	if ("`e(constant)'" == "yes") loc k1 = `k1' + 1
	loc n = `n1' + `n2' // # of endog variables
	loc k = `k1' + `k2' // # of exog variables (w cons)
	loc nq = `n' * `k'
	loc na = `n' * (`n' - 1) / 2
	loc nl = `n'
	loc nqbar = `n1' * `k' + `n2' * (`n1' + `k1')
	loc nqcovar = `n' * (`n' + 1) / 2
	loc qqq = `nqbar' + `nqcovar' // # of total parameters

	if (`Nh' > 1) {
		if ("`e(model)'" == "var") di as text "Plotting the impulse response function..."
		else di as text "Plotting the parameter path over horizons..."
	}
	else if (`Nh' == 1) di as text "Plotting the parameter path over time..."
	
	* transmit data
	tempname tmat
	if ("`period'" != "") mkmat `period', mat(`tmat')
	else mat define `tmat' = J(`T',1,1)
	if ("`plotvarirf'" != "") {
		loc q = `n' * `n'
		loc qqq = `n' * `n'
		mata: coef = st_matrix("e(varirf)")
		mata: coef_ub = st_matrix("e(varirf_ub)")
		mata: coef_lb = st_matrix("e(varirf_lb)")
		if ("`plotconst'" != "") mata: coef_const = st_matrix("e(varirf_const)")
	}
	else if ("`plotcoef'" != "") {
		mata: coef = st_matrix("e(coef)")
		mata: coef_ub = st_matrix("e(coef_ub)")
		mata: coef_lb = st_matrix("e(coef_lb)")
		if ("`plotconst'" != "") mata: coef_const = st_matrix("e(coef_const)")
	}
	// recover the matrix
	if (("`e(model)'" == "var") & ("`plotcoef'" != "")) {
		mata: coef_all = coef
		mata: coef_ub_all = coef_ub
		mata: coef_lb_all = coef_lb
		if ("`plotconst'" != "") mata: coef_const_all = coef_const
	}
	else {
		mata: coef_all = J((`maxh'+1)*`q',`T',0)
		mata: coef_ub_all = J((`maxh'+1)*`q',`T',0)
		mata: coef_lb_all = J((`maxh'+1)*`q',`T',0)
		if ("`plotconst'" != "") mata: coef_const_all = J((`maxh'+1)*`qqq',1,0)
		loc nh = 0
		foreach hh of numlist `e(horizon)' {
			mata: coef_all[`hh'*`q'+1..(`hh'+1)*`q',.] = coef[`nh'*`q'+1..(`nh'+1)*`q',.]
			mata: coef_lb_all[`hh'*`q'+1..(`hh'+1)*`q',.] = coef_ub[`nh'*`q'+1..(`nh'+1)*`q',.]
			mata: coef_ub_all[`hh'*`q'+1..(`hh'+1)*`q',.] = coef_lb[`nh'*`q'+1..(`nh'+1)*`q',.]
			if ("`plotconst'" != "") mata: coef_const_all[`hh'*`qqq'+1..(`hh'+1)*`qqq',.] = coef_const[`nh'*`qqq'+1..(`nh'+1)*`qqq',.]
			loc nh = `nh' + 1
		}
	}

	* extract the horizons
	if (`Nh' == 1) { // Parameter path over time
		mata: coef = coef_all[`plotnhorizon'*`q'+1..(`plotnhorizon'+1)*`q',.]
		mata: coef_ub = coef_ub_all[`plotnhorizon'*`q'+1..(`plotnhorizon'+1)*`q',.]
		mata: coef_lb = coef_lb_all[`plotnhorizon'*`q'+1..(`plotnhorizon'+1)*`q',.]
		if ("`plotconst'" != "") mata: coef_const = coef_const_all[`plotnhorizon'*`qqq'+1..(`plotnhorizon'+1)*`qqq',.]
	}
	else { // Parameter path over horizons
		mata: IRF = J(`Nh'*`q',`T',0)
		if ("`plotconst'" != "") mata: IRF_const = J(`Nh'*`qqq',1,0)
		loc nh = 0
		foreach hh of numlist `plotnhorizon' {
			loc nh = `nh' + 1
			forvalues qq = 1/`q' {
				mata: IRF[(`qq'-1)*`Nh'+`nh',.] = coef_all[`hh'*`q'+`qq',.]
			}
			if ("`plotconst'" != "") {
				forvalues qq = 1/`q' {
					mata: IRF_const[(`qq'-1)*`Nh'+`nh',.] = coef_const_all[`hh'*`qqq'+`qq',.]
				}
			}
		}
	}
	
	* options
	if ("`name'" == "") loc name tvpreg
	loc namecmd name(`name')
	cap graph drop `name'
	if ("`ytitle'" == "") loc ytitlecmd ytitle("Parameter")
	else loc ytitlecmd ytitle(`ytitle')
	if ("`xtitle'" == "") {
		if (`Nh' == 1) loc xtitlecmd xtitle("Time")
		else loc xtitlecmd xtitle("Horizon")
	}
	else loc xtitlecmd xtitle(`xtitle')
	loc level = e(level)
	if ("`tvplegend'" == "") loc tvplegend "Time-varying parameter"
	if ("`constlegend'" == "") loc constlegend "Constant parameter"
	if ("`bandlegend'" == "") loc bandlegend "`level'% confidence band"
	if ("`shadeband'" == "") loc shadeband "`period'"
	if ("`e(band)'" == "no") loc ci noci
	if ("`scheme'" == "") local scheme `c(scheme)'
	if ("`tvpcolor'" == "") loc tvpcolor lc(green)
	else loc tvpcolor lc(`tvpcolor')
	if ("`constcolor'" == "") loc constcolor lc(black)
	else loc constcolor lc(`constcolor')
	
	* Figure
	loc tvpfigs
	loc nf
	foreach v in `plotcoef' `plotvarirf' {
		loc nf = `nf' + 1
		loc ff = 0
		if ("`plotcoef'" != "") {
			loc pos = 0
			foreach vv in `e(coefname)' {
				loc pos = `pos' + 1
				if ("`v'" == "`vv'") loc ff = `pos'
			}
		}
		else if ("`plotvarirf'" != "") {
			loc pos = 0
			foreach vv in `e(varirfname)' {
				loc pos = `pos' + 1
				if ("`v'" == "`vv'") loc ff = `pos'
			}
		}
		if (`ff' == 0) {
			if ("`plotcoef'" != "") di as err "`v' is not a valid name for plotcoef()."
			else di as err "`v' is not a valid name for plotvarirf()."
			exit
		}
		else {
			parse "`v'", parse(":")
			cap gr drop tvpreg`ff'
			loc tvpfigs `tvpfigs' tvpreg`ff'
			if ("`title'" != "") loc titlecmd title("`title'")
			else {
				if ("`2'" == ":") {
					loc paratype "slope"
					loc lhs "`1'"
					loc rhs "`3'"
					loc titlecmd title("`lhs' : `rhs'")
				}
				else {
					loc paratype "cov"
					loc titlecmd title("cov para `v'")
				}
			}
			loc suboption `ytitlecmd' `xtitlecmd' `titlecmd' name("tvpreg`ff'") nodraw
			if (`Nh' == 1) { // Parameter path over time
				mata: movmat = movmean(`T'-`plotnhorizon'+`minh',`movavg')
				tempname lower_i upper_i coef_i coef_const_i
				mata: lower_i = (movmat*(coef_lb[`ff',1..`T'-`plotnhorizon'+`minh'])' \ J(`plotnhorizon',1,.))
				mata: upper_i = (movmat*(coef_ub[`ff',1..`T'-`plotnhorizon'+`minh'])' \ J(`plotnhorizon',1,.))
				mata: coef_i = (movmat*(coef[`ff',1..`T'-`plotnhorizon'+`minh'])' \ J(`plotnhorizon',1,.))
				getmata `coef_i'=coef_i `upper_i'=upper_i `lower_i'=lower_i
				if ("`plotconst'" != "") {
					mata: coef_const_i = (J(`T'-`plotnhorizon'+`minh',1,coef_const[`ff']) \ J(`plotnhorizon',1,.))
					getmata `coef_const_i'=coef_const_i
					loc plotconst || (line `coef_const_i' `timevar', lp(solid) lwidth(0.5) `constcolor')
				}
				if ("`legend'" == "") {
					if ("`period'" == "") {
						if (("`ci'" == "") & ("`plotconst'" != "")) loc legendcmd legend(order(1 "`tvplegend'" 2 "`bandlegend'" 4 "`constlegend'"))
						else if (("`ci'" == "") & ("`plotconst'" == "")) loc legendcmd legend(order(1 "`tvplegend'" 2 "`bandlegend'"))
						else if (("`ci'" != "") & ("`plotconst'" != "")) loc legendcmd legend(order(1 "`tvplegend'" 2 "`constlegend'"))
						else if (("`ci'" != "") & ("`plotconst'" == "")) loc legendcmd legend(off)
					}
					else {
						loc bglegend legend
						if (("`ci'" == "") & ("`plotconst'" != "")) loc legendcmd legend(order(2 "`tvplegend'" 3 "`bandlegend'" 5 "`constlegend'" 1 "`shadeband'"))
						else if (("`ci'" == "") & ("`plotconst'" == "")) loc legendcmd legend(order(2 "`tvplegend'" 3 "`bandlegend'" 1 "`shadeband'"))
						else if (("`ci'" != "") & ("`plotconst'" != "")) loc legendcmd legend(order(2 "`tvplegend'" 3 "`constlegend'" 1 "`shadeband'"))
						else if (("`ci'" != "") & ("`plotconst'" == "")) loc legendcmd legend(order(2 "`tvplegend'" 1 "`shadeband'"))
					}
				}
				else loc legendcmd legend(off)
				if ("`ci'" != "") loc twcmd (line `coef_i' `timevar', lp(solid) lwidth(0.5) `tvpcolor') `plotconst', `suboption' `legendcmd' scheme(`scheme')
				else loc twcmd (line `coef_i' `timevar', lp(solid) lwidth(0.5) `tvpcolor') || (line `lower_i' `timevar', lp(dash) lwidth(0.5) `tvpcolor') || (line `upper_i' `timevar', lp(dash) lwidth(0.5) `tvpcolor') `plotconst', `suboption' `legendcmd' scheme(`scheme')
				if ("`period'" != "") bgshade `timevar', shaders(`period') twoway(`twcmd') `bglegend'
				else gr tw `twcmd'
			}
			else { // Parameter path over horizons
				loc Th = `T' - `maxploth'
				loc S = 0
				loc legendcmd
				loc grcommand
				if (`"`periodlegend'"' != "") parse "`periodlegend'", parse(",")
				loc W
				forvalues ss = 1/`Th' {
					if (`tmat'[`ss',1] == 1) {
						loc W = `W' + 1
					}
				}
				loc width = 0.1 + 0.4 * exp((1 - `W')/10)
				forvalues ss = 1/`Th' {
					if (`tmat'[`ss',1] == 1) {
						mata: IRF_`ss' = (IRF[(`ff'-1)*`Nh'+1..`ff'*`Nh',`ss'], (`hlist'))
						loc S = `S' + 1
						loc SS = 2 * `S' - 1
						if (`"`periodlegend'"' != "") {
							loc legendcmd `legendcmd' `S' "``SS''"
							loc patterns = "l -  ._"
							loc SSS = mod(`S',3)
							if (`SSS' == 0) loc SSS = 3
							if (`SSS' == `S') loc pattern = word("`patterns'",`SSS')
							else {
								loc pattern = word("`patterns'",`SSS')
								loc SSSS = (`S' - `SSS') / 3
								forvalues s = 1/`SSSS' {
									loc pattern `pattern'.
								}
							}
							loc grcommand `grcommand' (line matamatrix(IRF_`ss'), lp("`pattern'") lwidth(`width') `tvpcolor') ||
						}
						else loc grcommand `grcommand' (line matamatrix(IRF_`ss'), lp(solid) lwidth(`width') `tvpcolor') ||
					}
				}
				if ("`plotconst'" != "") {
					mata: IRF_c = (IRF_const[(`ff'-1)*`Nh'+1..`ff'*`Nh',1], (`hlist'))
					loc grcommand `grcommand' (scatter matamatrix(IRF_c), m(O) mc(black) msiz(0.5) connect(l) lp(solid) lwidth(0.5) `constcolor') ||
					loc S = `S' + 1
				}
				if (("`legend'" == "") & ("`plotconst'" != "")) {
					if (`"`periodlegend'"' != "") loc legendcmd legend(order(`legendcmd' `S' "`constlegend'"))
					else loc legendcmd legend(order(1 "`tvplegend'" `S' "`constlegend'"))
				}
				else loc legendcmd legend(off)
				gr tw `grcommand', `suboption' `legendcmd' scheme(`scheme')
			}
		}
		if ("`paratype'" == "slope") di as text "slope para: effect of `rhs' on `lhs'"
		else di as text "cov para: `v'"
	}
	loc scale = 1 / ceil(sqrt(wordcount("`plotcoef' `plotvarirf'")))
	graph combine `tvpfigs', `namecmd' iscale(`scale')
	graph drop `tvpfigs'
	restore
end

mata:
 real matrix movmean(real scalar T, real scalar K) {
	real scalar k, sk, ek, dk
	real matrix A
	
	A = J(T,T,0)
	for (k=1;k<=T;k++) {
		sk = floor(max((1,k-(K-1)/2)))
		ek = floor(min((T,k+(K-1)/2)))
		dk = ek - sk + 1
		A[k,sk..ek] = J(1, dk, 1/dk)
	}
	return(A)
 }
end
