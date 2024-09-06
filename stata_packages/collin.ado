*! version 1.5.1  - 7/16/04
*! version 1.4    - 1/25/04
*! version 1.1.1  - 1/31/02  
*! version 1.1    - 2/7/01
program define collin, rclass
  version 6.0
  syntax varlist [if] [in] [, corr rinv]
  marksample touse
  local vars `varlist'
  tempname r ri r2 x v xr vr ci cir t sscp det diag1
  quietly mat accum `r'    = `vars' if `touse', noconst deviations
  mat `r' = corr(`r')

 /*
  if "`cdiag'" ~= "" {
    quietly mat accum `sscp' = `vars' if `touse', noconst 
    mat `diag1' = diag(vecdiag(`sscp'))
    mat `diag1' = syminv(`diag1')
    mat `sscp' = `diag1'*`sscp'*`diag1'
    matrix symeigen `x' `v' = `sscp'
    local str1 "raw sscp (no intercept)"
  } */
  

  else if "`corr'"~="" {
    mat `sscp' = `r'
    matrix symeigen `x' `v' = `r'
    local str1 "deviation sscp (no intercept)"
  }
  
  else {
    quietly mat accum `sscp' = `vars' if `touse' 
    mat `diag1' = diag(vecdiag(`sscp'))
    local i = 1
    while `i' <= colsof(`sscp') {
      mat `diag1'[`i',`i'] = sqrt(`diag1'[`i',`i'])
      local i = `i'+1
    }
    mat `diag1' = syminv(`diag1')
    mat `sscp' = `diag1'*`sscp'*`diag1'
    matrix symeigen `x' `v' = `sscp'
    local str1 "scaled raw sscp (w/ intercept)"
  } 
  
  mat `ri' = inv(`r')
  mat `r2' = vecdiag(`ri')
  mat `t'  = vecdiag(`ri')
  scalar `det' = det(`r')
  local m  = colsof(`v')
  local m2 = colsof(`r')
  local i = 1
  local var2 : colnames(`sscp')
  matrix colnames `v' = `var2'
  matrix rownames `v' = " "
  matrix `ci' = J(1,`m',0)
  local sum = 0
  local i = 1
  while `i' <= `m2' {
    local sum = `sum' + `t'[1,`i']
    matrix `r2'[1,`i'] = 1 - 1/`r2'[1,`i']
    local i = `i'+1
  }
  local i = 1
  while `i' <= `m' {
    matrix `ci'[1,`i'] = sqrt(`v'[1,1]/`v'[1,`i'])
    local i = `i'+1
  }
  local cn  = `ci'[1,`m']
  local mvif = `sum'/`m2'
  tokenize `var2'
  display
  display in green "  Collinearity Diagnostics"
  display  
  display in green "                        SQRT                   R-"
  display in green "  Variable      VIF     VIF    Tolerance    Squared"
  display in green _dup(52) "-"
  local i = 1
  while `i' <= `m2' {
     display in yellow %10s "``i''" %10.2f `t'[1,`i'] /*
            */  %8.2f (sqrt(`t'[1,`i'])) /*
            */ "  " %8.4f (1/`t'[1,`i'])  /*
            */ "  " %10.4f  `r2'[1,`i']  
                
     local i = `i'+1
  }
  display in green _dup(52) "-"
  display in green %10s "Mean VIF" %10.2f in yellow `mvif'
  display
  display in green "                           Cond"
  display in green "        Eigenval          Index"
  display in green _dup(33) "-"
  local i = 1
  while `i' <= `m' {
     display in yellow  "    "  `i' /*
            */ "   "  %8.4f `v'[1,`i']  /*
            */ " " %15.4f `ci'[1,`i']        
     local i = `i'+1
  }
  
  
  display in green _dup(33) "-"
  display in green " Condition Number" %15.4f in yellow `cn' " " %10.4f `cnr'
  display in green " Eigenvalues & Cond Index computed from " "`str1'"
  display in green " Det(correlation matrix)" %10.4f in yellow `det'
  
        
  if "`rinv'" ~= "" {
    display
    display in green "Inverse of correlation matrix"
    mat lis `ri', noh
  }
 
  return scalar m_vif = `mvif'
  return scalar cn = `cn'
end
