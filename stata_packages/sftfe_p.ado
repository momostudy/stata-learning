*! version 1.0.1  11mar2015

program define sftfe_p, sortpreserve
        version 8

    syntax [anything] [if] [in], [*]

	local S_COST = cond("`e(function)'"=="production", 1, -1)

    local myopts "U JLMS ALPHA JLMSP UP ALPHAS US TES GHKDraws(string)"

	/* Note that us and alphas are for SIM_TFE implemented via _sftfe_mmsle_het_sem() */

    _pred_se "`myopts'" `0'
    if `s(done)' {
        exit
    }
    local vtyp  `s(typ)'
    local varn `s(varn)'
    local 0 `"`s(rest)'"'

    syntax [if] [in] [, `myopts']

    marksample touse 	// this is not e(sample)

    local sumt = ("`u'"!="") + ("`us'"!="") + ("`jlms'"!="") + ("`tes'"!="") + ("`alpha'"!="") + ("`alphas'"!="") + ("`jlmsp'"!="") + ("`up'"!="")
    if `sumt' >1 {
        di as err "only one statistic may be specified"
        exit 198
    }
    else {
        if `sumt' == 0 {
            local stat "xb"
            di as txt "(option xb assumed; fitted values)"
        }
        else {
            local stat "`u'`us'`jlms'`tes'`alpha'`alphas'`jlmsp'`up'"
         }
    }

	*** GHK parsing (adapted from -cmp-)
	if "`e(upattern)'"=="ar1" {
		if "`ghkdraws'"!=""  {

			local 0 `ghkdraws'
			syntax [anything], [type(string)]
			if `"`type'"' != "" local ghktype `type'
			else local ghktype halton
			/*if `"`pivot'"' != "" scalar ghkpivot = 1
			else scalar ghkpivot = 0
			if `"`antithetics'"' != "" scalar ghkanti = 1
			else scalar ghkanti = 0*/

			local 0, ghkdraws(`anything')
			syntax, [ghkdraws(numlist integer>=1 max=1)]
			*scalar ghkdraws = `ghkdraws'

			if inlist(`"`ghktype'"', "halton", "random") == 0 {
				di as error `"The {cmdab:ghkd:raws}' suboption {cmdab:t:ype()} must be "halton" or "random". See help {help ghk2}."'
				error 198
			}
		}
		else {
			loc ghkdraws 1000
			loc ghktype "halton"
		}
	}
	else {
		loc ghkdraws 0
		loc ghktype "none"
	}

    Calc `"`vtyp'"' `varn' `stat' `S_COST' `touse' `ghktype' `ghkdraws'

end

program define Calc
    args vtyp varn stat S_COST cond ghktype ghkdraws 

    local y `e(depvar)'
    local ivar=e(ivar)
    local by "by `ivar'"
    local tvar=e(tvar)

	if inlist("`stat'","us","alphas","tes")==0 {

		sort `ivar' `tvar' `cond'
		if "`e(upattern)'"=="ar1" local upattern "ar1"
		else local upattern "unstructured"

		if ("`stat'"=="jlmsp" | "`stat'"=="up") local pooled "pooled"
		else local pooled

			if "`stat'"=="xb" {
				tempvar xb
				qui _predict double `xb' if e(sample), xb eq(Frontier)
					qui gen `vtyp' `varn'=`xb' if `cond'
					exit
			}
			else if "`stat'"=="alpha" {

				/// the following to correctly estimate alpha in the het case
				/// We need `su2mata' to be passed into _sftfe_alpha mata function
				if "`e(het)'" == "u" {
					tempvar xb_u su2mata sigma_u
					qui _predict double `xb_u' if `cond', xb eq(Usigma)
					qui gen double `sigma_u' = exp(`xb_u')
					qui bys `ivar': egen `su2mata' = mean(`sigma_u')
					local su2mata "`su2mata'"
				}
				else {
					tempname sigma_u
					scalar `sigma_u' = `e(sigma_u)'
				}

				if "`e(het)'" == "v" {
					tempvar xb_v sv2mata sigma_v
					qui _predict double `xb_v' if `cond', xb eq(Vsigma)
					qui gen double `sigma_v' = exp(`xb_v')
					qui bys `ivar': egen `sv2mata' = mean(`sigma_v')
					local sv2mata "`sv2mata'"
				}
				else {
					tempname sigma_v
					scalar `sigma_v' = `e(sigma_v)'
				}

				if "`e(het)'" == "uv" {
					tempvar xb_u su2mata sigma_u
					qui _predict double `xb_u' if `cond', xb eq(Usigma)
					qui gen double `sigma_u' = exp(`xb_u')
					qui bys `ivar': egen `su2mata' = mean(`sigma_u')
					local su2mata "`su2mata'"
					tempvar xb_v sv2mata sigma_v
					qui _predict double `xb_v' if `cond', xb eq(Vsigma)
					qui gen double `sigma_v' = exp(`xb_v')
					qui bys `ivar': egen `sv2mata' = mean(`sigma_v')
					local sv2mata "`sv2mata'"
				}

				tempvar m_y alpha
				qui bys `ivar': egen `m_y' = mean(`y')

				local covar "`e(covariates)'"
				local cov2mata ""
				foreach var of local covar {
					tempvar m_`var'
					qui bys `ivar': egen `m_`var'' = mean(`var')
					local cov2mata "`cov2mata' `m_`var''"
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
					if "`e(mu_rhs)'"!="" {
						local muvec 1
						local mu2mata "`mu'"
					}
					else {
						local muvec 0
						scalar mu2mata = `mu'
					}
				}
				else local muvec .

				if "`e(upattern)'"=="ar1" scalar __rho_ = e(rho)
				qui gen `alpha' = .
				mata: _sftfe_alpha("`ivar'","`m_y'","`cov2mata'","`cond'", `S_COST', "`alpha'", "`e(het)'", "`e(dist)'","`pooled'",`muvec',"`ghktype'",`ghkdraws')
				qui gen `vtyp' `varn'=`alpha' if `cond' & e(sample)==1
				exit

			}


			if "`e(estimator)'" == "pde" | "`e(estimator)'" == "mmsle" | "`e(estimator)'"=="within" | "`e(estimator)'"=="fdiff" {

			/* Common part to predict U and JLMS TE */
			tempvar xb
			qui _predict double `xb' if e(sample), xb eq(Frontier)

				if "`e(het)'" == "u" {
					tempvar xb_u su2mata sigma_u
					qui _predict double `xb_u' if `cond', xb eq(Usigma)
					qui gen double `sigma_u' = exp(`xb_u')
					qui bys `ivar': egen `su2mata' = mean(`sigma_u')
					local su2mata "`su2mata'"
				}
				else {
					tempname sigma_u
					scalar `sigma_u' = `e(sigma_u)'
				}

				if "`e(het)'" == "v" {
					tempvar xb_v sv2mata sigma_v
					qui _predict double `xb_v' if `cond', xb eq(Vsigma)
					qui gen double `sigma_v' = exp(`xb_v')
					qui bys `ivar': egen `sv2mata' = mean(`sigma_v')
					local sv2mata "`sv2mata'"
				}
				else {
					tempname sigma_v
					scalar `sigma_v' = `e(sigma_v)'
				}

				if "`e(het)'" == "uv" {
					tempvar xb_u su2mata sigma_u
					qui _predict double `xb_u' if `cond', xb eq(Usigma)
					qui gen double `sigma_u' = exp(`xb_u')
					qui bys `ivar': egen `su2mata' = mean(`sigma_u')
					local su2mata "`su2mata'"
					tempvar xb_v sv2mata sigma_v
					qui _predict double `xb_v' if `cond', xb eq(Vsigma)
					qui gen double `sigma_v' = exp(`xb_v')
					qui bys `ivar': egen `sv2mata' = mean(`sigma_v')
					local sv2mata "`sv2mata'"
				}

				tempvar m_y alpha res

				if ("`pooled'"=="pooled") qui egen `m_y' = mean(`y')
				else qui bys `ivar': egen `m_y' = mean(`y')

				local covar "`e(covariates)'"
				local cov2mata
				foreach var of local covar {
					tempvar m_`var'
					if ("`pooled'"=="pooled") qui egen `m_`var'' = mean(`var')
					else qui bys `ivar': egen `m_`var'' = mean(`var')
					local cov2mata "`cov2mata' `m_`var''"
				}

				/* truncated-normal */
				if "`e(dist)'" == "tnormal" {
					tempname _b _c _d
					mat `_b' = e(b)
					mat `_c' = `_b'[.,"Mu:"]
					scalar `_d' = colsof(`_c')
					local _colname: colnames `_c'
					if `_d'==1 & "`_colname'"=="_cons" {
						tempname mu
						scalar `mu' = `_c'[1,1]
					}
					else {
						tempvar mu
						qui _predict double `mu' if `cond', eq(Mu) xb
						noi sum `mu'
					}
					if "`e(mu_rhs)'"!="" {
						local muvec 1
						local mu2mata "`mu'"
					}
					else {
						local muvec 0
						scalar mu2mata = `mu'
					}
				}
				else local muvec .

				if "`e(upattern)'"=="ar1" scalar __rho_ = e(rho)
				qui gen `alpha' = .
				mata: _sftfe_alpha("`ivar'","`m_y'","`cov2mata'","`cond'", `S_COST', "`alpha'", "`e(het)'", "`e(dist)'", "`pooled'", `muvec',"`ghktype'",`ghkdraws')

				if ("`pooled'"=="pooled")  {
					qui sum `alpha'
					local alphamean = r(mean)
					qui gen double `res' = `y' - `alphamean' - `xb' if e(sample)
				}
				else qui gen double `res' = `y' - `alpha' - `xb' if e(sample)

		if "`e(upattern)'"=="ar1" {
			qui gen `vtyp' `varn' = .
			mata _sftfe_ar1("`ivar'","`res'","`cov2mata'","`e(het)'","`cond'", `S_COST', "`varn'","`e(dist)'",`muvec',"`ghktype'",`ghkdraws')
			scalar drop __rho_
		}
		else {

			if "`e(dist)'" == "exponential" {
					tempvar zit term1 term2
					gen double `zit' = - `S_COST' * `res'- (`sigma_v'^2/`sigma_u')  if `cond'
					qui gen double `term1' = normalden(-`zit'/`sigma_v')
					qui gen double `term2' = normal(`zit'/`sigma_v')
			}

			if "`e(dist)'" == "hnormal" {
					tempvar mu1 sigma1
					qui gen double `mu1' = -`S_COST'*`res'*`sigma_u'^2/(`sigma_u'^2+`sigma_v'^2) if `cond'==1
					qui gen double `sigma1' = `sigma_u'*`sigma_v'/sqrt(`sigma_u'^2+`sigma_v'^2) if `cond'==1
			}


			if "`e(dist)'" == "tnormal" {
					tempvar mu1 sigma1
					qui gen double `mu1' = (-`S_COST'*`res'*`sigma_u'^2 + ///
								`mu'*`sigma_v'^2)/(`sigma_u'^2+`sigma_v'^2) if `cond'==1
					qui gen double `sigma1' = `sigma_u'*`sigma_v'/ ///
									sqrt(`sigma_u'^2+`sigma_v'^2) if `cond'==1
			}

			************* Get estimates for u=E(u|e) *************
			if "`stat'"=="u" | "`stat'"=="up"  {

				if "`e(dist)'" == "exponential" gen `vtyp' `varn' = `zit' + `sigma_v'*(`term1'/`term2')  if `cond'==1
				if ("`e(dist)'" == "hnormal" | "`e(dist)'" == "tnormal") {
						local z (`mu1'/`sigma1')
						gen `vtyp' `varn' = `mu1'+`sigma1'*(normalden(-`z')/normal(`z')) if `cond'==1
				}
			}

			************* Get estimates for JLMS Technical Efficiency (TE) *************

			if "`stat'"=="jlms" | "`stat'"=="jlmsp" {

				if "`e(dist)'" == "exponential" {
					gen `vtyp' `varn' =  exp(-(`zit' + `sigma_v'*(`term1'/`term2'))) if `cond'==1
				}
				if ("`e(dist)'" == "hnormal" | "`e(dist)'" == "tnormal") {
					local z (`mu1'/`sigma1')
					gen `vtyp' `varn' = exp(-(`mu1'+`sigma1'*(normalden(-`z')/normal(`z')))) if `cond'==1
				}
			}
		}

	} /* close estimator */


} /* CLOSE CHECK ON Sim-tfe */
else {

	// Here predict for SIM-TFE implemented */

	** This sort is needed to get the right nu,mbers in the right places
	sort `tvar'  `ivar'  `cond'

	qui generate `vtyp' `varn' = .
	local tpvar = trim("`varn'")
	if "`stat'"=="us"  {
		qui generate `vtyp' `tpvar'_intrinsic = .
		qui generate `vtyp' `tpvar'_dir = .
		qui generate `vtyp' `tpvar'_indir_ij = .
		qui generate `vtyp' `tpvar'_indir_ji = .
		qui generate `vtyp' `tpvar'_tot_ij = .
		qui generate `vtyp' `tpvar'_tot_ji = .
	}
	if "`stat'"=="tes" {
		local pvar_intrinsic = trim("`varn'")
		local pvar_intrinsic "`pvar_intrinsic'_intrinsic"
		local pvar_spillover = trim("`varn'")
		local pvar_spillover "`pvar_spillover'_spillover"
		qui generate `vtyp' `pvar_intrinsic' = .
		qui generate `vtyp' `pvar_spillover' = .
	}


    *** Get parameters estimates
	/// Initialize and fill estimate vectors
	tempname __b _bbeta _bbbeta _bbetaa _ggamma _theta _vsigma  _rho
	mat `__b' = e(b)
	mat `_bbeta' = `__b'[1,"Frontier:"]
	mat `_ggamma' = `__b'[1,"Usigma:"]
	mat `_vsigma' = `__b'[1,"Vsigma:"]
	//if "`e(effects)'"=="re" mat `_theta' = `__b'[1,"Theta:"]
	mat `_rho' = `__b'[1,"Rho:"]

	m _sftfe_predict(_sftfe_DaTa, "`varn'", "`_bbeta'", "`_ggamma'","`_rho'","`_vsigma'", "`e(u_rhs)'", "`stat'", "`_theta'")
















}




end
