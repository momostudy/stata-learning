*! version 2.0  Jun 2023
program define Display

	syntax , [Level(cilevel)]
	
	di
	if "`censor'" == "" & "`quadratic'" == "" {
		di in smcl as text "Censored Quadratic AIDS model"
		di in smcl as text "{hline 20}"
	}
	else if "`quadratic'" == "" & "`censor'" == "nocensor" {
		di in smcl as text "Quadratic AIDS model"
		di in smcl as text "{hline 20}"
	}
	else if "`censor'" == "" {
		di in smcl as text "Censored AIDS model"
		di in smcl as text "{hline 20}"
	}
	else {
		di in smcl as text "AIDS model"
		di in smcl as text "{hline 10}"
	}
	di as text "Number of obs          = " as res %10.0g `=e(N)'
	di as text "Number of demographics = " as res %10.0g `=e(ndemos)'
	di as text "Alpha_0                = " as res %10.0g `=e(anot)'
	di as text "Log-likelihood         = " as res %10.0g `=e(ll)'
	di
	
	_coef_table, level(`level')
	
end

program define quaidsce_c, eclass

	version 12

	syntax varlist [if] [in] ,					///
		  ANOT(real)						///
		  REPS(real)						///
		[ LNEXPenditure(varlist min=1 max=1 numeric) 		///
		  EXPenditure(varlist min=1 max=1 numeric) 		///
		  PRices(varlist numeric)				///
		  LNPRices(varlist numeric) 				///
		  DEMOgraphics(varlist numeric)				///
		  noQUadratic 						///
		  noCEnsor   ///
		  INITial(name) noLOg Level(cilevel) Method(name) * ] 
		  
		  
	local shares `varlist'
	
	if "`options'" != "" {
		di as error "`options' not allowed"
		exit 198
	}
	
	if "`prices'" != "" & "`lnprices'" != "" {
		di as error "cannot specify both {cmd:prices()} and "	///
			as error "{cmd:lnprices()}"
		exit 198
	}
	if "`prices'`lnprices'" == "" {
		di as error "must specify {cmd:prices()} or {cmd:lnprices()}"
		exit 198
	}
	
	if "`expenditure'" != "" & "`lnexpenditure'" != "" {
		di as error "cannot specify both {cmd:expenditure()} "	///
			as error "and {cmd:lnexpenditure()}"
		exit 198
	}
	if "`expenditure'`lnexpenditure'" == "" {
		di as error						///
"must specify {cmd:expenditure()} or {cmd:lnexpenditure()}"
		exit 198
	}
	
	
	local allshares `shares'
	local neqn : word count `shares'
	if `neqn' < 3 {
		di as error "must specify at least 3 expenditure shares"
		exit 498
	}
	
	if `=`:word count `prices'' + `:word count `lnprices''' != `neqn' {
		if "`prices'" != "" {
			di as error "number of price variables must "	///
				as error "equal number of equations "	///
				as error "(`neqn')"
		}
		else {
			di as error "number of log price variables "	///
				as error "must equal number of "	///
				as error "equations (`neqn')"
		}
		exit 498
	}

	
	marksample touse
	markout `touse' `prices' `lnprices' `demographics'
	markout `touse' `expenditure' `lnexpenditure'


	local i 1
	while (`i' < `neqn') {
		local shares2 `shares2' `:word `i' of `shares''
		local `++i'
	}
	
	// Check whether variables make sense
	if "`censor'" == "nocensor" {
		tempvar sumw
		egen double `sumw' = rsum(`shares') if `touse'
		cap assert reldif(`sumw', 1) < 1e-4 if `touse'
		if _rc {
			di as error "expenditure shares do not sum to one"
			exit 499
		}	
	}
	
	if "`censor'" == "" {
		if "`demographics'" == "" {
			di as error "at least one demographic variable is needed for censoring correction"
			exit 499
		}	
	}

	if "`prices'" != "" {
		local usrprices 1
		local lnprices
		foreach x of varlist `prices' {
			summ `x' if `touse', mean
			if r(min) <= 0 {
				di as error "nonpositive value(s) for `x' found"
				exit 499
			}
			tempvar ln`x'
			qui gen double `ln`x'' = ln(`x') if `touse'
			local lnprices `lnprices' `ln`x''
		}
	}
	if "`expenditure'" != "" {
		local usrexpenditure 1
		summ `expenditure' if `touse', mean
		if r(min) <= 0 {
			di as error "nonpositive value(s) for "		///
				as error "`expenditure' found"
			exit 499
		}
		tempvar lnexp
		qui gen double `lnexp' = ln(`expenditure') if `touse'
		local lnexpenditure `lnexp'
	}
	
	
	if "`quadratic'" == "noquadratic" {
		local np = 2*(`neqn'-1) + `neqn'*(`neqn'-1)/2
		local np2 = 2*(`neqn') + `neqn'*(`neqn'-1)/2
	}
	else {
		local np = 3*(`neqn'-1) + `neqn'*(`neqn'-1)/2
		local np2 = 3*(`neqn') + `neqn'*(`neqn'-1)/2
	}
	
	
	
	if "`demographics'" == "" {
		local demos "nodemos"
		local demoopt ""
		local ndemos = 0
	}
	else {
		local demos ""
		local demoopt "demographics(`demographics')"
		local ndemos : word count `demographics'
		local np = `np' + `ndemos'*(`neqn'-1) + `ndemos'
		local np2 = `np2' + `ndemos'*(`neqn'-1) + `ndemos'
	}
	
	if "`initial'" != "" {
		local rf = rowsof(`initial')
		local cf = colsof(`initial')
		if `rf' != 1 | `cf' != `np' {
			di "Initial vector must be 1 x `np'"
			exit 503
		}
		else {
			local initialopt initial(`initial')
		}
	}
	
		if "`method'" == "" {
		local estimator "ifgnls"
		}
		else {
			local estimator `method'
		}

		//First stage
		capture drop cdf* pdf* du*
		local pdf
		local cdf
		local du
		
		if "`censor'" == "nocensor" {
			foreach x of varlist `shares' {
				qui gen pdf`x'=0
				qui gen cdf`x'=1
				qui gen du`x'=1
				local pdf `pdf' pdf`x'
				local cdf `cdf' cdf`x'
			}
		}
		else {
			local np_prob : word count `lnprices' `lnexp' `demographics' intercept
			local zvar `lnprices' `lnexp' `demographics' 
			local nprob M `demographics' cons

			mat tau=J(1,`np_prob',0)
			mat setau=J(`np_prob'*`neqn',`np_prob'*`neqn',0)
			local i=1
			foreach x of varlist `shares' {
				summ `x' if `touse', mean
				if r(min) > 0 {
				di as error "no censoring for `x' found"
				exit 499
				}
				tempvar z`x' 
				qui gen double `z`x'' = 1 if `x' > 0  & `touse'
				qui replace `z`x'' = 0 if `x' == 0  & `touse'
				qui gen pdf`i'=0
				qui gen cdf`i'=1
			
				summ `z`x'' if `touse', mean
				if r(min) == 0 {
				qui probit `z`x'' `zvar'
			
				tempname loc
				if `i'==1 {
					mat tau= e(b)'
					mat setau[1,1]= e(V)
				}
				else {
					mat tau=tau \ e(b)'
					local loc = `np_prob'*(`i'-1)+1
					mat setau[`loc',`loc'] = e(V)
				}
				quietly predict du`i'
			
				if e(N) < _N {
				di as error "at least one variable completely predicts probit outcome, check your data"
				exit 499
				}
				qui replace pdf`i'= normalden(du`i')
				qui replace cdf`i'= normal(du`i')
				}
				local pdf `pdf' pdf`i'
				local cdf `cdf' cdf`i'
				local du `du' du`i'
				local i=`i'+1
			}
		}
		
		if "`censor'" == "nocensor" {
		local shares `shares2' 
		local np2= `np'
		local neqn2=`=`neqn'-1'
		}
		else {
		local np2= `np2' + `neqn' //adding n deltas
		local neqn2 `neqn'
		}
		
		
	qui nlsur __quaidsce @ `shares' if `touse',				///
		lnp(`lnprices') lnexp(`lnexpenditure') cdfi(`cdf') pdfi(`pdf') a0(`anot')	///
		nparam(`np2') neq(`neqn2') `estimator' noeqtab nocoeftab	///
		`quadratic' `options' `censor' `demoopt'  `initialopt' `log' 


	// do delta method to get cov matrix

	tempname b bfull V Vfull Vn Delta aux auxt aux0 Vfullc bfullc
	mat `b' = e(b)
	mat `V' = e(V)

	mata:_quaidsce__fullvector("`b'", `neqn', "`quadratic'", `ndemos', "`bfull'", "`censor'")
	mata:_quaidsce__delta(`neqn', "`quadratic'", "`censor'", `ndemos', "`Delta'")
	mat `Vn' = `Delta'*`V'*`Delta''
	
	tempname alpha beta gamma lambda delta eta rho ll
	mata:_quaidsce__getcoefs("`b'", `neqn', "`quadratic'", "`censor'", `ndemos', 	///
			"`alpha'", "`beta'", "`gamma'", "`lambda'", "`delta'",	///
			"`eta'", "`rho'")		
	
	mat `Vfull' = `Vn'

	
	**************
	
	
	if "`censor'" == "" {
	mat `bfullc' = `bfull' , tau'
	mat `aux' = J(rowsof(`Vfull'),rowsof(setau),0)
	mat `auxt' = J(rowsof(setau),rowsof(`Vfull'),0)
	mat `auxt' = `auxt' , setau
	mat `aux' = `Vfull' , `aux'
	mat `Vfullc' = `aux' \ `auxt'
	}
	else {
	mat `bfullc' = `bfull'
	mat `Vfullc' = `Vfull'
	}
		
	
	forvalues i = 1/`neqn' {
		local namestripe `namestripe' alpha:alpha_`i'
	}
	forvalues i = 1/`neqn' {
		local namestripe `namestripe' beta:beta_`i'
	}
	forvalues j = 1/`neqn' {
		forvalues i = `j'/`neqn' {
			local namestripe `namestripe' gamma:gamma_`i'_`j'
		}
	}
	if "`quadratic'" == "" {
		forvalues i = 1/`neqn' {
			local namestripe `namestripe' lambda:lambda_`i'
		}
	}
	
	
	if "`censor'" == "" {
		forvalues i = 1/`neqn' {
			local namestripe `namestripe' delta:delta_`i'
		}
	}

	if `ndemos' > 0 {
		foreach var of varlist `demographics' {
			forvalues i = 1/`neqn' {
				local namestripe `namestripe' eta:eta_`var'_`i'
			}
		}
		foreach var of varlist `demographics' {
			local namestripe `namestripe' rho:rho_`var'
		}
	}
	if "`censor'" == "" {
		forvalues i = 1/`neqn' {
			forvalues j = 1/`neqn' {
				local namestripe `namestripe' tau:p`j'_`i'
			}
			foreach x in `nprob' {
				local namestripe `namestripe' tau:`x'_`i'
			}
		}
	}
	
	***ELASTICITIES***

	
	//AVERAGES, INDEXES, PREDICTIONS
	local i 1
		tempname lnpr
		local lnpr ""
		foreach var of varlist `lnprices' {
			local lnp`i' `var'
			local lnpr `lnpr' `lnp`i''
			local `++i'
		}
	local i 1
		tempname w_
		local w_ ""
		foreach var of varlist `shares' {
			local w_`i' `var'
			local w_ `w_' `w_`i''
			local `++i'
		}
	if "`censor'" == "" {
		foreach x of varlist `w_' `lnpr' `lnexpenditure' `demographics' `cdf' `pdf' `du' {
		qui sum `x'
		scalar `x'm=r(mean)
		}
		}
		else {
		foreach x of varlist `w_' `lnpr' `lnexpenditure' `demographics' {
		qui sum `x'
		scalar `x'm=r(mean)
		}
	}

	*JCSH discutir con Tocayo
	tempname lnpindex
	scalar `lnpindex'= `anot'
	forvalue i=1/`neqn' {	
		scalar `lnpindex'= `lnpindex' + `alpha'[1,`i']*`lnp`i''m
		forvalue j=1/`neqn' {
			if `j'>=`i' {
				scalar `lnpindex'= `lnpindex' + 0.5*(`gamma'[`j',`i']*(`lnp`i''m*`lnp`j''m))
			}
			 else {
				scalar `lnpindex'= `lnpindex' + 0.5*(`gamma'[`i',`j']*(`lnp`i''m*`lnp`j''m))
			}
		}
	}
	
	*GENERAR GSUM'i''j' PARA TODAS LAS COMBINACIONES
	*JCSH Previously 
	/*forvalue i=1/`neqn' {	
			tempname gsum`i'	
			scalar `gsum`i''= 0
			forvalue ii=1/`neqn' {
				scalar `gsum`i''= `gsum`i'' + `gamma'[`ii',`i']*`lnp`i''m 
				}
				}*/

	forvalue j=1/`neqn' {	
		tempname gsum`j'	
		scalar `gsum`j''= 0
		forvalue l=1/`neqn' {
		scalar `gsum`j''= `gsum`j'' + `gamma'[`j',`l']*`lnp`l''m 
		}
		}

				

	//When quadratics
	if "`quadratic'" == "" {
		tempname bofp 
		scalar `bofp'= `beta'[1,1]*`lnp1'm		
		forvalues i = 2/`neqn' {		
			 scalar `bofp'= `bofp' + `beta'[1,`i']*`lnp`i''m
		}
	}
	
	//When demographics
	if `ndemos' > 0 {			
		tempname cofp mbar
		*scalar `cofp'= 1 //It is OK to set 1 because below we set a multiplication JCSH previously
		scalar `cofp'= 0 //To add cofp`i' below
		scalar `mbar'= 1 //It is OK because I need to add a "1"
		
		forvalue i=1/`neqn' {
			tempname betanz`i' cofp`i'
			scalar `betanz`i''=`beta'[1,`i']
			scalar `cofp`i''= 0
		}

		local j = 1
		foreach var of varlist `demographics' {	
			forvalue i=1/`neqn' {
				 scalar `cofp`i''= `cofp`i''+(`var'm*`eta'[`j',`i']) 
				 scalar `betanz`i''=`betanz`i''+(`var'm*`eta'[`j',`i']) 
									}			
		scalar `mbar'= `mbar' + (`rho'[1,`j']*`var'm)
		local `++j'
		}
		
		forvalue i=1/`neqn' {
				scalar `cofp`i''= `cofp`i''*`lnp`i''m
				scalar `cofp'= `cofp'+`cofp`i''
			}
	}
	
	//FUNCTION EVALUATOR (PREDICTED SHARE)
	
	forvalues i = 1/`neqn' {
		//When censor
		if "`censor'" == "" {
		 scalar we`i' = `w_`i''m*cdf`i'm + `delta'[1,`i']*pdf`i'm
		}
		else {
		 scalar we`i' = `w_`i''m	
		}
	}
	
	
	****INCOME****
	*tempname elas_i
	mat elas_i = J(1,`neqn',0)
	forvalues i = 1/`neqn' {
		if `ndemos' == 0 {
			local ie`i' = (1+`beta'[1,`i']/`w_`i''m)
			if "`quadratic'" == "" {
				 local ie`i'= (1+1/`w_`i''m*(`beta'[1,`i']+2*`lambda'[1,`i']/exp(`bofp')*(`lnexp'm-`lnpindex')))
			}
		}
		else {
			global ie`i' = 1+`betanz`i''/`w_`i''m
			if "`quadratic'" == "" {
				local ie`i'= (1+1/`w_`i''m*(`betanz`i''+2*`lambda'[1,`i']/exp(`bofp')/exp(`cofp')*(`lnexp'm-`lnpindex'-ln(`mbar'))))
			}
		}
			//When censor
		local loc = `np_prob'*(`i'-1)+`neqn'+1
		if "`censor'" == "" {
			local ie`i' = (1+1/we`i'*((cdf`i'm*((`ie`i''-1)*`w_`i''m))+tau[`loc',1]*pdf`i'm*(`w_`i''m-`delta'[1,`i']*du`i'm)))				
		}			 
	mat elas_i[1,`i'] = `ie`i''
	}
	
	*AJUSTAR LOS GSUM EN FUNCION DE LA ELASTICIDAD
	***UNCOMPENSATED***
	local k1 = 1
	local k2 = `neqn'* `neqn'
	mat elas_u = J(1,`k2',0)
	
	
	forvalues i = 1/`neqn' {
		forvalues j = 1/`neqn' {
		
		local de=cond(`i'==`j',1,0)
		
		if `ndemos' == 0 {
			//No demographics nor quadratic		
			local ue`i'`j' = (-`de'+1/`w_`i''m*(`gamma'[`i',`j']-(`beta'[1,`i']*(`alpha'[1,`j']+`gsum`j''))))	
						
			if "`quadratic'" == "" {
					//No demographics & quadratic		
					local ue`i'`j' = (-`de'+1/`w_`i''m*(`gamma'[`i',`j']-(`beta'[1,`i']+(2*`lambda'[1,`i']/exp(`bofp'))*(`lnexp'm-`lnpindex'))*(`alpha'[1,`j']+`gsum`j'')-(`beta'[1,`i']*`lambda'[1,`i']/exp(`bofp')*(`lnexp'm-`lnpindex')^2)))		
			}
		}
		else {	//Demographics no quadratic
				local ue`i'`j' = (-`de'+1/`w_`i''m*(`gamma'[`i',`j']-(`betanz`i'')*(`alpha'[1,`j']+`gsum`j'')))				
				if "`quadratic'" == "" {
					//Demographics & quadratic
					local ue`i'`j' = (-`de'+1/`w_`i''m*(`gamma'[`i',`j']-(`betanz`i''+(2*`lambda'[1,`i']/exp(`bofp')/exp(`cofp'))*(`lnexp'm-`lnpindex'-ln(`mbar')))*(`alpha'[1,`j']+`gsum`j'')-(`betanz`i''*`lambda'[1,`i']/exp(`bofp')/exp(`cofp')*(`lnexp'm-`lnpindex'-ln(`mbar'))^2)))
			}
		}
		//When censor
		local loc = `np_prob'*(`i'-1)+`j'
		if "`censor'" == "" {
			local ue`i'`j' = (-`de'+1/we`i'*(cdf`i'm*((`ue`i'`j''+`de')*`w_`i''m) + tau[`loc',1]*pdf`i'm*(`w_`i''m-`delta'[1,`i']*du`i'm)))
		}
	
	*JCSH revisar con tocayo: corroborar con tocayo la salida de mat elas_u
		
	mat elas_u[1,`k1'] = `ue`i'`j''
	local `++k1'		

	}
	}
	
	
	***COMPENSATED***
	local k1 = 1
	mat elas_c = J(1,`k2',0)
	forv i = 1/`neqn' {
	forv j = 1/`neqn' {  //JCSH revisar con tocayo esta me falta
		local ce`i'`j' = `ue`i'`j''+`ie`i''*`w_`j''m

	mat elas_c[1,`k1'] = `ce`i'`j''	
	local `++k1'
	
	}
	}
		
	***ALL TOGETHER IN THE MATRICES***
	if "`censor'" == "" {
		
	mat `bfullc' = `bfullc' , elas_i
	mat `aux0' = J(`neqn',`neqn',0)
	mat `aux' = J(rowsof(`Vfullc'),`neqn',0)
	mat `auxt' = J(`neqn',rowsof(`Vfullc'),0)
	mat `auxt' = `auxt' , `aux0'
	mat `aux' = `Vfullc' , `aux'
	mat `Vfullc' = `aux' \ `auxt'
	
	mat `bfullc' = `bfullc' , elas_u
	mat `aux0' = J(`k2',`k2',0)
	mat `aux' = J(rowsof(`Vfullc'),`k2',0)
	mat `auxt' = J(`k2',rowsof(`Vfullc'),0)
	mat `auxt' = `auxt' , `aux0'
	mat `aux' = `Vfullc' , `aux'
	mat `Vfullc' = `aux' \ `auxt'
	
	mat `bfullc' = `bfullc' , elas_c
	mat `aux0' = J(`k2',`k2',0)
	mat `aux' = J(rowsof(`Vfullc'),`k2',0)
	mat `auxt' = J(`k2',rowsof(`Vfullc'),0)
	mat `auxt' = `auxt' , `aux0'
	mat `aux' = `Vfullc' , `aux'
	mat `Vfullc' = `aux' \ `auxt'
	}
	
	forvalues i = 1/`neqn' {
		local namestripe `namestripe' ELAS_INC:e_`i'
	}
	forvalues j = 1/`neqn' {
		forvalues i = 1/`neqn' {
			local namestripe `namestripe' ELAS_UNCOMP:e_`i'_`j'
		}
	}
	forvalues j = 1/`neqn' {
		forvalues i = 1/`neqn' {
			local namestripe `namestripe' ELAS_COMP:e_`i'_`j'
		}
	}
	
	*************************
	
	capture drop du* cdf* pdf*
	
	mat colnames `bfullc' = `namestripe'
	mat colnames `Vfullc' = `namestripe'
	mat rownames `Vfullc' = `namestripe'
				
	scalar `ll' = e(ll)
	local vcetype	`e(vcetype)'
	local clustvar	`e(clustvar)'
	local vcer	`e(vce)'
	local nclust	`e(N_clust)'

	qui count if `touse'
	local capn = r(N)
	
	eret post `bfullc' `Vfullc', esample(`touse')	
	
	eret matrix alpha	= `alpha'
	eret matrix beta	= `beta'
	eret matrix gamma	= `gamma'
	if "`quadratic'" == "" {
		eret matrix lambda = `lambda'
	}
	else {
		eret local quadratic	"noquadratic"
	}	
	if "`censor'" == "" {
		eret matrix delta = `delta'
		mat tau = tau'
		eret matrix tau tau
		eret local cdf `cdf'
		eret local pdf `pdf'
	}
	else {
		eret local censor	"nocensor"
		drop cdf* pdf*
	}
	if `ndemos' > 0 {
		eret matrix eta = `eta'
		eret matrix rho = `rho'
		eret local demographics `demographics'
		eret scalar ndemos = `ndemos'
	}
	else {
		eret scalar ndemos = 0
	}
	
	eret matrix elas_i	elas_i
	eret matrix elas_u	elas_u
	eret matrix elas_c	elas_c
	
	eret scalar N		= `capn'
	eret scalar ll		= `ll'
	
	eret scalar anot	= `anot'
	eret scalar reps	= `reps'
	eret scalar ngoods	= `neqn'

	if "`usrprices'" != "" {
		eret local prices	`prices'
	}
	else {
		eret local lnprices	`lnprices'
	}
	if "`usrexpenditure'" != "" {
		eret local expenditure	`expenditure'
	}
	else {
		eret local lnexpenditure `lnexpenditure'
	}

	eret local lhs		"`allshares'"
	eret local demographics	"`demographics'"
	
	eret local vcetype	`vcetype'
	eret local clustvar	`clustvar'
	eret local vcer		`vce'
	if "`nclust'" != "" {
		eret scalar N_clust	= `nclust'
	}
	
	eret local predict	"quaidsce_p"
	eret local cmd 		"quaidsce"
	
	Display, level(`level')

end