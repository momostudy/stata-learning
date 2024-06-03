*! version 1.0.0 13aug2014
* Ilse Ruyssen
set trace on

capture program drop xtbcfe_p

program define xtbcfe_p
        version 8.0
      syntax newvarname  [if] [in], [XB XBU U UE E]

        
        
        tempname touse
        mark `touse' `if' `in'

        local stat "`xb'`xbu'`u'`ue'`e'" 

        if "`stat'"=="xb" | "`stat'" == "" {
                _predict `typlist' `varlist' if `touse'
        }       
        else if "`stat'"=="ue" {
                tempname xb
                qui _predict double `xb' if `touse'
                gen `typlist' `varlist'=`e(depvar)'-`xb' 
        }
   
        // statistics from the estimation sample   
        else if "`stat'"=="xbu" {
                tempname xb res eta
                qui _predict double `xb' if e(sample)
                qui gen double `res'=`e(depvar)'-`xb'
                qui egen double `eta'=mean(`res') if e(sample),by(`e(ivar)')
                gen `typlist' `varlist'=`xb' + `eta' if `touse'
        }       
        
        else if "`stat'"=="u"  {
                tempname xb res eta
                qui _predict double `xb' if e(sample)
                qui gen double `res'=`e(depvar)'-`xb' 
                qui egen double `eta'=mean(`res') if e(sample),by(`e(ivar)') 
                gen `typlist' `varlist'=`eta' if `touse'
        }
        else if "`stat'"=="e" {
                tempname xb res eta 
                qui _predict double `xb' if e(sample)
                qui gen double `res'=`e(depvar)'-`xb' 
                qui egen double `eta'=mean(`res') if e(sample),by(`e(ivar)')
                gen `typlist' `varlist'=`res'- `eta' if `touse'
                
        }       
        else {
                di as err "You can only predict one statistic at a time."
                exit 198 
        }
end
