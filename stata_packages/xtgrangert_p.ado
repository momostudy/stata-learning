*! predict program for xtgrangert
*! 04.07.2022 by Jan Ditzen

cap program drop xtgrangert_p
program define xtgrangert_p
	syntax anything [in] [if] [,  xb RESiduals]

	tempvar touse
	marksample touse		

	/// check options
	local cnt =  wordcount("`residuals' `xb'")
	if `cnt' > 1 {
		display "{err}only one statistic may be specified"
		exit 498
	}
	else if `cnt' == 0 {
		local xb xb
		disp "Option xb assumed."
	}
	qui {
		/// time series options and variables
		_xt
		local idvar `r(ivar)'
		local tvar `r(tvar)'

		local depvar `e(depvar)'
		local indepvars `e(indepvar)'

		/// remove from touse variables before lag
		by `idvar' (`tvar'), sort: replace `touse' = 0 if _n <= `e(p)'

		mata m_xtgrangert_p("`depvar'","L(1/`e(p)').`depvar'","`indepvars'","`anything'","`idvar' `tvar'","`touse'",("`xb'":=="xb"))
	}

end


capture mata mata drop m_xtgrangert_p()
mata:
	function m_xtgrangert_p(string scalar depvarn , string scalar zn, string scalar indepvarn, string scalar residn, string scalar idtn,string scalar tousen, real scalar xb)
	{
		
		real matrix x, y, z, xi, yi, zi, idt, index, res, resi, mz
		real scalar idx, i
		depvarn
		indepvarn
		zn
		residn
		idtn
		xb
		/// load data
		y = st_data(.,depvarn,tousen)
		x = st_data(.,indepvarn,tousen)
		z = st_data(.,zn,tousen)
		z = J(rows(z),1,1),z

		idt = st_data(.,idtn,tousen)
		index = panelsetup(idt,1)

		/// load beta coefficients
		beta = st_matrix("e(b_HPJ)")

		/// add variable for residuals
		idx=st_addvar("double", residn)		
		st_view(res,.,residn,tousen)
		 
		/// loop over cross-sections
		i = rows(index)
		while (i>0) {
			yi = panelsubmatrix(y,i,index)
			xi = panelsubmatrix(x,i,index)
			zi = panelsubmatrix(z,i,index) 

			panelsubview(resi,res,i,index)


			mz = I(rows(yi)) - zi * invsym(quadcross(zi,zi)) * zi'
			
			if (xb:==1) {
				resi[.,.] = mz*(xi * beta') 
			}
			else {
				resi[.,.] = mz*(yi - xi * beta') 
			}
			i--
		}

	}
end
