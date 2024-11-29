*! cmp 7.0.0 19 June 2017
*! Copyright David Roodman 2007-13. May be distributed free.
cap program drop cmp_clear
program define cmp_clear
	version 11
	forvalues l=1/0$parse_L {
		cap mat drop cmp_fixed_sigs`l'
		cap mat drop cmp_fixed_rhos`l'
		cap mat drop cmpREInd`l'
	}
	foreach mat in cmp_mprobit_group_inds cmp_roprobit_group_inds cmp_num_cuts cmp_nonbase_cases cmp_RC_T cmp_trunceqs cmp_intregeqs cmp_NumEff cmpGammaInd cmpBetaInd {
		cap mat drop `mat'
	}
	foreach vars in y id u Ut Lt ind {
		cap drop _cmp_`vars'*
	}
	cap drop _mp_cmp*
	cap drop _cmp_y*_*
	macro drop ml_*
	macro drop parse_*
	forvalues eq=1/0$cmp_d {
		macro drop cmp_y`eq'_revar
		macro drop cmp_x`eq'_revar
		macro drop cmp_xo`eq'_revar
		macro drop cmp_xe`eq'_revar
		cap label drop cmp_y`eq'_label
		cap mat drop cmp_cat`eq'
	}
	foreach global in REDraws XVars HasGamma ParamsDisplay SigXform AnyOprobit {
		macro drop cmp`global'
	}
	foreach global in d truncreg* intreg* y* gammaparams* tot_cuts max_cuts eq* x* mprobit_ind_base roprobit_ind_base num_mprobit_groups num_roprobit_groups ///
			reverse rc* re* id* ind* L* Lt* Ut* cov* num_scores num_coefs k probity1 IntMethod weight* {
		macro drop cmp_`global'
	}
	foreach var in _X _Cns _t _p _Y _NumREDraws _mod _lnf _S _H {
		cap mata mata drop `var'
	}
	ml clear
end
