*! version 1.0.6  06feb2023  sk dcs

program define ardl_p , sortpreserve

    version 11.2

    syntax newvarname [if] [in] ,       ///  must parse using 'newvarname' as this automatically defines `typlist'
                [ xb                    ///  default
                  Residuals             ///
                  ec                    /// 
                ]
        
    marksample touse , novarlist

    if "`e(cmd)'" != "ardl" exit 301

    local nstats : word count `xb' `residuals' `ec'
    if `nstats' > 1 {
        disp as error "More than one statistic specified."
        exit 198
    }
    if `nstats'==0 {
        local xb  xb
        disp as text "(option xb assumed; fitted values)"
    }

    tempname b
    matrix `b' = e(b)
    if "`xb'`residuals'"!="" {
        tempvar xbtemp
        if "`e(model)'"=="ec" {
            tempvar  ec
            tempname srpart  // may be variable or scalar
            qui predict double `ec' if `touse' , ec
            tempname srmat
            capture matrix `srmat' = `b'[1, "SR:"]
            if !_rc {
                qui matrix score `srpart' = `srmat' if `touse'
            }
            else {
                scalar `srpart' = 0  // no SR-part in model
            }
            
            
            if "`xb'"!="" {
                gen `typlist' `varlist' =  `b'[1,1] * `ec' + `srpart' if `touse'
                label variable `varlist' "ardl: fitted values"
            }
            else {
                gen `typlist' `varlist' = `e(depvar)' - `b'[1,1] * `ec' - `srpart' if `touse'
                label variable `varlist' "ardl: residuals"
            }
        }
        else {
            qui mat score double `xbtemp' = `b' if `touse'
            if "`xb'"!="" {
                gen `typlist' `varlist' = `xbtemp' if `touse'
                label variable `varlist' "ardl: fitted values"
            }
            else {
                gen `typlist' `varlist' = `e(depvar)' - `xbtemp' if `touse'
                label variable `varlist' "ardl: residuals"
            }
        }
        exit
    }

    if "`ec'"!="" {
        if "`e(model)'"!="ec" {
            disp as error "Estimation not in error-correction form."
            exit 198
        }
        tempname ecx y
        matrix `y'  = 1
        tsrevar `e(depvar)' , list   // get rid of "D." or other TS ops before depvar
        local depvar = r(varlist)
        matrix colnames `y' = LR:L.`depvar'

        capture matrix `ecx' = -1 * `b'[1, "LR:"]
        matrix `ec' = (`y' , nullmat(`ecx'))
            // `ecx' does not exist if model contains no LR-xregs or LR deterministics
        matrix score `typlist' `varlist' = `ec' if `touse' , equation(LR)
        label variable `varlist' "ardl: error-correction term"
    }
    
end



