*! cvlassologit 
*! part of lassopack v1.3
*! last edited: 6may2019
*! authors: aa/ms

program cvlassologit, eclass sortpreserve
	version 13
	syntax [anything] [if] [in] [fw aw pw] [,		///
			PLOTCV									///+ triggers plotting
			PLOTOPT(string)							///+ options to pass to graph command
			LSE LOPT 								///+
			POSTRESults								///+
			///
			/// important:
			/// list all cvlasso options that do not apply to lassologit
			NFolds(integer -1)						///+ number of folds
			FOLDVar(varlist numeric max=1)			///+ alternatively: user-specified fold variable
			SAVEFoldvar(string)						///+ if string is supplied fold var is saved 
			seed(int 0)								///+
			VERsion									///
			STRATified 								///+
			STOREest(string)						///+
			LOSSMeasure(string) 					///+
			tabfold									///+
			OMITGrid 								///
			LONGgrid 								///+
													///
			* 										/// [options = passed on to lassologit]
			]

	local lversion 
	local pversion 

	if "`version'" != "" {							//  Report program version number, then exit.
		di in gr "cvlasso version `lversion'"
		di in gr "lassopack package version `pversion'"
		ereturn clear
		ereturn local version		`lversion'
		ereturn local pkgversion	`pversion'
		exit
	}
	//
	if ~replay() { // no replay	
		tokenize "`0'", parse(",")
		_cvlassologit `1', `options' 					///
							nfolds(`nfolds') 			///
							foldvar(`foldvar') 			///
							savefoldvar(`savefoldvar') 	///
							seed(`seed') 				///
							`stratified' 				///
							storeest(`storeest')		///
							lossmeasure(`lossmeasure')  ///
							`tabfold'					///
							`omitgrid' `longgrid'
		ereturn local cmdoptions `options'  
	}
	//
	
	
	*** display output
	if ("`omitgrid'"=="") {
		CVdisplay, `longgrid'
		di as text "* lopt = the lambda that minimizes loss measure." 
		di as text "  Run model: " _c
		di in smcl "{stata cvlassologit, lopt}" 
		di as text "^ lse = largest lambda for which MSPE is within one standard error of the minimum loss."
		di as text "  Run model: " _c
		di in smcl "{stata cvlassologit, lse}"
	}
	if ("`longgrid'"=="") {
		di as text "  Use 'long' option for long output."
	}
	if (`e(lunique)'==0) {
		di as err "Warning: no unique optimal lambda value."
	}
	//
	
	if ("`e(cmd)'"!="cvlassologit") {
		di as error "No variables specified." 
		error 198
	}
	if ("`plotcv'`plotopt'"!="") {
		cvplot2, plotopt(`plotopt') logistic
	}
	//
	
	if ("`lse'`lopt'"!="") { // run lasso2 with lse/lopt
		
		*** get lambda & alpha for lasso2 call
		if ("`lse'"!="") & ("`lopt'"!="") {
			di as error "lse and lopt not allowed at the same time."
			exit 198
		} 
		else if ("`lse'"!="") {
			local lambdause = e(lse)
		}
		else if ("`lopt'"!="") {
			local lambdause = e(lopt)
		}

		if (`lambdause'==.) {
			// this will happen if lopt is not unique.
			di as err "Internal error. `lopt'`lse' is not defined."
			error 1
		}
		
		di as text "Estimate `e(method)' with lambda=" round(`lambdause',0.001) " (`lse'`lopt')."
		
		*** call lassologit
		local depvar `e(depvar)'
		local varXmodel `e(varX)'
		local cmdoptions0 `e(cmdoptions)'
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
		lassologit `depvar' `varXmodel' if `esample', ///
									newlambda(`lambdause')  ///
									`cmdoptions0' ///
									noprogressbar 
		if ("`postresults'"=="") {
			_estimates unhold `model0'
		}
	}
end

program _cvlassologit, eclass sortpreserve

	syntax varlist(numeric min=2 fv ts)				 ///
		[if] [in] [fw aw pw] [,						 ///
		Lambda(numlist >0 min=2 descending)			 /// overwrite default lambda
		NFolds(integer -1)							 /// number of folds
		FOLDVar(varlist numeric max=1)				 /// alternatively: user-specified fold variable
		SAVEFoldvar(string )						 /// if string is supplied fold var is saved 
		VERBose 									 ///
		debug 										 /// 
		LCount(integer 50)							 /// number of lambdas
		LMINRatio(real 1e-3)						 /// ratio of maximum to minimum lambda
		lmax(real 0)							 	 ///
		LADJustment									 /// lambda is divided by 2*n (to make results comparable with glmnet)
		LAMBDAN										 /// use as input/report as output lambda that incorporates 1/n
		seed(int 0)									 ///
		ALPHACount(int -1)	 						 ///	
		ALPha(numlist ascending)					 /// elastic net parameter
		///saveest(string)								 ///
		LOSSMeasure(string)	   						 ///
		STRATified 									 ///
		STOREest(string)							 ///
		stdsmart									 ///
		tabfold										 ///
		omitgrid									 ///
		longgrid									 ///
		*											 ///
		]

	// does not replicate without this! unclear why...
	ereturn clear

	// flags	
	local weightflag	= ("`weight'"~="")
	local fweightflag	= ("`weight'"=="fweight")
	// cvlassologit internally uses lambda that incorporates 1/n
	// but reports lambda that does not incorporate 1/n
	// lambdanflag=0 (default): reported lambdas need to be rescaled by n at the end
	//                          and user=provided lambdas need to be deflated by 1/n before use
	// lambdanflag=1          : no rescaling necessary
	local lambdanflag	= ("`lambdan'"~="")
	local stdsmartflag	= ("`stdsmart'"~="")

	// defaults
	if "`lossmeasure'"=="" {
		local lossmeasure deviance
	}
	//
	
	if ("`verbose'"!="") {
		local qui 
		local noqui qui
	} 
	else {
		local qui qui
		local noqui
	}
	//
	
	*** Record which observations have non-missing values
	marksample touse
	markout `touse' `varlist' `ivar' `foldvar'
	sum `touse' if `touse', meanonly		//  will sum weight var when weights are used
	local N		= r(N)
	
	*** weights
	// `exp' includes the =
	tempvar wvar
	if `fweightflag' {
		// fweights
		qui gen long `wvar' `exp'
	}
	else if `weightflag' {
		// aweights and pweights
		if "`weight'"=="aweight" {
			// Stata's logit won't accept aweights
			local weight pweight
		}
		qui gen double `wvar' `exp'
		sum `wvar' if `touse' `wtexp', meanonly
		// Weight statement
		di as text "(sum of wgt is " %14.4e `r(sum)' ")"
		// normalize to have unit mean
		qui replace `wvar' = `wvar' * r(N)/r(sum)
	}
	else {
		// unweighted
		qui gen byte `wvar' = 1
	}
	//

	*** Create separate varlists:
	// expand
	fvexpand `varlist' if `touse'
	local allvars `r(varlist)'
	local varY_o	: word 1 of `allvars'						
	local varX_o	: list allvars - varY_o
	// depvar
	tempvar varY_t
	gen byte `varY_t' = `varY_o'~=0
	qui replace `varY_t' = . if `varY_o'==.
	// check for duplicates has to follow expand
	local dups		: list dups varX_o
	if "`dups'"~="" {
		di as text "Dropping duplicates: `dups'"
	}
	local varX_o	: list uniq varX_o
	// make X temp doubles unless using stdsmart
	if `stdsmartflag' {
		foreach var of local varX_o {
			// determine whether variable exists
			_ms_parse_parts `var'
			if "`r(op)'`r(op1)'"=="" {
				// no fv or ts operator, variable exists
				// determine variable type
				local stype : type `var'
				if "`stype'"=="byte" {
					// create byte temp var
					tempvar v
					qui gen byte `v' = `var'
					local varX_t `varX_t' `v'
					local bytelist `bytelist' 1
				}
				else {
					// create double temp var
					tempvar v
					qui gen double `v' = `var'
					local varX_t `varX_t' `v'
					local bytelist `bytelist' 0
				}				
			}
			else {
				// fv or ts operator, use fvrevar
				fvrevar `var'
				local rv `r(varlist)'
				local stype : type `rv'
				if "`stype'"=="byte" {
					local varX_t `varX_t' `rv'
					local bytelist `bytelist' 1
				}
				else {
					tempvar v
					qui gen double `v' = `rv'
					local varX_t `varX_t' `v'
					local bytelist `bytelist' 0
				}				
			}	
		}
	}
	else {
		// default - all temps are doubles
		foreach var of local varX_o {
			tempvar v
			qui gen double `v' = `var'
			local varX_t `varX_t' `v'
			local bytelist `bytelist' 0
		}
	}
	*

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
			local nfolds =5
		}
		else if (`nfolds'<=2) {
		di as err "nfolds=`nfolds' is not allowed. Use default nfolds=10."
			local nfolds =5
		}
		* random assignment of folds
		if (`seed'>0) {
			set seed `seed'
		}
		qui { 
			if ("`stratified'"=="") {
				tempvar uni cuni
				tempvar foldvar
				gen `uni'=runiform()  if `touse'
				if (`weightflag') {
					cumul `uni' [`weight'=`wvar'] if `touse', gen(`cuni')
				} 
				else {
					cumul `uni' if `touse', gen(`cuni')
				}
				replace `cuni'  = `cuni'*`nfolds'
				gen `foldvar' = ceil(`cuni') if `touse'  
			}
			else {
				tempvar uni cuni0 cuni1
				tempvar foldvar
				gen `uni'=runiform() if `touse'
				if (`weightflag') {
					cumul `uni' [`weight'=`wvar'] if `touse' & `varY_t'==0, gen(`cuni0')
					cumul `uni' [`weight'=`wvar'] if `touse' & `varY_t'==1, gen(`cuni1')
				}
				else {
					cumul `uni' if `touse' & `varY_t'==0, gen(`cuni0')
					cumul `uni' if `touse' & `varY_t'==1, gen(`cuni1')				
				}
				replace `cuni0'  = `cuni0'*`nfolds'
				replace `cuni1'  = `cuni1'*`nfolds'
				gen     `foldvar' = ceil(`cuni0') if `touse'  & `varY_t'==0
				replace `foldvar' = ceil(`cuni1') if `touse'  & `varY_t'==1
			}
		}
		//if ("`savefoldvar'"!="") & ("`rolling'"!="") {
		//	di as err "Saving of fold IDs not supported after rolling CV."
		//}
		if ("`savefoldvar'"!="") & ("`rolling'"=="") { // save fold id
			qui gen long `savefoldvar' = `foldvar'
			di "Fold variable saved in `savefoldvar'."
		}
	}
	// display fold distribution
	if ("`tabfold'"!="") {
			label var `foldvar' "Fold"
			if (`weightflag') {
				tab `varY_o' `foldvar' [fw=`wvar']
			}
			else {
				tab `varY_o' `foldvar' 
			}			 
	}
	*
	
	*** check if all estimation samples have at least one success ("1") and one failure ("0")
	forvalues f = 1/`nfolds' {
		sum `varY_t' if `foldvar'!=`nfolds', meanonly
		cap assert r(mean)>0 & r(mean)<1
		if _rc==9 {
			di as err "error: outcome does not vary in estimation sample (fold=`f')"
			if ("`stratified'"=="") {
				di as err "consider using 'stratified' option."
			}
			else {
				di as err "consider reducing number of folds."
			}
			exit 2000
		}
	}
	//

	* generate fold id variable
	// do here so that indicator variables are included in data struct
	tempvar training
	qui gen byte `training'=1
	tempvar validation
	qui gen byte `validation'=0	

	
	*** set up data struct and get lambda ***************************************
	// call lassologit once to set up data including indicator vars and get default lambdas.
	// data struct will also have names of wvar, touse, toest and holdout Stata variables
	tempname data
	lassologit `varY_o' if `touse' [`weight' `exp'],	///
								setupstruct(`data')		///
								settingup 				///
								vary_t(`varY_t')		///
								varx_o(`varX_o')		///
								varx_t(`varX_t')		///
								bytelist(`bytelist')	///
								lcount(`lcount')		///
								lminratio(`lminratio')	///
								lmax(`lmax')			///
								wvar(`wvar')			///
								touse(`touse')			///
								toest(`training')		///
								holdout(`validation')	///
								lambdan					/// enforce lambdan option
								`stdsmart'				///
								noprogressbar 			///
								nopath					///
								`options'

	// macro `lambda' has lambdas in string format
	// matrix `lambdamat0' has lambdas in matrix format
	tempname lambdamat0
	if ("`lambda'"=="") {
		// use default lambdas returned by lassologit
		// note these incorporate the factor of 1/n (lambdan option)
		mat `lambdamat0'=e(lambdas)
		// put matrix of lambdas into local `lambda'
		mata: st_local("lambda",invtokens(strofreal(st_matrix("e(lambdas)"))))		
//		local lambda
//		forvalues i = 1(1)`lcount' {
//			local thislambda = el(`lambdamat0',1,`i')
//			local lambda `lambda' `thislambda'
//		}
	}
	else {
		// store user-specified lambdas in matrix
		local lcount	: word count `lambda'
		// cvlassologit internally uses lambda that incorporates 1/n
		// but reports lambda that does not incorporate 1/n
		// if user provides lambda that does not incorporate 1/n, need to rescale it
		if `lambdanflag'==0 {
			// first create rescaled matrix, then replace local with rescaled version
			mata: st_matrix("`lambdamat0'",strtoreal(tokens("`lambda'"))*1/st_numscalar("e(N)"))
			mata: st_local("lambda",invtokens(strofreal(st_matrix("`lambdamat0'"))))
		}
		else {
			// default case, no rescaling needed
			mata: st_matrix("`lambdamat0'",strtoreal(tokens("`lambda'")))
		}
//		mat `lambdamat0'	= J(1,`lcount',.)
//		local j = 1
//		foreach lami of local lambda {
//			mat `lambdamat0'[1,`j'] = `lami'  
//			local j=`j'+1
//		}
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
		
		** k-fold CV
		tempname loss
		tempname foldsize
		
			qui sum `foldvar', meanonly
			local nfolds=r(max)
			
			* loop over folds
			di as text "K-fold cross-validation with `nfolds' folds."
			`noqui' di as text "Fold " _c
			
			forvalues rsam=1(1)`nfolds'  {  // loop over folds
				if (`rsam'<`nfolds') {
					`noqui' di as res `rsam' " " _c	
				}
				else {
					`noqui' di as res `rsam' " "
				}
				qui replace `training'=0
				qui replace `validation'=0
				
				// training=1 if in training set; =0 if not in sample OR in validation set
				qui replace `training'=(`foldvar'!=`rsam') if `touse' 
				// validation=1 if in validation set; =0 if not in sample OR in training set
				qui replace `validation'=(`foldvar'==`rsam') if `touse' 
						
				// estimation
				// note that above changes to training and validation variables
				// are automatic because data struct is a view onto these variables
				// note that CV is over lambdas that incorporate factor of 1/n
				// also no need to pass weight expression
				`qui'  lassologit `varY_o' if `touse', 						///
												structname(`data')			///
												lam(`lambda')				///
												lossmeasure(`lossmeasure')	///
												lambdan						///enforce lambdan option
												nopath						/// 
												noprogressbar 				///
												`options' 	
				
				if ("`storeest'"!="") {
					estimates store `storeest'`rsam'
				}
				
				// save mspe
				if (`rsam'==1) {
					mat `loss' = e(loss)
					mat `foldsize' = e(N_holdout)
				}
				else {
					mat `loss' = (`loss' \ e(loss))
					mat `foldsize' = (`foldsize' \ e(N_holdout))
				}			
			} // end loop over folds
		
	}
	//
	ereturn post, obs(`N') esample(`touse')

	mata: eReturnCV("`loss'","`lambdamat0'","`lossmeasure'","`foldsize'","`omitgrid'","`longgrid'",`lambdanflag')
	local lunique = r(lunique)
		
	ereturn local cmd cvlassologit
	ereturn local predict lassologit_p
	ereturn local varX `varX_o'
	ereturn local depvar `varY_o'
	ereturn local wtype `weight'
	// need "s since it's an expression
	ereturn local wexp "`exp'"

	// tidy up Mata - drop data struct from Mata's memory
	mata: mata drop `data'

end


program define cvplot2 
	syntax [anything] [, plotopt(string) logistic]

	* objects needed for replay plotting
	tempname lambdas mmspe cvupper cvlower
	
	if ("`logistic'"!="") {
		mat `lambdas'		=e(lambdas)'
		mat `mmspe'			=e(mloss)'
		mat `cvupper'		=e(cvupper)'
		mat `cvlower'		=e(cvlower)'
		local nalpha = 1
		local loss_measure `e(lossmeasure)'
	} 
	else {
		mat `lambdas'		=e(lambdamat) 
		mat `mmspe'			=e(mmspe)
		mat `cvupper'		=e(cvupper)
		mat `cvlower'		=e(cvlower)	
		local nalpha = `e(nalpha)'
		local loss_measure "Mean-squared prediction error"
	}
	//

	* do plotting
	if (`nalpha'==1) {
	
		preserve 
		clear
		qui mat M=(`lambdas',`mmspe',`cvlower',`cvupper')
		qui svmat M
		rename M1 lambda
		label var lambda "Lambda"
		rename M2 mmspe
		label var mmspe "`loss_measure'"
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

/*##############################################################################
################# Program for displaying output ##############################*/
program define CVdisplay
	syntax [anything] [, LONGgrid ]
	version 12
	
	local lcount = e(lcount)
	local loptid = e(loptid)
	local lseid = e(lseid)
	local lmeasure = e(lossmeasure)
	local lambdan = e(lambdan)
	
	tempname cvsd_mat mloss_mat lam_mat
	mat `cvsd_mat' = e(cvsd)
	mat `mloss_mat' = e(mloss)
	mat `lam_mat' = e(lambdas)

	mata: CVdisplay(`lcount',"`lam_mat'",`loptid',`lseid',"`longgrid'","`cvsd_mat'","`mloss_mat'","`lmeasure'",`lambdan')
	
end	
	
/*##############################################################################
#################  MATA SECTION ################################################
##############################################################################*/

mata: 

mata clear

void eReturnCV(string scalar lossstr,			///
					string scalar lambdastr,	///
					string scalar lossmeasure,	///
					string scalar foldsizestr, 	///
					string scalar omitgrid,		///
					string scalar longgrid, 	///
					real scalar lambdanflag)
{

	// cvlassologit internal lambdas incorporate factor of 1/n
	// by default rescale here so that factor of 1/n is removed
	// unless overridden with lambdan option
	
	if (lambdanflag==0) {
		lamvec=st_matrix(lambdastr)*st_numscalar("e(N)")
		//lambdanstr="Lambda"
	}
	else {
		lamvec=st_matrix(lambdastr)
		//lambdanstr="Lambda/N"
	}	
	
	if (lossmeasure=="class") {
		lossmeasurestr = "Missclass."
	}
	else if (lossmeasure=="deviance") {
		lossmeasurestr="Deviance"
	}	
	
	loss = st_matrix(lossstr)  // #fold x #lambda matrix
	foldsize = st_matrix(foldsizestr) 
	nfolds = rows(loss)
	lnum=cols(lamvec)
	mloss=mean(loss,foldsize) // mean of loss across folds
	cvsd = sqrt(mean((loss:-mloss):^2):/(nfolds-1)) // standard error
	cvup = mloss :+ cvsd
	cvlo = mloss :- cvsd
	loptid=.
	minindex(mloss,1,loptid,.)	// returns index of lambda that minimises RMSE
	if (rows(loptid)>1) {
		loptid=. // no unique lopt 
		lseid=.
		lopt=.
		lse=.
		mlossmin=.
		unique=0
	}
	else {
		lseid=getOneSeLam(mloss,cvsd,loptid)	// returns index of "1 standard error rule"
		lopt=lamvec[1,loptid]	
		lse=lamvec[1,lseid]		// returns the lambda "1 standard error rule"
		mlossmin=mloss[1,loptid]
		unique=1
	}

	lmin=min(lamvec)
	lmax=max(lamvec)
		
	st_numscalar("e(lunique)",unique)
	st_numscalar("e(mlossmin)",mlossmin)
	st_numscalar("e(lseid)",lseid)
	st_numscalar("e(loptid)",loptid)
	st_numscalar("e(lcount)",lnum)
	st_numscalar("e(lmin)",lmin)
	st_numscalar("e(lmax)",lmax)
	st_numscalar("e(lse)",lse)
	st_numscalar("e(lopt)",lopt)
	st_numscalar("e(nfolds)",nfolds)
	st_numscalar("e(lambdan)",lambdanflag)
	st_global("e(lossmeasure)",lossmeasurestr)
	st_matrix("e(loss)",loss)
	st_matrix("e(mloss)",mloss)	
	st_matrix("e(cvsd)",cvsd)
	st_matrix("e(cvupper)",cvup)
	st_matrix("e(cvlower)",cvlo)
	st_matrix("e(lambdas)",lamvec)
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
// end getOneSeLam

void CVdisplay( real scalar lnum, 
				string scalar lamvec_str, 
				real scalar loptid,
				real scalar lseid,
				string scalar longgrid, 
				string scalar cvsd_str,
				string scalar mloss_str, 
				string scalar lossmeasurestr,
				real scalar lambdanflag) {

	if (lambdanflag==0) {
		lambdanstr="Lambda"
	}
	else {
		lambdanstr="Lambda/N"
	}			
	
	mloss = st_matrix(mloss_str)
	lamvec = st_matrix(lamvec_str)
	cvsd = st_matrix(cvsd_str)
				
	printf("{txt}%10s{c |} {space 3} {txt}%10s {space 3} {txt}%10s {space 3} {txt}%10s\n","",lambdanstr,lossmeasurestr,"St. err.")
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
		if ((longgrid!="") | (j==loptid) | (j==lseid)) {
			printf("{txt}%10.0g{c |} {space 3} {res}%10.0g {space 3} {res}%10.0g {space 3} {res}%10.0g  %s\n",j,lamvec[1,j],mloss[1,j],cvsd[1,j],marker)
		}
	}
}
//

// END MAIN MATA SECTION
end

////////////////////////////////////////////////////////////////////

// Remainder is in Stata environment and is for reference only.


/*
// following is for reference only - struct is defined in lassologit.ado
struct dataStruct {
	
	// data
	pointer matrix X // predictor matrix, full sample
	pointer matrix X1 // predictor matrix, estimation sample
	pointer matrix X0 // corresponds to holdout sample
	pointer colvector y // outcome vector, full sample
	pointer colvector y1 // outcome vector, estimation sample
	pointer colvector y0 // corresponds to holdout sample
	pointer colvector w // weight vector, full sample
	pointer colvector w1 // weight vector, estimation sample
	pointer colvector w0 // weight vector, holdout sample
	real scalar holdout_n //number of obs in the holdout sample
	pointer colvector toest // indicator variable for estimation sample
	pointer colvector holdout // indicator variable for holdout sample
	
	// standardisation and loadings
	real rowvector sdvec
	real rowvector unsdvec
	real rowvector mvec	// = mean(X)
	real scalar ymean
	real rowvector ploadings // penalty loadings
	real rowvector Psi // penalty loadings in metric of unstandardized X
	real rowvector sPsi // penalty loadings in metric of standardized X
	real rowvector Xbyte // =1 if X is a byte, =0 if not (double)
	
	// names
	string scalar Xnames_o
	string scalar XnamesCons_o
	string scalar Xnames_t
	string scalar XnamesCons_t
	string scalar Yname
	string scalar Wname
	string scalar tousename
	string scalar toestname
	string scalar holdoutname
	string scalar NPnames_o
	
	// data dimension
	real scalar total_success //sum(y)
	real scalar num_feat // cols(X) incl constant
	real scalar total_trials //sum(w) = number of observations
	real scalar data_rows // rows(X)=rows(y)
	
	// settings
	real scalar postlogit
	real scalar max_iter 
	real scalar precision
	real scalar logit
	real scalar verb
	real scalar cons
	real scalar std
	real scalar stdfly
	real scalar stdsmart
}
// end dataStruct
*/


