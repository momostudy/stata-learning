*! cmp 8.7.3 21 July 2022
*! Copyright (C) 2007-22 David Roodman

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.

cap program drop cmp_p
program define cmp_p
	version 11.0
	syntax anything [if] [in], [EQuation(string) Outcome(string) /*FIXEDonly RELevel(string)*/ xb NOOFFset e pr REsiduals lnl SCores Ystar(string) REDucedform CONDition(string) *]
	marksample touse, novarlist
	local _pr `pr'
	local _e `e'
	local 0, `options'
	syntax, [pr(string) e(string) *]
	if "`pr'"!="" & `"`outcome'"'!="" {
		di as error "{cmd:pr(`pr')} incompatible with {cmd:outcome(`outcome')}."
		exit 198
	}
	if "`e'"!="" & `"`outcome'"'!="" {
		di as error "{cmd:e(`e')} incompatible with {cmd:outcome(`outcome')}."
		exit 198
	}

	if `: word count `xb' `_pr' `_e' `residuals' `scores' `lnl'' + (`"`pr'"'!="") + (`"`ystar'"'!="") + (`"`e'"'!="") > 1 {
		di as err "Only one statistic allowed per {cmd:predict} call."
		exit 198
	}

	tempname b
	mat `b' = e(b)
	if "`scores'"=="" mat `b' = `b'[1,1..`=e(k)-e(k_aux)']

	_score_spec `anything', equation(`equation') b(`b')
	if "`s(eqspec)'"=="#1" & `"`equation'`lnl'"'=="" & e(k_dv)>1 di as txt "(equation #1 assumed)"
	local vartype: word 1 of `s(typlist)'
	local _varlist `s(varlist)'
	local _eqspec = subinstr("`s(eqspec)'", "#", "", .)

	quietly if "`scores'`lnl'" != "" {
		if e(L) > 1 {
			di as error "Observation-level likelihoods and scores not defined for random effects/coefficient models."
			exit 111
		}
		if "`lnl'"!="" local _varlist: word 1 of `_varlist'
		foreach var of newlist `_varlist' {
			gen `vartype' `var' = . in 1
		}

		`e(cmdline)' predict(if `touse', `scores'`lnl'(`_varlist') eq(`_eqspec'))
		exit
	}

	tempname num_cuts cat
	if "`pr'`e'" != "" mat `num_cuts' = J(e(k_dv), 1, 0) // for oprobit, pr() or e() with range overrides usage of outcomes' ranges
	else {
		mat `cat' = e(cat)
		mat `num_cuts' = e(num_cuts)
	}

	if ("`pr'"=="" & "`_pr'"!="") | ("`e'`_e'"  =="" & `"`outcome'"'!="") local pr 0 .
	if ("`e'" =="" & "`_e'" !="") | ("`pr'`_pr'"=="" & `"`outcome'"'!="") local e  . .

	tempvar xb
	local _options `options'
	
	if `"`pr'`e'`ystar'"'!="" {
		if `: word count `pr'`e'`ystar'' != 2 {
			di as err "{cmd:pr}, {cmd:e}, and {cmd:ystar} require two arguments, without commas."
			exit 198
		}
		tempname Sigma sig rho
		mat `Sigma' = e(Sigma)
		local ll: word 1 of `pr'`e'`ystar'
		local ul: word 2 of `pr'`e'`ystar'
		cap confirm var `ll'
		local lmissing = _rc & (`ll')>=.
		cap confirm var `ul'
		local umissing = _rc & (`ul')>=.
		if `lmissing' & `umissing' & `"`ystar'"'!="" {
			local e `ystar'
			local ystar
		}
	}
	else if `"`condition'"'!="" {
		di as err "{cmdab:cond:ition} option only compatible with {cmd:pr} and {cmdab:y:star} statistic options."
		exit 198
	}
	if `"`condition'"'!="" {
		tempvar condxb
		tempname condsig
		local 0 `condition'
		syntax anything, EQuation(string)
		local condll: word 1 of `anything'
		local condul: word 2 of `anything'
		if "`condll'`condul'"==".." local condition
		else {
			local condeq `equation'
			_score_spec `condxb', equation(`condeq') b(`b')
			local condeq = substr("`s(eqspec)'", 2, .)
			Predict double `condxb' if `touse', eq(`s(eqspec)') `reducedform'
			scalar `condsig' = sqrt(`Sigma'[`condeq',`condeq'])
		}
	}
	
	if `"`_options'`pr'`residuals'`ystar'`e'"' == "" di as txt "(option xb assumed; fitted values)"
	
	qui if "`e(MprobitGroupEqs)'`e(ROprobitGroupEqs)'"!="" & "`_eqspec'"!="" & "`pr'" !="" {
		tempname t1 t2 d M E ghk2DrawSet pr
		mata `t1' = st_matrix("e(MprobitGroupEqs)"); `t2' = st_matrix("e(ROprobitGroupEqs)")
		mata `t1' = rows(`t1')? (rows(`t2')? `t1' \ `t2' : `t1') : `t2'
		mata `t1' = select(`t1', (`_eqspec' :>= `t1'[,1]) :& (`_eqspec' :<= `t1'[,2]))
		mata st_local("inds", rows(`t1')? invtokens(strofreal(`t1')) : "")
		if "`inds'"!="" {  // specified equation in an mprobit group?
			local lo: word 1 of `inds'
			local hi: word 2 of `inds'
			local k = `_eqspec' - `lo' + 1  // chosen alternative
			forvalues eq=`lo'/`hi' {
				tempvar xb`eq'
				Predict double `xb`eq'' if `touse', eq(#`eq')  // opposite sign sense from the error terms
			}
			forvalues eq=`lo'/`hi' {
				if `eq' != `_eqspec'  {
					replace `xb`eq'' = `xb`k'' - `xb`eq'' if `touse'  // utility of each alternative relative to chosen one
					local xbs `xbs' `xb`eq''
				}
			}
			
			mata `Sigma' = st_matrix("`Sigma'")[|`lo',`lo' \ `hi',`hi'|]
			mata `d' = cols(`Sigma')
			mata _mod = cmp_model(); `M' = _mod.insert(I(`d'-1), `k', J(1, `d'-1, -1))
			mata `Sigma' = `M' ' `Sigma' * `M'  // eq (12) in cmp article
			mata st_view(`E'=., ., "`xbs'", "`touse'")
			if 0`e(ghkdraws)' {
				mata `t1' = select(0..3, ("", "sqrt", "negsqrt", "fl"):=="`e(ghkscramble)'")
				mata `ghk2DrawSet' = ghk2setup(rows(`E'), 0`e(ghkdraws)', `d', "`e(ghktype)'", 1, (NULL, &ghk2SqrtScrambler(), &ghk2NegSqrtScrambler(), &ghk2FLScrambler())[1+`t1'])
			}
			else mata `ghk2DrawSet' = .
			gen `vartype' `_varlist' = . in 1
			mata st_view(`pr'=., ., "`_varlist'", "`touse'")
			mata `pr'[,] = _mod.vecmultinormal(`E', J(0,0,0), `Sigma', cols(`Sigma'), J(1,0,0), ., 0, `t1', `t1', `t1', `ghk2DrawSet', 0`e(ghkanti)', ., .)
			mata mata drop `t1' `d' `M' `E' `ghk2DrawSet' `pr'
			exit
		}
		mata mata drop `t1' `t2'
	}

	tempvar L U phiL phiU PhiL PhiU condU condL xbinormalL_condL xbinormalL_condU xbinormalU_condL xbinormalU_condU binormalL_condL binormalL_condU binormalU_condL binormalU_condU denom
	tokenize `_varlist'
	for`=cond("`_eqspec'"=="", "values eq=1/`e(k_dv)'", "each eq in `_eqspec'")' {
		local depvar: word `eq' of `e(depvar)'
		if `"`pr'`residuals'`ystar'`e'"' == "" {
			Predict `vartype' `1' if `touse', `_options' eq(#`eq') `offset' `reducedform'
		}
		else {
			Predict double `xb' if `touse', `_options' eq(#`eq') `offset' `reducedform'
			if "`residuals'" != "" {
				gen `vartype' `1' = `depvar' - `xb' if `touse'
				label var `1' Residuals
			}
			else {
				scalar `sig' = sqrt(`Sigma'[`eq',`eq'])
				if `"`condition'"'!="" {
					scalar `rho' = `Sigma'[`eq',`condeq'] / `condsig' / `sig'
					if `rho'==0 & !inlist("`condeq'", "", "`eq'") {
						di _n as res "Warning: conditioning equation #`condeq' for {cmd:e(`e')} option uncorrelated without outcome equation #`eq'."
						di "Conditioning information ignored."
					}
				}
				else scalar `rho' = 1
				if `"`ystar'`e'"' != "" {
					local num_cats = `num_cuts'[`eq',1] + 1
          if `num_cats' > 1 {
            parseoutcome, varname(`1') outcome(`outcome') eq(`eq') num_cats(`num_cats') cat(`cat')
            local outcome `s(outcome)'
          }

          forvalues outno=`=cond(`num_cats'==1, "1/1", cond("`outcome'"!="", "`outcome'/`outcome'", "1/`num_cats'"))' {
            if `num_cats' > 1 {
              local _outno = cond("`outcome'"!="", "", "_`outno'")
              local ll = cond(`outno'>1                  , "[cut_`eq'_`=`outno'-1']_cons", ".")
              local ul = cond(`outno'<=`num_cuts'[`eq',1], "[cut_`eq'_`outno']_cons"     , ".")
            }

            if `"`condition'"'=="" | `"`ll'`ul'"'==".." {  // use simpler formula if conditioning or dependent var unbounded or the two are uncorrelated, or conditioning variable undeclared
              local cond = cond(`"`condition'"'!="", "cond", "")
              qui gen double `L' = ((``cond'll')-``cond'xb')/``cond'sig' if `touse'
              qui gen double `U' = ((``cond'ul')-``cond'xb')/``cond'sig' if `touse'
              qui gen double `phiL' = cond(`L'>=., 0, normalden(`L'))    if `touse'
              qui gen double `phiU' = cond(`U'>=., 0, normalden(`U'))    if `touse'
              qui gen double `PhiL' = cond(`L'>=., 0, normal(   `L'))    if `touse'
              qui gen double `PhiU' = cond(`U'>=., 1, normal(   `U'))    if `touse'
              if `"`e'"'!="" gen `vartype' `1'`_outno' = `xb' - cond(`"`condition'"'=="", `sig', `rho'*`sig') * (`phiU'-`phiL')/(`PhiU'-`PhiL') if `touse'
              else           gen `vartype' `1'`_outno' = (`PhiU'-`PhiL')*`xb'-`sig'*(`phiU'-`phiL')+cond((`ll')>=.,0,`PhiL'*(`ll'))+cond((`ul')>=.,0,(1-`PhiU')*(`ul')) if `touse'
              drop `L' `U' `phiL' `phiU' `PhiL' `PhiU'
            }
            else {
              qui gen double `L' = ((`ll')-`xb')/`sig' if `touse'
              qui gen double `U' = ((`ul')-`xb')/`sig' if `touse'
              qui gen double `condU' = ((`condul')-`condxb')/`condsig' if `touse'
              qui gen double `condL' = ((`condll')-`condxb')/`condsig' if `touse'
              xbinormal `U' `condU' + + `rho' `xbinormalU_condU'       if `touse'
              xbinormal `U' `condL' + - `rho' `xbinormalU_condL'       if `touse'
              xbinormal `L' `condU' - + `rho' `xbinormalL_condU'       if `touse'
              xbinormal `L' `condL' - - `rho' `xbinormalL_condL'       if `touse'
               binormal `U' `condU' + + `rho'  `binormalU_condU'       if `touse'
               binormal `U' `condL' + - `rho'  `binormalU_condL'       if `touse'
               binormal `L' `condU' - + `rho'  `binormalL_condU'       if `touse'
               binormal `L' `condL' - - `rho'  `binormalL_condL'       if `touse'

              if `"`e'"'!="" {
                gen `vartype' `1'`_outno' = `xb' - `sig'*(`xbinormalU_condU' - `xbinormalU_condL' - `xbinormalL_condU' + `xbinormalL_condL') ///
                                                           /  ( `binormalU_condU' - `binormalU_condL' - `binormalL_condU' + `binormalL_condL') if `touse'
              }
              else {
                qui gen double `denom' = cond(`condU'>=., 1, normal(`condU')) - cond(`condL'>=., 0, normal(`condL')) if `touse'
                gen `vartype' `1'`_outno' = `xb' + `sig'*(`xbinormalU_condL' + `xbinormalL_condU' -`xbinormalU_condU' - `xbinormalL_condL' ///
                                                  + `L' * (`binormalL_condU' - `binormalL_condL') ///
                                                  + `U' * (`denom' - `binormalU_condU' + `binormalU_condL')) ///
                                                    / `denom' if `touse'
                drop `denom'
              }
              drop `L' `U' `condU' `condL' `xbinormalL_condL' `xbinormalL_condU' `xbinormalU_condL' `xbinormalU_condU' `binormalL_condL' `binormalL_condU' `binormalU_condL' `binormalU_condU'
            }
            if `num_cats' > 1 label var `1'`_outno' "E(`depvar'*`=cond(`"`e'"'=="","*","")'|`depvar'=`=`cat'[`eq', `outno']')"
              else            label var `1'`_outno' "E(`depvar'*`=cond(`"`e'"'=="","*","")'`=cond(`lmissing' & `umissing', "", "|`=cond(`lmissing', "", "`ll'<")'`depvar'`=cond(`umissing', "", "<`ul'")'")')"
          }
				}
				else if "`pr'" != "" {
					local num_cats = `num_cuts'[`eq',1] + 1
          if `num_cats' > 1 {
            parseoutcome, varname(`1') outcome(`outcome') eq(`eq') num_cats(`num_cats') cat(`cat')
            local outcome `s(outcome)'

            forvalues outno=`=cond("`outcome'"!="", "`outcome'/`outcome'", "1/`num_cats'")' {
              local _outno = cond("`outcome'"!="", "", "_`outno'")
              condpr `xb' `rho' `vartype' `1'`_outno' if `touse', sig(`sig') condll(`condll') condul(`condul') condxb(`condxb') condsig(`condsig') ///
                ll(`=cond(`outno'>1, "[cut_`eq'_`=`outno'-1']_cons", ".")') ///
                ul(`=cond(`outno'<=`num_cuts'[`eq',1], "[cut_`eq'_`outno']_cons", ".")') 
              label var `1'`_outno' "Pr(`depvar'=`=`cat'[`eq', `outno']')"
            }
					}
					else if `"`outcome'"' == "" {
						if `"`condition'"'=="" & `"`pr'"'=="0 ." {
							gen `vartype' `1' = normal(`xb' / sqrt(`Sigma'[`eq',`eq']))
							label var `1' "Pr(`depvar')"
						}
						else {
              condpr `xb' `rho' `vartype' `1' if `touse', sig(`sig') condll(`condll') condul(`condul') condxb(`condxb') condsig(`condsig') ll(`ll') ul(`ul')
              label var `1' "Pr(`=cond(`lmissing' & `umissing', "`depvar'>0", "`=cond(`lmissing', "", "`ll'<")'`depvar'`=cond(`umissing', "", "<`ul'")'")')"
            }
					}
					else {
						di as err "Equation #`eq' is not ordered probit. outcome() is not allowed."
						exit 197
					}
				}
			}
			drop `xb'
		}
		macro shift
	}
end

cap program drop parseoutcome
program define parseoutcome, sclass
  version 11.0
  syntax, [varname(string) outcome(string) eq(string) num_cats(string) cat(string)]

  if `"`outcome'"' == "" {
    _stubstar2names `varname'_*, nvars(`num_cats') outcome  // just for error checking?
  }
  else {
    if substr(`"`outcome'"', 1, 1) == "#" {
      local outcome = substr(`"`outcome'"', 2, .)
      if `outcome' > `num_cats' {
        di as err `"There is no outcome #`outcome'. There are only `num_cats' outcomes for equation #`eq'."'
        exit 111
      }
    }
    else {
      local i 1
      while `i' <= `num_cats' & `cat'[`eq', `i'] != `outcome' {
        local ++i
      }
      if `i' > `num_cats' {
        di as error `"Outcome `outcome' not found in equation `eq'. outcome() must either be a value of `depvar' or #1, #2, ..."'
        exit 111
      }
      local outcome `i'
    }
  }
  sreturn local outcome `outcome'
end


cap program drop Predict
program define Predict, eclass
	version 11.0
	
	syntax anything [if], [eq(string) reducedform *]
	local hasGamma = e(k_gamma) & "`options'"!="scores"
	if `hasGamma' {
		tempname b V N hold hold2 _p
		if "`reducedform'"!="" | strpos("`:coleq e(b)'", "gamma"+substr("`eq'",2,.)) {
			di "(using reduced-form results for predictions)"
			mat `b' = e(br)
			mat `V' = e(Vr)
			local colnamesr: colnames e(br)
			forvalues i=1/`e(k)' { // if margins has hacked e(b) colnames to point to temporary vars, copy substitutions to e(br)
				local colnamesr: subinstr local colnamesr "`:word `i' of `:colnames e(bs)''" "`:word `i' of `:colnames e(b)''", all word
			}
			scalar `N' = e(N)
			_estimates hold `hold', restore
			ereturn post `b' `V', obs(`=`N'') esample(`hold') // pass around sample marker without duplicating it
			mat `b' = e(b)
			mat colnames `b' = `colnamesr'
			ereturn repost b=`b', rename
		}
		else {
			_estimates hold `hold', copy restore
			mat `b' = e(b)
			mat `V' = e(V)
			mata `_p' = st_matrix("e(_p)"); st_matrix("`b'", st_matrix("`b'")[`_p']); st_matrix("`V'", st_matrix("`V'")[`_p',`_p'])
			mata mata drop `_p'
			ereturn repost b=`b' V=`V'
			mat `b' = e(b)
			mat colnames `b' = `e(params)'
			ereturn repost b=`b', rename
		}
	}

	/*qui*/ ml_p `anything' `if', `options' equation(`eq') `=cond("`options'"=="scores", "missing", "")'

	if `hasGamma' {
		_estimates hold `hold2'
		_estimates unhold `hold'
		ereturn repost, esample(`hold2')
	}
end

// Call binormal, dealing with missing coordinates
// Arguments: x y xsign ysign rho newvarname [if]
// xsign, ysign = +/-, indicating whether to interpret . as +/-infinity
cap program drop binormal
program define binormal
	version 11
	args x y xsign ysign rho newvarname
	syntax anything [if]
	qui gen double `newvarname' = cond(`x'>=., ///
	                                     cond("`xsign'"=="-", ///
                                              0, ///
                                              cond(`y'>=.,  ///
                                                "`ysign'"=="+", ///
																						 normal(`y') ///
																					     ) ///
																		    ), ///
                                        cond(`y'>=., ///
																		       cond("`ysign'"=="-", ///
																					        0, ///
																		              normal(`x') ///
																					     ), ///
																					 binormal(`x',`y',`rho') ///
																		    ) ///
                                    ) `if'
end

// Integral of xPr[x,y] over quarter plane, corresponding to binormal()'s integral of Pr[x,y] over quarter plane
// For efficiency, returns the negative of the integral
// Arguments: x y xsign ysign rho newvarname [if]
// xsign, ysign = +/-, indicating whether to interpret . as +/-infinity
// Equation can be found in Rosenbaum (1961), JRSS B, eq 1.
cap program drop xbinormal
program define xbinormal
	version 11
	args x y xsign ysign rho newvarname
	syntax anything [if]
	tempname c
	scalar `c' = 1/sqrt(1-`rho'*`rho')
	qui gen double `newvarname' = cond(`x'>=., ///
	                                     cond(-("`xsign'"=="-"), ///
                                              0, ///
													                 cond(`y'>=.,  ///
																					        0, ///
																									`rho'*normalden(`y') ///
																					     ) ///
																		    ), ///
                                        cond(`y'>=., ///
																		       cond(-("`ysign'"=="-"), ///
																					        0, ///
																		              normalden(`x') ///
																					     ), ///
																					 normalden(`x')*normal((`y'-`rho'*`x')*`c') + `rho'*normalden(`y')*normal((`x'-`rho'*`y')*`c') ///
																		    ) ///
                                    ) `if'
end

// compute Pr[a<x<b | c<z<d]
cap program drop condpr
program define condpr
	version 11
	args xb rho newvartype newvarname
	syntax anything [if], ll(string) ul(string) sig(string) [condll(string) condul(string) condxb(string) condsig(string)]
	tempvar L U condL condU binormalL_condL binormalL_condU binormalU_condL binormalU_condU
  qui gen double `L' = ((`ll') - `xb') `=cond(`sig' != 1, "/ `sig'", "")' `if'
  qui gen double `U' = ((`ul') - `xb') `=cond(`sig' != 1, "/ `sig'", "")' `if'  	
	if `"`condll'"' == "" {
		gen `newvartype' `newvarname' = cond(`U'>=., 1, normal(`U')) - cond(`L'>=., 0, normal(`L')) `if'
	}
	else {
		qui gen double `condL' = ((`condll')-`condxb')/`condsig' `if'
		qui gen double `condU' = ((`condul')-`condxb')/`condsig' `if'
		binormal `U' `condU' + + `rho' `binormalU_condU' `if'
		binormal `U' `condL' + - `rho' `binormalU_condL' `if'
		binormal `L' `condU' - + `rho' `binormalL_condU' `if'
		binormal `L' `condL' - - `rho' `binormalL_condL' `if'
		gen `newvartype' `newvarname'  = (`binormalU_condU' - `binormalU_condL' - `binormalL_condU' + `binormalL_condL') / ///
											                  cond(`condU'>=., cond(`condL'>=., 1, normal(-`condL')), cond(`condL'>=., normal(`condU'), cond(`condL'+`condU'<0, normal(`condU')-normal(`condL'), normal(-`condL')-normal(-`condU')))) `if'
	}
end
