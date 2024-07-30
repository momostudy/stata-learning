*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw

capture program drop sf_half
program define sf_half

version 12

   args lnf xb zdw zdv

   tempvar sigv2 sigs epsi lambda sigw2

   quie gen double `sigv2'  = exp(`zdv')
   quie gen double `sigw2' = exp(`zdw')
   quie gen double `sigs'  = sqrt(`sigw2' + `sigv2')
   quie gen double `epsi'  = ($ML_y1 - `xb')
  if $PorC == 2 { /* cost frontier */
   quie replace `epsi' = -(`epsi')
   }
   quie gen double `lambda' = sqrt((`sigw2')/(`sigv2'))


   quie replace `lnf' = ln(2) - ln(`sigs') + lnnormalden(-(`epsi')/(`sigs')) /*
                        */ + lnnormal(`lambda'* (-`epsi')/`sigs')

end
