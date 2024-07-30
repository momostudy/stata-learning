*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw

capture program drop sf_SW
program define sf_SW

   version 11
   args lnf xb zd mu c0 zdv
   tempvar sigwi sigvi sigs2 epsi mustar sigstar sigwi0


   quie gen double `sigwi0'= exp(`zd')
   quie gen double `sigwi' = exp(`c0'+`zd')
   quie gen double `sigvi' = exp(`zdv')
   quie gen double `sigs2' = (`sigwi')^2 + (`sigvi')^2
   quie gen double `epsi'  = $ML_y1 - `xb'
  if $PorC == 2 {
   quie replace `epsi' = -(`epsi')
   }
   quie gen double `mustar' = (((`sigvi')^2)* `mu'*`sigwi0' - ((`sigwi')^2)* `epsi')/(`sigs2')
   quie gen double `sigstar' = (`sigvi'*`sigwi')/sqrt(`sigs2')

   quie replace `lnf' = -0.5* ln(`sigs2') + lnnormalden((`epsi' + `mu'*`sigwi0')/(sqrt(`sigs2'))) /*
                  */    + lnnormal(`mustar'/`sigstar') /*
                  */    - lnnormal(`mu'*exp(-`c0'))

end
