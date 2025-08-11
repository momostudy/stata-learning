capture program drop nwxtregress_predict
program define nwxtregress_predict, rclass
	syntax anything [if], [replace *]
	
		if "`replace'" != "" {
			if wordcount("`anything'") == 2 {
				local toremove = word("`anything'",2)
			}
			else {
				local toremove "`anything'"
			}
			cap drop `toremove'
		}

		nw_predict `anything' , `options'	
end


program define nw_predict
	syntax newvarlist(max=1 generate) , [xb RESidual array(string)]

		if "`xb'`residual'" == "" {
			noi disp as smcl "Option {it:xb} assumed."
			local xb xb
		}

		if wordcount("`xb' `residual'") > 1 {
			noi disp as error "Options {it:xb} and {it:residual} cannot be combined."
			error 184			
		}

		qui {
			tempvar smpl
			gen `smpl' = e(sample)

			xtset
			sort `r(panelvar)' `r(timevar)'

			if "`array'" == "" local array `e(output_mat)'

			cap mata asarray_contains(`array',"W")
			if _rc != 0 {
				noi disp in smcl as error "mata array `array' with saved contents from {cmd:nwxtregress} not found."
				exit
			}

			mata CopyData("`varlist'",asarray(`array',"residuals"),"`smpl'")		

			if "`xb'" != "" {
				replace `varlist' = `e(depvar)' - `varlist' if `smpl'
			}
		}

end

capture mata mata drop CopyData()
mata:
	function CopyData(string scalar varn, real matrix data_idt,string scalar smpl)
	{
		

		data_sorted = sort(data_idt,(2,3))

		real matrix var 
		st_view(var,.,varn,smpl)
		var[.,.] = data_sorted[.,1]
	}
end

