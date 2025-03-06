// Package for Time-Varying-Parameter Regression
// Author: Atsushi Inoue, Barbara Rossi, Yiru Wang, Lingyun Zhou

cap program drop tvpreg
cap program drop tvpplot
cap program drop Estimate
cap program drop Replay
program define tvpreg, eclass

    version 17.0

	if replay() {
		Replay
	}
	else {
		cap noi Estimate `0'
	}
	
end

program define Estimate, eclass

	loc cmdline tvpreg `0'
	_iv_parse `0'
	
	local y2z1 `s(lhs)' `s(exog)'
	local y1 `s(endog)'
	local z2 `s(inst)'
	local 0 `s(zero)'

	syntax [if] [in] [, 			///
		///* Estimator*///
		ols							/// ordinary least squares; the default when no instruments are specified
		newey						/// newey-west standard error
		2sls						/// two-stage least squares; the default when instruments are specified
		gmm							/// general method of moments
		weakiv						/// weak instrument robust method
		var							/// vector autoregressive model
		///* Model *///
		ny(real 1) 					/// # of LHS variables; default is 1
		varlag(string)				/// number list of lags in the vector autoregression
		q(real 0) 					/// # of time-varying parameters; default is all
		slope						/// only the slope parameters are time-varying; default is not
		NOCONStant 					/// whether constant is included; default is yes
		NHORizon(string) 			/// number of horizons in the local projection; default is 0
		cum							/// whether the endogeneous variables are cumulated over horizons
		NWLag(real -1) 				/// # of Newey-West lags; default is T^(-1/3)
		Cmatrix(string) 			/// smooth matrices; default is 0:5:50
		CHOLesky					/// use cholesky decomposition; default is no
		ndraw(real 1000)			/// number of draws using weakiv; default is 1000
		fix							/// fix the random seed using weakiv; default is no
		///* Report *///
		GETBand 					/// whether the confidence band is calculated; default is no
		Level(cilevel) 				/// confidence level; default is cilevel
		NODISplay					/// do not display the information
		///* Plot *///
		plotcoef(string) 			/// the position list of parameters to be plotted; default is the first parameter
		plotvarirf(string) 			/// the position list of impulse response function in VAR model to be plotted; default is the first parameter
		PLOTNHORizon(string)		/// the number list of horizons to be plotted; default is the list specified by nhorizon; NOTE: (1) If specifying a number, the parameter path over time is plotted; (2) If specifying a number list, the parameter path over horizons is plotted
		PLOTConst					/// add a horizon line of the constant parameter estimate
		period(varname)				/// indicating the time points to be plotted in the impulse response function
		movavg(real 1)				/// moving average when plotting the weak iv result; default is 1
		noci						/// suppress the confidence band
		TItle(string)				/// figure title
		YTItile(string)				/// title of yaxis
		XTItile(string)				/// title of xaxis
		TVPLegend(string) 			/// legend name of the time-varying-parameter estimates
		CONSTLegend(string) 		/// legend name of the constant-parameter estimates
		BANDLegend(string)			/// legend name of the confidence band
		SHADELegend(string)			/// legend name of the background shade
		PERIODLegend(string)		/// legend name of each period
		nolegend					/// suppress the legend
		name(string)				/// figure name
	]
	
	loc estimator `ols'`newey'`2sls'`gmm'`weakiv'`var'
	if ("`estimator'" == "") {
		if ("`y1'" == "") loc estimator ols
		else loc estimator 2sls
	}
	else if (!inlist("`estimator'","ols","newey","2sls","gmm","weakiv","var")) {
		di as err "Unknown estimator type."
		exit
	}

	* Preliminary
	cap tsset
	if _rc {
		di as err "time variable not set, use -tsset timevar [, options]"
		exit 101
	}
    loc timevar  "`r(timevar)'"
	marksample touse
	markout `touse' `y2z1' `y1' `z2'
	qui gsort -`touse' `timevar'
	preserve
	qui keep if `touse'
	cap tsset `timevar'
	qui describe
	loc T = r(N)
	if ("`noconstant'" == "") loc cons = 1
	else loc cons = 0
	if ("`getband'" == "") loc getband 0
	else loc getband 1
	if ("`cholesky'" == "") loc chol 0
	else loc chol 1
	if ("`nhorizon'" == "") loc nhorizon = 0
	tempname c0
	mata: c0 =  5 * (0::10)'
	mata: st_matrix("`c0'", c0)
	if ("`cmatrix'" == "") mata: c = c0
	else mata: c = st_matrix("`cmatrix'")	
	
	loc minh = `T'
	loc maxh = 0
	foreach hh of numlist `nhorizon' {
		loc Nh = `Nh' + 1
		loc hlist `hlist' `hh'
		loc minh = min(`minh',`hh')
		loc maxh = max(`maxh',`hh')
	}
	if ("`estimator'" == "var") {
		loc nhorizon = 0
		loc Nh = 1
		loc maxhvar = `maxh'
		loc maxh = 0
		loc minh = 0
		if ("`varlag'" == "") loc varlag = 1
		loc maxl = 0
		foreach ll of numlist `varlag' {
			loc Nl = `Nl' + 1
			loc llist `llist' `ll'
			loc maxl = max(`maxl',`ll')
			if (`Nl' == 1) loc laglist `ll'
			else loc laglist "`laglist' \ `ll'"
		}
	}
	if ("`fix'" != "") loc fix = 1
	else loc fix = 0
	
	* Parse varlist
	foreach v in `y2z1' {
		loc p = `p' + 1
		if (`p' <= `ny')	 loc y2 `y2' `v'
		else if (`p' > `ny') loc z1 `z1' `v'
	}
	
	loc n1 = wordcount("`y1'")
	loc n2 = wordcount("`y2'")
	loc k1 = wordcount("`z1'")
	loc k2 = wordcount("`z2'")
	if ("`estimator'" == "var") {
		loc n1 = 0
		loc n2 = wordcount("`y2z1'")
		loc k1 = `Nl' * `n2'
		loc k2 = 0
	}
	if ("`noconstant'" == "") loc k1 = `k1' + 1
	loc n = `n1' + `n2' // # of LHS variables
	loc k = `k1' + `k2' // # of RHS variables (w cons)
	loc nq = `n' * `k'
	loc na = `n' * (`n' - 1) / 2
	loc nl = `n'
	loc nqbar = `n1' * `k' + `n2' * (`n1' + `k1')
	loc nqcovar = `n' * (`n' + 1) / 2

	if (!inlist("`estimator'","ols","newey","var") & (`k2' == 0) & (`n1' == 0)) {
		di as err "No instrument available."
		exit
	}
	if (`k2' < `n1') {
		di as err "# of external instruments is less than endogeneous variables."
		exit
	}
	if (`q' == 0) {
		if ("`slope'" != "") {
			if ((`k2' == 0) & (`n1' == 0)) loc q = `nq'
			else loc q = `nqbar'
		}
		else loc q = `nqbar' + `nqcovar'
	}

	* Transmit data
	if (inlist("`estimator'","ols","newey")) { // OLS
		mata: y = st_data(.,"`y1' `y2'") // LHS
		mata: x = st_data(.,"`z1' `z2'") // RHS
		if ("`noconstant'" == "") mata: x = x, J(`T',1,1)
	}
	else if ("`estimator'" == "var") { // VAR
		mata: y = st_data(.,"`y2z1'")
		loc Nl = 0
		mata: x = J(`T'-`maxl',0,0)
		foreach ll of numlist `varlag' {
			mata: x = x, y[`maxl'-`ll'+1..`T'-`ll',.]
		}
		if ("`noconstant'" == "") mata: x = x, J(`T'-`maxl',1,1)
		mata: y = y[`maxl'+1..`T',.]
		loc T = `T' - `maxl'
	}
	else { // IV
		mata: y1 = st_data(.,"`y1'")
		mata: y2 = st_data(.,"`y2'")
		mata: z2 = st_data(.,"`z2'")
		if ("`noconstant'" == "") {
			if (`k1' > 1) mata: z1 = st_data(.,"`z1'"), J(`T',1,1)
			else mata: z1 = J(`T',1,1)
		}
		else {
			if (`k1' > 1) mata: z1 = st_data(.,,"`z1'")
			else mata: z1 = J(`T',1,0)
		}
	}
	di as text "Running the Time-Varying-Parameter Estimation..."
	if ((rowsof(`cmatrix') > 1) & (`getband' == 1)) di as text "The procedure might be slow when obtaining confidence band with vector ci."

	* Estimation
	loc Tall = `T'-`minh'
	mata: beta_const_all = J((`maxh'+1)*`q',1,0)
	mata: beta_all = J((`maxh'+1)*`q',`Tall',0)
	mata: beta_ub_all = J((`maxh'+1)*`q',`Tall',0)
	mata: beta_lb_all = J((`maxh'+1)*`q',`Tall',0)
	mata: Omega_all = J((`maxh'+1)*`q',`q'*`Tall',0)
	mata: weight_all = J(`maxh'+1,cols(c),0)
	mata: qLL_all = J(`maxh'+1,1,0)
	mata: residual_all = J((`maxh'+1)*`n',`Tall',0)
	
	foreach hh of numlist `nhorizon' {
		loc Th = `T'-`hh'
		if (`nwlag' == -1) {
			if (inlist("`estimator'","ols","var")) loc nlag = 0
			else loc nlag = floor(`Th'^(1/3))
		}
		else loc nlag = `nwlag'
		if (inlist("`estimator'","ols","newey")) { // OLS
			if ("`cum'" == "") mata: yy = y[`hh'+1..`T',.]
			else mata: yy = cum(y,`hh')
			mata: xx = x[1..`Th',.]
			mata: result = MPpath(yy,xx,`nlag',c,`getband',`chol',`q',`level')
		}
		else if ("`estimator'" == "var") { // VAR
			mata: result = MPpath(y,x,`nlag',c,`getband',`chol',`q',`level')
		}
		else { // IV
			mata: zz1 = z1[1..`Th',.]
			mata: zz2 = z2[1..`Th',.]
			if ("`cum'" == "") {
				mata: yy1 = y1[`hh'+1..`T',.]
				mata: yy2 = y2[`hh'+1..`T',.]
			}
			else {
				mata: yy1 = cum(y1,`hh')
				mata: yy2 = cum(y2,`hh')
			}
			if ("`estimator'" != "weakiv") { // strong IV
				mata: result = MPIVpath(yy1,yy2,zz1,zz2,`nlag',c,`getband',`chol',`q',`level',"`estimator'")
			}
			else if ("`estimator'" == "weakiv") { // weak IV
				loc qq = `nq' + `nqcovar'
				mata: result_TVPIV = MPpath((yy1,yy2),(zz2,zz1),`nlag',c,`getband',`chol',`qq',`level')
				mata: result = MPweakIVpath(yy1,yy2,zz1,zz2,result_TVPIV,`q',`ndraw',`level',`fix',`getband')
			}
		}
		if ("`estimator'" != "weakiv") {
			mata: beta_const_all[`hh'*`q'+1..(`hh'+1)*`q'] = result.beta_const
			mata: Omega_all[`hh'*`q'+1..(`hh'+1)*`q',1..`q'*`Th'] = result.Omega
		}
		mata: beta_all[`hh'*`q'+1..(`hh'+1)*`q',1..`Th'] = result.beta
		mata: beta_lb_all[`hh'*`q'+1..(`hh'+1)*`q',1..`Th'] = result.beta_lb
		mata: beta_ub_all[`hh'*`q'+1..(`hh'+1)*`q',1..`Th'] = result.beta_ub
		mata: residual_all[`hh'*`n'+1..(`hh'+1)*`n',1..`Th'] = result.residual
		mata: weight_all[`hh'+1,.] = result.weight
		mata: qLL_all[`hh'+1] = result.qLL
	}

	* extract the non-zero
	loc T = `Tall'
	mata: beta_const = J(0,1,0)
	mata: beta = J(0,`T',0)
	mata: beta_ub = J(0,`T',0)
	mata: beta_lb = J(0,`T',0)
	mata: Omega = J(0,`q'*`T',0)
	mata: weight = J(0,cols(c),0)
	mata: qLL = J(0,1,0)
	mata: residual = J(0,`T',0)
	foreach hh of numlist `nhorizon' {
		mata: beta_const = beta_const \ beta_const_all[`hh'*`q'+1..(`hh'+1)*`q',.]
		mata: Omega = Omega \ Omega_all[`hh'*`q'+1..(`hh'+1)*`q',.]
		mata: beta = beta \ beta_all[`hh'*`q'+1..(`hh'+1)*`q',.] 
		mata: beta_lb = beta_lb \ beta_lb_all[`hh'*`q'+1..(`hh'+1)*`q',.]
		mata: beta_ub = beta_ub \ beta_ub_all[`hh'*`q'+1..(`hh'+1)*`q',.]
		mata: residual = residual \ residual_all[`hh'*`n'+1..(`hh'+1)*`n',.]
		mata: weight = weight \ weight_all[`hh'+1,.]
		mata: qLL = qLL \ qLL_all[`hh'+1,.]
	}
	if ("`estimator'" != "weakiv") {
		mata: st_matrix("beta_const", beta_const)
		mata: st_matrix("Omega", Omega)
	}
	mata: st_matrix("beta", beta)
	mata: st_matrix("beta_lb", beta_lb)
	mata: st_matrix("beta_ub", beta_ub)
	mata: st_matrix("residual", residual)
	mata: st_matrix("weight", weight)
	mata: st_matrix("qLL", qLL)

	* Impulse response function VAR
	if (("`hlist'" != "0") & ("`estimator'" == "var")) { // VAR
		mata: sortmat = sortvar((`laglist'), `n',`cons')
		mata: beta_adj = sortmat * beta
		mata: Omega_adj = sortmat * Omega * (I(`T') # sortmat')
		mata: beta_const_adj = sortmat * beta_const		
		mata: result_VAR = MPVARpath(beta_adj, Omega_adj,`n',`cons',`maxhvar',`ndraw',`level',`fix',`chol',`getband')
		mata: st_matrix("varirf", result_VAR.irf)
		mata: st_matrix("varirf_lb", result_VAR.irf_lb)
		mata: st_matrix("varirf_ub", result_VAR.irf_ub)
		mata: result_VARconst = varirf(beta_const_adj,`n',`cons',`maxhvar',`chol')
		mata: st_matrix("varirf_const", result_VARconst)
	}
	
	* matname
	// beta name
	loc slopepara
	if ("`noconstant'" == "") loc consname _cons
	if (inlist("`estimator'","ols","newey")) {
		foreach y in `y2' { // vec(B')
			foreach x in `z1' `consname' {
				loc slopepara `slopepara' `y':`x'
			}
		}
	}
	else if ("`estimator'" == "var") { 
		foreach y in `y2z1' { // vec([B1(t),...,Bp(t),C(t)]')
			foreach ll in `llist' {
				foreach x in `y2z1' {
					if (`ll' == 1) loc slopepara `slopepara' `y':L.`x'
					else loc slopepara `slopepara' `y':L`ll'.`x'
				}
			}
			if ("`noconstant'" == "") loc slopepara `slopepara' `y':_cons
		}
	}
	else if (inlist("`estimator'","2sls","gmm","weakiv")) {
		foreach y in `y1' { // vec(α')
			foreach x in `z2' `z1' `consname' {
				loc slopepara `slopepara' `y':`x'
			}
		}
		foreach y in `y2' { // vec(M')
			foreach x in `y1' {
				loc slopepara `slopepara' `y':`x'
			}
		}
		foreach y in `y2' { // vec(μ')
			foreach x in `z1' `consname' {
				loc slopepara `slopepara' `y':`x'
			}
		}
	}	
	
	loc covpara
	if (`chol' == 1) { // [a(t)',l(t)']'
		if (`n' > 1) {
			forvalues n1 = 2/`n' {
				loc ne = `n1' - 1
				forvalues n2 = 1/`ne' {
					loc covpara `covpara' a`n1'`n2'
				}
			}
		}
		forvalues n1 = 1/`n' {
			loc covpara `covpara' l`n1'
		}
	}
	else { // vech(Σ(t))
		forvalues n1 = 1/`n' {
			forvalues n2 = `n1'/`n' {
				loc covpara `covpara' v`n2'`n1'
			}
		}
	}

	loc paraname `slopepara' `covpara'
	loc rowname
	foreach hh of numlist `nhorizon' {
		foreach v in `paraname' {
			if (`hh' == 0) loc rowname `rowname' `v'
			else loc rowname `rowname' h`hh'.`v'
		}
	}

	mat rownames beta = `rowname'
	mat rownames beta_ub = `rowname'
	mat rownames beta_lb = `rowname'
	if ("`estimator'" != "weakiv") {
		mat rownames Omega = `rowname'
		mat rownames beta_const = `rowname'
	}

	// irf name
	loc irfpara
	loc rowname
	if (("`hlist'" != "0") & ("`estimator'" == "var")) {
		foreach y in `y2z1' { 
			foreach x in `y2z1' {
				loc irfpara `irfpara' `y':`x'
			}
		}
		foreach hh of numlist `hlist' {
			foreach v in `irfpara' {
				if (`hh' == 0) loc rowname `rowname' `v'
				else loc rowname `rowname' h`hh'.`v'
			}
		}
		mat rownames varirf = `rowname'
		mat rownames varirf_lb = `rowname'
		mat rownames varirf_ub = `rowname'
		mat rownames varirf_const = `rowname'
	}

	* ereturn list
	return clear
	restore
	ereturn post, esample(`touse') buildfvinfo
	ereturn scalar T = `T'
	ereturn scalar q = `q'
	ereturn local paraname = "`paraname'"
	ereturn local title = "Time-Varying-Parameter Estimation"
	ereturn local cmd = "tvpreg"
	ereturn local model = "`estimator'"
	ereturn local horizon = "`hlist'"
	if ("`cum'" != "") ereturn local cum = "yes"
	else ereturn local cum = "no"
	if ("`noconstant'" == "") ereturn local constant = "yes"
	else ereturn local constant = "no"
	if (`chol' == 1) ereturn local cholesky = "yes"
	else ereturn local cholesky = "no"
	if (`getband' == 1) ereturn local band = "yes"
	else ereturn local band = "no"
	ereturn scalar level = `level'
	ereturn local depvar = "`y2'"
	if (inlist("`estimator'" , "ols","newey")) ereturn local indepvar = "`z1'"
	else if ("`estimator'" == "var") {
		ereturn local depvar = "`y2z1'"
		ereturn local varlag = "`llist'"
		ereturn local maxvarlag = "`maxl'"
		if ("`hlist'" != "0") {
			ereturn matrix varirf = varirf
			ereturn matrix varirf_lb = varirf_lb
			ereturn matrix varirf_ub = varirf_ub
			ereturn matrix varirf_const = varirf_const
			ereturn local irfname = "`irfpara'"
		}
	}
	else {
		ereturn local instd = "`y1'" // instrumented variables
		ereturn local insts = "`z1' `z2'" // instruments
		ereturn local inexog = "`z1'" // included instruments
		ereturn local exexog = "`z2'" // excluded instruments
	}
	ereturn local cmdline = "`cmdline'"
	if ("`cmatrix'" == "") {
		ereturn matrix qLL = qLL
		ereturn matrix c = `c0'
	}
	else {
		ereturn matrix c = `cmatrix'
		mat define `cmatrix' = e(c)
	}
	ereturn matrix weight = weight
	if ("`estimator'" != "weakiv") {
		ereturn matrix beta_const = beta_const
		if (`getband' == 1) ereturn matrix Omega = Omega
	}
	ereturn matrix beta = beta
	ereturn matrix beta_lb = beta_lb
	ereturn matrix beta_ub = beta_ub
	ereturn matrix residual = residual

	* display information
	Replay, `nodisplay'
	
	* figures
	if (("`plotcoef'" != "") | ("`plotvarirf'" != "")) {
		di as text ""
		if ("`ci'" != "") loc noci noci
		if ("`legend'" != "") loc nolegend nolegend
		foreach opt in plotcoef plotvarirf plotnhorizon period movavg title ytitle xtitle tvplegend constlegend bandlegend shadelegend periodlegend name {
			if ("``opt''" != "") loc `opt' `opt'(``opt'')
		}
		tvpplot, `plotcoef' `plotvarirf' `plotnhorizon' `plotconst' `period' `movavg' `noci' `title' `name' `ytitle' `xtitle' `tvplegend' `constlegend' `bandlegend' `shadelegend' `periodlegend' `nolegend'
	}
end

program define Replay
	version 17.0
	
	syntax [if] [in] [, NODISplay]
	
	* Table	
	if ("`nodisplay'" == "") {
		if ("`e(constant)'" == "yes") loc consname " _cons"
		if (inlist("`e(model)'","ols","newey")) {
			loc n = wordcount("`e(depvar)'")
			loc k = wordcount("`e(indepvar)'")
			if ("`e(constant)'" == "yes") loc k = `k' + 1
			if ("`e(horizon)'" == "0") {
				di as text "The model is:"
				di as text ""
				di as text "    y(t) = B(t) × x(t) + e(t)"
				di as text ""
				di as text " with dependent variable   y(t) (`n'×1): `e(depvar)',"
				di as text "      independent variable x(t) (`k'×1): `e(indepvar)'`consname',"
				loc Bname "vec(B(t)')'"
			}
			else if ("`e(cum)'" == "no") {
				di as text "The model is:"
				di as text ""
				di as text "    y(t+h) = B(h,t+h) × x(t) + e(t+h)"
				di as text ""
				di as text " with horizon (h) includes `e(horizon)',"
				di as text "      dependent variable   y(t) (`n'×1): `e(depvar)',"
				di as text "      independent variable x(t) (`k'×1): `e(indepvar)'`consname',"
				loc Bname "vec(B(h,t+h)')'"
			}
			else {
				di as text "The model is:"
				di as text ""
				di as text "    cumy(t+h) = B(h,t+h) × x(t) + e(t+h)"
				di as text ""
				di as text " with horizon (h) includes `e(horizon)',"
				di as text "      dependent variable   y(t) (`n'×1): `e(depvar)', cumy(t+h) = y(t)+...+y(t+h),"
				di as text "      independent variable x(t) (`k'×1): `e(indepvar)'`consname',"
				loc Bname "vec(B(h,t+h)')'"
			}
			loc vname e
		}
		else if ("`e(model)'" == "var") {
			loc n = wordcount("`e(depvar)'")
			if ("`e(constant)'" == "yes") {
				di as text "The model is:"
				di as text ""
				di as text "       y(t) = [B(1,t),...,B(p,t),c(t)] × [y(t-1)',...,y(t-p)',1]' + e(t)"
				di as text "  Bt(L)y(t) = c(t) + u(t) = c(t) + Θ(0,t)ε(t)"
				di as text ""
				di as text " with lags (p) includes `e(varlag)',"
				di as text "      dependent variable  y(t) (`n'×1): `e(depvar)',"
				di as text "      B(t) = [B(1,t),...,B(p,t),c(t)],"
			}
			else {
				di as text "The model is:"
				di as text ""
				di as text "       y(t) = [B(1,t),...,B(p,t)] × [y(t-1)',...,y(t-p)']' + e(t)"
				di as text "  Bt(L)y(t) = u(t) = Θ(0,t)ε(t)"
				di as text ""
				di as text " with lags (p) includes `e(varlag)'"
				di as text "      dependent variable  y(t) (`n'×1): `e(depvar)',"
				di as text "      B(t) = [B(1,t),...,B(p,t)],"
			}
			loc Bname "vec(B(t)')'"
			loc vname e
		}
		else {
			loc n2 = wordcount("`e(depvar)'")
			loc n1 = wordcount("`e(instd)'")
			loc k2 = wordcount("`e(exexog)'")
			loc k1 = wordcount("`e(inexog)'")
			loc n = `n1' + `n2'
			if ("`e(constant)'" == "yes") loc k1 = `k1' + 1
			if ("`e(horizon)'" == "0") {
				di as text "The structural model is:"
				di as text ""
				di as text "    y(t) = B(x,t) × x(t) + B(z1,t) × z(1,t) + ν(2,t)"
				di as text ""
				di as text " with dependent variable   y(t) (`n2'×1): `e(depvar)',"
				di as text "      endogeneous variable x(t) (`n1'×1): `e(instd)', and"
				di as text ""
				di as text "    x(t) = Π(2,t) × z(2,t) + Π(1,t) × z(1,t) + ν(1,t)"
				di as text ""
				di as text " with included instruments z(1,t) (`k1'×1): `e(inexog)'`consname',"
				di as text "      excluded instruments z(2,t) (`k2'×1): `e(exexog)'."
				di as text ""
				di as text "The multivariate system is:"
				di as text ""
				di as text "     _      _     _                           _     _        _     _        _"
				di as text "    |  x(t)  |   |            Π(t)             |   |  z(2,t)  |   |  ν(1,t)  |"
				di as text "    |        | = |                             | × |          | + |          |"
				di as text "    |_ y(t) _|   |_ B(x,t)×Π(t) + [0 B(z1,t)] _|   |_ z(1,t) _|   |  ν(2,t) _|"
				di as text ""
				di as text " with Π(t) = [Π(2,t),Π(1,t)], ν(t) = [ν(1,t)',ν(2,t)']',"
				loc Bname "vec(Π(t)')',vec(B(x,t)')',vec(B(z1,t)')'"
			}
			else if ("`e(cum)'" == "no") {
				di as text "The structural model is:"
				di as text ""
				di as text "    y(t+h) = B(x,h,t+h) × x(t+h) + B(z1,h,t+h) × z(1,t) + ν(2,t+h)"
				di as text ""
				di as text " with dependent variable   y(t) (`n2'×1): `e(depvar)',"
				di as text "      endogeneous variable x(t) (`n1'×1): `e(instd)', and"
				di as text ""
				di as text "    x(t+h) = Π(2,h,t+h) × z(2,t) + Π(1,h,t+h) × z(1,t) + ν(1,t+h)"
				di as text ""
				di as text " with included instruments z(1,t) (`k1'×1): `e(inexog)'`consname',"
				di as text "      excluded instruments z(2,t) (`k2'×1): `e(exexog)'."
				di as text ""
				di as text "The multivariate system is:"
				di as text ""
				di as text "     _        _     _                                       _     _        _     _          _"
				di as text "    |  x(t+h)  |   |                  Π(h,t+h)               |   |  z(2,t)  |   |  ν(1,t+h)  |"
				di as text "    |          | = |                                         | × |          | + |            |"
				di as text "    |_ y(t+h) _|   |_ B(x,h,t+h)×Π(h,t+h) + [0 B(z1,h,t+h)] _|   |_ z(1,t) _|   |  ν(2,t+h) _|"
				di as text ""
				di as text " with Π(h,t+h) = [Π(2,h,t+h),Π(1,h,t+h)], ν(t+h) = [ν(1,t+h)',ν(2,t+h)']',"
				loc Bname "vec(Π(h,t+h)')',vec(B(x,h,t+h)')',vec(B(z1,h,t+h)')'"
			}
			else {
				di as text "The structural model is:"
				di as text ""
				di as text "    cumy(t+h) = B(x,h,t+h) × cumx(t+h) + B(z1,h,t+h) × z(1,t) + ν(2,t+h)"
				di as text ""
				di as text " with dependent variable   y(t) (`n2'×1): `e(depvar)', cumy(t+h) = y(t)+...+y(t+h),"
				di as text "      endogeneous variable x(t) (`n1'×1): `e(instd)', cumx(t+h) = x(t)+...+x(t+h), and"
				di as text ""
				di as text "    cumx(t+h) = Π(2,h,t+h) × z(2,t) + Π(1,h,t+h) × z(1,t) + ν(1,t+h)"
				di as text ""
				di as text " with included instruments z(1,t) (`k1'×1): `e(inexog)'`consname',"
				di as text "      excluded instruments z(2,t) (`k2'×1): `e(exexog)'."
				di as text ""
				di as text "The multivariate system is:"
				di as text ""
				di as text "     _           _     _                                       _     _        _     _          _"
				di as text "    |  cumx(t+h)  |   |                  Π(h,t+h)               |   |  z(2,t)  |   |  ν(1,t+h)  |"
				di as text "    |             | = |                                         | × |          | + |            |"
				di as text "    |_ cumy(t+h) _|   |_ B(x,h,t+h)×Π(h,t+h) + [0 B(z1,h,t+h)] _|   |_ z(1,t) _|   |  ν(2,t+h) _|"
				di as text ""
				di as text " with Π(h,t+h) = [Π(2,h,t+h),Π(1,h,t+h)], ν(t+h) = [ν(1,t+h)',ν(2,t+h)']',"
				loc Bname "vec(Π(h,t+h)')',vec(B(x,h,t+h)')',vec(B(z1,h,t+h)')'"
			}
			loc vname ν
		}
		if ("`e(cholesky)'" == "yes") {
			if (("`e(horizon)'" == "0") | "`e(model)'" == "var") {
				if (`n' == 1) {
					di as text "      `vname'(t) ~ N(0,σ(`vname',t)^2)."
					di as text ""
					di as text "The parameter is [`Bname',lnσ(`vname',t)]',"
				}
				else if (`n' == 2) {
					di as text "      `vname'(t) ~ N(0,Σ(`vname',t)), and A(t) × Σ(`vname',t) × A(t)' = Σ(ε,t) × Σ(ε,t)',"
					di as text ""
					di as text "            _           _"
					di as text "           |   1      0  |"
					di as text "   A(t) =  |             | and Σ(ε,t) = diag[σ(1,t), σ(2,t)]."
					di as text "           |_ a(t)    1 _|"
					di as text ""
					di as text "The parameter is [`Bname',a(t),lnσ(1,t), lnσ(2,t)]',"
				}
				else if (`n' == 3) {
					di as text "      `vname'(t) ~ N(0,Σ(`vname',t)), and A(t) × Σ(`vname',t) × A(t)' = Σ(ε,t) × Σ(ε,t)',"
					di as text ""
					di as text "            _                          _"
					di as text "           |     1          0        0  |"
					di as text "   A(t) =  |  a(21,t)       1        0  |"
					di as text "           |_ a(31,t)    a(32,t)     1 _|"
					di as text ""
					di as text "and Σ(ε,t) = diag[σ(1,t), σ(2,t), σ(3,t)]."
					di as text ""
					di as text "The parameter is [`Bname',a(t)',lnσ(t)']',"
					di as text ""
					di as text " with a(t) = [a(21,t),a(31,t),a(32,t)]', and"
					di as text "      σ(t) = [σ(1,t), σ(2,t), σ(3,t)]'."
				}
				else if (`n' > 3) {
					di as text "      `vname'(t) ~ N(0,Σ(`vname',t)), and A(t) × Σ(`vname',t) × A(t)' = Σ(ε,t) × Σ(ε,t)',"
					di as text ""
					di as text "            _                                             _"
					di as text "           |     1          0        0        ...       0  |"
					di as text "           |  a(21,t)       1        0        ...       0  |"
					di as text "   A(t) =  |  a(31,t)    a(32,t)     1        ...       0  |, N = `n'"
					di as text "           |    ...        ...      ...       ...      ... |"
					di as text "           |_ a(N1,t)      ...      ...   a(N(N-1),t)   1 _|"
					di as text ""
					di as text "and Σ(ε,t) = diag[σ(1,t), ..., σ(N,t)]."
					di as text ""
					di as text "The parameter is [`Bname',a(t)',lnσ(t)']',"
					di as text ""
					di as text " with a(t) = [a(21,t),a(31,t),a(32,t),...,a(N(N-1),t)]', and"
					di as text "      σ(t) = [σ(1,t),...,σ(N,t)]'."
				}
			}
			else {
				if (`n' == 1) {
					di as text "      `vname'(t+h) ~ N(0,σ(`vname',t+h)^2)."
					di as text ""
					di as text "The parameter is [`Bname',lnσ(`vname',t+h)]',"
				}
				else if (`n' == 2) {
					di as text "      `vname'(t+h) ~ N(0,Σ(`vname',t+h)), and A(t+h) × Σ(`vname',t+h) × A(t+h)' = Σ(ε,t+h) × Σ(ε,t+h)',"
					di as text ""
					di as text "              _             _"
					di as text "             |    1       0  |"
					di as text "   A(t+h) =  |               | and Σ(ε,t+h) = diag[σ(1,t+h), σ(2,t+h)]."
					di as text "             |_ a(t+h)    1 _|"
					di as text ""
					di as text "The parameter is [`Bname',a(t+h),lnσ(1,t+h), lnσ(2,t+h)]',"
				}
				else if (`n' == 3) {
					di as text "      `vname'(t+h) ~ N(0,Σ(`vname',t+h)), and A(t+h) × Σ(`vname',t+h) × A(t+h)' = Σ(ε,t+h) × Σ(ε,t+h)',"
					di as text ""
					di as text "              _                              _"
					di as text "             |      1            0         0  |"
					di as text "   A(t+h) =  |  a(21,t+h)        1         0  |"
					di as text "             |_ a(31,t+h)    a(32,t+h)     1 _|"
					di as text ""
					di as text "and Σ(ε,t+h) = diag[σ(1,t+h), σ(2,t+h), σ(3,t+h)]."
					di as text ""
					di as text "The parameter is [`Bname',a(t+h)',lnσ(t+h)']',"
					di as text ""
					di as text " with a(t) = [a(21,t+h),a(31,t+h),a(32,t+h)]', and"
					di as text "      σ(t) = [σ(1,t+h), σ(2,t+h), σ(3,t+h)]'."
				}
				else if (`n' > 3) {
					di as text "      `vname'(t+h) ~ N(0,Σ(`vname',t+h)), and A(t+h) × Σ(`vname',t+h) × A(t+h)' = Σ(ε,t+h) × Σ(ε,t+h)',"
					di as text ""
					di as text "              _                                                   _"
					di as text "             |      1            0         0         ...        0  |"
					di as text "             |  a(21,t+h)        1         0         ...        0  |"
					di as text "   A(t+h) =  |  a(31,t+h)    a(32,t+h)     1         ...        0  |, N = `n'"
					di as text "             |     ...          ...       ...        ...       ... |"
					di as text "             |_ a(N1,t+h)       ...       ...   a(N(N-1),t+h)   1 _|"
					di as text ""
					di as text "and Σ(ε,t+h) = diag[σ(1,t+h), ..., σ(N,t+h)]."
					di as text ""
					di as text "The parameter is [`Bname',a(t+h)',lnσ(t+h)']',"
					di as text ""
					di as text " with a(t+h)   = [a(21,t+h),a(31,t+h),a(32,t+h),...,a(N(N-1),t+h)]', and"
					di as text "      σ(t+h)   = [σ(1,t+h),...,σ(N,t+h)]'."
				}
			}
		}
		else {
			if ("`e(horizon)'" == "0") {
				if (`n' == 1) {
					di as text "      `vname'(t) ~ N(0,σ(`vname',t)^2)."
					di as text ""
					di as text "The parameter is [`Bname',σ(`vname',t)^2]'."
				}
				else if (`n' > 1) {
					di as text "      `vname'(t) ~ N(0,Σ(`vname',t)), Σ(`vname',t) is a symmetric matrix."
					di as text ""
					di as text "The parameter is [`Bname',vech(Σ(`vname',t))']'."
				}
			}
			else {
				if (`n' == 1) {
					di as text "      `vname'(t+h) ~ N(0,σ(`vname',t+h)^2)."
					di as text ""
					di as text "The parameter is [`Bname',σ(`vname',t+h)^2]'."
				}
				else if (`n' > 1) {
					di as text "      `vname'(t+h) ~ N(0,Σ(`vname',t+h)), Σ(`vname',t+h) is a symmetric matrix."
					di as text ""
					di as text "The parameter is [`Bname',vech(Σ(`vname',t+h))']'."
				}
			}
		}
		di as text ""
		if (inlist("`e(model)'","ols","newey")) di as text "The constant parameter model is estimated by OLS."
		else if ("`e(model)'" == "var")         di as text "The constant parameter model is estimated by VAR."
		else if ("`e(model)'" == "2sls")        di as text "The constant parameter model is estimated by 2SLS."
		else if ("`e(model)'" == "gmm")         di as text "The constant parameter model is estimated by GMM."
		else if ("`e(model)'" == "weakiv")      di as text "The reduced-form constant parameter model is estimated by OLS."
	}
	
end

program define tvpplot
	version 17.0
	
	syntax [if] [in] [, plotcoef(string) plotvarirf(string) PLOTNHORizon(string) PLOTConst period(string) movavg(real 1) noci TItle(string) YTItile(string) XTItile(string) name(string) TVPLegend(string) CONSTLegend(string) BANDLegend(string) SHADELegend(string) PERIODLegend(string) nolegend]
	
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
		loc sp = `e(maxvarlag)'+1
		mat `tmat' = `tmat'[`sp'...,.]
		loc q = `n' * `n'
		mata: beta_all = st_matrix("e(varirf)")
		mata: beta_ub_all = st_matrix("e(varirf_ub)")
		mata: beta_lb_all = st_matrix("e(varirf_lb)")
		if ("`plotconst'" != "") mata: beta_const_all = st_matrix("e(varirf_const)")
	}
	else if ("`plotcoef'" != "") {
		mata: beta = st_matrix("e(beta)")
		mata: beta_ub = st_matrix("e(beta_ub)")
		mata: beta_lb = st_matrix("e(beta_lb)")
		if ("`plotconst'" != "") mata: beta_const = st_matrix("e(beta_const)")
		// recover the matrix
		if ("`e(model)'" == "var") {
			mata: beta_all = beta
			mata: beta_ub_all = beta_ub
			mata: beta_lb_all = beta_lb
			if ("`plotconst'" != "") mata: beta_const_all = beta_const
		}
		else {
			mata: beta_all = J((`maxh'+1)*`q',`T',0)
			mata: beta_ub_all = J((`maxh'+1)*`q',`T',0)
			mata: beta_lb_all = J((`maxh'+1)*`q',`T',0)
			if ("`plotconst'" != "") mata: beta_const_all = J((`maxh'+1)*`q',1,0)
			loc nh = 0
			foreach hh of numlist `e(horizon)' {
				mata: beta_all[`hh'*`q'+1..(`hh'+1)*`q',.] = beta[`nh'*`q'+1..(`nh'+1)*`q',.]
				mata: beta_lb_all[`hh'*`q'+1..(`hh'+1)*`q',.] = beta_ub[`nh'*`q'+1..(`nh'+1)*`q',.]
				mata: beta_ub_all[`hh'*`q'+1..(`hh'+1)*`q',.] = beta_lb[`nh'*`q'+1..(`nh'+1)*`q',.]
				if ("`plotconst'" != "") mata: beta_const_all[`hh'*`q'+1..(`hh'+1)*`q',.] = beta_const[`nh'*`q'+1..(`nh'+1)*`q',.]
				loc nh = `nh' + 1
			}
		}
	}

	* extract the horizons
	if (`Nh' == 1) { // Parameter path over time
		mata: beta = beta_all[`plotnhorizon'*`q'+1..(`plotnhorizon'+1)*`q',.]
		mata: beta_ub = beta_ub_all[`plotnhorizon'*`q'+1..(`plotnhorizon'+1)*`q',.]
		mata: beta_lb = beta_lb_all[`plotnhorizon'*`q'+1..(`plotnhorizon'+1)*`q',.]
		if ("`plotconst'" != "") mata: beta_const = beta_const_all[`plotnhorizon'*`q'+1..(`plotnhorizon'+1)*`q',.]
	}
	else { // Parameter path over horizons
		mata: IRF = J(`Nh'*`q',`T',0)
		if ("`plotconst'" != "") mata: IRF_const = J(`Nh'*`q',1,0)
		loc nh = 0
		foreach hh of numlist `plotnhorizon' {
			loc nh = `nh' + 1
			forvalues qq = 1/`q' {
				mata: IRF[(`qq'-1)*`Nh'+`nh',.] = beta_all[`hh'*`q'+`qq',.]
				if ("`plotconst'" != "") mata: IRF_const[(`qq'-1)*`Nh'+`nh',.] = beta_const_all[`hh'*`q'+`qq',.]
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
	
	* Figure
	loc tvpfigs
	loc nf
	foreach v in `plotcoef' `plotvarirf' {
		loc nf = `nf' + 1
		loc ff = 0
		if ("`plotcoef'" != "") {
			loc pos = 0
			foreach vv in `e(paraname)' {
				loc pos = `pos' + 1
				if ("`v'" == "`vv'") loc ff = `pos'
			}
		}
		else if ("`plotvarirf'" != "") {
			loc pos = 0
			foreach vv in `e(irfname)' {
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
				tempname lower_i upper_i beta_i beta_const_i
				if ("`e(maxvarlag)'" == "") loc maxvarlag = 0
				else loc maxvarlag = `e(maxvarlag)'
				mata: lower_i = (J(`maxvarlag',1,.) \ movmat*(beta_lb[`ff',1..`T'-`plotnhorizon'+`minh'])' \ J(`plotnhorizon',1,.))
				mata: upper_i = (J(`maxvarlag',1,.) \ movmat*(beta_ub[`ff',1..`T'-`plotnhorizon'+`minh'])' \ J(`plotnhorizon',1,.))
				mata: beta_i = (J(`maxvarlag',1,.) \ movmat*(beta[`ff',1..`T'-`plotnhorizon'+`minh'])' \ J(`plotnhorizon',1,.))
				getmata `beta_i'=beta_i `upper_i'=upper_i `lower_i'=lower_i
				if ("`plotconst'" != "") {
					mata: beta_const_i = (J(`maxvarlag',1,.) \ J(`T'-`plotnhorizon'+`minh',1,beta_const[`ff']) \ J(`plotnhorizon',1,.))
					getmata `beta_const_i'=beta_const_i
					loc plotconst || (line `beta_const_i' `timevar', lp(solid) lwidth(0.5) lc(black))
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
				if ("`ci'" != "") loc twcmd (line `beta_i' `timevar', lp(solid) lwidth(0.5) lc(blue)) `plotconst', `suboption' `legendcmd'
				else loc twcmd (line `beta_i' `timevar', lp(solid) lwidth(0.5) lc(blue)) || (line `lower_i' `timevar', lp(dash) lwidth(0.5) lc(blue)) || (line `upper_i' `timevar', lp(dash) lwidth(0.5) lc(blue)) `plotconst', `suboption' `legendcmd'
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
							loc grcommand `grcommand' (line matamatrix(IRF_`ss'), lp("`pattern'") lwidth(`width') lc(green)) ||
						}
						else loc grcommand `grcommand' (line matamatrix(IRF_`ss'), lp(solid) lwidth(`width') lc(green)) ||
					}
				}
				if ("`plotconst'" != "") {
					mata: IRF_c = (IRF_const[(`ff'-1)*`Nh'+1..`ff'*`Nh',1], (`hlist'))
					loc grcommand `grcommand' (scatter matamatrix(IRF_c), m(O) mc(black) msiz(0.5) connect(l) lp(solid) lwidth(0.5) lc(black)) ||
					loc S = `S' + 1
				}
				if (("`legend'" == "") & ("`plotconst'" != "")) {
					if (`"`periodlegend'"' != "") loc legendcmd legend(order(`legendcmd' `S' "`constlegend'"))
					else loc legendcmd legend(order(1 "`tvplegend'" `S' "`constlegend'"))
				}
				else loc legendcmd legend(off)
				gr tw `grcommand', `suboption' `legendcmd'
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

findfile "tvpreg.mata"
include "`r(fn)'"
exit
