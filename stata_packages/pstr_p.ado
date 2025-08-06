
capture prog drop pstr_p
program define pstr_p, rclass
    version 16
    if "`e(cmd)'" != "pstr" {
        error 301
    }
    syntax newvarlist [if] [in] , [ xb xbu u e ue stf sxnum(integer 0) ]
    marksample touse, novarlist
	// set trace on

    local nopts : word count `xb' `xbu' `u' `e' `ue' `stf'
    if `nopts' >1 {
        display "{err}only one statistic may be specified"
        exit(498)
    }
	else if `nopts'==0 {
		local vcat = "xb"
	}
	else {
		local vcat = strtrim("`xb'`xbu'`u'`e'`ue'`stf'")
	}
	if !inlist("`vcat'", "xb", "xbu", "u", "e", "ue", "stf") {
		dis as error "allowed options: xb, xbu, u, e, ue, stf"
		exit(198)
	}
		tempname p kvec cst stfvec cnum
		matrix `p' = e(b)
		local y = e(depvar)
		local ix = e(ix)
		local ifcons = e(ifcons)
		local sx = e(sx)
		local rx = e(rx)
		matrix `kvec' = e(rxnum)
		matrix `cst' = e(cst)
		matrix `stfvec' = e(stf)
		matrix `cnum' = e(thnum)
	
	qui xtset
	local pid = r(panelvar)
	// set trace on
	if !mi("`stf'") {
		local ksx = e(kstr)
		if `sxnum'>`ksx' {
			dis as error "sxnum() should be less than or equal to the number of transition variable"
			exit(198)
		}
		if (`sxnum'==0) {
			local k = 0
			local nv: word count `varlist'
			if `ksx'!=`nv' {
				dis as error "number of varlist should be equal to the number of transition variable"
				exit(198)
			}
			forvalues i=1/`ksx' {
				local ty: word `i' of `typlist'
				local v: word `i' of `varlist'
				qui gen `ty' `v' = .
			}
		}
		else {
			qui gen `typlist' `varlist' = .
		}
		mata: xtstregpred("`p'","`pid'", "`y'", "`ix'", `ifcons', "`sx'", "`rx'", "`kvec'", "`cst'", "`stfvec'", "`cnum'", "`touse'", "stf", "`varlist'", `sxnum')
    }
	else {
		qui gen `typlist' `varlist' = .
		mata: xtstregpred("`p'", "`pid'",  "`y'", "`ix'", `ifcons', "`sx'", "`rx'", "`kvec'", "`cst'", "`stfvec'", "`cnum'", "`touse'", "`vcat'", "`varlist'") 
	}
end
