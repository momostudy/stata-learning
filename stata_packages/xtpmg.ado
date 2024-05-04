*! 1.1.1 Ed Blackburne -- Mark Frank Sam Houston State University 20 February 2007
*! Fit pooled-mean group, mean group, and dynamic fixed effects panel data models

capture progam drop xtpmg
program define xtpmg
	version 9
		if replay() {
			if (`"`e(cmd)'"' !="xtpmg") error 301
			Display `0'
		}
		else Estimate `0'
end

program define Estimate, eclass
	syntax varlist(ts) [if] [in] [,LR(varlist ts) EC(namelist)				///
      	         	CONSTraints(numlist) noCONStant Level(integer `c(level)')  	///
			     	CLUster(passthru) 							///
		           	TECHnique(passthru) DIFficult REPLACE FULL MG DFE PMG] 

	if ("`mg'"!="")+("`dfe'"!="")+("`pmg'"!="")>1 { 
		di in red "choose only one of pmg, mg or dfe"
		exit 198 
	}

	if ("`full'"!="") & ("`dfe'"!=""){
		di
		di in ye "full option not meaningful with dfe"
		di in ye "ignoring option and continuing..."
	}

	if ("`cluster'"!="") & ("`dfe'"==""){
		di
		di in ye "cluster option only meaningful with dfe"
		di in ye "ignoring option and continuing..."

	} 
	

	if "`lr'"!=""{
		if "`ec'"==""{
      		local ec __ec
	      }
		if "`replace'"!=""{
			capture drop `ec'
		}

		capture confirm new variable `ec'
		if _rc!=0{
			di in ye "Variable " in gr "`ec'" in ye " already exists."
			di in ye "Either drop the variable or specify another name as EC option."
			exit
		}

	}

	global constraints `constraints'
	marksample touse
	tempname T_i
	quie count if `touse'
	tempname N
	scalar `N'=r(N)
	qui tsset
	local ivar `r(panelvar)'
	local tvar `r(timevar)'
	capture macro drop nocons LRy LRx SRy SRx
	tokenize `varlist'
	global SRy `1'
	mac shift
	global SRx `*'
	global cluster "`cluster'"
	if "`lr'"!=""{
		tokenize `lr'
		global LRy `1'
      	mac shift
		global LRx `*'
	}

	quie levels `ivar' if `touse', local(ids)
	global iis "`ids'"

	global nocons "`constant'"

	if "`mg'"!=""{
		EstMG if `touse', level(`level') ec(`ec') `full'
		exit
	}

	if "`dfe'"!=""{
		EstDFE if `touse', level(`level') ec(`ec')
		exit
	}

	if "`lr'"!=""{	
		quie regress $LRy $LRx if `touse', noconstant
		tempname b0 theta xb thV
		matrix `b0'=e(b)
		ml model d0 xtpmg_ml ($LRy = $LRx, noconstant) if `touse', init(`b0') 	///
		`difficult' `technique' search(off) max
		matrix `theta'=e(b)
		matrix `thV'=e(V)
		quie predict double `xb' if `touse'
		quie gen double `ec'=$LRy-`xb' if `touse' 			
		matrix `thV'=J(1,colsof(e(b)),.) \ `thV'
		matrix `thV'=J(colsof(e(b))+1,1,.) , `thV'
	}
	

	quie count if `touse'
	tempname kl ks

	scalar `kl'=wordcount("$LRx")
	scalar `ks'=wordcount("$SRx")

	if "`constant'"==""{
		scalar `ks'=`ks'+1	
	}
	
	if "`lr'"!=""{
		scalar `ks'=`ks'+1
	}
	tempname n g1 g2 g3 
	local n=wordcount("$iis")
	scalar `g2'=r(N)/`n'
	scalar `g1'=r(N)
	scalar `g3'=0
	tempname param n_sig phi sig sigs xpx cpsr cplr B
	local names
	if "`lr'"!=""{
		foreach x in $LRx{
	 		local names `names' "`ec':`x'"
		}
	}

	local j=1
	tempname ll	
	scalar `ll'=0

// setup initial matricies
  
	tempname G
	matrix `G'=J(`n'*(`ks'),`n'*(`ks'),0)
	if "`lr'"!=""{
		tempname Grow Gxx phis phihat phi_se b_mg V_mg tmp
		matrix `Gxx'=J(`kl',`kl',0) 
	}
	tempname r
	quie gen double `r'=.

// Loop through all panels for regressions
// Also, we fix equation lables within this loop

	foreach i of global iis{
		tempvar `r'`i'
		if "`lr'"!=""{      	
			local names `names' "`ivar'_`i':`ec'"
		}
		foreach x in  $SRx{
           		local names `names' "`ivar'_`i':`x'"
		}
     		if "`constant'"==""{
     			local names `names' "`ivar'_`i':_cons"
		}
		quie count if `touse' & `ivar'==`i'
		scalar `g1'=cond(r(N)<scalar(`g1'),r(N),scalar(`g1'))
		scalar `g3'=cond(r(N)>scalar(`g3'),r(N),scalar(`g3'))
		quie regress $SRy `ec' $SRx if `touse' & `ivar'==`i', `constant'
		quie predict double `r'`i' if `touse' & `ivar'==`i', resid
		quie replace `r'=`r'`i' if `touse' & `ivar'==`i'
		matrix `B'=nullmat(`B') \ e(b)
		scalar `ll'=scalar(`ll')+e(ll)
		scalar `sig'=e(rss)/e(N)			
		matrix `sigs'=nullmat(`sigs') \ `sig'

		if "`lr'"!=""{
			scalar `phi'=_b[`ec']
			matrix `phis'=nullmat(`phis') \ `phi'
			quie matrix accum `xpx'=$LRx if `touse' & `ivar'==`i', nocons
			matrix `Gxx'=`Gxx'+`xpx'*(`phi'^2/`sig')		
			quie matrix accum `cplr'=$LRx `ec' $SRx if `touse' & `ivar'==`i', `constant'
			matrix `cplr'=`cplr'[1..`kl',`kl'+1...]
			matrix `Grow'=(nullmat(`Grow'), -(`phi'/`sig')*`cplr')
		}  

		matrix `param'=nullmat(`param') , e(b)
		quie matrix accum `cpsr'=`ec' $SRx if `touse' & `ivar'==`i', `constant'
		matrix `G'[(`j'-1)*(`ks')+1,(`j'-1)*(`ks')+1]=`cpsr'/(`sig')
		local j=`j'+1
	}

	if "`lr'"!=""{
		matrix `G'=`Grow' \ `G'
		matrix `G'=((`Gxx' \ `Grow''), `G')
	
	}

	tempname b V 
	matrix `V'=syminv(`G')
	matrix `thV'=`V'[1..`kl',1..`kl']
	matrix `b'=nullmat(`theta'), `param' 
	matrix colnames `V'=`names'
	matrix rownames `V'=`names'
	matrix colnames `b'=`names'
	matrix rownames `sigs'=$iis
	matrix colnames `sigs'="Variance"	
	eret post `b' `V', esample(`touse')

// Handle any constraints. However, much like reg3, this will
// fail if the unconstrained model is not identified since these constraints
// are applied post estimation.
// Note: The displayed log-likelihood is from the UNrestricted model

	capture{
		if "$constraints"!=""{
			CalcConst $constraints
			di in gr _n "The following constraints have been applied to the system:"
			matrix dispCns
		}
	}
	
	matrix `b'=e(b)
	matrix `V'=e(V)

	CalcMGE `B' `V'

	tempname v0 v1 k0 k1
	
	matrix `B'=nullmat(`theta'), `B'
	local k0=colsof(`thV')
	local k1=colsof(`V')
	
	matrix `v0'=`thV', J(`k0',`k1',0)
	matrix `v1'=J(`k1',`k0',0),`V'
	matrix `V'=`v0' \ `v1'
	
	quie replace `r'=`r'^2
	quie sum `r' if e(sample)
	ereturn scalar sigma=r(mean)
	ereturn scalar N=`N'
	ereturn scalar n_g=`n'
	ereturn scalar g_min=`g1'
	ereturn scalar g_avg=`g2'
	ereturn scalar g_max=`g3'
	ereturn matrix sig2_i=`sigs'
	ereturn matrix MGE_b=`B'
	ereturn matrix MGE_V=`V'
	ereturn local depvar="$SRy"
	ereturn local ivar="`ivar'"
	ereturn local tvar="`tvar'"
	ereturn local cmd="xtpmg"
	ereturn local model="PMG"
	ereturn scalar ll=scalar(`ll')

	quie est store PMG, copy title("Full pmg estimates")
	matrix `b'=e(MGE_b)
	matrix `V'=e(MGE_V)

	local names
	foreach x of global LRx{
		local names `names' "`ec':`x'"
	}
	local names `names' "SR:`ec'"
	foreach x of global SRx{
		local names `names' "SR:`x'"
	}
	if "$nocons"==""{
		local names `names' "SR:_cons"
	}
	matrix colnames `b'=`names'
	matrix colnames `V'=`names'
	matrix rownames `V'=`names'

	quie gen byte `touse'=e(sample)
	eret post `b' `V', esample(`touse')
	capture{
		if "$constraints"!=""{
			CalcConst $constraints
			di in gr _n "The following constraints have been applied to the system:"
			matrix dispCns
		}
	}

	ereturn scalar sigma=r(mean)
	ereturn scalar N=`N'
	ereturn scalar n_g=`n'
	ereturn scalar g_min=`g1'
	ereturn scalar g_avg=`g2'
	ereturn scalar g_max=`g3'
	matrix `sigs'=e(sig2_i)
	ereturn matrix sig2_i=`sigs'
	ereturn local depvar="$SRy"
	ereturn local ivar="`ivar'"
	ereturn local tvar="`tvar'"
	ereturn local cmd="xtpmg"
	ereturn local model="pmg"
	ereturn scalar ll=scalar(`ll')
	quie est store pmg, copy title("Summarized pmg estimates")

	if "`full'" !=""{
		quie est restore PMG
	}

	Display, level(`level')
end

program define EstMG, eclass
	syntax [if] [in], EC(string) [Level(integer `c(level)') FULL] 
	marksample touse
	tempname nl N names
	quie count if `touse'
	local N=r(N)
	tempname n g1 g2 g3 
	local n=wordcount("$iis")
	scalar `g2'=r(N)/`n'
	scalar `g1'=r(N)
	scalar `g3'=0
	local nl
	local names
	foreach x of global LRx{
		local nl `nl' (-_b[`x']/_b[$LRy])	
		local names `names' "`ec':`x'"
	}
	local nl `nl' (_b[$LRy])
	local names `names' "SR:`ec'"
	foreach x of global SRx{
		local nl `nl' (_b[`x'])
		local names `names' "SR:`x'"
	}
	if "$nocons"==""{
		local nl `nl' (_b[_cons])
		local names `names' "SR:_cons"
	}

	tempname B V r ll sig2 xb r 
	scalar `ll'=0
	quie generate `r'=.
	tempname b0 v0 VV kk new_name

	local kk=wordcount("$LRy $LRx $SRx")

	if "$nocons"==""{
		local kk=`kk'+1
	}

	matrix `VV'=J(`kk'*`n',`kk'*`n',0)
	local j=1
	
	foreach i of global iis{
		tempvar `r'`i'
		quie count if `touse' & `_dta[iis]'==`i'
		scalar `g1'=cond(r(N)<scalar(`g1'),r(N),scalar(`g1'))
		scalar `g3'=cond(r(N)>scalar(`g3'),r(N),scalar(`g3'))
		quie regress $SRy $LRy $LRx $SRx if `touse' & `_dta[iis]'==`i', $nocons
		quie predict double `r'`i' if `touse' & `_dta[iis]'==`i', resid
		quie replace `r'=`r'`i' if `touse' & `_dta[iis]'==`i'
		scalar `ll'=`ll'+e(ll)
		quie nlcom `nl', level(`level') post
		tempname b V
		matrix `b'=e(b)
		matrix `V'=e(V)
		matrix colnames `b'=`names'
		foreach xx of local names{
			local newname "`newname' `_dta[iis]'_`i'`xx'"
		}
		matrix `b0'=nullmat(`b0'),`b'
		matrix `VV'[(`j'-1)*(`kk')+1,(`j'-1)*(`kk')+1]=`V'
		matrix `B'=nullmat(`B') \ `b'
		local j=`j'+1
	}

	matrix colnames `VV'= `newname'
	matrix rownames `VV'= `newname'
	matrix colnames `b0'= `newname'
	CalcMGE `B' `V'
	eret post `B' `V', esample(`touse')
	if "$constraints"!=""{
		capture{
			CalcConst $constraints
			di in gr _n "The following constraints have been applied to the system:"
			matrix dispCns
		}
	}
	quie gen byte `touse'=e(sample)
	quie predict double `ec' if `touse', eq(`ec')
	quie replace `ec'=$LRy-`ec'
	quie replace `r'=`r'^2 if `touse'
	quie sum `r' if `touse'
	scalar `sig2'=r(mean)
	ereturn scalar sigma=`sig2'
	ereturn scalar ll=`ll'
	ereturn scalar N=`N'
	ereturn scalar n_g=`n'
	ereturn scalar g_min=`g1'
	ereturn scalar g_avg=`g2'
	ereturn scalar g_max=`g3'
	ereturn local depvar="$SRy"
	ereturn local ivar="`ivar'"
	ereturn local tvar="`tvar'"
	ereturn local cmd="xtpmg"	
	ereturn local model="mg"
	quie est store mg, copy	title("Summarized mg estimates")
	eret post `b0' `VV', esample(`touse')
	if "$constraints"!=""{
		capture{
			CalcConst $constraints
			di in gr _n "The following constraints have been applied to the system:"
			matrix dispCns
		}
	}
	ereturn scalar sigma=`sig2'
	ereturn scalar ll=`ll'
	ereturn scalar N=`N'
	ereturn scalar n_g=`n'
	ereturn scalar g_min=`g1'
	ereturn scalar g_avg=`g2'
	ereturn scalar g_max=`g3'
	ereturn local ivar="`ivar'"
	ereturn local depvar="$SRy"
	ereturn local tvar="`tvar'"
	ereturn local cmd="xtpmg"	
	ereturn local model="MG"
	quie est store MG, copy title("Full mg estimates")
	if "`full'"==""{
		quie est restore mg
	}
	Display, level(`level')
end

program define EstDFE, eclass
	syntax [if] [in], EC(string) [Level(integer `c(level)')] 
	marksample touse
	tempname nl names sigma
	quie xtreg $SRy $LRy $LRx $SRx if `touse', level(`level') fe $cluster
	quie est store rDFE, copy title("Reduced form dfe estimates")
	scalar `sigma'=e(sigma)
	local nl
	local names
	foreach x of global LRx{
		local nl `nl' (-_b[`x']/_b[$LRy])	
		local names `names' "`ec':`x'"
	}

	local nl `nl' (_b[$LRy])
	local names `names' "SR:`ec'"
	foreach x of global SRx{
		local nl `nl' (_b[`x'])
		local names `names' "SR:`x'"
	}
	if "$nocons"==""{
		local nl `nl' (_b[_cons])
		local names `names' "SR:_cons"
	}
	quie nlcom `nl', level(`level') post
	tempname b V
	matrix `b'=r(b)
	matrix `V'=r(V)
	matrix colnames `b'=`names'
	matrix colnames `V'=`names'
	matrix rownames `V'=`names'
	eret post `b' `V', esample(`touse')

// Handle any constraints. However, like reg3, this will
// fail if the unconstrained model is not identified since these constraints
// are applied post estimation.
// Note: The displayed log-likelihood is from the UNrestricted model
	
	if "$constraints"!=""{
		CalcConst $constraints
		di in gr _n "The following constraints have been applied to the system:"
		matrix dispCns
	}

	eret local cmd="xtpmg" 
	eret local model="fe"
	eret scalar sigma=`sigma' 
	quie est store DFE, title("Dynamic fixed effects estimates")
	Display, level(`level')
end


program define CalcConst
	args constraint
	tempname A bc C IAR j R Vc touse
	matrix makeCns `constraint'
	matrix `C' = get(Cns)
	local cdim = colsof(`C')
	local cdim1 = `cdim' - 1
	matrix `R' = `C'[1...,1..`cdim1']
	matrix `A' = syminv(`R'*get(VCE)*`R'')
	local a_size = rowsof(`A')
	scalar `j' = 1
	while `j' <= `a_size' {
		if `A'[`j',`j'] == 0 {
			error 412
		} 
		scalar `j' = `j' + 1
	}
	matrix `A' = get(VCE)*`R''*`A'
	matrix `IAR' = I(colsof(get(VCE))) - `A'*`R'
	matrix `bc' = get(_b) * `IAR'' + `C'[1...,`cdim']'*`A''
	matrix `Vc' = `IAR' * get(VCE) * `IAR''
	gen byte `touse' = e(sample)
	eret post `bc' `Vc' `C', esample(`touse')
end

program define CalcMGE
	args b V
	tempname n tmp names j touse rec_n 
	local n=rowsof(`b')
	local names: colfullnames `b'
	scalar `rec_n'=1/`n'
	matrix `tmp'=`b'-J(`n',1,1)#(J(1,`n',`rec_n')*`b')
	matrix coleq `tmp'=:
	matrix roweq `tmp'=:

// JASA 1999 paper has a typo - the correct variance is below

	matrix `V'=`tmp''*`tmp'/(`n'*(`n'-1))
	matrix `b'=J(1,`n',`rec_n')*`b'
	matrix rownames `b'="MGE"
	matrix colnames `b'=`names'
	matrix rownames `V'=`names'
	matrix colnames `V'=`names'	
end



program define Display
	syntax [,Level(integer `c(level)')]
	
	if "`e(model)'"=="pmg" || "`e(model)'"=="PMG"{
		#delimit ;
		di _n in gr "Pooled Mean Group Regression";
		di in gr "(Estimate results saved as " in ye e(model) in gr ")";
      	di _n in gr "Panel Variable (i): " in ye abbrev(e(ivar),12)
                _col(49) in gr "Number of obs" _col(68) "="
                _col(70) in ye %9.0f e(N) ;
      	di in gr "Time Variable (t): " in ye abbrev(e(tvar),12) in gr
		_col(49) "Number of groups " _col(68) "="
                _col(70) in ye %9.0g e(n_g) ;
      	di in gr _col(49) in gr "Obs per group: min" _col(68) "="
                _col(70) in ye %9.0g e(g_min) ;
      	di in gr _col(64) in gr "avg" _col(68) "="
                _col(70) in ye %9.1f e(g_avg) ;
      	di in gr _col(64) in gr "max" _col(68) "="
                _col(70) in ye %9.0g e(g_max) _n ;
      	di in gr _col(49) "Log Likelihood" _col(68) "="
                _col(70) in ye %9.0g e(ll) ;
		#delimit cr
	}
	if "`e(model)'"=="fe"{
		quie est restore DFE
		if "$cluster"!=""{
			di _n in smcl in gr "{hline 78}"
			di in ye "Standard errors adjusted with " "$cluster" " option."
		}		
		#delimit ;
		di in smcl in gr "{hline 78}";
      	di in gr "Dynamic Fixed Effects Regression: " in ye "Estimated Error Correction Form";
		di in gr "(Estimate results saved as " in ye "DFE" in gr ")";
		di in smcl in gr "{hline 78}";

		#delimit cr
	}
	if "`e(model)'"=="mg" || "`e(model)'"=="MG"{
		#delimit ;	
		di _n in smcl in gr "{hline 78}";
		di in gr "Mean Group Estimation: " in ye "Error Correction Form";
		di in gr "(Estimate results saved as " in ye e(model) in gr ")";
		di in smcl in gr "{hline 78}";
		#delimit cr
	}
	eret disp, level(`level')
end

