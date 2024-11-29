program define cluster2, rclass
	version 10.1
	syntax [, a(real 0.05) p(real 0.8) rho(real 0) rxy(real 0) d(real 1) n2(integer 1) n1(integer 1) power mdes obs2 obs1]
		foreach x in rho rxy {
			if abs(``x'')>1 {
				di ""
				di "ERROR: condition -1<`x'<1 not met"
				di ""
				exit 499
			}
		}
		foreach x in a p {
			if ``x''>1 | ``x''<0 {
				di ""
				di "ERROR: condition 0<`x'<1 not met"
				di ""
				exit 499
			}
		}

		if `n2'<=0 | `n1'<=0 {
		    di ""
			di "ERROR: n2 and/or n1 must be >=1"
			di ""
			exit 499
		}

		if "`power'"!="" {
			local  f = 1 + (`n1'-1)*`rho'
			local  p = normal(`d'*sqrt(`n2'*`n1'/(2*`f'*(1-`rxy'^2)))-invnormal(1-`a'/2))
		}
		
		if "`obs2'"!="" {
			local  f = 1 + (`n1'-1)*`rho'
			local  g = (invnormal(1-`a'/2)+invnormal(`p'))
			local n2 = round((2*`f'*(1-(`rxy')^2)*`g'^2)/(`n1'*`d'^2))
		}
		
		if "`obs1'"!="" {
			local  g = (invnormal(1-`a'/2)+invnormal(`p'))
			local n1 = round((2*(1-`rho')*(1-`rxy'^2)*`g'^2)/(`n2'*(`d'^2)-2*`rho'*(1-`rxy'^2)*`g'^2))
		}
		
		if "`mdes'"!="" {
			local  f = 1 + (`n1'-1)*`rho'
			local  g = (invnormal(1-`a'/2)+invnormal(`p'))
			local  d = `g'*sqrt((2*`f'*(1-`rxy'^2))/(`n2'*`n1'))
		}

		if "`power'"=="" & "`mdes'"=="" & "`obs2'"=="" & "`obs1'"=="" {
			di "ERROR: must use one of the following options; power, mdes, obs2, or obs1"
			exit 499
		}
		local N = 2*`n2'*`n1'
		di in green "*****************************************************"
		di in green "Alpha =" as result %4.3f _col(40) `a'
		di in green ""
		di in green "ICC =" as result %4.3f _col(40) `rho'
		di in green "Corr(x,y) =" as result %-4.3f _col(40) `rxy'
		di in green ""
		di in green "Power =" as result %4.3f _col(40) `p'
		di in green "Delta =" as result %4.3f _col(40) `d'
		di in green ""
		di in green "Level-2 obs per group =" as result %12.0fc _col(30) `n2'
		di in green "Level-1 obs =" as result %12.0fc _col(30) `n1'
		di in green "Total obs =" as result %12.0fc _col(30) `N'
		di in green "*****************************************************"
		
		return local alpha = `a'
		return local rho = `rho'
		return local rxy = `rxy'
		return local power = `p'
		return local delta = `d'
		return local obs2 = `n2'
		return local obs1 = `n1'
		return local N = `N'
	end
