*! cvlasso 1.0.09 28jun2019
*! lassopack package 1.3
*! authors aa/ms

* Updates (release date):
* 1.0.03  (30jan2018)
*         First public release.
*         Promoted to require version 13 or higher.
*         Rewrite to estimate via lasso2.
* 1.0.04  (10feb2018)
*         Save noftools macro left by lassoutils
* 1.0.05  (23feb2018)
*         Bug fix - lcount/lmin/lmax option weren't being passed to lasso2.
*         Tweak to prevent warning msg about lcount/lmax/lminratio at end if lse or lopt options used.
* 1.0.06  (22apr2018)
* 		  Minor change in output (to make cvlasso consistent with lasso2).
* 		  Display link in output to allow run lse/lopt model interactively.
* 		  Fix minor display error that occured when multiple alphas where used.
* 1.0.07  (08nov2018)
*         Added version option
*         Replaced "postest" option with name "postresults"; legacy support for postest.
* 1.0.08  (6jan2018)
*         Replace Ups terminology with Psi (penalty loadings)
* 1.0.09  (28jun2019)
*         Minor tweaks to display table message.
*         Fix to accommodate if inrange(.) syntax.

program cvlasso, eclass sortpreserve
	version 13
	syntax [anything] [if] [in] [,					///
			PLOTCV									/// triggers plotting
			PLOTOPT(string)							/// options to pass to graph command
			LSE LOPT 								///
			POSTRESults								///
			POSTEst 								/// legacy option, now replaced by postresults
			///
			/// list all cvlasso options that do not apply to lasso2
			NFolds(integer -1)						/// number of folds
			FOLDVar(varlist numeric max=1)			/// alternatively: user-specified fold variable
			SAVEFoldvar(string)						/// if string is supplied fold var is saved 
			ROLLing 								/// rolling CV
			seed(int 0)								///
			ALPHACount(int -1) 						///	
			H(integer 1)							///
			ORigin(integer -1) 						///
			FIXEDWindow 							///
			VERsion									///
			* 										///
			]

	local lversion 1.0.07
	local pversion 1.1.01

	if "`version'" != "" {							//  Report program version number, then exit.
		di in gr "cvlasso version `lversion'"
		di in gr "lassopack package version `pversion'"
		ereturn clear
		ereturn local version		`lversion'
		ereturn local pkgversion	`pversion'
		exit
	}

	*** legacy option postest replaced by postresults
	if "`postest'" != "" {
		local postresults postresults
	}
	*
			
	if ~replay() { // no replay	
		// bug fix:
		// tokenize "`0'", parse(",")
		// _cvlasso `1', `options' 					///
		_cvlasso `anything' `if' `in', `options'	///
						nfolds(`nfolds') 			///
						foldvar(`foldvar') 			///
						savefoldvar(`savefoldvar') 	///
						`rolling' 					///
						seed(`seed') 				///
 						alphacount(`alphacount') 	///
						h(`h') 	origin(`origin') 	///
						`fixedwindow'
		ereturn local lasso2opt `options'  
	}
	
	if ("`e(cmd)'"!="cvlasso") {
		di as error "No variables specified." 
		error 198
	}
	if ("`plotcv'`plotopt'"!="") & (`e(nalpha)'==1) {
		cvplot, plotopt(`plotopt')
	}
	else if ("`plotcv'`plotopt'"!="") & (`e(nalpha)'>1) {
		di as err "plotting only supported for scalar alpha"
		exit 198
	}
	
	if ("`lse'`lopt'"!="") { // run lasso2 with lse/lopt
		
		*** get lambda & alpha for lasso2 call
		if ("`lse'"!="") & ("`lopt'"!="") {
			di as error "lse and lopt not allowed at the same time."
			exit 198
		} 
		else if ("`lse'"!="") & (`e(nalpha)'==1) {
			local lambdause = e(lse)
			local alphause = e(alpha)
		}
		else if ("`lopt'"!="") & (`e(nalpha)'==1) {
			local lambdause = e(lopt)
			local alphause = e(alpha)
		}
		else if ("`lse'"!="") & (`e(nalpha)'>1) {
			local lambdause = e(lse)
			local alphause = e(alphamin)
		}
		else if ("`lopt'"!="") & (`e(nalpha)'>1) {
			local lambdause = e(lopt)
			local alphause = e(alphamin)
		}
		if (`lambdause'==.) {
			// this will happen if lopt is not unique.
			di as err "`lopt'`lse' is not defined."
			error 1
		}
		if (`e(nalpha)'==1) {
			di as text "Estimate `e(method)' with lambda=" round(`lambdause',0.001) " (`lse'`lopt')."
		}
		else {
			di as text "Estimate `e(method)' with lambda=" round(`lambdause',0.001) " (`lse'`lopt') and alpha=" round(`alphause',0.01) "."
		}
		
		*** call lasso2
		local depvar `e(depvar)'
		local varXmodel `e(varXmodel)'
		local lasso2opt `e(lasso2opt)'
		// trick to remove lcount/lmin/lratio options
		// this strips out the options in the lasso2opt
		// macro and leaves remainder in macro `options'
		local 0 ", `lasso2opt'"
		syntax [, lcount(integer 100) lminratio(real 1e-4) lmax(real 0) * ]
		// and reset the lasso2opt macro
		local lasso2opt `options'
		tempvar esample
		gen `esample' = e(sample)
		tempname model0
		if ("`postresults'"=="") {
			_estimates hold `model0'
		}
		lasso2 `depvar' `varXmodel' if `esample', ///
									newalpha(`alphause')   ///
									newlambda(`lambdause')  ///
									`lasso2opt'
		if ("`postresults'"=="") {
			_estimates unhold `model0'
		}
	}
end


program _cvlasso, eclass sortpreserve

	syntax varlist(numeric min=2 fv ts) [if] [in] [, ///
		Lambda(numlist >0 min=2 descending)			 /// overwrite default lambda
		NFolds(integer -1)							 /// number of folds
		FOLDVar(varlist numeric max=1)				 /// alternatively: user-specified fold variable
		SAVEFoldvar(string)							 /// if string is supplied fold var is saved 
		ROLLing 									 /// rolling CV
		Verbose VVerbose 							 ///
		debug 										 /// 
		LCount(integer 100)							 /// number of lambdas
		LMINRatio(real 1e-4)						 /// ratio of maximum to minimum lambda
		lmax(real 0)							 	 ///
		LADJustment									 /// lambda is divided by 2*n (to make results comparable with glmnet)
		seed(int 0)									 ///
		ALPHACount(int -1) 							 ///	
		H(integer 1)								 ///
		ORigin(integer -1) 							 ///
		FIXEDWindow 								 ///
		ALPha(numlist ascending)					 /// elastic net parameter
		saveest(string)								 ///
		*											 ///
		]
		
	*** Record which observations have non-missing values
	marksample touse
	markout `touse' `varlist' `ivar' `foldvar'
	sum `touse' if `touse', meanonly		//  will sum weight var when weights are used
	local N		= r(N)
	
	*** Create separate _o varlists: Y, X, notpen, partial
	// Y, X
	local varY_o		: word 1 of `varlist'
	local varX_o		: list varlist - varY_o				//  incl notpen/partial

	*** CV: generate fold id variable and set local nfolds:=#folds. 
	local cvopt = ("`rolling'"!="")+(`nfolds'>0)+("`foldvar'"!="")
	if (`cvopt'>1) {
		di as error "Only one of the following options allowed: rolling | nfolds | foldvar."
		error 198
	}

	if ("`foldvar'"!="") {
		* user-specified folds
		di as text "Use user-specified fold variable."
		tempname integercheck
		gen `integercheck'=mod(`foldvar',2)
		assert `integercheck'==0 | `integercheck'==1 // integer check
		qui sum `foldvar', meanonly
		local nfolds=r(max)
		// check that there are no gaps in the fold list (e.g. "1 1 2 2 4 4")
			tab `foldvar', nofreq
		local cvvarunique=r(r)
		if (`cvvarunique'!=`nfolds') {
			di as err "cvvariable is incorrectly specified"
			error 198
		}
	}
	else if ("`foldvar'"=="") & ("`rolling'"=="") {
		if (`nfolds'<=0) {
			//di as text "Use default nfolds=10."
			local nfolds =10
		}
		else if (`nfolds'==1) {
		di as err "nfolds=1 is not allowed. Use default nfolds=10."
				local nfolds =10
		}
		* random assignment of folds
		tempvar uni cuni
		if (`seed'>0) {
			set seed `seed'
		}
		qui { 
			tempvar foldvar
			gen `uni'=runiform()  if `touse'
			cumul `uni' if `touse', gen(`cuni')
			replace `cuni'  = `cuni'*`nfolds'
			gen `foldvar' = ceil(`cuni') if `touse'  
		}
		if ("`savefoldvar'"!="") & ("`rolling'"!="") {
			di as err "Saving of fold IDs not supported after rolling CV."
		}
		if ("`savefoldvar'"!="") & ("`rolling'"=="") { // save fold id
			qui gen long `savefoldvar' = `foldvar'
			di "Fold variable saved in `savefoldvar'."
		}	
	}
	*
	
	*** get lambda **************************************************************
	if ("`lambda'"=="") {
		qui lasso2 `varlist' if `touse', `options'							///
					lcount(`lcount') lminratio(`lminratio') lmax(`lmax')
		tempname lambdamat0
		mat `lambdamat0'=e(lambdamat)'
	}
	else {
		local lcount	: word count `lambda'
		tempname lambdamat0
		mat `lambdamat0'	= J(1,`lcount',.)
		local j = 1
		foreach lami of local lambda {
			mat `lambdamat0'[1,`j'] = `lami'  
			local j=`j'+1
		}
	}
	*
	
	************* loop over alpha ***********************************************
	
	*** alpha list
	if ("`alpha'"=="") & (`alphacount'<=1) {
		local alpha = 1
	}
	else if ("`alpha'"=="") & (`alphacount'>1) {
		// create num list
		local alphastep=1/(`alphacount'-1)
		numlist "0(`alphastep')1"
		local alpha=r(numlist)
	}
	else if ("`alpha'"!="") & (`alphacount'>1) {
		di as err "alphacount() option ignored. Use alpha value(s) specified in alpha()."
	}
	local acount	: word count `alpha' // if acount>1, CV'ing over alpha
	
	*** to store results if #alpha>1
	if (`acount'>1) {
		tempname mminmat // used to store minimum MSPE value for each alpha
		tempname mminlam // used to store optimal lambda for each alpha
		mat `mminmat' = J(1,`acount',.)
		mat `mminlam' = J(1,`acount',.)
	}
	*

	*** loop over alpha
	local aid = 1
	foreach alphai of numlist `alpha' {
		if (`alphai'<0) | (`alphai'>1) {
			di as err "Each alpha value must be in the range 0<=alpha<=1."
			exit 198
		}
		
		* generate fold id variable
		tempvar training
		tempvar validation
		qui gen `training'=0
		qui gen `validation'=0	
		
		** k-fold CV
		tempname Mspe
		if ("`rolling'"=="") {
		
			qui sum `foldvar', meanonly
			local nfolds=r(max)
			* loop over folds
			di "`sqrt'"
			if "`sqrt'"!="" {
				di as text "K-fold cross-validation with `nfolds' folds. Square-root LASSO estimator."
			}
			else {
				di as text "K-fold cross-validation with `nfolds' folds. Elastic net with alpha=`alphai'."
			}
			di as text "Fold " _c
			
			mat `Mspe' = J(`nfolds',`lcount',.) // stores MSPE for each fold & lambda
			tempvar sqpe // saves squared P.E. temporarily
			tempvar temp_pe // saves prediction errors temporarily
			
			forvalues rsam=1(1)`nfolds'  {  // loop over folds
				if (`rsam'<`nfolds') {
					di as res `rsam' " " _c	
				}
				else {
					di as res `rsam' " "
				}
				qui replace `training'=0
				qui replace `validation'=0
				// training=1 if in training set; =0 if not in sample OR in validation set
				qui replace `training'=(`foldvar'!=`rsam') if `touse' 
				// validation=1 if in validation set; =0 if not in sample OR in training set
				qui replace `validation'=(`foldvar'==`rsam') if `touse' 
				
				// adjust lambda 
				sum `training', meanonly
				local smpladjust = r(sum)/`N'
				
				// estimation
				qui lasso2 `varlist' if `touse', 				///
										lambdamat(`lambdamat0') ///
										lfac(`smpladjust')		///
										holdout(`validation') 	///
										alpha(`alphai')			///
										verb norecover ///
										`options' 	

				if ("`saveest'"!="") {
					estimates store `saveest'`rsam'
				}
										
				// save mspe
				if (`rsam'==1) {
					mat `Mspe' = e(mspe)
				}
				else {
					mat `Mspe' = (`Mspe' \ e(mspe))
				}			
			} // end loop over folds
			
		} // end k-fold CV
		else {
			
			cap tsset, noquery
			if _rc ~= 0 {
				di as err "Error: rolling option requires data to be tsset or xtset"
				exit 459
			}
			else {
				local tvar =r(timevar)
				sum `tvar' if `touse', meanonly
				local tmin = r(min) 
				local tmax = r(max)
				local Tobs = `tmax'-`tmin'+1 // =T
			}
			// origin = number of obs in first training data set
			if `origin' <= 0 {
				local origin=max(`tmax'-10-`h',`tmin') // ad hoc rule
			}
			if ((`origin'+`h')>`tmax') {
				di as error "First validation point is outside of data range. Change origin() or h()."
				exit 198
			}
			else if (`origin'<`tmin') {
				di as error "origin() out of range. origin() must be >=`tmin'."
				exit 198
			}
			local trainend = `origin'
			local trainstart = `tmin'
			local nfoldscheck = 0 // tracks number of folds
			local nfolds = (`tmax'-`trainend')-`h'+1
			if (`nfolds'<=2) {
				di as error "Validation window too small. Change origin()."
				exit 198
			}
			if "`sqrt'"!="" {
				di as text "Rolling forecasting cross-validation with `h'-step ahead forecasts. Square-root LASSO estimator."
			} 
			else {
				di as text "Rolling forecasting cross-validation with `h'-step ahead forecasts. Elastic net with alpha=`alpha'."
			}
			di as text "Training from-to (validation point): " _c
			while ((`trainend'+`h')<=`tmax') { 
				
				if ((`trainend'+`h')<`tmax') {
					di as res "`trainstart'-`trainend' (`=`trainend'+`h''), " _c	
				}
				else {
					di as res "`trainstart'-`trainend' (`=`trainend'+`h'')."  
				}
					
				qui replace `training'=0
				qui replace `validation'=0
				// training=1 if in training set; =0 if not in sample OR in validation set
				qui replace `training'=(`trainstart'<=`tvar')*(`tvar'<=`trainend') if `touse' 
				// validation=1 if in validation set; =0 if not in sample OR in training set
				qui replace `validation'=(`tvar'==(`trainend'+`h')) if `touse' 
				
				// adjust lambda 
				sum `training', meanonly
				local smpladjust = r(sum)/`N'	
				
				* lasso estimation (for given lambda and specific fold)
				qui lasso2 `varlist' if `touse', 				///
										lambdamat(`lambdamat0') ///
										lfactor(`smpladjust') 	///
										holdout(`validation') 	///
										alpha(`alphai')			///
										`options' 	
				if ("`saveest'"!="") {
					estimates store `saveest'`rsam'
				}
				
				// save mspe
				if `trainend'==`origin' {  // first run
					mat `Mspe' = e(mspe)
				}
				else {
					mat `Mspe' = (`Mspe' \ e(mspe))
				}			
				
				// trainend
				local trainend=`trainend'+1
				local nfoldscheck = `nfoldscheck'+1
				if ("`fixedwindow'"!="") {
					local trainstart = `trainstart' + 1
				}
			} // end rolling over folds
			if (`nfolds'!=`nfoldscheck') {
				di as err "internal cvlasso error. nfolds!=nfoldscheck. `nfolds'!=`nfoldscheck'"
				exit 1
			}

		} // end rolling CV
		*
		
		*** for ereturn (taken from lasso2)
		local sqrtflag		= e(sqrt)
		local ada			= e(adaptive)
		local ols			= e(ols)
		local partial_ct	= e(partial_ct)
		local notpen_ct		= e(notpen_ct)
		if `partial_ct'>0 {
			local partialvar=e(partial)
		}
		if `notpen_ct'>0 {
			local notpenvar	=e(notpen)
		}
		local prestdflag	= e(prestd)
		local pcount		= e(p)
		local noftools		`e(noftools)'
		
		*** display and get lopt/lse
		mata: ReturnCVResults2("`Mspe'", 		///
							   "`lambdamat0'", 	///
							   "`omitgrid'")
		*** show warning if no unique lambda
		local lunique = r(lunique)
		if (`lunique'==0) {
			di as err "Warning: no unique optimal lambda value."
		}
		else if ("`omitgrid'"=="") {
			di as text "* lopt = the lambda that minimizes MSPE." 
			di as text "  Run model: {stata cvlasso, lopt}" 
			di as text "{p 0 8 2}^ lse = largest lambda for which MSPE is within one standard error of the minimal MSPE.{p_end}"
			di as text "  Run model: {stata cvlasso, lse}"
		}
		*
		
		*** show warning if lambda opt/se at limit
		local loptid0 = r(loptid)
		local lseid0  = r(lseid)
		local lcount  = r(lcount)
		if (`loptid0' == 1) | (`loptid0' == `lcount') {
			di as red "Warning: lopt is at the limit of the lambda range."
		}
		if (`lseid0' == 1) | (`lseid0' == `lcount') {
			di as red "Warning: lse is at the limit of the lambda range."
		}
		*
		
		*** if CV'ing over alpha, store min MSPE, lopt and lse
		if `acount'>1 { 
			if `lunique'==0 {
				// need to abort CV across alpha
				di as err "Not able to cross-validate over alpha."
				error 1 // AA: please change error code
			}
			if `aid'==1 {
				local mspemin=r(mspemin)
				local alphamin=`alphai'
				local loptoverall = r(lopt)
				local lseoverall = r(lse)
			}
			else if (r(mspemin)<`mspemin') {
				local mmspemin=r(mspemin)
				local alphamin=`alphai'
				local loptoverall = r(lopt)
				local lseoverall = r(lse)
			}
			mat `mminmat'[1,`aid']=r(mspemin)
			mat `mminlam'[1,`aid']=r(lopt)
		}
		if `acount'!=`aid' {
			di ""
			local aid = `aid'+1
		}
		
	} // end loop over alpha
	*
	
	*** display results for cv across alpha
	if (`acount'>1) {
		local i=1
		di
		di as text "Cross-validation over alpha (`alpha')."
		di as text _col(10) "alpha {c |} lopt*" _c
		di as text _col(30) " Minimum MSPE"
		di as text _col(4) "{hline 12}{c +}{hline 28}"
		forvalues i=1(1)`acount' {
			local alphai : word `i' of `alpha'
			local mi = `mminmat'[1,`i']
			local lopti = `mminlam'[1,`i']
			if (`alphai'==`alphamin') {
				di as res _col(10) %4.3f `alphai' _c
				di as text _col(16) "{c |}" _c
				di as res _col(17) %10.0g `lopti' _c
				di as res _col(30) %10.0g `mi' _c
				di as text _col(42) "#" 
			}
			else {
				di as res _col(10) %4.3f `alphai' _c
				di as text _col(16) "{c |}" _c
				di as res _col(17) %10.0g `lopti' _c
				di as res _col(30) %10.0g `mi' 
			}
		}
		di as text "* lambda value that minimizes MSPE for a given alpha"
		di as text "# alpha value that minimizes MSPE"
	}
	*
	
	*** ereturn 
	ereturn post, obs(`N')  esample(`touse')
	ereturn scalar nfolds		=r(nfolds)
	ereturn scalar lmax 		=r(lmax)
	ereturn scalar lmin			=r(lmin)
	ereturn scalar lcount 		=`lcount'
	ereturn scalar sqrt 		=`sqrtflag'
	ereturn scalar adaptive		=`ada'
	ereturn scalar ols			=`ols'
	ereturn scalar notpen_ct	=`notpen_ct'
	ereturn scalar partial_ct	=`partial_ct'
	ereturn scalar prestd 		= `prestdflag'
	mat `lambdamat0' 			= `lambdamat0''
	ereturn matrix lambdamat 	= `lambdamat0'
	ereturn scalar nalpha 		= `acount'
	ereturn scalar p 			= `pcount'
	ereturn local noftools		`noftools'
	ereturn local partial 		`partialvar'
	ereturn local notpen 		`notpenvar'
	ereturn local cmd			cvlasso
	ereturn local predict		lasso2_p
	ereturn local depvar 		`varY_o'
	ereturn local varX			`varX_o' // regressors
	local varXmodel_o : list varX_o - partialvar	
	ereturn local varXmodel		`varXmodel_o' // regressors ex partial
	ereturn local method 		`r(method)'
	ereturn local cvmethod 		`cvmethod'
	if `acount'==1 {
		ereturn scalar alpha 	= `alpha'
		ereturn scalar lopt		=r(lopt)
		ereturn scalar lse		=r(lse)
		ereturn scalar mspemin 	=r(mspemin)
		tempname mspe0 mmspe0 cvsd0 cvup0 cvlo0
		mat `mspe0' = r(mspe)'
		mat `mmspe0' = r(mmspe)'
		mat `cvsd0' = r(cvsd)'
		mat `cvup0' = r(cvupper)'
		mat `cvlo0' = r(cvlower)'
		ereturn matrix mspe 	=`mspe0'
		ereturn matrix mmspe 	=`mmspe0'
		ereturn matrix cvsd 	=`cvsd0'
		ereturn matrix cvupper 	=`cvup0'
		ereturn matrix cvlower 	=`cvlo0'
	}
	else {	
		ereturn local alphalist `alpha'
		ereturn scalar lopt 		= `loptoverall'
		ereturn scalar lse 			= `lseoverall'
		ereturn scalar alphamin 	= `alphamin'
		ereturn scalar mspemin		=`mspemin'
		ereturn matrix mspeminmat 	= `mminmat'
	}
	if ("`rolling'"!="") {
		ereturn scalar h = `h'
		ereturn scalar origin		=`origin'
		ereturn local cvmethod "rolling"
	}
	else {
		ereturn local cvmethod "K-fold"
	}
end

******************* Stata utilities ************************

program define cvplot 
	syntax [anything] [, plotopt(string)]

	* needed for replay plotting
	tempname lambdas mmspe cvupper cvlower
	mat `lambdas'		=e(lambdamat) 
	mat `mmspe'			=e(mmspe)
	mat `cvupper'		=e(cvupper)
	mat `cvlower'		=e(cvlower)

	* do plotting
	if (`e(nalpha)'==1) {
		preserve 
		clear
		qui mat M=(`lambdas',`mmspe',`cvlower',`cvupper')
		qui svmat M
		rename M1 lambda
		label var lambda "Lambda"
		rename M2 mmspe
		label var mmspe "Mean-squared prediction error"
		rename M3 lower
		label var lower "MSPE - sd. error"
		rename M4 upper
		label var upper "MSPE + sd. error"
		gen double lnlambda=ln(lambda)
		label var lambda "ln(Lambda)"
		if ("`plotopt'"=="") {
			local plotopt xline(`=ln(`e(lopt)')', lpattern(solid)) xline(`=ln(`e(lse)')', lpattern(dash_dot )) xtitle("ln(Lambda)") ytitle("MSPE") lcol(black black black) lpattern(dash solid dash)
		}
		line lower mmspe upper lnlambda, `plotopt'
		restore
	}
	else {
		di as err "Plotting only supported for scalar alpha value."
	}
end

program define fvstrip, rclass
// internal version of fvstrip 1.01 ms 24march2015
// takes varlist with possible FVs and strips out b/n/o notation
// returns results in r(varnames)
// optionally also omits omittable FVs
// expand calls fvexpand either on full varlist
// or (with onebyone option) on elements of varlist
	version 11.2
	syntax [anything] [if] , [ dropomit expand onebyone NOIsily ]
	if "`expand'"~="" {												//  force call to fvexpand
		if "`onebyone'"=="" {
			fvexpand `anything' `if'								//  single call to fvexpand
			local anything `r(varlist)'
		}
		else {
			foreach vn of local anything {
				fvexpand `vn' `if'									//  call fvexpand on items one-by-one
				local newlist	`newlist' `r(varlist)'
			}
			local anything	: list clean newlist
		}
	}
	foreach vn of local anything {									//  loop through varnames
		if "`dropomit'"~="" {										//  check & include only if
			_ms_parse_parts `vn'									//  not omitted (b. or o.)
			if ~`r(omit)' {
				local unstripped	`unstripped' `vn'				//  add to list only if not omitted
			}
		}
		else {														//  add varname to list even if
			local unstripped		`unstripped' `vn'				//  could be omitted (b. or o.)
		}
	}
// Now create list with b/n/o stripped out
	foreach vn of local unstripped {
		local svn ""											//  initialize
		_ms_parse_parts `vn'
		if "`r(type)'"=="variable" & "`r(op)'"=="" {			//  simplest case - no change
			local svn	`vn'
		}
		else if "`r(type)'"=="variable" & "`r(op)'"=="o" {		//  next simplest case - o.varname => varname
			local svn	`r(name)'
		}
		else if "`r(type)'"=="variable" {						//  has other operators so strip o but leave .
			local op	`r(op)'
			local op	: subinstr local op "o" "", all
			local svn	`op'.`r(name)'
		}
		else if "`r(type)'"=="factor" {							//  simple factor variable
			local op	`r(op)'
			local op	: subinstr local op "b" "", all
			local op	: subinstr local op "n" "", all
			local op	: subinstr local op "o" "", all
			local svn	`op'.`r(name)'							//  operator + . + varname
		}
		else if"`r(type)'"=="interaction" {						//  multiple variables
			forvalues i=1/`r(k_names)' {
				local op	`r(op`i')'
				local op	: subinstr local op "b" "", all
				local op	: subinstr local op "n" "", all
				local op	: subinstr local op "o" "", all
				local opv	`op'.`r(name`i')'					//  operator + . + varname
				if `i'==1 {
					local svn	`opv'
				}
				else {
					local svn	`svn'#`opv'
				}
			}
		}
		else if "`r(type)'"=="product" {
			di as err "fvstrip error - type=product for `vn'"
			exit 198
		}
		else if "`r(type)'"=="error" {
			di as err "fvstrip error - type=error for `vn'"
			exit 198
		}
		else {
			di as err "fvstrip error - unknown type for `vn'"
			exit 198
		}
		local stripped `stripped' `svn'
	}
	local stripped	: list retokenize stripped						//  clean any extra spaces
	
	if "`noisily'"~="" {											//  for debugging etc.
di as result "`stripped'"
	}

	return local varlist	`stripped'								//  return results in r(varlist)
end

// Internal version of matchnames
// Sample syntax:
// matchnames "`varlist'" "`list1'" "`list2'"
// takes list in `varlist', looks up in `list1', returns entries in `list2', called r(names)
program define matchnames, rclass
	version 11.2
	args	varnames namelist1 namelist2

	local k1 : word count `namelist1'
	local k2 : word count `namelist2'

	if `k1' ~= `k2' {
		di as err "namelist error"
		exit 198
	}
	foreach vn in `varnames' {
		local i : list posof `"`vn'"' in namelist1
		if `i' > 0 {
			local newname : word `i' of `namelist2'
		}
		else {
* Keep old name if not found in list
			local newname "`vn'"
		}
		local names "`names' `newname'"
	}
	local names	: list clean names
	return local names "`names'"
end


version 13
mata:
void s_maketemps(real scalar p)
{
	(void) st_addvar("double", names=st_tempname(p), 1)
	st_global("r(varlist)",invtokens(names))
}
//

real rowvector getLambdaList(string scalar ystring, 
							 string scalar xstring, 
							 real scalar cons,
							 string scalar touse,
							 string scalar psistr,
							 ///string scalar sdy,
							 real scalar lmax,
							 real scalar lcount,
							 real scalar lminratio, 
							 real scalar sqrt)
{
	st_view(y,.,ystring,touse)
	st_view(X,.,xstring,touse)
		if (lmax<=0) {
		Psi = st_matrix(psistr)
		if (cons) {
			Xy = quadcrossdev(X,mean(X),y,mean(y)):/(Psi')
		}
		else {
			Xy = quadcross(X,y):/(Psi')
		}
		if (sqrt==0) {
			lmax = max(abs(Xy))*2 // Friedman et al (2010), p. 7.  
		}
		else {
			lmax = max(abs(Xy))
		}
	}
	lmin = lminratio*lmax
	lamlist=exp(rangen(log(lmax),log(lmin),lcount))'
	return(lamlist)
}
//


void ReturnCVResults2(string scalar mspestr, ///
					string scalar lambdastr, ///
					string scalar omitgrid)
{
		
	mspe = st_matrix(mspestr) 
	nfolds = rows(mspe)
	lamvec=st_matrix(lambdastr)
	lnum=cols(lamvec)
	mmspe=mean(mspe)			// mean of mean squared pred error across folds
	cvsd = sqrt(mean((mspe:-mmspe):^2):/(nfolds-1))	// standard error
	cvup = mmspe :+ cvsd
	cvlo = mmspe :- cvsd
	loptid=.
	minindex(mmspe,1,loptid,.)	// returns index of lambda that minimises RMSE
	if (rows(loptid)>1) {
		loptid=. // no unique lopt 
		lseid=.
		lopt=.
		lse=.
		mmspemin=.
		unique=0
	}
	else {
		lseid=getOneSeLam(mmspe,cvsd,loptid)	// returns index of "1 standard error rule"
		lopt=lamvec[1,loptid]	
		lse=lamvec[1,lseid]		// returns the lambda "1 standard error rule"
		mmspemin=mmspe[1,loptid]
		unique=1
	}
	lmin=min(lamvec)
	lmax=max(lamvec)
		
	if (omitgrid=="") {
		
		printf("{txt}%10s{c |} {space 3} {txt}%10s {space 3} {txt}%10s {space 3} {txt}%10s\n","","Lambda","MSPE","st. dev.")
		printf("{hline 10}{c +}{hline 45}\n")
				
		for (j = 1;j<=lnum;j++) {
			
			if (j==loptid) {
				marker="*"
			}
			else {
				marker=""
			}
			if (j==lseid) {
				marker=marker+"^"
			}
			printf("{txt}%10.0g{c |} {space 3} {res}%10.0g {space 3} {res}%10.0g {space 3} {res}%10.0g  %s\n",j,lamvec[1,j],mmspe[1,j],cvsd[1,j],marker)
		}
	}
	
	st_numscalar("r(lunique)",unique)
	st_numscalar("r(mspemin)",min(mmspe))
	st_numscalar("r(lseid)",lseid)
	st_numscalar("r(loptid)",loptid)
	st_numscalar("r(lcount)",lnum)
	st_numscalar("r(lmin)",lmin)
	st_numscalar("r(lmax)",lmax)
	st_numscalar("r(lse)",lse)
	st_numscalar("r(lopt)",lopt)
	st_numscalar("r(nfolds)",nfolds)	
	st_matrix("r(mspe)",mspe)
	st_matrix("r(mmspe)",mmspe)	
	st_matrix("r(cvsd)",cvsd)
	st_matrix("r(cvupper)",cvup)
	st_matrix("r(cvlower)",cvlo)
}
// end ReturnCVResults

// return the lambda id of the largest lambda at which the MSE
// is within one standard error of the minimal MSE.		
real scalar getOneSeLam(real rowvector mse, real rowvector sd, real scalar id) 
{
	if (id!=.) {
		minmse = mse[1,id] // minimal MSE
		minsd = sd[1,id]  // SE of minimal MSE
		criteria = mse[1,id]+sd[1,id] // max allowed MSE
		for (j=0; j<id; j++) {
			theid=id-j 
			thismspe= mse[1,theid]
			if (thismspe > criteria) { // if MSE is outside of interval, stop
					theid = id-j+1 // go back by one id and break
					break
			}
		} 
	}
	else {
		theid = .
	}
	return(theid)
}


// END MATA SECTION
end

