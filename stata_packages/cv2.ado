*! cv2 0.2.0 2022-03-13
*! Copyright (c) 2022 Lorenz Graf-Vlachy
*! mail@graf-vlachy.com

* Version history at bottom

cap program drop cv2
prog define cv2, rclass byable(recall)

	local debug 0 // set to 1 to debug, to 0 for release

	// preliminaria
	version 9
	syntax varlist(min=1) [if] [in] [, warn(real 0.05) onlynomiss]
	if ("`onlynomiss'" == "onlynomiss") {
		marksample touse
	}
	else {
		marksample touse, novarlist
	}

	if `debug' di "cv2 invoked in debug mode"

	// retain user's data
	preserve
	
	// remove all obs that are not desired
	qui drop if !`touse'

	// get length of longest varname in list
	tempname maxlen
	scalar `maxlen' = 8
	foreach var in `varlist' {
		scalar `maxlen' = max(`maxlen', strlen("`var'"))
	}
	if (`debug') {
		di "maxlen: " `maxlen' 
	}

	tempname skip
	scalar `skip' = `maxlen'
	local `skip' = `skip' - 8
	
	di as text ""
	di as text " Variable " _dup(``skip'') " " "{c |} Coefficient of Variation"
	di as text _continue "{hline 10}"
	di as text _continue "{hline ``skip''}"
	
	di as text "{c +}{hline 25}"
	
	// loop over all variables
	foreach var in `varlist' {

		// calculate CV
		tempname mean sd cv
		qui sum `var'
		scalar `mean' = r(mean)
		scalar `sd' = r(sd)
			scalar `cv' = `sd' / `mean'
		
		// print output
		tempname cols
		scalar `cols' = `maxlen' - strlen("`var'")
		local `cols' = `cols'
		if `debug' di "cols: " `cols'
		di as text _continue " `var'"
		di as text _continue _dup(``cols'') " " " {c |} " `cv'
		if `debug' di "(mean: " `mean' ", sd: " `sd' ")"
		if `mean' == 0 {
			di as text _continue " (Warning: Mean qual to zero, coefficient of variation cannot be computed)"
		}
		else if `mean' < 0 {
			di as text _continue " (Warning: Mean is negative, coefficient of variation may be misleading)"
		}
		else if abs(`mean') < `warn' {
			di as text _continue " (Warning: Mean below `warn', coefficient of variation may be misleading)"
		}
		di as text ""
	
	}
	
	// restore user data
	restore 

end

* Version history
* 
* 0.1.0	Initial version
* 0.2.0	Added "onlynonmiss" option to reduce sample to only observations for which none of the specified varibales are missing, which was previously the default behavior
