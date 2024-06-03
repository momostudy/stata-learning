*! version 3.6.2 7 May 2015
*! David Roodman, david@davidroodman.com
cap program drop xtab2_p
program define xtab2_p
	version 7.0
  syntax newvarname [if] [in], [XB REsiduals DIFFerence]
	tempname touse
	mark `touse' `if' `in'

	if "`xb'`residuals'" == "xbresiduals" {
		di as err "You can only predict one statistic at a time."
		exit 198 
	}
	if "`xb'`residuals'`difference'" == "" {
		di as txt "(option xb assumed; fitted values)"
	}
	_predict `typlist' `varlist' if `touse'
	label var `varlist' "Fitted Values"
	if "`e(esttype)'" == "difference" {
		cap version 10: estimates esample
		if !_rc & "`r(who)'"=="zero'd" {
			di as txt "Warning: Estimation sample definition lost. Predictions could not be adjusted to have the same sample average as " as res "`e(depvar)'" as txt "."
		}
		else {
			sum `e(depvar)' if e(sample), meanonly
			local yavg = r(mean)
			sum `varlist' if e(sample), meanonly
			*qui replace `varlist' = `varlist' - `r(mean)' + `yavg'
		}
	}
	if "`residuals'" != "" {
		qui replace `varlist' = `e(depvar)' - `varlist'
		label var `varlist' Residuals
	}
	if "`difference'" != "" {
		qui replace `touse' = D.`varlist'
		qui replace `varlist' = `touse'
		label var `varlist' "Differenced `:var label `varlist''"
	}
end
