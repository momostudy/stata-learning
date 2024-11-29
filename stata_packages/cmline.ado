  ** mvport package v2
  * cmline command 
  * Author: Alberto Dorantes, July, 2016
  * cdorante@itesm.mx
capture program drop cmline
program cmline, rclass
  version 11.0
  syntax varlist(min=2 numeric ts) [if] [in] [,RFrate(real 0)] [NPort(real 100)] [NOShort] [MINweight(real -1)] [MAXweight(real -1)] [CASEwise] [RMINweights(numlist)] [RMAXweights(numlist)] [COVMatrix(string)] [MRets(string)] [NOGraph] 
   if (`nport'<3) {
     display as error "Number of portfolios must be greater than two"
     exit 
  }
   marksample touse
   if "`casewise'"=="" {
	  marksample touse, novarlist
	}		  
 
  tempname cov Rgmv maxR N Nrows Nret j delta exprets rmin mrax vecweights vecmaxweights sumw i covmat k Ri params retgmvp sdgmvp wgmvp
  	local nvar : word count `varlist'
	 if "`mrets'"!="" { 
	  capture matrix `exprets' = `mrets'
	  if (_rc!=0) {
	    display as error "The matrix for Expected Returns does not exist; define a Stata Matrix (Vertical Vector of N rows and 1 column)"
	    exit
	  }
	  else if (rowsof(`exprets')!=`nvar') {
	    display as error "The length of the vertical mean vector specified in the mrets option is not equal to the number of variables "
		exit
	  }
	  else { 
        mata: MR=st_matrix("`mrets'")
		mata: st_numscalar("rmin",min(MR))
        mata: st_numscalar("rmax",max(MR))
		matrix `exprets'=`mrets'
		local maxR=rmax	  
	  }
	}
	else {
	  quietly meanrets `varlist' `if' `in', `casewise'	
	  matrix `exprets'=r(meanrets)
	  local rmax=r(maxret)
	  local rmin=r(minret)
	  local maxR=`rmax'
	}  
	if "`covmatrix'"!="" { 
	  capture matrix `covmat' = `covmatrix'
	  if (_rc!=0) {
	    display as error "The Variance-Covariance Matrix does not exist; define a Stata Matrix with that name or change to the right matrix name"
	    exit
	  }
	  else if (rowsof(`covmat')!=`nvar' | colsof(`covmat')!=`nvar') {
	    display as error "The number of columns or rows of the variance-covariance matrix specified in the covm option is not equal to the number of variables "
		exit
	  }
	}
	else {
	  matrix `covmat' = J(1,1,0)
	}

	
	local i=0
	local sumw=0

	matrix `vecmaxweights'=J(`nvar',1,100)
	matrix `vecweights'=J(`nvar',1,-100)
    if "`rmaxweights'"!="" {
     foreach peso in `rmaxweights' {
     if `i'<`nvar' {
	   local i=`i'+1
	   matrix `vecmaxweights'[`i',1] = `peso'
	   local sumw=`sumw'+`peso'
	 }
   }
   
   if `sumw'<=1 {
	  display as error "The sum of each weight specified for the returns is too small; it is not possible to assign 100% in the weights."
      exit
	    }
   }
	else {
	if `maxweight'!=-1 {
    	if `maxweight'*`nvar'<=1 {
	      display as error "The maximum weight specified for all returns is too small; it is not possible to assign 100% in the weights."
	      exit
	    }
	  matrix `vecmaxweights'=J(`nvar',1,`maxweight')

	}
	}
 
  	if ("`rmaxweights'"!="" | `maxweight'!=-1) { 
	  mata: maxr=m_getmaxr(st_matrix("`exprets'"),st_matrix("`vecmaxweights'"))
      mata: st_numscalar("srmax",maxr)	
	  local rmax=srmax
	  local maxR=`rmax'
	}

 local i=0
 local sumw=0
   if "`rminweights'"!="" {
	   local noshort "noshort"
	   matrix `vecweights'=J(`nvar',1,0)
       foreach peso in `rminweights' {
	    if `i'<`nvar' {
    	 local i=`i'+1
	     matrix `vecweights'[`i',1] = `peso'  
		 local sumw=`sumw'+`peso'
		} 
	   }
	   if `sumw'>=1 {
	      display as error "The minimum weights specified for each returns exceed 1 (100%); you have to change them so that the sum of all minimum weights is less than 1"
	    exit
	    }
    }
*	
	else {
	if `minweight'!=-1 {
    	if `minweight'*`nvar'>=1 {
	      display as error "The minimum weight specified for all returns is not valid; they exceed 1 (100%) considering all returns"
	    exit
	    }
	  matrix `vecweights'=J(`nvar',1,`minweight')

	  local noshort "noshort"
	}
	else if "`noshort'"!="" {
	  local noshort "noshort"
	  local minweight 0
	  matrix `vecweights'=J(`nvar',1,0)
	}

	}

   if "`noshort'"=="noshort" { 
     local params  `"noshort `casewise' minweight(`minweight') maxweight(`maxweight') rminweights(`rminweights') rmaxweights(`rmaxweights') covmatrix(`covmatrix') mrets(`mrets')"'
   }
   else {
     local params `"`casewise' maxweight(`maxweight') rmaxweights(`rmaxweights') covmatrix(`covmatrix') mrets(`mrets')"'
    }
   qui gmvport `varlist' `if' `in', `params' 
   if (`rfrate'>=r(retport)) {
  	   display "The risk-free is greater than the GMV Portfolio, which is equal to " r(retport) 
	   display "An approximate Tangent Portfolio was estimated." 
     }
  
   scalar `Nret'=r(N)
   matrix  `cov'=r(cov)
   scalar `retgmvp'=r(retport)
   scalar `sdgmvp'=r(sdport)
   matrix `wgmvp'=r(weights)
  local Rgmv=`r(retport)'
  if missing(`Rgmv') {
     display as error "Global minimum variance portfolio can not be calculated; it might be high correlation or a return variable has a variance of zero"
     exit
  }  
  
  if `rfrate'>=`maxR' {
  	  display as error "The risk-free rate must be smaller than the maximum possible return of the portfolio (=`maxR'). "
	  local rfrate=`maxR' - 0.001
	  *exit 
  }
  
if ("`rmaxweights'"=="" & `maxweight'==-1 & "`noshort'"=="") { 
  local maxR=2*`maxR'
  qui ovport `varlist' `if' `in', rfrate(`rfrate') nport(`nport') `params'
  if r(rop)>`maxR' { 
	 local maxR=r(rop)
  }
 } 

  local N=rowsof(`exprets')

  tempname wef vref vsdef vsharpe vsharpe_order rop sdop sharpe wop vrcml vsdcml walphacml nnoshort pmv mcr cr pcr betas Nobs
  local Nrows=1+round(`nport')
  matrix  `wef'=J(`Nrows',`N',.)
  matrix  `vref'=J(`Nrows',1,.)
  matrix  `vsdef'=J(`Nrows',1,.)
  matrix  `vsharpe'=J(`Nrows',1,.)
  matrix  `vsharpe_order'=J(`Nrows',1,.)
  matrix  `vsdef'[1,1]=0
  matrix  `vsharpe'[1,1]=-1000
  local j=1
  local delta=(`maxR'-`Rgmv')/(`nport'-1)
  if `delta'==0 {
     display as error "The return of the global minimum variance is equal to the portfolio with maximum return possible, so a frontier cannot be constructed"
	 exit
  }  
  forvalues Ri = `Rgmv'(`delta')`maxR' {
    if `Ri'<=`maxR' {
    local j=`j'+1
	 local nnoshort=("`noshort'"!="")
     mata: `pmv'= m_mvport2("`varlist'",`Ri',st_matrix("`vecweights'"),"`touse'", "`casewise'", st_matrix("`covmat'"), st_matrix("`exprets'"),st_matrix("`vecmaxweights'"), `nnoshort')
     matrix  `pmv'=r(weights)
	
    forvalues i= 1/`N' {
 	   matrix `wef'[`j',`i']=`pmv'[`i',1]
	}
    matrix `vref'[`j',1]=r(retp)
    matrix `vsdef'[`j',1]=r(sdp)
	matrix `vsharpe'[`j',1]=(r(retp)-`rfrate')/r(sdp)
	if missing(`vsharpe'[`j',1]) { 
	   matrix `vsharpe'[`j',1]=-1
	}   
  }
  }

while missing(`vsdef'[`Nrows',1]) {
   local Nrows=`Nrows'-1
}  
   matrix `vref'=`vref'[1..`Nrows',1]
   matrix `vsdef'=`vsdef'[1..`Nrows',1]
   matrix `vsharpe'=`vsharpe'[1..`Nrows',1] 
   matrix `wef'=`wef'[1..`Nrows',1..`N']
   matrix `vsharpe_order'=`vsharpe_order'[1..`Nrows',1]


mata : st_matrix("`vsharpe_order'", order(st_matrix("`vsharpe'"), 1))
local nmaxSharpe=`vsharpe_order'[`Nrows',1]
scalar `sharpe'=`vsharpe'[`nmaxSharpe',1]
matrix `wop'=`wef'[`nmaxSharpe',1..`N']'
scalar `rop'=`vref'[`nmaxSharpe',1]
scalar `sdop'=`vsdef'[`nmaxSharpe',1]
matrix `mcr' = `cov' * `wop' / `sdop'
matrix `cr'=`mcr'
forvalues i=1/`nvar' {
  matrix `cr'[`i',1]=`wop'[`i',1]*`mcr'[`i',1]
}

matrix `pcr' = `cr' / `sdop'
matrix `betas' = `mcr' / `sdop'
 
  local i=`vsdef'[`Nrows',1]
  local delta=(`i')/(`nport'-1)
  local k=round(`i'/`delta') + 1
  matrix `vrcml'=J(`k',1,.)
  matrix `walphacml'=J(`k',1,.)
  matrix `vsdcml'=J(`k',1,.)
  local j=0
  forvalues Ri= 0(`delta')`i' {
 	local j=`j'+1

	matrix `vrcml'[`j',1]= `rfrate' + `sharpe' * `Ri'
	matrix `walphacml'[`j',1]= (`vrcml'[`j',1] - `rop') / (`rfrate' - `rop')
	matrix `vsdcml'[`j',1]= `Ri'
  }                       

 
scalar `Nobs'=_N
tempvar RET_P risk CML

if "`nograph'"=="" {
  qui svmat `vref', names(`RET_P')
  if "`noshort'"=="" {
    label var `RET_P'1 "Port. Returns in EFrontier (Allowing short sales)"
  }
  else {
    label var `RET_P'1 "Port. Returns in EFrontier (Without short sales)"
  }

  qui svmat `vsdef', names(`risk')
  label var `risk'1 "Portfolio Risk"
  
  gen `CML'=`rfrate' + (`rop'-`rfrate')/`sdop' * `risk'1
  label var `CML' "Capital Market Line"
  twoway (scatter `RET_P'1 `risk'1) (line `CML' `risk'1), title("Efficient Frontier & Capital Market Line, Risk-free rate=`rfrate'")
  qui drop if (_n>`Nobs')
}
matrix `vref'=`vref'[2..`Nrows',1]
matrix `vsdef'=`vsdef'[2..`Nrows',1]
matrix `vsharpe'=`vsharpe'[2..`Nrows',1] 
matrix `wef'=`wef'[2..`Nrows',1..`N']

foreach v of varlist `varlist' {
	   local nomvar "`nomvar' `v'"
} 

matrix rownames `wop' = `nomvar'
matrix rownames `mcr' = `nomvar'
matrix rownames `cr' = `nomvar'
matrix rownames `pcr' = `nomvar'
matrix rownames `betas' = `nomvar'
matrix colnames `wop' = "Weights"
matrix rownames `cov' = `nomvar'
matrix colnames `cov' = `nomvar'
matrix colnames `wef' = `nomvar'
matrix colnames `vref' = "Ret"
matrix colnames `vsdef' = "Risk"
matrix colnames `vsharpe' = "Sharpe R"
matrix colnames `walphacml' = "Risk-free weight"
matrix colnames `vrcml' = "Ret CML"
matrix colnames `vsdcml'= "Risk CML"
matrix colnames `mcr' = "Marginal contribution to Risk"
matrix colnames `cr' = "Contribution to Risk"
matrix colnames `pcr' = "Percent contribution to Risk"
matrix colnames `betas' = "Asset Betas"

	display "Number of observations used to calculate expected returns and var-cov matrix : " `Nret'
	if "`noshort'"=="" {
	display "The weight vector of the Tangent Portfolio with a risk-free rate of `rfrate'  (Allowing Short Sales) is:"
	}
	else { 
	display "The weight vector of the Tangent Portfolio with a risk-free rate of `rfrate' (NOT Allow Short Sales) is:" 
	}
	matrix list `wop', noheader 
    display "The return of the Tangent Portfolio is: " `rop'
	display "The standard deviation (risk) of the Tangent Portfolio is: " `sdop'
	display _skip(1)
    display "The marginal contributions to risk of the assets in the Tangent Portfolio are:"
	matlist `mcr'
	display "Type return list to see the portfolios in the Capital Market Line and the efficient frontier"

return matrix wef=`wef'
return matrix vref=`vref'
return matrix vsdef=`vsdef'
return matrix vsharpe=`vsharpe'
return matrix wop=`wop'
return scalar rop=`rop'
return scalar sdop=`sdop'
return scalar sharper=`sharpe'
return scalar rfrate=`rfrate'
return matrix vrcml=`vrcml'
return matrix vsdcml=`vsdcml'
return matrix walphacml= `walphacml'
return matrix cov=`cov'
return matrix exprets=`exprets'
return matrix mcr=`mcr'
return matrix cr=`cr'
return matrix pcr=`pcr'
return matrix betas=`betas'

return scalar retgmvp=`retgmvp'
return scalar sdgmvp=`sdgmvp'
return scalar N=`Nret'
return matrix wgmvp=`wgmvp'

end
