*! version jul2015
* M. Manjon & J. MaÒez
* Created: 20150302
* Estimation of production functions using the ACF method.
* (GMM estimation with standard errors robust to arbitrary heteroskedasticity).
* Related commands: -levpet-, -opreg-

* Usage: 
*	acfest varname [if] [in], free(varlist1) state(varlist2) proxy(varname) /// 
*		[i(varname) t(varname) intmat(varlist) invest nbs(#) robust nodum ///
*		second va overid] 

*	where 

*		varname contains the dependent variable (value added or gross revenue)
*		varlist1 contains free inputs (e.g. labour and materials)
*		varlist2 contains state variable (e.g capital and age)
*		varname contains the proxy variable (investment/materials) 

*		(The "ts" option is added to accommodate time-series operators in  
*		varlist1, varlist2 and varname).

*		Options include intermediate material inputs other than that used 
*		as proxy, use of investment as proxy, number of bootstrap replications, 
*		robust standard errors, no time dummies in the (first-stage) estimation
* 		of the function phi, second order polynomial approximations, value added 
* 		as dependent variable	and alternative instruments in the second stage.


capture program drop acfest 
program acfest, eclass
version 13

	syntax varname(ts) [if] [in], 	///
	free(varlist ts)			  	///
	state(varlist ts) 			  	///
	proxy(varname ts) 			  	/// 
	[i(varname ts) t(varname ts) intmat(varlist ts) invest nbs(integer 100) ///
		robust nodum second va overid]
	

quietly{

// Declare data to be a panel	
						
	cap xtset 
	// Check consistency between xtset and the program options
	if ("`r(panelvar)'" != "" & "`i'" != "") & ///
		("`r(panelvar)'" != "`i'") {
	display as error "Use the same variables for xtset and i() and t() options"
	exit
	} 
	if ("`r(timevar)'" != "" & "`t'" != "") & ///
		("`r(timevar)'" != "`t'") {
	display as error "Use the same variables for xtset and i() and t() options"
	exit
	} 
	
	// If panel declared trough xtset or tsset
	if "`r(panelvar)'" != "" & "`r(timevar)'" != "" {		
	local i : char _dta[iis]
	local t : char _dta[tis]
	}
	
	// If panel declared through options
	else {
	if "`i'" != "" & "`t'" != "" {
	xtset `i' `t'	
					}
	if "`i'" == "" | "`t'" == "" {
	display as error "Declare data to be a panel; use xtset (or tsset) specyfying both panelvar and timevar"
	display as error "Altenatively, use both the i() and t() options"
	exit
		}
		}


	local depvar `varlist' 
	local nstate : word count `state'
	local nfree : word count `free'
	local nintmat: word count `intmat'

	
// SELECT SAMPLE
	marksample touse
	// Here there is a change
	markout `touse' `free' `proxy' `state' `intmat'
	
/* marksample handles the variables in `varlist' automatically,  but not the 
 variables included in the options `free',`proxy' and `state'. In particular, 
 markout sets `touse' to 0 for any observations where the variables listed are 
 missing */ 

		

	/*CREATE THIRD ORDER POLYNOMIAL TERMS */
	
//==============================================================================
//
// Given variables x, y, z, polynomial terms are created in alphabetical order,
// for example, x_x_y, rather than x_y_x.  Elements in each term are separated
// by an underscore, thus proxy and state variables provided by the user cannot
// contain underscores, which is checked in the caller.
//
//==============================================================================

	local polyvars `proxy' `state' `free'
	local tmp `polyvars'
	foreach x of local polyvars {
		foreach y of local tmp {
			if ("`x'" < "`y'") {
				local secondorder `secondorder' `x'_`y'
				local secondop `secondop' `x'*`y'
			}
			else {
				local secondorder `secondorder' `y'_`x'
				local secondop `secondop' `y'*`x'
			}
		}
		gettoken junk tmp : tmp
	}
		
	local polylen : word count `secondorder'
	forvalues i=1/`polylen' {
		local var : word `i' of `secondorder'
		local op : word `i' of `secondop'
		tempvar `var'
		qui gen double ``var'' = `op'	
		local polylist `polylist' ``var''
	}
		
	// get third order terms

	if "`second'" == "" {
	
		foreach x of local polyvars {
			forvalues i=1/`polylen' {
				local lbl : word `i' of `secondorder'
				local y : word `i' of `polylist'
				
				if ("`x'" <= "`lbl'") {
					local tmp `x'_`lbl'
				}
				else local tmp `lbl'_`x'
				
				// check if poly term is already in list
				
				local tmp : subinstr local tmp "_" " ", all
				local srt : list sort tmp
				local tmp : subinstr local srt " " "_", all			
				local in : list tmp in thirdorder
				if (`in'==0) {
					local thirdorder `thirdorder' `tmp'
					local thirdop `thirdop' `x'*`y'
				}
			}
		}
		
		local polylen : word count `thirdorder'
		forvalues i=1/`polylen' {
			local var : word `i' of `thirdorder'
			local op : word `i' of `thirdop'
			tempvar `var'
			qui gen double ``var'' = `op'
			local polylist `polylist' ``var''
		}
	}
	
	local polyterms `secondorder' `thirdorder'
	local polylen : word count `polyterms'
	
	
 	/*END OF THIRD ORDER POLYNOMIAL TERMS */	

*******************************************************************************

// Generate variables that will be used in the second stage 

	forvalues m=1/`nfree' {
		local op: word `m' of `free'
		tempvar l1_`op'
		gen double `l1_`op''=L1.`op'
		local freelags `freelags' `l1_`op''
	}
	
		forvalues m=1/`nstate' {
		local op: word `m' of `state'
		tempvar l1_`op'
		gen double `l1_`op''=L.`op'
		local statelags `statelags' `l1_`op''	
	}

	if "`intmat'" != "" {		
		forvalues m=1/`nintmat' {
		local op: word `m' of `intmat'
		tempvar l1_`op'
		gen double `l1_`op''=L.`op'
		local intmatlags `intmatlags' `l1_`op''	
		}
	}

	tempvar l1_proxy
	gen double `l1_proxy'=L.`proxy'

	if "`overid'" != "" {	
		forvalues m=1/`nfree' {
		local op: word `m' of `free'
		tempvar l2_`op'
		gen double `l2_`op''=L2.`op'
		local freelags2 `freelags2' `l2_`op''
		}
		
		if "`intmat'" != "" {	
		forvalues m=1/`nintmat' {
		local op: word `m' of `intmat'
		tempvar l2_`op'
		gen double `l2_`op''=L2.`op'
		local intmatlags2 `intmatlags2' `l2_`op''
		}
		}
		
		tempvar l2_proxy
		gen double `l2_proxy'=L.`l1_proxy'
	
	}
	
*******************************************************************************	

/// Remove missings 
if "`overid'" != "" {
	markout `touse' `freelags' `l1_proxy' `intmatlags' ///
					 `statelags' `l2_proxy' `freelags2'
	}
else {
	markout `touse' `freelags' `l1_proxy' `intmatlags'
	}

*******************************************************************************	
******** ESTIMATION PROCEDURE ********
******************************************************************************

// First initial values and locals

*******************************************************************************
* Initial values (to be used in the GMM procedure of the second stage)

if "`va'" != "" { 

// OLS estimation to get starting values
	reg `depvar' `state' `free' if `touse'
	
	/// We store the estimated coefficients	
	tempname bols 
	mat bols=e(b)
}


else {

// In the revenue case, the OLS regression should not include the proxy 
// when using investment as proxy. Thus,

	if  "`invest'" != "" { 

	reg `depvar' `state' `intmat' `free'  if `touse'
	tempname bols 
	mat bols=e(b)
	}

	else {

	reg `depvar' `state' `intmat' `proxy' `free'  if `touse'
	tempname bols 
	mat bols=e(b)

	}
}


*******************************************************************************

// Now we can now start with the estimation

*******************************************************************************
		
//	First Stage: Regress loutput on l, m, k and the cross products

if "`va'" != "" {
	if "`dum'" != "" { // careful with this local
	reg `depvar' `state' `proxy' `free'  `polylist' /*i.`t'*/ if `touse'
	}
	else {
	reg `depvar' `state' `proxy' `free'  `polylist' i.`t' if `touse' 
	}
	local NF=e(N)
}

else {
	if "`dum'" != "" { // careful with this local
	reg `depvar' `state' `proxy' `free' `intmat' `polylist' /*i.`t'*/ if `touse'
	}
	else {
	reg `depvar' `state' `proxy' `free' `intmat' `polylist' i.`t' if `touse' 
	}
	local NF=e(N)
	}
	
	
	// None of the coefficients on inputs is identified in this first stage 
	/// but we can still obtain an estimate phi of the composite term 
	/// We thus generate the predicted values (phi) from the previous regression

	tempvar phi phi_lag 
	predict double `phi', xb
	gen double `phi_lag' = L.`phi'

	
*******************************************************************************
/// Define locals to be used in the GMM procedure
		
if "`va'" != "" { 
	local ex `state' `free'
	local exlag `statelags' `freelags' 
	if "`overid'" != "" {
		local inst `state' `freelags' `statelags' `freelags2'
		}
	else {
	local inst `state' `freelags'
	}
}

else {
	if "`invest'" != "" {
		local intmat `intmat' 
		local intmatlags `intmatlags'
		local intmatlags2 `intmatlags2'
		}
	else {
		local intmat `intmat' `proxy'
		local intmatlags `intmatlags' `l1_proxy'
		local intmatlags2 `intmatlags2' `l2_proxy'
		}
	local ex `state' `intmat' `free'
	local exlag `statelags' `intmatlags' `freelags'
	if "`overid'" != "" {
		local inst `state' `intmatlags' `freelags' ///
					`statelags' `intmatlags2' `freelags2'
		}
	else {
		local inst `state' `intmatlags' `freelags' 
	}
}


*******************************************************************************	
	
/// Remove missings 
if "`overid'" != "" {
	markout `touse' `phi' `phi_lag' `freelags' `intmatlags' ///
				`statelags' `intmatlags2' `freelags2'
	}
else {
	markout `touse' `phi' `phi_lag' `freelags' `intmatlags'
	}

*******************************************************************************

// Second step.	

// Call the Mata routine. All the results will be waiting for us in "r()" macros
// For future use, the following locals will store the results (matrices) from Mata
	tempname b V omega
	
*******************************************************************************
	macro dir	
** Case1: Heteroskedastic VCV matrix

if "`robust'" != "" { 
	local proc m_acf_het
	mata: m_acf_homo ("`depvar'", "`ex'", "`exlag'", "`phi'", "`phi_lag'", ///
	"`inst'", "`touse'", "`robust'") 
	mata: `proc' ("`depvar'", "`ex'", "`exlag'", "`phi'", "`phi_lag'", ///
	"`inst'", "`touse'", "`robust'")
	// Move the basic results from r() macros to Stata matrices. 
	mat `b' = r(beta) 
		loc bsize = colsof(`b')-1
		 mat `b'=`b'[1,1..`bsize']
	mat `V' = r(V) 
	mat `omega' = r(omega) 
	// We want to have N, J, L, K from the full estimation    
	local NN = r(N) 
	local jj = r(j)
	local LL = r(L)
	local KK = r(K) 
}	

** Case2: Homoskedastic VCV matrix

// MOST PREVIOUS STUFF APPLIES HERE

else  { 
	local proc m_acf_homo
	mata: `proc' ("`depvar'", "`ex'", "`exlag'", "`phi'", "`phi_lag'", ///
	"`inst'", "`touse'", "`robust'")
	mat `b' = r(beta)
		  loc bsize = colsof(`b')-1
		  mat `b'=`b'[1,1..`bsize']
	local NN = r(N)
	local jj = r(j)
	local LL = r(L)
	local KK = r(K) 
	}

*******************************************************************************

// BOOTSTRAPPING

local nex: word count `ex'
	tempname A V
	matrix `A' = J(`nbs', `nex', 0)  // Change to the number of replications

forvalues m=1/`nex' {
	local op: word `m' of `ex'
	local bs1 `bs1' `op'
	}

// Bootstrapping to get standard errors
	set more off
	local clust `i' // To avoid problems with the next loop
	forv i=1/`nbs'	{ // Number of replications
		noi di "." _continue
		preserve 
		// If cluster is specified in bsample the sample drawn during 
		// each replication is a bootstrap sample of clusters.
		tempvar neword
		bsample if `touse', cluster(`clust') 
		mata: `proc'("`depvar'", "`ex'", "`exlag'", "`phi'", "`phi_lag'", ///
		"`inst'","`touse'", "`robust'")
		tempname bs
		mat `bs' = r(beta)
			local varx `bs1'
			local j=1
			foreach x of local varx {
			tempvar betab_`x'
			generate `betab_`x''=`bs'[1,`j']
			qui sum `betab_`x''
			local el=r(mean)
			mat `A'[`i',`j']=`el'
		local j=`j'+1
		}
		restore
	}
	
	svmat `A'
	forvalues m=1/`nex' {
		local op: word `m' of `ex'
		tempvar boots_`op'
		ren `A'`m' `boots_`op''
		local naccum `naccum' `boots_`op''
		sum `naccum'
		}		

	local m=r(N)

// matrix accum, causes the accumulation to be performed in terms 
// of deviations from the mean.  If noconstant is not specified, 
// the accumulation of X is done in terms
// of deviations, but the added row and column of sums are 
// not in deviation format (in which case they would be zeros).  //
// With noconstant specified, the resulting matrix divided through by N-1,
// where N is the number of observations, is a covariance matrix.

mat accum `V'= `naccum', dev nocons
mat `V'=`V'/(`m'-1)


// Prepare row/col names.
	local vnames `ex'
	matrix rownames `V' = `vnames'
	matrix colnames `V' = `vnames'
	matrix colnames `b' = `vnames'
	
// We need the number of observations before we post our results.
	local N = r(N)

// Wald test 	
	tempname capr diff rvri waldcrs junk
    loc bsize = colsof(`b')
    mat `capr' = J(1, `bsize', 1)
    mat `rvri' = syminv(`capr'*`V'*`capr'')
	mat `diff' = `b'*`capr'' - 1
    mat `junk' = `diff'*`rvri'*`diff'
    scalar `waldcrs' = trace(`junk')


// Posting the results
	
    ereturn post `b' `V', depname(`depvar') obs(`NF') esample(`touse')
			
// Store remaining estimation results as e() macros accessible to the user.
	ereturn local depvar = "`depvar'" 
		
	ereturn scalar N = `NF'
	ereturn scalar L = `LL'
	ereturn scalar K = `KK'	
	
	ereturn scalar waldcrs = `waldcrs' 
	ereturn scalar j = `jj'


// Log of productivity prediction after estimation
ereturn local predict "acfest_p"


} // End of quietly


* Display results

* Headlines
	display _newline "Ackerberg-Caves-Frazer Method to Estimate Production Functions" 

	if "`va'" != "" {
		if "`robust'" != "" {
		ereturn local vcetype "robust" 
		display  "(Non-linear heteroskedastic GMM estimates for value added)" 
		}
		else  {
		display  "(Non-linear homoskedastic GMM estimates for value added)" 
			}
		}
	else  {
		if "`robust'" != "" {
		ereturn local vcetype "robust" 
		display  "(Non-linear heteroskedastic GMM estimates for revenue)" 
		}
		else  {
		display  "(Non-linear homoskedastic GMM estimates for revenue)" 
			}
		}

	display _newline _col(58) "Number of obs = " e(N)			
		
* Estimates
	ereturn display
	
* Tests	
	di as text "Wald test of constant returns to scale: Chi2 = " /*
         */ as result %6.2f e(waldcrs) as text " (p = " /*
         */ as result %6.4f chi2tail(1, e(waldcrs)) as text ")" _newline
		 
		 	
	if e(L)== e(K) {
	display "Sargan-Hansen J-statistic: " %7.3f e(j) " (p = .)"
	display "Exactly identifided model (no overidentifying restrictions)""	
	}
	else if e(L) > e(K) {
	display "Sargan-Hansen J-statistic: " %7.3f e(j) " (p = " ///
        %5.4f chiprob(e(L)-e(K), e(j)) ")" 
	display "H0: overidentifying restrictions are valid"
	}
	

end


