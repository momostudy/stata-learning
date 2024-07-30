*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw


capture program drop sf_expo
program define sf_expo


   version 11
   args todo b lnf

   tempvar xb zdw zdv
   mleval `xb' = `b', eq(1)
   mleval `zdw' = `b', eq(2)
   mleval `zdv' = `b', eq(3)


  tempvar sigv2 sigv sigw2 sigw epsi
  quie gen double `sigv2' = exp(`zdv')
  quie gen double `sigv'  = exp(0.5*`zdv')
  quie gen double `sigw2' = exp(`zdw')
  quie gen double `sigw'  = exp(0.5*`zdw')

  quie gen double `epsi'  = $ML_y1 - `xb'
  if $PorC == 2 { /* cost frontier */
     quie replace `epsi' = -(`epsi')
   }

  quie replace `lnf' = -ln(`sigw') + lnnormal(-(`epsi')/(`sigv') - (`sigv')/(`sigw')) /*
                  */   + (`epsi')/(`sigw') + (`sigv2')/(2*(`sigw2'))


end
