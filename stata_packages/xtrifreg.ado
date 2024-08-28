
*! 1.0 Nicolai T. Borgen 12February2016
*! xtrifreg 

program define xtrifreg, eclass sortpreserve 
	
	version 9		
	
	syntax varlist [if] [in] [aw fw iw],	///
		[KErnop(string)]	      			///
		[Width(real 0.0)] 	    		  	///
		[Quantile(real 0.5)]				///
		FE 									///
		I(varlist) 							///
		[NORobust							///
		BOotstrap							///
		CLUSTERBOotstrap					///
		REPS(integer 50)]

	if "`bootstrap'"=="bootstrap" & "`clusterbootstrap'"=="clusterbootstrap" {
		di in red "Can't use both bootstrap and clusterbootstrap option at the same time"
		exit 198
		}
	if ("`bootstrap'"=="bootstrap" | "`clusterbootstrap'"=="clusterbootstrap") & "`norobust'"=="norobust" {
		di in red "Can't use both bootstrap/clusterbootstrap and norobust option at the same time"
		exit 198
		}
	if ("`bootstrap'"=="bootstrap" | "`clusterbootstrap'"=="clusterbootstrap") & `reps'<2 {
		di in red "Number of reps must be at least 2"
		exit 198
		}
			
	tokenize `varlist'
		local y `1'
		macro shift
		local rest `*'
	
	if `quantile'<1 & `quantile'>0 {
		local quantile=`quantile'*100
		}

	tempvar B VCE VCEmata se `rest2' eval density rify evalb densityb rifyb
	
	if "`norobust'"=="norobust" {
		local robust ""
		}
	
	if "`norobust'"!="norobust" & "`bootstrap'"!="bootstrap" & "`clusterbootstrap'"!="clusterbootstrap" {
		local robust "robust"
		}
	
	if "`clusterbootstrap'"=="clusterbootstrap" {
		local clusterbo "cluster(`i')"
		}
	
	if "`kernop'"=="" {
		local kernop "gaussian"
		}
	
	local exp_no_eq = regexr("`exp'", "=", "")

	if "`weight'" == "" {
		local exp "=1.0"
		local weight "aweight"
		}
	
	marksample touse
	markout `touse' `varlist' `exp_no_eq'
		
	RIF `width' `kernop' `y' `rify' `eval' `density' 100 `quantile' "`weight'`exp'" `touse'

	qui xtreg `rify' `rest' if `touse' [`weight' `exp'], i(`i') fe `robust'
		ereturn local depvar "rif_`quantile'"
		est sto UQR
		
	if "`bootstrap'"!="bootstrap" & "`clusterbootstrap'"!="clusterbootstrap" {
		est replay
		cap est drop UQR
		}

	if "`bootstrap'"=="bootstrap" | "`clusterbootstrap'"=="clusterbootstrap" {
			
		nois _dots 0, title("Bootstrap xtrifreg") reps(`reps')
		
		forvalues r=1/`reps' {
		
			preserve

				qui bsample if `touse', `clusterbo'
						
				RIF `width' `kernop' `y' `rifyb' `evalb' `densityb' 100 `quantile' "`weight'`exp'" `touse'
				
				qui xtreg `rifyb' `rest' if `touse' [`weight' `exp'], i(`i') fe `robust'
					
					matrix `se'=nullmat(`se')\e(b)

			restore
			
			_dots `r' 0
				
			}
			
		mata `VCEmata'=st_matrix("`se'")
		mata st_matrix("`VCE'", variance(`VCEmata'))
		matrix colnames `VCE' = `rest' _cons
		matrix rownames `VCE' = `rest' _cons
		qui est restore UQR
		RIFREPOST `VCE'
		ereturn local depvar "rif_`quantile'"
		ereturn local vce "bootstrap"
		ereturn local vcetype "Bootstrap"
		qui est sto UQR
		qui est restore UQR
		est replay 
		qui est drop UQR
		}
	
										
end

capture program drop RIF
program RIF, 
	args width kernop y  rif eval density steps quantile weightexp touse
	tempvar quantiles indicator 
	pctile `quantiles'=`y' [`weightexp'] if `touse', nq(`steps')
	kdensity `y' if `touse' [`weightexp'], at(`quantiles') kernel(`kernop') bwidth(`width') generate(`eval' `density') nograph
	qui generate `indicator'=`y'<`quantiles'[`quantile'] if `touse' 	// Firpo, et al. (2009) uses less than (not less than or equal).
	qui generate `rif'=`quantiles'[`quantile']+(((`quantile'/100)-`indicator')/`density'[`quantile'])  if `touse' 
end

capture program drop RIFREPOST
program RIFREPOST, eclass
	ereturn repost V = `1'
end
