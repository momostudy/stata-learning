*!Version 3.0.0 6Aug09 (By Jonah B. Gelbach)
*!Version 2.3.1 4Aug09 (By Jonah B. Gelbach)
*!Version 2.0.0 20Feb07 (By Jonah B. Gelbach)
*Version 1.0.0 22May06 (By Jonah B. Gelbach)


*************
* CHANGELOG *
*************

*
* 3.0.0: 
*
*	 ## Added eigenvalue fix for non-psd cases
*	 ## Fixed ereturn behavior for scalars & macros
*
* 2.3.1: small edit by JBG to
*
*		## ensure that observations with missing cluster values are dropped
*		   (this matters b/c cgmreg runs Stata's -regress- without clustering, 
*		    so previous behavior was to include obs with missing cluster values
*		    and then treat "missing" as a cluster in its own right)
*
* 2.3.0: medium edit by JBG to 
*
*		## add treatment of if & in conditions
*		## add treatment of weights
*	
*        (required edit of syntax of to sub_robust subroutine, as well as adding some code on main regress line)


program define cgmlogit, eclass byable(onecall) sortpreserve

	syntax anything [if] [in] [fweight iweight pweight /], Cluster(string) [NOEIGenfix *]

	*NOTE: use "NOEIGenfix" rather than "noEIGenfix" b/c we define a separate macro eigenfix below

	/* deal with weights */
	if "`weight'"~="" {
		local weight "[`weight'=`exp']"
	} 
	else {
		local weight ""
	}

	*marksample code added in version 2.3.1, replacing homemade mark that happened after regress
	marksample touse
	markout `touse' `cluster', strok

	local numcvars : word count `cluster'

	/* main regression */
	di
        di " -> qui logit `anything' if `touse' `weight' , `options' "
	di "    (`touse' is an internal 'touse' variable; see -marksample-)"
        qui logit `anything' if `touse' `weight' , `options' 

	local ell_0=e(ll_0)
        local ell  =e(ll)
        local edf_m=e(df_m)

	local crittype   = e(crittype)
        local predict    = e(predict)
        local properties = e(properties)
        local estat_cmd  = e(estat_cmd)

	/* generate the score estimates */
	tempvar score
	qui predict double `score' if e(sample)==1, score
	local n = e(N)

	di 
	di "Note: +/- means the corresponding matrix is added/subtracted"
	di

/*commented for version 2.3.1 fix of missing cluster values issue (we make `touse' with marksample, above)
	/* copy some information that regress provides */
	tempvar touse
	gen `touse' = e(sample)
end commented for version 2.3.1 fix of missing cluster values issue
*/

	tempname b
	mat `b' = e(b)

	local depname = e(depvar)
	

	*save hessian
	tempname hessian rows
	mat `hessian' = e(V)
	mat `rows' = rowsof(e(V))
	local rows = `rows'[1,1]
	local cols = `rows'		/* avoid confusion */

	/* matrix that holds the running sum of covariance matrices as we go through clustering subsets */
	tempname running_sum
	mat `running_sum' = J(`rows',`cols',0)

	/* we will use a_cluster for matrix naming below as our trick to enumerate all clustering combinations */
	tempname Bigmat
	mat `Bigmat' = J(1,1,1)

	*taking inductive approach
	forvalues a=2/`numcvars' { /* inductive loop for Bigmat */

		mat `Bigmat' = J(1,`a',0) \ ( J(2^(`a'-1)-1,1,1) , `Bigmat' ) \ (J(2^(`a'-1)-1,1,0) , `Bigmat' ) 
		mat `Bigmat'[1,1] = 1

	} /* end inductive loop for Bigmat */

	mat colnames `Bigmat' = `cluster'

	local numsubs = 2^`numcvars' - 1
	local S = `numsubs' 			/* for convenience below */

	forvalues s=1/`S' { /* loop over rows of `Bigmat' */

		{	/* initializing */
			local included=0
			local grouplist
		} /* done initializing */

		foreach clusvar in `cluster' { /* checking whether each `clusvar' is included in row `s' of `Bigmat' */

			tempname element
			mat `element' = `Bigmat'[`s',"`clusvar'"] 
			local element = `element'[1,1]


			if `element' == 1 { /* add `clusvar' to grouplist if it's included in row `s' of `Bigmat' */

				local included= `included' + 1
				local grouplist "`grouplist' `clusvar'"

			} /* end add `clusvar' to grouplist if it's included in row `s' of `Bigmat' */
		} /* checking whether each `clusvar' is included in row `s' of `Bigmat' */


		*now we use egen to create the var that groups observations by the clusvars in `grouplist'
		tempname groupvar
		qui egen `groupvar' = group(`grouplist') if `touse'

		*now we get the robust estimate
		local plusminus "+"
		if mod(`included',2)==0 { /* even number */
			local plusminus "-"
		} /* end even number */

                sub_robust `if' `in' `weight', groupvar(`groupvar') hessian(`hessian') plusminus(`plusminus') score(`score') running_sum(`running_sum') touse(`touse')
	
		di "Calculating cov part for variables: `grouplist' (`plusminus')"

	} /* end loop over rows of `Bigmat' */


	*checking/fixing non-psd variance estimate
	tempname eigenvalues eigenvectors
	*use mata to get eigenvalues after ensuring that variance matrix is (numerically) symmetric
	mata { 
		B = st_matrix("`running_sum'") 
		A = makesymmetric(B) 
		symeigensystem(A, C=., lamda=.) 
  		st_matrix("`eigenvalues'", lamda) 
		st_matrix("`eigenvectors'", C)
	}

	local rnames  : rownames `running_sum'
	local numcols = colsof(`running_sum')
	local eigenfix "no"
	forvalues col=1/`numcols' { /* column number loop */
		if (`eigenvalues'[1,`col']<0) {

			if "`noeigenfix'"=="noeigenfix" {
			    	di
			    	di " -> NOTE: Raw estimated variance matrix was non positive semi-definite."
			    	di
				di "          Because you used the -noeigenfix- option, -cgmreg- must end."
				di
		    		di "          See Cameron, Gelbach & Miller, "
		    		di "            'Robust Inference with Multi-Way Clustering'."
		    		di	
				di "Program terminated."			
				di
				exit
			}

		    	mat `eigenvalues'[1,`col']=0
		    	local eigenfix "yes"
		}
	} /* end column number loop */

	*now reconstruct variance matrix using spectral decomposition formula (e.g., Def A.16 in Greene, 6th)
	tempname raw_running_sum
	mat `raw_running_sum' = `running_sum'	/* pre eigen-fix variance matrix */
	mat `running_sum' = `eigenvectors'*diag(`eigenvalues')*`eigenvectors''
	mat rownames `running_sum' = `rnames'
	mat colnames `running_sum' = `rnames'
	/* end checking/fixing non-psd variance estimate */

	
	/* final cleanup and post */
	di
	di _column(50) "Number of obs     =    `n'"
	di _column(50) "Num clusvars      =    `numcvars'"
	di _column(50) "Num combinations  =    `S'"
	di
	local c 0
	foreach clusvar in `cluster' { /* getting num clusters by cluster var */

		local c = `c' + 1
                qui unique `clusvar' if `touse'
		di _column(50) "G(`clusvar')" _column(68) "=    " _result(18)

		local Gclusvar`c' = _result(18)
		
	} /* end getting num obs by cluster var */
	di

	ereturn post `b' `running_sum', e(`touse') depname(`depname') 
	ereturn display

	local c 0
	foreach clusvar in `cluster' { /* getting num clusters by cluster var */
		local c = `c' + 1
		ereturn scalar N_clus`c' =  `Gclusvar`c''
	}

	ereturn scalar ll_0 =`ell_0'
	ereturn scalar ll   =`ell'
	ereturn scalar df_m =`edf_m'
	ereturn scalar N    =           `n'
	
	ereturn local eigenfix  = 	  "`eigenfix'"
	ereturn local depvar =            "`depname'"
	ereturn local cmd =               "cgmlogit"
	ereturn local crittype  =         "`crittype'"
	ereturn local predict   =         "`predict'"
	ereturn local properties=	  "`properties'"
	ereturn local estat_cmd =	  "`estat_cmd'"
	ereturn local vcetype =           "cgm_robust"
	ereturn local clustvar =          "`cluster'"
	ereturn local clusvar  =          "`cluster'"


	*matrices
	ereturn matrix rawcovmat = `raw_running_sum'

	if "`eigenfix'"=="yes" {
		    di
		    di " -> NOTE: Raw estimated variance matrix was non-positive semi-definite."
		    di "          -cgmreg- is replacing any/all negative eigenvalues with 0."
		    di
		    di "          See Cameron, Gelbach & Miller, "
		    di "            'Robust Inference with Multi-Way Clustering'."
		    di
		    di "          Raw, non-psd covariance estimate will be available "
		    di "            in e(rawcovmat)."
		    di
		    di "          (If you don't want this behavior, use the 'noeigenfix' option,"
		    di "            in which case -cgmreg- will throw an error)"
		    di
		    di
	}
end



prog define sub_robust

	syntax [if] [in] [fweight iweight pweight /] , groupvar(string) hessian(string) plusminus(string) score(string) running_sum(string) touse(string) 

/*
	local cvar 		"`1'"	/* cluster var, to be fed to us as argument 1 */
	local hessian 		"`2'"	/* hessian estimate, to be fed to us as argument 2 */
	local plusminus 	"`3'"	/* whether to add or subtract to `running_sum', argument 3 */
	local score 		"`4'"	/* name of tempvar with resids in it, arg 4 */
	local running_sum 	"`5'"	/* running_sum estimate, to be fed to us as argument 5 */
	local touse		"`6'"
*/

	/* deal with weights */
	if "`weight'"~="" {
		local weight "[`weight'=`exp']"
	} 
	else {
		local weight ""
	}

	tempname rows
	mat `rows' = rowsof(`hessian')
	local rows = `rows'[1,1]

	cap mat drop `m'
	tempname m
	mat `m' = `hessian'

*mat li `m'

	if "`if'"=="" local if "if 1"
	else          local if "`if' & `touse'"

*        di " -> qui _robust `score' `if' `in' `weight', v(`m') cluster(`groupvar')"
        qui _robust `score' `if' `in' `weight', v(`m') cluster(`groupvar')
	mat `running_sum' = `running_sum' `plusminus' `m'
end



*! version 1.1  mh 15/4/98  arb 20/8/98
*got this from http://fmwww.bc.edu/repec/bocode/u/unique.ado
program define unique
local options "BY(string) GENerate(string) Detail"
local varlist "req ex min(1)"
local if "opt"
local in "opt"
parse "`*'"
tempvar uniq recnum count touse
local sort : sortedby
mark `touse' `if' `in'
qui gen `recnum' = _n
sort `varlist'
summ `touse', meanonly
local N = _result(18)
sort `varlist' `touse'
qui by `varlist': gen byte `uniq' = (`touse' & _n==_N)
qui summ `uniq'
di in gr "Number of unique values of `varlist' is  " in ye _result(18)
di in gr "Number of records is  "in ye "`N'"
if "`detail'" != "" {
	sort `by' `varlist' `touse'
	qui by `by' `varlist' `touse': gen int `count' = _N if _n == 1
	label var `count' "Records per `varlist'"
	if "`by'" == "" {
		summ `count' if `touse', d
	}
	else {
		by `by': summ `count' if `touse', d
	}
}
if "`by'" !="" {
	if "`generate'"=="" {
		cap drop _Unique
		local generat _Unique
	}
	else {
		confirm new var `generate'
	}

        drop `uniq'
	sort `by' `varlist' `touse'
	qui by `by' `varlist': gen byte `uniq' = (`touse' & _n==_N)
	qui by `by': replace `uniq' = sum(`uniq')
	qui by `by': gen `generate' = `uniq'[_N] if _n==1
	di in blu "variable `generate' contains number of unique values of `varlist' by `by'"
	list `by' `generate' if `generate'!=., noobs nodisplay
}
sort `sort' `recnum'
end

