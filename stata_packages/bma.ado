* Bayesian Model Averaging
* Version 1.0 
* Date: 06/05/2011
* Author: De Luca Giuseppe, Jan Magnus

*-------------------------------------------------------------------------------------------------
* bma
*-------------------------------------------------------------------------------------------------
program define bma, eclass 
	syntax [anything] [if] [in],	[*]
	if !replay() {
		local cmdline : copy local 0
	}

	version 11.1, missing
	
	if replay() {
		if "`e(cmd)'" != "bma" {
			error 301
		}
		Di_bma `0' 
		exit
	}
	version 11.1: Estimate `0'
	version 11.1: ereturn local cmdline `"bma `0'"'
end
*-------------------------------------------------------------------------------------------------




*-------------------------------------------------------------------------------------------------
* Estimate
*-------------------------------------------------------------------------------------------------
program define Estimate, eclass
qui {
	version 11.1

* Identify dependent variable 
	gettoken depvar 0 : 0 , parse(" =,[")
	gettoken equals rest : 0 , parse(" =")
	if "`equals'" == "=" local 0 `"`rest'"'
	local depvarn : subinstr local depvar "." "_"
	
* Syntax
	syntax [varlist(default=none)] [if] [in] , 		///
		AUXiliary(varlist numeric min=1) 			///
		[noCONstant notable nodots]

* Options
	local nc `constant'
	if "`auxiliary'"!=	""  		local aux  "`auxiliary'"
	if "`table'"=="notable" 		local dis  "quietly"
	else			 				local dis  "noisily"
	if "`dots'"=="nodots" 			local DOT  0
	else 							local DOT  1
	
* Estimation sample 
	marksample touse
	markout `touse' `depvar' `varlist' `aux' 

* Check estimation sample 
	count if `touse' 
	if r(N)==0 error 2000 
	else local N=r(N)	
	tempname Nl
	matrix `Nl'=(`N')

* Constant term (if any)
	if "`nc'"~="noconstant" {
		tempvar const
		gen byte `const'=1
	}
	
* Check for collinearity
	_rmcollright (`const') (`varlist') (`aux') if `touse', noconstant 
	local dropped `r(dropped)'
	local rb2 `r(block2)'
	local rb3 `r(block3)'
	if "`dropped'"!="" {
		noi di in gr "note: `dropped' omitted because of collinearity" 
		local varlist_rc ""
		local x=1
		foreach xx of local varlist {
			local yy: word `x' of `rb2' 
			if "`yy'"!="o.`xx'" local varlist_rc `varlist_rc' `xx'
			local x=`x'+1
		}
		local auxlist_rc ""
		local x=1
		foreach xx of local aux {
			local yy: word `x' of `rb3' 
			if "`yy'"!="o.`xx'" local auxlist_rc `auxlist_rc' `xx'
			local x=`x'+1
		}
	}
	else {
		local varlist_rc `varlist'
		local auxlist_rc `aux'
	}
		
* Number of focus and auxiliary regressors
	tempname Kl
	local k1: word count `varlist_rc' 
	if "`nc'"~="noconstant" local k1=`k1'+1
	local k2: word count `auxlist_rc' 
	matrix `Kl'=(`k1',`k2')

* Check conditions on number of obs 
	if `N'<`k1'+`k2' {
		noi di as err "Number of obs must be greater than (k1+k2)"
		error 2000
	}
	if `N'<=`k1'+2 {
		noi di as err "Number of obs must be greater than (k1+2)"
		error 2000
	}
	
* Define Zellner's g-prior
	tempname Gl
	local g=1/max(`N',`k2'^2) 
	matrix `Gl'=(`g')

* Estimation
	local models = 2^`k2'
	if `DOT'==1 & `models'>=128 {
		noi di as text _n 	"Model space: " as res "`models'" as text " models"		
		noi mata:   bma_dot("`touse'","`depvar'","`varlist_rc' `const'","`auxlist_rc'","`Nl'","`Kl'","`Gl'") 
	}
	else {
		noi mata: bma_nodot("`touse'","`depvar'","`varlist_rc' `const'","`auxlist_rc'","`Nl'","`Kl'","`Gl'") 
	}
	
* Combine estimation results 
	tempname b_aux V_aux pip rsc
	matrix `b_aux' 	= r(b_aux)
	matrix `V_aux' 	= r(V_aux)
	matrix `pip' 	= r(pip)
	matrix `rsc' 	= r(rsc)
	matrix coln `b_aux' = `auxlist_rc' 
	matrix coln `V_aux' = `auxlist_rc' 
	matrix rown `V_aux' = `auxlist_rc' 
	matrix coln `pip' = `auxlist_rc' 
	if `k1'>0 {
		tempname b_foc V_foc C_foc_aux
		matrix `b_foc' 		= r(b_foc)
		matrix `V_foc' 		= r(V_foc)
		matrix `C_foc_aux' 	= r(C_focaux)
		if "`nc'"~="noconstant" local k1s=`k1'-1
		else 					local k1s=`k1'
	}
	else local k1s=0
	if "`nc'"~="noconstant" {
		tempname b_cc V_cc C_aux_cc   
		matrix `b_cc'=`b_foc'[1,`k1']
		matrix coln `b_cc' = _cons 

		matrix `V_cc'=`V_foc'[`k1',`k1']
		matrix coln `V_cc' = _cons
		matrix rown `V_cc' = _cons

		matrix `C_aux_cc'=`C_foc_aux'[`k1'..`k1',1..`k2']
		matrix coln `C_aux_cc' = `auxlist_rc' 
		matrix rown `C_aux_cc' = _cons 
		
		if `k1s'>0 {
			tempname C_foc_cc
			matrix `C_foc_cc'=`V_foc'[`k1'..`k1',1..`k1s']
			matrix coln `C_foc_cc' = `varlist_rc' 
			matrix rown `C_foc_cc' = _cons 
			matrix `b_foc'=`b_foc'[1,1..`k1s']
			matrix `V_foc'=`V_foc'[1..`k1s',1..`k1s']
			matrix `C_foc_aux'=`C_foc_aux'[1..`k1s',1..`k2']
		}
	}
	if `k1s'>0 {
		matrix coln `b_foc' = `varlist_rc' 
		matrix coln `V_foc' = `varlist_rc' 
		matrix rown `V_foc' = `varlist_rc' 
		matrix coln `C_foc_aux' = `auxlist_rc' 
		matrix rown `C_foc_aux' = `varlist_rc' 
	}
	if "`nc'"~="noconstant" {
		tempname b V
		if `k1s'==0 {
			matrix `b'=(`b_cc',`b_aux')
			matrix `V'=`V_cc' , `C_aux_cc' \ `C_aux_cc'' , `V_aux'
		}
		else {
			matrix `b'=(`b_cc',`b_foc',`b_aux')
			matrix `V'		= `V_cc'       , `C_foc_cc' , `C_aux_cc'  	/*
						*/ 	\ `C_foc_cc''  , `V_foc'    , `C_foc_aux' 	/*
						*/  \ `C_aux_cc'' , `C_foc_aux'' , `V_aux'
		}
	}
	else {
		tempname b V
		if `k1s'==0 {
			matrix `b'=`b_aux'
			matrix `V'=`V_aux'
		}
		else {
			matrix `b'=(`b_foc',`b_aux')
			matrix `V'=`V_foc', `C_foc_aux' \ `C_foc_aux'' , `V_aux'
		}
	}
	if "`nc'"~="noconstant" local df_m=colsof(`b')-1
	else 					local df_m=colsof(`b')
	local df_r=`N'-colsof(`b')

	
* Estimate Return
	ereturn post `b' `V', dep(`depvar') obs(`N') esample(`touse')		
	ereturn matrix pip 	= `pip'
	ereturn local auxiliary "`auxlist_rc'"
	if "`nc'"~="noconstant" ereturn local focus 	"_cons `varlist_rc'"
	else 					ereturn local focus 	"`varlist_rc'"
	ereturn scalar k1 	= `k1'
	ereturn scalar k2 	= `k2'
	ereturn scalar df_m = `df_m'
	ereturn scalar df_r = `df_r'
	ereturn scalar ms 	= `models'
	ereturn local title "BMA estimates"
	ereturn local cmd "bma"

* Estimate Display
	`dis' Di_bma, nc(`nc') 

}
end
*-------------------------------------------------------------------------------------------------





*-------------------------------------------------------------------------------------------------
* bma_dot
*-------------------------------------------------------------------------------------------------
version 11.1
mata:
mata clear
void bma_dot(touse,depvar,varlist,aux,Nl,Kl,Gl)
{
// Declarations
	real colvector 	y, K, b1r, b1, mindex, b2, p, b1i, pip   
	real matrix 	X1, X2, V1r, V1, b1b1, C12, b1b2, V2, b2b2, Ti, X2i, X2i_s, 	/*
				*/	V2i_s, Q, V1i_s, var_b1, var_b2, cov_b1_b2 
	real scalar 	n, k1, k2, k, g, Sc, SS1, lam, S_lam, SS2, SS3, si  

// Loading data from stata into mata
	y  = st_data(., (st_varindex(tokens(depvar))), touse)
	X1 = st_data(., (st_varindex(tokens(varlist))), touse)
	X2 = st_data(., (st_varindex(tokens(aux))), touse)
	n = st_matrix(Nl)
	K = st_matrix(Kl[1,1])
	g = st_matrix(Gl)

// Define number of observations and regressors 
	k1=K[1]
	k2=K[2]
	k=k1+k2

// Number of models in the model space
	models = 2^k2
	
// Estimation

	// Check on focus parameters
		if (k1>0) {
			// Restricted model
				V1r = invsym(X1'*X1)
				M1y = y - (X1*V1r)*(X1'*y)
				SS1 = M1y'*M1y
				b1r = V1r*X1'*y
			
			// Normalization of the model weights	
				X2_s = X2-(X1*V1r)*(X1'*X2)
				V2s   = invsym(X2_s'*X2_s)
				p     = X2_s'*y
				SS2   = p'*V2s*p
				SSmin = SS1 - SS2 /(1+g)

			// Estimates of focus parameters 
				lam=(SS1/SSmin)^(-(n-k1)/2)	
				b1 = lam * b1r
				V1 = lam * SS1 * V1r / (n-k1-2)		
				b1b1 = lam * b1r * b1r'				

			// Update sum of model weights 
				S_lam = lam
		}
		else {
			// Restricted model
				SS1= y'*y

			// Normalization of the model weights	
				X2_s = X2
				V2s   = invsym(X2_s'*X2_s)
				p     = X2_s'*y
				SS2   = p'*V2s*p
				SSmin = SS1 - SS2 /(1+g)

			// Update sum of model weights 
				S_lam = 0
		}
		
	// Title
		printf("\n{txt}Estimation \n")
		printf("{hline 4}{c +}{hline 2} 10%% {hline 2}{c +}{hline 2} 20%% {hline 2}{c +}{hline 2} 30%% {hline 2}{c +}{hline 2} 40%% {hline 2}{c +}{hline 2} 50%%\n")
		displayflush()	

	// Initialize variables before looping over model space
		mindex 	= J(k2,1,0)
		b2 		= J(k2,1,0)
		V2 		= J(k2,k2,0)
		b2b2 	= J(k2,k2,0)
		C12 	= J(k1,k2,0)
		b1b2 	= J(k1,k2,0)
		pip 	= J(k2,1,0)
		print_l1=0
	
	// Loop over models
		for (i=2; i<=models; i++) {

			// Monitoring
				print_mod = round(100*i/models);
				if (print_mod>print_l1) {
					if (print_mod!=50 & print_mod!=100) {
						printf("{txt}.")
						displayflush()
					}
					else{ 
						printf("{txt}. {res} %5.0f%%\n", print_mod)
					}
					print_l1=print_mod;
				}
		
			// Update model
				for (j=1; j<=k2; j++) {
					if (mindex[j,1] == 0) {
						mindex[j,1] = 1
						jm1 = j -1
						for (h=1; h<=jm1; h++) {
							mindex[h,1] = 0
						}
						j=k2
					}
				}
			
			// Create selection matrix
				k2i = colsum(mindex)
				Ti  = J(k2, k2i, 0)
				h=1
				for (j=1; j<=k2; j++) {
					if (mindex[j,1] == 1) {
						Ti[j,h]=1
						h=h+1
					}
				}

			// Select auxiliary variables
				X2i = X2 * Ti
				
			// Estimate current model
				if (k1>0) {
					X2i_s = X2i-(X1*V1r)*(X1'*X2i)
				}
				else {
					X2i_s = X2i
				}
				V2i   = invsym(X2i_s'*X2i_s)
				p     = X2i_s'*y
				SS2   = p'*V2i*p
				SS3   = SS1 - SS2 /(1+g)
				lam   = (k2i/2) * ln(g/(1+g)) - ((n-k1)/2) * (ln(SS3) -ln(SSmin))
				lam   = exp(lam)
				b2i   = V2i * p / (1+g)
				si	= SS3 / (n-k1-2)
				V2i_s = si * V2i / (1+g)

			// Save results
				if (k1 > 0) {
					Q=V1r * X1' * X2i
					b1i = b1r - Q * b2i
					V1i_s = si * V1r + Q * V2i_s * Q'
					V12i_s = - Q * V2i_s 
					b1 = b1 + lam * b1i 
					V1 = V1 + lam * V1i_s
					b1b1 = b1b1 + lam * b1i * b1i'
					C12  = C12 + lam * V12i_s * Ti'
					b1b2 = b1b2 + lam * b1i * b2i' * Ti'
				}				
				b2 = b2 + lam * Ti * b2i 
				V2 = V2 + lam * Ti * V2i_s * Ti'
				b2b2 = b2b2 + lam * Ti * b2i * b2i' * Ti'
				pip  = pip + lam * mindex
				S_lam = S_lam + lam
		}	

	// Normalization
		b2=b2/S_lam
		V2=V2/S_lam
		b2b2=b2b2/S_lam
		var_b2 = V2 + b2b2 - b2 * b2'
		pip = pip / S_lam
		if (k1 > 0) {
			b1=b1/S_lam
			
			V1=V1/S_lam
			b1b1=b1b1/S_lam
			var_b1 = V1 + b1b1 - b1 * b1'
			
			C12=C12/S_lam
			b1b2=b1b2/S_lam
			cov_b1_b2=C12 + b1b2 - b1 * b2'
		}

// Return estimates
	st_matrix("r(b_aux)", b2')	
	st_matrix("r(V_aux)", var_b2)	
	st_matrix("r(pip)", pip')	
	if (k1 > 0) {
		st_matrix("r(b_foc)", b1')	
		st_matrix("r(V_foc)", var_b1)	
		st_matrix("r(C_focaux)", cov_b1_b2)	
	}

}
end
*-------------------------------------------------------------------------------------------------



*-------------------------------------------------------------------------------------------------
* bma_nodot
*-------------------------------------------------------------------------------------------------
version 11.1
mata:
mata clear
void bma_nodot(touse,depvar,varlist,aux,Nl,Kl,Gl)
{
// Declarations
	real colvector 	y, K, b1r, b1, mindex, b2, p, b1i, pip   
	real matrix 	X1, X2, V1r, V1, b1b1, C12, b1b2, V2, b2b2, Ti, X2i, X2i_s, 	/*
				*/	V2i_s, Q, V1i_s, var_b1, var_b2, cov_b1_b2 
	real scalar 	n, k1, k2, k, g, Sc, SS1, lam, S_lam, SS2, SS3, si  

// Loading data from stata into mata
	y  = st_data(., (st_varindex(tokens(depvar))), touse)
	X1 = st_data(., (st_varindex(tokens(varlist))), touse)
	X2 = st_data(., (st_varindex(tokens(aux))), touse)
	n  = st_matrix(Nl)
	K  = st_matrix(Kl[1,1])
	g  = st_matrix(Gl)

// Define number of observations and regressors 
	k1=K[1]
	k2=K[2]
	k=k1+k2

// Number of models in the model space
	models = 2^k2
	
// Estimation
	// Check on focus parameters
		if (k1>0) {
			// Restricted model
				V1r = invsym(X1'*X1)
				M1y = y - (X1*V1r)*(X1'*y)
				SS1 = M1y'*M1y
				b1r = V1r*X1'*y
			
			// Normalization of the model weights	
				X2_s = X2-(X1*V1r)*(X1'*X2)
				V2s   = invsym(X2_s'*X2_s)
				p     = X2_s'*y
				SS2   = p'*V2s*p
				SSmin = SS1 - SS2 /(1+g)

			// Estimates of focus parameters 
				lam=(SS1/SSmin)^(-(n-k1)/2)	
				b1 = lam * b1r
				V1 = lam * SS1 * V1r / (n-k1-2)		
				b1b1 = lam * b1r * b1r'				

			// Update sum of model weights 
				S_lam = lam
		}
		else {
			// Restricted model
				SS1= y'*y

			// Normalization of the model weights	
				X2_s = X2
				V2s   = invsym(X2_s'*X2_s)
				p     = X2_s'*y
				SS2   = p'*V2s*p
				SSmin = SS1 - SS2 /(1+g)

			// Update sum of model weights 
				S_lam = 0
		}
		
	// Initialize variables before looping over model space
		mindex 	= J(k2,1,0)
		b2 		= J(k2,1,0)
		V2 		= J(k2,k2,0)
		b2b2 	= J(k2,k2,0)
		C12 	= J(k1,k2,0)
		b1b2 	= J(k1,k2,0)
		pip 	= J(k2,1,0)
	
	// Loop over models
		for (i=2; i<=models; i++) {

			// Update model
				for (j=1; j<=k2; j++) {
					if (mindex[j,1] == 0) {
						mindex[j,1] = 1
						jm1 = j -1
						for (h=1; h<=jm1; h++) {
							mindex[h,1] = 0
						}
						j=k2
					}
				}
			
			// Create selection matrix
				k2i = colsum(mindex)
				Ti  = J(k2, k2i, 0)
				h=1
				for (j=1; j<=k2; j++) {
					if (mindex[j,1] == 1) {
						Ti[j,h]=1
						h=h+1
					}
				}

			// Select auxiliary variables
				X2i = X2 * Ti
				
			// Estimate current model
				if (k1>0) {
					X2i_s = X2i-(X1*V1r)*(X1'*X2i)
				}
				else {
					X2i_s = X2i
				}
				V2i   = invsym(X2i_s'*X2i_s)
				p     = X2i_s'*y
				SS2   = p'*V2i*p
				SS3   = SS1 - SS2 /(1+g)
				lam   = (k2i/2) * ln(g/(1+g)) - ((n-k1)/2) * (ln(SS3) -ln(SSmin))
				lam   = exp(lam)
				b2i   = V2i * p / (1+g)
				si	  = SS3 / (n-k1-2)
				V2i_s = si * V2i / (1+g)

			// Save results
				if (k1 > 0) {
					Q=V1r * X1' * X2i
					b1i = b1r - Q * b2i
					V1i_s = si * V1r + Q * V2i_s * Q'
					V12i_s = - Q * V2i_s 
					b1 = b1 + lam * b1i 
					V1 = V1 + lam * V1i_s
					b1b1 = b1b1 + lam * b1i * b1i'
					C12  = C12 + lam * V12i_s * Ti'
					b1b2 = b1b2 + lam * b1i * b2i' * Ti'
				}				
				b2 = b2 + lam * Ti * b2i 
				V2 = V2 + lam * Ti * V2i_s * Ti'
				b2b2 = b2b2 + lam * Ti * b2i * b2i' * Ti'
				pip  = pip + lam * mindex
				S_lam = S_lam + lam
		}	

	// Normalization
		b2=b2/S_lam
		V2=V2/S_lam
		b2b2=b2b2/S_lam
		var_b2 = V2 + b2b2 - b2 * b2'
		pip = pip / S_lam
		if (k1 > 0) {
			b1=b1/S_lam
			
			V1=V1/S_lam
			b1b1=b1b1/S_lam
			var_b1 = V1 + b1b1 - b1 * b1'
			
			C12=C12/S_lam
			b1b2=b1b2/S_lam
			cov_b1_b2=C12 + b1b2 - b1 * b2'
		}

// Return estimates
	st_matrix("r(b_aux)", b2')	
	st_matrix("r(V_aux)", var_b2)	
	st_matrix("r(pip)", pip')	
	if (k1 > 0) {
		st_matrix("r(b_foc)", b1')	
		st_matrix("r(V_foc)", var_b1)	
		st_matrix("r(C_focaux)", cov_b1_b2)	
	}

}
end
*-------------------------------------------------------------------------------------------------







*-------------------------------------------------------------------------------------------------
* Di_bma
*-------------------------------------------------------------------------------------------------
program Di_bma
	syntax [, nc(string)]
	local y=abbrev(`"`e(depvar)'"',12)
	local focus "`e(focus)'"
	local aux "`e(auxiliary)'"
	tempname pip
	matrix `pip'=e(pip)

	di as text _n `"`e(title)'"'							///
		_col(53) "Number of obs =" as res %8.0f e(N)		///
		_n as text _col(53) "k1 " _col(67) "=" 				///
		as res %8.0f e(k1) 									///
		_n as text _col(53) "k2 " _col(67) "=" 				///
		as res %8.0f e(k2) 								
		
	di as text "{hline 13}{c TT}{hline 61}"									///
		_n "{ralign 12:`y'} {c |}"											///
		"      Coef.   Std. Err.      t     pip    [1-Std. Err. Bands]"		/// 
		_n "{hline 13}{c +}{hline 61}"	
		
	if "`nc'"~="noconstant" {
		di as text "{ralign 12:_cons} {c |}  "				///
				as res %9.0g  _b[_cons] "  "				///
				as res %9.0g  _se[_cons]	"    "			///
				as res %5.2f  _b[_cons]/_se[_cons]	"  "	///
				as res %5.2f  1					"    "		///			
				as res %9.0g _b[_cons]-_se[_cons] " "		///
				as res %9.0g _b[_cons]+_se[_cons] "   "	
	}
	foreach jj of local focus {
		if "`jj'"=="_cons" continue
		local name =abbrev(`"`jj'"',15)
		di as text "{ralign 12:`name'} {c |}  "			///
			as res %9.0g _b[`jj'] "  "					///
			as res %9.0g _se[`jj']	"    "				///
			as res %5.2f _b[`jj']/_se[`jj']	"  "		///
			as res %5.2f 1	 			"    "			///			
			as res %9.0g _b[`jj']-_se[`jj'] " "			///
			as res %9.0g _b[`jj']+_se[`jj'] "   "	
	}
	di as text "{hline 13}{c +}{hline 61}"	
	local s=1
	foreach jj of local aux {
		local name =abbrev(`"`jj'"',12)
		tempname pip_j
		scalar `pip_j'=`pip'[1,`s']
		di as text "{ralign 12:`name'} {c |}  "			///
			as res %9.0g _b[`jj'] "  "					///
			as res %9.0g _se[`jj']	"    "				///
			as res %5.2f _b[`jj']/_se[`jj']	"  "		///	
			as res %5.2f `pip_j'	 	"    "			///								
			as res %9.0g _b[`jj']-_se[`jj'] " "			///
			as res %9.0g _b[`jj']+_se[`jj'] "   "	
		local s=`s'+1
	}
	noi di as text "{hline 13}{c BT}{hline 61}"	
	
end
*-------------------------------------------------------------------------------------------------
