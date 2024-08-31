// KP05  two-tier stochastic frontier model
cap drop SFA2tier_KP05_extend_ll
program define SFA2tier_KP05_extend_ll
version 8.2

   args lnf xb sigma_v sigma_u sigma_w
   tempvar e a b eta beta

   qui gen double   `e' = $ML_y1 - `xb'
   qui gen double   `a' = `e'/exp(`sigma_u') + exp(`sigma_v')^2/(2*exp(`sigma_u')^2)  
   qui gen double   `b' = `e'/exp(`sigma_v') - exp(`sigma_v')/exp(`sigma_w')
   qui gen double `eta' = exp(`sigma_v')^2/(2*exp(`sigma_w')^2) - `e'/exp(`sigma_w')
   qui gen double `beta'= - `e'/exp(`sigma_v') - exp(`sigma_v')/exp(`sigma_u')

   qui replace `lnf' = - ln(exp(`sigma_u') + exp(`sigma_w')) ///
                       + ln(exp(`a')*norm(`beta') + exp(`eta')*norm(`b'))

end

