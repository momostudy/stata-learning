*! boottest 4.4.4 36 April 2023
*! Copyright (C) 2015-23 David Roodman

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.

*! Version history at bottom


cap program drop boottest
program define boottest
	version 11
  cap version 13.1
  if _rc {
     di as err "This version of {cmd:boottest} requires Stata version 13 or later. An older version compatible with Stata `c(stata_version)'"
     di as err "is at https://github.com/droodman/boottest/releases/tag/v2.6.0."
     exit _rc
  }
	cap noi _boottest `0'
	local rc = _rc
	constraint drop `anythingh0'
	cap mata mata drop _boottestp
	cap mata mata drop _boottestC
	cap mata mata drop _boottestkeepC
	cap mata mata drop _boottestm
	cap mata mata drop _boottestt
	cap drop `contourvars'
	exit `rc'
end

cap program drop _boottest
program define _boottest, rclass sortpreserve
	version 11

	local   cmd = cond(substr("`e(cmd)'", 1, 6)=="ivreg2" | ("`e(cmd)'"=="ivreghdfe" & "`e(extended_absvars)'"==""), "ivreg2", "`e(cmd)'")
	local ivcmd = cond(inlist("`cmd'","reghdfe","ivreghdfe"), cond("`e(model)'"=="iv", "ivreg2", ""), cond("`cmd'"=="xtivreg2", "ivreg2", "`cmd'"))

	if "`e(cmd)'" == "" {
		di as err "No estimates detected."
		error 198
	}
	if "`e(prefix)'" == "svy" {
		di as err "Doesn't work after {cmd:svy}."
		exit 198
	}
	if inlist("`cmd'", "mvreg", "sureg") {
		di as err "Doesn't work after {cmd:`e(cmd)'}."
		exit 198
	}
	if "`e(cmd)'" == "margins" {
		di as err "Doesn't work after {cmd:margins ..., post}."
		exit 198
	}
	if inlist("`cmd'", "xtreg", "xtivreg") & "`e(model)'"!="fe" {
		di as err "Doesn't work after {`cmd', `e(model)'}."
		exit 198
	}
	if "`cmd'"=="xtivreg2" & "`e(xtmodel)'"!="fe" {
		di as err "Doesn't work after {`cmd', `e(xtmodel)'}."
		exit 198
	}
	if inlist("`cmd'","reghdfe","ivreghdfe") {
    fvunab absvars: `e(extended_absvars)'
		if `:word count `absvars''>1 {
			di as err "Doesn't work after {cmd:`cmd'} with more than one set of absorbed fixed effects or with absorbed interaction terms."
			exit 198
		}
		if strpos("`absvars'", "c.") {
			di as err "Doesn't work after {cmd:`cmd'} with absorbed interaction terms containing slopes."
			exit 198
		}
    else local absvars = subinstr(subinstr("`absvars'", "#", " ", .), "i.", "", .)
	}
	if inlist("`cmd'", "sem", "gsem") & c(stata_version) < 14 {
		di as err "Requires Stata version 14.0 or later to work with {cmd:`e(cmd)'}."
		exit 198
	}
	if "`e(cmd)'"=="regress" & "`e(model)'" == "iv" {
		di as err "Doesn't support the undocumented IV syntax of {cmd:regress}."
		exit 198
	}
  
  if ("`ivcmd'"=="ivreg2" & "`e(model)'"=="gmm2s") | ("`cmd'"=="ivregress" & "`e(estimator)'"=="gmm") {
  	di as err "GMM no longer supported."
    exit 198
  }

	tokenize `"`0'"', parse(",")
	if `"`1'"' != "," {
		local h0s `1'
		macro shift
	}
	local 0 `*'
	syntax, [h0(numlist integer >0) Reps(integer 999) seed(string) BOOTtype(string) CLuster(string) Robust BOOTCLuster(string) noNULl QUIetly WEIGHTtype(string) Ptype(string) STATistic(string) NOCI Level(real `c(level)') NOSMall SMall SVMat ///
						noGRaph gridmin(string) gridmax(string) gridpoints(string) graphname(string asis) graphopt(string asis) ar MADJust(string) CMDline(string) MATSIZEgb(real 1000000) PTOLerance(real 1e-3) svv MARGins ///
            issorted julia threads(integer 0) float(integer 64) Format(string) jk JACKknife *]
  if "`format'"=="" local format %10.4g
  
  local jk = "`jk'`jackknife'" != ""

  local julia = "`julia'" != ""

  if `julia' & !0$boottest_julia_loaded {
    if c(stata_version) < 16 {
      di as err "The {cmd:julia} option requires Stata 16 or higher."
      exit 198
    }

    cap python: 1
		if _rc {
      di as err "The {cmd:julia} option requires that Python be installed and Stata be configured to use it."
      di as err `"See {browse "https://blog.stata.com/2020/08/18/stata-python-integration-part-1-setting-up-stata-to-use-python":instructions}."'
      exit 198
    }

    qui python query
    if "`r(version)'" < "3" {
      di as err "Stata is currently configured to use Python " `r(version)' ". The {cmd:julia} option requires Python 3."
      di as err `"See {help python}."'
      exit 198
    }

    local pipline = "!py" +  cond(c(os)=="Windows","","thon"+substr("`r(version)'",1,1)) + " -m pip install --user"  // https://packaging.python.org/en/latest/tutorials/installing-packages/#use-pip-for-installing
    python: from sfi import Data, Matrix, Missing, Scalar, Macro

    di as txt "Invoking the Julia implementation. The first call in each Stata session is slow."
    mata displayflush()

    cap python: import julia

    if _rc {
      di "Installing PyJulia..."
      `pipline' julia
      cap python: import julia; julia.install(color=False)
    }
    if _rc {
      di as err _n "The {cmd:julia} option requires the Python package PyJulia. Unable to install it automatically."
      di as err `"You can install it {browse "https://pyjulia.readthedocs.io/en/stable/installation.html":manually}."'
      exit 198
    }

    cap python: import psutil
    if _rc {
      di "Installing psutil..."
      `pipline' psutil
      cap python: import psutil
    }
    if _rc {
      di as err _n "The {cmd:julia} option requires the Python package psutil. Unable to install it automatically."
      di as err `"You can install it {browse "https://github.com/giampaolo/psutil/blob/master/INSTALL.rst":manually}."'
      exit 198
    }

    cap python: import numpy as np
    if _rc {
      di "Installing NumPy..."
      `pipline' numpy
      cap python: import numpy as np
      if _rc {
        di as err _n "The {cmd:julia} option requires the Python package NumPy. Unable to install it automatically."
        di as err `"You can install it {browse "https://numpy.org/install":manually}."'
        exit 198
      }
    }
    
//     python: import sys; nthreads = str(psutil.cpu_count(logical=False)) if 'psutil' in sys.modules else '1'  // try to set # of Julia threads to # of physical cores
//     local pyline from julia.api import LibJulia; LibJulia.load().init_julia(['--threads='+nthreads]); from julia import Main, Random, Pkg
    if `threads' {
      python: nthreads = `threads'
    }
    else {
      python: import sys; nthreads = psutil.cpu_count(logical=False) if 'psutil' in sys.modules else 1  // try to set # of Julia threads to # of physical cores
    }
    local pyline from julia import Julia; jl=Julia(/*sysimage=r"C:\Users\drood\ado\plus\b\wbt.so",*/ threads=nthreads); from julia import Main, Random, Pkg
    cap python: `pyline'
    if _rc {
      cap python: julia.install(color=False); `pyline'
      if _rc {
        di as err _n "Could not automatically initialize the PyJulia package."
        di as err `"Perhaps {browse "https://pyjulia.readthedocs.io/en/latest/installation.html#install-pyjulia":these instructions} will help."'
        exit 198
      }
    }

    qui python: Scalar.setValue("rc", Main.eval('VERSION < v"1.8.0"')) 
    if 0`rc' {
      di as err _n "The {cmd:julia} option requires that Julia 1.8 or higher be installed and accessible by default through the system path."
      di as err `"Follow {browse "https://julialang.org/downloads/platform":these instructions} for installing it and adding it to the system path."'
      exit 198
    }
// python:Main.eval('pushfirst!(LOAD_PATH,raw"D:\OneDrive\Documents\Macros\WildBootTests.jl")')
    qui python: Main.eval('using Pkg; p=[v for v in values(Pkg.dependencies()) if v.name=="WildBootTests"]')
    python: Macro.setLocal("rc", str(Main.eval('length(p)')))
    if `rc'==0 {
      di "Installing WildBootTests.jl..."
      cap python: Pkg.add("WildBootTests")
      if _rc {
        di as err _n "Failed to automatically install the Julia package WildBootTests.jl."
        di as err `"You should be able to install it by running Julia and typing {cmd:using Pkg; Pkg.add("WildBootTests")}."'
        exit 198
      }
    }
    else {
      python: Macro.setLocal("rc", str(Main.eval('p[1].version < v"0.9.7"')))  // hard-coded version requirement
      if "`rc'" == "True" {
        di "Updating WildBootTests.jl..."
        cap python: Pkg.update("WildBootTests")
        if _rc {
          di as err _n "Failed to automatically update the Julia package WildBootTests.jl."
          di as err `"You should be able to update it by running Julia and typing {cmd:using Pkg; Pkg.update("WildBootTests")}."'
          exit 198
        }
      }
    }

    qui python: Main.eval('using Pkg; p=[v for v in values(Pkg.dependencies()) if v.is_direct_dep && v.name=="StableRNGs"]')
    python: Macro.setLocal("rc", str(Main.eval('length(p)')))
    if `rc'==0 {
      di "Installing StableRNGs.jl..."
      cap python: Pkg.add("StableRNGs")
      if _rc {
        di as err _n "Failed to automatically install the Julia package StableRNGs."
        di as err `"This should be installable from within Julia by typing {cmd:using Pkg; Pkg.add("StableRNGs")}."'
        exit 198
      }
    }
    python: from julia import WildBootTests, StableRNGs
    python: rng = StableRNGs.StableRNG(0)  // create now; properly seed later
    global boottest_julia_loaded 1
  }

  if "`small'" != "" & "`nosmall'" != "" {
    di as err "{cmd:small} and {cmd:nosmall} options conflict."
    exit 198
  }

  local margins = "`margins'" != ""
  if `margins' & `"`h0s'`h0'"' != "" {
    di as err "Include the {cmd:margins} option or state null hyptheses, but don't do both."
    exit 198
  }
  if `margins' & "`r(predict1_label)'" != "Linear prediction" {
    di as err _n "{cmd:margins} option only works with linear margins predictions such as average predictions after {cmd:regress}."
    exit 198
  }
  
  if inlist("`e(cmd)'", "didregress", "xtdidregress") & `"`h0s'`h0'"' == "" local h0s r1vs0.`e(treatment)'

	if `matsizegb'==1000000 local matsizegb .
  
  if "`svv'" != "" tempname svv

	if `reps'==0 local svmat
		else {
			local _svmat = cond("`svmat'"=="", "", "t")
			local 0, `options'
			syntax, [SVMat(string) *]
			if !inlist(`"`svmat'"', "numer", "t", "") {
				di as err "option " as res "svmat(" `svmat' ")" as err " not allowed."
				error 198
			}
			if "`svmat'" == "" local svmat `_svmat'
		}

	if `"`options'"' != "" {
		if `"`options'"'=="ci" di as err "Option {cmd:ci} is obsolete, because it is now the default."
			else di as err `"Option `options' not allowed."'
		exit 198
	}

	if `reps' < 0 {
		di as err "{cmdab:r:eps()} option must be non-negative."
		exit 198
	}

	local 0, `madjust'
	syntax, [Bonferroni Sidak]
	local madjust `bonferroni'`sidak'

	if `"`graphname'"' != "" {
		local 0 `graphname'
		syntax [anything(name=graphname)], [replace]
	}
	else local graphname Graph

	if `"`gridpoints'"'!="" {
		foreach g of local gridpoints {
			cap confirm integer number `g'
			local rc = _rc
			if !_rc {
				local rc = `g' <= 0
			}
			if `rc' {
				di as err "{cmd:gridpoints()} entry not a positive integer."
				exit 198
			}
		}
	}

	foreach macro in gridmin gridmax {
		if `"``macro''"'!="" {
			foreach g of local `macro' {
				if `"`g'"' != "." {
					cap confirm number `g'
					if _rc {
						di as err "{cmd:`macro'()} entry not numeric."
						exit 198
					}
				}
			}
		}
	}
	
	if `"`robust'`cluster'"' != "" {
		local hasrobust 1
		local clustvars `cluster'
		if `"`clustvars'"'!="" confirm var `clustvars'
		local override 1
		di as txt _n "Overriding estimator's cluster/robust settings with " as res `"`=cond("`clustvars'"=="", "robust", "cluster(`clustvars')")'"'
	}
	else {
		local clustvars `e(clustvar)'
		local hasrobust = "`e(vcetype)'" == "Robust" | "`clustvars'" != ""
	}

	local hasclust = `"`clustvars'"' != ""

	local wtype `e(wtype)'
	local null = "`null'" == ""
	if "`svmat'"!="" tempname dist
	local ar = "`ar'" != ""
	if `ar' & `"`h0s'`h0'"' == "" local h0s `e(instd)'

	if `:word count `weighttype'' > 1 {
		di as err "The {cmd:weight:type} option must be {cmdab:rad:emacher}, {cmdab:mam:men}, {cmdab:nor:mal}, {cmdab:web:b}, or {cmdab:gam:ma}."
		exit 198
	}
	if "`weighttype'"'=="" local weighttype rademacher
	else {
		local 0, `weighttype'
		syntax, [RADemacher MAMmen NORmal WEBb GAMma]
		local weighttype `rademacher'`mammen'`normal'`webb'`gamma'
	}

	if `:word count `ptype'' > 1 {
		di as err "The {cmd:wp:type} option must be {cmdab:sym:metric}, {cmdab:eq:qualtail}, {cmd:lower}, or {cmd:upper}."
		exit 198
	}
	if "`ptype'"'=="" local ptype symmetric
	else {
		local 0, `ptype'
		syntax, [SYMmetric EQualtail LOWer UPper]
		local ptype `symmetric'`equaltail'`lower'`upper'
	}
 
	if `"`statistic'"'=="" local statistic t
	else if !inlist(`"`statistic'"', "t", "c") {
		di as err "The {cmd:stat:istic} option must be {cmd:t} or {cmd:c}."
		exit 198
	}
	else if "`statistic'"=="c" & `reps'==0 {
		di as err "{cmdab:stat:istic(c)} not allowed with non-bootstrap tests."
		exit 198
	}

	local ML = e(converged) != .
	local IV = "`e(instd)'`e(endogvars)'" != ""
	local LIML = ("`cmd'"=="ivreg2" & "`e(model)'"=="liml") | ("`cmd'"=="ivregress" & "`e(estimator)'"=="liml")| (inlist("`cmd'","reghdfe","ivreghdfe") & strpos("`e(title)'", "LIML"))
	local WRE = `"`boottype'"'!="score" & `IV' & `reps'
	local small = (e(df_r) != . | "`small'" != "" | e(cmd)=="cgmreg") & "`nosmall'"==""
  local partial = `:word count `e(partial1)'' & inlist("`e(cmd)'", "ivreg2", "xtivreg2", "ivreghdfe")
	local fuller `e(fuller)'  // "" if missing
	local K = e(kclass)  // "." if missing

  local DID = inlist("`cmd'", "didregress", "xtdidregress")
  if `DID' {
    if "`e(aggmethod)'" != "" {
      di as err "Doesn't work after {cmd:`e(cmd)'} with aggregation."
      exit 198
    }
    local treatment `e(treatment)'
  	local 0 `e(cmdline)'
    syntax [anything], [NOGTEFFECTS *]
    local DID = "`nogteffects'" == ""
  }

	local tz = cond(`small', "t", "z")
	local symmetric Prob>|`tz'|
	local equaltail 2 * min(Prob>|`tz'|, Prob<-|`tz'|)
	local lower             Prob<`tz'
	local upper             Prob>`tz'

	if `ar' & !`IV' {
		di as err "Anderson-Rubin test is only for IV models."
		exit 198
	}

  if `jk' & `ML' {
		di as err "boottest can't jackknife ML-based estimates."
		exit 198
  }
  
	if "`boottype'"'=="" local boottype = cond(`ML', "score", "wild")
	else {
		local 0, `boottype'
		syntax, [Wild SCore]
		local boottype `score'`wild'
		if "`boottype'" == "wild" & `ML' {
			di as err "{cmd:boottype(wild)} not accepted after Maximum Likelihood-based estimation."
			exit 198
		}
		if "`boottype'"=="score" & "`fuller'`K'" != "." & "`e(model)'"!="liml" {
			di as err "{cmd:boottype(score)} not accepted after Fuller LIML or k-class estimation."
			exit 198
		}
	}
	local scoreBS = "`boottype'"=="score"
	
  local NFE = cond(inlist("`cmd'","xtreg","xtivreg","xtivreg2"), e(N_g) + 0`e(singleton)',  ///
              cond(`DID', 0`e(N_clust)',                                  ///
              cond("`cmd'"=="areg", 1+e(df_a),                            ///
                   max(0`e(K1)', 0`e(df_a_initial)'))))  // reghdfe

  local _FEname = cond(inlist("`cmd'","xtreg","xtivreg","xtivreg2"), "`e(ivar)'", cond(`DID', "`e(clustvar)'", "`e(absvar)'`absvars'"))
  if `"`_FEname'"' != "" {
    cap confirm numeric var `_FEname'
    if _rc | `:word count `_FEname' > 1' {
      tempvar FEname
      qui egen long `FEname' = group(`_FEname') if e(sample)
    }
    else local FEname `_FEname'
  }

  if "`cmd'" == "xtreg" {
    local 0 `e(cmdline)'
    syntax [anything] [if] [in] [fw aw pw iw], [dfadj *]
    local FEdfadj = ("`dfadj'" != "") * `NFE'
  }
  else if inlist("`cmd'","xtivreg","xtivreg2","xtdidregress") local FEdfadj 0
  else if inlist("`cmd'", "reghdfe", "ivreghdfe") local FEdfadj = max(1, e(df_a))
  else local FEdfadj `NFE'

	if `"`seed'"'!="" set seed `seed'

	tempname p padj se teststat df df_r hold C1 C R1 R r1 r1r R1R r b V b0 V0 keepC repsname repsFeasname t NBootClustname marginsH0 touse
	mat `b' = e(b)
	if "`e(wtype)'" != "" {
		tokenize `e(wexp)', parse("=")
		cap confirm var `2'
		if _rc {
			tempname wtname
			qui gen double `wtname' `e(wexp)'
		}
		else if c(varabbrev)=="on" unab wtname: `2'
    else local wtname `2'
	}

	if `"`h0s'"' != "" {
		if "`h0'" != "" {
			di as err "Specify hypotheses before comma or with {cmd:h0()} option, but not both."
			exit 198
		}
		local multiple = strpos(`"`h0s'"', "{")
		if !`multiple' local h0s {`h0s'}
		local N_h0s 0  // number of nulls
		while `"`h0s'"' != "" {
			gettoken h0 h0s: h0s, parse("{}")
			if !inlist(`"`h0'"', "{", "}") {
				local ++N_h0s
				while `"`h0'"' != "" {
					gettoken cns h0: h0, parse("()") match(m)
					constraint free
					constraint `r(free)' `cns'
					local h0_`N_h0s' `h0_`N_h0s'' `r(free)'
					local constraints  `constraints' `r(free)'
					c_local anythingh0 `constraints'
				}
			}
		}
		local anythingh0 1
	}
	else if `margins' {
  	if strlen("`r(Jacobian)'") {
    	mata _boottestp = selectindex(rowsum(st_matrix("r(Jacobian)"):!=0))  // skip all-zero rows
      mata st_local("marginsnames", invtokens(st_matrixrowstripe("r(Jacobian)")[_boottestp,2]'))
      mata st_matrix("`marginsH0'", st_matrix("r(Jacobian)")[_boottestp,])
      mata st_local("N_h0s", strofreal(length(_boottestp)))
      if `N_h0s'==0 {
        di as err "No valid {cmd:margins} results not found."
        error 303
      }
      scalar `df' = 1  // always when working with margins results, df = 1 and constant term = 0
      mat `r' = 0

      local 0 r(cmdline)
      marksample marginstouse, strok
    }
    else {
    	di as err "{cmd:margins} results not found."
      error 303
    }
  }
  else {
		local N_h0s 1  // number of nulls
		if "`h0'" == "" {
			di as txt _n "({cmd:h0(1)} assumed)"
			local h0 1
		}
		foreach c of numlist `h0' {
			`quietly' if `"`: constraint `c''"' == "" di as res "Constraint `c' not found and will be skipped."
		}
		local h0_1 `h0'
	}

	if `N_h0s'==1 local madjust

	makecns
	if "`e(Cns)'" != "" {
		local hascns 1
		mat `C1' = e(Cns)
    mat `R1' = `C1'[1...,1..colsof(`C1')-1]
    mat `r1' = `C1'[1...,   colsof(`C1')  ]
	}

	cap _estimates drop `hold'
	if !`ML' {
		if ("`ivcmd'"=="ivreg2" & !inlist("`e(model)'", "ols", "iv", "gmm2s", "liml")) | ("`ivcmd'"=="ivregress" & !inlist("`e(estimator)'", "liml", "2sls", "gmm")) {
			di as err "Only for use with OLS, 2SLS, single-equation GMM, and ML-based estimators."
			exit 198
		}

		local Ynames `e(depvar)'

		local colnames: colnames e(b)
    if `partial' local colnames `colnames' `e(partial1)'
    local k = `:word count `colnames'' + (`partial' & 0`e(partialcons)')
		local _cons _cons
    local cons = "`:list colnames & _cons'" != ""
		local colnames: list colnames - _cons

		if `IV' {
			local Xnames_endog `e(instd)'
			local Xnames_exog: list colnames - Xnames_endog
			local cons = `cons' | e(partialcons)==1

			if inlist("`cmd'", "ivreg2", "xtivreg2", "ivreghdfe") local ZExclnames `e(exexog1)'
//       else if "`e(cmd)'"=="ivreghdfe" {  // ivreghdfe provides no collinear instrument info
//         if "`FEname'"==""  local ZExclnames `e(exexog1)'
//         else {
//           qui _rmdcoll `Ynames' `Xnames_exog' i.`FEname' `e(exexog1)' if e(sample) [`e(wtype)'`e(wexp)']  // will fail if number of groups exceeds matsize
//           local varlist `r(varlist)'
//           local n: word count `varlist'
//           forvalues i=`=`n'-`:word count `e(exexog1)''+1'/`n' {
//             local var: word `i' of `varlist'
//             _ms_parse_parts `var'
//             if !r(omit) local ZExclnames `ZExclnames' `var'
//           }
//         }
//       }
      else {
        local ZExclnames `e(insts)'
        local ZExclnames: list ZExclnames - Xnames_exog
      }
		}
		else {
			local Xnames_exog `colnames'
      if inlist("`e(cmd)'", "didregress", "xtdidregress") local Xnames_exog: subinstr local Xnames_exog "r1vs0." ""
		}

		local cons = `cons' & !0`NFE'  // no constant in FE model
		if !`cons' local _cons

		mata _boottestp = J(`cons', 1, `k') \ order(tokens("`colnames'")', 1)[invorder(order(tokens("`Xnames_exog' `Xnames_endog'")', 1))]  // for putting vars in cons-exog-endog order
		if `cons' mat `keepC' = 1
		local colnames `_cons' `Xnames_exog' `Xnames_endog'

		foreach varlist in Xnames_exog Ynames Xnames_endog ZExclnames {
      fvrevar ``varlist'' if e(sample)
      local revarlist `r(varlist)'
			local _revarlist
			forvalues i=1/`:word count ``varlist''' {
				local var: word `i' of ``varlist''
        _ms_parse_parts `var'
				if !r(omit) {
					local _revarlist `_revarlist' `: word `i' of `revarlist''
					if inlist("`varlist'", "Xnames_exog", "Xnames_endog") {
						local pos: list posof "`var'" in colnames
						if `pos' mat `keepC' = nullmat(`keepC'), `pos'
					}
				}
			}
			local `varlist' `_revarlist'
		}
		mata _boottestkeepC = st_matrix("`keepC'"); _boottestp = cols(_boottestkeepC)? _boottestp[_boottestkeepC] : J(0,1,0)

		if 0`hascns' {
      if `partial' mat `R1' = `R1', J(rowsof(`R1'), `:word count `e(partial1)'', 0)  // add blanks for partialled-out 
      mata st_matrix("`R1'", st_matrix("`R1'")[,_boottestp])  // put cols in standardized order & drop those for omitted regressors
      mata _boottestkeepC = rowsum(st_matrix("`R1'"):!=0)
      mata st_matrix("`R1'", select(st_matrix("`R1'"), _boottestkeepC))  // drop rows corresponding purely to omitted variables
      mata st_matrix("`r1'", select(st_matrix("`r1'"), _boottestkeepC))
    }    

		if `cons' local Xnames_exog `hold' `Xnames_exog'  // add constant term
	}

	local NErrClustVar : word count `clustvars'
	if `hasclust' {
		if 0`override' {
			cap assert !missing(`:subinstr local clustvars " " ",", all') if e(sample), `=cond(c(stata_version)>=12.1, "fast", "")'
			if _rc {
				di as err "A clustering variable has a missing value for at least one observation."
				exit 9
			}
		}

		if `"`bootcluster'"' == "" {
			local bootcluster `clustvars'
			if `reps' & `NErrClustVar'>1 di as txt "({cmdab:bootcl:uster(`clustvars')} assumed)"
		}
		local    clustvars `:list clustvars & bootcluster' `:list clustvars - bootcluster'
		local allclustvars `:list bootcluster - clustvars' `clustvars' // put bootstrapping clusters first, error clusters last, overlap in middle

		if "`issorted'"=="" sort `clustvars' `:list bootcluster - clustvars', stable  // bootstrapping-only clusters left out of this sort. Effect is that in subcluster bootstrap, bootstrapping clusters are intersections of all clusterings

		foreach clustvar in `allclustvars' {
			if !inlist("`:type `clustvar''", "byte", "int", "long") {
				tempvar IDname
				qui egen long `IDname' = group(`clustvar') if e(sample)
				local _allclustvars `_allclustvars' `IDname'
			}
			else local _allclustvars `_allclustvars' `clustvar'
		}
		local allclustvars `_allclustvars'
	}
  local NBootClustVar: word count `bootcluster'

	forvalues h=1/`N_h0s' {  // loop over multiple independent constraints
    if `margins' mat `R' = `marginsH0'[`h', 1...]
    else {
    	_estimates hold `hold', restore
      ereturn post `b'
      mat `b' = e(b)

      local h0text
      foreach c in `h0_`h'' {
        local h0text = `"`h0text'"' + `" "`: constraint `c''""'
      }

      qui makecns `h0_`h''  // process hypothesis constraints into e(Cns)
      if "`h0_`h''" != "`r(clist)'" {
        local clist `r(clist)'
        local clist: list h0_`h' - clist
        foreach c in `clist' {
          di as txt `"note: constraint `=cond(0`anythingh0', `"{res}`:constraint `c''{txt}"', "number `c'")' caused error {search r(111)}"'
          if `DID' di `"If your test relates to the treatment effect, you may need to reference "{cmd:r1vs0.`treatment'}" instead of "{cmd:`treatment'}"."' _n
        }
        exit 111
      }
      
      cap mat `C' = e(Cns)
      if _rc exit 111
      _estimates unhold `hold'
      if r(k_autoCns) mat `C' = `C'[r(k_autoCns)+1...,1...]
      mat `R' = `C'[1...,1..colsof(`C')-1]
      mat `r' = `C'[1...,   colsof(`C')  ]

			* get rid of any remaining o. and b. constraints; r(k_autoCns) doesn't capture all
			mata _boottestC = st_matrixcolstripe("`R'")[,2]
			mata _boottestC = rowsum(select(st_matrix("`R'"), !(strmatch(_boottestC, "*b*.*") :| strmatch(_boottestC, "*o*.*"))') :!= 0)
			mata st_matrix("`R'", select(st_matrix("`R'"), _boottestC))
			mata st_matrix("`r'", select(st_matrix("`r'"), _boottestC))
			cap mat `R'[1,1] = `R'[1,1]
			if _rc {
				di as error _n "Null constraint applies only to omitted variables or base levels of factor variables."
				continue
			}
			scalar `df' = rowsof(`R')
    }

		if 0`NFE' {
			mata st_local("rc", strofreal(any(0:!=select(st_matrix("`R'"),st_matrixcolstripe("`R'")[,2]':=="_cons"))))

			if `rc' {
				di as err "In fixed-effect models, null hypotheses may not involve constant term."
				exit 111
			}
		}

		local plotmat
		local peakmat
		local cimat
		if "`noci'"=="" & !`ML' & (`df'<=1 | `df'==2 & "`graph'"=="") {
			if `reps' | !`scoreBS' | `null' | "`graph'"=="" tempname plotmat peakmat // don't request plot if doing simple Wald with no graph
			if `level'<100 & `df'==1 tempname cimat
		}

		if `df'>1 & "`ptype'"!="symmetric" di as txt "Note: {cmd:ptype(`ptype')} ignored for multi-constraint null hypotheses."

		if `df'<=2 {  // a bit duplicative of code in the if-`ML' block just below...
			if  "`graph'"=="" {  // construct axis label(s)
				if `margins' local constraintLHS1 "Margins of `:word `h' of `marginsnames''"
        else {
        	local coleq: coleq `b'
          if "`:word 1 of `coleq''"=="_" local coleq
          local colnames: colnames `b'
          forvalues i=1/`=`df'' {
            local terms 0
            local constraintLHS`i'
            forvalues j=1/`=colsof(`R')' {
              if `R'[`i',`j'] {
                if `terms++' local constraintLHS`i' `constraintLHS`i''+
                local constraintLHS`i' `constraintLHS`i'' `=cond(`R'[`i',`j']!=1,"`=`R'[`i',`j']'*","")'`=cond("`coleq'"=="","","[`:word `j' of `coleq'']")'`:word `j' of `colnames''
              }
            }
					}
				}
			}
			
			foreach option in gridmin gridmax gridpoints {
				if "``option''" == "" local `option' = `df' * ". "
				else if `df' != `:word count ``option''' {
					di as err "{cmd:`option'()} option needs " cond(`df'==1, "one entry", "two entries")
					exit 199
				}
        tempname `option'vec
        mata st_matrix("``option'vec'", strtoreal(tokens("``option''"))) 
			}
		}

		if `ML' {
			local K .
      local k = colsof(`b')

			if `null' {
				if "`e(cmdline)'"=="" & `"`cmdline'"'=="" {
					di as err "Original estimation command line needed. Include it in a {cmd:cmdline()} option."
					exit 198
				}
				if "`cmd'"=="tobit" & c(stata_version)<15 {
					di as err "Cannot impose null after {help tobit} in Stata versions below 15. Try re-fitting the model with {stata ssc describe cmp:cmp}, {help intreg}, or {help gsem}."
					exit 198
				}

				mat `R1R' = `R' \ nullmat(`R1')  // add null to model constraints
				mat `r1r' = `r' \ nullmat(`r1')

				`quietly' di as res _n "Re-running regression with null imposed." _n
				if `"`cmdline'"'=="" local 0 `e(cmdline)'
				                else local 0 `cmdline'
				syntax [anything] [aw pw fw iw] [if] [in], [CONSTraints(passthru) from(passthru) INIt(passthru) ITERate(passthru) CLuster(passthru) Robust vce(string) *]
				if "`e(cmd)'"=="ml" local max max  // tack on max option in case ml run in interactive model and cmdline() is missing it

				cap _estimates drop `hold'
				_estimates hold `hold', restore
				local coleq: coleq `b'
				if "`:word 1 of `coleq''"=="_" local coleq
				local colnames: colnames `b'
				local _constraints
				forvalues i=1/`=rowsof(`R1R')' {
					local terms 0
					local _constraint
					forvalues j=1/`=colsof(`R1R')' {
						if `R1R'[`i',`j'] {
							if `terms++' local _constraint `_constraint' +
							local _constraint `_constraint' `=cond(`R1R'[`i',`j']!=1,"`=`R1R'[`i',`j']' * ","")' `=cond("`coleq'"=="","","[`:word `j' of `coleq'']")'`:word `j' of `colnames''
						}
					}
					local _constraint `_constraint' = `=`r1r'[`i',1]'
					constraint free
					local _constraints `_constraints' `r(free)'
					constraint `r(free)' `_constraint'
				}

				cap `=cond("`quietly'"=="", "noisily", "")' `=cond("`cmd'"=="tobit", "version 15:", "")' `anything' if `hold' `=cond("`weight'"=="","",`"[`weight'`exp']"')', constraints(`_constraints') `from' `init' `iterate' `max' `options'

				local rc = _rc
				constraint drop `_constraints'
				if e(converged)==0 {
					di as err "Could not impose null."
					exit 430
				}
				if !`rc' {
					mat `b0' = e(b)
					cap `=cond("`cmd'"=="tobit", "version 15:", "")' `anything' if e(sample), `=cond(inlist("`cmd'","cmp","ml"),"init(`b0')","from(`b0',skip)")' iterate(0) `options' `max'
					local rc = _rc
          mat drop `b0'
				}
				if `rc' {
					di as err "Error imposing null. Perhaps {cmd:`cmd'} does not accept the {cmd:constraints()}, {cmd:from()}, and {cmd:iterate()} options, as needed."
					exit `rc'
				}
				if "`quietly'"=="" {
					mata st_numscalar("`t'", any(!diagonal(st_matrix("e(V)")) :& st_matrix("e(b)")'))
					if `t' {
						di _n as res _n "{res}Warning: Negative Hessian under null hypothesis not positive definite. Results may be unreliable." _n
						di "This may indicate that the constrained optimum is far from the unconstrained one, i.e., that the hypothesis is incompatible with the data." _n
					}
				}
			}
			
			mat `V' = e(V`=cond("`e(V_modelbased)'"!="", "_modelbased", "")')

			tempvar sc
			cap predict double `sc'* if e(sample), score
			if _rc {
				di as err "Could not generate scores from `e(cmd)' with {cmd:predict}."
				exit _rc
			}

			unab scnames: `sc'*
			if `:word count `scnames'' == e(k_eq) {  // generate score for each parameter from those for each equation
				local colnames: colnames `b'
				tokenize `:coleq `b''
				local lasteq
				local eq 0
				local _sc
				qui forvalues i=1/`k' {
					if "``i''" != "`lasteq'" | "``i''"=="/" {
						local ++eq
						local lasteq ``i''
					}
					local var: word `i' of `colnames'
					if "`var'"=="_cons" | strmatch("`var'","*._cons") | "``i''"=="/" local _sc `_sc' `:word `eq' of `scnames'' // constant term or free parameter
					else {
						tempvar t
						gen double `t' = `:word `eq' of `scnames'' * `var' if e(sample)
						local _sc `_sc' `t'
					}
				}
				local scnames `_sc'
			}

			if !`null' {
				cap _estimates drop `hold'
				_estimates hold `hold', restore  // rename estimation as `hold' instead of generating new sample marker
			}
		}
		else { // not ML
      if `partial' mat `R'  = `R', J(`df', `:word count `e(partial1)'' + e(partialcons), 0)  // add blanks for partialled-out
      mata st_matrix("`R'" , st_matrix("`R'" )[,_boottestp])  // put cols in standardized order & drop those for 0-variance vars

 			cap _estimates drop `hold'
			_est hold `hold', restore

			if `ar' {
				local kEnd: word count `Xnames_endog'
				local kEx : word count `Xnames_exog'
				mata st_numscalar("`p'", rows(st_matrix("`R'"))!=`kEnd' | (`kEx'? any(st_matrix("`R'")[|.,.\.,`kEx'|]) : 0))
				if `p' {
					di as err "For Anderson-Rubin test, null hypothesis must constrain all the instrumented variables and no others."
					exit 198
				}			
			}
		}

    cap confirm var `hold'
    if _rc {
      di as err "Sample marker for the regression not found. Perhaps the data set was cleared and reconstructed."
      exit _rc
    }

    if `margins' {
      cap drop `touse'
      gen byte `touse' = `hold' & `marginstouse'
      local sample `touse'
    }
    else local sample `hold'

    return local seed = cond("`seed'"!="", "`seed'", "`c(seed)'")

    if !`julia' {
      mata boottest_stata("`teststat'", "`df'", "`df_r'", "`p'", "`padj'", "`cimat'", "`plotmat'", "`peakmat'", `level', `ptolerance', ///
                          `ML', `LIML', 0`fuller', `K', `ar', `null', `scoreBS', `jk', "`weighttype'", "`ptype'", "`statistic'", ///
                          "`madjust'", `N_h0s', "`Xnames_exog'", "`Xnames_endog'", ///
                          "`Ynames'", "`b'", "`V'", "`ZExclnames'", "`hold'", "`scnames'", `hasrobust', "`allclustvars'", `NBootClustVar', `NErrClustVar', ///
                          "`FEname'", `NFE', `FEdfadj', "`wtname'", "`wtype'", "`R1'", "`r1'", "`R'", "`r'", `reps', "`repsname'", "`repsFeasname'", `small', "`svmat'", "`dist'", ///
                          "`gridmin'", "`gridmax'", "`gridpoints'", `matsizegb', "`quietly'"!="", "`b0'", "`V0'", "`svv'", "`NBootClustname'")
    }
    else {
      foreach X in R R1 V {
        cap python: `X' = np.asarray(Matrix.get('``X'''))
        if _rc python: `X' = np.empty([0,0])
      }
      foreach X in gridminvec gridmaxvec gridpointsvec {
        cap python: `X' = np.squeeze(np.asarray([np.nan if x==Missing.getValue() else x for x in Matrix.get('``X''')[0]])).flatten()
        if _rc python: `X' = np.empty([`=`df'',0])
      }
      foreach X in r r1 b {
        cap python: `X' = np.squeeze(np.asarray(Matrix.get('``X'''))).flatten()
        if _rc python: `X' = np.empty([0])
      }
      foreach X in Xnames_exog Xnames_endog ZExclnames scnames {
        python: `X' = np.asarray(Data.get('``X''', selectvar="`hold'"))
      }
      foreach X in Ynames wtname {
        python: `X' = np.squeeze(np.asarray(Data.get('``X''', selectvar="`hold'"))).flatten()
      }
      python: FEname = np.squeeze(np.asarray(Data.get('`FEname'', selectvar="`hold'"), dtype=np.int64)).flatten()
      python: allclustvars = np.asarray(Data.get('`allclustvars'', selectvar="`hold'"), dtype=np.int64)
// foreach X in Ynames Xnames_exog Xnames_endog ZExclnames scnames wtname gridminvec gridmaxvec gridpointsvec R R1 V r r1 b FEname allclustvars {
//   python:Main.`X' = `X'
// }
// python:Main.eval('using JLD; @save "c:/users/drood/Downloads/tmp.jld" Ynames Xnames_exog Xnames_endog ZExclnames wtname allclustvars FEname scnames R r R1 r1 gridminvec gridmaxvec gridpointsvec b V')
      qui python: Random.seed_b(rng, `=runiformint(0, 9007199254740992)')  // chain Stata rng to Julia rng
// python: from juliacall import Main as jl; jl.seval("using WildBootTests")
//       python: test = jl.wildboottest_b(jl.Float`float', R, r, overwrite=true, resp=Ynames, predexog=Xnames_exog, predendog=Xnames_endog, inst=ZExclnames, obswt=wtname, clustid=allclustvars, feid=FEname, scores=scnames, ///
//                                 R1=R1, r1=r1, ///
//                                 nbootclustvar=`NBootClustVar', nerrclustvar=`NErrClustVar', ///
//                                 issorted=True, ///
//                                 hetrobust=bool(`hasrobust'), ///
//                                 fedfadj=`FEdfadj', ///
//                                 fweights = "`wtype'"=="fweight", ///
//                                 maxmatsize=`=0`matsizegb'', ///
//                                 ptype="`ptype'", ///
//                                 bootstrapc = "`statistic'"=="c", ///
//                                 liml=bool(`LIML'), fuller=`=0`fuller'', `=cond(`K'<.,"kappa=`K',","")' ///
//                                 arubin=bool(`ar'), small=bool(`small'), ///
//                                 scorebs=bool(`scoreBS'), ///
//                                 jk=bool(`jk'), ///
//                                 reps=`reps', imposenull=bool(`null'), level=`level'/100, ///
//                                 auxwttype="`weighttype'", ///
//                                 rtol=`ptolerance', ///
//                                 madjtype="none" if "`madjust'"=="" else "`madjust'", nH0=`N_h0s', ///
//                                 ml=bool(`ML'), beta=b, A=V, ///
//                                 gridmin=gridminvec, gridmax=gridmaxvec, gridpoints=gridpointsvec, ///
//                                 diststat = "none" if "`svmat'"=="" else "`svmat'", ///
//                                 getci = `level'<100 and "`cimat'" != "", getplot = "`plotmat'"!="", ///
//                                 getauxweights = "`svv'"!="", ///
//                                 rng=rng)
      python: test = WildBootTests.wildboottest_b(Main.Float`float', R, r, resp=Ynames, predexog=Xnames_exog, predendog=Xnames_endog, inst=ZExclnames, obswt=wtname, clustid=allclustvars, feid=FEname, scores=scnames, ///
                                R1=R1, r1=r1, ///
                                nbootclustvar=`NBootClustVar', nerrclustvar=`NErrClustVar', ///
                                issorted=True, ///
                                hetrobust=bool(`hasrobust'), ///
                                fedfadj=`FEdfadj', ///
                                fweights = "`wtype'"=="fweight", ///
                                maxmatsize=`=0`matsizegb'', ///
                                ptype="`ptype'", ///
                                bootstrapc = "`statistic'"=="c", ///
                                liml=bool(`LIML'), fuller=`=0`fuller'', `=cond(`K'<.,"kappa=`K',","")' ///
                                arubin=bool(`ar'), small=bool(`small'), ///
                                scorebs=bool(`scoreBS'), ///
                                jk=bool(`jk'), ///
                                reps=`reps', imposenull=bool(`null'), level=`level'/100, ///
                                auxwttype="`weighttype'", ///
                                rtol=`ptolerance', ///
                                madjtype="none" if "`madjust'"=="" else "`madjust'", nH0=`N_h0s', ///
                                ml=bool(`ML'), beta=b, A=V, ///
                                gridmin=gridminvec, gridmax=gridmaxvec, gridpoints=gridpointsvec, ///
                                diststat = "none" if "`svmat'"=="" else "`svmat'", ///
                                getci = `level'<100 and "`cimat'" != "", getplot = "`plotmat'"!="", ///
                                getauxweights = "`svv'"!="", ///
                                rng=rng)
      python: Macro.setLocal("seed", str(Main.rand(rng, Main.Int32)))  // chain Julia rng back to Stata to advance it replicably
      set seed `seed'
      python: Main.test = test
      if "`plotmat'"!="" {
        if `df'==1 {
            python: Matrix.store("`plotmat'", Main.eval("[test.plot[:X][1] test.plot[:p]]"))
            python: Matrix.store("`peakmat'", Main.eval("[test.peak[:X][1] test.peak[:p]]"))
        }
        else {
          python: Y, X = np.meshgrid(Main.eval("test.plot[:X][2]"), Main.eval("test.plot[:X][1]"))
          python: Matrix.store("`plotmat'", np.vstack((np.reshape(X,-1), np.reshape(Y,-1), Main.eval("test.plot[:p]"))).transpose())
        }
      }
      if `level'<100 & "`cimat'" != "" python: Matrix.store("`cimat'", test.ci)
      python: Scalar.setValue("`teststat'", test.stat)
      python: Scalar.setValue("`df'", test.dof)
      python: Scalar.setValue("`df_r'", test.dof_r)
      python: Scalar.setValue("`p'", test.p)
      python: Scalar.setValue("`padj'", test.padj)
      python: Scalar.setValue("`repsname'", test.reps)
      python: Scalar.setValue("`repsFeasname'", test.repsfeas)
      python: Scalar.setValue("`NBootClustname'", test.nbootclust)
      python: Matrix.store("`b0'", test.b)
      python: Matrix.store("`V0'", test.V)
      if "`dist'"!="" python: Matrix.store("`dist'", test.dist)
      if "`svv'" !="" python: Matrix.store("`svv'", test.auxweights)
    }

		_estimates unhold `hold'

    `quietly' if 2^`NBootClustname' < `reps' & inlist("`weighttype'", "rademacher", "mammen") {
      di _n "Warning: with " `NBootClustname' " bootstrap clusters, the number of replications, `reps', exceeds the universe of " strproper("`weighttype'") " draws, 2^"`NBootClustname' " = " 2^`NBootClustname' ". " _c
      if "`weighttype'"=="rademacher" di "Sampling each once." _c
      di _n "Consider Webb weights instead, using {cmd:weight(webb)}."
    }
    local reps = `repsname'  // in case reduced to 2^G
    `quietly' if `reps' & (`NBootClustname'>12 | "`weighttype'" != "rademacher") & floor(`level'/100 * (`reps'+1)) != `level'/100 * (`reps'+1) {
      di _n "Note: The bootstrap usually performs best when the confidence level (here, `level'%)" _n "      times the number of replications plus 1 (`reps'+1=" `reps'+1 ") is an integer."
    }

		if !`ML' & `reps' & `NErrClustVar'>1 & `teststat'<. {
			return scalar repsFeas = `repsFeasname'
			if `repsFeasname' < `reps' di _n "Warning: " `reps' - `repsFeasname' " replications returned an infeasible test statistic and were deleted from the bootstrap distribution."
		}
		
		if `N_h0s'>1 local _h _`h'

		if `df'==1 {
			local tz = cond(`small', "t", "z")
			return scalar `tz'`_h' = `teststat'
		}

		di
		if `reps' {
      di as txt strproper("`boottype'") " bootstrap-`statistic', null " cond(0`null', "", "not ") "imposed, " _c
      if `jk' di "jackknifed residuals, " _c
      di as txt `reps' as txt " replications, " _c
    }
		di as txt cond(`ar', "Anderson-Rubin ", "") cond(!`reps' & `null' & "`boottype'"=="score", "Rao score (Lagrange multiplier)", "Wald") " test" _c
		if "`cluster'"!="" di ", clustering by " as res "`cluster'" _c
		if ("`bootcluster'"!="" | `NErrClustVar' > 1) & `reps' di as txt ", bootstrap clustering by " as res "`bootcluster'" _c
		if `reps'	di as txt ", " strproper("`weighttype'") " weights" _c
		di as txt ":"
		
		if `margins' di `"  `:word `h' of "`marginsnames'""'
    else {
    	foreach c in `h0_`h'' {
        di "  " _c
        if !0`anythingh0' di as txt %4.0g `c' ": " _c
        di as res "`:constraint `c''"
      }
    }

		if `df'==1 {
			local line1 = cond(`small', "t(`=`df_r'')", "z")
			di _n as txt _col(`=33-strlen("`line1'")') "`line1' = " as res %10.4f `teststat' _n _col(`=33-strlen("``ptype''")') as txt "``ptype'' = " as res %10.4f `p'
			local `teststat' = `teststat' * `teststat'
		}
		else {
			if `small' {
				local line1 F(`=`df'', `=`df_r'')
				local line2 Prob > F
			}
			else {
				local line1 chi2(`=`df'')
				local line2 Prob > chi2
			}
			di _n as txt _col(`=27-strlen("`line1'")') "`line1' = " as res %10.4f `teststat' _n as txt _col(`=27-strlen("`line2'")') "`line2' = " as res %10.4f `p'
		}

		if "`madjust'" != "" {
			di _col(`=strlen("bonferroni")-strlen("`madjust'")+3') as txt strproper("`madjust'") "-adjusted prob = " as res %10.4f `padj'
			return scalar padj`_h' = `padj'
		}

		if `NErrClustVar' > 1 {
			cap mat `t' = syminv(`V0')
			cap noi if diag0cnt(`t') di _n "Test statistic could not be computed. The multiway-clustered variance estimate " cond(`df'==1, "", "matrix ") "is not positive" cond(`df'==1, "", "-definite") "."
		}
		cap mat colnames `b0' = `h0text'
		cap mat colnames `V0' = `h0text'
		cap mat rownames `V0' = `h0text'
    cap return matrix b`_h' = `b0'
		cap return matrix V`_h' = `V0'

		cap confirm mat `plotmat'
		if _rc == 0 {
			tempvar X1 Y _plotmat
			mat `_plotmat' = `plotmat'
			return matrix plot`_h' = `plotmat'
			mat `plotmat' = `_plotmat'

			if "`graph'"=="" {
				cap confirm matrix `peakmat'
				if !_rc {
					mata st_matrix("`plotmat'", st_matrix("`plotmat'") \ st_matrix("`peakmat'"))
					return matrix peak`_h' = `peakmat'
				}
				cap confirm matrix `cimat'
				if _rc mat `_plotmat' = `plotmat'
				else {
					mata st_matrix("`_plotmat'", st_matrix("`plotmat'") \ ((st_matrix("`cimat'")[,1] \ st_matrix("`cimat'")[,2]), J(2*`=rowsof(`cimat')', 1, 1-`level'/100)))
				}

        if colsof(`_plotmat')==3 tempvar X2
				mat colnames `_plotmat' = `X1' `X2' `Y'
				local _N = _N
        qui svmat `_plotmat', names(col)
				label var `Y' " "  // in case user turns on legend
				if `"`graphname'"'=="Graph" cap graph drop Graph`_h'

				if colsof(`_plotmat')==2 {
        	cap mata st_local("nonmiss", strofreal(nonmissing(st_matrix("`cimat'"))))
          if 0`nonmiss' > 1 {
            mata _boottestm = (-min(-st_matrix("`cimat'")) - min(st_matrix("`cimat'"))) / 2 / (`nonmiss' + 1)  // margin
            mata _boottestt = min(select(st_matrix("`plotmat'")[,1], st_matrix("`plotmat'")[,1] :> max(st_matrix("`cimat'")) + _boottestm)); st_local("plotmax", rows(_boottestt)? strofreal(_boottestt * (1 + sign(_boottestt)*1e-6)) : .)
            mata _boottestt = max(select(st_matrix("`plotmat'")[,1], st_matrix("`plotmat'")[,1] :< min(st_matrix("`cimat'")) - _boottestm)); st_local("plotmin", rows(_boottestt)? strofreal(_boottestt * (1 - sign(_boottestt)*1e-6)) : .)
          }
          else {
          	local plotmin .
            local plotmax .
          }
          
					format `X1' `X2' %5.0g

					local 0, `graphopt'
					syntax, [LPattern(passthru) LWidth(passthru) LColor(passthru) LStyle(passthru) *]

					line `Y' `X1', sort(`X1') `lpattern' `lwidth' `lcolor' `lstyle' || scatter `Y' `X1' if _n>rowsof(`plotmat'), mlabel(`X1') mlabpos(6) mlabformat(`format') xtitle("`constraintLHS1'") ///
            || if (`gridmin'<. | -`X1'<=-`plotmin') & (`gridmax'<. | `X1'<=`plotmax'), ///
						ytitle(`"`=strproper("`madjust'") + cond("`madjust'"!="","-adjusted ", "")' p value"') ///
						yscale(range(0 .)) name(`graphname'`_h', `replace') ///
						`=cond(`level'<100, "yline(`=1-`level'/100') ylabel(#6 `=1-`level'/100')", "")' legend(off) `options'
				}
				else {
					foreach var in Y X1 X2 {
						if "``var''" != "" {
							cap drop _boottest``var''
              ren ``var'' _boottest``var'' // work-around for bug in twoway contour, rejecting temp vars
							local `var' _boottest``var''
						}
					}
					c_local contourvars `Y' `X1' `X2' // pass these to calling program for dropping in case twoway contour crashes
					
					twoway contour `Y' `X2' `X1' if _n<=rowsof(`plotmat'), xtitle("`constraintLHS1'") ytitle("`constraintLHS2'") ///
						ztitle(`"`=strproper("`madjust'")+ cond("`madjust'"!="","-adjusted ", "")' p value"', orient(rvert)) ///
						name(`graphname'`_h', `replace') crule(linear) scolor(gs5) ecolor(white) ccut(0(.05)1) plotregion(margin(zero)) /// // defaults copied from weakiv
						`graphopt'
				}
        qui keep in 1/`_N'
			}
		}

		cap confirm mat `cimat'
		if _rc==0 {
			di _n as res `level' "%" as txt " confidence set for null hypothesis expression: " _c
      local CIstr
      local infty = cond(c(stata_version)>=14, "∞", ".")
      local neginfty = cond(c(stata_version)>=14, "-∞", ".")
      local union = cond(c(stata_version)>=14, "∪", "U")
			forvalues i=1/`=rowsof(`cimat')' {
				if `i'>1 local CIstr = "`CIstr' `union' "
				local CIstr = "`CIstr'" + cond(`cimat'[`i',1]==., "(`neginfty'", "[" + strofreal(`cimat'[`i',1], "`format'")) + ", " + cond(`cimat'[`i',2]==., "`infty')", strofreal(`cimat'[`i',2], "`format'") + "]")
			}
      local CIstr = subinstr("`CIstr'", "-", "−", .)  // proper minus sign
			di as res "`CIstr'"

			if inlist("`ptype'", "symmetric", "equaltail") {
				tempname t
				mata st_numscalar("`t'", anyof(st_matrix("`cimat'"), .))
				if `t' di "(A confidence interval could not be bounded. Try widening the search range with the {cmd:gridmin()} and {cmd:gridmax()} options.)"
			}
			mat colnames `cimat' = lo hi
      cap mat rownames `cimat' = `h0text'
			return matrix CI`_h' = `cimat'
			return local CIstr`_h' `CIstr'
		}
		
		if "`statistic'" == "c" & `df'==1 {
			di "Note: denominator for `tz' statistic computed from the bootstrap replications of the numerator."
		}
		
		return scalar `=cond(`small', "F", "chi2")'`_h' = cond(`df'==1, `teststat'*`teststat', `teststat')
		if `small' return scalar df_r`_h' = `df_r'
		return scalar df`_h' = `df'
		return scalar p`_h' = `p'
		if `hasrobust' return local robust robust
		if "`svmat'"!="" return matrix dist`_h' = `dist'
    if "`svv'" != "" return matrix v`_h' = `svv'
	}  // loop over independent H0s

  cap mat_put_rr `C'  // can fail in boottest, margins
	return scalar level = `level'
	return scalar ptol = `ptolerance'
	return local statistic `statistic'
	return local weighttype `weighttype'
	return local boottype `boottype'
	return local clustvars `clustvars'
	return scalar null = `null'
	return scalar reps = `repsname'
  return scalar NH0s = `N_h0s'
end


* Version history
* 4.4.4 Increase WildBootTests.jl version 0.9.0. Fixed bug in WRE jk test stat computation when clusters are many ("granular"). Changed ptol() default to 1e-3. Fixed computation bug in WRE with classical errors.
*       Correct dof when constraints include restrictions on o. and b. regressors
* 4.4.3 Fixed bug in WRE jackknife test stat computation when clusters are many ("granular"). Changed ptol() default to 1e-3. Fixed computation bug in WRE with classical errors.
* 4.4.2 Fixed wrong "robust" CI's after OLS
* 4.4.1 Fixed crash in AR test after over-ID'd regression; added mention of jackknifing to output
* 4.4.0 Minimized O(N) operations in non-jk WRE when clustering is coarse. Skip FE code in WRE if FE = cluster grouping. Bumped Julia version to 0.8.5.
* 4.3.1 Bumped Julia version to 0.8.3. Check for Python 2. Restored code path of memory-intensive granular WRE computation of denominator.
* 4.3.0 Added jackknife for WRE; fixed failure to detect constant term after ivreg; fixed incorrect computation in "WUE"
* 4.2.1 jk bug fixes
* 4.2.0 Added jackknife (WCU/WCR_31) for OLS and Anderson-Rubin
* 4.1.1 Made margins option honor if/in clause in margins call. Clarifed in help that margins option is only for linear predictions.
* 4.1.0 Added format option.
* 4.0.5 Fixed bugs in support for xtivreg2. Moved to WildBootTests version 0.7.13.
* 4.0.4 Fixed Julia crash. Moved to WildBootTests version 0.7.11.
* 4.0.3 Bumped WildBootTests version to 0.7.10. Fixed failure to incorporate constraints into dof calculation for small-sample correction
* 4.0.2 Fixed bugs in Julia installation.
* 4.0.1 Bumped WildBootTests version to 0.7.8. Added messages about installation process.
* 4.0.0 Added Julia support. Fixed plotting bug in artest with >1 instrument. Added sensitivity to (iv)reghdfe's e(df_a) return value.
* 3.2.6 For tests of dimension > 2 return symmetric r(V), not upper triangle; fixed crash in WRE with matsizegb() and obs weights; added support for one-way FEs based on interactions in reghdfe
* 3.2.5 Added nosmall option and check for missing sample marker
* 3.2.4 Fixed bug in test statistic in no-null tests after IV/GMM. Fixed Fuller adjustment always being treated as 1. Fixed bad value in lower left corner of contour plots.
*       Fixed crash in WRE for hypotheses involving exogenous vars
*       Prevented crash after margins, post.
*       Label result matrices with hypothesis text. Return r(NH0s).
*       Fixed 3.2.2 crash after xtreg with if, in, or weights clause
* 3.2.3 After (xt)didregress, default to testing treatment effect; Fixed bug in pXB(). Properly handle nointeract, nogteffects, aggmethod options of (xt)didregress.
* 3.2.2 Add didregress, xtdidregress support. After xtXXX estimation, emulate those commands in not counting FE in dof adjustment, unless "xtreg, dfadj"
* 3.2.1 Prevent it from expanding data set when number of points in graph exceed # of rows in data set
* 3.2.0 Added margins option
* 3.1.4 Fixed crashes with matsizegb() and with "granular" (many-clustered) FE estimates with FE & cluster groups coherent
* 3.1.3 Fixed crash on stat(c) after OLS
* 3.1.2 Incorporated small-sample factor in r(dist)
* 3.1.1 Minor bug fixes and speed-ups
* 3.1.0 Complete overhaul of WRE for ~200X speed gain. Dropped GMM support. Added support for ivreg2's partial().
* 3.0.2 Dropped "KK" calculation (last expression in eq 60 in paper) because inefficient when interpolating. Refined plotting to minimize interpolation anchor resets. Refined criterion to use "granular"-optimized code (many small clusters).
* 3.0.1 Recompiled in Stata 13
* 3.0.0 Exploit linearity/quadratic form in denominators too. ~10X speed-up over 2018 version for inverting tests after OLS.
* 2.8.1 Fix 2.8.0 bugs. Even more fully exploit linearity in test stat numerators, for ~2X speed gain in inverting test after OLS.
* 2.8.0 More fully exploit linearity of numerators and K matrices as in appendix A.2. Recenter classical score test even for non-OLS, reversing 2.4.1 change. Added ptolerance() option.
* 2.7.4 Fixed errors affecting results after GMM
* 2.7.3 Prevented crash on WRE bootstrap-t with svmat(numer)
* 2.7.2 Added error check for absorbed interaction terms in (iv)reghdfe
* 2.7.1 Fixed crash after IV without clustering. Added check for regress with undocumented IV syntax. Fixed crash on 2-D test with "nonull" but not "nograph".
* 2.7.0 Require Stata 13 or later, so no need to work around possible lack of panelsum()
* 2.6.0 Added svv option.
* 2.5.7 If lusolve() fails on non-invertible matrix, resort to invsym() for generalized inverse.
* 2.5.6 Fixed 2.4.0 bug: look in e(df_a_initial) rather than e(df_a). Matters if clustering on the absorbed var.
* 2.5.5 Fixed wrong results when absorbed variable is type string
* 2.5.4 Added support for ivreghdfe
* 2.5.3 Fixed crash in score test (including waldtest) after "robust" estimation without observation weights
* 2.5.2 More graceful handling of degenerate cases: multiway t stat = .; test hypothesis refers to dropped/constrained variable
* 2.5.1 Fixed 2.5.0 bug after "robust" estimation
* 2.5.0 Added bootstrap-c. Fixed bug affecting results from WCU when using Mammen/Rademacher/Webb and Rademacher universe not exhausted; doubles test stat in published Conley & Tabor reanalysis.
* 2.4.3 minor bug fixes and edits
* 2.4.2 Fixed 2.4.1 bug. Added r(b) and r(V) return values.
* 2.4.1 Optimized classical tests; removed bug in score test after FE est (wrongly droped term 2 in (63) in non-classical use of score test)
* 2.4.0 After reghdfe look for FE count in e(df_a) as well as e(K1)
* 2.3.9 Prevented crash in pure "robust" non-WRE
* 2.3.8 Prevented crash when it can't recompile boottest.mata; instead issues an explanatory warning
* 2.3.7 Fixed crash after tobit estimation in Stata 15
* 2.3.6 Fixed crash in score test/bootstrap with multiple independent hypotheses
* 2.3.5 Fixed stupid 2.3.4 crash
* 2.3.4 Dropped "Rejection" from axis labels. Added check for right number of entries in gridmin(), gridmax(), gridpoints().
* 2.3.3 Eliminated false warning that neg Hessian not pos def when a parameter is constrained to 0 in model
* 2.3.2 Fixed 2.2.0 crash when errors are non-robust
* 2.3.1 Fixed 2.2.0 bug--left behind temporary variables
* 2.3.0 Removed optimization hacks from WRE code because they created matrices with 1 row per obs and 1 col per replication
* 2.2.2 Allowed quietly option in ado interface to suppress dots. Made sorts in Mata code stable.
*       For LIML, reverted to finding eigenvalue of I-TT/TPZT instead of TT/TPZT; seems to avoid instances of eigensystem() returning all missing
* 2.2.1 Fixed failure to detect # of FE after areg in Stata version < 15
* 2.2.0 Added contour plotting for 2-D tests.
* 2.1.9 Work-around for Stata crash when number of fixed effects is very large: require # of FE as input, and don't represent them as linked list.
* 2.1.8 Fixed 2.1.6 crash with FE. Fixed parsing of matsizegb() option.
* 2.1.6 Changed to faster computation for WCR with many clusters, but not quite WB. In multiway only applies to intersection of all clusters.
* 2.1.4 Fixed CI scaling issue introduced in 2.0.5 that affects scoretest, waldtest
* 2.1.3 Fixed crash on testing of multiple independent hypotheses on ML models
*       Added more return values and Roodman et al. cite to help file. Blocked warning about \alpha(B+1) being an integer for Rademacher with <=12 groups.
* 2.1.2 Fixed error in removing half-counting of ties in 2.0.6
*       Stopped crashes after mlogit (and probably other mlogit and mprobit commands)
* 2.1.1 Fixed failure to detect FE variable after xtreg, fe cluster()
* 2.1.0 Added matsizegb feature.
*       Fixed 2.0.6 failure to subtract 1 from Mammen, Webb weights in WRE non-AR
*       Fixed failure in subcluster bootstrap to sort data by error clusterings before bootstrap clustering
*       Avoided creating diagonal/sparse crosstab matrix
*       Terminate search for CI bounds when bracketing p values are within 1/reps (2/reps for equaltail), with 1 last linear interpolation, rather than find precise step-up point, which not so meaningful
*       Fixed minor new bugs when using Mata interface
* 2.0.6 Stopped (half-)counting ties. Changed default reps from 1000 to 999. Fixed swapped labeling of equal-tail and symmetric p-values(!).
* 2.0.5 Fixed subcluster bootstrap bugs: need to sort data even when c=1; don't falsely flag pure-robust case in WB subcluster
*       Fixed possible failure to find graph bounds when many replications infeasible and bounds not manually set
*       Fixed crash in FE estimation when FE cluster = error cluster
*       Accelerated generation of some wild weights by exploiting fact that results are invariant to rescaling of the weights
*       Finally optimized CI construction for nonull case.
*       Made default plot bounds more symmetric.
* 2.0.4 Made "unrestricted WRE" (WUE?) work.
* 2.0.3 Added automatic reporting of any infeasible replication statistics in multi-way clustering. Made r(reps) return value reflect possible reduction to 2^G.
* 2.0.2 Dropped citations from output but added reporting of weight type. Added warning if alpha*(B+1) not integer. Sped up Webb weight generation.
*       If seed() not specified, then return c(seed) in r(seed). For waldtest, nograph just compute CI analytically.
*       Prevented WRE crash when no clustering.
* 2.0.1 Reworked info matrix construction and organization to fix 2.0.0 bug in "subcluster" bootstrapping
* 2.0.0 Implemented code optimized for pure robust case. Allowed bootstrapping clusters to be chosen arbitrarily, independent of error clusterings.
* 1.9.7 Fixed crash on score bootstrap without observation weights. Improved run time when clusters are many by avoiding computation of Q'Q.
*       Fixed failure to recenter score test (not score bootstrap); bug introduced circa 1.9.0. Fixed failure to square t/z to make r(F)/r(chi2).
*       Fixed 1.9.6 bug causing normal weights to be replace by Mammen weights.
* 1.9.6 Added Gamma(4, .5) - 2 wild weight distribution option per Liu (1988)
* 1.9.5 Fixed score test bugs from 1.9.0, and bugs after ML estimation in Stata 15 because of new free parameter matrix label system
* 1.9.4 Cleaned up display of results for symmetric, equal-tail, etc.
* 1.9.3 Tweaked to no longer explode wild weights in multiway clustering; not needed since 1.9.0
* 1.9.2 Fixed crash with FE and omitted dummies for other vars. Fixed 1.9.0 crash in old Stata versions.
* 1.9.1 Fixed crash with FE and df>1. Stopped waldtest and scoretest ignoring small
* 1.9.0 Added fixed effect support
* 1.8.3 Added svmat(numer) option
* 1.8.2 Fixed bug after ML: was using V from unconstrained instead of constrained fit
* 1.8.1 Fixed bugs in handling robust non-cluster
* 1.8.0 Reworked multiway clustering to first collapse data to one obs per all-cluster-var intersections.
*       Reworked test stat computation for df>1 to mostly iterate over constraints rather than replications. Speeds AR test too.
* 1.7.1 Changed residual dof for multi-way clustered, small-sample-corrected models to smallest number of groups across grouping variables
* 1.7.0 Made bootcluster() accept more than one variable. Fixed error causing it to always bootstrap on combination of all vars in multi-way clustered models.
* 1.6.2 Fixed ado bug in 1.6.1
* 1.6.1 Fixed AR test crash. Dropped nowarning in favor of capture because commands such as poisson don't accept it. Changed left and right to lower and upper. Fixed bugs.
*       Suppressed non-concavity warning when imposing null after ML that was incorrectly triggered by omitted factor variables.
* 1.6.0 Added left and right p value types. Added cmdline option. Added nowarning option to ml, iter(0) call to suppress non-convergence warning.
* 1.5.7 renamed _selectindex() to boottest_selectindex() to reduce conflicts with old cmp versions
* 1.5.6 Fixed crash on waldtest after ML
* 1.5.5 Fixed bug in determining confidence intervals when some test results is missing.
* 1.5.4 Fixed two bugs causing crashes after GMM estimation
* 1.5.3 Simplify _selectindex(). Switch from invt() to invttail() since invt() added in Stata 13. Work around Mata garbage-collecting bug.
* 1.5.2 Switch from "[]" to "{}" in multiple hypothesis syntax. Prevent crashes if hypothesis applies to constrained/dropped parameter, or in non-robust ML.
* 1.5.1 Make wrapper accept level() and graphname(). Handle graphopt() options relevant for format of line.
* 1.5.0 Added Anderson-Rubin test, new null hypothesis syntax, multiple hypothesis testing and corrections thereof
* 1.4.0 Added WRE for LIML, sped up WRE, k-class and Fuller support after ivreg2
* 1.3.1 Bug fixes in WRE with observation weights and no clusters; and in clustered non-ML estimation with time series operators
*       Added level(100) option to disable plotting of CI's
* 1.3.0 Implemented Davidson & MacKinnon WRE. Bug fixes affecting non-robust fweight, weighted OLS/2SLS/GMM when null imposed
* 1.2.5 Added stable option to sort by cluster, for stability of results
* 1.2.4 More thorough clean-up of fv handling.
* 1.2.3 Fixed bug in search for upper bound of CI
* 1.2.2 Fixed bug in handling of fv base vars in non-ML estimation
* 1.2.1 LIML bug fixes.
* 1.2.0 Added svmat option. LIML support. Fixed bug in handling of weights. Replaced ci option with noci.
* 1.1.6 Fixed minor 1.1.4 and 1.1.5 bugs.
* 1.1.5 After ML estimation, don't restrict to sample until after scores generated, in case of ts ops
* 1.1.4 Erase old mlib before compiling new one. Don't recenter Z'e inside sandwich if not bootstrapping.
* 1.1.3 Fixed bug in multiway cluster ci's. Made compatible with estimation commands whose constraints() option only accept numlists. Drop out-of-sample obs *after* predicting scores.
* 1.1.2 Force use of score bootstrap after 2SLS/GMM. Thanks to Federico Belotti.
* 1.1.1 Added support for single-equation linear GMM with ivreg2 and ivregress.
* 1.1.0 Fixed 1.0.1 bug in observation weight handling. Added multiway clustering, robust, cluster(), and bootcluster() options. Added waldtest wrapper.
* 1.0.1 Added check for empty constraints. Fixed crash on use of weights after clustered estimation in Stata >13.
