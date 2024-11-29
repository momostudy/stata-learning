*! cmp 8.7.9 18 April 2024
*! Copyright (C) 2007-24 David Roodman 

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

* Version history at bottom

cap program drop cmp
program define cmp, sortpreserve properties(user_score svyb svyj svyr mi fvaddcons) byable(recall)
  version 11
  cap version 13.0
  if _rc {
     di as err "This version of {cmd:cmp} requires Stata version 13 or later. An older version compatible with Stata `c(stata_version)'"
     di as err "is at https://github.com/droodman/cmp/releases/tag/v8.6.1."
     exit _rc
  }

	cap noi _cmp `0'
	if _rc {
		local rc = _rc
		if _rc>1 cmp_clear
		error `rc'
	}
end

cap program drop _cmp
program define _cmp
	version 11

	if replay() {
		if "`e(cmd)'" != "cmp" error 301
		if _by() error 190
		Display `0'
		exit 0
	}

	cmp_clear

	global cmp_out 0
	global cmp_cont 1
	global cmp_left 2
	global cmp_right 3
	global cmp_probit 4
	global cmp_oprobit 5
	global cmp_mprobit 6
	global cmp_int 7
	global cmp_trunc 8 // deprecated
	global cmp_probity1 8 // now used in cmp_ind* vars to indicate probit obs with y!=0
	global cmp_roprobit 9
	global cmp_frac 10
	global cmp_missing .
	
	if `"`0'"' == "setup" {
		di as txt "$" "cmp_out      = " as res 0
		di as txt "$" "cmp_missing  = " as res .
		di as txt "$" "cmp_cont     = " as res 1
		di as txt "$" "cmp_left     = " as res 2
		di as txt "$" "cmp_right    = " as res 3
		di as txt "$" "cmp_probit   = " as res 4
		di as txt "$" "cmp_oprobit  = " as res 5
		di as txt "$" "cmp_mprobit  = " as res 6
		di as txt "$" "cmp_int      = " as res 7
		di as txt "$" "cmp_trunc    = " as res 8 as txt "  (deprecated)"
		di as txt "$" "cmp_roprobit = " as res 9
		di as txt "$" "cmp_frac     = " as res 10
		exit 0
	}

	cap ghk2version
	if _rc | "`r(version)'" < "01.70.00" {
		di as err "Error: {cmd:cmp} works with {cmd:ghk2()} version 1.7.0 or later."
		di `"To install or update it, type or click on {stata "ssc install ghk2, replace"}. Then restart Stata."'
		exit 601
	}

	syntax anything(equalok id="model" name=model) [pw fw aw iw] [if] [in], INDicators(string asis) [svy GHKAnti GHKDraws(string) ///
		GHKType(string) QUIetly noLRtest CLuster(varname) Robust vce(string) Level(real `c(level)') RESULTsform(string) predict(string) ///
		CONSTraints(passthru) TECHnique(string) INTERactive noDRop init(namelist min=1 max=1) from(namelist min=1 max=1) lf pseudod2 PSampling(numlist min=1 max=2) ///
		STRUCtural REVerse noESTimate REDraws(string) COVariance(string) INTPoints(string) INTMethod(string) noAUTOconstrain noSIGXform *] 

	if "`pseudod2'" != "" cmp_error 198 "The pseudod2 option is no longer supported."
	if "`from'" != "" {
		if "`init'" != "" cmp_error 198 "Cannot specify both {cmd:init()} and {cmd:from()}."
		local init `from'
	}

	local cmdline `0'
	
	mata _mod = cmp_model()

	global parse_wtypeL `weight'
	tokenize `"`exp'"'
	macro shift // get rid of = prefix
	global parse_wexpL `*'

	local structural = "`structural'" != ""
	global cmp_reverse = "`reverse'" != ""
	mata _mod.setReverse($cmp_reverse)
	global cmpSigXform = "`sigxform'" ==""
	mata _mod.setSigXform($cmpSigXform)
	if $cmpSigXform {
		local ln ln
		local atanh atanh
	}

	marksample touse, strok

	_get_eformopts, soptions eformopts(`options') allowed(hr shr IRr or RRr)
	local eformopts `s(eform)'
	_get_mldiopts, `s(options)'
	local mldiopts `s(diopts)'

	if "`svy'" != "" {
		if "`_dta[_svy_stages]'"=="" {
			di as res _n "Warning: data not svyset. Ignoring " as inp "svy" as res "."
			local svy
		}
		else {
			svymarkout `touse'
			svyopts modopts svydiopts options, `s(options)'
			local meff `s(meff)'
			local 0, `modopts'
			local _options `options'
			syntax, [subpop(string) *]
			local modopts `options'
			local options `_options'
			if `"`subpop'"' != "" {
				cap confirm var `subpop'
				if _rc {
					tempvar subpop
					qui gen byte `subpop' = `s(subpop)' & `touse'
				}
			}
		}
	}
	else local options `s(options)'

	local diopts `eformopts' `mldiopts' `svydiopts' level(`level') resultsform(`resultsform')
	mlopts mlopts, `options'
	local 0, `mlopts'
	syntax, [iterate(passthru) *]
	local mlopts `options'

	ParseEqs `model' // parse the equations
	global cmp_d $parse_d
	if $parse_L == 1 global cmp_IntMethod 0
	else {
		if `"`redraws'"'=="" {
			if "`intmethod'"'!="" {
				local 0 `intmethod'
				local _iterate `iterate'
        syntax [anything(name=intmethod)], [TOLerance(real 1e-8) ITERate(integer 1001)]
				if `tolerance'<=0 cmp_error 198 "Adaptive quadrature tolerance must be positive."
				if   `iterate'<=0 cmp_error 198 "Maximum adaptive quadrature iterations must be positive."
				mata _mod.setQuadTol(`tolerance'); _mod.setQuadIter(`iterate')
        local iterate `_iterate'
			}
			else mata _mod.setQuadTol(1e-3); _mod.setQuadIter(1001)
			if "`intmethod'"'=="" local intmethod mvaghermite
			local 0, `intmethod'
			syntax, [Ghermite MVAghermite]
			local methods ghermite mvaghermite
			local t: list posof "`ghermite'`mvaghermite'" in methods
			if `t' global cmp_IntMethod = `t' - 1
				else cmp_error 198 `"The {cmdab:intm:ethod()} option, if included, should be "ghermite" or "mvaghermite"."'
			
			if `"`vce'`svy'`robust'`cluster'"'=="" local vce oim
			if "`technique'"=="" & !("`svy'"!="" & date(c(born_date),"DMY")<d(30jan2018)) {  // moptimize() would crash with BHHH & svy & gfX evaluators
				local technique bhhh
				di as res _n "For quadrature, defaulting to technique(bhhh) for speed."
			}
		}
		else global cmp_IntMethod 0
	}
	local 0 `ghkdraws'
	syntax [anything], [type(string) ANTIthetics SCRamble *]
	if `"`options'"' != "" {
		local 0, `options'
		syntax, [SCRamble(string)]
	}
	else if "`scramble'" != "" local scramble sqrt
	if `"`scramble'"' != "" {
		local 0, `scramble'
		syntax, [sqrt NEGsqrt fl]
		local scramble `sqrt'`negsqrt'`fl'
	}

	if `"`ghktype'"' != "" & `"`type'"' != "" & `"`ghktype'"' != `"`type'"' & `"`ghktype'`type'"' != "halton" {
		di as res _n "Warning: {cmd:type(`type')} suboption overriding deprecated {cmd:ghktype(`ghktype')} option."
	}
	if `"`type'"' != "" local ghktype `type'
	local 0, ghkdraws(`anything')
	syntax, [ghkdraws(numlist integer>=`=c(stata_version)<15' max=1)]  // In Stata 15+, allow ghkdraws(0) to trigger use of mvnormal()
  if "`ghkdraws'" == "" | 0`ghkdraws' {
    if `"`ghktype'"'=="" local ghktype halton
    else if inlist(`"`ghktype'"', "halton", "hammersley", "ghalton", "random") == 0 {
      cmp_error 198 `"The {cmdab:ghkt:ype()} option must be "halton", "hammersley", "ghalton", or "random". It corresponds to the {cmd:{it:type}} option of {cmd:ghk()}. See help {help mf_ghk}."'
    }
    if "`scramble'"!="" & "`type'"=="ghalton" {
      di as res "Warning: {cmd:scramble} in {cmd:ghkdraws()} option incompatible with {cmd:ghalton}. {cmd:scramble} ignored."
      local scramble
    }
    if 0`ghkdraws' mata _mod.CheckPrime(`ghkdraws')
    local ghkanti = "`antithetics'`ghkanti'"!=""
    mata _mod.setGHKType("`ghktype'"); _mod.setGHKAnti(`ghkanti'); _mod.setGHKDraws(0`ghkdraws'); _mod.setGHKScramble("`scramble'")
    local ghkscramble `scramble'
  }

	if `"`covariance'"' == "" {
		forvalues l=1/$parse_L {
			global cmp_cov`l' unstructured
		}
	}
	else {
		local covariance: subinstr local covariance "." "unstructured", word all
		if `:word count `covariance'' != $parse_L cmp_error 198 "The {cmdab:cov:ariance()}, if used, must contain one entry for each of the $parse_L levels in the model."
		else {
			tokenize `covariance'
			forvalues l=1/$parse_L {
				local 0, ``l''
				syntax, [UNstructured EXchangeable INDependent]
				global cmp_cov`l' `unstructured'`exchangeable'`independent'
				if inlist("${cmp_cov`l'}", "unstructured", "exchangeable", "independent") == 0 {
					cmp_error 198 `"Each entry in the {cmdab:cov:ariance()} option must be "unstructured", "." (equivalent to "unstructured"), "exchangeable", or "independent"."'
				}
			}
		}
	}
	forvalues l=1/$parse_L {
		local FixedRhoFill`l' = cond("${cmp_cov`l'}"=="independent", 0, .)
	}

	local t: subinstr local indicators "(" "", all
	if $cmp_d != `:word count `:subinstr local t ")" "", all'' cmp_error 198 `"The {cmdab:ind:icators()} option must contain $cmp_d `=plural($cmp_d,"variable","variables, one for each equation")'. Did you forget to type {stata "cmp setup"}?"'

	mata _mod.setQuadrature(0); _mod.setREAnti(1)
	if $parse_L > 1 {
		if `"`redraws'"' == "" {
			if `"`intpoints'"' == "" {
				forvalues l=2/$parse_L {
					local intpoints `intpoints' 12 // default precision level for quadrature
				}
				local redraws `intpoints'
			} 
			else {
				local 0, intpoints(`intpoints')
				syntax, [intpoints(numlist integer>=1)]
				if $parse_L!=`:word count `intpoints''+1 cmp_error 198 "If included, the intpoints() should have one entry for each level except the lowest."
				tokenize `intpoints'
				forvalues l=1/`=$parse_L-1' {
					if ``l'' > 25 {
						di as res "Warning: quadrature precision limited to the equivalent of 25 integration points."
						local `l' 25
					}
					local redraws `*'
				}
			}
			local steps 1
			mata _mod.setQuadrature(1); _mod.setREAnti(1)
		} 
		else {
			if `"`intpoints'"' != "" cmp_error 198 "intpoints() and redraws() options conflict. Use one or neither. (Default: sparse-grid quadrature with precision equivalent to 12 integration points.)"
			local 0 `redraws'
			syntax [anything], [type(string) ANTIthetics STeps(numlist integer min=1 max=1 >0) SCRamble *]
			if `"`options'"' != "" {
				local 0, `options'
				syntax, [SCRamble(string)]
			}
			else if "`scramble'" != "" local scramble sqrt
			if `"`scramble'"' != "" {
				local 0, `scramble'
				syntax, [sqrt NEGsqrt fl]
				local scramble `sqrt'`negsqrt'`fl'
			}
			local 0, redraws(`anything')
			syntax, [redraws(numlist integer>=1)]
			if $parse_L!=`:word count `redraws''+1 cmp_error 198 "If included, the redraws() option should have one entry for each level except the lowest."

			if `"`type'"'=="" local type halton
			else if inlist(`"`type'"', "halton", "hammersley", "ghalton", "random") == 0 {
				cmp_error 198 `"The {cmd:redraws()} {cmd:type()} suboption must be "halton", "hammersley", "ghalton", or "random"."'
			}
			if "`type'"=="hammersley" & "`ghktype'"=="hammersley" {
				cmp_error 198 "Random effects and GHK sequences shouldn't both be Hammersley since this will assign the same draws to the first dimension of each."
			}
			if "`scramble'"!="" & "`type'"=="ghalton" {
				di as res "Warning: {cmd:scramble} in {cmd:redraws()} option incompatible with {cmd:ghalton}. {cmd:scramble} ignored."
				local scramble
			}
			mata _mod.CheckPrime(strtoreal(tokens("`redraws'")))
			mata _mod.setREType("`type'"); _mod.setREAnti(1+("`antithetics'"!= "")); _mod.setREScramble("`scramble'")
		}
	}
	if 0`steps'==0 local steps 1

	global cmp_max_cuts 0
	global cmp_num_mprobit_groups 0
	global cmp_num_roprobit_groups 0
	global cmp_mprobit_ind_base 20
	global cmp_roprobit_ind_base 40
	global cmp_intreg 0
	global cmp_truncreg 0
	local asprobit_eq 0
	tempvar _touse n asmprobit_dummy_sum asmprobit_ind

	qui {
		gen byte `_touse' = 0
		tokenize `"`indicators'"', parse("() ")
		local parse_eqno 0
		local cmp_eqno 0
		while `"`1'"' != "" {
			if (`"`1'"' == ")" & `asprobit_eq' == 0) | (`"`1'"' == "(" & `asprobit_eq') cmp_error 132 "Too many `1'"
			if `"`1'"'==")" {
				if "`m_ro'" == "m" {
					cap assert `asmprobit_dummy_sum'==1 if `touse' & _cmp_ind`first_asprobit_eq', fast
					if _rc cmp_error 132 "For multinomial probit groups, exactly one dependent variable must be non-zero for each observation."
					replace _cmp_ind`first_asprobit_eq'=`asmprobit_ind'*(_cmp_ind`first_asprobit_eq'!=0) // store choice info in indicator var for first equation
					drop `asmprobit_ind' `asmprobit_dummy_sum'
				}
				mat cmp_`m_ro'probit_group_inds[${cmp_num_`m_ro'probit_groups}, 2] = `cmp_eqno'
				mat cmp_nonbase_cases = nullmat(cmp_nonbase_cases) , 0 , J(1, `asprobit_eq'-2, 1)
				local asprobit_eq 0
				local m_ro
				macro shift
				continue
			}

			local ++parse_eqno
			local ++cmp_eqno
			local NAlts 0

			if `"`1'"'=="(" {
				macro shift
				if `"`1'"' == ")" continue
				local asprobit_eq 1
				local first_asprobit_eq `cmp_eqno'

				if "${parse_x`parse_eqno'}" != "" global parse_xc`parse_eqno' nocons  // put nocons for first eq in asprobit group or (below, after eq gets its name) leave cons in but constrained to 0
			}

			cap gen byte _cmp_ind`cmp_eqno' = `1'
			if _rc cmp_error 198 `"Error building indicator variable for equation `cmp_eqno' from expression `1'. Did you forget to type {stata "cmp setup"}?"'
			if "${parse_y`parse_eqno'}"=="." {
				cap assert inlist(_cmp_ind`cmp_eqno', ., 0) if `touse', fast
				if _rc cmp_error 198 `"Indicator for ${parse_eq`parse_eqno'} equation must only evaluate to missing (".") or 0 since the dependent variable is unobserved."'
			}
			else {
				cap assert inlist(_cmp_ind`cmp_eqno', ., 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10) if `touse', fast
				if _rc cmp_error 198 "Indicator for ${parse_y`parse_eqno'} must only evaluate to integers between 0 and 10."
				replace _cmp_ind`cmp_eqno' = $cmp_cont if _cmp_ind`cmp_eqno'==$cmp_trunc // deprecate this indicator value
			}
			
			foreach macro in eq x xc xo xe y yR id {
				global cmp_`macro'`cmp_eqno' ${parse_`macro'`parse_eqno'}
			}

			markout _cmp_ind`cmp_eqno' ${cmp_xo`cmp_eqno'} ${cmp_xe`cmp_eqno'} `:subinstr global cmp_id`cmp_eqno' "_n" "", all word'
			if "${cmp_xe`cmp_eqno'}" != "" replace _cmp_ind`cmp_eqno' = 0 if ${cmp_xe`cmp_eqno'}<=0
			
			cap assert _cmp_ind`cmp_eqno' != $cmp_int if `touse', fast
			if _rc {
				if `:word count ${cmp_y`cmp_eqno'}' != 2 cmp_error 198 "Interval regression equations require two dependent variables."
				global cmp_y`cmp_eqno'_L : word 1 of ${cmp_y`cmp_eqno'}
				gen double _cmp_y`cmp_eqno' = `: word 2 of ${cmp_y`cmp_eqno'}' if `touse'  // copy so can modify below in converting some obs to Tobits for efficiency
				global cmp_y`cmp_eqno' _cmp_y`cmp_eqno'
				global cmp_intreg 1
				global cmp_intreg`cmp_eqno' 1
				mat cmp_intregeqs = nullmat(cmp_intregeqs), 1
				replace _cmp_ind`cmp_eqno' = ${cmp_y`cmp_eqno'}<. if _cmp_ind`cmp_eqno'==$cmp_int & ${cmp_y`cmp_eqno'}==${cmp_y`cmp_eqno'_L}
				replace _cmp_ind`cmp_eqno' = 0 if _cmp_ind`cmp_eqno'==$cmp_int & ${cmp_y`cmp_eqno'} < ${cmp_y`cmp_eqno'_L} & ${cmp_y`cmp_eqno'_L} < .
				markout _cmp_ind`cmp_eqno' ${parse_x`parse_eqno'}
			}
			else {
				mat cmp_intregeqs = nullmat(cmp_intregeqs), 0
				markout _cmp_ind`cmp_eqno' ${parse_x`parse_eqno'}  // `=cond("${parse_y`parse_eqno'}"!="." & , "${parse_y`parse_eqno'}", "")'
				global cmp_intreg`cmp_eqno' 0
				global cmp_y`cmp_eqno'_L .  // to prevent syntax errors
			}

			if `"${parse_tr`parse_eqno'}"' != "" { // truncated regression
				gen double _cmp_Lt`cmp_eqno' = `:word 1 of ${parse_tr`parse_eqno'}'
				gen double _cmp_Ut`cmp_eqno' = `:word 2 of ${parse_tr`parse_eqno'}'
				mat cmp_trunceqs = nullmat(cmp_trunceqs), 1
				global cmp_Lt`cmp_eqno' _cmp_Lt`cmp_eqno'
				global cmp_Ut`cmp_eqno' _cmp_Ut`cmp_eqno'
				global cmp_truncreg 1
				global cmp_truncreg`cmp_eqno' 1
				count if _cmp_ind`cmp_eqno' & `touse'
				local N = r(N)
				replace _cmp_ind`cmp_eqno' = 0 if `touse' & inlist(_cmp_ind`cmp_eqno', $cmp_cont, $cmp_left, $cmp_right) & ///
					((${cmp_y`cmp_eqno'}<=${cmp_Lt`cmp_eqno'} & ${cmp_Lt`cmp_eqno'}<.) | ${cmp_y`cmp_eqno'}>=${cmp_Ut`cmp_eqno'})
				replace _cmp_ind`cmp_eqno' = 0 if `touse' & _cmp_ind`cmp_eqno'==$cmp_trunc & ///
					((${cmp_y`cmp_eqno'}<=${cmp_Lt`cmp_eqno'} & ${cmp_Lt`cmp_eqno'}<.) | ${cmp_y`cmp_eqno'_L}>=${cmp_Ut`cmp_eqno'})
				replace _cmp_ind`cmp_eqno' = 0 if `touse' & _cmp_ind`cmp_eqno'==$cmp_probit & ///
					((0<${cmp_Lt`cmp_eqno'} & ${cmp_Lt`cmp_eqno'}<.) | 0>${cmp_Ut`cmp_eqno'}) // truncation range must embrace 0 for probits
				count if _cmp_ind`cmp_eqno' & `touse'
				if r(N)!=`N' di as res `N'-r(N) " observations dropped because dependent variable in equation `parse_eqno' is outside truncation range."

				if ${cmp_intreg`cmp_eqno'} {
					gen double _cmp_y`cmp_eqno'_L = ${cmp_y`cmp_eqno'_L}
					global cmp_y`cmp_eqno'_L _cmp_y`cmp_eqno'_L
					global cmp_y`cmp_eqno'   _cmp_y`cmp_eqno'
					replace _cmp_y`cmp_eqno'_L = _cmp_Lt`cmp_eqno' if `touse' & _cmp_ind`cmp_eqno'==$cmp_int & (_cmp_y`cmp_eqno'_L==. | (_cmp_y`cmp_eqno'_L<_cmp_Lt`cmp_eqno' & _cmp_Lt`cmp_eqno'<.))
					replace _cmp_y`cmp_eqno'   = _cmp_Ut`cmp_eqno' if `touse' & _cmp_ind`cmp_eqno'==$cmp_int & _cmp_y`cmp_eqno'  >_cmp_Ut`cmp_eqno'
				}
			}
			else {
				global cmp_truncreg`cmp_eqno' 0
				mat cmp_trunceqs = nullmat(cmp_trunceqs), 0
				global cmp_Lt`cmp_eqno' .
				global cmp_Ut`cmp_eqno' .
			}

			global cmp_eq`cmp_eqno' = cond("${parse_eq`parse_eqno'}"=="eq`parse_eqno'", subinstr("`: word 1 of ${parse_y`parse_eqno'}'", ".", "", .), "${parse_eq`parse_eqno'}")
			if "`:list eqnames & global(cmp_eq`cmp_eqno')'" != "" global cmp_eq`cmp_eqno' `=substr("${cmp_eq`cmp_eqno'}",1,29)'`cmp_eqno'
			local eqnames `eqnames' ${cmp_eq`cmp_eqno'}

      if 0`first_asprobit_eq' == `cmp_eqno' & "${parse_x`parse_eqno'}" == "" {  // if this is an mprobit base case with no regressors, leave cons in but constrain to 0
        constraint free
        local _constraints `_constraints' `r(free)'
        constraint `r(free)' [${cmp_eq`parse_eqno'}]_cons
      }	

			replace `_touse' = `_touse' | _cmp_ind`cmp_eqno'

			cap assert _cmp_ind`cmp_eqno' != $cmp_oprobit if `touse', fast
      mat cmp_num_cuts = nullmat(cmp_num_cuts) \ _rc  // _rc is a placeholder non-zero value, to be corrected later
      if _rc {  // ordered probit
				local i_oprobit_ys `i_oprobit_ys' i._cmp_y`cmp_eqno'
				global cmpAnyOprobit 1
			}
			else local lrtest `lrtest' ${cmp_xc`cmp_eqno'}

			cap assert _cmp_ind`cmp_eqno' != $cmp_frac if `touse', fast
			if _rc {
				local hasfrac 1
				cap assert (${cmp_y`cmp_eqno'} >= 0 & ${cmp_y`cmp_eqno'} <= 1) | ${cmp_y`cmp_eqno'} >= . if `touse' & _cmp_ind`cmp_eqno'==$cmp_frac, fast
				if _rc cmp_error 198 "Observations of dependent variable for fractional probit equation must be in [0,1]."
			}

			count if _cmp_ind`cmp_eqno'==$cmp_mprobit & `touse'
			local N_mprobit `r(N)'
			count if _cmp_ind`cmp_eqno'==$cmp_roprobit & `touse'
			local N_roprobit `r(N)'
			if `N_mprobit' | `N_roprobit' {  // multinomial or rank-ordered probit
				if (`N_mprobit' & "`m_ro'" == "ro") | (`N_roprobit' & "`m_ro'" == "m") cmp_error 148 "Cannot mix multinomial and rank-ordered indicator values in the same group."
				cap assert inlist(_cmp_ind`cmp_eqno', 0, $cmp_mprobit, $cmp_roprobit) if `touse', fast

				if _rc | `N_mprobit'&`N_roprobit' cmp_error 198 `"Dependent variables modeled as `=cond(`N_mprobit',"multinomial","rank-ordered")' probit may not be modeled differently for other observations in the same equation."'
				
				if ${cmp_truncreg`cmp_eqno'} cmp_error 198 `'"Truncation not allowed in `=cond(`N_mprobit',"multinomial","rank-ordered")' probit equations."'
				
				if `asprobit_eq'==1 & "`m_ro'" == "" {  // starting new asprobit group?
					if `N_mprobit' {
						gen byte `asmprobit_dummy_sum' = 0 if `touse'
						gen byte `asmprobit_ind' = $cmp_mprobit_ind_base + `cmp_eqno' - 1 if `touse'
						local m_ro m
					}
					else local m_ro ro
					
					global cmp_num_`m_ro'probit_groups = ${cmp_num_`m_ro'probit_groups} + 1
					mat cmp_`m_ro'probit_group_inds = nullmat(cmp_`m_ro'probit_gr 	 	oup_inds) \ (`cmp_eqno', .)
				}
				
				if `asprobit_eq' == 0 { // non-as mprobit?
					if `N_roprobit' cmp_error 148 "Rank-ordered probit indicators must be grouped in parentheses."

					global cmp_num_mprobit_groups = $cmp_num_mprobit_groups + 1

					GroupCategoricalVar if `touse' & _cmp_ind`cmp_eqno'==$cmp_mprobit, predict(`predict') cmp_eqno(`cmp_eqno')
					mat cmp_cat`cmp_eqno' = r(cat)
					local NAlts = colsof(cmp_cat`cmp_eqno') - 1
					if `NAlts' == 0 cmp_error 148 "There is only one outcome in ${cmp_y`cmp_eqno'}."
					if $cmp_max_cuts < `NAlts' global cmp_max_cuts = `NAlts' // hack for including cmp_y`cmp_eqno'_label in e(cat) for use after predict just below

					mat cmp_mprobit_group_inds = nullmat(cmp_mprobit_group_inds) \ (`cmp_eqno', `cmp_eqno'+`NAlts')
					mat cmp_nonbase_cases = nullmat(cmp_nonbase_cases) , 0 , J(1, `NAlts', 1)

					replace _cmp_ind`cmp_eqno' = $cmp_mprobit_ind_base + _cmp_y`cmp_eqno' + `cmp_eqno' - 1 if `touse' & _cmp_ind`cmp_eqno'==$cmp_mprobit // indicator for first eq holds choice info

					forvalues i=`cmp_eqno'/`=`cmp_eqno'+`NAlts'' {
						gen byte _mp_cmp_y`i' = _cmp_y`cmp_eqno' == `=`i'+1-`cmp_eqno'' 
						global cmp_y`i' _mp_cmp_y`i'
					}

					LabelMprobitEq `cmp_eqno' `parse_eqno' 1 `cmp_eqno'

					forvalues j=`=`cmp_eqno'+1'/`=`cmp_eqno'+`NAlts'' { // Generate all equations associated with this, the user's one mprobit equation
						tempvar ind`j'
						global cmp_ind`j' _cmp_ind`j'
						gen byte _cmp_ind`j' = $cmp_mprobit*(_cmp_ind`cmp_eqno'>0) if `touse'
						LabelMprobitEq `j' `parse_eqno' `j' `cmp_eqno'
						foreach macro in x xc xo xe yR id {
							global cmp_`macro'`j' ${cmp_`macro'`cmp_eqno'}
						}
						mat cmp_num_cuts = cmp_num_cuts \ 0
					}

					// first equation in expanded group is placeholder, for consistency with asmprobit--constant-only and constant=0
					constraint free
					local _constraints `_constraints' `r(free)'
					constraint `r(free)' [${cmp_eq`cmp_eqno'}]_cons
					foreach macro in x xc xo xe yR {
						global cmp_`macro'`cmp_eqno' 
					}
				}
				else {
					if "`m_ro'" == "m" {
						replace `asmprobit_ind' = `asmprobit_ind' + (${cmp_y`cmp_eqno'}!=0) * `asprobit_eq' if _cmp_ind`cmp_eqno'
						replace `asmprobit_dummy_sum' = `asmprobit_dummy_sum' + (${cmp_y`cmp_eqno'}!=0) if _cmp_ind`cmp_eqno'
						replace _cmp_ind`cmp_eqno' = 0 if _cmp_ind`first_asprobit_eq' == 0  // exclude obs missing for base case
					}
					else {
						cap assert mod(${cmp_y`cmp_eqno'}, 1)==0 & ${cmp_y`cmp_eqno'}>=0 & ${cmp_y`cmp_eqno'}<=`=maxbyte()-$cmp_roprobit_ind_base' if `touse', fast
						if _rc cmp_error 148 "Dependent variables modeled as rank-ordered probit must take integer values between 0 and `=maxbyte()-$cmp_roprobit_ind_base'."
						replace _cmp_ind`cmp_eqno' = ${cmp_y`cmp_eqno'} + $cmp_roprobit_ind_base if _cmp_ind`cmp_eqno'
					}
					local ++asprobit_eq
				}
			}
			else {
				if `asprobit_eq' {
					if "`m_ro'"=="m" cmp_error 148 "Each indicator in an alternative-specific multinomial probit group must evaluate to $cmp_mprobit ($"  "cmp_mprobit) at least once."
					            else cmp_error 148 "Each indicator in a rank-ordered probit group must evaluate to $cmp_roprobit ($" "cmp_roprobit) at least once."
				}
				mat cmp_nonbase_cases = nullmat(cmp_nonbase_cases) , 1
			}

			cap assert ${cmp_y`cmp_eqno'}==. & _cmp_ind`cmp_eqno'!=$cmp_int if `touse', fast
			if _rc==0 global cmp_y`cmp_eqno' .
			qui replace _cmp_ind`cmp_eqno' = 0 if `touse' & mi(${cmp_y`cmp_eqno'}) & _cmp_ind`cmp_eqno'!=$cmp_int

			forvalues i=`cmp_eqno'/`=`cmp_eqno'+`NAlts'*(`asprobit_eq'==0)' { // do once unless expanding non-alt-specific mprobit eq

				if `i'==1 mat cmp_fixed_rhos$parse_L = 0
				else      mat cmp_fixed_rhos$parse_L = (cmp_fixed_rhos$parse_L, J(`i'-1, 1, .)) \ J(1, `i', `FixedRhoFill$parse_L')

				// create sig param unless mprobit eq 1-2 or entirely (ordered/fractional) probit or unobserved
				cap assert inlist(_cmp_ind`i', $cmp_out, $cmp_probit, $cmp_oprobit, $cmp_missing, $cmp_frac) if `touse', fast
				if _rc==0 {
					mat cmp_fixed_sigs$parse_L = nullmat(cmp_fixed_sigs$parse_L), 1
					forvalues l=1/`=$parse_L-1' {
						mat cmp_fixed_sigs`l' = nullmat(cmp_fixed_sigs`l'), .
					}
					cap assert inlist(_cmp_ind`i', $cmp_out, $cmp_missing, $cmp_oprobit) if `touse', fast
					if _rc==0 global cmp_xc`i' nocons
					if "${parse_y`parse_eqno'}"=="." noi di _n as txt "Error for ${cmp_eq`parse_eqno'} equation modeled as standard normal (mean 0, variance 1) and constant term set to 0."
				}
				else if `asprobit_eq'-1==1 | (`NAlts' & `i'==`cmp_eqno') { // 1st eq of m/roprobit. sig=1 for structural, 0 otherwise, all levels
					forvalues l=1/$parse_L {
						mat cmp_fixed_sigs`l' = nullmat(cmp_fixed_sigs`l'), `structural'
					}
				}
				else if `asprobit_eq'-1==2 | (`NAlts' & `i'==`cmp_eqno'+1) { // 2nd eq of m/roprobit. sig=1 for structural, 2 otherwise, bottom level
					mat cmp_fixed_sigs$parse_L = nullmat(cmp_fixed_sigs$parse_L), sqrt(2-`structural')
					forvalues l=1/`=$parse_L-1' {
						mat cmp_fixed_sigs`l' = nullmat(cmp_fixed_sigs`l'), .
					}
				}
				else {
					forvalues l=1/`=$parse_L-1' {
						mat cmp_fixed_sigs`l' = nullmat(cmp_fixed_sigs`l'), .
					}
					if `i'>=`cmp_eqno'+2 & "${parse_iia`parse_eqno'}" != "" { // impose IIA for non-alt-specifc mprobits
						mat cmp_fixed_sigs$parse_L = nullmat(cmp_fixed_sigs$parse_L), sqrt(2-`structural')
						forvalues j=`=`cmp_eqno'+1'/`=`i'-1' {
							mat cmp_fixed_rhos$parse_L[`i',`j'] = cond(`structural', 0, cond($cmpSigXform, atanh(.5), .5))
						}
					}
					else {
						if "${cmp_cov$parse_L}" != "exchangeable" local sigparams$parse_L `sigparams$parse_L' /`ln'sig_`i' 
						mat cmp_fixed_sigs$parse_L = nullmat(cmp_fixed_sigs$parse_L), .
					}
				}

				if "${cmp_x`i'}"=="" & "${cmp_xc`i'}"=="nocons" { // ml doesn't like eqs with no regressors or constant, but they can be OK in gamma models
					global cmp_xc`i'
					constraint free
					local _constraints `_constraints' `r(free)'
					constraint `r(free)' [${cmp_eq`i'}]_cons
					local lrtest nocons
				}

				replace _cmp_ind`i' = $cmp_probity1 if `touse' & _cmp_ind`i'==$cmp_probit & `:word 1 of ${cmp_y`i'}' // to streamline likelihood computation split probit samples into y=0 and y!=0

				forvalues l=1/`=$parse_L-1' {
					if cmp_fixed_sigs`l'[1,`i'] { // suppress RC and RE lists if this is a base case without structural, so sigs=0
						global cmp_rc`l'_`i' ${parse_rc`l'_`parse_eqno'}
						global cmp_re`l'_`i' ${parse_re`l'_`parse_eqno'}
						global cmp_cov`l'_`i' ${parse_cov`l'_`parse_eqno'}
					}
					local cmp_NumEff`l'_`i': word count ${cmp_rc`l'_`i'} ${cmp_re`l'_`i'}
				}

				global cmp_cov${parse_L}_`i' unstructured
				local  cmp_NumEff${parse_L}_`i' 1  // one "random effect" at bottom
				global cmp_re${parse_L}_`i' _cons // ditto
				global cmp_intreg`i' ${cmp_intreg`cmp_eqno'}
				global cmp_truncreg`i' ${cmp_truncreg`cmp_eqno'}
				global cmp_Ut`i' ${cmp_Ut`cmp_eqno'}
				global cmp_Lt`i' ${cmp_Lt`cmp_eqno'}
				if `i'>`cmp_eqno' {
					mat cmp_trunceqs = nullmat(cmp_trunceqs), 0
					mat cmp_intregeqs = nullmat(cmp_intregeqs), 0
				}
			}

			if `asprobit_eq'==0 local cmp_eqno = `cmp_eqno' + `NAlts'
			macro shift
		}

		replace `touse' = `touse' & `_touse'
		global cmp_d `cmp_eqno'
		forvalues eq=1/$cmp_d {
			global cmp_eq $cmp_eq ${cmp_eq`eq'}
			global cmp_Lt $cmp_Lt ${cmp_Lt`eq'}
			global cmp_Ut $cmp_Ut ${cmp_Ut`eq'}
			global cmp_yL $cmp_yL ${cmp_y`eq'_L}
			global cmp_ind $cmp_ind _cmp_ind`eq'
		}
		mata _mod.setd($cmp_d); _mod.setL($parse_L)
		mata _mod.setUtVars("$cmp_Ut"); _mod.setLtVars("$cmp_Lt"); _mod.setyLVars("$cmp_yL"); _mod.setindVars("$cmp_ind")

		drop `_touse'
		egen byte `_touse' = rowmax($cmp_ind) if `touse'
		replace `touse' = 0 if `_touse'==0 | `_touse'==.  // drop obs for which all outcomes unobserved
		drop `_touse'

    global cmpHasGamma 0
    tempname GammaINobs GammaI GammaId
    mat `GammaI'     = I($cmp_d)
    mat `GammaINobs' = I($cmp_d)
    forvalues eq1=1/$cmp_d {
      foreach EndogVar in ${cmp_yR`eq1'} {
        local eq2: list posof `"`EndogVar'"' in global(cmp_eq)
        if `eq2' {
          mat cmpGammaInd = nullmat(cmpGammaInd) \ `eq2',`eq1'
          mat `GammaI'[`eq1', `eq2'] = 1
          qui count if _cmp_ind`eq2' & `touse'  // is the linear functional referred to sometimes unavailable?
          mat `GammaINobs'[`eq1', `eq2'] = r(N)>0
          global cmp_gammaparams $cmp_gammaparams /gamma`eq1'_`eq2'
          global cmpHasGamma = $cmpHasGamma + 1
        }
        else cmp_error 111 `"Equation `EndogVar' not found."'
      }
    }
    mata _mod.setGammaI(st_matrix("`GammaI'")); _mod.setGammaInd(st_matrix("cmpGammaInd"))
    if $cmpHasGamma {
      mata st_matrix("`GammaId'", colsum(st_matrix("`GammaI'")))
      forvalues eq=1/$cmp_d {
        if "${cmp_y`eq'}"=="." & `GammaId'[1,`eq']==1 cmp_error 481 "Coefficients in ${cmp_eq`eq'} equation are unidentified because dependent variable is entirely unobserved and does not appear in any other equation."
      }
      mat `GammaId' = `GammaINobs'
      forvalues eq1=1/`=$cmp_d-2' {
        mat `GammaId' = `GammaId' * `GammaINobs'
      }

      forvalues eq1=1/$cmp_d {
        forvalues eq2=1/$cmp_d {
          if `eq1' != `eq2' & `GammaId'[`eq1',`eq2'] {
            count if _cmp_ind`eq1' & _cmp_ind`eq2'==0
            replace _cmp_ind`eq1' = 0 if _cmp_ind`eq1' & _cmp_ind`eq2'==0
            if r(N) noi di _n as txt "(" r(N) plural(r(N)," observation") " dropped from ${cmp_eq`eq1'} equation because " cond(r(N)>1,"they are","it is") " unavailable in the ${cmp_eq`eq2'} equation, on which the ${cmp_eq`eq1'} equation depends)"
          }
        }
      }
    }

    global cmp_tot_cuts 0  // handle cut parameters now, *after* possibly deleting observations because of gamma interdependencies. which can empty a category
    forvalues eq=1/$cmp_d {
      if cmp_num_cuts[`eq',1] {
        GroupCategoricalVar if ${cmp_y`eq'} < . & `touse' & _cmp_ind`eq', predict(`predict') cmp_eqno(`eq')
        global cmp_y`eq' _cmp_y`eq'
        mat cmp_cat`eq' = r(cat)
        local t = colsof(cmp_cat`eq') - 1
        mat cmp_num_cuts[`eq',1] = `t'
        if $cmp_max_cuts < `t' global cmp_max_cuts = `t'
        global cmp_tot_cuts = $cmp_tot_cuts + `t'
        forvalues j=1/`t' {
          local cutparams `cutparams' /cut_`eq'_`j'
        }
      }
    }
    mata  _mod.setMaxCuts($cmp_max_cuts)
  }

  xi, prefix(" ") noomit `i_oprobit_ys'

	tempname Eqs
	mat `Eqs' = J($cmp_d, $parse_L, 0)
	forvalues eq = 1/$cmp_d {
		foreach id in ${cmp_id`eq'} {
			local l: list posof "`id'" in global(parse_id)
			mat `Eqs'[`eq', `l'] = "`id'"=="_n" | cmp_fixed_sigs`l'[1,`eq']>0  // don't simulate REs with variance 0
		}
	}
	mata _mod.setEqs(st_matrix("`Eqs'"))
	mat cmp_NumEff = J($parse_L, $cmp_d, 0)
	forvalues l=1/$parse_L {
		forvalues eq=1/$cmp_d {
			mat cmp_NumEff[`l', `eq'] = `cmp_NumEff`l'_`eq''
		}
	}
	mata _mod.setNumEff(st_matrix("cmp_NumEff"))
	
	local technique technique(`technique')
	_vce_parse, optlist(Robust oim opg) argoptlist(CLuster) pwallowed(robust cluster oim opg) old: `wgtexp', `robust' cluster(`cluster') vce(`vce')
	local vce `r(vceopt)'
	local robust `r(robust)'
	local cluster `r(cluster)'
	markout `touse' `cluster', strok

	if 0`hasfrac' & "`cluster'`robust'"=="" {
		local vce vce(robust)
		noi di as res _n "Note: fractional probit models imply " as inp "vce(robust)" as res "."
	}	

	tokenize $parse_id
	forvalues l = 1/`=$parse_L-1' {
		mat cmp_fixed_rhos`l' = J($cmp_d, $cmp_d, `FixedRhoFill`l'')
		local ids `ids' ``l''
		qui egen long _cmp_id`l' = group(`ids') if `touse'
	}

	forvalues l=1/$parse_L {
		forvalues j=1/$cmp_d {
			global cmp_rc`l' ${cmp_rc`l'} ${cmp_rc`l'_`j'} ${cmp_re`l'_`j'}
			forvalues k=1/`: word count ${cmp_rc`l'_`j'} ${cmp_re`l'_`j'}' {
				global cmp_rceq`l' ${cmp_rceq`l'} ${cmp_eq`j'}
			}
		}
	}

	if $parse_L == 1 { // for 1-level models, ml/svy will handle weights
		if `"$parse_wexpL"' != "" {
			tempvar wvar
			cap confirm var $parse_wexpL
			if _rc qui gen double `wvar' = $parse_wexpL if `touse'
			  else local wvar $parse_wexpL
			local wgtexp [$parse_wtypeL = `wvar']
			local awgtexp [aw = `wvar']
			markout `touse' `wvar'
		}
	}
	else {
		sort _cmp_id*, stable

		global parse_wtype$parse_L $parse_wtypeL
		global parse_wexp$parse_L $parse_wexpL
		forvalues l = 1/$parse_L {
			tempvar weight`l'
			local cmp_ids `cmp_ids' _cmp_id`l'
			if "${parse_wtype`l'}" != "" {
				if 0 & "`svy'"!="" cmp_error 101 "weights not allowed with the {bf:svy} option; the {bf:svy} option assumes survey weights were already specified using svyset"

				cap confirm var ${parse_wexp`l'}
				if _rc qui gen double `weight`l'' = ${parse_wexp`l'} if `touse'
				  else local weight`l' ${parse_wexp`l'}
				global cmp_weight`l' `weight`l''

				markout `touse' `weight`l''
				replace `touse' = 0 if `weight`l''<=0

				if "${parse_wtype`l'}" == "fweight" {
					cap assert mod(`weight`l'', 1)==0 if `touse', fast
					if _rc cmp_error 401 "Frequency weights must be integers."
				}
					
				if "${parse_wtype`l'}" == "pweight" & 0`wcluster' == 0 {
					local wcluster 1
					if "`cluster'" != "`:word `l' of $parse_id'" {
						if "`cluster'`robust'" != "" {
							di as res _n "Warning: " as txt `"[pweight = ${parse_wexp`l'}]"' as res " would usually imply " as txt "vce(cluster `:word `l' of $parse_id')."
							di as res "Implementing " as txt `"`=cond("`cluster'"=="", "robust", "cluster `cluster'")'"' as res " instead."
						}
						else {
							local vce vce(`=cond(`l'<$parse_L, "cluster `:word `l' of $parse_id'", "robust")')
							local lrtest pweight
							di as res _n "Note: " as txt `"[pweight = ${parse_wexp`l'}]"' as res " implies `vce'"
						}
					}
				}

				if `l' < $parse_L {
					tempvar t
					qui by `cmp_ids': egen float `t' = mad(`weight`l'') if `touse'
					qui assert inlist(`t', 0, .) if `touse', fast
					if _rc cmp_error 101 "Weights for level {res}`:word `l' of $parse_id'{err} must be constant within groups."
					drop `t'
				}
			}
		}

		if "`svy'"!="" {
			if "`: char _dta[_svy_wvar]'" != "" local wvar: char _dta[_svy_wvar]
			if "`wvar'" != "" {
				local wgtexp  [pw = `wvar']
				local awgtexp [aw = `wvar']
				markout `touse' `wvar'
			}
		}
		
		tokenize $parse_id // rebuild id's in case weights<=0 nix some groups
		local ids
		qui forvalues l = 1/`=$parse_L-1' {
			local ids `ids' ``l''
			drop _cmp_id`l'
			egen long _cmp_id`l' = group(`ids') if `touse'
		}
		sort _cmp_id*, stable
	}

	qui count if `touse'
	if r(N)==0 cmp_error 2000 "No observations."

	mata _mod.settodo("`lf'"=="")

	if "`predict'" != "" {
		forvalues l=1/$parse_L {
			mat cmp_fixed_rhos`l' = e(fixed_rhos`l')
			mat cmpSigScoreInds`l' = e(sig_score_inds`l')
		}
		global cmp_num_scores = e(num_scores)
		mata _mod.setNumREDraws(strtoreal(tokens("`redraws'"))')
		
		constraint drop `_constraints' `initconstraints' `1onlyinitconstraints'
	}

	mata _mod.setMprobitGroupInds(st_matrix("cmp_mprobit_group_inds" )); _mod.setRoprobitGroupInds(st_matrix("cmp_roprobit_group_inds"))
	mata _mod.setNonbaseCases(st_matrix("cmp_nonbase_cases"))
	mata _mod.setvNumCuts(st_matrix("cmp_num_cuts")); _mod.settrunceqs(st_matrix("cmp_trunceqs")); _mod.setintregeqs(st_matrix("cmp_intregeqs"))

// /lnsigEx_[lev] accross (ergo within too), exchangeable
// /lnsigEx accross, bottom
// /lnsigEx_[lev]_[eq] within-equation, exchangeable
// /lnsig_[coef]_[lev]_[eq] unstructured
// /lnsig_[eq] bottom level
	if "${cmp_cov$parse_L}" == "exchangeable" {
		local sigparams$parse_L `sigparams$parse_L' /`ln'sigEx
	}
	forvalues l=1/`=$parse_L-1' {
		if "${cmp_cov`l'}" == "exchangeable" {
			local sigparams`l' `sigparams`l'' /`ln'sigEx_`l'
		}
		else {
			forvalues eq=1/$cmp_d {
				if cmp_nonbase_cases[1,`eq'] { 
					if "${cmp_cov`l'_`eq'}" == "exchangeable" {
						local sigparams`l' `sigparams`l'' /`ln'sigEx_`l'_`eq'
					}
					else {
						forvalues c=1/`:word count ${cmp_rc`l'_`eq'}' {
							local sigparams`l' `sigparams`l'' /`ln'sig_`c'_`l'_`eq'
						}
						if "${cmp_re`l'_`eq'}"!="" local sigparams`l' `sigparams`l'' /`ln'sig_`l'_`eq'
					}
				}
			}
		}
	}

// /atanhrhoEx_[lev] across, exchangeable
// /atanhrhoEx across, exchangeable, bottom level
// /atanhrhoEx_[lev]_[eq] within-equation, exchangeable
// /atanhrho_[coef1]_[coef2]_[lev]_[eq] within, unstructured
// /atanhrho_[eq1][eq2] across, bottom level
// /atanhrho_[lev]_[eq1][eq2] across, upper levels, REs on both sides
// /atanhrho_[coef1]_[coef2]_[lev]_[eq1][eq2] across, upper levels, REs not on both sides
	forvalues l=$parse_L(-1)1 {
		if "${cmp_cov`l'}" == "exchangeable" {
			local sigparams`l' `sigparams`l'' /`atanh'rhoEx`=cond(`l'<$parse_L,"_`l'","")'
		}
		forvalues eq1=1/$cmp_d {
			if "${cmp_cov`l'_`eq1'}"=="exchangeable" & cmp_NumEff[`l', `eq1'] & cmp_nonbase_cases[1,`eq1'] {
				local sigparams`l' `sigparams`l'' /`atanh'rhoEx_`l'_`eq1'
			}
			forvalues c1=1/`=cmp_NumEff[`l', `eq1']' {
				if "${cmp_cov`l'_`eq1'}"=="unstructured" {
					forvalues c2=`=`c1'+1'/`=cmp_NumEff[`l', `eq1']' {
						local sigparams`l' `sigparams`l'' /`atanh'rho_`c1'_`c2'_`l'_`eq1'
					}
				}
				forvalues eq2=`=`eq1'+1'/$cmp_d {
					if cmp_nonbase_cases[1,`eq1'] & cmp_nonbase_cases[1,`eq2'] {
						if cmp_fixed_rhos`l'[`eq2',`eq1']==. &  "${cmp_cov`l'}" == "unstructured" {
							forvalues c2=1/`=cmp_NumEff[`l', `eq2']' {
								local sigparams`l' `sigparams`l'' /`atanh'rho`=cond("`:word `c1' of ${cmp_rc`l'_`eq1'}'`:word `c2' of ${cmp_rc`l'_`eq2'}'"=="","","_`c1'_`c2'")'`_l'_`eq1'`eq2'
							}
						}
					}
					else mat cmp_fixed_rhos`l'[`eq2',`eq1'] = 0
				}
			}
		}
		local _l _`=`l'-1'
	}
	forvalues l=1/$parse_L {
		local sigparams `sigparams' `sigparams`l''
	}
	local auxparams `cutparams' `sigparams'

	if "`predict'" != "" {
		local 0 `predict'
		syntax if/, [lnl(varname) scores(varlist) EQuation(string)]
		local s = cond(0`e(k_gamma)'`e(k_gamma_reducedform)', "s", "")  // for gamma models, make sure to use structural parameter set
		tempname hold
    _est hold `hold', copy restore
		local model `e(model)'
		version 11: ml model `:subinstr local model ": . =" ": _cmp_ind1 =", all' if e(sample) & `if', collinear missing  // XXX incorporating user's if restriction here will affect results in hierarchical models?? too soon?
		mata _mod.settodo("`scores'"!=""); st_local("rc", strofreal(_mod.cmp_init($ML_M)))
    if `rc' error `rc'
		_est unhold `hold'
		mata _lnf = _S = _H = .
		mata moptimize_init_userinfo($ML_M, 1, &_mod)
    mata (void) cmp_lf1($ML_M, "`scores'"!="", st_matrix("e(b`s')"), _lnf, _S, _H)
		if "`lnl'" != "" mata st_view(_H, ., "`lnl'", st_global("ML_samp")); _H[,] = _lnf
    else {  // scores requested
      mata st_view(_H, ., "`scores'", st_global("ML_samp"))
      if "`e(resultsform)'" == "reduced" {
        di as err "cmp: Won't compute scores on reduced-form results. " _c
        if "`c(prefix)'"=="svy" di as err "Try estimating with cmp's svy option instead of the svy prefix." _c
        di _n _n
      }
//    if "`e(resultsform)'" == "reduced" mata _H[,] = _S * ("`equation'" == ""? st_matrix("e(dbr_db)") : st_matrix("e(dbr_db)")[`equation',])'
        else                             mata _H[,] =       "`equation'" == ""? _S                     : _S                    [,`equation']
    }
		cmp_clear
		exit 0
	}

  ereturn clear
	tempname b cmpInitFull
	// Fit individual models before mis-specifed and constant-only ones in case perfect probit predictors shrink some eq samples
	// Do InitSearch even if user specifies init() to check for that and to build fully labelled parameter vector for constraint work in Estimate
	if "`init'" == "" {
		di as res _n "Fitting individual models as starting point for full model fit."
		`quietly' di as res "Note: For programming reasons, these initial estimates may deviate from your specification."
		`quietly' di as res "      For exact fits of each equation alone, run cmp separately on each."
	}

	`quietly' DoInitSearch InitSearch if `touse' `=cond("`subpop'"!="","& `subpop'","")' `wgtexp', `svy' adjustprobitsample `drop' auxparams(`auxparams') `=cond("`init'" == "", "", "quietly")' mlopts(`mlopts')
	mat `cmpInitFull' = r(b)
	local ParamsDisplay `r(ParamsDisplay)'
	local XVarsAll `r(XVarsAll)'

	if "`estimate'" != "" {
		mat colnames `cmpInitFull' = `ParamsDisplay'
		NoEstimate `cmpInitFull' `wgtexp'
		ereturn display
		cmp_clear
		di as res _n `"Full model not fit. To view the initial coefficient matrix, type or click on {stata "mat list e(b)"}."'
		di as res "You can copy and modify this matrix, then pass it back to {cmd:cmp} with the {cmd:init()} option."
		exit 0
	}

	local initconstraints `r(initconstraints)'
	local auxparams `r(auxparams)'
	global cmp_num_scores = $cmpHasGamma + $cmp_d + `:word count `auxparams''

	tempvar t
	egen byte `t' = anycount(_cmp_ind*), values(0)
	qui replace `touse' = 0 if `t'==$cmp_d
	qui count if `touse'
	if r(N)==0 cmp_error 2000 "No observations."
	drop `t'

	tokenize $parse_id
	cap drop _cmp_id*
	local ids
	if $parse_L > 1 {
		forvalues l = 1/`=$parse_L-1' {
			local ids `ids' ``l''
			qui egen long _cmp_id`l' = group(`ids') if `touse' // rebuild these in case whole groups dropped, forcing renumbering
		}
		sort _cmp_id*, stable
	}

	forvalues i=1/$cmp_d { // save these for full fit in case they get modified by 1only or meff calls to InitSearch
		local cmp_x`i' ${cmp_x`i'}
		local cmp_xc`i' ${cmp_xc`i'}
	}

	if "`meff'" != "" {
		di as res _n "Fitting misspecified model."
		qui InitSearch if `touse' `=cond("`subpop'"!="","& `subpop'","")', `drop' auxparams(`auxparams') mlopts(`mlopts')
		mat `b' = r(b)
		Estimate if `touse' `=cond("`subpop'"!="","& `subpop'","")', init(`init') cmpinit(`b') `vce' auxparams(`auxparams') psampling(`psampling') resteps(`steps') `lf' ///
			`constraints' _constraints(`_constraints' `initconstraints') `autoconstrain' mlopts(`mlopts') `iterate' `technique' `quietly' redraws(`redraws') paramsdisplay(`r(ParamsDisplay)') `interactive'
		if _rc==0 {
			tempname vsmp
			mat `vsmp' = e(V)
		}
	}

	if `"`lrtest'`constraints'`robust'`cluster'`estimate'`svy'`hasfrac'"'=="" & "`weight'"!="pweight" & "$parse_x"!="" {
		local HasGamma $cmpHasGamma
		global cmp_num_scores = $cmp_num_scores - $cmpHasGamma
		global cmpHasGamma 0
		mata _mod.setGammaInd(J(0,0,0))

		di as res _n "Fitting " plural($cmp_d>1, "constant") "-only model for LR test of overall model fit."
		qui InitSearch if `touse' `=cond("`subpop'"!="","& `subpop'","")' `wgtexp', `svy' 1only  auxparams(`auxparams') mlopts(`mlopts')
		local 1onlyinitconstraints `r(initconstraints)'
		mat `b' = r(b)
		qui Estimate if `touse' `wgtexp', cmpinit(`b') `constraints' _constraints(`_constraints' `1onlyinitconstraints') `autoconstrain' psampling(`psampling') resteps(`steps') `lf' ///
		                `svy' subpop(`subpop') modopts(`modopts') mlopts(`mlopts') `iterate' `technique' auxparams(`r(auxparams)') 1only `quietly' redraws(`redraws') paramsdisplay(`r(ParamsDisplay)') `interactive'
		if _rc==0 local lf0opt lf0(`e(rank)' `e(ll)')

		global cmpHasGamma `HasGamma'
		global cmp_num_scores = $cmp_num_scores + $cmpHasGamma
	}
	mata _mod.setGammaInd(st_matrix("cmpGammaInd"))  // hidden from constants-only fit

	tempname LeftCens RightCens
	qui {
		forvalues eq=1/$cmp_d {
			if "${cmp_y`eq'}" != "." {
				cap   gen byte `LeftCens'  = _cmp_ind`eq'==$cmp_int & `touse' & ${cmp_y`eq'_L}>=.
				if _rc==0 {
					replace   _cmp_ind`eq' = $cmp_left      if `LeftCens'  // Having gotten initial fits treating as intreg,
					cap gen byte `RightCens' = _cmp_ind`eq'==$cmp_int & `touse' & ${cmp_y`eq'  }>=.
					cap assert `RightCens'==0, fast
					if _rc==0 {
						replace _cmp_ind`eq' = $cmp_right     if `RightCens' // helps speed & precision to treat left & right
						if strpos("${cmp_y`eq'}", ".") {
							fvrevar ${cmp_y`eq'}
							global cmp_y`eq' `r(varlist)'
						}
						replace ${cmp_y`eq'} = ${cmp_y`eq'_L} if `RightCens' // intreg cases as bounded on only one side
					}
				}
			}
			global cmp_x`eq'  `cmp_x`eq''
			global cmp_xc`eq' `cmp_xc`eq''
		}

		replace _cmp_ind`cmp_eqno' = $cmp_probit   if `touse' & _cmp_ind`cmp_eqno' == $cmp_frac & `:word 1 of ${cmp_y`cmp_eqno'}'==0 // for speed, model frac probit boundary values as probit
		replace _cmp_ind`cmp_eqno' = $cmp_probity1 if `touse' & _cmp_ind`cmp_eqno' == $cmp_frac & `:word 1 of ${cmp_y`cmp_eqno'}'==1
	}

	if $parse_L==1 & $cmpSigXform {
		foreach param in `auxparams' {
			if substr("`param'", 2, 2) == "ln" {
				local diparmopt `diparmopt' diparm(`=substr("`param'", 2, .)', exp label("`=substr("`param'", 4, .)'"))
			}
			else if substr("`param'", 2, 5) == "atanh" {
				local diparmopt `diparmopt' diparm(`=substr("`param'", 2, .)', tanh label("`=substr("`param'", 7, .)'"))
			}
		}
	}

	di as res _n "Fitting full model."

	cmp_full_model if `touse' `wgtexp', `vce' `lf0opt' modopts(`modopts') mlopts(`mlopts') `iterate' `technique' `lf' paramsdisplay(`ParamsDisplay') xvarsall(`XVarsAll') ///
		`constraints' _constraints(`_constraints' `initconstraints') init(`init') cmpinit(`cmpInitFull') `svy' subpop(`subpop') psampling(`psampling') ///
		`quietly' auxparams(`auxparams') cmdline(`"`cmdline'"') resteps(`steps') redraws(`redraws') intpoints(`intpoints') ///
		vsmp(`vsmp') meff(`meff') ghkanti(`ghkanti') ghkdraws(`ghkdraws') ghktype(`ghktype') ghkscramble(`ghkscramble') diparmopt(`diparmopt') `interactive'
	constraint drop `_constraints' `initconstraints' `1onlyinitconstraints'

	if e(cmd)=="cmp" Display, `diopts'
end

cap program drop ParseEqs
program define ParseEqs
	version 11
	local _cons _cons
	global parse_d 0

	local 0: subinstr local 0 "<-" "=", all

	gettoken eq eqs: 0, match(parenflag)
	while `"`eq'"' != "" {
		global parse_d = $parse_d + 1

		tokenize `"`eq'"', parse(" :")
		if "`2'" == ":" {
			confirm name `1'
			global parse_eq$parse_d `1'
			macro shift 2
		}

		local eq `"`*'"'
		gettoken 0 eq: eq, parse("=|:")
		if `"`0'"' != "|" { // includes an FE equation?
			if `"`0'"' == "=" | `"`0'"' == "." {
				if "${parse_eq$parse_d}"=="" cmp_error 198 "Equations with unobserved dependent variables must be named. Example: {cmd: (X: = x1)}."
				global parse_y$parse_d .
				if `"`0'"' == "." gettoken 0 eq: eq, parse("=|:")
			}
			else {
				fvunab myy: `0'
				global parse_y$parse_d `myy'
				gettoken 0 eq: eq, parse("=")
				if `"`0'"' != "=" cmp_error 198 `"Missing "=": (`0')"'
			}
			global parse_y $parse_y ${parse_y$parse_d}

			gettoken 0 eq: eq, parse("|")
			if "`0'" == "|" {
				local 0
				local eq |`eq'
			}

			syntax [anything], [noCONStant OFFset(varname) EXPosure(varname) TRUNCpoints(string) iia]
			tokenize `anything'
			while `"`1'"' != "" {
				if substr(`"`1'"',strlen(`"`1'"'),1)=="#" global parse_yR$parse_d ${parse_yR$parse_d} `=substr(`"`1'"', 1, strlen(`"`1'"')-1)'
					else local varlist `varlist' `1'
				macro shift
			}
			if "`varlist'" != "" {
				fvunab varlist: `varlist'
				global parse_x$parse_d `varlist'
				global parse_x $parse_x `varlist'
				global parse_iia$parse_d `iia'
			}
			if "`constant'" != "" global parse_xc$parse_d nocons
			if "`offset'`exposure'"!="" {
				if "`offset'" != "" & "`exposure'" != "" cmp_error 198 "cannot specify both offset() and exposure()"
				global parse_xo$parse_d `offset'
				global parse_xe$parse_d `exposure'
			}
			if `"`truncpoints'"' != "" {
				if "${parse_y$parse_d}"=="." cmp_error 198 "Unobserved dependent variable can't be truncated."
				tokenize `"`truncpoints'"'
				if `"`3'"' != "" | `"`2'"'=="" cmp_error 198 `"truncpoints(`"`truncpoints'"') invalid. Must have two arguments. Arguments with spaces must be quoted."'
				global parse_tr$parse_d `truncpoints'
			}
		}
		else local eq |`eq' // if no FE eq, stick the | back on the beginning
		
		gettoken 0 eq: eq, parse("|")
		while `"`0'"' != "" {
			gettoken 0 eq: eq, parse("|")
			if `"`0'"' != "|" cmp_error 198 `""|" not allowed in equation specification. Use "||"."'

			gettoken 0 eq: eq, parse("|")
			tokenize `"`0'"'
			local id `1'
			confirm name `id'
			if "`2'" != ":" cmp_error 198 `"Specify random effects starting with the group identifier variable and a ":"."'

			global parse_id: list global(parse_id) | id
			global parse_id$parse_d: list global(parse_id$parse_d) | id
			local L: list posof "`id'" in global(parse_id)
			macro shift 2
		
			local 0 `*'
			syntax [varlist(fv ts default=none)] [fw aw pw iw/], [noCONStant COVariance(string)]

			if "`varlist'"!="" fvexpand `varlist'
      local varlist
      foreach var in `r(varlist)' {
        _ms_parse_parts `var'
        if !r(omit) local varlist `varlist' `var'
      }

			if `"`weight'`exp'"' != "" {
				if `"${parse_wtype`L'}${parse_wexp`L'}"' == ""  {
					global parse_wtype`L' `weight'
					global parse_wexp`L' `"`exp'"'
					if "`weight'"=="fweight" global parse_fweight 1
				}
				else if "${parse_wtype`L'}"!="`weight'" | `"${parse_wexp`L'}"'!=`"`exp'"' cmp_error 198 "Weights for the `id' level specified more than once."
			}

			if "`varlist'"=="" & "`constant'"!="" di as res "Warning: No random effect or coefficients specified for the `id' level of the ${parse_y$parse_d} equation."

			if "`constant'" == "" global parse_re`L'_$parse_d _cons
			global parse_rc`L'_$parse_d `varlist'
			
			if inlist(`"`covariance'"', ".", "") global parse_cov`L'_$parse_d unstructured
			else {
				local 0, `covariance'
				syntax, [UNstructured EXchangeable INDependent]
				global parse_cov`L'_$parse_d `unstructured'`exchangeable'`independent'
				if inlist("${parse_cov`L'_$parse_d}", "unstructured", "exchangeable", "independent") == 0 {
					cmp_error 198 `"Each entry in the {cmdab:cov:ariance()} option must be "unstructured", "." (equivalent to "unstructured"), "exchangeable", or "independent"."'
				}
			}

			gettoken 0 eq: eq, parse("|")
		}
		global parse_id$parse_d ${parse_id$parse_d} _n

		if subinstr(`"`eqs'"', " ", "", .) == "[]" gettoken eq eqs: eqs, match(parenflag) // "[]" as weight clause ends up in "anything" section in main syntax command, passed here

		gettoken eq eqs: eqs, match(parenflag)
	}

	global parse_L: word count $parse_id

	if $parse_L > 1 { // draw together partial orderings implied by random effect sequences in each equation
		mata _X = I($parse_L)
		forvalues i=1/$parse_d {
			tokenize ${parse_id`i'}
			forvalues j=1/`=`:word count ${parse_id`i'}'-2' {
				mata _X[`:list posof "``j''" in global(parse_id)',`:list posof "``=`j'+1''" in global(parse_id)'] = 1
			}
		}
		mata _Y = _X; for (i=$parse_L-1; i; i--) _Y = _Y * _X
		mata _p = order(rowsum(_Y:!=0), -1) // permutation to make Y upper triangular
		mata st_local("t", strofreal(all(vech(_Y'[_p,_p]))))
		if `t' mata st_global("parse_id", invtokens(tokens("$parse_id")[_p]))
		else {
			di as err "Cannot determine hierarchical order of levels."
			di as err `"You can add a dummy equation like ""' as res "( || id1: || id2: || id3:)" as err `"" to specify the full ordering."'
			di as err "Don't include this equation in the " as res "indicators()" as err " option."
			cmp_error 110
		}

		forvalues l=1/$parse_L { // rearrange RE and RC macros to reflect any corrections to level numbers assigned in initial parsing pass.
			forvalues i=1/$parse_d {
				foreach macro in re rc cov {
					mata st_local("_parse_`macro'`l'_`i'", st_global("parse_`macro'"+strofreal(_p[`l'])+"_`i'"))
				}
			}
		}
		forvalues l=1/$parse_L {
			forvalues i=1/$parse_d {
				foreach macro in re rc cov {
					global parse_`macro'`l'_`i' `_parse_`macro'`l'_`i''
				}
			}
		}
	}

	local i 0
	forvalues j=1/$parse_d { // expunge dummy eqs
		if "${parse_y`j'}${parse_eq`j'}" != "" {
			if `++i' != `j' {
				foreach macro in eq y yR x xo xe xc tr id {
					global parse_`macro'`i' ${parse_`macro'`j'}
					global parse_`macro'`j'
				}
				forvalues l=1/$parse_L {
					foreach macro in rc re {
						global parse_`macro'`l'_`i' ${parse_`macro'`l'_`j'}
						global parse_`macro'`l'_`j'
					}
				}
			}

			if "${parse_eq`i'}" == "" {
				global parse_eq`i' eq`i'
			}
			local eqnames `eqnames' ${parse_eq$`i'}
		}
	}
	global parse_d `i'
	forvalues j=1/$parse_d { // will cause to generate and extract /atanhrho params to work correctly for bottom level
		global parse_re$parse_L_`j' _cons
	}

	local t: list dups eqnames
	if "`t'" != "" cmp_error 110 "Multiply defined equations: `t'"
	
	global parse_id $parse_id _n
	global parse_L: word count $parse_id
end

* Parses and implements corr() option as constraint set
/*cap program drop ParseCorr
program define ParseCorr, rclass
	version 11
	
	if `"`0'"' == "."
	
	gettoken token 0: 0, parse(" *@")
	while `"`token'"' != "" {
		local eq1: list posof "`token'" in global(cmp_eq)
		if `eq1'==0 cmp_error 198 "`token' equation not found."
		gettoken token 0: 0, parse(" *@")
		local eq2 0
		if `"`token'"' == "*" {
			gettoken token 0: 0, parse(" *@")
			local eq2: list posof "`token'" in global(cmp_eq)
			if `eq2'==0 cmp_error 198 "`token' equation not found."
		}
		gettoken token 0: 0, parse(" *@")
		if `"`token'"'=="@" {
			gettoken token 0: 0, parse(" *@")
			cap confirm number `token'
			if _rc {
				cap confirm name `token'
				if _rc cmp_error 198 `""`token'" found where name or number expected."'
				local ConstraintGroupID: list posof "`token'" in ConstraintGroupNames
				
			}	
			gettoken token 0: 0, parse(" *@")
		}

	}
end*/

* These lines are in a subroutine to work around Stata parsing bug with "if...quietly {"
cap program drop DoInitSearch
program define DoInitSearch, rclass
	version 11
	`*'  // run InitSearch
	tempname b
	mat `b' = r(b)
	return matrix b = `b'
	return local auxparams `r(auxparams)'
	return local initconstraints `r(initconstraints)'
	return local ParamsDisplay `r(ParamsDisplay)'
	return local XVarsAll `r(XVarsAll)'
end

* perform full estimate. Program cmp is not eclass, so it can be called for non-estimating purposes without obliterating current estimates
* cmp_full_model is eclass, so it performs and saves full estimate
cap program drop cmp_full_model
program define cmp_full_model, eclass
	version 11
	syntax if/ [pw fw aw iw], [auxparams(string) vsmp(string) meff(string) paramsdisplay(string) xvarsall(string) ///
					ghkanti(string) ghkdraws(string) ghktype(string) ghkscramble(string) diparmopt(string) cmdline(string) ///
					redraws(string) resteps(string) retype(string) reanti(string) intpoints(string) svy *]

	Estimate if `if' [`weight'`exp'], auxparams(`auxparams') paramsdisplay(`paramsdisplay') resteps(`resteps') redraws(`redraws') `svy' `options'

	if _rc==0 {
		if "`meff'" != "" _svy_mkmeff `vsmp'

		ereturn scalar sigxform = $cmpSigXform
		ereturn scalar L = $parse_L
		ereturn local ivars $parse_id
		ereturn mat NumEff = cmp_NumEff
		forvalues l=$parse_L(-1)1 {
			ereturn mat fixed_rhos`l' = cmp_fixed_rhos`l'
			ereturn mat fixed_sigs`l' = cmp_fixed_sigs`l'
			cap ereturn mat sig_score_inds`l' = cmpSigScoreInds`l'
			ereturn local covariance ${cmp_cov`l'} `e(covariance)'
			forvalues eq=$cmp_d(-1)1 {
				ereturn local covariance`eq' ${cmp_cov`l'_`eq'} `e(covariance`eq')'
				ereturn local EffNames`l'_`eq' ${cmp_rc`l'_`eq'} ${cmp_re`l'_`eq'}
			}
		}

		if $cmpHasGamma {  // prepare to build reduced-form b and V
			mat cmpGammaInd = .,. \ cmpGammaInd[1..rowsof(cmpGammaInd), 1...]

			tempname b beq Beta
			mat `b' = e(b)
			if "`xvarsall'" != "" mat `Beta'  = J($cmp_d, `:word count `xvarsall'', 0)
			mat cmpBetaInd  = .,.
			local cols 0
			forvalues eq=1/$cmp_d {
				mat `beq' = `b'[1,"`:word `eq' of $cmp_eq':"] // `b'[1,"#`eq'"] doesn't work in Stata 10
				local colnames: colnames `beq'
				local cols = `cols' + colsof(`beq')
				forvalues i=1/`=colsof(`beq')' {
					local var: word `i' of `colnames'
					local j: list posof "`var'" in xvarsall
					mat `Beta'[`eq',`j'] = `beq'[1,`i']
					mat cmpBetaInd  = cmpBetaInd  \ `j',`eq'
				}
			}

			local _cons _cons
			local l_
			if $cmpSigXform {
				local ln ln
				local atanh atanh
			}
			forvalues l=$parse_L(-1)1 {
				local cmp_rcu`l': list uniq global(cmp_rc`l')
				local hascons = "`:list cmp_rcu`l' & _cons'" != ""
				if `hascons' local cmp_rcu`l' `: list cmp_rcu`l' - _cons' _cons // move _cons to end
				local k: word count `cmp_rcu`l''
				forvalues eq1=1/$cmp_d {
					foreach var in ${cmp_rc`l'_`eq1'} ${cmp_re`l'_`eq1'} {
						local j: list posof "`var'" in cmp_rcu`l'
						mat cmpREInd`l' = nullmat(cmpREInd`l')  \ `eq1',`j'
					}
					forvalues c1=1/`k' {
						local sigparams`l' `sigparams`l'' `ln'sig_`=cond(`hascons' & `c1'==`k', "", "`c1'_")'`l_'`eq1'
						forvalues c2=`=`c1'+1'/`k' {
							local rhoparams`l' `rhoparams`l'' `atanh'rho_`c1'_`c2'_`l'_`eq1'
						}
						forvalues eq2=`=`eq1'+1'/$cmp_d {
							forvalues c2=1/`k' {
								local rhoparams`l' `rhoparams`l'' `atanh'rho`=cond(`hascons' & `c1'==`k' & `c2'==`k', "", "_`c1'_`c2'")'_`l_'`eq1'`eq2'
							}
						}
					}
				}
				local l_ `=`l'-1'_
			}
		}

		mata _mod.SaveSomeResults() // Get final Sig; if weights, get weighted sample size; for Gamma models build e(br), e(Vr)

		if $cmpHasGamma {  // eliminate unnecessary "#"'s in e(b) colnames, unnecessary for predict that is, which wrongly imply that variable is unobserved
			mat colnames `b' = `paramsdisplay'
			local paramsdisplay: colnames `b'
			forvalues eq=1/$cmp_d {
				local eqname `:word `eq' of $cmp_eq'
				local eqnamep `eqname'#
				if "`:list eqnamep & paramsdisplay'" != "" {
					cap assert _cmp_ind`eq'<=1 if e(sample), `=cond(c(stata_version)>=12.1,"fast","")'
					if _rc==0 local paramsdisplay: subinstr local paramsdisplay "`eqname'#" "`eqname'", word all
				}
			}
			mat colnames `b' = `paramsdisplay'
			ereturn local params `:colfullnames `b''
			mat `b' = e(b)
			ereturn matrix bs = `b'
			mat `b' = e(V)
			ereturn matrix Vs = `b'
		}
		ereturn local resultsform structural
		
		if "`1only'"=="" & "`e(chi2type)'"=="Wald" {
			local t
			forvalues eq=1/$cmp_d {
				cap test ([${cmp_eq`eq'}]) // crashes if cons only
				if _rc==0 local t `t' ([${cmp_eq`eq'}])
			}
			if "`t'" != "" {
				qui test `t'
				ereturn scalar df_m = r(df)
				ereturn scalar p = r(p)
				ereturn scalar chi2 = r(chi2)
			}
		}

		if "`svy'" != "" & "`: char _dta[_svy_wvar]'" != "" {  // compensate for bug in Stata 14, 15 because of which ml model, svy puts references to temp var in these macros
			ereturn local wtype: char _dta[_svy_wtype]
			ereturn local wvar : char _dta[_svy_wvar]
			ereturn local wexp "= `e(wvar)'"
		}
		else if "$parse_wexpL"!="" ereturn local wexp `"= $parse_wexpL"'

		forvalues eq=$cmp_d(-1)1 {  // doing in reverse order seems to get proper order in displayed results
			qui count if e(sample) & _cmp_ind`eq'
			ereturn scalar N`eq' = r(N)
		}

		tempname cat t
		forvalues i=1/$cmp_d {  // capture all _cmp_y* labels, from oprobit and non-as mprobit eqs, for later use if called from cmp_p
			cap confirm matrix cmp_cat`i'
			if _rc mat `t' = J(1, $cmp_max_cuts+1, .)
			else {
				if colsof(cmp_cat`i') <= $cmp_max_cuts mat `t' = cmp_cat`i', J(1, $cmp_max_cuts-colsof(cmp_cat`i')+1, .)
				  else                                 mat `t' = cmp_cat`i'
			}
			mat `cat' = nullmat(`cat') \ `t'
		}
		mat rownames `cat' = $cmp_eq

		ereturn mat cat = `cat'
		mat `t' = cmp_num_cuts
		mat rownames `t' = $cmp_eq
		ereturn mat num_cuts = `t'

		if "``intpoints'" != "" {
			ereturn local n_quad `intpoints'
			ereturn local quad_method = cond($cmp_IntMethod, "mvaghermite", "ghermite")
		}
	
		ereturn scalar num_scores = $cmp_num_scores
		mata st_local("ghkdraws", strofreal(_mod.getGHKDraws()))
		foreach macro in diparmopt ghkanti ghkdraws ghktype retype reanti intpoints {
			ereturn local `macro' ``macro''
		}
		if `resteps' > 1 ereturn local resteps `resteps'
		ereturn local ghkscramble `ghkscramble'
		ereturn local depvar $parse_y
		ereturn local indicators = `"`indicators'"'
		ereturn local eqnames $cmp_eq `:subinstr local auxparams "/" "", all'
		ereturn local predict cmp_p
		ereturn local title Mixed-process `=cond($parse_L>1, "multilevel ", "")'regression
		ereturn local cmdline cmp `cmdline'
		ereturn local cmd cmp
	}
	cmp_clear
	if _rc==1 error 1
end

cap program drop NoEstimate
program NoEstimate, eclass
	version 11
	ereturn post `0'
	ereturn local title Mixed-process regression--initial fits only
	ereturn local cmdline cmp `cmdline'
	ereturn local cmd cmp
end

cap program drop Estimate
program Estimate, eclass
	version 11
	syntax if/ [fw aw pw iw], [auxparams(string) psampling(string) svy subpop(passthru) autoconstrain paramsdisplay(string) ///
		modopts(string) mlopts(string) iterate(passthru) init(string) cmpinit(string) constraints(string) _constraints(string) technique(string) vce(string) 1only quietly resteps(string) redraws(string) interactive lf *]

	if "`svy'" == "" {
  	if "`weight'" != "" local awgtexp [aw`exp']
    local weightexp `weight'`exp'
  }

	tempname _init
	if "`init'" == "" local _init `cmpinit'
		else {
			mat `_init' = `init'
			cap mat colnames `_init' = `:colfullnames `cmpinit''
			if _rc cmp_error 503 "init() matrix should 1 x `:word count `:colfullnames `cmpinit'''."
		}

	if $cmpSigXform {
		local ln ln
		local atanh atanh
	}

	forvalues eq=1/$cmp_d { 
		local model `model' (${cmp_eq`eq'}: `=cond("${cmp_y`eq'}"==".", "`ind1'", "${cmp_y`eq'}")' = // ml doesn't like "." for a depvar
		if "`1only'"=="" local model `model' ${cmp_x`eq'}
		local model `model', ${cmp_xc`eq'} offset(${cmp_xo`eq'}) exposure(${cmp_xe`eq'}))
	}
	if "`1only'"=="" local model `model' $cmp_gammaparams
	local model `model' `auxparams'
	local modeldisplay: subinstr local model ": `ind1' =" ": . =", all

	if "`constraints'" != "" {
		cap confirm matrix `constraints'
		if _rc {
			tempname b
			local _paramsdisplay `paramsdisplay'
			if $cmpHasGamma {  // makeCns can't handle constraints with names suffixed by #; rename temporarily
				foreach c of numlist `constraints' {  // make temporary copy of constraint set
					constraint free
					constraint `r(free)' `:constraint `c''
					local __constraints `__constraints' `r(free)'
				}
				local i 0
				forvalues eq=1/$cmp_d {
					tempname v`++i'
					foreach c of numlist `__constraints' {
						local thisConstraint: constraint `c'
						constraint `c' `:subinstr local thisConstraint "${cmp_eq`eq'}#" "`v`i''", all'
					}
					local _paramsdisplay: subinstr local _paramsdisplay "${cmp_eq`eq'}#" "`v`i''", all
				}
			}
			else local __constraints `constraints'
			mat `b' = `cmpinit'
			mat colnames `b' = `_paramsdisplay'
			ereturn post `b'
			makecns `__constraints'
			if $cmpHasGamma constraint drop `__constraints'
			tempname constraints
			cap mat `constraints' = e(Cns)

			if _rc local constraints
		}
	}
	if "`_constraints'" != "" {
		tempname b
		mat `b' = `cmpinit'
		ereturn post `b'
		makecns `_constraints'
		if "`e(Cns)'"!="" {
			if "`constraints'"=="" {
				tempname constraints
				mat `constraints' =                          e(Cns)
			}
			else {
				mat `constraints' = nullmat(`constraints') \ e(Cns)
			}
		}
	}

	tempname b sample
	mata _mod.setWillAdapt($cmp_IntMethod)

	if "`psampling'" == "" {
		local psampling_cutoff 1
		local psampling_rate 2
		local u 1
	}
	else {
		qui count if `if'
		local N = r(N)
		tokenize `psampling'
		local psampling_cutoff = cond(`1'>=1, `1'/`N', `1')
		local psampling_rate = cond(0`2', 0`2', 2)
		tempvar u
		gen `u' = uniform() if `if'
	}

	local gf = $parse_L > 1 & "`1only'" == ""

	while `psampling_cutoff' < `psampling_rate' {
		if "`psampling'" != "" {
			if `psampling_cutoff' < 1 di as res _n "Fitting on approximately " %1.0f `psampling_cutoff'*`N' " observations (approximately " %1.0f `psampling_cutoff'*100 "% of the sample)."
			else di as res _n "Fitting on full sample."
		}

		if `resteps'>1 mata _NumREDraws = J(`=$parse_L-1', 1, 1) :/ (_DrawMultipliers = strtoreal(tokens("`redraws'"))' :^ (1/(`resteps'-1)))

		forvalues restep = 1/`resteps' {
			if `restep' < `resteps' mata _NumREDraws = _NumREDraws:*_DrawMultipliers
												 else mata _NumREDraws = strtoreal(tokens("`redraws'"))'

			if "`_init'" != "" local initopt init(`_init', copy)

			mata _mod.setNumREDraws(ceil(_NumREDraws))

			local _if if (`if') `=cond("`psampling'" != "", "& (`psampling_cutoff'>=1 | `u'<=.001+`psampling_cutoff')", "")'

			local method = cond(`gf' & "`svy'"!="", "gf`="`lf'"==""' cmp_gf1()", `"lf`="`lf'"==""' cmp_lf1()"')

			local final = `psampling_cutoff'>=1 & `restep'==`resteps'

			if `final' {
				local this_technique `technique'
				local this_iterate `iterate'
				if `gf' & "`svy'"=="" & "`vce'"!="opg" {
					local this_vce opg // faster than oim for lf1, gf1; this interim VCV ignored anyway
					local this_mlopts
				}
				else  {
					local this_mlopts `mlopts'
					local this_vce `vce'
				}
			}
			else {
				local this_mlopts nrtol(.001) tolerance(.001)
				local this_technique = cond($cmp_IntMethod, "bhhh", "nr")
				local this_technique nr
				if "`svy'"=="" local this_vce opg // faster than oim for lf1, gf1; this interim VCV ignored anyway; but vce() can't be combined with svy
			}

			local mlmodelcmd `model' `=cond(`final' & "`1only'"=="","[`weightexp'] `_if', `options'", "`awgtexp' `_if',")' ///
				`svy' `subpop' constraints(`constraints') nocnsnotes nopreserve missing collinear `modopts'
			local mlmaxcmd `quietly' ml max, search(off) nooutput

			`quietly' ml model `method' `mlmodelcmd' vce(`this_vce') `initopt' technique(`this_technique') `=cond(`gf' & "`svy'"!="", "group(_cmp_id1)", "")'
			mata moptimize_init_userinfo($ML_M, 1, &_mod)
      mata moptimize_init_nmsimplexdeltas($ML_M, .1)  // in case nm used

			mata st_local("rc", strofreal(_mod.cmp_init($ML_M)))
      if `rc' error `rc'

			capture noisily `mlmaxcmd' noclear `this_mlopts' `iterate'  // Estimate!

			if _rc==1400 {
				di as res "Restarting search with parameters all 0."
				tempname zeroes
				mat `zeroes' = J(1, `=colsof(`_init')', 0)
				`quietly' ml model `method' `mlmodelcmd' vce(`this_vce') init(`zeroes', copy) technique(`this_technique')
        mata moptimize_init_userinfo($ML_M, 1, &_mod)
        mata moptimize_init_nmsimplexdeltas($ML_M, .1)  // in case nm used
				capture noisily `mlmaxcmd' `this_mlopts' `iterate'
			}
			if _rc==1 {
				if "`interactive'"=="" cmp_clear
				error 1
			}
			error _rc
			
			mat `_init' = e(b)

			if !`final' & "`quietly'"=="" noi version 11: ml di
		} // resteps loop

		local psampling_cutoff = `psampling_cutoff' * `psampling_rate'
	} // psampling loop

	if `gf' & "`svy'"=="" & "`vce'"!="opg" { // Non-svy hierarchical models use fast lf1 search, which doesn't quite give right Hessian; get correct VCV via honest gf1
		tempname hold V
		_est hold `hold'
		`quietly' ml model gf`="`lf'"==""' cmp_gf1() `mlmodelcmd' vce(`vce') init(`_init') group(_cmp_id1)
		mata moptimize_init_userinfo($ML_M, 1, &_mod)
		quietly ml max, search(off) `mlopts' iter(0) nooutput
		mat `V' = e(V)
		local vce `e(vce)'
		local vcetype `e(vcetype)'
		_est unhold `hold'
		ereturn	repost V = `V'
		ereturn local vce `vce'
		ereturn local vcetype `vcetype'
	}

	cap local _a // reset _rc to 0
	ereturn local marginsok Pr XB default
	cap _ms_op_info e(b)
	if _rc==0 & r(fvops) {
		if 0$cmpAnyOprobit {
			ereturn repost, buildfvinfo ADDCONS
			ereturn local marginsprop `e(marginsprop)' addcons
		}
		else ereturn repost, buildfvinfo
	}

	ereturn scalar k_gamma = $cmpHasGamma
	ereturn scalar k_aux = `:word count `auxparams'' + e(k_gamma)
	ereturn scalar k_eq = $cmp_d + e(k_aux)
	mata st_numscalar("e(k_sigrho)", st_numscalar("e(k_aux)") - colsum(st_matrix("cmp_num_cuts")) - st_numscalar("e(k_gamma)"))

	if _rc {
		local rc = _rc
		error `rc'
	}

	ereturn local model `method' `modeldisplay'
end

// if estimating, transform a categorical variable with the equivalent of egen group(), storing the transformation in cmp_y`cmp_eqno'_label
// if being called from predict, transform the variable using the info stored in e(cat) via that label, in case the var has been modified for prediction purposes
// returns ordered row vector of the categories
cap program drop GroupCategoricalVar
program define GroupCategoricalVar, rclass
	version 11
	syntax [if], cmp_eqno(string) [predict(string)]
	tempname cat num_cuts
	if "`predict'"=="" {
		tab ${cmp_y`cmp_eqno'} `if', matrow(`cat')
		cap confirm matrix `cat'
		if _rc {
			return scalar k = 0
			exit
		}
		mat `cat' = `cat'' // should extract numerically exact representation of doubles
	}
	else mata st_matrix("`cat'", select(st_matrix("e(cat)")[`cmp_eqno',], st_matrix("e(cat)")[`cmp_eqno',]:<.))

	forvalues i=1/`=colsof(`cat')' {
		local recode `recode' (`=string(`cat'[1,`i'], "%21x")' = `i') 
	}
	recode ${cmp_y`cmp_eqno'} `recode' `if', gen(_cmp_y`cmp_eqno')
	return matrix cat = `cat'
end

cap program drop LabelMprobitEq
program LabelMprobitEq
	version 11
	// try to name the eq after the outcome's label
	local 3: label (_cmp_y`4') `3'
	global cmp_eq`1': label (${parse_y`2'}) `3'
	cap confirm names ${cmp_eq`1'}
	if _rc | `:word count ${cmp_eq`1'}' > 1 global cmp_eq`1' _outcome_`2'_`3'
end

// Given current ml model, estimate starting points equation by equation
// Also, return reduced lists of RHS vars reflecting rmcoll and perfect-prediction eliminations in probit case
// as well as constraints on rho's needed for equations with non-overlapping samples
cap program drop InitSearch
program InitSearch, rclass
	version 11
	syntax [aw fw iw pw] if/, [auxparams(string) adjustprobitsample nodrop svy 1only quietly mlopts(string)]
	local if (`if')
	tempname sig beta gamma betavec gammavec auxparamvec _auxparamvec sigvec atanhrho V mat_cons omit
	tempvar y id choice
	local _cons _cons
	mat `mat_cons' = 0
	mat `auxparamvec' = 0
	mat colnames `mat_cons' = "_cons"
	if "`svy'"!="" local svy svy:
	if "`weight'" != "" & "`svy'"=="" {
		local iwgtexp [iweight `exp']
		local awgtexp [aweight `exp']
	}

	if $cmpSigXform {
		local ln ln
		local atanh atanh
	}

	forvalues eq=1/$cmp_d {
		local xvars
		tempvar e`eq' ebar`eq'

		if "${cmp_y`eq'}"=="." local regtype $cmp_missing
		else {
			cap assert (_cmp_ind`eq'<=$cmp_mprobit_ind_base | _cmp_ind`eq'>=$cmp_roprobit_ind_base) & inlist(_cmp_ind`eq', $cmp_probit, $cmp_probity1, $cmp_mprobit)==0 if `if', `=cond(c(stata_version)>=12.1,"fast","")'
			if _rc local regtype $cmp_probit
			else {
				qui levels _cmp_ind`eq' if `if'
				if      strpos(" `r(levels)' ", " $cmp_oprobit ")  local regtype $cmp_oprobit
				else if strpos(" `r(levels)' ", " $cmp_int ")      local regtype $cmp_int
				else if strpos(" `r(levels)' ", " $cmp_roprobit ") local regtype $cmp_roprobit
				else if strpos(" `r(levels)' ", " $cmp_left ")     local regtype $cmp_left
        else if strpos(" `r(levels)' ", " $cmp_right ")    local regtype $cmp_right
				else if strpos(" `r(levels)' ", " $cmp_frac ")     local regtype $cmp_frac
				else                                               local regtype $cmp_cont
			}
		}

		if "`1only'"=="" {
			fvexpand ${cmp_x`eq'} if `if' & _cmp_ind`eq'
			global cmp_x`eq' `r(varlist)'

			if "`drop'" == "" {
				`=cond(`regtype'==1 & "${cmp_y`eq'}"!=".", "_rmdcoll ${cmp_y`eq'}", "_rmcoll")' ${cmp_x`eq'} if `if' & _cmp_ind`eq', ${cmp_xc`eq'} expand
				foreach var in `r(varlist)' {
					if strpos("`var'", "o.") == 0 local xvars `xvars' `var'
				}
			}
			else local xvars ${cmp_x`eq'}
		}

		forvalues tries=0/1 { // Try at most two times to get a regression without collinear terms, perfect predictors, missing standard errors, etc.
			local keep
			cap drop `e`eq''
			cap mat drop `_auxparamvec'
			if `regtype'==$cmp_missing {
				mata st_matrix("`beta'", J(1, `:word count `xvars'', 0))
				mat colnames `beta' = `xvars'
				if "${cmp_xc`eq'}"=="" mat `beta' = `beta', `mat_cons'
				mata st_matrix("`V'", I(cols(st_matrix("`beta'"))))
				scalar `sig' = 0
				if $cmp_d > 1 | $parse_L > 1 qui gen `e`eq'' = 0 if e(sample)
			}
			else if `regtype'==$cmp_oprobit {
				`quietly' `svy' oprobit ${cmp_y`eq'} `xvars' `iwgtexp' if `if' & _cmp_ind`eq', offset(${cmp_xo`eq'}) `mlopts' iter(16000)
				mat `beta' = e(b)
				mat `V' = e(V)
				scalar `sig' = 0
				mat `_auxparamvec' = nullmat(`_auxparamvec'), `beta'[1, `=colsof(`beta')-e(k_aux)+1'...]
				if e(k_eq) == e(k_cat) {
					mat `beta' = `beta'[1,"${cmp_y`eq'}:"]
					mat `V' = `V'["${cmp_y`eq'}:","${cmp_y`eq'}:"]
					global cmp_xc`eq' nocons
				}
				else {
					mat `beta' = `mat_cons' // put a 0 on end for "constant"
					constraint free
					local initconstraints `initconstraints' `r(free)'
					constraint `r(free)' [${cmp_eq`eq'}]_cons
					global cmp_xc`eq'
				}
				qui if $cmp_d > 1 | $parse_L > 1 {
					_predict `e`eq'' if e(sample)
					recode `e`eq'' (. = 0) if e(sample) // can be all missing if there are no regressors
					replace `e`eq'' = ${cmp_y`eq'} - `e`eq''
				}
			}
			else if `regtype'==$cmp_probit {
				cap confirm variable _mp_cmp_y`eq' // check for cmp-made dummies for non-as mprobit
				`quietly' `svy' probit `=cond(_rc, "${cmp_y`eq'}", "_mp_cmp_y`eq'")' `xvars' `iwgtexp' ///
					if `if' & (inlist(_cmp_ind`eq',$cmp_probit,$cmp_probity1,$cmp_mprobit) | (_cmp_ind`eq' > $cmp_mprobit_ind_base & _cmp_ind`eq' < $cmp_roprobit_ind_base)), ${cmp_xc`eq'} offset(${cmp_xo`eq'}) `mlopts' iter(16000)

        if "`adjustprobitsample'" != "" {
          forvalues r=1/$cmp_num_mprobit_groups {  // for mprobit obs that got zapped for perfect prediction, remove from all eqs in group
            if cmp_mprobit_group_inds[`r',1] <= `eq' & `eq' <= cmp_mprobit_group_inds[`r',2] {
              qui forvalues c=`=cmp_mprobit_group_inds[`r',1]'/`=cmp_mprobit_group_inds[`r',2]' {
                if `c' != `eq' replace _cmp_ind`c' = 0 if `if' & e(sample)==0 & _cmp_ind`eq'
              }
            }
          }
          qui replace _cmp_ind`eq' = 0 if e(sample)==0
        }
        
				mat `beta' = e(b)
				mat `V' = e(V)
				scalar `sig' = 0
				qui if $cmp_d > 1 | $parse_L > 1 {
					predict `e`eq'' if e(sample)
					replace `e`eq'' = (`e(depvar)'!=0) - `e`eq''
				}
				tempname rules rules2
				mat `rules' = e(rules)

				local imperfect
				foreach var in `:colnames `beta'' {
					if strpos("`var'", "o.") == 0 local imperfect `imperfect' `var'
				}

				foreach var in `:list xvars - imperfect' {
					cap mat `rules2' = `rules'["`var'",1] // error can occur if using FV's and nodrop. Some entries of xvars have "o." but are dropped from regression
					if _rc==0 {
						if `rules2'[1,1]==1 {
							di as res _n "Warning: `var' perfectly predicts success or failure in ${cmp_y`eq'}."
							if "`drop'" == "" di as res "It will be dropped from the full model."
							di as res "Perfectly predicted observations will be dropped from the estimation sample for this equation."
						}
					}
				}
			}
			else if `regtype'==$cmp_left | `regtype'==$cmp_right {
        
				cap noisily `svy' tobit ${cmp_y`eq'} `xvars' `awgtexp' if `if' & inlist(_cmp_ind`eq', 1, 2, 3), ${cmp_xc`eq'} ll ul iter(16000)
				if _rc & _rc != 430 { // crash on error other than failure to converge
					error _rc
					cmp_error _rc
				}
				mat `beta' = e(b)
				scalar `sig' = ln([sigma]_cons)
				mat `beta' = `beta'[1, "model:"]
				mat `V' = e(V)
				mat `V' = `V'["model:", "model:"]
				qui if $cmp_d > 1 | $parse_L > 1 {
					predict `e`eq'' if e(sample) & (${cmp_y`eq'} > e(llopt) | e(llopt)==.) & ${cmp_y`eq'} < e(ulopt)
					replace `e`eq'' = ${cmp_y`eq'} - `e`eq''
				}
			}
			else if `regtype'==$cmp_int {
				cap `svy' intreg ${cmp_y`eq'_L} ${cmp_y`eq'} `xvars' `iwgtexp' if `if' & inlist(_cmp_ind`eq', 1, $cmp_int), ${cmp_xc`eq'} offset(${cmp_xo`eq'}) `mlopts' iter(16000)
				if _rc & _rc != 430 { // crash on error other than failure to converge
					error _rc
					cmp_error _rc
				}
				if "`quietly'"=="" intreg
				mat `beta' = e(b)
				scalar `sig' = [lnsigma]_cons
				mat `beta' = `beta'[1, "model:"]
				mat `V' = e(V)
				mat `V' = `V'["model:", "model:"]
				qui if $cmp_d > 1 | $parse_L > 1 {
					predict `e`eq'' if e(sample)
					replace `e`eq'' = cond(${cmp_y`eq'}<., cond(${cmp_y`eq'_L}<., (${cmp_y`eq'} - ${cmp_y`eq'_L})/2, ${cmp_y`eq'}), ${cmp_y`eq'_L}) - `e`eq''
				}
			}
			else if `regtype'==$cmp_frac {
				`quietly' `svy' regress ${cmp_y`eq'} `xvars' `iwgtexp' if `if', ${cmp_xc`eq'}
				mat `beta' = e(b)
				if "`svy'"=="" scalar `sig' = e(rmse)
					else qui {
						tempname e
						predict `e' if e(sample), resid
						svyset
						sum `e' `=cond(`"`r(wexp)'"'!="", `"[iw `r(wexp)']"', "")' if e(sample)
						scalar `sig' = r(sd)
					}
				mat `V' = e(V)
				if $cmp_d > 1 | $parse_L > 1 {
					qui predict `e`eq'' if e(sample), resid
					replace `e`eq'' = `e`eq'' / `sig' if e(sample)
				}
				mat `beta' = `beta' / `sig'
				scalar `sig' = 0 // ln 1
			}
			else { // uncensored or roprobit
				`quietly' `svy' regress ${cmp_y`eq'} `xvars' `iwgtexp' if `if' & (_cmp_ind`eq'==1 |  _cmp_ind`eq'>=$cmp_roprobit_ind_base), ${cmp_xc`eq'}
				mat `beta' = e(b)
				if $cmp_reverse & `regtype'==$cmp_roprobit mat `beta' = -`beta'
				if "`svy'"=="" scalar `sig' = ln(e(rmse))
					else qui {
						tempname e
						predict `e' if e(sample), resid
						svyset
						sum `e' `=cond(`"`r(wexp)'"'!="", `"[iw `r(wexp)']"', "")' if e(sample)
						scalar `sig' = ln(r(sd))
					}
				mat `V' = e(V)
				if $cmp_d > 1 | $parse_L > 1 qui predict `e`eq'' if e(sample), resid
			}

			local dropped
			local k = colsof(`beta')
			if `k' {
				local xvars: colnames `beta'
				local xvars: list xvars - `_cons'
				if diag0cnt(`V') & diag0cnt(`V') < rowsof(`V') { // unless all the coefs had se=0, drop those that did from this equation
					if "`drop'" == "" {
						_ms_omit_info `V'
						mat `omit' = r(omit)

						forvalues j=1/`=`k' - ("${cmp_xc`eq'}"=="")' {
							if `V'[`j',`j'] == 0 & `omit'[1,`j']==0 {
								if `"`dropped'"' == "" {
									di as res _n "Warning: Covariance matrix for single-equation estimate of ${cmp_y`eq'} equation is not of full rank."
									di as res "Parameters with singular variance will be excluded from full model."
									if `tries'==0 di as res "Re-running single-equation estimate without them."
								}
								local dropped `dropped' `:word `j' of `xvars''
								if `tries'==0 mat `beta'[1,`j'] = 0
							}
						}

						if e(ic) > 0 { // unless we're contrained to zero iterations, mark dropped variables
							_ms_findomitted `beta' `V'  // In FV versions of Stata, prefix with "o." rather than dropping
							local xvars: colnames `beta'
							local xvars: list xvars - `_cons'

							if "${cmp_xc`eq'}"=="" & `V'[`k',`k']==0 {
								local dropped `dropped' _cons
								global cmp_xc`eq' noconstant
							}
						}
					}
					else {
						di as res "Parameters with singular variance will be retained in full model."
						local xvars " `:subinstr local xvars "o." ".", all'"
						local xvars: subinstr local xvars " ." " ", all
						local colnames: colnames `beta'
						local colnames " `:subinstr local colnames "o." ".", all'"
						mat colnames `beta' = `:subinstr local colnames " ." " ", all'
					}
				}
			}
			else local xvars

			if "`dropped'" == "" continue, break
		}
		mat `auxparamvec' = `auxparamvec', nullmat(`_auxparamvec')

		if `k' mat coleq `beta' = ${cmp_eq`eq'}

		if "${cmp_yR`eq'}"!="" & "`1only'"=="" {
			mat `gamma' = J(1, `:word count ${cmp_yR`eq'}', 0.1) // starting value of 0 prevents identification there of scores w.r.t. coefs in unobserved-depvar eqs
			mat colnames `gamma' = `:subinstr global cmp_yR`eq' " " "# ", all'#
			mat coleq `gamma' = ${cmp_eq`eq'}
			mat `gammavec' = nullmat(`gammavec'), `gamma'
		}

		if cmp_fixed_sigs$parse_L[1,`eq']==. mat `sigvec' = nullmat(`sigvec'), cond($cmpSigXform, `sig', exp(`sig'))

		if e(converged) == 0 & e(ic)!=0 {
			di as res _n "Single-equation estimate for ${cmp_eq`eq'} equation did not converge."
			di "This may indicate convergence problems for the full model too."
		}
		CheckCondition `xvars'

		if `regtype'!=$cmp_missing & (e(df_m) | `regtype'!=$cmp_oprobit) {
			if "${cmp_xc`eq'}"=="" & `V'[`=colsof(`V')', `=colsof(`V')']==0 & e(converged) & diag0cnt(`V') < rowsof(`V') global cmp_xc`eq' noconstant
		}
		global cmp_x`eq' `xvars' `keep'

		if $cmpHasGamma {
			local t: colnames `beta'
			local XVarsAll: list XVarsAll | t
		}

		if colsof(`beta') {
			cap noi mat `betavec' = nullmat(`betavec'), `beta'
			if _rc {
				if _rc==198 {
					di as err _n "Error constructing parameter vector. Possible cause:"
					di as err `"The base for an indicator ("i.") variable has a different minimum value"'
					di as err "in the samples for different equations, so Stata's default choice for base/omitted dummy "
					di as err "differs by equation. Fix: manually {help fvvarlist##bases:set a uniform base}."
					di as err `"E.g. to make the omitted case 2, prefix throughout with "ib2." instead of "i."."' _n
				}
				cmp_error _rc
			}
		}
	}

	local ParamsDisplay `:colfullnames `betavec''
	if $cmpHasGamma {
		local ParamsDisplay `ParamsDisplay' `:colfullnames `gammavec'' 
		mat colnames `gammavec' = _cons
		mat coleq `gammavec' = `:subinstr global cmp_gammaparams "/" "", all'
		mat `betavec' = `betavec', `gammavec'
	}

  if "`adjustprobitsample'" != "" {  // for mprobit obs which in some eq got zapped for perfect prediction, see if only base case remains or chosen case dropped and drop obs if so
    tempvar t
    qui forvalues r=1/$cmp_num_mprobit_groups {
    	gen byte `t' = 1 if `if'
      forvalues c=`=cmp_mprobit_group_inds[`r',1]+1'/`=cmp_mprobit_group_inds[`r',2]' {
      	replace `t' = 0 if `if' & _cmp_ind`c'
      }
      forvalues c=`=cmp_mprobit_group_inds[`r',1]+1'/`=cmp_mprobit_group_inds[`r',2]' {  // but zap if obs for chosen case dropped
      	replace `t' = 1 if `if' & _cmp_ind`c'==0 & _cmp_ind`=cmp_mprobit_group_inds[`r',1]'==$cmp_mprobit_ind_base + `c' - cmp_mprobit_group_inds[`r',1] + 1
      }
      forvalues c=`=cmp_mprobit_group_inds[`r',1]'/`=cmp_mprobit_group_inds[`r',2]' {
        replace _cmp_ind`c' = 0 if `if' & `t'
      }
			drop `t'
    }
  }

	if "${cmp_cov$parse_L}" == "exchangeable" cap mata st_matrix("`sigvec'", mean(st_matrix("`sigvec'")'))   // can fail if sigvec is empty because all sigs fixed

	tempname Rho rho _sigvec sig t
	forvalues l=1/$parse_L {
		cap mat drop `_sigvec'
		cap mat drop `atanhrho'
		mat `Rho' = I($cmp_d)
		if `l' < $parse_L {
			local cmp_ids `cmp_ids' _cmp_id`l'
			local l_ `l'_
			local level_l "level `l' "
		}
		else {
			local l_
			local level_l
			local _sigvec `sigvec'
		}

		if "${cmp_cov`l'}" == "exchangeable" {
			mat `_sigvec' = 0
			mat `atanhrho' = 0
		}

		quietly forvalues eq=1/$cmp_d {
			if cmp_nonbase_cases[1,`eq'] {
				if "${cmp_rc`l'_`eq'}" != "" & "${cmp_cov`l'_`eq'}" != "exchangeable"  & "${cmp_cov`l'}" != "exchangeable" {
					mat `_sigvec' = nullmat(`_sigvec'), J(1, `:word count ${cmp_rc`l'_`eq'}', `ln'(.1)) // starting value for sd of RC's is .1
				}
				if `l' < $parse_L {
					tempname ebar`eq'
					by `cmp_ids': egen `ebar`eq'' = mean(`e`eq'') if `if' & _cmp_ind`eq'
					if ("${cmp_re`l'_`eq'}" != "" | "${cmp_cov`l'_`eq'}" == "exchangeable") & "${cmp_cov`l'}" != "exchangeable" {
						sum `ebar`eq'' `awgtexp'
						scalar `sig' = cond(r(sd), `ln'(r(sd)), `ln'(.1))
						mat `_sigvec' = nullmat(`_sigvec'), `sig'
					}
					replace `e`eq'' = `e`eq'' - `ebar`eq'' if `if' & _cmp_ind`eq'
				}
				else local ebar`eq' `e`eq''
			}
		}

		forvalues eq1=1/$cmp_d {
			if cmp_nonbase_cases[1,`eq1'] {
				if "${cmp_cov`l'_`eq1'}" == "exchangeable" & cmp_NumEff[`l', `eq1'] mat `atanhrho' = nullmat(`atanhrho'), 0
				forvalues c1=1/`=cmp_NumEff[`l', `eq1']' {
					if "${cmp_cov`l'_`eq1'}" == "unstructured" & `c1' < cmp_NumEff[`l', `eq1'] {
						mat `atanhrho' = nullmat(`atanhrho'), J(1, cmp_NumEff[`l', `eq1'] - `c1', 0)
					}
					if "${cmp_cov`l'}" == "unstructured" {
						forvalues eq2=`=`eq1'+1'/$cmp_d {
							if cmp_fixed_rhos`l'[`eq2',`eq1']==. {
								forvalues c2=1/`=cmp_NumEff[`l', `eq2']' {
									local corrREs = "`:word `c1' of ${cmp_rc`l'_`eq1'}'`:word `c2' of ${cmp_rc`l'_`eq2'}'"==""
									local param `atanh'rho`=cond(`corrREs',"","_`c1'_`c2'")'_`l_'`eq1'`eq2'
									cap corr `ebar`eq1'' `ebar`eq2''
									if r(N) {
										if `corrREs' {
											scalar `rho' = cond(atanh(r(rho))==., 0, atanh(r(rho)))
											mat `Rho'[`eq1',`eq2'] = tanh(`rho')
											mat `Rho'[`eq2',`eq1'] = tanh(`rho')
										}
										else scalar `rho' = 0
										mat `atanhrho' = nullmat(`atanhrho'), cond($cmpSigXform, `rho', tanh(`rho'))
									}
									else {
										if "`drop'" != "" {
											if `c1'==1 & `c2'==1 {
												di as res _n "Samples for `level_l'equations `eq1' and `eq2' do not overlap."
												di as res "`atanh'rho_`l_'`eq1'`eq2' kept in the model because of {cmd:nodrop} option."
												di as res "It cannot be identified, so it must be constrained."
											}
											mat `atanhrho' = nullmat(`atanhrho'), 0
											constraint free
											local initconstraints `initconstraints' `r(free)'
											constraint `r(free)' [`param']_cons
										}
										else {
											if `c1'==1 & `c2'==1  {
												di as res _n "Samples for `level_l'equations `eq1' and `eq2' do not overlap. Removing associated correlation parameter(s) from model."
												mat cmp_fixed_rhos`l'[`eq2',`eq1'] = 0
											}
											local t /`param'
											local auxparams: list auxparams - t
										}
									}
								}
							}
						}
					}
				}
			}
		}

		if "${cmp_cov`l'}" == "unstructured" {
			cap mat `Rho' = cholesky(`Rho')
			if _rc { // If initial guess not pos-def, zero out rhos while preserving column labels in case noESTimate will post this
				forvalues c=1/`=colsof(`atanhrho')' {
					mat `atanhrho'[1,`c'] = 0
				}
			}
		}
 		mat `auxparamvec' = `auxparamvec', nullmat(`_sigvec'), nullmat(`atanhrho')
	}

	if colsof(`auxparamvec') > 1 {
		mat `auxparamvec' = `auxparamvec'[1, 2...]
		mat colnames `auxparamvec' = _cons
		mat coleq    `auxparamvec' = `:subinstr local auxparams "/" "", all'
		local ParamsDisplay `ParamsDisplay' `:colfullnames `auxparamvec''
		mat `betavec' = `betavec', `auxparamvec'
	}

	local t: list posof "_cons" in XVarsAll
	if `t' local XVarsAll `:list XVarsAll - _cons' _cons
	return local XVarsAll `XVarsAll'

	return local ParamsDisplay `ParamsDisplay'
	return matrix b = `betavec'
	return local auxparams `auxparams'
	return local initconstraints `initconstraints'
end

cap program drop Display
program Display, eclass
	version 11
	novarabbrev {
		syntax [, Level(real `c(level)') RESULTsform(string) *]
		_get_eformopts, soptions eformopts(`options') allowed(hr shr IRr or RRr)
		local eformopts `s(eform)'
		_get_mldiopts, `s(options)'
		local mldiopts `s(diopts)'
		svyopts modopts svydiopts, `s(options)'
		local diopts `eformopts' `mldiopts' `svydiopts'
		local meff meff meft
		local diopts: list diopts - meff

		if e(k_gamma) | e(k_gamma_reducedform) < . {
			if `"`resultsform'"' != "" {
				local 0, `resultsform'
				syntax, [REDuced STRUCTural]
				local form `reduced'`structural'
				if "`form'" == "reducedstructural" cmp_error 198 "The {cmd:form()} option, if used, must be {cmdab:red:uced} or {cmdab:struct:ural}"
				local    form = substr("`form'"      ,1,1)
				local curform = substr(e(resultsform),1,1)
				if "`form'" != "`curform'" {
					tempname b V Cns Cns`curform' b`curform' V`curform' hold

					mat `b' = e(b`form')
					mat `V' = e(V`form')
					mat `Cns' = e(Cns`form')
					if `Cns'[1,1]==. local Cns

					local scalars : e(scalars)
					local macros  : e(macros)
					local matrices: e(matrices)
					local t b V Cns
					local matrices: list matrices - t
					foreach t in `scalars' {
						tempname `t'
						scalar ``t'' = e(`t')
					}
					foreach t in `macros' {
						tempname `t'
						local ``t'' `"`e(`t')'"'
					}
					foreach t in `matrices' {
						tempname `t'
						mat ``t'' = e(`t')
					}
					_estimates hold `hold'
					scalar `k' = colsof(`b')

					eret post `b' `V' `Cns', obs(`=`N'') esample(`hold')

					ereturn scalar k_sigrho = `k_sigrho_reducedform'
					ereturn scalar k_sigrho_reducedform = `k_sigrho'
					ereturn matrix NumEff = `NumEff_reducedform'
					ereturn matrix NumEff_reducedform = `NumEff'
					forvalues l=1/`=`L'' {
						ereturn matrix fixed_sigs`l' = `fixed_sigs_reducedform`l''
						ereturn matrix fixed_sigs_reducedform`l' = `fixed_sigs`l''
						ereturn matrix fixed_rhos`l' = `fixed_rhos_reducedform`l''
						ereturn matrix fixed_rhos_reducedform`l' = `fixed_rhos`l''
						forvalues eq=1/`=`k_dv'' {
							ereturn local EffNames`l'_`eq' `EffNames_reducedform`l'_`eq''
							ereturn local EffNames_reducedform`l'_`eq' `EffNames`l'_`eq''
						}
					}
					foreach t in `scalars' {
						ereturn scalar `t' = ``t''
					}
					foreach t in `macros' {
						ereturn local `t' `"```t'''"'
					}
					foreach t in `matrices' {
						cap ereturn mat `t' = ``t'' // matrices already stored in lines above will be gone and cause errors here
					}
					if "`form'"=="r" {
						ereturn scalar k_gamma_reducedform = `k_gamma'
						ereturn scalar k_gamma = 0
						ereturn scalar k_eq  = `k_eq'  - `k_gamma' - `k_sigrho' + `k_sigrho_reducedform'
						ereturn scalar k_aux = `k_aux' - `k_gamma' - `k_sigrho' + `k_sigrho_reducedform'
						ereturn local covariance
						ereturn local covariance_reducedform ``covariance''
						forvalues eq=1/`=e(k_dv)' {
							ereturn local `covariance`eq''
							ereturn local covariance_reducedform`eq' ``covariance`eq'''
						}
						cap ereturn matrix Cnss = `Cnss'
					}
					else {
						ereturn scalar k_gamma_reducedform = .
						ereturn scalar k_gamma = `k_gamma_reducedform'
						ereturn scalar k     = `k'     + `k_gamma_reducedform' + `k_sigrho' - `k_sigrho_reducedform'
						ereturn scalar k_eq  = `k_eq'  + `k_gamma_reducedform' + `k_sigrho' - `k_sigrho_reducedform'
						ereturn scalar k_aux = `k_aux' + `k_gamma_reducedform' + `k_sigrho' - `k_sigrho_reducedform'
						ereturn local covariance_reducedform
						ereturn local covariance ``covariance_reducedform''
						forvalues eq=1/`=e(k_dv)' {
							ereturn local covariance_reducedform`eq'
							ereturn local covariance`eq' ``covariance_reducedform`eq'''
						}
					}
					ereturn local resultsform = cond("`form'"=="s", "structural", "reduced")
				}
			}

			if e(resultsform)=="structural" {  // make gamma parameters look like regular coefficients
				tempname b V Cns hold
				_estimates hold `hold', copy
				mat `b' = e(b)
				mat colnames `b' = `e(params)'
				ereturn repost b=`b', rename
				mat `b' = e(b)
				mat `V' = e(V)
				mata _p = st_matrix("e(_p)"); st_replacematrix("`b'", st_matrix("`b'")[_p]); st_replacematrix("`V'", st_matrix("`V'")[_p,_p])
				mata st_matrixcolstripe("`b'", _t = st_matrixcolstripe("`b'")[_p,]); st_matrixcolstripe("`V'", _t); st_matrixrowstripe("`V'", _t)
				cap mat `Cns' = e(Cns)
				if !_rc {
					mata _p=_p, `e(k)'+1; st_replacematrix("`Cns'", st_matrix("`Cns'")[,_p]); st_matrixcolstripe("`Cns'", _t \ ("_Cns","_r"))
					local cnsarg Cns=`Cns'
				}
				mata mata drop _p _t
				ereturn repost b=`b' V=`V' `cnsarg', rename
				ereturn scalar k_eq  = e(k_eq)  - e(k_gamma)
				ereturn scalar k_aux = e(k_aux) - e(k_gamma)
			}
		}

    if c(noisily) {
      if e(L) == 1 {
        if `:word count `e(diparmopt)''/3+`:word count `diopts''<=68 ml display, level(`level') `diopts' showeqns `e(diparmopt)'
                                                                else ml display, level(`level') `diopts' showeqns
      }
      else {
        tempname t
        mat `t' = e(num_cuts)' * J(`e(k_dv)', 1, 1)
        ml display, level(`level') `diopts' showeqns `=cond(e(sigxform) | `t'[1,1], "", "neq(`e(k_dv)')")' // just displaying cuts causes them to be listed as equations, not aux params
      
        tempname fixed_sigs fixed_rhos NumEff param se z
        scalar `z' = invnormal(.5+`level'/200)
        mat `NumEff' = e(NumEff)

        if e(sigxform) {
          local exp exp
          local ln ln
          local tanh tanh
          local atanh atanh
        }

        di as txt "{hline 36}{c TT}{hline 47}"
        di "Random effects parameters           {c |}  Estimate    Std. Err.    [`level'% Conf. Interval]"
        di as txt "{hline 36}{c +}{hline 47}"

        forvalues l=1/`=e(L)-1' {
          local covariance: word `l' of `e(covariance)'
          di "Level: " as res abbrev("`:word `l' of `e(ivars)''", 15) as txt cond("`covariance'"=="exchangeable", " (exchangeable)", "") _col(37) "{c |}" 
          mat `fixed_sigs' = e(fixed_sigs`l')
          mat `fixed_rhos' = e(fixed_rhos`l')
          if "`covariance'" == "exchangeable" {
            local paramname /`ln'sigEx_`l'
            di as txt "    Standard deviations" _col(37) "{c |} " as res %9.0g `exp'(_b[`paramname']) _c
            if _se[`paramname'] di _col(51) %9.0g exp(e(sigxform)*_b[`paramname'])*_se[`paramname'] _col(64) %9.0g `exp'(_b[`paramname']-`z'*_se[`paramname']) _col(76) %9.0g `exp'(_b[`paramname']+`z'*_se[`paramname'])
              else di as res "  " %9.0g . as txt
            if e(k_dv) > 1 {
              local paramname /`atanh'rhoEx_`l'
              di as txt "    Cross-eq " plural(1+(e(k_dv)>2 | (e(k_dv)==2 & (`NumEff'[`l', 1]>1 | `NumEff'[`l', e(k_dv)]>1))), "correlation") _col(37) "{c |} " as res %9.0g `tanh'(_b[`paramname']) _c
              if _se[`paramname'] di _col(51) %9.0g _se[`paramname']/cosh(e(sigxform)*_b[`paramname'])^2 _col(64) %9.0g `tanh'(_b[`paramname']-`z'*_se[`paramname']) _col(76) %9.0g `tanh'(_b[`paramname']+`z'*_se[`paramname'])
                else di as res "  " %9.0g . as txt
            }
          }
          forvalues eq1=1/`=e(k_dv)' {
            if `NumEff'[`l', `eq1'] {
              local covariance`eq1': word `l' of `e(covariance`eq1')'
              if e(k_dv)>1 di as txt "  " as res abbrev("`:word `eq1' of `e(eqnames)''", 15) as txt cond("`covariance`eq1''"=="exchangeable", " (exchangeable)", "") _col(37) "{c |}" 
              if  "`covariance'" != "exchangeable" {
                di as txt "    Standard deviations" _col(37) "{c |} " _c as res
                if "`covariance`eq1''"=="exchangeable" {
                  local paramname /`ln'sigEx_`l'_`eq1'
                  di as res %9.0g `exp'(_b[`paramname']) _c
                  if _se[`paramname'] di _col(51) %9.0g exp(e(sigxform)*_b[`paramname'])*_se[`paramname'] _col(64) %9.0g `exp'(_b[`paramname']-`z'*_se[`paramname']) _col(76) %9.0g `exp'(_b[`paramname']+`z'*_se[`paramname'])
                    else di "  " %9.0g .
                }
                else {
                  di as txt
                  forvalues c=1/`=`NumEff'[`l', `eq1']' {
                    local t = abbrev("`:word `c' of `e(EffNames`l'_`eq1')''", 22)
                    di as txt "      `t'"  _col(37) "{c |} " _c
                    if `fixed_sigs'[1,`eq1'] == . {
                      local paramname /`ln'sig`=cond("`t'"=="_cons","","_`c'")'_`l'_`eq1'
                      di as res %9.0g `exp'(_b[`paramname']) _c
                      if _se[`paramname'] di _col(51) %9.0g exp(e(sigxform)*_b[`paramname'])*_se[`paramname'] _col(64) %9.0g `exp'(_b[`paramname']-`z'*_se[`paramname']) _col(76) %9.0g `exp'(_b[`paramname']+`z'*_se[`paramname'])
                        else di "  " %9.0g . as txt
                    }
                    else di %9.0g `fixed_sigs'[1,`eq1'] as txt "  (constrained)"
                  }
                }
              }
              if `NumEff'[`l', `eq1'] > 1 & "`covariance`eq1''"!="independent" {
                di as txt "    Intra-eq " plural(`NumEff'[`l', `eq1']-1, "correlation") _col(37) "{c |} " _c
                if "`covariance`eq1''"=="exchangeable" {
                  local paramname /`atanh'rhoEx_`l'_`eq1'
                  di %9.0g `tanh'(_b[`paramname']) _c
                  if _se[`paramname'] di _col(51) %9.0g _se[`paramname']/cosh(e(sigxform)*_b[`paramname'])^2 _col(64) %9.0g `tanh'(_b[`paramname']-`z'*_se[`paramname']) _col(76) %9.0g `tanh'(_b[`paramname']+`z'*_se[`paramname'])
                    else di "  " %9.0g .
                }	
                else {
                  di
                  forvalues c1=1/`=`NumEff'[`l', `eq1']' {
                    forvalues c2=`=`c1'+1'/`=`NumEff'[`l', `eq1']' {
                      local t1 = abbrev("`:word `c1' of `e(EffNames`l'_`eq1')''", 15)
                      local t2 = abbrev("`:word `c2' of `e(EffNames`l'_`eq1')''", 15)
                      local paramname /`atanh'rho_`c1'_	`c2'_`l'_`eq1'
                      di as txt "      `t1'" _col(20) "`t2'" _col(37) "{c |} " as res %9.0g `tanh'(_b[`paramname']) _c
                      if _se[`paramname'] di _col(51) %9.0g _se[`paramname']/cosh(e(sigxform)*_b[`paramname'])^2 _col(64) %9.0g `tanh'(_b[`paramname']-`z'*_se[`paramname']) _col(76) %9.0g `tanh'(_b[`paramname']+`z'*_se[`paramname'])
                        else di "  " %9.0g .
                    }
                  }
                }
              }
            }
          }
          if "`:word `l' of `e(covariance)''" == "unstructured" & e(k_dv) > 1 {
            local needheader 1
            forvalues eq1=1/`e(k_dv)' {
              forvalues eq2=`=`eq1'+1'/`e(k_dv)' {
                if `fixed_rhos'[`eq2',`eq1'] == . & `=`NumEff'[`l', `eq1']' & `=`NumEff'[`l', `eq2']' {
                  if `needheader' di as txt " Cross-eq " plural(1+(e(k_dv)>2 | (e(k_dv)==2 & (`NumEff'[`l', 1]>1 | `NumEff'[`l', e(k_dv)]>1))), "correlation") _col(37) "{c |} "
                  local needheader 0
                  di as txt "  " as res abbrev("`:word `eq1' of `e(eqnames)''", 15) _col(19) abbrev("`:word `eq2' of `e(eqnames)''", 15) as txt _col(37) "{c |}"
                  forvalues c1=1/`=`NumEff'[`l', `eq1']' {
                    forvalues c2=1/`=`NumEff'[`l', `eq2']' {
                      local t1 = abbrev("`:word `c1' of `e(EffNames`l'_`eq1')''", 15)
                      local t2 = abbrev("`:word `c2' of `e(EffNames`l'_`eq2')''", 15)
                      local paramname /`atanh'rho`=cond("`t1'`t2'"=="_cons_cons", "", "_`c1'_`c2'")'_`l'_`eq1'`eq2'
                      di as txt "    `t1'" _col(21) "`t2'" _col(37) "{c |} " as res %9.0g `tanh'(_b[`paramname']) _c
                      if _se[`paramname'] di _col(51) %9.0g _se[`paramname']/cosh(e(sigxform)*_b[`paramname'])^2 _col(64) %9.0g `tanh'(_b[`paramname']-`z'*_se[`paramname']) _col(76) %9.0g `tanh'(_b[`paramname']+`z'*_se[`paramname'])
                        else di "  " %9.0g .
                    }
                  }
                }
              }
            }
          }
          di as txt "{hline 36}{c +}{hline 47}"
        }

        mat `fixed_sigs' = e(fixed_sigs`e(L)')
        mat `fixed_rhos' = e(fixed_rhos`e(L)')
        di "Level: " as res "Observations" _col(37) as txt "{c |}"
        di " Standard " plural(e(k_dv), "deviation") _col(37) "{c |} " as res  _c
        if "`:word `e(L)' of `e(covariance)''" == "exchangeable" {
          local paramname /`ln'sigEx
          di %9.0g `exp'(_b[`paramname']) _c
          if _se[`paramname'] di _col(51) as res %9.0g exp(e(sigxform)*_b[`paramname'])*_se[`paramname'] _col(64) %9.0g `exp'(_b[`paramname']-`z'*_se[`paramname']) _col(76) %9.0g `exp'(_b[`paramname']+`z'*_se[`paramname'])
            else di "  " %9.0g . as txt
          if e(k_dv) > 1 {
            di as txt " Cross-eq " plural(e(k_dv)-1, "correlation") _col(37) "{c |} " _c
            local paramname /`atanh'rhoEx
            di as res %9.0g `tanh'(_b[`paramname']) _c
            if _se[`paramname'] di _col(51) as res %9.0g _se[`paramname']/cosh(e(sigxform)*_b[`paramname'])^2 _col(64) %9.0g `tanh'(_b[`paramname']-`z'*_se[`paramname']) _col(76) %9.0g `tanh'(_b[`paramname']+`z'*_se[`paramname'])
              else di "  " %9.0g .
          }
        }
        else {
          if e(k_dv)>1 di
          forvalues eq1=1/`=e(k_dv)' {
            if e(k_dv)>1 di as txt "  " as res abbrev("`:word `eq1' of `e(eqnames)''", 24) as txt _col(37) "{c |} " _c
            if `fixed_sigs'[1,`eq1'] == . {
              local paramname /`ln'sig_`eq1'
              di as res %9.0g `exp'(_b[`paramname']) _c
              if _se[`paramname'] di _col(51) %9.0g exp(e(sigxform)*_b[`paramname'])*_se[`paramname'] _col(64) %9.0g `exp'(_b[`paramname']-`z'*_se[`paramname']) _col(76) %9.0g `exp'(_b[`paramname']+`z'*_se[`paramname'])
                else di "  " %9.0g .
            }
            else di as res %9.0g `fixed_sigs'[1,`eq1'] as txt "  (constrained)"
          }
          if e(k_dv) > 1 & "`:word `e(L)' of `e(covariance)''" == "unstructured" {
            local needheader 1
            forvalues eq1=1/`e(k_dv)' {
              forvalues eq2=`=`eq1'+1'/`e(k_dv)' {
                if `fixed_rhos'[`eq2',`eq1'] == . {
                  if `needheader' di as txt " Cross-eq " plural(e(k_dv)-1,"correlation") _col(37) "{c |} "
                  local needheader 0
                  di as txt "  " as res abbrev("`:word `eq1' of `e(eqnames)''", 15) _col(19) as res abbrev("`:word `eq2' of `e(eqnames)''", 15) as txt _col(37) "{c |} " _c
                  local paramname /`atanh'rho_`eq1'`eq2'
                  di as res %9.0g `tanh'(_b[`paramname']) _c
                  if _se[`paramname'] di _col(51) %9.0g _se[`paramname']/cosh(e(sigxform)*_b[`paramname'])^2 _col(64) %9.0g `tanh'(_b[`paramname']-`z'*_se[`paramname']) _col(76) %9.0g `tanh'(_b[`paramname']+`z'*_se[`paramname'])
                    else di "  " %9.0g .
                }
              }
            }
          }
        }
        di as txt "{hline 36}{c BT}{hline 47}"
      }
     }
		if e(k_gamma) & e(resultsform)=="structural" _estimates unhold `hold'
	}
end

// built-in _get_eformopts and _get_diopts don't align with ml display option sets
// This routine extracts all acceptable ml display options
// doesn't accept -first- option because that conflicts with cmp's usage of showeqns
// for same reason, deletes any showeqns option
cap program drop _get_mldiopts
program define _get_mldiopts, sclass
	version 11
	syntax, [NOHeader NOFOOTnote /*first*/ neq(string) SHOWEQns PLus NOCNSReport NOOMITted vsquish NOEMPTYcells BASElevels ALLBASElevels cformat(string) pformat(string) sformat(string) NOLSTRETCH coeflegend *]
	foreach opt in neq cformat pformat sformat {
		if `"``opt''"' != "" {
			local `opt' `opt'(``opt'')
		}
	}
	sreturn local diopts `noheader' `nofootnote' `first' `neq' /*`showeqns'*/ `plus' `nocnsreport' `noomitted' `vsquish' `noemptycells' `baselevels' `allbaselevels' `cformat' `pformat' `sformat' `nolstretch' `coeflegend' `shr'
	sreturn local options `options'
end

cap program drop CheckCondition
program define CheckCondition
	version 11
	if "`1'" != "" {
		syntax varlist(ts fv) [aw iw]
		tempname XX c
		fvrevar `varlist'
		local varlist `r(varlist)'
		qui mat accum `XX' = `varlist' [`weight'`exp'] if e(sample), nocons
		forvalues i=1/`=colsof(`XX')' {
			if `XX'[`i',`i'] local xvars `xvars' `:word `i' of `varlist''
		}
		if "`xvars'" != "" {
			qui mat accum `XX' = `xvars' [`weight'`exp'] if e(sample), nocons
			mata st_numscalar("`c'", cond(corr(st_matrix("`XX'"))))
			if `c' > 20 { // threshhold from Greene (2000, p. 40)
				di _n as res "Warning: regressor matrix for " as txt e(depvar) as res " equation appears ill-conditioned. (Condition number = " `c' ".)"
				di "This might prevent convergence. If it does, and if you have not done so already, you may need to remove nearly"
				di "collinear regressors to achieve convergence. Or you may need to add a {opt nrtol:erance(#)} or {opt nonrtol:erance} option to the command line."
				di "See {help cmp##tips:cmp tips}."
			}
		}
	}
end

cap program drop cmp_error
program define cmp_error
	version 11
	noi di as err `"`2'"'
	cmp_clear
	exit `1'
end

* Version history
* 8.7.9 Fixed broken compatibility with Stata < 15 from adding mvnormal() / ghkdraws(0) in 8.7.3
* 8.7.8 Fixed crash on ghkrdaws(0) with random effects.
* 8.7.7 Prevent crash in a gamma model with ordered probits, when deleting obs because of eq interdependencies empties a category
*       Support tech(nm)
*       Fix crashes when restarting with all 0's
* 8.7.6 Prevent crash when random-coefficient var list fv-expands to include omitted or base levels
* 8.7.5 Fixed crash on complex weight expressions with parentheses
* 8.7.4 Prevent crash when too few primes for Halton or multiple RC's causing passing of matrix to setcol()
* 8.7.3 Fixed crash in predicting likelihoods and scores after cmp command line with quotes
* 8.7.2 Added ability to predict many e's at once as it could already predict many pr's at once
* 8.7.1 Prevent crash when random effect grouping var has missing values
* 8.7.0 Fixed bugs in printing error messages in a few cases.
* 8.6.9 Fixed bug causing predict/margins to think system involving m/roprobits uses GHK just because it has more equations
* 8.6.8 Rollback 8.6.7 changes in favor of iter(16000) on calls to tobit, probit, oprobit, intreg in order not to slightly change results
* 8.6.7 workaround for obscure bug in Stata's tobit in Stata 16, 17 causing crash. Slightly affects results for tobit models.
* 8.6.6 Fixed 8.6.3 crash when bicensored (oprobit intreg) eqs combined with eqs incomplete for some obs
* 8.6.5 Allow abbreviation of vce() suboptions
* 8.6.4 Fixed 8.6.0 bug in truncated-regression models
* 8.6.3 speed tweaks
* 8.6.2 Fixed crashes in margins, vce(unconditional) after svy estimation. Now requires Stata 13 or newer.
* 8.6.1 Fixed crash in margins after resultsform(reduced) and observation weights, and crash in svy: , resultsform(reduced).
*       Fixed computational bug affecting predict, lnl and predict, scores after resultsform(reduced) and thus standard errors from svy: , resultsform(reduced).
* 8.6.0 Added optimizations for 1-eq models
* 8.5.4 Fixed crash when GHK necessitated only by truncation in >=3 eq
* 8.5.3 Fixed crash on # reference to m/roprobit base case; fixed crash on hierarchical/svy/redraw(, steps())
* 8.5.2 Fixed crash on non-hierarchical svy models
* 8.5.1 Small speed-ups
* 8.5.0 Made predict, pr factor in error variance in all cases, not assume it's 1
* 8.4.1 Fixed 8.4.0 bug causing crash
* 8.4.0 Fixed bugs in handling mprobits in which observable (not-chosen!) cases vary by observation
* 8.3.9 Fixed crash on use of intmethod()
* 8.3.8 Prevented crash when using svy on data svyset with pweights or when combining svy with multi-level
* 8.3.7 Better error message on syntax error in indicator variable definition caused most likely by not doing "cmp setup"
* 8.3.6 Return e(ghkdraws) even when option not set by user; fixes crash in predict or margins for models with mprobits with >3 categories
* 8.3.5 Fixed 8.3.0 bug, 4/1/2019: e(covariance...) terms in backwards order, sometimes causing crash on results display
* 8.3.4 Fixed crash on predict/margins of probabilities (pr) after estimation with mprobit/roprobit + other equations
* 8.3.3 Streamlined Predict code; made cmp always store e(bs) and e(br) regardless of current resultsform
* 8.3.2 Fixed bug causing wrong predictions after gamma models
* 8.3.1 Prevented crash when it can't recompile boottest.mata; instead issues an explanatory warning
* 8.3.0 Fixed bug introduced in 8.2.3, 7/17/2018: without "nolr" option, mprobit, asprobit, and gamma models estimated wrongly/didn't converge
* 8.2.9 Fixed crashes in multi-equation, multilevel models when diferent equations have effects at different levels.
* 8.2.8 Fixed bugs in predict after mprobit
* 8.2.7 Fixed new "option vce() not allowed" bug in hierarchical models
* 8.2.6 Fixed loss of user's vce() option in 8.2.3
* 8.2.5 Fixed crash when oprobit eq's take more values in full sample than in eq's sample.
* 8.2.4 Fixed crashes in hierarchical models with "lf", introduced in 8.0.0.
* 8.2.3 After 8.2.0 changes, in hierarchichal models, allowed iter() to affect pre-refinement estimation too.
*       Got rid of "refining" stage for hierarchical models: first stage fully fits with lf1, second just computes proper VCV with iter(0).
*       Fully redefined ml model for latter stage to prevent crashes in some contexts.
* 8.2.2 Extended predictions of multinomial probabilities to predictions of being top-ranked for roprobit models.
*       Fixed false error in parsing of upper-level weights in multilevel models
* 8.2.1 Fixed 8.2.0 bug: fully loosened convergence criteria before "refining" multilevel model search
* 8.2.0 Created gf1 evaluator for proper multilevel modeling (Hessian not quite right under lf1 trick)
*       Added predictions of multinomial probit probabilities
*       Fixed bugs when RC on a var not in other eqs
* 8.1.2 Fixed svy hierarchical model crashes, partly by writing gf1 wrapper for lf1 evaluator. Stopped default of bhhh for such models because of moptimize() bug for svy/gf1.
* 8.1.1 Compensated for Stata 14, 15 bug in which ml model, svy leaves behind reference to temp var in e(wexp), e(wvar)
* 8.1.0 Fixed 8.0.9 crash in fully uncensored models
* 8.0.9 Fixed bug in models mixing fractional probits with non-censored models, or varying which fractional probit eqs are included
* 8.0.8 Added reference to $ML_samp in one call of st_data(), preventing crash in hierarchical models not fit to all data
* 8.0.7 Fixed 6.9.1 bug causing crash on subpop()
* 8.0.6 Fixed crash when all included eqs have unobserved outcomes
* 8.0.5 Fixed crash in multi-equation models with only some eqs truncated
* 8.0.4 Fixed another bug causing crash in quadrature models with nolrtest. Restored broken LR test.
* 8.0.3 Changes to cmp.pkg and stata.toc only, on GitHub
* 8.0.2 Workaround for Stata 15 bug: prevent varabbrev from affecting _b[] and _se[] references in printing output. Fixed crash in adaptive quadrature models without nolrtest.
* 8.0.1 Fixed 8.0.0 mishandling of ml maximization options
* 8.0.0 Switched to pure-Mata evaluator function. Now requires Stata 11 or newer.
* 7.1.0 Added fractional probit model. Fixed bugs when combining rank-ordered probits with other models.
* 7.0.5 Avoid pre-computation of some potentially large matrices unless needed for gamma models.
* 7.0.4 Fixed 7.0.3 mprobit crash.
* 7.0.3 Fixed crash in _ms_find_omitted(). Replaced egen..group() for oprobit variables with code that handles doubles precisely.
* 7.0.2 Fixed bug causing it to ignore observation-level weights in hierarchical models, and 7.0.1 bug causing dropping of random coefficients in non-interactive mode, fv Stata versions
* 7.0.1 Fixed crash when a variable was dropped as a perfect probit predictor in one equation but retained in another, in non-interactive mode, fv Stata versions
* 7.0.0 Made all sorts stable to improve exact reproducibility in multilevel models, improved precision of denominator in cmp_p's cond() option
* 6.9.9 Fixed bug preventing convergence in models with truncation but not truncation in first equation
* 6.9.8 Prevented crash if an oprobit variable's range is smaller in sample than in full data. Avoid use of assert, fast in Stata<12.1.
* 6.9.7 Fixed handling of ts and fv ops on dep vars. Prevented overwriting of e(wexp) if already set by svy option. Fixed 6.9.5 crash for real this time.
* 6.9.6 Fixed 6.9.5 crash: failed to restrict to sample when calling cmp, predict before generating scores.
* 6.9.5 Added from() as synonym for init(); dropped mlopts from tobit call in InitSearch because tobit is finnicky about ml options; for speed, made predict all scores at once on "predict stub*, scores".
*       Set GHK draw set width = max # of censored dimensions, not number of equations. Fixed 6.8.5 bug in labelling mprobit equations when outcome present in depvar but not realized in estimation sample
* 6.9.4 Fixed crash when GHK needed, at least one eq is oprobit/intreg and at least one eq is not (default lower bound in F -> . for minus infinity, not 0)
* 6.9.3 Fixed crash on "[]" as weight clause
* 6.9.2 Fixed crash parsing intmethod(ghermite); crash on results display when adaptive quad never works for some groups; contraint-dropping bug introduced in 6.8.8; failure to drop atanhrho's at all levels in hierarchical models
* 6.9.1 Added support for if clause in subpop()
* 6.9.0 Fixed bugs causing crash on svy option and obscuring properties of cmp
* 6.8.9 Fixed small 6.8.8 bugs
* 6.8.8 Improved constraint handling: constraint() option now accepts a matrix; constraints on gamma parameters now display correctly; now revars all variables for speed even with constraints
* 6.8.7 Prevented crash on resultsform(reduced) after constrained regression
* 6.8.6 Fixed 6.8.0 bug affecting coefficient standard errors in latent-variable models after cmp, results(reducedform).
* 6.8.5 Made _cmp more robust to being called by cmp_p after depvars modified, in non-as mprobit and oprobit models, to faciliate computing margins w.r.t. fixed outcomes.
*       Fixed minor bugs when fitting models with many, many censored equations.
* 6.8.4 Fixed bug introduced in 6.8.0 when dep var missing for some observations, causing crash.
* 6.8.3 For speed, eliminated calls from cmp_p to cmp, predict when predicting xb, stdp, stddp--just scores and lnl
* 6.8.2 Added constraint drop when doing cmp, predict
* 6.8.1 Fixed bug affecting hierarchical models in Stata version<13. Can't use * as string operator.
* 6.8.0 Added -missing- equation type
*       Added tolerance() and iterate() suboptions to intmethod(). Dropped undocumented rzghermite and onestep suboptions.
*       Made resultsform(reduced) change estimates of covariance matrices too(!).
*       Added support for all -ml display- display and eform options; fixed handling of subpop() option.
*       Made it byable.
*       Fixed bug preventing proper functioning of margins at() option with Gamma models
*       Fixed bugs introduced in 6.5.5 affecting displayed name of interval regression equations and preventing prediction of log likelihoods after interval regression
* 6.7.2 Fixed 5.4.0 bug affecting models in which the number of censored equations varies by observation and at least one is ordered probit
*       Made bhhh/oim the default for adaptive quadrature.
* 6.7.1 Fixed 6.7.0 bug in score prediction.
* 6.7.0 Added condition() option to predict.
* 6.6.4 passed ml maximization options to initial fits; prevented crash with svy by switching back from if e(chi2type) to "`e(chi2type)'"
* 6.6.3 Prevented crash when using resultsform() with constraints
* 6.6.2 Fixed 6.6.0: made resultsform(reduced) modify e(k)
* 6.6.1 Fixed bug in hierarchical gamma models whose equation set varies by observation. Made it drop obs for eqs referring via # coefs to missing eqs even if latter are uncensored.
* 6.6.0 Added resultsform() option to switch model results to reduced to allow proper -margins- after "gamma" models.
* 6.5.5 Fixed overwriting of depvar in interval regressions. Thanks to anonymous Stata Journal reviewer.
* 6.5.4 Prevented crash with models of 4 or more levels
* 6.5.3 Fixed bug introduced in 6.0.0 affecting computation in models with mprobit eq and other censored eq
* 6.5.2 Fixed e(marginsok)
* 6.5.1 Fixed bug 6.5.0 bug -- now _ms_findomitted().
* 6.5.0 Fixed bug 6.4.9 bug.
* 6.4.9 Wrote __ms_findomitted since Stata 11 doesn't have _ms_findomitted. Fixed bug in posting e(marginsprop) for oprobit.
* 6.4.8 Fixed bug causing predict, ystar() and predict, e() to halt with "Only one statistic allowed".
* 6.4.7 Fixed bug created in 6.0.0 preventing estimation of misspecified models with svy option.
*       Made to call to buildfvinfo, without ADDCONS, in non-oprobit cases. Should cut need for margins, noestimcheck.
* 6.4.6 Added -missing- option to ml_p scores calls to fix bug in svy standard errors in multi-eq models with eqs having different samples.
* 6.4.5 Prevented crash in hierarchical models if InitSearch perfect probit predictor detection causes dropping of whole groups. Added trap for predict , lnl after hierarchical models.
* 6.4.4 Defined _IntMethod and $cmpN when called by predict. Factored in weights in computing cmpN.
* 6.4.3 Only add the undocumented ADDCONS info if there is an oprobit equation in the model.
* 6.4.2 Warn on non-prime draw counts. In factor-variable Stata versions (>=11) omit vars that have 0 standard error in single-equation fits.
*       Dropped 5.4.4's "nonrtolerance tolerance(0.1)" for safety. E.g., loose tobit fit may misjudge which variables ought to be dropped (indicated by singular variance).
*       Fixed 6.4.0 bug: bounds() option broke code in interactive mode. Moved from ml model to ml max command.
* 6.4.1 Use traditional product rule instead of "sparse" grid for 2-D problems. Eliminate small-sample correction to C in Naylor-Smith adaptation that wasn't reflected in AdaptiveShift.
* 6.4.0 Added undocumented noSIGXform option to parameterize with sig's and rho's instead of lnsig's and atanhrho's.
*       Fixed labeling on non-mprobit eqs in mixed mprobit system using short mprobit syntax
*       Label e(b) and e(V) with true model so that scores can be computed, e.g., as requested for svy
* 6.3.2 Restored display of sigs and rhos in non-hierarchical models (bug).
* 6.3.1 Made sure to set _GammaInds and set _interactive=1 in cmp...predict. Was preventing score prediction, including during svy:.
* 6.3.0 Added adaptive quadrature, by default for random effects/coefficients models. Disabled 6.0.3's setting of favorspeed.
* 6.2.0 Added sparse-grid quadrature as default replacement for simulation-based modelling of random effects and coefficients.
* 6.1.0 Added support for hierarchical Gamma models. Fixed non-convergence in hierarchical mprobit models & models with >2 levels. Cleaned up display of hierarchical results.
* 6.0.4 Tightened Mata code. Fixed Gamma-related bug in score construction in cmp_d1 for Stata 10.
*       Fixed bug in binormalGenz() introduced in 6.0.3. Fixed new bug in handling mprobit eqs that are 0 for some obs, 6 for others
* 6.0.3 Fixed bug in Gamma models with constraints in constants-only fit.
*       Zero out Gamma scores for obs in which a Gamma-including eq is dropped.
*       Switch to favorspeed to avoid apparent bug in ml.
* 6.0.2 Fixed Gamma models messing up displayed parameter names when constraints used 
* 6.0.1 Fixed handling of constants-only fit in Gamma models
* 6.0.0 Allowed references to (latent) linear dep vars, with full simultaneity. Eliminated serious bug in ThetaSign computation in models with more than 2 levels.
* 5.4.5 In InitSearch, for mprobit obs which in some eq get dropped for perfect prediction, remove from all eqs in group
* 5.4.4 Fixed bugs in InitSearch in recognizing factor variables dropped by probit or _rmcoll. Made cmp_full_model omit o. FV's from fvrevar'd lists.
*       Stopped rerunning initial fits when variables dropped in Stata 11 or later. Added "nonrtolerance tolerance(0.1)" for faster, coarser initial fits.
* 5.4.3 Fixed Mata bugs in multi-equation truncation models.
* 5.4.2 Fixed bug causing e(wexp)="=" when no weights used.
* 5.4.1 Fixed typo in code for interactive mode. Updated cmp_d1 and cmp_lf.
* 5.4.0 Made truncation available in all models except multinomial and rank-ordered probit. Thanks to Tamas Bartus for the suggestion.
*       Added custom display of RE and RC results.
*       Interpret "exchangeable" to mean all sigs in a group, not just rhos, the same.
*       Went public with random coefficients
*       Fixed misc bugs
* 5.3.1 Fixed InitSearch bug for eqs with RCs but no RE.
*       Implemented proper dSigdParams construction for RCs.
*       Added use of undocumented ADDCONS feature with buildfvinfo.
* 5.3.0 Added random coefficients (undocumented, beta). Fixed bug in redraws(, anti).
* 5.2.6 Added informative error message if i. variables get different bases in different eqs
* 5.2.5 Prevented crash when two eqs have same name, by suffixing with eq number
*       Fixed bug in constants-only InitSearch when dropping rhos for non-overlapping eqs
* 5.2.4 Dropped e(diparmopt) from call to ml display if that exceeds maximum # of options for syntax command
* 5.2.3 Fixed bug causing crash in mixed censored-uncensored models.
*       Used ereturn, repost to establish correct esample() before using buildfvinfo option. Prevented revar'ing when constraints used.
* 5.2.2 Assured intreg residuals in InitSearch are never missing even if bounds are
* 5.2.1 Changed _rmdcoll to _rmcoll exept for regtype==1
* 5.2.0 Added lnl option to predict
* 5.1.2 Prevented crash when adjustprobitsample restricts sample on only eq that applies to obs, thus restricting sample
*       Prevented crash when model with oprobit has some obs with no oprobit (or otherwise censored) eqs for some obs
* 5.1.1 Prevented crash when diparm tries to display rho version of a dropped atanhrho
* 5.1.0 Added covariance() option
* 5.0.0 Added random effects, iia suboption. Dropped pseudod2.
* 4.0.4 Minor changes in handling of rho's for non-overlapping eqs in constant-only model
* 4.0.3 Added check after _rmdcoll to remove "o." vars in varlist--artifact of factor variable support
* 4.0.2 Tweaked InitSearch tobit code introduced in 3.5.2 for factor var compatibility. No "version 10:" now.
* 4.0.1 Code refinements
* 4.0.0 Added rank-ordered probit support.
* 3.9.3 In InitSearch, eliminated subscripting matrices with "#1" in Stata-provided code fragment for compatibility with Stata <11.
* 3.9.2 Suppressed call to test introduced in 3.9.1 if LR test used 
* 3.9.1 Fixed bugs in handling factor variables with help of Stata Corp. 
*       For intreg, made InitSearch include samples where indicator==1, not just 7
* 3.9.0 Added factor variable support. Thanks to Tamas Bartus for inspiration.
*       Use pseudod2 in Stata version 11.1 or earlier. Code to check version is version dependent! date() takes "dmy" in some versions, "DMY" in others
* 3.8.6 Fixed typo in 3.8.5. Suppressed "equation #1 assumed" in predict if there is only 1 equation
* 3.8.5 Use pseudod2 if Stata born before 11 feb 2010
* 3.8.4 Fixed bug so pseudod2 will call ml to be run under version 9.2 so that cluster() is accepted
*       Fixed bug introduced in 3.6.8--code for vecmultinormal() call for truncregs not properly updated
* 3.8.3 Fixed bug in InitSearch preventing dropping of last regressor from an eq if no SE in preliminary regression and nocons
*       Fixed bug in line determinining version to use for ml. (local a=c(version) can return 9.199999999)
* 3.8.2 Added lnl() option to save observation-level log likelihood. Fixed 3.8.0 bug.
* 3.8.1 Use arguments instead of Stata locals to pass to cmp_lnL() variable names for scores and likelihood
*       Changed required ghk2() version to 1.3.1 because of bug fix in latter
* 3.8.0 Incorporated use of lf1 method by default in Stata 11 and later
* 3.7.0 Fixed minor bugs in InitSearch in handling case of no RHS vars
*       Fixed bug restricting whole-system sample to those of non-as mprobit eqs
* 3.6.9 Got rid of i loop in vecbinormal() for speed
* 3.6.8 Made vecmultinormal() return value and scores of log instead of level. Tightened functions that call it.
* 3.6.7 In cmp_d2, changed constant in h formula from 1e-4 to 1e-5.
*       Introduced normal2() to calculate normal(U)-normal(L) more precisely.
* 3.6.6 Added check in ParseEqs for missing "="
* 3.6.5 Fixed 3.6.4 bug: predict didn't handle SigScoreInds properly when it was empty
* 3.6.4 Fixed bug: code for dropping rhos of non-overlapping eqs broken by 3.5.0.
*       Fixed bug: changed `0' to `"`0'"' in call to cmp_full_model in case command line contains quotes
*       Fixed bug: lack of SE for _cons in InitSearch probit fit didn't cause its coef to be dropped from initial fit vector
* 3.6.3 Added check to cmp_d2 for lnf = 0 after cmp_lnL call
* 3.6.2 Reworked `quietly' 3.5.5 work-around. Put bracketed code in DoInitSearch
* 3.6.1 Fixed bug in 3.6.0
* 3.6.0 Added noestimate option, copying gllamm. Thanks to Stas Kolenikov for suggestion.
* 3.5.6 Made mi-friendly
* 3.5.5 Inserted line break in "`quietly' {" to avoid Stata syntactic pecadillo.
*       If inital guess for Sigma is not positive definite, InitSearch makes it diagonal
* 3.5.4 Allowed reals for level()
* 3.5.3 Added warning about initial single-equation fits deviating from specification.
* 3.5.2 For weighted regressions, InitSearch now uses iweights throughout, except for -tobit- in Stata 9.2, where it must use aweights.
*       This improves starting point. -tobit- does aweights differently from -ml-. (see [R] intreg)
* 3.5.1 Added "did you forget to type cmp setup?"
* 3.5.0 Reorganized to leave no variables behind. Now works with -est (re)store- and -suest-. Dropped cleanup/clear subcommand.
* 3.4.6 Removed bug causing attempt to store potentially non-numeric value labels in e(cat) for oprobit eq
* 3.4.5 Added warning that with GHK changing observation order changes results.
* 3.4.4 Added nopreserve to ml model command in interactive mode
* 3.4.3 Added e(cmdline)
* 3.4.2 Added clear as synonym for cleanup
* 3.4.1 Tightened vecbinormal(), neg_half_E_Dinvsym_E(), and dPhi_dpE_dSig(). Took over model parsing and changed truncreg syntax
* 3.4.0 Added truncreg equation type
* 3.3.3 Run InitSearch even when init() specified in order to consistently perform and report various specification checks. Thanks to Misha Bontch-Osmolovski.
* 3.3.2 Made it use distinct GHK draws for each block of identically censored observations, via new ghk2() s argument
* 3.3.1 Added warning about Stata 9 cluster() behavior with missing values in regressors. Thanks to Misha Bontch-Osmolovski.
* 3.3.0 Added ghk2version check
* 3.2.9 Switched from invsym() to cholinv(). Fixed bug in cmp_p affecting predicted probability after ordered probit for second-highest outcome
* 3.2.8 Added -missing- option to ml model call in interactive model to prevent sample shrinkage
* 3.2.7 Fixed loss of sample marker caused by preserve/restore in Estimate
* 3.2.6 Fixed bug causing crash with use of init()
* 3.2.5 Fixed robust/cluster handling incompatibility between Estimate and Stata 9
* 3.2.4 Changed =r(varlist) to `r(varlist)' after tsrevar so it doesn't treat macros as strings
* 3.2.3 Fixed bugs affecting mprobit score and Hessian computations. mprobit converges much better. Fixed misc bugs.
* 3.2.2 Used tsrevar and preserve/keep/restore to cut down data set for speed in non-interactive mode. Created Estimate subroutine.
*       For non-overlapping samples removed rho_ij from model rather than keeping and constraining to 0, for speed.
* 3.2.1 Added e() and ystar() options to cmp_p
* 3.2.0 Added interval regression type. Replaced minfloat() and maxfloat() for cuts with "."
* 3.1.1 Fixed bug preventing use of user-supplied equation names. Added "_cons" after ":" in _b[] in cmp_p
* 3.1.0 Added psuedo-d2 evaluator as default
* 3.0.3 Fixed call to _ghk2_2d() had dE and dF swapped
* 3.0.2 Made sure empty score matrix still created for cuts in obs with no oprobit eq
* 3.0.1 Fixed bug in determining which cut #s are relevant for which obs when set of oprobit eqs varies
* 3.0.0 Added multinomial probit support. Added lf evaluator. Switched to ghk2(). Added progressive sampling.
* 2.1.0 Fixed bug causing constants-only model to be unweighted
* 2.0.9 Replaced call to symeigenvalues() with one to cholesky() for surprisingly large speed gain.
* 2.0.8 Tightened Mata code. Put missing qui in InitSearch.
* 2.0.7 Fixed bugs in Mata code for ordered probit. Wasn't working if # of o-probit eq varied by obs.
* 2.0.6 Fixed small bug in cmp_p
* 2.0.5 Fixed 2.0.4 bug affecting whether constant included in an ordered probit equation
* 2.0.4 Fixed 2.0.2 bug. Estimation restricted to union of samples for each eq. Was the intersection before 2.0.2. Was set by if/in only in 2.0.2.
* 2.0.3 When using dep var as eq name, remove "." from ts ops
* 2.0.2 Changed response to missing obs. If indicator>0 and obs missing, no longer set touse=0 for all eq--just set indicator=0.
* 2.0.1 Changed e(indicators) to contents of indicators() option. (e(k_dv) holds # of indicators.)
*       Fixed bug in dPhi_dpE_dSig() for ordered-probit case.
* 2.0.0 Added ordered probit and beefed up predict.
* 1.4.1 Added real generation of residuals after probit in InitSearch, so 1.3.1 code doesn't think probit samples overlap no others
* 1.4.0 Added init() option for manual control of initial values
* 1.3.1 Added rho constraints to handle equations with non-overlapping subsamples
* 1.3.0 Added plot feature. Added _rmdcoll check to InitSearch.
* 1.2.8 Fixed typo ("`drop'"") introduced in 1.2.7
* 1.2.7 Turned ghkanti option from an integer to a present/absent macro. Added nodrop option.
* 1.2.6 Changed e(indicators) from macro to scalar
* 1.2.5 Added return macros e(Ni) with equation-specific sample sizes. Prevented errors if cmp cleanup run unnecessarily.
*       Fixed bugs in handling of ts ops.
*       Prevented it from dropping all regressors if an initial 1-equation tobit fails to converge.
* 1.2.4 In interactive mode, moved mlopts from ml model to ml max command, where they belong.
*       Adjusted 1.2.3 fix: iweights for probit and aweight for tobit and regress.
*       Added warning for ill-conditioned regressor matrix.
* 1.2.3 Use aweights instead of pweights, if requested, in InitSearch since Stata 9.2 tobit doesn't accept pweights, and for speed
* 1.2.2 Fixed bug in InitSearch causing it to drop observations with missing even when the missings are in variables/equations marked as out
* 1.2.1 Changed "version 9.2" to "cap version 10" in cmp_ll so callersversion() returns right value.
* 1.2.0 Made it work in Stata 9.2
* 1.1.2 Added noclear to ml command line in interactive mode
* 1.1.1 Prevented repeated display of ghk notification in interactive mode
* 1.1.0 Added interactive option
* 1.0.2 Fixed predict statement after bicensored tobit in InitSearch
* 1.0.1 Minor changes
