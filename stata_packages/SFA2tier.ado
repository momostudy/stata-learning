*! Author: Lian Yu-jun
*! E-mail: arlionn@163.com
*! Homepage: http://toran.cn/arlion

program define SFA2tier , eclass
version 8.2 

        if replay() {
        
                if "`e(cmd)'" != "SFAsw" {
            error 301
        }
                Replay `0'
                exit
        }

   syntax varlist(ts) [if] [in] [,noCONStant sigmau(string) sigmaw(string) /* 
                                */Check SEarch Plot Robust  Firmeff Timeeff]
        
        if "`constant'" != "" {
             local nocns=", `constant'"
        }  
        if "`robust'" != ""{
               local robust "robust"
         }
          
        marksample touse
        markout `touse' `varlist'     
        gettoken lhs varlist: varlist  
        if "`varlist'" == "" & "`constant'" != "" {
             error 102
        }
           
        tsunab lhs : `lhs'
                    /* check `lhs' not constant */
        qui _rmcoll `lhs'
        if "`r(varlist)'" == "" {
             di as err "dependent variable cannot be constant"
             exit 198
        }
        
                
        if "`firmeff'"!="" | "`timeeff'"!=""{
           qui tsset
           local id   "`r(panelvar)'"
           local t    "`r(timevar)'"   
        }
            
        
        markout `touse' `ivar' `tvar'  /* iis does not allow string */

        qui count if `touse' == 1
        if r(N) == 0 {
              error 2000
        }   
        


    ** Firm fixed effects and Time fixed effects
            
      if "`firmeff'"!="" | "`timeeff'"!=""{
           qui xtdes
           local NN = r(N)
           local TT = r(max)
      }

      if "`firmeff'" != ""{
        cap drop _dum_fe*
        qui tab `id', gen(_dum_fe)
        drop _dum_fe1
        local varlist `varlist' _dum_fe2-_dum_fe`NN'
        local mlmax "ml max"
        local dropf "drop _dum_fe*"
      }
      if "`timeeff'" != ""{
        cap drop _dum_t*
        qui tab `t', gen(_dum_t)
        drop _dum_t1 _dum_t2
        local varlist `varlist' _dum_t3-_dum_t`TT'
        local mlmax "ml max"
        local dropt "drop _dum_t*"
      }   


    ** remove collinearity 
    cap noi _rmdcoll `lhs' `varlist' if `touse'  `nocns'
    if _rc {
        di as err "some independent variables " /*
            */ "collinear with the dependent variable"
        exit _rc
    }
    local varlist `r(varlist)'
    local names `varlist'

    ** time-series operator 
    local eq1 : subinstr local lhs "." "_", all
    tsrevar `varlist'
    local varlist `r(varlist)'
    local lhsname `lhs'
    tsrevar `lhs'
    local lhs `r(varlist)'
    markout `touse' `varlist' `lhs'    
  
    if `"`sigmau'"' == "" & `"`sigmaw'"' == ""{
        ml model lf SFA2tier_KP05_ll (`eq1': `lhs'=`varlist' `nocns') /*
                */ (sigma_v: )                        /*
                */ (sigma_u: `sigmau')                 /*
                */ (sigma_w: `sigmaw' )                /*
                */ if `touse', `robust' title(Two-tier SFA Model (2TSFA) : HOMO)        
    }
    else {
        ml model lf SFA2tier_KP05_extend_ll (`eq1': `lhs'=`varlist' `nocns') /*
                */ (sigma_v: )                        /*
                */ (sigma_u: `sigmau')                 /*
                */ (sigma_w: `sigmaw' )                /*
                */ if `touse', `robust' title(Two-tier SFA Model (2TSFA) : HET) 
    }
    if "`check'" != ""{
        qui ml check
    }
    if "`search'" != ""{
        qui ml search   
    }
    if "`plot'" != ""{             
        ml plot _cons 
    }       
        //ml max
        `mlmax'
        `dropf'
        `dropt'
    ereturn local sigmau "`sigmau'"
    ereturn local sigmaw "`sigmaw'"

end
