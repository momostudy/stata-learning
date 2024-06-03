*! xtabond2 3.7.0 22 November 2020
*! Copyright (C) 2003-20 David Roodman. May be distributed free.

* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 3 of the License, or
* (at your option) any later version.

* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
* GNU General Public License for more details.

* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses>.

* Version history at bottom

cap program drop xtabond2
program define xtabond2, eclass byable(recall) sortpreserve `=cond(0`c(stata_version)'>=11, "properties(mi)","")'
	version 7
	local xtabond2_version 03.07.00
	if !replay() {
		syntax varlist(fv ts) [aw pw fw] [if/] [in], [noMata Level(real $S_level) *]
		cap fvexpand `varlist'
		if _rc==0 { local varlist `r(varlist)' }
		qui query born
		if "`mata'"=="" {
			if c(stata_version) >= 11.2 {
				local cmdline xtabond2 `0'
				tempname rc
				mata st_numscalar("`rc'",xtabond2_mata())
				if `rc'==0 {
					est local version `xtabond2_version'
					est local cmdline `cmdline'
					xtabond2_output `level'
				}
				exit `=`rc''
			}
		}
		if $S_1 < d(11jun2002) {
			di as err `"Your Stata executable is out of date. Type "update executable" at the Stata prompt and follow the instructions the command displays when finished."'
			exit 498
		}
		if `"`if'"' == "" { local if 1 }
		if _by() { local if (`if') & `_byindex' == `=_byindex()' }
		xtabond2_stata `varlist' [`weight'`exp'] if `if' `in', level(`level') `options'
		est local cmdline xtabond2 `0'
		est local version `xtabond2_version'
		xtabond2_output `level'
	}
	else {
		cap syntax, VERSion
		if _rc {
			if "`e(cmd)'" != "xtabond2" { error 301 } 
			if _by() { error 190 }
			syntax [, Level(real $S_level)]
			xtabond2_output `level'
		}
		else {
			est clear
			est local version `xtabond2_version'
			di as txt "`xtabond2_version'"
		}
	}
end

cap program drop xtabond2_output
program define xtabond2_output
	version 7
	di _n as txt "Dynamic panel-data estimation, " /*
*/				cond("`e(twostep)'" == "", "one", "two") "-step " /*
*/				cond("`e(esttype)'"=="difference", "difference", "system") " GMM" _n "{hline 78}"

	di as txt "Group variable: " as res abbrev("`e(ivar)'", 12) as txt _col(49) "Number of obs      = " as res %9.0f e(N)
	di as txt "Time variable : " as res abbrev("`e(tvar)'", 12) as txt _col(49) "Number of groups   = " as res %9.0g e(N_g)
	di as txt "Number of instruments = " as res e(j) _col(49) as txt "Obs per group: min = " as res %9.0g e(g_min)

	if "`e(small)'" != "" {
	 	di as txt "F(" as res e(df_m) as txt ", " as res e(df_r) as txt ")" _col(15) "= " as res %9.2f e(F) _col(64) as txt "avg = " as res %9.2f e(g_avg)
		di as txt "Prob > F" _col(15) "=" as res %10.3f e(F_p) _col(64) as txt "max = " as res %9.0g e(g_max)
	}
	else {
	 	di as txt "Wald chi2(" as res e(df_m) as txt ")" _col(15) "= " as res %9.2f e(chi2) _col(64) as txt "avg = " as res %9.2f e(g_avg)
		di as txt "Prob > chi2" _col(15) "=" as res %10.3f e(chi2p) _col(64) as txt "max = " as res %9.0g e(g_max)
	}

	if "`e(clustvars)'" != "" {
		di as txt _col(`=60-strlen("`e(clustvars)'")') "(Std. Err. adjusted for clustering on " e(clustvars) ")"
	}
	
	est di, level(`1')

	if "`e(twostep)'" != "" & "`e(vcetype)'" != "Corrected" {
		di "Warning: Uncorrected two-step standard errors are unreliable." _n
      }

	foreach retval in ivequation ivpassthru ivmz gmmequation gmmpassthru gmmcollapse gmmlaglimits gmmorthogonal {
		tempname `retval'
		cap mat ``retval'' = e(`retval')
	}
	local eqname `e(transform)'
	forvalues eq = 0/`="`e(esttype)'"=="system"' {
		local eqnotdisplayed 1
		local insttypedisplay Standard
		foreach insttype in iv gmm {
			local insttypenotdisplayed 1
			local g 1
			local basevars `e(`insttype'insts`g')'
			while "`basevars'" != "" {
				if ``insttype'equation'[1,`g'] != `eq' {
					if `eqnotdisplayed' {
						di as txt "Instruments for `eqname' equation"
						local eqnotdisplayed 0
					}
					if `insttypenotdisplayed' {
						di _col(3) as txt "`insttypedisplay'"
						local insttypenotdisplayed 0
					}
					if "`insttype'"=="iv" {
						if `eq' | `ivpassthru'[1,`g'] {
							local line `basevars'
						}
						else {
							local line `=cond("`eqname'"=="orthogonal deviations","FO","")'D.
							if `:word count `basevars'' > 1 {
								local line `line'(`basevars')
							}
							else local line `line'`basevars'
						}
						local line `line'`=cond(`ivmz'[1,`g'], ", missing recoded as zero", "")'
					}
					else {
						local laglim1 = `gmmlaglimits'[1,`g'] - (`eq' & `gmmequation'[1,`g'])
						local laglim2 = `gmmlaglimits'[2,`g'] - (`eq' & `gmmequation'[1,`g'])
						local line `=cond(!`eq' & `gmmorthogonal'[1,`g'], "BOD.", "")'`=cond(`eq' & !`gmmpassthru'[1,`g'], "D", "")'`=cond(`laglim2'>`laglim1' & (`eq' & `gmmequation'[1,`g'])==0, "L(`laglim1'/`laglim2')", cond(`laglim1', cond(`laglim1'>1, "L`laglim1'", "L"), ""))'.
						if `:word count `basevars'' > 1 {
							local line `line'(`basevars')
						}
						else local line `line'`basevars'
						if `gmmcollapse'[1,`g'] {
							local line `line' collapsed
						}
					}
					local p 1
					local piece: piece 1 74 of "`line'"
					while "`piece'" != "" {
						di as txt _col(5) "`piece'"
						local p = `p' + 1
						local piece: piece `p' 74 of "`line'"
					}
				}
				local g = `g' + 1
				local basevars `e(`insttype'insts`g')'
			}
			local insttypedisplay GMM-type (missing=0, separate instruments for each period unless collapsed)
		}
		local eqname levels
	}
	if `e(j)' != `e(j0)' {
*		di as txt "  (Instrument count reported above excludes " as res `e(j0)'-`e(j)' as txt " of these as collinear.)"
	}
	di as txt "{hline 78}"

	forvalues i = 1/`e(artests)' {
		di as txt "Arellano-Bond test for AR(`i') in `e(artype)':" _col(52) "z = " as res %6.2f e(ar`i') as txt "  Pr > z = " as res %6.3f e(ar`i'p)
	}

	di as txt "{hline 78}" _n "Sargan test of overid. restrictions: chi2(" /*
*/		as res e(sar_df) as txt ")" _col(49) "=" as res %7.2f e(sargan) as txt _col(59) "Prob > chi2 = " /*
*/		as res %6.3f e(sarganp)
	di as txt "  (Not robust, but not weakened by many instruments.)"

	if "`e(twostep)'`e(vcetype)'" != "" {
		di as txt "Hansen test of overid. restrictions: chi2(" /*
*/			as res e(hansen_df) as txt ")" _col(49) "=" as res %7.2f e(hansen) as txt _col(59) "Prob > chi2 = " /*
*/			as res %6.3f e(hansenp)
		di as txt "  (Robust, but weakened by many instruments.)"
	}

	tempname diffsargan d
	cap mat `diffsargan' = e(diffsargan)
	local overidtest = cond("`e(twostep)'`e(vcetype)'"=="", "Sargan", "Hansen")
	if _rc == 0 {
		local options : colnames(`diffsargan')
		forvalues g=1/`= colsof(`diffsargan')' {
			if (`diffsargan'[5, `g'] != .) {
				if "`printed_header'" == "" {
					di _n as txt "Difference-in-`overidtest' tests of exogeneity of instrument subsets:"
					local printed_header = 1
				}
				mat `d' = `diffsargan'[1..., `g']
				di as txt "  `e(diffgroup`g')'"
				di as txt "    `overidtest' test excluding group:" _col(38) "chi2(" as res /*
*/				      e(sar_df) - `diffsargan'[3,`g'] as txt ")" _col(49) "=" as res %7.2f `diffsargan'[1, `g'] as txt _col(59) /*
*/					"Prob > chi2 = " as res %6.3f `diffsargan'[4, `g']
				di as txt "    Difference (null H = exogenous):" _col(38) "chi2(" as res `diffsargan'[3,`g'] as txt ")" _col(49) "=" as res %7.2f `diffsargan'[2,`g'] /*
*/				   as txt _col(59) "Prob > chi2 = " as res %6.3f `diffsargan'[5, `g']
			}
		}
	}

	if "`e(pca)'" != "" {
		di as txt "{hline 78}"
		di as txt "Extracted " as res e(components) as txt " principal components from GMM-style instruments"
		di as txt "  Portion of variance explained by the components = " as res %6.3f e(pcaR2)
		di as txt "  {help pca postestimation##kmo:Kaiser-Meyer-Olkin measure} of sampling adequacy = " as res %6.3f e(kmo)
	}
	
	di
end

cap program drop xtabond2_stata
program define xtabond2_stata, eclass
	version 7
	syntax varlist(ts) [aw pw fw] [if] [in], [Robust TWOstep noConstant noLeveleq ORthogonal ARtests(integer 2) SMall H(integer 3) DPDS2 Level(real $S_level) ARLevels noDiffsargan *]

	local arlevels = "`arlevels'"!=""
	local maineq = "`leveleq'"==""
	local steps = 1 + ("`twostep'"!="")

	if !`maineq' & `arlevels' {
		di as err "The arlevels option is invalid for difference GMM estimation."
		exit 198
	}

	if "`orthogonal'" != "" {
		di as err "The orthogonal option is only available in the Mata version of xtabond2."
		di as err "You need to run xtabond2 without the nomata option, in Stata 10.1 or later."
		exit 198
	}

	if `h'!=1 & `h'!=2 & `h'!=3 {
		di as err `"h(`h') invalid."'
		exit 198
	}

	tokenize `varlist'
	local depvar `1'
	macro shift 
	local xvars_nocons `*'
	local depvarname `depvar'
	tsrevar `depvar'
	local depvar `r(varlist)'

	quietly {

	tsset
	local tmin = r(tmin)
	local tmax = r(tmax)
	local id `r(panelvar)'
	local t `r(timevar)'
	local tdelta `r(tdelta)'
	if 0`tdelta'==0 { local tdelta 1 }

	if "`id'" == "" {
		di as err "You must tsset the data and specify the panel and time variables."
		exit 459
	}

	marksample touse
	markout `touse' `id'
	count if `t' >= .
	if r(N) {
		di as err "Missing values in time variable (`t')."
		exit 459
	}	

	count if `touse'
	if r(N) == 0 {
		di as err "No observations."
		exit 2000
	}

	if "`weight'" != "" {
		local wexp `exp'
		local wtype `weight'
		tempvar wvar
		gen double `wvar' `exp' if `touse'
		if "`weight'" == "fweight" {
			tempvar tmp
			gen `tmp' = D.`wvar' if `touse'
			count if `tmp' < . & `tmp' > 1e-6 & `touse'
			if `r(N)' {
				di as err "Frequency weights must be constant over time for {cmd:xtabond2}."
				exit 101
			}
			local wgtexp [fweight=`wvar']
		}
		else {
			if "`twostep'" == "" & "`weight'" == "pweight" { local robust robust }
			local wtype aweight
			local wgtexp [aweight=`wvar']
		}
		markout `touse' `wvar'
		local iwgtexp [iweight=`wvar']
	}

	preserve

	tempvar numobs
	by `id': egen long `numobs' = sum(`touse')
	keep if `numobs'
	drop `numobs'

/* append second copy of data set to incorporate equation in levels. Variable `eq' indicates whether observations for first difference or levels.*/	

	if `maineq' {
		expand 2
		tempname eq
		gen byte `eq' = _n > _N/2
	}
	else {
		local eq 0
	}

/* t2 contains absolute time variable, going from 1 to t2max.*/
	tempvar id2 t2 ideq
	local t2max = `tmax' - `tmin' + 1
	gen long `t2' = (`t' - `=`tmin' - 1') / `tdelta'
	sum `id', meanonly
	gen double `ideq' = `id' + `eq' * `=r(max) - r(min) + 1'
	tsset `ideq' `t2' /* tsset jointly by id and equation type, so t.s. ops for one equation can't grab data from other */

	tempname ivpassthru ivmz ivequation
	if "`constant'" == "" & `maineq' {
		tempvar cons1 cons1z
		gen byte `cons1' = `eq'
		gen byte `cons1z' = `eq'  /* separate copy in case copy for X is multiplied by weights */
		local consname _cons
		mat `ivpassthru' = 0
		mat `ivmz' = 0
		mat `ivequation' = 0
		local ivinsts1 _cons
		local ivgroups 1
	}
	else {
		local consopt nocons
		local ivgroups 0
	}

	local levelarg `level'
	local levelflag 0
	local diffflag 1
	local bothflag 2
	local 0, `options'
	syntax [, IVstyle(string) *]
	while "`ivstyle'" != "" {
		local optionsarg `options'
		local 0 `ivstyle'
		capture syntax varlist(numeric ts), [Equation(string) Passthru MZ]
		if _rc {
			di as err "ivstyle(`0') invalid."
			exit 198
		}

		local basevars `varlist'
		local 0, `equation'
		capture syntax, [Diff Level Both]
		local check : word count `equation'
		if _rc | `check' > 1 {
			di as err `"equation(`equation') invalid."'
			exit 198
		}
		local equation = cond(`check', "`diff'`level'`both'", "both")
		if !`maineq' & "`equation'" == "level" {
			noi di as txt "Instruments for levels equations only ignored since noleveleq specified."
		}
		else {
			local passthru = "`passthru'" != ""
			local mz = "`mz'" != ""

			if `passthru' & "`equation'" == "both" & `maineq' {
				di as err "passthru not valid with equation(both) in system GMM."
				exit 198
			}

			local ivgroups = `ivgroups' + 1
			local ivinsts`ivgroups' `basevars'
			mat `ivequation' = nullmat(`ivequation'), ``equation'flag'
			mat `ivpassthru' = nullmat(`ivpassthru'), `passthru'
			mat `ivmz' = nullmat(`ivmz'), `mz'
			foreach var of varlist `basevars' {
				tempvar tmp
				local varxformed
				local vartype = reverse("`var'")
				local index = index("`vartype'", ".")
				local vartype : type `=reverse(cond(`index', substr("`vartype'", 1, `index'-1), "`vartype'"))'
				gen `vartype' `tmp' = cond(`eq'==``equation'flag', 0, cond(`eq' | `passthru', `var', D.`var')) if `touse'
				local ivinsts `ivinsts' `tmp'
				if `mz' {
					recode `tmp' . = 0
				}
				else {
					markout `touse' `tmp'
				}
			}
		}
		local 0, `optionsarg'
		syntax [, IVstyle(string) *]
	}	

	/* check for collinearity and difference regressors 	*/
	foreach x of local xvars_nocons {
		tempvar tmp
		local vartype = reverse("`x'")
		local index = index("`vartype'", ".")
		local vartype : type `=reverse(cond(`index', substr("`vartype'", 1, `index'-1), "`vartype'"))'
		gen `vartype' `tmp' = cond(`eq', `x', D.`x') if `touse'
		local xvars `xvars' `tmp'
		markout `touse' `tmp'
	}
	local k : word count `xvars'
	_rmcoll `xvars' if `touse' & `maineq'==`eq', `consopt'
	local xvars_rmcolled `r(varlist)'

	/* drop entries from original regressor list corresponding to transformed vars dropped for collinearity */
	tokenize `xvars'
	forvalues vi = 1/`k' {
		local v_unxformed : word `vi' of `xvars_nocons'
		local tmp : subinstr local xvars_rmcolled "``vi''" "``vi''", word count(local n)
		if `n' {
			local xvars_nocons2 `xvars_nocons2' `v_unxformed'
		}
		else {
			noi di as txt "`v_unxformed' dropped because of collinearity."
		}
	}
	local xvars_nocons `xvars_nocons2'
	local xvars `xvars_rmcolled' `cons1'
	local k : word count `xvars'
	if `k'==0 {
		di as err "No regressors."
		exit 481 
	}

	tempvar yvar
	gen `:type `depvar'' `yvar' = cond(`eq', `depvar', D.`depvar') if `touse'
	markout `touse' `yvar'

	noi di as txt "Building GMM instruments." _c
	tokenize
	local j 1
	local gmmgroups 0
	local 0, `options'
 	syntax [, GMMstyle(string) *]
	tempname gmmpassthru gmmcollapse gmmequation gmmlaglimits gmmorthogonal
	while "`gmmstyle'" != "" {
		local optionsarg `options'
		local 0 `gmmstyle'
		capture syntax varlist(numeric ts), [Equation(string) LAGlimits(string) Collapse Passthru]
		if _rc {
			di as err _n "gmmstyle(`0') invalid."
			exit 198
		}	
		local basevars `varlist'

		local 0, `equation'
		capture syntax, [Diff Level Both]
		if _rc | `: word count `equation'' > 1 {
			di as err _n `"equation(`equation') invalid."'
			exit 198
		}
		mat `gmmequation' = nullmat(`gmmequation'), ``=cond("`equation'"=="", "both", "`diff'`level'`both'")'flag'
		local both = "`diff'`level'" == ""
		local level = "`level'" != ""
		if !`maineq' & `level' {
			noi di as txt _n "Instruments for levels equations only ignored since noleveleq specified."
		}
		else {
			local passthru = "`passthru'" != ""
			local collapse = "`collapse'" != ""
			if `maineq' & `passthru' & `both' {
				di as err _n "passthru not valid with equation(both) in system GMM."
				exit 198
			}
	
			if "`laglimits'" == "" {
				local laglim1 = 1
				local laglim2 = .
			}
			else {
				if `:word count `laglimits'' != 2 {
					di as err _n `"laglimits(`laglimits') must have two arguments."'
					exit 198
				}
				forvalues a = 1/2 {
					capture local laglim`a' = `: word `a' of `laglimits'' + 0
					if _rc {
						di as err _n `"laglimits(`laglimits') invalid."'
						exit 198
					}
				}
				if `laglim1' == . { local laglim1 1 }
				if `laglim1' > `laglim2' {
					local tmp `laglim1'
					local laglim1 `laglim2'
					local laglim2 `tmp'
				}
			}
			local gmmgroups = `gmmgroups' + 1
			local gmminsts`gmmgroups' `basevars'
			mat `gmmcollapse' = nullmat(`gmmcollapse'), `collapse'
			mat `gmmpassthru' = nullmat(`gmmpassthru'), `passthru'
			mat `gmmlaglimits' = nullmat(`gmmlaglimits'), (`laglim1' \ `laglim2')

			local dlag = cond(`laglim1'>0, `laglim1'-1, min(`laglim2'-1, 0))
			local makeextrainsts = `both' & `maineq'
			local fullinstseteq = `level'
			local fullinstsetdiffed = `level' & !`passthru'
			foreach var of varlist `basevars' {
				local vartype = reverse("`var'")
				local index = index("`vartype'", ".")
				local vartype : type `=reverse(cond(`index', substr("`vartype'", 1, `index'-1), "`vartype'"))'
				if `collapse' {
					forvalues lag = `=max(1-`t2max', `laglim1')'/`=min(`t2max'-1, `laglim2')' {
						tempvar `j'
						make_GMM_inst j `j' ``j'' `vartype' `"`=cond(`lag'>=0,"L","F")'`=abs(`lag')'D`fullinstsetdiffed'.`var' if `touse' & `eq'==`fullinstseteq'"'
	
					}
					if `makeextrainsts' {
						tempvar `j'
						make_GMM_inst j `j' ``j'' `vartype' `"`=cond(`dlag'>=0,"L","F")'`=abs(`dlag')'D.`var' if `touse' & `eq'"'
					}
				}
				else {
					forvalues ti = `=2-`maineq''/`t2max' {
						forvalues lag = `=max(`ti'-`t2max', `laglim1')'/`=min(`ti'-1, `laglim2')'{
							tempvar `j'
							make_GMM_inst j `j' ``j'' `vartype' "`=cond(`lag'>=0,"L","F")'`=abs(`lag')'D`fullinstsetdiffed'.`var' if `touse' & `eq'==`fullinstseteq' & `t2'==`ti'"
						}
						if `makeextrainsts' {
							forvalues ti2 = `=cond(`laglim1'>0,"`=`ti'+`dlag''/`t2max'","`=`ti'+`dlag''(-1)`=2-`maineq''")' {
								tempvar `j'
								local oldj `j'
								local dlag2 = `ti2' - `ti'
								make_GMM_inst j `j' ``j'' `vartype' "`=cond(`dlag2'>=0,"L","F")'`=abs(`dlag2')'D.`var' if `touse' & `eq' & `t2'==`ti2'"
								if `j' != `oldj' {
									continue, break  /* found a feasible instrument for levels */
								}
							}
						}
					}
				}
				noi di as txt "." _c
			}
		}
		local 0, `optionsarg'
		syntax [, GMMstyle(string) *]
	}
	local level `levelarg'
	noi di

	if "`options'" != "" {
		di as err "`options' invalid."
		exit 198
	}
	keep if `touse' /* since instruments and first differences computed, don't need more data from excluded observations */
	if !_N {
		di as err "No observations."
		exit 2000
	}	

	sum `yvar' if `eq' == `maineq' `wgtexp', mean
	local N = r(N)
	local Neff `N'
	if "`wtype'" != "" {
		sum `wvar' if `eq'==`maineq', mean
		local wttot = r(sum)
		noi di as txt "(sum of weights is " `wttot' ")"
		if "`wtype'" == "fweight" {
			if `steps'==1 & "`robust'"=="" {
				local Neff `wttot'   /* Effective sample size with fweights = sum of weights only if no clustering */
			}
			else {
				replace `wvar' = `wvar' * (`Neff' / `wttot')
				local wttot `Neff'
			}
		}
		else {
			replace `wvar' = `wvar' / r(mean)
			local wttot `N'
		}
		foreach var in `yvar' `xvars' {
			replace `var' = `var' * `wvar'
		}
	}
	else { local wttot `N' }

	egen long `id2' = group(`id')

 	local j0: word count `*' `ivinsts' `cons1z'
	_rmcoll `*' `ivinsts' `cons1z', noconstant
	local zvars `r(varlist)'
 	local j: word count `zvars'
	if `j' < `k' {
		di as err "Equation not identified. Regessors outnumber instruments."
		exit 481
	}
	if `j' < `j0' {
		noi di as txt `j0'-`j' " instrument(s) dropped because of collinearity."
	}

	replace `t2' = `t2' + `t2max' if `eq' /*now treat levels eqs as for t2=t2max+1 through 2*t2max.*/
	tsset `id2' `t2'
	sum `id2', meanonly
	local N_g `r(max)'
	tempvar count
	by `id2': egen long `count' = sum(`eq'==`maineq' & `touse')
	sum `count', meanonly
	local g_min `r(min)'
	local g_max `r(max)'

	noi di as txt "Estimating."
	tempname b1 V1 A1 A2 sargan hansen Zy V V2 b2 Ze H ZX ZXA VZXA m2VZXA tmp Xw d wHw ZHw V1robust V2robust A1Ze A2Ze ewi sig2 smallcorrection
	tempvar xb e_sq e1 e2 w ewvar etmp

	mat vecaccum `Zy' = `yvar' `zvars', noconstant
	foreach x of local xvars {
		mat vecaccum `tmp' = `x' `zvars', noconstant
		mat `ZX' = nullmat(`ZX') \ `tmp'
	}

	if `h' == 1 {
		mat `H' = I(2 * `t2max')
	}
	else {
		mat `H' = I(`t2max')
		mat `H' = (`H' - (`H'[2..., 1...] \ J(1, `t2max', 0)))
		if `h' == 2 {
			mat `H' = `H'' * `H'
			mat `H' = ((`H', J(`t2max', `t2max', 0)) \ (J(`t2max', `t2max', 0), I(`t2max')))
		}
		else {
			mat `H' = `H', I(`t2max')
			mat `H' = `H'' * `H'
		}
	}

	mat glsaccum `A1' = `zvars' `iwgtexp', group(`id2') row(`t2') glsmat(`H') noconstant
	if diag0cnt(`A1') {
		noi di as txt "Warning: One-step estimated covariance matrix of moment conditions is singular."
		noi di "Using a generalized inverse to calculate optimal weighting matrix for one-step estimation."
		if `h'==3 { noi di "The problem may be that the H used is also singular. Try specifying h(1) or h(2)." }
	}
	mat `A1' = syminv((`A1' + `A1'')/2)
	mat `ZXA' = `ZX' * `A1'
	mat `V1' = `ZXA' * `ZX''
	mat `V1' = syminv((`V1' + `V1'')/2)
	mat `b1' =  `Zy' * (`V1' * `ZXA')'
	est post `b1' `V1', obs(`N') depname(`depvarname')
	mat `b1' = e(b)
	mat `V1' = e(V)
 	_predict double `xb'
	gen double `e1' = `yvar' - `xb'
	if "`wtype'" != "" {
		tempvar we1
		gen double `we1' = `e1' / sqrt(`wvar')
	}
	else { local we1 `e1' }
	sum `we1' if `eq' == (("`dpds2'" != "" | `h'==1) & `maineq')
	scalar `sig2' = (r(Var) * (r(N)-1) + r(N)*r(mean)^2) / `N' / (2 - (`h'==1))
	mat `A1' = `A1' / `sig2'
	mat `V1' = `V1' * `sig2'
	est repost V = `V1'
	mat `V1' = e(V)
	mat vecaccum `Ze' = `e1' `zvars', noconstant
	mat `A1Ze' = `A1' * `Ze''
	mat `sargan' = `Ze' * `A1Ze'

	if "`twostep'`robust'" == "" {
		/*1-step non-robust case: correct H by sig2 too*/
		mat `H' = `H' * `sig2'
	}
	else {
		mat opaccum `A2' = `zvars', group(`id2') opvar(`e1') noconstant
		if "`robust'" != "" { 
			mat `VZXA' = e(V) * `ZX' * `A1'
			mat `V1robust' = `VZXA' * `A2' * `VZXA''
			mat `V1robust' = (`V1robust' + `V1robust'')/2
		}

		/* even in one-step robust case, do two-step to get two-step Sargan */

		mat `A2' = syminv((`A2' + `A2'')/2)
		if diag0cnt(`A2') {
			noi di as txt "Warning: Two-step estimated covariance matrix of moment conditions is singular."
			noi di "Number of instruments may be large relative to number of groups."
			noi di "Using a generalized inverse to calculate " cond(`steps'==2, "optimal weighting matrix for two-step estimation.", /*
*/			          "robust weighting matrix for Hansen test.")
		}

		mat `ZXA' = `ZX' * `A2'
		mat `V2' = `ZXA' * `ZX''
		mat `V2' = syminv((`V2' + `V2'')/2)
		mat `VZXA' = `V2' * `ZXA'
		mat `b2' = `Zy' * `VZXA''
		est repost b=`b2' V=`V2'
		drop `xb'
	 	_predict double `xb'
		gen double `e2' = `yvar' - `xb'
		mat vecaccum `Ze' = `e2' `zvars', noconstant
		mat `A2Ze' = `A2' * `Ze''
		mat `hansen' = `Ze' * `A2Ze'

		if `steps' == 1 {
			est repost b=`b1' V=`V1'
		}
		else {
			if "`wtype'" != "" {
				tempvar we2
				gen double `we2' = `e2' / sqrt(`wvar')
			}
			else { local we2 `e2' }
			sum `we2' if `eq' == (("`dpds2'" != "" | `h'==1) & `maineq')
			scalar `sig2' = (r(Var) * (r(N)-1)+ r(N)*r(mean)^2) / `N' / (2 - (`h'==1))

			if "`robust'" != "" {
			       /* Windmeijer-corrected variance matrix for two-step
				 Need to compute matrix whose jth column is 
					[sum_i Z_i'(xj_i*e1_i'+e1_i*xj_i')Z_i]*A2*Z'e2 (where xj = jth col of X)
				    = sum_i (Z_i'xj_i*e1_i'Z_i*A2*Z'e2 + Z_i'e1_i*xj_i'Z_i*A2*Z'e2).
				    Since e1_i'Z_i*A2*Z'e2 and xj_i'Z_i*A2*Z'e2 are scalars, they can be transposed and swapped with 
				    adjacent terms. So this is:
				      matrix whose jth col is sum_i (e1_i'Z_i*A2*Z'e2 + Z_i'e1_i*e2'Z*A2)Z_i'xj_i
				   =  sum_i (e1_i'Z_i*A2*Z'e2 + Z_i'e1_i*e2'Z*A2)Z_i'X_i
				(Transformation reverse engineered from DPD.) */

				tempname D
				noi di as txt "Computing Windmeijer finite-sample correction." _c
				tempname Ze1 ZXi Zi
				mat `D' = J(`j', `k', 0)
				forvalues i = 1/`N_g' {
					sum `e1' if `id2' == `i'
					if r(N) > 1 {
						mat vecaccum `Ze1' = `e1' `zvars' if `id2' == `i', noconstant
						foreach x of local xvars {
							mat vecaccum `tmp' = `x' `zvars' if `id2' == `i', noconstant
							mat `ZXi' = nullmat(`ZXi') , `tmp''
						}
					}
					else {
						local ee `r(sum)'
						mkmat `zvars' if `id2' == `i', matrix(`Zi')
						mat `Ze1' = `ee' * `Zi'
						foreach x of local xvars {
							sum `x' if `id2' == `i', meanonly
							mat `ZXi' = nullmat(`ZXi') , (`Zi'' * (`r(sum)'))
						}
					}
					mat `D' = `D' + (`Ze1' * `A2Ze') * `ZXi' + (`Ze1'' * `A2Ze'') * `ZXi'
					mat drop `ZXi'
					noi di as txt "." _c
				}
				noi di
				mat `D' = `VZXA' * `D'
				mat `V2robust' = e(V) + `D' * `V1robust' * `D'' + 2 * `D' * e(V)
				mat `V2robust' = (`V2robust' + `V2robust'')/2
			}
		}
	}

	noi di as txt "Performing specification tests."

	mat `V`steps'' = e(V)
	mat `m2VZXA' = -2 * e(V) * `ZX' * `A`steps''
	if  "`wtype'" != "" {
		tempvar e0
		gen double `e0' = `e`steps'' / `wvar'
	}
	else {
		local e0 `e`steps''
	}
	forvalues l = 1/`artests' {
		tempname ar`l' ar`l'p
		gen double `w' = cond(`eq' != `arlevels' | `t' < `=`tmin' + `l'', 0, L`l'.`e0')
		gen double `ewvar' = `w' * `e`steps'' if `eq' == `arlevels'
		sum `ewvar', meanonly
		local ew `r(sum)'
		if `ew' {
			if "`twostep'`robust'" == "" {
				mat glsaccum `wHw' = `w' if `eq' == `arlevels' `iwgtexp', group(`id2') row(`t2') glsmat(`H') noconstant
				foreach z of local zvars {
					mat glsaccum `tmp' = `w' `z' `iwgtexp', group(`id2') row(`t2') glsmat(`H') noconstant
					mat `ZHw' = nullmat(`ZHw'), `tmp'[1,2]
				}
			}
			else {
				by `id2' : egen double `ewi' = sum(`ewvar')
				gen double `etmp' = cond(`ewi' < 0, -`e`steps'', `e`steps'') /* flip signs on two terms at once to ensure ewi always positive */
				replace `ewi' = abs(`ewi') 
				mat vecaccum `ZHw' = `etmp' `zvars' [iweight = `ewi'], noconstant
				mat vecaccum `wHw' = `etmp' `w' [iweight = `ewi'], noconstant
				drop `ewi' `etmp'
			}
			mat vecaccum `Xw' = `w' `xvars' if `eq' == `arlevels', noconstant
 			mat `d' = `wHw' + `Xw' * (`m2VZXA' * `ZHw'' + `V`steps'`robust'' * `Xw'')
			scalar `ar`l'' = `ew' / sqrt(`d'[1,1])
			scalar `ar`l'p' = 2 * normprob(-abs(`ar`l''))
			mat drop `ZHw'
		}
		else {
			scalar `ar`l'' = .
			scalar `ar`l'p' = .
		}
		drop `w' `ewvar'
	}	

	if "`robust'" != "" {
		est repost V = `V`steps'robust'
	}

	keep if `eq' == `maineq'
	_rmcoll `xvars_rmcolled' /* if DIF-GMM or noconstant was specified, yet constant is in regressor column space, bump it out for model fit test */
	local df_m = `: word count `r(varlist)'' - ("`constant'" == "")
	if "`small'" != "" {
		mat `b1' = e(b)
		mat `V1' = e(V) * cond(`steps'==1 & "`robust'"=="", `N'/(`N'-`k'), `N'/(`N'-`k'+1)*`N_g'/(`N_g'-1))
		scalar `sig2' = `sig2' * `wttot'/(`wttot' - `k')
		est post `b1' `V1', obs(`N') dof(`=cond("`robust'"!="" || `steps'==2, `N_g', `Neff' - `df_m') - ("`constant'" == "")') depname(`depvarname')
		if "`r(varlist)'" != "" {
			test `r(varlist)'
			est scalar F = r(F)
			est scalar F_p = r(p)
		}
	}
	else if "`r(varlist)'" != "" {
		test `r(varlist)'
		est scalar chi2 = r(chi2)
		est scalar chi2p = r(p)
	}
	est scalar sargan = `sargan'[1,1]
	est scalar sar_df = `j' - `k'
	est scalar sarganp = chiprob(e(sar_df), e(sargan))

	if "`twostep'`robust'" != "" {
		est scalar hansen = `hansen'[1,1]
		est scalar hansen_df = `j' - `k'
		est scalar hansenp = chiprob(e(hansen_df), e(hansen))
	}

	/* pass the sample marker across the restore barrier */
	tempfile tmp
	keep `id' `t'
	sort `id' `t'
	save `"`tmp'"', replace
	restore
	tempvar merge
	capture rename _merge `merge'
	merge `id' `t' using `"`tmp'"', nokeep /* will yield _merge=3 for match, _merge=1 for no match */
	replace _merge = _merge == 3

 	mat `b1' = e(b)
	mat colnames `b1' = `xvars_nocons' `consname'
	est repost b = `b1', rename esample(_merge)
	capture rename `merge' _merge

	est local depvar `depvarname'

	foreach retval in N artests g_min g_max N_g df_m h `=cond("`small'"=="", "chi2 chi2p", "F F_p")' sig2 j j0 {
		cap est scalar `retval' = ``retval''
	}
	est scalar sigma = sqrt(`sig2')
	est local transform first differences
	est local noconstant `constant'

	est scalar g_avg = `N'/`N_g'
	forvalues l = 1/`artests' {
		est scalar ar`l' = `ar`l''
		est scalar ar`l'p = `ar`l'p'
	}
	foreach retval in twostep robust small wtype wexp {
		est local `retval' ``retval''
	}

	cap confirm matrix `gmmcollapse'
	if _rc==0 {
		mat `gmmorthogonal' = J(1, `=colsof(`gmmcollapse')', 0)
	}
	foreach retval in A1 A2 ivequation ivpassthru ivmz gmmequation gmmpassthru gmmcollapse gmmlaglimits gmmorthogonal {
		cap est mat `retval' ``retval''
	}

	est local ivar `id'
	est local tvar `t'
	foreach insttype in iv gmm {
		forvalues l=``insttype'groups'(-1)1 {
			est local `insttype'insts`l' ``insttype'insts`l''
		}
	}
	est local esttype = cond(`maineq', "system", "difference")

	if "`robust'" != "" {
		est local vcetype = cond(`steps' == 1, "Robust", "Corrected")
	}
	est local artype = cond(`arlevels', "levels", "first differences")
	est local predict xtab2_p
	est local cmd xtabond2
	} /* quietly */
end

program define make_GMM_inst
	version 7
	gen `4' `3' = `5'
	recode `3' . = 0
	if r(N) == _N {
		drop `3'
		c_local `2'
	}
	else {
		c_local `1' = `2' + 1
	}
end


* Version history
* 3.7.0 Require Stata 11.2 or later for Mata version. Restore _rmcoll() dropped in 3.6.6 for treatment of RHS regressors. But fix _rmcoll() bug introduced in 3.6.3 causing it to count dropped vars in Sargan/Hansen dof.
* 3.6.8 Don't restrict sample because of missing observations in iv(, mz) instruments with -orthogonal-
* 3.6.7 Don't post covariance matrix if it contains missing values (rare)
* 3.6.6 Stopped trying to drop collinear regressors and just compute their rank and adjust dof with that.
*       Prevent diffsargan if removing an instrument group renders model unidentified.
* 3.6.5 Greatly sped up svmat by using only Mata to make row stripe
* 3.6.4 Prevented diffsargan code crash in degenerate case of System GMM with no retained gmm() instruments
* 3.6.3 Improved collinearity detection by pre-normalizing variables
* 3.6.2 Added marginsok return value to obviate need for margins, force
* 3.6.1 Made predict behave gracefully if e(sample) destroyed by -est save-/-est use-.
* 3.6.0 Added multiway clustering, with finite-sample correction as simulated in Cameron, Gelbach, and Miller 2006
* 3.5.0 Added svvar option (thanks to Aart Kraay for idea). Added e(clustid) for svmat. Prevented _rmcoll() crash if passed 0 or 1 vars.
* 3.4.1 Prevented 3.2.0 bug causing crash in ado version when using no gmm() options
* 3.4.0 Prevented crash on eq(level)-noleveleq combination. Added e(ideqt) return matrix for svmat. Added version option.
* 3.3.5 Fixed bug in detection of non-constant fweight's
* 3.3.4 Fixed 3.3.3 code to prevent _cons being dropped as collinear
* 3.3.3 Fixed bug in collinearity detection, switching from lud() to invsym()
* 3.3.2 Prevent crash if pca specified without gmm() instruments.
* 3.3.1 When using svmat in Stata versions before 12, use "_" instead of "/" in stripes for e(Z).
* 3.3.0 Fixed bug in 3.2.0. Made svmat save labelled Stata matrices.
* 3.2.0 Added orthogonal suboption to gmm() option. Thanks to Joe Dieleman for the suggestion.
* 3.1.4 Added H to svmat
* 3.1.3 Added e(Ze)
* 3.1.2 Refined PCA implementation. Thanks to Jens Mehrhoff for guidance.
* 3.1.1 Changed from st_view() to st_data() for Y var to fix bug causing crash if Y had ts or fv ops
* 3.1.0 Added principal components factorization
* 3.0.1 Prevented -split- from causing crash with -noleveleq-
* 3.0.0 Added factor variable support
* 2.9.5 Added e(sigma) return value, sqrt of e(sig2).
* 2.9.4 Undid previous change which was very bad! Calls to editmissing() needed for effective cloning.
* 2.9.3 Changed calls to editmissing() to _editmissing() in _ParseInsts()
* 2.9.2 Fixed 2.9.1 bug affecting Stata 9 and earlier.
* 2.9.1 Made savvy to tsset delta() option. Thanks to Moritz Meyer.
* 2.9.0 Added svmat
* 2.8.6 Fixed bug in sample definition in transformed equation with orthog: shifted it forward one period. Thanks to Julian Reif.
* 2.8.5 Made mi-friendly
* 2.8.4 Allowed reals for level()
* 2.8.3 Fixed vestigial bug in 2.4.3 changes: in 1-step, non-robust System GMM, use # of obs (sum of weights) from xformed eq, not levels for sig2
*       Thanks to Julian Reif and David Drukker.
* 2.8.2 Added e(cmdline). Thanks to Julian Reif
* 2.8.1 Changed e(diffgroups) return value to e(diffgroup[i]) return values to handle long varlists better
* 2.8.0 Added cluster() option to Mata version
* 2.7.5 Changed "D." to "FOD." to reporting of ivstyle instruments in transformed equation
* 2.7.4 Fixed split-related bugs in labeling of eq and laglims in gmm instrument reporting
* 2.7.3 Fixed bugs in 2.6.0 instrument-reporting code arising from collision between long variable list names and Stata string length limit
* 2.7.2 Cut extraneous debugging statement
* 2.7.1 Got rid of 2.7.0 call to invtokens() since Stata 9 lacks it
* 2.7.0 Added split suboption to gmm(). Added "D." to output of standard IV instruments for diff equation.
* 2.6.2 Fixed reporting of eq(lev) GMM instruments for levels equation (off by one lag). Thanks to Julio Pindado.
* 2.6.1 Fixed construction of psi' in mata, one-step, non-robust, arlevels case
* 2.6.0 Implemented weights and reporting of instrument sets. Changed small corrections to conform with Stata convention for cluster() small
* 2.5.1 Fixed bug causing deletion of df_r return macro when there are no regressors.
* 2.5.0 Always report Sargan test, typically along with Hansen
* 2.4.8 Fixed bug on one-step, non-robust, h(1), diff-GMM in ado version causing sig2=0
*       Fixed bug in Mata version, introduced around version 2.3.0, January 2007, causing constant to be left out of Z in system GMM if no iv() options
* 2.4.7 Minor fixes in Mata code to catch degenerate situations.
* 2.4.6 Added depname() option to est post so depvar appears in results.
* 2.4.5 Changed earliest OK version date for Mata to 17may2006 because 2.4.4 uses new select() function.
* 2.4.4 Dropped empty columns from diffsargan matrix. Prevented crash when diffsargans requested but none could be run.	
* 2.4.3 Switched to computing sig2 based on differenced residuals even in system GMM, unlike DPD, unless h=1. Thanks to David Drukker. 
*       Dropped dpds2 option in Mata.
* 2.4.2 Fixed bug introduced in 2.4.0 affecting Windmeijer when no IV-style instruments.
* 2.4.1 Fixed orthogonal deviations bug. rownonmissing() => !rowmissing().
* 2.4.0 Got rid of all globals in Mata, passed by -external-, for speed. Dropped precomputing of Z submatrices in speed mode since it doubled memory use
* 2.3.1 Added warning about negative difference-in-Sargan tests when covariance of moments not invertible
* 2.3.0 Implemented automatic difference-in-Sargan tests in Mata
* 2.2.0 Implemented orthogonal deviations in Mata. Fixed small bugs in F test (thanks to Maria Elena Bontempi). Dropped tsfill in Mata.
*       Added return macro for sig2. Fixed bugs in both versions when called with by:. In Mata version, based Sargan dof 
*	  adjustment for collinear instruments on A1 even in two-step (thanks to Paulo Regis).
* 2.1.6 Added error check to prevent crash in Mata on expressions like gmm(.) and iv(L.).
*       Switched from _edittozero() to _edittozerotol() in xtabond2_rmcoll().
* 2.1.5 Restored collinear moment correction to instrument count for Sargan DF in Mata version.
* 2.1.4 Added diff option to predict. Added mean correction to predict after diff-GMM.
*       Dropped collinear moment correction to instrument count for Sargan DF in Mata version
* 2.1.3 In Mata, included hot-linked command in message about space vs. speed
* 2.1.2 Fixed bug in Mata that caused crash on gmm(X, lag(0 ...) eq(level))
* 2.1.1 Fixed bug in Mata that caused parameters from last gmm() clause to be used in previous ones.
* 2.1.0 Revised to not build full Z if matafavor=space. Dispensed with removing collinear instruments.
* 2.0.3 Dispensed with calling word() in ado to determine variable types, for compatibility with Stata 7
* 2.0.2 Switched to computing Z[|Subscripts|] as needed rather than precomputing in pZi, since that doubles memory demand 
* 2.0.1 Implemented minor refinements in .ado and .mata; fixed bug in Mata code so that excluded 
*       observations zeroed out before rmcoll. Thanks to Ken Simons.
* 2.0.0 Implemented Mata version. In both versions, changed test of overall model fit to copy -test-. I.e, does
*       Wald chi2 test when small not specified.
* 1.2.9 Made two refinements suggested by Ken Simons. 1) Added code to drop unused groups. 
*	    2) Gave transformed variables and instruments same type as original.
* 1.2.8 Generates extra instruments for levels that are not actually redundant if multiple lags of regressors are used.
*       E.g., if two lags of depvar included, then first first-diff eq is for t=4, but first level eq is for t=3. Dz_2
*       is then a good moment for t=3 levels equation, along with Dz_3, z an instrument. Thanks to Miguel Portela.
* 1.2.7 Fixed small bug in Windmeijer correction for individuals with observations for only 1 period, changing ee to r(sum).
*       Thanks to Tue Gorgens.
* 1.2.6 Fixed problem of "t" being displayed over z-stat column when "small" not invoked, via df_r2 return macro a la ivreg2
* 1.2.5 Restored "local zvars `r(varlist)'" line after instrument rmcoll. Old line was defeating purpose of rmcoll.
* 1.2.4 Restored quote marks to save and merge commands.
* 1.2.3 Switched to version 7 syntax (no parens) in recode commands.
* 1.2.2 Changed response to singular A1 or A2 from error to warning.
* 1.2.1 Put in checks for constant being the only regressor, for no regressors, and for singularity of A1 and A2.
*       Dispensed with call to xtdes, which has an infinite-loop bug.
* 1.2.0 Expanded eq() suboption of gmm() option to allow eq(level). Added passthru suboption to gmm().
* 1.1.9 Made several changes, some in response to Tue Gorgens:
*         Allowed GMM-style conditions to be made for period 1, which is possible (though odd) 
*           if leads are used instead of lags, e.g., with laglimits(-1 0).
*         If a>b in laglimits(a b), then a and b are now swapped.
*         Now reports number of instruments.
*         Now prints notice of instruments dropped due to collinearity.
* 1.1.8 Fixed two bugs spotted by Tue Gorgens:
*         One causing it to drop GMM-style levels conditions for time periods with incomplete observations in first differences.
*         One causing it to use first-differences of IV-style instruments for levels equations.
* 1.1.7 Added eq(diff | both) suboption to gmm() option.
* 1.1.6 Made it check if constant is in col(X) even when noleveleq or noconstant is specified, and adjusted F stat.
*       Copied new ivreg2 handling of F stat/Wald chi2. In particular, switched to always reporting F.
*       Fixed bug created in 1.1.5, to handle "lag(X .) collapse".
* 1.1.5 Fixed bug causing collapse to ignore lag limits.
* 1.1.4 Changed data type of ideq to double to handle floating point panel id's.
* 1.1.3 Fixed bug causing it to display warning for twostep even when robust also invoked.
* 1.1.2 Fixed handling of case where AR(i) test is trivially zero so it won't crash.
* 1.1.1 Made data type long or double where it had not been explicity in gen and egen commands.
* 1.1.0 Added arlevels option. Simplified AR() code.
* 1.0.5 Put in check for Stata 7 executable new enough for opaccum.
* 1.0.4 Saved results from summarize before mkmat, which destroys r() values in Stata 7.
* 1.0.3 Added capture rename commands to handle case of _merge already existing before merge.
* 1.0.2 For compatibility with Stata 7, took "=" out of est mat commands and dropped keep() from merge.
* 1.0.1 Allowed GMM-style conditions to be made for period 2, which is possible if lagged dep var is not regressor;
*		added ", replace" to save before restore; and dropped unnecessary sorts before tssets.
