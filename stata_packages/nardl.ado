*! version 0.6  17jul2012

program define nardl, eclass
version 11
syntax varlist(ts numeric) [if] [in], ///
   [COnstraints(string) p(integer 2) q(integer 2) Horizon(integer 40) ///
   DETerministic(varlist numeric) plot BRief RESiduals robust ///
   BOOTstrap(integer 0) LEvel(cilevel) bsrun(integer 0) savetempdata ]

local n : word count `varlist'
if `n' < 2 {
	di as err "you must provide at least 2 variables"
	exit
	}
qui cap tsset
local tvar = r(timevar)
if "`tvar'"=="." {
	di as err "you must first -tsset- your dataset"
	exit
	}
if (`p'<2 | `q'<2) {
	di as err "sorry, p and q must be at least 2 in this version"
	exit
	}


local cl = strlen("`constraints'")	

// define effective sample
marksample touse
markout `touse' `deterministic'


	
// generate dependent variable and regressors
	
local thisvariable: word 1 of `varlist' 
qui gen _y = `thisvariable'
qui gen _dy = D._y	
if "`savetempdata'" != "" qui gen _L1_y = L1._y

local rhs "L._y"
	
forvalues j=2/`n' {
	tempvar dx
	local thisvariable: word `j' of `varlist' 
	qui gen `dx' = D.`thisvariable'
	local i = `j' - 1
	qui gen _dx`i'p = max(0,`dx') if `dx' != .
	qui gen _dx`i'n = min(0,`dx') if `dx' != .
	qui gen _x`i'p = 0
	qui replace _x`i'p = L._x`i'p + _dx`i'p if L._x`i'p != .
	qui gen _x`i'n = 0
	qui replace _x`i'n = L._x`i'n + _dx`i'n if L._x`i'n != .
	* list `dx' _dx`i'p _dx`i'n _x`i'p _x`i'n
	qui drop `dx'
	local rhs  `"`rhs' L._x`i'p L._x`i'n "'
	if "`savetempdata'" != "" {	
		qui gen _L1_x`i'p = L1._x`i'p
		qui gen _L1_x`i'n = L1._x`i'n
		}
	}

	
	
	
local p1 = `p'-1
local q1 = `q'-1
forvalues j=1/`p1' {
	local rhs  `"`rhs' L`j'._dy "'
	if "`savetempdata'" != "" qui gen _L`j'_dy = L`j'._dy
	}
forvalues j=2/`n' {
	local i = `j' - 1
	forvalues l=0/`q1' {
		local rhs  `"`rhs' L`l'._dx`i'p "'
		if ("`savetempdata'" != "") qui gen _L`l'_dx`i'p = L`l'._dx`i'p
		}
	forvalues l=0/`q1' {
		local rhs  `"`rhs' L`l'._dx`i'n "'
		if ("`savetempdata'" != "") qui gen _L`l'_dx`i'n = L`l'._dx`i'n
		}
	}
	

	
// saving temporary data
if "`savetempdata'" != "" {
	preserve
	qui tsset 
	local timevar = r(timevar)
	gen esample = `touse'
	label variable esample "observation was used in the model" 
	move esample `timevar'
	drop `touse'
	qui keep esample _dy _L*  `deterministic' `timevar' 
	save _nardltempdata, replace
	restore
	}
	
	
	
// run regression
di ""
local quiet = ""
if "`brief'" != "" local quiet = "quietly"
if "`brief'" == "" di as text "Regression results (variables renamed):"
if `cl'==0 `quiet' regress _dy `rhs' `deterministic' if `touse', `robust'
if `cl'!=0 `quiet' cnsreg  _dy `rhs' `deterministic' if `touse', `robust' constraints("`constraints'")


// model diagnostics 
tempname diag_hetchi2 diag_hetp diag_resetf diag_resetp diag_wnchi2 diag_wnp diag_wnlags diag_jbchi2 diag_jbp 
tempvar tmpresid
quietly predict `tmpresid' if e(sample), residuals
cap quietly estat hettest
	scalar `diag_hetchi2'= r(chi2)
	scalar `diag_hetp'   = r(p)
cap quietly estat ovtest
	scalar `diag_resetf' = r(F)
	scalar `diag_resetp' = r(p)
quietly wntestq `tmpresid'
	scalar `diag_wnchi2' = r(stat)
	scalar `diag_wnp'    = r(p)
	scalar `diag_wnlags' = r(df)
quietly summarize `tmpresid', detail
	scalar `diag_jbchi2' = r(N)/6 * (r(skewness)^2 + ((r(kurtosis)-3)^2)/4) 
	scalar `diag_jbp'    = 1 - chi2(2,`diag_jbchi2')
	
*tempname diag_hetchi2 diag_hetp diag_resetf diag_resetp diag_wnchi2 diag_wnp diag_wnlags diag_jbchi2 diag_jbp

ereturn scalar diag_hetchi2    = `diag_hetchi2'	
ereturn scalar diag_hetp       = `diag_hetp'
ereturn scalar diag_resetf     = `diag_resetf'
ereturn scalar diag_resetp     = `diag_resetp'
ereturn scalar diag_wnchi2     = `diag_wnchi2'
ereturn scalar diag_wnp        = `diag_wnp'
ereturn scalar diag_wnlags     = `diag_wnlags'
ereturn scalar diag_jbchi2     = `diag_jbchi2'
ereturn scalar diag_jbp        = `diag_jbp'	

if "`residuals'" != "" | `bootstrap'>0 {
	cap drop nardlres
	gen nardlres = `tmpresid'
	label var nardlres "residuals from NARDL model"
	}



tempname b V pmat
matrix `b' = e(b)
matrix `V' = e(V)
matrix `pmat' = J(`n'-1,4,.)
local pmatrownames ""

di ""
di as text "Asymmetry statistics:"
di as text "{hline 13}{c TT}{hline 32}{c TT}{hline 31}" 
di as text "             {c |}            Long-run effect [+] {c |}            Long-run effect [-]"
di as text "  Exog. var. {c |}       coef.     F-stat     P>F {c |}       coef.     F-stat     P>F"
di as text "{hline 13}{c +}{hline 32}{c BT}{hline 31}"

forvalues j=2/`n' {
local i = `j' - 1
local thisvariable: word `j' of `varlist' 
di as text %12s abbrev(("`thisvariable'"),12) _c
di as text " {c |}" _c
local thisabb = abbrev(("`thisvariable'"),8)
local pmatrownames "`pmatrownames' `thisabb'"

local coef = -_b[L1._x`i'p]/_b[L1._y]
di as result " " %11.3f `coef' "  " _c
qui testnl -_b[L1._x`i'p]/_b[L1._y] = 0
local F = r(F)
local pval = r(p)
di as result %9.4g `F' "   " _c
di as result %4.3f `pval' _c
matrix `pmat'[`j'-1,1] = `pval'
di "  " _c

local coef = _b[L1._x`i'n]/_b[L1._y]
di as result " " %11.3f `coef' "  " _c
qui testnl _b[L1._x`i'n]/_b[L1._y] = 0
local F = r(F)
local pval = r(p)
di as result %9.4g `F' "   " _c
di as result %4.3f `pval'  
matrix `pmat'[`j'-1,2] = `pval'
} 


di as text "{hline 13}{c +}{hline 32}{c TT}{hline 31}"
di as text "             {c |}             Long-run asymmetry {c |}            Short-run asymmetry"
di as text "             {c |}                 F-stat     P>F {c |}                 F-stat     P>F"
di as text "{hline 13}{c +}{hline 32}{c BT}{hline 31}"

forvalues j=2/`n' {
local i = `j' - 1
local thisvariable: word `j' of `varlist' 
di as text %12s abbrev(("`thisvariable'"),12) _c
di as text " {c |}              " _c

qui testnl -_b[L1._x`i'p]/_b[L1._y] = -_b[L1._x`i'n]/_b[L1._y]
local F = r(F)
local pval = r(p)
di as result %9.4g `F' "   " _c
di as result %4.3f `pval' _c
matrix `pmat'[`j'-1,3] = `pval'
di "                " _c

local exp1 ""
local exp2 ""
forvalues l=0/`q1' {
	if `l' > 0 local exp1 `"`exp1' + "'
	if `l' > 0 local exp2 `"`exp2' + "'
	local exp1 `"`exp1' L`l'._dx`i'p "' 
	local exp2 `"`exp2' L`l'._dx`i'n "'
	}
qui test `exp1' = `exp2'
local F = r(F)
local pval = r(p)
di as result %9.4g `F' "   " _c
di as result %4.3f `pval' _c
matrix `pmat'[`j'-1,4] = `pval'
di "" 
} 
di as text "{hline 13}{c BT}{hline 64}"
di as text "Note: Long-run effect [-] refers to a permanent change in exog. var. by -1"

matrix colnames `pmat' = lrpos lrneg lrasym srasym
matrix rownames `pmat' = `pmatrownames' 


tempname mat1 se1 b1 t_bdm f_pss
matrix `mat1'  = `V'["L._y","L._y"]
scalar `se1'   = `mat1'[1,1] ^ 0.5
matrix `mat1'  = `b'[1,"L._y"]
scalar `b1'    = `mat1'[1,1]
scalar `t_bdm' = `b1' / `se1'  

qui testparm L1._y L1._x*
scalar `f_pss' = r(F)


di as text ""
di as text "  Cointegration test statistics:    t_BDM = " _c
di as result %12.4f `t_bdm'
di as text "                                    F_PSS = " _c
di as result %12.4f `f_pss'


ereturn scalar t_bdm = `t_bdm'
ereturn scalar f_pss = `f_pss'
ereturn matrix nardl_pmat   = `pmat' 

di as text ""
di as text "  Model diagnostics                                stat.    p-value"
di as text "  {hline 65}"
di as text "  Portmanteau test up to lag " _c
  di as text %3.0f `diag_wnlags' _c
  di as text " (chi2)        " _c
  di as result %9.4g `diag_wnchi2' "     " _c
  di as result %5.4f `diag_wnp'
di as text "  Breusch/Pagan heteroskedasticity test (chi2) " _c
  di as result %9.4g `diag_hetchi2' "     " _c
  di as result %5.4f `diag_hetp'
di as text "  Ramsey RESET test (F)                        " _c
  di as result %9.4g `diag_resetf' "     " _c
  di as result %5.4f `diag_resetp'    
di as text "  Jarque-Bera test on normality (chi2)         " _c
  di as result %9.4g `diag_jbchi2' "     " _c
  di as result %5.4f `diag_jbp'    




// calculate multipliers
nardl_m `b' `n' `p' `q' `horizon' `bsrun'
	


// bootstrap
if `bootstrap' > 0 nardl_bs "`varlist'" `touse' `n' `p' `q' `horizon' "`deterministic'" "`constraints'" `bootstrap' `level'
if `bsrun' == 0 cap drop _y _dy* _x* _dx*

if "`plot'" != "" {
	preserve
	clear
	tempname cdm asym asym_ql asym_qm asym_qu
	local bsplots ""
	local note ""
	local bslabels ""
	matrix `cdm'     = e(nardl_cdm)
	matrix `asym'    = e(nardl_asym)
	matrix `asym'    = `asym'[1...,2...]   // remove "horizon" column
	qui svmat `cdm' , names(col)
	qui svmat `asym', names(asym)
	label variable horizon "Time periods"
	
	
	if `bootstrap' > 0 {
		matrix `asym_ql' = e(nardl_asym_ql)
		matrix `asym_qm' = e(nardl_asym_qm)
		matrix `asym_qu' = e(nardl_asym_qu)
		matrix `asym_ql' = `asym_ql'[1...,2...] 
		matrix `asym_qm' = `asym_qm'[1...,2...]
		matrix `asym_qu' = `asym_qu'[1...,2...]
		qui svmat `asym_ql', names(asym_ql)
		qui svmat `asym_qm', names(asym_qm)
		qui svmat `asym_qu', names(asym_qu) 
		local note `"Note: `level'% bootstrap CI is based on `bootstrap' replications"' 
		}

	
	local depvar : word 1 of `varlist'
	local depvar = strupper("`depvar'")
	local n1 = `n'-1
	forvalues j=1/`n1' {
		label var x`j'p "positive change"
		label var x`j'n "negative change"
		label var asym`j' "asymmetry"
		local i = `j' + 1
		local thisvariable: word `i' of `varlist' 
		local thisvariable = strupper("`thisvariable'")
		local bsbars ""
		local bsplots ""
		local ordering "1 2 3"
		local extralabel ""
		if `bootstrap'>0 {
			local bsbars "||"
			local bsplots `" twoway rarea asym_ql`j' asym_qu`j' horizon, col("210 220 235") "'
			local ordering "2 3 4 1"
			local extralabel `"label(1 "CI for asymmetry")"'
			}

		
		qui `bsplots' `bsbars' scatter x`j'p  horizon, c(l) ms(i) lpattern(dash) lc("0 160 60") `bsbars' ///
		||  scatter x`j'n  horizon, c(l) ms(i) lpattern(longdash) lc("160 0 60") || ///
		||  scatter asym`j' horizon, c(l) ms(i) lpattern(solid) lc("0 0 160") ||  ///
		, title("Cumulative effect of `thisvariable' on `depvar'") note(`"`note'"') xlabel(,grid) ylabel(,grid) /// 
		legend(region(lwidth(none)) cols(2) order("`ordering'") `extralabel') scheme(s1mono) nodraw saving("_nardlplot`j'.gph", replace)
		local plotlist `"`plotlist' _nardlplot`j'.gph"'
		}
	graph combine `plotlist', scheme(s1mono) scale(0.8)
	restore
	}



end


*******************************************************************************

program nardl_m, eclass

	version 11
	args b n p q h bsrun
	local n1 = `n'-1
	local p1 = `p'-1
	local q1 = `q'-1
	tempname tmp phi deltap deltan qamma pip pin phi thetap thetan lambdap lambdan phix mp mn hindex cdynmult asym
	

	// re-arrange coefficients
	matrix `tmp' = `b'["y1","L._y"]
	local rho = `tmp'[1,1]
	
	matrix `deltap' = J(`n'-1,1,.)
	matrix `deltan' = J(`n'-1,1,.)
	matrix `qamma'  = J(1,`p1',.)
	matrix `pip'    = J(`n'-1,`q1'+1,.)
	matrix `pin'    = J(`n'-1,`q1'+1,.)
	matrix `phi'    = J(1,`p1'+1,.)
	matrix `thetap' = J(`n'-1,`q'+1,.)
	matrix `thetan' = J(`n'-1,`q'+1,.)
	matrix `lambdap'= J(`n'-1,`h'+1,.)
	matrix `lambdan'= J(`n'-1,`h'+1,.)
	matrix `mp'     = J(`n'-1,`h'+1,.)
	matrix `mn'     = J(`n'-1,`h'+1,.)	
	matrix `asym'   = J(`n'-1,`h'+1,.)
	matrix `phix'   = J(1,`h',0)


	
	forvalues j=1/`n1' {
		matrix `deltap'[`j',1] = `b'["y1","L1._x`j'p"]
		matrix `deltan'[`j',1] = `b'["y1","L1._x`j'n"]
		matrix `pip'[`j',1]    = `b'["y1","_dx`j'p"]
		matrix `pin'[`j',1]    = `b'["y1","_dx`j'n"]
		forvalues l=1/`q1' {
			matrix `pip'[`j',`l'+1] = `b'["y1","L`l'._dx`j'p"]
			matrix `pin'[`j',`l'+1] = `b'["y1","L`l'._dx`j'n"]
			}	
	}
	
	forvalues l=1/`p1' {
		matrix `qamma'[1,`l'] = `b'["y1","L`l'._dy"]
		}
	
	
	
	// calculate phi
	if `p' > 1 matrix `phi'[1,1] = `rho' + 1 + `qamma'[1,1]
	if `p' > 2 {
			forvalues j=2/`p1' {
				matrix `phi'[1,`j'] = `qamma'[1,`j'] - `qamma'[1,`j'-1]
				}
		}
	matrix `phi'[1,`p'] = - `qamma'[1,`p'-1]
	matrix `phix'[1,1] = `phi'  // this copies phi into phix (not just the 1,1 element) and leaves the zeros on the right
	

	
	// calculate theta
	forvalues j=1/`n1' {
		matrix `thetap'[`j',1] = `pip'[`j',1]
		matrix `thetan'[`j',1] = `pin'[`j',1]
		matrix `thetap'[`j',2] = `deltap'[`j',1] - `pip'[`j',1] + `pip'[`j',2]
		matrix `thetan'[`j',2] = `deltan'[`j',1] - `pin'[`j',1] + `pin'[`j',2]
		forvalues i=2/`q1' {
			matrix `thetap'[`j',`i'+1] = `pip'[`j',`i'+1] - `pip'[`j',`i']
			matrix `thetan'[`j',`i'+1] = `pin'[`j',`i'+1] - `pin'[`j',`i']
			}
		matrix `thetap'[`j',`q'+1] = - `pip'[`j',`q1'+1]  
		matrix `thetan'[`j',`q'+1] = - `pin'[`j',`q1'+1]
		}


	
	// calculate multpliers
	forvalues j=1/`n1' {
		matrix `lambdap'[`j',1] = `thetap'[`j',1]
		matrix `lambdan'[`j',1] = `thetan'[`j',1]
		matrix `mp'[`j',1]      = `lambdap'[`j',1]
		matrix `mn'[`j',1]      = `lambdan'[`j',1]
		matrix `asym'[`j',1]    = `mp'[`j',1] - `mn'[`j',1]  
		
		forvalues i=1/`h' {
			matrix `tmp' = J(2,1,0)
			if `i' <= `q' matrix `tmp'[1,1] = `thetap'[`j',`i'+1]
			if `i' <= `q' matrix `tmp'[2,1] = `thetan'[`j',`i'+1]
			forvalues k = 1/`i' {
				matrix `tmp'[1,1] = `tmp'[1,1] + `phix'[1,`k'] * `lambdap'[`j',1+`i'-`k']
				matrix `tmp'[2,1] = `tmp'[2,1] + `phix'[1,`k'] * `lambdan'[`j',1+`i'-`k']
				}			
			matrix `lambdap'[`j',`i'+1] = `tmp'[1,1]
			matrix `lambdan'[`j',`i'+1] = `tmp'[2,1]
			matrix `mp'[`j',`i'+1]      = `mp'[`j',`i'] + `lambdap'[`j',`i'+1]
			matrix `mn'[`j',`i'+1]      = `mn'[`j',`i'] + `lambdan'[`j',`i'+1]
			matrix `asym'[`j',`i'+1]    = `mp'[`j',`i'+1] - `mn'[`j',`i'+1]
			}
		}
		
		
	// re-arrange result
	
	matrix `hindex' = J(1,`h'+1,0)
	
	forvalues j=1/`h' {
		matrix `hindex'[1,`j'+1] = `hindex'[1,`j'] +1
		}
	matrix rownames `hindex' = horizon

	
	
	local namesp ""
	local namesn ""
	local namesa ""
	forvalues j=1/`n1' {
		local namesp `"`namesp' x`j'p"'
		local namesn `"`namesn' x`j'n"'
		local namesa `"`namesa' x`j'"'
		}
		
	matrix rownames `mp'   = `namesp'
	matrix rownames `mn'   = `namesn'
	matrix rownames `asym' = `namesa'
	
	matrix `cdynmult' = (`hindex' \ `mp' \ -`mn' )'
	matrix `asym'     = (`hindex' \ `asym')'

	

	ereturn matrix nardl_cdm    = `cdynmult'
	ereturn matrix nardl_asym   = `asym'
	ereturn matrix nardl_phi    = `phi'
	ereturn matrix nardl_thetap = `thetap'
	ereturn matrix nardl_thetan = `thetan'
	
	
end




*******************************************************************************

program nardl_bs, eclass
args varlist touse n p q h deterministic constraints replications level

tempname lfnr b0 btemp phi thetap thetan res newy bsdv shuffle asym_bs rmat hmat qlower qmedian qupper  
tempfile nardlbs
qui gen `lfnr' = _n
qui sum `lfnr' if nardlres != .
local t1    = r(min)
local tmax  = r(max)
local n1 = `n'-1
local OBS = _N
local h1 = `h'+1
local y: word 1 of `varlist'
mkmat nardlres if nardlres != ., matrix(`res') 
local nres = rowsof(`res')
local ndet : word count `deterministic'
matrix `b0'     = e(b) 
matrix `phi'    = e(nardl_phi)
matrix `thetap' = e(nardl_thetap)
matrix `thetan' = e(nardl_thetan)
matrix `hmat'   = J(`h1',1,0)



forvalues i=2/`h1' {
	matrix `hmat'[`i',1] = `hmat'[`i'-1,1] + 1
	}
	
matrix `qlower' = (`hmat', J(`h1',`n1',.))

local header  "horizon"
forvalues i=1/`n1' {
	local header `"`header' x`i'"'
	}
matrix colnames `qlower' = `header'
matrix `qmedian' = `qlower'
matrix `qupper'  = `qlower'

local xlist ""
forvalues i=2/`n' {
	local thisx : word `i' of `varlist'
	local xlist `"`xlist' `thisx'"'
	}

di in green "Bootstrapping (one dot per 10 replications): " _c
forvalues r=1/`replications' {
	mkmat `y', matrix(`bsdv')
	forvalues t=`t1'/`tmax' {   // generate resample observations after "pre-sample" period; levels notation
		
		matrix `newy' = J(1,1,0)

		forvalues i=1/`p' {     // take care of lags of y
			matrix `newy' = `newy' + `phi'[1,`i'] * `bsdv'[`t'-`i',1]
			}
			
		forvalues i=0/`q' {     // take care of lags of x
			forvalues j=1/`n1' {
				matrix `newy' = `newy' + `thetap'[`j',`i'+1] * _x`j'p[`t'-`i']
				matrix `newy' = `newy' + `thetan'[`j',`i'+1] * _x`j'n[`t'-`i']
				}
			}
		
		matrix `newy' = `newy' + `b0'["y1","_cons"]  // add the constant
		
		if `ndet'>0 {    // add deterministic terms
			forvalues i=1/`ndet' {
				local thisvar: word `i' of `deterministic'
				matrix `newy' = `newy' + `b0'["y1","`thisvar'"] * `thisvar'[`t']
				}
			}
		matrix `newy' = `newy' + `res'[ceil(runiform() * `nres'),1]  // pick one value from the list of residuals
		matrix `bsdv'[`t',1] = `newy'[1,1] 
		}

	svmat `bsdv', names(_bsdv)
	***** qui replace _bsdv1 = . if nardlres==.   // should "pre-sample" values be deleted?
	drop _y _dy* _x* _dx*

	qui nardl _bsdv1 `xlist' if `touse', p(`p') q(`q') horizon(`h') constraints(`constraints') deterministic(`deterministic') bsrun(1)
	drop _bsdv1
	matrix `asym_bs' = e(nardl_asym)
	matrix `rmat' = J(rowsof(`asym_bs'),1,`r')
	matrix colnames `rmat' = repl
	matrix `asym_bs' = (`rmat' , `asym_bs')
	preserve
	clear
	qui svmat `asym_bs', names(col)
	if `r'>	1 append using `nardlbs'
	qui save `nardlbs', replace
	restore
	if mod(`r',10)==0 di as result "." _c
}
di ""



// run again with original data so that results matrices are correct
cap drop _y _dy* _x* _dx*
qui nardl `varlist' if `touse', p(`p') q(`q') horizon(`h') `robust' constraints(`constraints') deterministic(`deterministic') bsrun(0)


preserve

forvalues jh=0/`h' { 
	use `nardlbs', clear
	qui keep if horizon == `jh'
	forvalues jx=1/`n1' {
		sort x`jx'
		forvalues i=1/3 {
			if `i' == 1 local z = 0.5 * (1 - `level'/100)
			if `i' == 2 local z = 0.5
			if `i' == 3 local z = 1 - 0.5 * (1 - `level'/100)
			
			local qindex1 = ceil(`replications'*`z')
			if ceil(`replications'*`z') - (`replications'*`z') != 0 local qindex2 = ceil(`replications'*`z')
			else local qindex2 = `replications'*`z'+1
			local v = (x`jx'[`qindex1'] + x`jx'[`qindex2']) / 2
			
			if `i' == 1 matrix  `qlower'[`jh'+1,`jx'+1] = `v'
			if `i' == 2 matrix `qmedian'[`jh'+1,`jx'+1] = `v'
			if `i' == 3 matrix  `qupper'[`jh'+1,`jx'+1] = `v'
			}
		}


	}

restore


ereturn matrix nardl_asym_ql    = `qlower'
ereturn matrix nardl_asym_qm    = `qmedian'
ereturn matrix nardl_asym_qu    = `qupper'



end

