*! version 2.0.1 SRD & JI 22jul2010
program define zscore
	version 7.0
	syntax varlist [aweight fweight iweight] [if] [in] /*
		*/ [, stub(string) Listwise]

	if "`weight'" != "" {
		local weight "[`weight'`exp']"
	}

	if "`stub'" == "" {
		local stub "z_"
	}

	foreach var of local varlist {
		capture confirm new variable `stub'`var'
		if _rc > 0 {
			di as err "`stub'`var' is not a valid variable name"
			exit 198
		}
	}

	if "`listwise'" != "" {
		tempvar totmis
		egen `totmis' = rowmiss(`varlist')
		if "`if'" == "" {
			local if "if (`totmis' == 0)"
		}
		else {
			local if "`if' & (`totmis' == 0)"
		}
	}

	foreach var of local varlist {
		qui sum `var' `weight' `if' `in'
		qui gen double `stub'`var' = (`var' - r(mean)) / r(sd) `if' `in'

		qui count if `stub'`var' == .
		local miss = r(N)

		if `miss' == 1 {
			local value "value"
		}
		else {
			local value "values"
		}

		local type : type `stub'`var'
		di as res "`stub'`var' " as txt /*
			*/ "created with `miss' missing `value'"
	}
end

