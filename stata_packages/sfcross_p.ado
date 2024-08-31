
program define sfcross_p
	version 8 

	syntax [anything] [if] [in], [ SCores *]

	if regexm("`0'","ci")!=0 {
		if regexm("`0'","ci\(")==1 {
			di as err `"Option -ci- incorrectly specified."'
		    exit 198		
		}		
	}
	
	if `"`scores'"' != "" {	
		
		mata: _go__ahead = "0"
		cap mata: _go__ahead = (_Results_cs!="")
		mata: st_numscalar("_go__ahead",_go__ahead)
		if _go__ahead == 0 {
	        di as err `"Scores can be obtained only after a sfcross estimation."'
	        exit 198
	    }
		cap scalar drop _go__ahead
		
		tempvar __esample
		qui gen `__esample' = (e(sample))
		
		mata: _Results_cs = _ReSeT_eSaMpLe_cs(_Results_cs)
		mata: __ScOrE = moptimize_result_scores(_Results_cs)
		
		if regexm("`e(ml_method)'","lf")==1 _score_spec `0'
		else {			
		    mata: st_numscalar("EqN_nUmB", cols(__ScOrE))
			local EqN_nUmB = EqN_nUmB
			scalar drop EqN_nUmB
			_stubstar2names `anything', nvars(`EqN_nUmB') single
		}

		local varn `s(varlist)'
		local vtyp `s(typlist)'
				        
		mata: st_view(__esample=., ., "`__esample'")
		mata: __rule = mm_which(__esample)
		
		local __i = 1
		foreach stubvar of local varn {
			qui gen `:word 1 of `vtyp'' `stubvar' = . if e(sample)==1
			mata: st_store(__rule, "`stubvar'", __ScOrE[.,`__i'] )
		local __i = `__i'+1	
		}
		exit
	}
	
	local S_COST = cond("`e(function)'"=="production", 1, -1) 
	
	
		/* Step 1:
			place command-unique options in local myopts
			Note that standard options are
			LR:
				Index XB Cooksd Hat 
				REsiduals RSTAndard RSTUdent
				STDF STDP STDR noOFFset
			SE:
				Index XB STDP noOFFset
		*/

	local myopts "RES U M BC JLMS MARGinal CI"

		/* Step 2:
			call _propts, exit if done, 
			else collect what was returned.
		*/
	
	_pred_se "`myopts'" `0'

	if `s(done)' {
		exit
	}
	local vtyp  `s(typ)'
	local varn `s(varn)'
	local 0 `"`s(rest)'"'
	
	if regexm("`varn'", "marg")==1 & "`0'"=="" {
		tempname trickmarg
		local vtyp "double"
		local varn "`trickmarg'"
		local 0 ", marginal" 
		local stat "trickmarg"
	}
	
		/* Step 3:
			Parse your syntax.
		*/

	syntax [if] [in] [, `myopts']

	marksample touse

	local sumt = ("`res'"!="") + ("`u'"!="") + ("`bc'"!="") + ("`m'"!="") + ("`jlms'"!="") 
	if `sumt' >1 {
		di as err "only one statistic may be specified"
		exit 198
	}
	else { 
		if `sumt' == 0 {
			if "`ci'"!="" {
				di as err "Confidence interval can be obtained only with option" in yel " u" in red ", " in yel "bc" in red" and " in yel "jlms" in red "." 
				exit 198
			}
			if "`marginal'"=="" {
				local stat "xb"
				di as txt "(option xb assumed; fitted values)"
			}
		}
		else local stat "`res'`u'`m'`bc'`jlms'"
		
		if "`marginal'" != "" local marg 1
		else local marg 0
	}
	
	if ("`stat'" == "" & `marg' == 1 & "`varn'"!="") {
		di as err "Option marginal can be specified together with either " in yel "u" in red "," in yel " jlms" in red "," in yel" bc" in red" or" in yel" m" in red " and alone without {newvar}."
		exit 198	
	}
	
	if ("`stat'" == "m" | "`stat'" == "bc")  & "`e(dist)'"=="gamma" {
		di as err "Option " in yel "`stat'" in red " cannot be specified with Gamma distribution."
		exit 198		
	}
	
	if ("`stat'" == "u" | "`stat'" == "jlms") & "`ci'"!="" & "`e(dist)'"=="gamma" {
		di in gre "Warning: Option `ci' will be ignored with Gamma distribution"
		local ci		
	}
		
	Calc `"`vtyp'"' `varn' `stat' `S_COST' `touse' `marg' `ci'
	 
end

program define Calc
	args vtyp varn stat S_COST cond marg ci
			/* vtyp: type of new variable
			   varn: name of new variable
	 		   cond: if & in
		 	   stat: option specified
			*/

	local y `e(depvar)'
	
	if "`ci'" != "" local ci `e(cilevel)'

	tempvar _uhat xb res mu1 sigma1 A
	/* Predict xb, and get residuals */
	qui _predict double `xb' if `cond', xb
	qui gen double `res'=`y'-`xb' if `cond'
	
	/// XB
    if "`stat'"=="xb" {
    	gen `vtyp' `varn' = `xb' if `cond'
        exit
    }                            

	/// RES
    if "`stat'"=="res" {
    	gen `vtyp' `varn' = `res' if `cond'
        exit
    }

	/// for the remaining, we also need to know the full estimation subsample
	tempvar smpl
	qui gen byte `smpl' = e(sample)
	
	if "`e(dist)'" == "gamma" {	
		
		mata: _go__ahead = "0"
		cap mata: _go__ahead = (_DaTa_cs!="" & _InIt_OpT_cs!="")
		mata: st_numscalar("_go__ahead",_go__ahead)
		if _go__ahead == 0 {
		    di as err `"SF models post-estimation can be performed only after a sfcross estimation."'
		    exit 198
		}
		cap scalar drop _go__ahead
        
		local __PrEdIcT__cs 1
		tempname _b _temp_matrix 
		tempvar  __sfcross_esample _uhat
        
		/// Mark esample for SF gamma models (out of sample prediction is not allowed because of MSL)
		qui gen `__sfcross_esample' = .
		qui replace `__sfcross_esample' = 1 if `smpl'
		markout `cond' `__sfcross_esample'
        
		mat `_b' = e(b)
		_get_eqspec c_eqlist c_stub c_k :  `_b'
		scalar _k = `c_k'
		mata: _SV_predict_cs = J(1, st_numscalar("_k"), _SV_predict_cs())
		local _params_num  = 1
        
		foreach _params of local c_eqlist {
			mat `_temp_matrix' = `_b'[1,"`_params':"]
			mata: _SV_predict_cs = _StArTiNg_VaLuEs_PrEd_cs("`_temp_matrix'", `_params_num', _SV_predict_cs)	
			** The following to check the content of the structure ** Just for debugging
			*mata: liststruct(_SV_predict_cs)
			local _params_num = `_params_num' + 1
		}
		qui gen `_uhat'=.
		mata: _InIt_OpT_cs = _ReSeTi_EsAmPlE_cs(_InIt_OpT_cs)
		mata: _PrEdIcT_cs(_DaTa_cs, _SV_predict_cs, _InIt_OpT_cs, "`_uhat'")
		if "`stat'"=="u" {
			gen `vtyp' `varn'=`_uhat' if `cond'
			label var `varn' "E(u|e)"
			exit
		}
		/* Get estimates for Technical Efficiency (TE) via Jondrow-Lovell-Materov-Schmidt (1982)*/
		if "`stat'"=="jlms" {
			gen `vtyp' `varn' = exp(-`_uhat') if `cond'
			label var `varn' "Tech efficiency index of exp(-E(u|e))"
			exit
		}
    }

	if "`stat'" != "xb" & "`e(dist)'"!="gamma" {
		
		/// Fix key parameters for subsequent post-estimation
		if "`e(het)'" == "" {
			tempname sigma_v sigma_u
			scalar `sigma_v' = exp(0.5*[Vsigma]_cons)
			scalar `sigma_u' = exp(0.5*[Usigma]_cons)
		} 	
		if "`e(het)'" == "u" {
			tempname sigma_v
			scalar `sigma_v' = exp(0.5*[Vsigma]_cons)
    	
			tempvar xb_u sigma_u
			qui _predict double `xb_u' if `cond', xb eq(Usigma)
			qui gen double `sigma_u' = exp(0.5*`xb_u')
		}	
		if "`e(het)'" == "v" {
			tempname sigma_u
			scalar `sigma_u' = exp(0.5*[Usigma]_cons)
    	
			tempvar xb_v sigma_v
			qui _predict double `xb_v' if `cond', xb eq(Vsigma)
			qui gen double `sigma_v' = exp(0.5*`xb_v')
		}	
		if "`e(het)'" == "uv" {
			tempvar xb_u xb_v sigma_v sigma_u
			qui _predict double `xb_u' if `cond', xb eq(Usigma)
			qui gen double `sigma_u' = exp(0.5*`xb_u')
    	
			qui _predict double `xb_v' if `cond', xb eq(Vsigma)
			qui gen double `sigma_v' = exp(0.5*`xb_v')
		}
		
		/* truncated-normal */
		if "`e(dist)'" == "tnormal" {
			tempname _b _c _d 
			
			mat `_b' = e(b)
			mat `_c' = `_b'[.,"Mu:"]
			scalar `_d' = colsof(`_c')
			if `_d'==1 {
				tempname mu
				scalar `mu' = `_c'[1,1]
			}
			else {
				tempvar mu
				qui _predict double `mu' if `cond', eq(Mu) xb
			}
		}			
    	
		////// POST-ESTIMATION ///////
		if "`e(dist)'" == "hnormal" {
			qui gen double `mu1' = -`S_COST'*`res'*`sigma_u'^2/(`sigma_u'^2+`sigma_v'^2) if `cond'
			qui gen double `sigma1' = `sigma_u'*`sigma_v'/sqrt(`sigma_u'^2+`sigma_v'^2) if `cond'
		}
		if "`e(dist)'" == "exponential" {
			qui gen double `mu1' = -`S_COST'*`res'-(`sigma_v'^2/`sigma_u') if `cond'
			qui gen `sigma1'     = `sigma_v' if `cond'
			qui gen `A'          =  -`mu1'/`sigma1' if `cond'
		}
		if "`e(dist)'" == "tnormal" {
			qui gen double `mu1' = (-`S_COST'*`res'*`sigma_u'^2 + ///
			                     `mu'*`sigma_v'^2)/(`sigma_u'^2+`sigma_v'^2) if `cond'
			qui gen double `sigma1' = `sigma_u'*`sigma_v'/ ///
				                    sqrt(`sigma_u'^2+`sigma_v'^2) if `cond'
		}	
    	local z (`mu1'/`sigma1')

		/* Get estimates for u=E(u|e) via Jondrow-Lovell-Materov-Schmidt (1982)*/
		if "`e(dist)'" == "hnormal" | "`e(dist)'" == "tnormal" {
				qui gen double `_uhat' = `mu1'+`sigma1'*(normalden(-`z')/normal(`z')) if `cond'
			}
		if "`e(dist)'" == "exponential" {
				qui gen double `_uhat' = `sigma1'*((normalden(`A')/(1-normal(`A')))-`A') if `cond'
		}
    	
		/* Store estimates for E(u|e) */
		if "`stat'"=="u" {
			gen `vtyp' `varn'=`_uhat' if `cond'
			
			if `S_COST' == 1 label var `varn' "Technical inefficiency via E(u|e)"
			else label var `varn' "Cost inefficiency via E(u|e)"
			
			/* Get CI for Inefficiency */
			if  "`ci'"!=""  {
					tempvar zl zu
					tempname alpha
					scalar `alpha' = (1-.`ci')
					gen `zu' = invnormal(1 - ((`alpha'/2) * norm(`z')))
					gen `zl' = invnormal((`alpha'/2) + ((1 - (`alpha'/2)) * norm(-`z')))
					local cin = `ci'
					gen `varn'_LB`cin' = `mu1' + `zl' * `sigma1'
					lab var `varn'_LB`cin' "`cin'% lower bound of E(u|e)"
					gen `varn'_UB`cin' = `mu1' + `zu' * `sigma1'
					lab var `varn'_UB`cin' "`cin'% upper bound of E(u|e)"
			}
		}
		/* Store estimates for M(u|e) */
		if "`stat'"=="m" {
			gen `vtyp' `varn'=cond(`mu1'>=0, `mu1', 0) if `cond'
			if `S_COST' == 1 label var `varn' "Technical inefficiency via M(u|e)"
			else label var `varn' "Cost inefficiency via M(u|e)"
			exit
		}
    	
		/* Get estimates for Technical Efficiency (TE) via Jondrow-Lovell-Materov-Schmidt (1982)*/
		if "`stat'"=="jlms" {
			gen `vtyp' `varn' = exp(-`_uhat') if `cond'
			if `S_COST' == 1 label var `varn' "Technical efficiency via exp[-E(u|e)]"
			else label var `varn' "Cost efficiency via exp[-E(u|e)]"
			/* Get CI for Technical Efficiency (TE) */
			if  "`ci'"!=""  {
					tempvar zl zu
					tempname alpha
					scalar `alpha' = (1-.`ci')
					gen `zu' = invnormal(1 - (1- (`alpha')/2) * norm(`z')  )
					gen `zl' = invnormal(1 - ((`alpha')/2) * norm(`z')  )
					local cin = `ci'
					gen `varn'_LB`cin' = exp(-`mu1' - `zl' * `sigma1')
					lab var `varn'_LB`cin' "`cin'% lower bound of exp[-E(u|e)]"
					gen `varn'_UB`cin' = exp(-`mu1' - `zu' * `sigma1')
					lab var `varn'_UB`cin' "`cin'% upper bound of exp[-E(u|e)]"
			}
		}
		
		/* Get estimates for Efficiency via Battese-Coelli (1988)*/
		if "`stat'"=="bc" {
				qui gen `vtyp' `varn'= (normal(-`sigma1'+`z'))/ ///
					 normal(`z') *exp(-`mu1'+1/2*`sigma1'^2) if `cond'
				
				if `S_COST' == 1 label var `varn' "Technical efficiency via E[exp(-u)|e]"
				else label var `varn' "Cost efficiency via E[exp(-u)|e]"
	
				/* Get CI for Battese-Coelli (1988) Efficiency*/
				if  "`ci'"!=""  {
						tempvar zl zu
						tempname alpha
						scalar `alpha' = (1-.`ci')
						gen `zu' = invnormal(1 - (1- (`alpha')/2) * norm(`z')  )
						gen `zl' = invnormal(1 - ((`alpha')/2) * norm(`z')  )
						local cin = `ci'
						gen `varn'_LB`cin' = exp(-`mu1' - `zl' * `sigma1')
						lab var `varn'_LB`cin' "`cin'% lower bound of E[exp(-u)|e]"
						gen `varn'_UB`cin' = exp(-`mu1' - `zu' * `sigma1')
						lab var `varn'_UB`cin' "`cin'% upper bound of E[exp(-u)|e]"
				}
		}

	}
	
	
	if (`marg'==1 & "`e(dist)'"=="tnormal") {

		    tempname margb mucoeffs sigmaucoeffs _hetero _ratio fsterm combi1 combi2 _coe1 _coe12 mgef
			matrix `margb' = e(b)
			
				matrix `mucoeffs' = `margb'[1, "Mu:"] 
				matrix `sigmaucoeffs' = `margb'[1, "Usigma:"] 
				local muvarn: coln `mucoeffs' 
				local uvarn: coln `sigmaucoeffs'
				local _k_mu: word count `muvarn'
				local _k_u: word count `uvarn'
				
				if ((`_k_mu' > 1) & (`_k_u' == 1) & ("`uvarn'"=="_cons")) local _check_case1 "1"
				if ((`_k_mu' == 1) & (`_k_u' > 1) & ("`muvarn'"=="_cons")) local _check_case2 "1"

				if `_k_mu' == 1 & `_k_u' == 1 & "`muvarn'" == "_cons" & "`uvarn'"== "_cons" di in gr "Warning: Cannot compute marginal effects if no covariates are included in emean() and usigma()."		
				if ((`_k_mu' == `_k_u') & ("`muvarn'" != "`uvarn'")) { 
				   di in red "Cannot compute marginal effects if emean() and usigma() variables are not the same."
				   exit 198
				}
				else if (`_k_mu' != `_k_u') & "`_check_case1'"=="" & "`_check_case2'"=="" {
				   di in red "Cannot compute marginal effects if emean() and usigma() variables are not the same."
				   exit 198
				}
				else if "`_check_case1'"=="1" { 
				   scalar _sost = `sigmaucoeffs'[1,1] 
				   matrix `sigmaucoeffs' = J(1, `_k_mu', 0) 
				   matrix `sigmaucoeffs'[1, `_k_mu'] = _sost 
				   scalar `_hetero' = 0
				}
				else if "`_check_case1'"=="2" { 
				   scalar _sost = `mucoeffs'[1,1] 
				   matrix `mucoeffs' = J(1, `_k_u', 0) 
				   matrix `mucoeffs'[1, `_k_u'] = _sost 
				   scalar `_hetero' = 0
				}
				else scalar `_hetero' = 1
		

			/* The following is the marginal effect on unconditional E(u) based Wang (2002) */

			local ii = 1
			cap scalar `_coe1' = `mucoeffs'[1,`ii']
			cap scalar `_coe12' = `sigmaucoeffs'[1,`ii']

			tokenize "`muvarn'"
			local _thevar ``ii''

			while (`_coe1' != .) & ("`_thevar'"!="_cons") {

	   			          quie gen double `_ratio' = (`mu')/`sigma_u' if `cond'
	   			          quie gen double `fsterm' = normalden(`_ratio')/normal(`_ratio') if `cond'
	   			          quie gen double `combi1' = `_coe1'*( 1 - (`_ratio')*(`fsterm') - (`fsterm')^2) if `cond'
	   			          quie gen double `combi2' = 0.5*(`_coe12')*( (`sigma_u' + (`mu')*(`_ratio'))*(`fsterm') + (`mu')*(`fsterm')^2) if `cond'
	   			          quie gen double `mgef' = `combi1' + `combi2' if `cond'
	   			  
	   			          *capture drop `_thevar'_M
						  if regexm("`_thevar'", "\.")==1 {
								gettoken _fp_thevar _sp_thevar: _thevar, parse(".")
								local _fp_thevar = subinstr("`_fp_thevar'",".","_",.)
								local _sp_thevar = subinstr("`_sp_thevar'",".","",1)
								local _sp_thevar = subinstr("`_sp_thevar'",".","_",.)
								local _fp_thevar = subinstr("`_fp_thevar'","(","_",.)
								local _sp_thevar = subinstr("`_sp_thevar'","(","_",.)
								local _fp_thevar = subinstr("`_fp_thevar'",")","_",.)
								local _sp_thevar = subinstr("`_sp_thevar'",")","_",.)
								local _fp_thevar = subinstr("`_fp_thevar'","#","_",.)
								local _sp_thevar = subinstr("`_sp_thevar'","#","_",.)
								local _thevar "`_sp_thevar'_`_fp_thevar'"
						  }
	   			          gen double `_thevar'_M = `mgef' if `cond'
	   			          label var `_thevar'_M "Marginal effect of `_thevar' on E(u)"

	   			      local ii = `ii' + 1

	   			        foreach X in `_ratio' `mgef' `fsterm' `combi1' `combi2' {
	   			           capture drop `X'
	   			        }

	   			      scalar `_coe1' = `mucoeffs'[1,`ii']
	   			      scalar `_coe12' = `sigmaucoeffs'[1, `ii']

	   			      tokenize "`muvarn'"
	   			      local _thevar ``ii''
			}

	   		/* The following is the marginal effect on unconditional V(u) based on Wang (2002) */


	   		local ii = 1
	   		capture scalar `_coe1' = `mucoeffs'[1,`ii']
	   		capture scalar `_coe12' = `sigmaucoeffs'[1,`ii']

	   		tokenize "`uvarn'"
	   		local _thevar ``ii''

	   		while (`_coe1' != .) & ("`_thevar'"!= "_cons") {
	    
				        quie gen double `_ratio' = (`mu')/`sigma_u' if `cond'
				        quie gen double `fsterm' = normalden(`_ratio')/normal(`_ratio') if `cond'
				        quie gen double `combi1' = (`fsterm')*((`mu')^2 -(`sigma_u'^2))/(`sigma_u') + (`fsterm')^2*3*(`mu') + (`fsterm')^3*2*(`sigma_u')  if `cond'
				        quie gen double `combi2' = `sigma_u'^2 - (`fsterm')*(((`sigma_u'^2)*(`mu') + (`mu')^3)/(2*(`sigma_u'))) - (`fsterm')^2*(`sigma_u'^2 + 1.5*(`mu')^2) - (`fsterm')^3*(`sigma_u')*(`mu')  if `cond'
				        quie gen double `mgef' =  (`_coe1')*(`combi1') + (`_coe12')*(`combi2')  if `cond'
				
				        *capture drop `_thevar'_V
					    if regexm("`_thevar'", "\.")==1 {
							gettoken _fp_thevar _sp_thevar: _thevar, parse(".")
							local _fp_thevar = subinstr("`_fp_thevar'",".","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'",".","",1)
							local _sp_thevar = subinstr("`_sp_thevar'",".","_",.)
							local _fp_thevar = subinstr("`_fp_thevar'","(","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'","(","_",.)
							local _fp_thevar = subinstr("`_fp_thevar'",")","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'",")","_",.)
							local _fp_thevar = subinstr("`_fp_thevar'","#","_",.)
							local _sp_thevar = subinstr("`_sp_thevar'","#","_",.)
							local _thevar "`_sp_thevar'_`_fp_thevar'"
					    }
				        gen double `_thevar'_V = `mgef'  if `cond'
				        label var `_thevar'_V "Marginal effect of `_thevar' on V(u)"

				    local ii = `ii' + 1

				      foreach X in `_ratio' `fsterm' `mgef' `combi1' `combi2' {
				         capture drop `X'
				      }

				    scalar `_coe1' = `mucoeffs'[1,`ii']
				    scalar `_coe12' = `sigmaucoeffs'[1, `ii']
					tokenize "`uvarn'"
					local _thevar ``ii''
			}


	}
	else if (`marg'==1 & "`e(dist)'"!="tnormal") di in gr "Warning: Cannot compute marginal effects if distribution is different from tnormal."		

		
end






