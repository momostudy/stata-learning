*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw

capture program drop sf_trun2
program define sf_trun2

   version 11
   args todo b lnf

   tempvar xb zd zdw zdv
   mleval `xb' = `b', eq(1)
   mleval `zd' = `b', eq(2)
   mleval `zdw' = `b', eq(3)
   mleval `zdv' = `b', eq(4)

   tempvar sigwi2 sigvi2 sigs2 epsi mustar sigstar sigwi sigvi ratio1 ratio2 ratio1a ratio2a sigsta2 epsianz

   quie gen double `sigwi2' = exp(`zdw')
   quie gen double `sigwi' = exp(0.5*(`zdw'))
   quie gen double `sigvi2' = exp(`zdv')
   quie gen double `sigvi' = exp(0.5*(`zdv'))
   quie gen double `sigs2' = (`sigwi2') + (`sigvi2')
   quie gen double `epsi'  = ($ML_y1) - (`xb')
  if $PorC == 2 { /* cost frontier */
   quie replace `epsi' = -(`epsi')
   }
   quie gen double `epsianz' = `epsi' + `zd'
   quie gen double `mustar' = ((`sigvi2')* (`zd') - (`sigwi2')* (`epsi'))/(`sigs2')
   quie gen double `sigstar' = (`sigvi')*(`sigwi')/sqrt(`sigs2')
   quie gen double `sigsta2' = (`sigvi2')*(`sigwi2')/(`sigs2')
   quie gen double `ratio1' = (`mustar')/(`sigstar')
   quie gen double `ratio2' = (`zd')/(`sigwi')
   quie gen double `ratio1a' = normalden(`ratio1')/normal(`ratio1')
   quie gen double `ratio2a' = normalden(`ratio2')/normal(`ratio2')


   quie replace `lnf' = -0.5* ln(`sigs2') + lnnormalden(((`epsi') + (`zd'))/sqrt(`sigs2')) /*
                     */    + lnnormal((`mustar')/(`sigstar')) /*
                     */    - lnnormal((`zd')/(`sigwi'))


end
