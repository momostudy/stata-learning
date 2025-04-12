program define spread
	version 12.1
	syntax varlist, [variable(varname) value(varname) label(string)]
	tokenize `varlist'
	local variable `1'
	local value `2'
	qui{

		/* take care of label */
		if "`label'" == "" & "`:value label `variable''" ~= ""{
			tempvar label
			decode `variable', gen(`label')
		}

		/* create variable`i' and label`i' */
		sort `variable'
		tempvar bylength
		bys `variable' : gen double `bylength' = _N 
		local start = 1
		local i = 0
		while `start' <= _N {
			local i = `i' + 1
			local end = `start' + `=`bylength'[`start']' - 1
			local variable_levels `"`variable_levels'  `"`=`variable'[`start']'"'"'
			if "`label'" ~= ""{
				local label_levels `"`label_levels'  `"`=`label'[`start']'"'"'
			}
			local start = `end' + 1
		}
		local n = `i'

		ds `variable' `value' `label' `bylength' , not
		local ivar `r(varlist)'
		if "`ivar'" == ""{
			tempvar newivar
			gen `newivar' = _N
			local ivar `newivar'
		}
		



		cap	confirm string variable `variable' 
		if _rc{
			local string ""
		}
		else{
			local string string
			tempvar temp
			gen `temp' = !regexm(`variable',"^[a-zA-Z_]*[a-zA-Z\_0-9]*$")
			count if `temp' == 1
			if `r(N)' > 0 {
				levelsof `variable' if `temp' == 1
				display as error `"Some observations for `variable' don't have valid variable names: `=r(levels)'"'
				exit 4
			}
			foreach v in `ivar'{
				local i : list posof "`v'" in variable_levels
				if `i' ~= 0{
					display as error `"The value `v' for the variable "`variable'" conflicts with existing variables"' 
					exit 4
				}
			}
		}
		/* manage when more than 10 id variables */
		loca ni `:word count `ivar''
		if `ni' > 10{
			tempvar id
			bys `ivar': gen `id' = 1
			qui replace `id' = sum(`id')
			local i `id'
		}
		else{
			local i `ivar'
		}

		/* reshape */
		drop `bylength' `label'
		qui reshape wide `value', i(`i') j(`variable') `string'

		/* check all new variable names are valid new variable name */

		if "`string'" == ""{
			local change "no"
		}
		else{
			forval i = 1/`n'{
				local v : word `i' of `variable_levels'
				cap confirm new variable `v'
				if _rc{
					di as error "`value'`v'"
					local change "no"
				}
			}
		}


	forval i = 1/`n'{
		local v : word `i' of `variable_levels'
		if "`change'" != "no"{
			rename `value'`v' `v'
			local names `names' `v'
			if "`label'" ~= ""{
				local l : word `i' of  `label_levels'
				label variable `v' `"`l'"'
			}
		}
		else{
			local names `names' `value'`v'
			if "`label'" ~= ""{
				local l : word `i' of  `label_levels'
				label variable `value'`v' `"`l'"'
			}
		}
	}
	di as result "new variables created: " as text "`=subinstr("`names'", " ", ", ", .)'"
}
end










