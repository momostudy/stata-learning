*! abar 1.1.4 15 August 2012
*! David Roodman, Center for Global Development, Washington, DC, www.cgdev.org

* Version history
* 1.1.4 Added cap di at end to zero out return code, which recode sets to 111 for some reason
* 1.1.3 Fixed bug in 1.1.2 (tsrevar =&gt; fvrevar)
* 1.1.2 Added work-around for newey's ommission of "=" from e(wexp).
* 1.1.1 Added code to handle dropped/omitted ("o.") variables in e(b) and e(V) in Stata 11 and later
* 1.1.0 Added support for weights. Fixed bug created by ivreg2 move from "gmm" to "gmm2s". Added support for ivregress 2sls and ivreg2 Newey-West.
* 1.0.5 Added warning for time series
* 1.0.4 Prevented crash running after ivreg2, gmm on time series
* 1.0.3 Prevented crash in case tmax=tmin and cluster()
* 1.0.2 Optimized code for OLS case
cap program drop abar
program define abar, rclass
	version 7.0

	di as err "Warning: This version of {cmd:abar} may be out of date."
	di as err `"For the latest, type or click on {stata "ssc install abar, replace"}. Then restart Stata."'

	syntax [if] [in], [Lags(integer 1)]

	if `lags' &lt; 1 {
		di as error "Number of tests must be positive."
		exit 7
	}
	if "`e(cmd)'" != "regress" &amp; "`e(cmd)'" != "ivreg" &amp; "`e(cmd)'" != "ivregress" &amp; "`e(cmd)'" != "ivreg2" &amp; "`e(cmd)'" != "ivreg3" &amp; "`e(cmd)'" != "newey" &amp; "`e(cmd)'" != "newey2" {
		di as err "This command only works after {cmd:regress}, {cmd:ivreg}, {cmd:ivregress}, {cmd:ivreg2}, {cmd:newey}, and {cmd:newey2}."
		exit 301
	}
	if "`e(cmd)'"=="ivregress" &amp; "`e(estimator)'"=="liml" {
		di as err "This command does not work after {cmd:ivregress, liml}."
		exit 301
	}
	if "`e(cmd)'"=="ivregress" &amp; "`e(estimator)'"=="gmm" {
		di as err "This command does not work after {cmd:ivregress, gmm}. It works after {cmd:ivreg2, gmm2s}, which computes different standard errors."
		exit 301
	}

	tempname b V A ZX ZXA tmp ZwHw Zei d Q Xw ar arp ewi m2QZXA
	tempvar e w ewvar etmp Hw 

	local ols ="`e(model)'" == "ols" | "`e(cmd)'" == "newey"
	local gmm = "`e(model)'`e(estimator)'" == "gmm" | "`e(model)'" == "gmm2s"
	local robust = "`e(vcetype)'" == "Robust" | "`e(vcetype)'" == "HAC" | "`e(cmd)'"=="newey" | "`e(cmd)'"=="newey2"
	local newey = "`e(vcetype)'" == "Newey-West" | "`e(vcetype)'" == "HAC" | "`e(kernel)'" == "Bartlett"
	local cluster = "`e(clustvar)'" != ""
	if `newey' {
		if "`e(cmd)'"=="ivregress" { local nwlags : word 3 of `e(vce)' }
		else {                      local nwlags = `e(bw)'`e(lag)'-("`e(cmd)'"=="ivreg2") }
	}

	quietly {

	tsset
	local t `r(timevar)'
	local id `r(panelvar)'
	if "`id'" == "" {
		noi di as res "Warning: The Arellano-Bond test is only valid for time series only if they are ergodic."
	}

	preserve

	if `cluster' &amp; "`id'" == "" {
		tempvar id
		egen long `id' = group(`e(clustvar)')
		tsset `id' `t'
	}

	mat `b' = e(b)
	mat `V' = e(V)

	if 0`c(stata_version)' &gt;= 11 {
		mata _b = st_matrix(_bname = st_local("b"))
		mata _V = st_matrix(_Vname = st_local("V"))
		mata _i = substr((_xvars = st_matrixcolstripe(_bname))[.,2]', 1, 2) :!= "o."
		mata st_matrix(_bname, select(_b, _i))
		mata st_matrix(_Vname, select(select(_V, _i), _i'))
		mata st_matrixcolstripe(_bname, select(_xvars, _i'))
		local tsfv fv
	}
	else local tsfv ts

	local xvars : colnames `b'
	local xvars : subinstr local xvars "_cons" "", count (local n)
	if `n' {
		tempvar cons
		gen byte `cons' = 1
		local xvars `xvars' `cons'
	}

	`tsfv'revar `xvars'
	local xvars `r(varlist)'

 	predict double `e', resid

	if !`ols' {
		if `gmm' {
			mat `A' = e(W)
			local zvars : colnames `A'
			local zvars : subinstr local zvars "_cons" "`cons'"
		}
		else {
			local zvars `e(insts)' `cons'
		}
		`tsfv'revar `zvars'
		local zvars `r(varlist)'
	}

	marksample touse
	keep if e(sample) &amp; `touse'
	if "`e(wexp)'" != "" {
		tempvar wtvar e0
		gen double `wtvar'`=cond("`e(cmd)'"=="newey", "=","")'`e(wexp)' if `touse'
		local wtype = cond("`e(wtype)'"=="fweight" &amp; (`gmm' | `cluster' | `robust'), "aweight", "`e(wtype)'")
		local wgtexp [`wtype'=`wtvar']
		if "`wtype'" == "aweight" | "`wtype'" == "pweight" {
			sum `wtvar', mean
			replace `wtvar' = `wtvar' / r(mean)
		}
		ren `e' `e0'
		gen double `e' = `e0' * `wtvar'
	}
	else { local e0 `e' }

	if `ols' {
		mat accum `Q' = `xvars' `wgtexp', noconstant
		mat `m2QZXA' = -4 *  syminv(`Q' + `Q'')
		local zvars `xvars'
	}
	else {
		if `gmm' == 0 {
			mat accum `A' = `zvars' `wgtexp', noconstant
			mat `A' = syminv((`A' + `A'')/2)
		}
		
		foreach x of local xvars {
			mat vecaccum `tmp' = `x' `zvars' `wgtexp', noconstant
			mat `ZX' = nullmat(`ZX') \ `tmp'
		}
		mat `ZXA' = `ZX' * `A'
		mat `Q' = `ZXA' * `ZX''
		mat `m2QZXA' = -4 * syminv(`Q' + `Q'') * `ZXA'
	}

	if (`gmm' | `cluster') == 0 {
		tempvar e2
		if "`wtvar'"=="" {
			gen double `e2' = cond(`robust', `e', e(rmse))^2
		}
		else {
			gen double `e2' = cond(`robust', `e'^2/`wtvar', e(rmse)^2*`wtvar')
		}
	}

	sum `t', meanonly 
	local tspan = r(max) - r(min)
	forvalues l = 1/`=min(`lags',`tspan')' {
		gen double `w' = L`l'.`e0'
		recode `w' . = 0
		gen double `ewvar' = `w' * `e'
		sum `ewvar', meanonly
		local ew `r(sum)'
		if (`gmm' | `cluster') == 0 {
			mat vecaccum `ZwHw' = `w' `w' `zvars' [iweight=`e2'], noconstant
			if `newey' {
				gen double `Hw' = 0
				forvalues j = 1/`nwlags' {
					replace `Hw'=`Hw'+(cond(L`j'.`ewvar'!=.,L`j'.`ewvar',0)+cond(F`j'.`ewvar'!=.,F`j'.`ewvar',0))*`=(1-`j'/(1+`nwlags'))'
				}
				replace `Hw' = `Hw' * `e'
				mat vecaccum `tmp' = `Hw' `w' `zvars', noconstant
				mat `ZwHw' = `ZwHw' + `tmp'
				drop `Hw'
			}
		}
		else {
			`=cond("`id'" == "", "", "by `id' :")' egen double `ewi' = sum(`ewvar')
			gen double `etmp' = cond(`ewi' &lt; 0, -`e', `e') /* flip signs on two terms at once to ensure ewi always positive */
			replace `ewi' = abs(`ewi')
			mat vecaccum `ZwHw' = `etmp' `w' `zvars' [iweight = `ewi'], noconstant
			drop `ewi' `etmp'
		}
		mat vecaccum `Xw' = `w' `xvars' `wgtexp', noconstant
		mat `d' = `ZwHw'[1,1] + `Xw' * (`m2QZXA' * `ZwHw'[1,2...]' + `V' * `Xw'')
		scalar `ar' = `ew' / sqrt(`d'[1,1])
		scalar `arp' = 2 * normprob(-abs(`ar'))
		ret scalar ar`l' = `ar'
		ret scalar ar`l'p = `arp'
		noi di as txt "Arellano-Bond test for AR(`l'): z = " as res %6.2f `ar' as txt "  Pr &gt; z = " as res %6.4f `arp'
		drop `w' `ewvar' 
	}

	forvalues l = `=`tspan'+1'/`lags' {
		ret scalar ar`l' = .
		ret scalar ar`l'p = .
		noi di as txt "Arellano-Bond test for AR(`l'): z = .  Pr &gt; z = ."
	}

	} /* quietly */

	restore
	cap display // zero out return code
end
