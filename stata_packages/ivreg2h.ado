*! ivreg2h  1.1.08  26sep2024  cfb/mes
*! cloned from
*! xtivreg2 1.0.13 28Aug2011
*! author mes
*! 1.0.4:  reinstate xtivreg2 code to fix up vnames
*! 1.0.5:  deal with inadequate number excluded insts, logic driving est table
*! 1.0.6:  introduce gen option to generate and leave behind generated instruments, with stub and replace option
*!         fix e(cmd) and e(cmdline) macros
*! 1.0.7:  Federico Belotti bugfix, -gen- option with multiple endogenous corrected
*! 1.0.8:  handle parsing with MES parse_iv
*! 1.0.9:  allow FE option
*! 1.1.00: Bug fix - orthog(.) would crash in gen-IV-only estimation
*!         Added nooutput option and nooutput calls to ivreg2 so that collinearity and duplicates msgs appear
*!         Removed extraneous `options' macro from calls to ivreg2.  Added check for ivreg210.
*!         Bug fix - needed capture before drop if gen(,replace) option used.
*!         Added saved xtmodel macro (="fe" if FE, ="" if not panel data estimation)
*! 1.1.01: Bug fix - version control so that new ivreg2 calls correct ivreg2x as appropriate
*!         Promoted required Stata to version 9 so that ivreg29 or higher used ("partial" was "fwl" in ivreg28)
*!         Removed extraneous ivreg2x check code and misc other extraneous code.
*!         Bug fix - wouldn't run under Stata 9 because of extraneous version 10.1 statement.
*! 1.1.02: Was not passing * (`options') on to ivreg2, which meant that options such as robust were ignored
*! 1.1.03: Add Z() option to select generated instruments
*! 1.1.04: Disable execution in absence of included endogenous
*! 1.1.05: correct refs to feest so that data are not centered in non-FE models, and 
*!         gen insts can be recovered
*! 1.1.06: fe option disabled. Should be implemented in ivreg2hfe.
*! 1.1.07: correct handling of excluded insts in genextinst code
*! 1.1.08: changed all tsunab, tsrevar to fvunab, fvrevar to permit FV syntax

program define ivreg2h, eclass byable(recall)
	version 9
	local lversion 01.1.07
// will be overridden by ivreg2 e(version) for ivreg2_p

// Needed for call to ivreg2
	local ver = _caller()
	local ver : di %6.1f `ver'

	if replay() {
		syntax [, FIRST FFIRST rf Level(integer $S_level) NOHEader NOFOoter /*
			*/ EForm(string) PLUS VERsion]

		if "`version'" != "" & "`first'`ffirst'`rf'`noheader'`nofooter'`eform'`plus'" != "" {
			di as err "option version not allowed"
			error 198
		}
		if "`version'" != "" {
			di in gr "`lversion'"
			ereturn clear
			ereturn local version `lversion'
			ereturn local cmd "ivreg2h"
			exit
		}
		if `"`e(cmd)'"' != "ivreg2h"  {
			error 301
		}
	}
// end replay()
	else {

		local cmdline "ivreg2h `*'"
// disable fe, fd [ /* FE   fd */ 
		syntax [anything(name=0)] [if] [in] [aw fw pw iw/] , [ /// 
				Ivar(varname) Tvar(varname) first ffirst rf ///
				savefirst SAVEFPrefix(name) saverf SAVERFPrefix(name) CLuster(varlist)	///
				orthog(string) ENDOGtest(string) REDundant(string) PARTIAL(string)		///
				BW(string) SKIPCOLL														///
				GEN1 GEN2(string) NOOUTput Z(string)									///
				* ]

// ms - `gen'=1 if ivreg2h leaves behind generated instruments, =0 if not
		local gen = ("`gen1'`gen2'"~="")

		parse_iv `*'
// di in r "`options'"
		local endo `r(endo)'
		local inexog `r(inexog)'
		local lhs `r(depvar)'
		local exexog `r(exexog)'

// stop if no endo
		if "`endo'" == "" {
			di as err _n "No endogenous regressors specified" 
			error 198
		}
// validate fe option: require panel
// cfb 1.1.05: null string if !fe!
// cfb 1.1.06: disable fe option
		loc feest ""
/*
		capt xtset
		if "`fe'" == "fe" & _rc>0 {
			xtset
			error 198
		}
// macro saved if not ""
		local xtmodel "`fe'"
*/						
		local ivreg2_cmd "ivreg2"
		tempname regest
		capture _estimates hold `regest', restore
		capture `ivreg2_cmd', version
		if _rc != 0 {
di as err "Error - must have ivreg2 version 2.1.15 or greater installed"
		exit 601
		}
		local vernum "`e(version)'"
		loc lversion `vernum'
		capture _estimates unhold `regest'

//		if "`gmm2s'" != "" & "`exexog'" == "" {
// di as err "option -gmm2s- invalid: no excluded instruments specified"
//			exit 102
//		}

* If first requested, also needs to request savefirst or savefprefix and set drop flag
		if "`first'" != "" & "`savefirst'`savefprefix'" == "" {
			local savefirst "savefirst"
			local dropfirst "dropfirst"
		}
		if "`savefirst'" != "" & "`savefprefix'" == "" {
			local savefprefix "_xtivreg2_"
		}

* If rf requested, also needs to request saverf or saverfprefix and set drop flag
		if "`rf'" != "" & "`saverf'`saverfprefix'" == "" {
			local saverf "saverf"
			local droprf "droprf"
		}
		if "`saverf'" != "" & "`saverfprefix'" == "" {
			local saverfprefix "_xtivreg2_"
		}

		tempvar wvar
		if "`weight'" !="" {
			local wtexp `"[`weight'=`exp']"'
			gen double `wvar'=`exp'
		}
		else {
			gen long `wvar'=1
		}

// di in r "Z = `z'" _n

* Begin estimation blocks
			loc qnoout nooutput
			marksample touse
			markout `touse' `lhs' `inexog' `exexog' `endo' `cluster' /* `tvar' */, strok
//			tsrevar `lhs', substitute
			fvrevar `lhs', substitute
			local lhs_t "`r(varlist)'"
//			tsrevar `inexog', substitute
			fvrevar `inexog', substitute
			local inexog_t "`r(varlist)'"
// di in r "inexog_t `inexog_t'"
			loc n_inex : word count `inexog_t'
// 1.1.03
			if "`z'" == "" {
				loc z `inexog'
			}
// 1.1.06
			loc zts `z'
			local zts : subinstr local zts "." "_", all	
// di in r "z: `z'"
// di in r "`zts: `zts'"
//			tsrevar `z', substitute
			fvrevar `z', substitute
//			local z_t "`r(varlist)'"
			local zlist_t "`r(varlist)'"
// di in r "zlist_t: `zlist_t'"
// di in r "n_inex `n_inex'" _n
//			tsrevar `endo', substitute
			fvrevar `endo', substitute
			local endo_t "`r(varlist)'"
			loc n_endo : word count `endo_t'
// di in r "n_endo `n_endo'"
//			tsrevar `exexog', substitute
			fvrevar `exexog', substitute
			local exexog_t "`r(varlist)'"
			loc n_exex : word count `exexog_t'
// di in r "n_exex `n_exex'"
//			tsrevar `orthog', substitute
			fvrevar `orthog', substitute
			local orthog_t "`r(varlist)'"
//			tsrevar `endogtest', substitute
			fvrevar `endogtest', substitute
			local endogtest_t "`r(varlist)'"
//			tsrevar `redundant', substitute
			fvrevar `redundant', substitute
			local redundant_t "`r(varlist)'"
//			tsrevar `partial', substitute
			fvrevar `partial', substitute
			local partial_t "`r(varlist)'"
			local npan1 0
// cfb ivreg2h: switch off noconstant for non-FE models
			local nocons 
			local dofminus 0
			
// begin FE code
/*			
			if "`fe'" == "fe" {
				qui xtset
				loc pv `r(panelvar)'

// di in r "lhs: `lhs_t'"
// di in r "inexog: `inexog_t'"
// di in r "endo: `endo_t'"
// di in r "exexog: `exexog_t'"
				su `lhs_t' `endo_t' `exexog_t' `inexog_t', mean

				qui reg `lhs_t' `endo_t' `exexog_t' `inexog_t' if `touse'
// compute number of panels in sample
				qui levelsof `pv' if e(sample)
				loc npan: word count `r(levels)'
//				di as err "`npan' panels in estimation"
				loc dofminus = `npan'
				loc nocons "nocons"

// casewise option in 1.0.9 (Jan2014) ensures that centering is done on the regression sample, and other
// observations are set to missing
di as err "pv `pv'"
				qui by `pv': center `lhs_t' `endo_t' `exexog_t' `inexog_t' if e(sample), casewise inplace 
				loc feest "Fixed Effects by(`pv'), `npan' groups"
			}
*/		
// end FE code
			
// preserve here, prior to first sort
// cfb disabled			preserve
		tempname b V S W firstmat touse2
	
// cfb check classical id status
		loc n_est 0
		if `n_exex' == 0 | `n_endo' > `n_exex' {
			if "`inexog_t'" == "" {
				di as res _n "No excluded instruments: standard IV model not estimable"
			}
			else {
				di as res _n "Too few excluded instruments: standard IV model not estimable"
			}
			cap est drop StdIV
		} 
		else {
		
// ---------------------------------------------------------------------------------------			
// COMPUTE STANDARD IV RESULTS IF EQUATION IS IDENTIFIED ---------------------------------
// ---------------------------------------------------------------------------------------	

			if "`nooutput'"=="" {
				di as res _n "Standard IV Results" _n "`feest'"
			}
// di in r "`lhs_t'"
// di in r "`inexog_t'"
// di in r "`endo_t'"
// di in r "`exexog_t'"
// ms
// changed `qq'(=qui) to nooutput option so that collinearity and duplicates messages reported
// added ver from _caller() so that ivreg2 called correct ivreg2x under version control.
			version `ver': `ivreg2_cmd' `lhs_t' `inexog_t' (`endo_t' = `exexog_t') `wtexp' if `touse', ///
						dofminus(`dofminus') `nocons' `first' `ffirst' `rf' ///
						savefprefix(`savefprefix') saverfprefix(`saverfprefix') ///
						cluster(`cluster') orthog(`orthog_t') endog(`endogtest_t') ///
						redundant(`redundant_t') partial(`partial_t') tvar(`tvar') bw(`bw') ///
						`qnoout' `options'

// Replace any time series locals with original time series names
// cfb
                        g byte `touse2' = `touse'

// Now fix main results
                        mat `b'       =e(b)
                        mat `V'       =e(V)
                        mat `S'       =e(S)
                        mat `W'       =e(W)
                        mat `firstmat'=e(first)
// Matrix column names to be changed
                        local l_cnames  : colnames `b'
                        local l_cnamesS : colnames `S'
                        local l_cnamesW : colnames `W'
                        local l_cnamesf : colnames `firstmat'
// Full list of names to change
                        local l_vnames   "`lhs'   `inexog'   `endo'   `exexog'"
                        local l_vnames_t "`lhs_t' `inexog_t' `endo_t' `exexog_t'"
// Macros to be fixed
                        local l_insts     "`e(insts)'"
                        local l_inexog    "`e(inexog)'"
                        local l_instd     "`e(instd)'"
                        local l_exexog    "`e(exexog)'"
                        local l_depvar    "`e(depvar)'"
                        local l_clist     "`e(clist)'"
                        local l_elist     "`e(elist)'"
                        local l_redlist   "`e(redlist)'"
                        local l_partial  "`e(partial)'"
// If any collinear or duplicates
                        local l_collin    "`e(collin)'"
                        local l_dups      "`e(dups)'"
                        local l_insts1    "`e(insts1)'"
                        local l_inexog1   "`e(inexog1)'"
                        local l_instd1    "`e(instd1)'"
                        local l_exexog1   "`e(exexog1)'"
                        local l_partial1  "`e(partial1)'"
                        foreach vn of local l_vnames {
                                tokenize `l_vnames_t'
                                local vn_t `1'
                                mac shift
                                local l_vnames_t `*'
                                local l_cnames  : subinstr local l_cnames    "`vn_t'" "`vn'"
                                local l_cnamesS : subinstr local l_cnamesS   "`vn_t'" "`vn'"
                                local l_cnamesW : subinstr local l_cnamesW   "`vn_t'" "`vn'"
                                local l_cnamesf : subinstr local l_cnamesf   "`vn_t'" "`vn'"
// Macro varlists
                                local l_insts   : subinstr local l_insts     "`vn_t'" "`vn'"
                                local l_inexog  : subinstr local l_inexog    "`vn_t'" "`vn'"
                                local l_instd   : subinstr local l_instd     "`vn_t'" "`vn'"
                                local l_exexog  : subinstr local l_exexog    "`vn_t'" "`vn'"
                                local l_partial : subinstr local l_partial   "`vn_t'" "`vn'"
                                local l_depvar  : subinstr local l_depvar    "`vn_t'" "`vn'"
                                local l_clist   : subinstr local l_clist     "`vn_t'" "`vn'"
                                local l_elist   : subinstr local l_elist     "`vn_t'" "`vn'"
                                local l_redlist : subinstr local l_redlist   "`vn_t'" "`vn'"
                                local l_collin  : subinstr local l_collin    "`vn_t'" "`vn'"
                                local l_dups    : subinstr local l_dups      "`vn_t'" "`vn'"
                                local l_insts1  : subinstr local l_insts1    "`vn_t'" "`vn'"
                                local l_inexog1 : subinstr local l_inexog1   "`vn_t'" "`vn'"
                                local l_instd1  : subinstr local l_instd1    "`vn_t'" "`vn'"
                                local l_exexog1 : subinstr local l_exexog1   "`vn_t'" "`vn'"
                                local l_partial1: subinstr local l_partial1  "`vn_t'" "`vn'"
                        }
                        mat colnames `b'       =`l_cnames'
                        mat colnames `V'       =`l_cnames'
                        mat rownames `V'       =`l_cnames'
                        mat colnames `S'       =`l_cnamesS'
                        mat rownames `S'       =`l_cnamesS'
                        mat colnames `W'       =`l_cnamesW'
                        mat rownames `W'       =`l_cnamesW'
                        mat colnames `firstmat'=`l_cnamesf'

                        ereturn post `b' `V', dep(`l_depvar') esample(`touse2') noclear
                        ereturn matrix S `S'
                        if ~matmissing(`W') {
                                ereturn matrix W `W'
                        }
                        if ~matmissing(`firstmat') {
                                ereturn matrix first `firstmat'
                        }
                        ereturn local insts    `l_insts'
                        ereturn local inexog   `l_inexog'
                        ereturn local instd    `l_instd'
                        ereturn local exexog   `l_exexog'
                        ereturn local partial  `l_partial'
                        ereturn local collin   `l_collin'
                        ereturn local dups     `l_dups'
                        ereturn local insts1   `l_insts1'
                        ereturn local inexog1  `l_inexog1'
                        ereturn local instd1   `l_instd1'
                        ereturn local exexog1  `l_exexog1'
                        ereturn local partial1 `l_partial1'
                        ereturn local depvar   `l_depvar'
                        ereturn local clist    `l_clist'
                        ereturn local elist    `l_elist'
                        ereturn local redlist  `l_redlist'
                        ereturn scalar sigma_e=e(rmse)
                        ereturn local xtmodel	"`xtmodel'"
//				est replay
				est store StdIV
				loc ++n_est
// Display output using ivreg2 replay mode
				if "`nooutput'"=="" {
// md
// added ver from _caller() so that ivreg2 called correct ivreg2x under version control.
					version `ver': `ivreg2_cmd', `first' `ffirst' `rf' `noheader' `nofooter' `plus' `levopt' `efopt' `dropfirst' `droprf'
				}
// ms
// For later use - any collinears or duplicates in standard IV estimation
				local collin_dups	"`l_collin' `l_dups'"
				
// cfb
// di as err "feest `feest'"
/*
				if "`feest'" != "" {
					di as err _n "Warning: variables have been centered"
					}
*/
					}	// end standard IV block

// ---------------------------------------------------------------------------------------				
// COMPUTE RESULTS FOR GENERATED INSTRUMENTS ONLY ----------------------------------------
// ---------------------------------------------------------------------------------------	

// Even if no excluded insts, must generate insts						
// Lewbel hetero instruments, based only on centered included exog in FSR
// Z() overrides list in inexog; expanded into z_t

// if eqn not identified, cannot retrieve e(inexog)
//  di as err "original inexog"
//  di as err "`e(inexog)'"
 				if `n_est' == 1 {
                	local l_inexog    "`e(inexog)'"
                }
                else {
                	local l_inexog `inexog'
                }
                local l_inexog : subinstr local l_inexog "." "_", all
//  di as err "new inexog"
//  di as err "`l_inexog'"
//  di as err "`inexog_t'""

/* 1.1.06: handled above, disable 
// if Z() specified, override; should check to see that Z is subset of X 
				loc zlist `inexog_t'
				if "`z'" != "" {
					loc zlist `z_t'
					loc zlist_t `z'
					local zlist_t : subinstr local z "." "_", all
// cfb 1.1.05: move zlist_t into zlist
                    loc zlist `zlist_t'
				}
*/				
//  di as err "zlist_t `zlist_t'"

// 1.1.06: must grab original z content to rename generated instruments if TS ops are used
//				loc n_inexog: word count `inexog_t'

// 1.1.06: refer to zlist_t
//				loc n_inexog: word count `zlist'
				loc n_inexog: word count `zlist_t'
				if `n_inexog' == 0 {
					di in red _n "Error: no Z variables available for construction of generated instruments." _n
					error 198
				}
				loc n_endo_t: word count `endo_t'
				loc geninst_t	
				loc geninst
				
				loc i 0		
// di as err "zlist `zlist'"
// di as err "zlist_t `zlist_t'"
// di as err "inexog_t `inexog_t'"
				foreach e of local endo_t {
// 1.1.06: revert to inexog_t tempvars
					qui reg `e' `inexog_t' if `touse'
//					qui reg `e' `zlist' if `touse'
					tempvar `e'_eps
					qui predict double ``e'_eps' if e(sample), residual
					loc ++i
					loc en: word `i' of `endo'
					local j 1
// 1.1.06: revert to zlist_t
// di in r "zlist_t: `zlist_t'"
//					foreach v of local inexog_t {
					foreach v of local zlist_t {
// Federico: added (and some lines commented) to allows correct naming 
// 			 in the case of more endo vars and to allow the -gen- option to work properly
// 						local vn: word `j' of `l_inexog' 
//						local vn: word `j' of `zlist_t'
						loc vn: word `j' of `zts'
 						tempvar z_`e'_`v'_eps
						su `v' if `touse', mean
						qui g double `z_`e'_`v'_eps' = (`v' - r(mean)) * ``e'_eps' if `touse'
						loc geninst_t "`geninst_t' `z_`e'_`v'_eps'"
// 1.0.6: pull name from zts
						loc geninst "`geninst' `en'_`vn'_g"
						local j = `j' + 1 
					}
				}

//  di "geninst and geninst_t (immediately after creation):"
//  di as err "`geninst'"
//  di as err "`geninst_t'"

// even though residuals are uncorrelated with the regressors used to generate them, 
// the product of residuals and the (centered) regressors are non-null
		if "`nooutput'"=="" {
			di as res _n "IV with Generated Instruments only" _n  "`feest'"
// list of original regressors here		
//			di as res "Instruments created from Z:"_n "`inexog'"
			di as res "Instruments created from Z:"_n "`z'"
		}
// 	set trace on
	
// di as err "geninst_t : `geninst_t'"
// ms
// remove orthog(`orthog_t') since std IVs not used here
// changed `qq'(=qui) to nooutput option so that collinearity and duplicates messages reported
// added ver from _caller() so that ivreg2 called correct ivreg2x under version control.

			version `ver': `ivreg2_cmd' `lhs_t' `inexog_t' (`endo_t' = `geninst_t') `wtexp' if `touse', ///
						dofminus(`dofminus') `nocons' `first' `ffirst' `rf' ///
						savefprefix(`savefprefix') saverfprefix(`saverfprefix') ///
						cluster(`cluster') /* orthog(`orthog_t') */ endog(`endogtest_t') ///
						redundant(`redundant_t') partial(`partial_t') tvar(`tvar') bw(`bw') ///
						`qnoout' `options'

// Replace any time series locals with original time series names
// cfb
                        g byte `touse2' = `touse'
// Now fix main results
                        mat `b'       =e(b)
                        mat `V'       =e(V)
                        mat `S'       =e(S)
                        mat `W'       =e(W)
                        mat `firstmat'=e(first)
// Matrix column names to be changed
                        local l_cnames  : colnames `b'
                        local l_cnamesS : colnames `S'
                        local l_cnamesW : colnames `W'
                        local l_cnamesf : colnames `firstmat'
// Full list of names to change
                        local l_vnames   "`lhs'   `inexog'   `endo'   `exexog'   `geninst'"
                        local l_vnames_t "`lhs_t' `inexog_t' `endo_t' `exexog_t' `geninst_t'" 
//         di as err    "`geninst_t'"
//         di as err _n "`geninst'"
//         di as err    "`e(inexog)'"
// Macros to be fixed
                        local l_insts     "`e(insts)'"
                        local l_inexog    "`e(inexog)'"
                        local l_instd     "`e(instd)'"
                        local l_exexog    "`e(exexog)'"
                        local l_depvar    "`e(depvar)'"
                        local l_clist     "`e(clist)'"
                        local l_elist     "`e(elist)'"
                        local l_redlist   "`e(redlist)'"
                        local l_partial   "`e(partial)'"
// If any collinear or duplicates
                        local l_collin    "`e(collin)'"
                        local l_dups      "`e(dups)'"
                        local l_insts1    "`e(insts1)'"
                        local l_inexog1   "`e(inexog1)'"
                        local l_instd1    "`e(instd1)'"
                        local l_exexog1   "`e(exexog1)'"
                        local l_partial1  "`e(partial1)'"
                        foreach vn of local l_vnames {
                                tokenize `l_vnames_t'
                                local vn_t `1'
                                mac shift
                                local l_vnames_t `*'
                                local l_cnames  : subinstr local l_cnames    "`vn_t'" "`vn'"
                                local l_cnamesS : subinstr local l_cnamesS   "`vn_t'" "`vn'"
                                local l_cnamesW : subinstr local l_cnamesW   "`vn_t'" "`vn'"
                                local l_cnamesf : subinstr local l_cnamesf   "`vn_t'" "`vn'"
// Macro varlists
                                local l_insts   : subinstr local l_insts     "`vn_t'" "`vn'"
                                local l_inexog  : subinstr local l_inexog    "`vn_t'" "`vn'"
                                local l_instd   : subinstr local l_instd     "`vn_t'" "`vn'"
                                local l_exexog  : subinstr local l_exexog    "`vn_t'" "`vn'"
                                local l_partial : subinstr local l_partial   "`vn_t'" "`vn'"
                                local l_depvar  : subinstr local l_depvar    "`vn_t'" "`vn'"
                                local l_clist   : subinstr local l_clist     "`vn_t'" "`vn'"
                                local l_elist   : subinstr local l_elist     "`vn_t'" "`vn'"
                                local l_redlist : subinstr local l_redlist   "`vn_t'" "`vn'"
                                local l_collin  : subinstr local l_collin    "`vn_t'" "`vn'"
                                local l_dups    : subinstr local l_dups      "`vn_t'" "`vn'"
                                local l_insts1  : subinstr local l_insts1    "`vn_t'" "`vn'"
                                local l_inexog1 : subinstr local l_inexog1   "`vn_t'" "`vn'"
                                local l_instd1  : subinstr local l_instd1    "`vn_t'" "`vn'"
                                local l_exexog1 : subinstr local l_exexog1   "`vn_t'" "`vn'"
                                local l_partial1: subinstr local l_partial1  "`vn_t'" "`vn'"
                        }
//                   di as err "`l_inexog'"
                        mat colnames `b'       =`l_cnames'
                        mat colnames `V'       =`l_cnames'
                        mat rownames `V'       =`l_cnames'
                        mat colnames `S'       =`l_cnamesS'
                        mat rownames `S'       =`l_cnamesS'
                        mat colnames `W'       =`l_cnamesW'
                        mat rownames `W'       =`l_cnamesW'
                        mat colnames `firstmat'=`l_cnamesf'

                        ereturn post `b' `V', dep(`depvar') esample(`touse2') noclear
                        ereturn matrix S `S'
                        if ~matmissing(`W') {
                                ereturn matrix W `W'
                        }
                        if ~matmissing(`firstmat') {
                                ereturn matrix first `firstmat'
                        }
                        ereturn local insts    `l_insts'
                        ereturn local inexog   `l_inexog'
                        ereturn local instd    `l_instd'
                        ereturn local exexog   `l_exexog'
                        ereturn local partial  `l_partial'
                        ereturn local collin   `l_collin'
                        ereturn local dups     `l_dups'
                        ereturn local insts1   `l_insts1'
                        ereturn local inexog1  `l_inexog1'
                        ereturn local instd1   `l_instd1'
                        ereturn local exexog1  `l_exexog1'
                        ereturn local partial1 `l_partial1'
                        ereturn local depvar   `l_depvar'
                        ereturn local clist    `l_clist'
                        ereturn local elist    `l_elist'
                        ereturn local redlist  `l_redlist'
// ms
 						ereturn local cmd		"ivreg2h"
 						ereturn local cmdline	"`cmdline'"
 						if `gen' {
							ereturn local geninsts "`geninst'"
						}
                        ereturn scalar sigma_e=e(rmse)
                        ereturn local xtmodel	"`xtmodel'"
// 
//				est replay
				est store GenInst
				loc ++n_est
// ms
// hack to enable ivreg2 to do the replaying
				ereturn local cmd "`ivreg2_cmd'"
// Display output using ivreg2 replay mode
// ms
// added ver from _caller() so that ivreg2 called correct ivreg2x under version control.
				if "`nooutput'"=="" {
					version `ver': `ivreg2_cmd', `first' `ffirst' `rf' `noheader' `nofooter' `plus' `levopt' `efopt' `dropfirst' `droprf'
				}
// ms
// undo hack
				ereturn local cmd "ivreg2h"
//		su `geninst' if e(sample)
//		corr `geninst' `inexog_t' if e(sample)

// cfb
// di as err "feest `feest'"
/*
				if "`feest'" != "" {
					di as err _n "Warning: variables have been centered"
					}
*/	
// ---------------------------------------------------------------------------------------				
// COMPUTE RESULTS FOR GENERATED AND EXCLUDED INSTRUMENTS --------------------------------
// ---------------------------------------------------------------------------------------	
				
// Lewbel hetero instruments, based on centered included exog + excluded exog in FSR
// Z() overrides list in inexog, expanded into z_t

		if "`exexog_t'" != "" {
                local l_inexog    "`e(inexog)'"
                local l_inexog : subinstr local l_inexog "." "_", all

// di as err _n "exexog_t: `exexog_t'"
// 1.1.06 handled above, disable                
// if Z() specified, override; should check to see that Z is subset of X 
/*
				loc zlist `inexog_t'
				if "`z'" != "" {
					loc zlist `z_t'
					loc zlist_t `z'
					local zlist_t : subinstr local z "." "_", all
				}
*/
// di as err ">>>>> `zlist'"

// 1.1.06: refer to zlist_t
//				loc n_inexog: word count `zlist'
				loc n_inexog: word count `zlist_t'
				if `n_inexog' == 0 {
					di in red _n "Error: no Z variables available for construction of generated instruments." _n
					error 198
				}
				loc n_endo_t: word count `endo_t'
				loc geninst_t 	
				loc geninst 
				loc i 0		
				foreach e of local endo_t {
//					qui reg `e' `inexog_t' if `touse'
					qui reg `e' `zlist' if `touse'
					tempvar `e'_eps
					qui predict double ``e'_eps' if e(sample), residual
					loc ++i
					loc en: word `i' of `endo'
					local j 1
// 1.1.06: revert to zlist_t
// di in r "zlist_t: `zlist_t'"
//					foreach v of local inexog_t {
					foreach v of local zlist_t {
// Federico: added (and some lines commented) to allows correct naming 
// 			 in the case of more endo vars and to allow the -gen- option to work properly
// 						local vn: word `j' of `l_inexog' 
//						local vn: word `j' of `zlist_t'
						loc vn: word `j' of `zts'
 						tempvar z_`e'_`v'_eps
						su `v' if `touse', mean
						qui g double `z_`e'_`v'_eps' = (`v' - r(mean)) * ``e'_eps' if `touse'
						loc geninst_t "`geninst_t' `z_`e'_`v'_eps'"
// 1.0.6: pull name from zts
						loc geninst "`geninst' `en'_`vn'_g"
						local j = `j' + 1 
					}
				}
				
// MS: if standard IV estimation identified, and orthog option empty,
// automatically report test of orthogonality of generated IVs
		if "exexog_t" ~= "" & "`orthog'"=="" {
			local orthog_t : list uniq exexog_t
			local orthog_t : list orthog_t - collin_dups
			if "`orthog_t'" ~= "" {
				loc orthogti "Testing Orthogonality of"
			}
		}
		if "`nooutput'"=="" {
			di as res _n "IV with Generated Instruments and External Instruments" _n "`feest'" 
// list of original regressors here		
//			di as res "`orthogti' Instruments created from Z:" _n "`inexog'"
			di as res "`orthogti' Instruments created from Z:"_n "`z'"
		}
//       di as err  _n  "geninst_t `geninst_t'"
//         di as err _n "`geninst'"
// ms
// changed `qq'(=qui) to nooutput option so that collinearity and duplicates messages reported
// added ver from _caller() so that ivreg2 called correct ivreg2x under version control.
			version `ver': `ivreg2_cmd' `lhs_t' `inexog_t' (`endo_t' = `exexog_t' `geninst_t') `wtexp' if `touse', ///
						dofminus(`dofminus') `nocons' `first' `ffirst' `rf' ///
						savefprefix(`savefprefix') saverfprefix(`saverfprefix') ///
						cluster(`cluster') orthog(`orthog_t') endog(`endogtest_t') ///
						redundant(`redundant_t') partial(`partial_t') tvar(`tvar') bw(`bw') ///
						`qnoout' `options'

// Replace any time series locals with original time series names

// Now fix main results
                        mat `b'       =e(b)
                        mat `V'       =e(V)
                        mat `S'       =e(S)
                        mat `W'       =e(W)
                        mat `firstmat'=e(first)
// Matrix column names to be changed
                        local cnames  : colnames `b'
                        local cnamesS : colnames `S'
                        local cnamesW : colnames `W'
                        local cnamesf : colnames `firstmat'
// Full list of names to change
                        local l_vnames   "`lhs'   `inexog'   `endo'   `exexog'   `geninst'"
                        local l_vnames_t "`lhs_t' `inexog_t' `endo_t' `exexog_t' `geninst_t'" 
// Macros to be fixed
                        local l_insts     "`e(insts)'"
// di as err _n "l_insts: `l_insts'"
                        local l_inexog    "`e(inexog)'"
                        local l_instd     "`e(instd)'"
                        local l_exexog    "`e(exexog)'"
                        local l_depvar    "`e(depvar)'"
                        local l_clist     "`e(clist)'"
                        local l_elist     "`e(elist)'"
                        local l_redlist   "`e(redlist)'"
                        local l_partial  "`e(partial)'"
// If any collinear or duplicates
                        local l_collin    "`e(collin)'"
                        local l_dups      "`e(dups)'"
                        local l_insts1    "`e(insts1)'"
                        local l_inexog1   "`e(inexog1)'"
                        local l_instd1    "`e(instd1)'"
                        local l_exexog1   "`e(exexog1)'"
                        local l_partial1  "`e(partial1)'"
                        foreach vn of local l_vnames {
                                tokenize `l_vnames_t'
                                local vn_t `1'
                                mac shift
                                local l_vnames_t `*'
                                local l_cnames  : subinstr local l_cnames    "`vn_t'" "`vn'"
                                local l_cnamesS : subinstr local l_cnamesS   "`vn_t'" "`vn'"
                                local l_cnamesW : subinstr local l_cnamesW   "`vn_t'" "`vn'"
                                local l_cnamesf : subinstr local l_cnamesf   "`vn_t'" "`vn'"
// Macro varlists
                                local l_insts   : subinstr local l_insts     "`vn_t'" "`vn'"
                                local l_inexog  : subinstr local l_inexog    "`vn_t'" "`vn'"
                                local l_instd   : subinstr local l_instd     "`vn_t'" "`vn'"
                                local l_exexog  : subinstr local l_exexog    "`vn_t'" "`vn'"
                                local l_partial : subinstr local l_partial   "`vn_t'" "`vn'"
                                local l_depvar  : subinstr local l_depvar    "`vn_t'" "`vn'"
                                local l_clist   : subinstr local l_clist     "`vn_t'" "`vn'"
                                local l_elist   : subinstr local l_elist     "`vn_t'" "`vn'"
                                local l_redlist : subinstr local l_redlist   "`vn_t'" "`vn'"
                                local l_collin  : subinstr local l_collin    "`vn_t'" "`vn'"
                                local l_dups    : subinstr local l_dups      "`vn_t'" "`vn'"
                                local l_insts1  : subinstr local l_insts1    "`vn_t'" "`vn'"
                                local l_inexog1 : subinstr local l_inexog1   "`vn_t'" "`vn'"
                                local l_instd1  : subinstr local l_instd1    "`vn_t'" "`vn'"
                                local l_exexog1 : subinstr local l_exexog1   "`vn_t'" "`vn'"
                                local l_partial1: subinstr local l_partial1  "`vn_t'" "`vn'"
                        }
						

                        mat colnames `b'       =`l_cnames'
                        mat colnames `V'       =`l_cnames'
                        mat rownames `V'       =`l_cnames'
                        mat colnames `S'       =`l_cnamesS'
                        mat rownames `S'       =`l_cnamesS'
                        mat colnames `W'       =`l_cnamesW'
                        mat rownames `W'       =`l_cnamesW'
                        mat colnames `firstmat'=`l_cnamesf'

                        ereturn post `b' `V', dep(`depvar') esample(`touse') noclear
                        ereturn matrix S `S'
                        if ~matmissing(`W') {
                                ereturn matrix W `W'
                        }
                        if ~matmissing(`firstmat') {
                                ereturn matrix first `firstmat'
                        }
                        ereturn local insts    `l_insts'
                        ereturn local inexog   `l_inexog'
                        ereturn local instd    `l_instd'
                        ereturn local exexog   `l_exexog'
                        ereturn local partial  `l_partial'
                        ereturn local collin   `l_collin'
                        ereturn local dups     `l_dups'
                        ereturn local insts1   `l_insts1'
                        ereturn local inexog1  `l_inexog1'
                        ereturn local instd1   `l_instd1'
                        ereturn local exexog1  `l_exexog1'
                        ereturn local partial1 `l_partial1'
                        ereturn local depvar   `l_depvar'
                        ereturn local clist    `l_clist'
                        ereturn local elist    `l_elist'
                        ereturn local redlist  `l_redlist'
// ms
 						ereturn local cmd		"ivreg2h"
 						ereturn local cmdline	"`cmdline'"
 						if `gen' {
							ereturn local geninsts "`geninst'"
						}
                        ereturn scalar sigma_e=e(rmse)
                        ereturn local xtmodel	"`xtmodel'"

				est store GenExtInst
// ms
// hack to enable ivreg2 to do the replaying
				ereturn local cmd "`ivreg2_cmd'"
				loc ++n_est
				if "`nooutput'"=="" {
// ms
// added ver from _caller() so that ivreg2 called correct ivreg2x under version control.
					version `ver': `ivreg2_cmd', `first' `ffirst' `rf' `noheader' `nofooter' `plus' `levopt' `efopt' `dropfirst' `droprf'
				}
// ms
// undo hack
				ereturn local cmd "ivreg2h"
		}	// end block for std+generated IVs
		
// cfb
// di as err "feest `feest'"
/*
				if "`feest'" != "" {
					di as err _n "Warning: variables have been centered"
					}
*/
// REPORT OUTPUT

//			if "`exexog_t'" == "" {
// no excluded insts: only GenInst results available
				if (`n_exex'==0) & ("`nooutput'"=="")  {
					est table       GenInst,            b(%12.4g) se(%7.3g)	stat(N rmse j jdf jp) stfmt(%7.3g)
				}
// equation underid with too few excluded insts, GenInst and GenExtInst available
				if (`n_exex' > 0) & (`n_endo' > `n_exex') & ("`nooutput'"=="") {
					est table       GenInst GenExtInst, b(%12.4g) se(%7.3g)	stat(N rmse j jdf jp) stfmt(%7.3g)
				}
				else if (`n_est'==3) & ("`nooutput'"=="") {
// equation identified
					est table StdIV GenInst GenExtInst, b(%12.4g) se(%7.3g)	stat(N rmse j jdf jp) stfmt(%7.3g)
				}
//			}

// cfb
//				if "`feest'" != "" {
//					di as err _n "Warning: variables have been centered"
//					}
			
// ms - if requested, rename and leave behind generated instruments
		if `gen' {
			loc repl
			loc stub
			if "`gen2'" != "" {
				loc com = strpos("`gen2'", ",") 
				if `com' {
					loc stub = substr("`gen2'",1,`=`com'-1')
					loc rest = substr("`gen2'", `com', 99)
					loc repl = strpos("`rest'", "replace")
				}
				else {
					loc stub `gen2'_
					loc rest
				}
			}
//		di in r "stub: `stub'"
//		di in r "`rest'"
//		di in r `repl'
			local gen_ct : word count `geninst'	
			forvalues i=1/`gen_ct' {
				local givname_t	: word `i' of `geninst_t'
				local givname	: word `i' of `geninst'
				if "`repl'" != "" {
					if !`repl' {
						confirm new var `stub'`givname'
					}
					else {
// ms
// added cap in case vars do not yet exist
						cap drop `stub'`givname'
					}
				}
				rename `givname_t' `stub'`givname'
			}
		}

// Collinearity and duplicates warning messages, if necessary
		if "`e(dups)'" != "" {
di as res "Warning - duplicate variables detected"
di as res "Duplicates:" _c
			Disp `e(dups)', _col(16)
		}
		if "`e(collin)'" != "" {
di as res "Warning - collinearities detected"
di as res "Vars dropped:" _c
			Disp `e(collin)', _col(16)
		}
* End estimation block
  }
// cfb ivreg2h

end

**********************************************************************
// from MES

program define parse_iv, rclass
	version 9

// cfb
	sreturn clear
		local n 0

		gettoken depvar 0 : 0, parse(" ,[") match(paren)
		IsStop `depvar'
		if `s(stop)' { 
			error 198 
		}
		while `s(stop)'==0 { 
			if "`paren'"=="(" {
				local n = `n' + 1
				if `n'>1 { 
capture noi error 198
di in red `"syntax is "(all instrumented variables = instrument variables)""'
exit 198
				}
				gettoken p depvar : depvar, parse(" =")
				while "`p'"!="=" {
					if "`p'"=="" {
						capture noi error 198 
di as err `"syntax is "(endogenous regressor = instrument variables)""'
di as err `"the equal sign "=" is required"'
						exit 198 
					}
					local endo `endo' `p'
					gettoken p depvar : depvar, parse(" =")
				}
				local temp_ct  : word count `endo'
				if `temp_ct' > 0 {
				//	tsunab endo : `endo'
					fvunab endo : `endo'
				}
* To enable OLS estimator with (=) syntax, allow for empty exexog list
				local temp_ct  : word count `depvar'
				if `temp_ct' > 0 {
				//	tsunab exexog : `depvar'
					fvunab exexog : `depvar'
				}
			}
			else {
				local inexog `inexog' `depvar'
			}
			gettoken depvar 0 : 0, parse(" ,[") match(paren)
			IsStop `depvar'
		}
		local 0 `"`depvar' `0'"'

//		tsunab inexog : `inexog'
		fvunab inexog : `inexog'
		tokenize `inexog'
		local depvar "`1'"
		local 1 " " 
		local inexog `*'

		return local depvar	"`depvar'"
		return local inexog	"`inexog'"
		return local exexog	"`exexog'"
		return local endo	"`endo'"

end

* Taken from ivreg2
program define Disp 
	version 8.2
	syntax [anything] [, _col(integer 15) ]
	local len = 80-`_col'+1
	local piece : piece 1 `len' of `"`anything'"'
	local i 1
	while "`piece'" != "" {
		di in gr _col(`_col') "`first'`piece'"
		local i = `i' + 1
		local piece : piece `i' `len' of `"`anything'"'
	}
	if `i'==1 { 
		di 
	}
end

program define IsStop, sclass
				/* sic, must do tests one-at-a-time, 
				 * 0, may be very large */
	if `"`0'"' == "[" {		
		sret local stop 1
		exit
	}
	if `"`0'"' == "," {
		sret local stop 1
		exit
	}
	if `"`0'"' == "if" {
		sret local stop 1
		exit
	}
* per official ivreg 5.1.3
	if substr(`"`0'"',1,3) == "if(" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "in" {
		sret local stop 1
		exit
	}
	if `"`0'"' == "" {
		sret local stop 1
		exit
	}
	else	sret local stop 0
end

exit


