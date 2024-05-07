*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw


capture program drop sf_halfd
program define sf_halfd

version 11

   args todo b lnf g H
   tempvar xb zd zdw zdv
   mleval `xb' = `b', eq(1)
   mleval `zdw' = `b', eq(2)
   mleval `zdv' = `b', eq(3)

   tempvar zd
   quie gen byte `zd' = 0 /* half normal, so zero */

   tempvar sigwi2 sigvi2 sigs2 epsi mustar sigstar sigwi sigvi ratio1 ratio2 ratio1a ratio2a sigsta2 epsianz

   quie gen double `sigwi2' = exp(`zdw') /* possible heter in one-sided variance */
   quie gen double `sigwi' = exp(0.5*(`zdw'))
   quie gen double `sigvi2' = exp(`zdv') /* possible heter in two-sided variance */
   quie gen double `sigvi' = exp(0.5*(`zdv'))
   quie gen double `sigs2' = (`sigwi2') + (`sigvi2')
   quie gen double `epsi'  = ($ML_y1) - (`xb')
   scalar cst = 1 /* a switch */
  if $PorC == 2 { /* cost frontier */
   quie replace `epsi' = -(`epsi')
   scalar cst = -1
   }
   quie gen double `epsianz' = `epsi' + `zd'
   quie gen double `mustar' = ((`sigvi2')* (`zd') - (`sigwi2')* (`epsi'))/(`sigs2')
   quie gen double `sigstar' = (`sigvi')*(`sigwi')/sqrt(`sigs2')
   quie gen double `sigsta2' = (`sigvi2')*(`sigwi2')/(`sigs2')
   quie gen double `ratio1' = (`mustar')/(`sigstar')
   quie gen double `ratio2' = (`zd')/(`sigwi')
   quie gen double `ratio1a' = normalden(`ratio1')/normal(`ratio1')
   quie gen double `ratio2a' = normalden(`ratio2')/normal(`ratio2')


   mlsum `lnf' = -0.5* ln(`sigs2') + lnnormalden(((`epsi') + (`zd'))/sqrt(`sigs2')) /*
                  */    + lnnormal((`mustar')/(`sigstar')) /*
                  */    - lnnormal((`zd')/(`sigwi'))


   if (`todo' == 0 | `lnf' >= .) exit

   tempname d1 d2 d3 /* d4 */

   mlvecsum `lnf' `d1' = cst*((`epsianz')/(`sigs2') + (`sigwi2')*(`ratio1a')/((`sigs2')*(`sigstar'))), eq(1)

   mlvecsum `lnf' `d2' = 0.5*( (`ratio2')*(`ratio2a') + ((`sigwi')*(`epsianz')/(`sigs2'))^2 - (`sigsta2')/(`sigvi2') /*
                        */ - (2*(`epsianz')*(`sigsta2')/(`sigs2') + (`mustar')*(1-(`sigsta2')/(`sigvi2')) )*(1/`sigstar')*(`ratio1a') ), eq(2)

   mlvecsum `lnf' `d3' = 0.5*( ((`sigvi')*(`epsianz')/(`sigs2'))^2 - (`sigsta2')/(`sigwi2') /*
                        */ + (2*(`epsianz')*(`sigsta2')/(`sigs2') - (`mustar')*(1 - (`sigsta2')/(`sigwi2')) )*(1/`sigstar')*(`ratio1a') ), eq(3)


   matrix `g' = (`d1', `d2', `d3')


   if (`todo' == 1 | `lnf'>=.) exit

   tempname ratio3 ratio4 ratio5 ratio6 ratio7
   quie gen double `ratio3' = (`epsianz')/(`sigs2')
   quie gen double `ratio4' = `sigsta2' - ((`sigsta2')^2)/(`sigwi2')
   quie gen double `ratio5' = `sigsta2' - ((`sigsta2')^2)/(`sigvi2')
   quie gen double `ratio6' = (`sigsta2')/(`sigwi2')
   quie gen double `ratio7' = (`sigsta2')/(`sigvi2')

   tempname h11 h12 h13 h22 h23 h33

mlmatsum `lnf' `h11' =  /*
    */ -((-(((`ratio1a')^2*(`sigsta2'))/(`sigvi2')^2)) - /*
    */ ((`mustar')*(`ratio1a')*(`sigstar'))/(`sigvi2')^2 - (`sigsta2')/((`sigvi2')*(`sigwi2'))), eq(1)



mlmatsum `lnf' `h12' = cst*( /*
    */ -((-(((`ratio1a')*(`sigstar')^3)/(`sigvi2')^2)) - /*
    */ ((`ratio3')*(`sigsta2'))/(`sigvi2') - /*
    */ ((`ratio1a')*(`ratio5'))/(2*(`sigstar')*(`sigvi2')) - /*
    */ (sqrt(2)*(`ratio1a')^2*(`sigstar')*(( /*
    */ (-(((`ratio3')*(`sigstar'))/sqrt(2))) + /*
    */ ((`ratio1')*(((-1) + (`sigsta2')/(`sigvi2'))))/(2*sqrt(2)))))/(`sigvi2') /*
    */ + ((`ratio1a')*(`sigstar')*((2 + (`mustar')^2/(`sigstar')^2 + /*
    */ ((`mustar')*((2*(`epsi') + (`mustar'))))/(`sigvi2'))))/(2*(`sigvi2')))), eq(1,2)

mlmatsum `lnf' `h13' = cst*( /*
    */ -((((-2)*(`ratio3')*(`sigsta2')*(`sigstar')^3*(`sigvi2') + /*
    */ (`ratio1a')^2*(`sigstar')^2*(( /*
    */ (`ratio1')*(`ratio4') - 2*(`ratio3')*(`sigsta2')*(`sigstar')))*(`sigwi2') + /*
    */ (`ratio1a')*(`sigsta2')*(( /*
    */ (((-2) + (`ratio1')^2))*(`sigstar')^4 - /*
    */ 2*(`ratio1')*(`ratio2')*(`sigstar')^3*(`sigwi') + /*
    */ (`ratio1')^2*(`sigstar')^2*(`sigwi')^2 - (`ratio4')*(`sigwi2')))))/ /*
    */ ((2*(`sigsta2')*(`sigstar')*(`sigvi2')*(`sigwi2'))))), eq(1,3)


mlmatsum `lnf' `h22' = /*
    */ -(((4*(`epsi')*(`ratio1a')*(`sigsta2')^2*(( /*
    */ 2*(`ratio5') - (`ratio1')^2*(`sigstar')^2 + (`ratio1')^2*(`ratio7')*(`sigstar')^2 - /*
    */ 2*(`ratio1')*(`ratio3')*(`sigstar')^3 + 4*(`ratio7')^2*(`sigvi2'))) + /*
    */ (`sigstar')*(( /*
    */ 2*(`ratio1')^3*(`ratio1a')*(((-1) + (`ratio7')^2))*(`sigsta2')^2*(`sigvi2') /*
    */ - 2*(`ratio1')^2*(`ratio1a')*(`sigsta2')^2*(( /*
    */ (`ratio1a') - 2*(`ratio1a')*(`ratio7') + (`ratio1a')*(`ratio7')^2 + /*
    */ 2*(`ratio3')*(`sigstar') + 2*(`ratio3')*(`ratio7')*(`sigstar')))*(`sigvi2') + /*
    */ 2*(`ratio1')*(`ratio1a')*(( /*
    */ 4*(`ratio5')*(`sigsta2')^2 + 3*(`ratio5')^2*(`sigvi2') - /*
    */ 2*(`sigsta2')^2*(`sigvi2') + 6*(`ratio7')*(`sigsta2')^2*(`sigvi2') + /*
    */ 4*(`ratio7')^2*(`sigsta2')^2*(`sigvi2') - /*
    */ 4*(`ratio1a')*(`ratio3')*(`sigsta2')^2*(`sigstar')*(`sigvi2') + /*
    */ 4*(`ratio1a')*(`ratio3')*(`ratio7')*(`sigsta2')^2*(`sigstar')*(`sigvi2'))) + /*
    */ (`sigsta2')^2*(`sigvi2')*(( /*
    */ (-2)*(`ratio2')*(`ratio2a') + /*
    */ 2*(`ratio2')^3*(`ratio2a') + /*
    */ 2*(`ratio2')^2*(`ratio2a')^2 - 4*(`ratio7') + /*
    */ 4*(`ratio7')^2 - /*
    */ 8*(`ratio1a')*(`ratio3')*(`sigstar') - /*
    */ 8*(`ratio1a')^2*(`ratio3')^2*(`sigstar')^2 + 4*(`ratio3')^2*(`sigwi2') - /*
    */ 8*(`ratio3')^2*(`ratio7')*(`sigwi2')))))))/ /*
    */ ((8*(`sigsta2')^2*(`sigstar')*(`sigvi2')))), eq(2)

mlmatsum `lnf' `h23' =    -(((((`sigsta2')^2*(`sigvi2')*(( /*
 */ (-4)*(`ratio1a')*(`ratio2')*(`ratio5') - /*
 */ 8*(`ratio1a')*(`ratio2')*(`ratio7')*(`sigstar')^2 + /*
 */ 4*(`ratio6')*(`ratio7')*(`sigstar')*(`sigwi') - /*
 */ 8*(`ratio3')^2*(`sigstar')^3*(`sigwi')))*(`sigwi2') - /*
 */ 2*(`ratio1')^3*(`ratio1a')*(`sigsta2')*(`sigstar')*(( /*
 */ 2*(`sigsta2')*(`sigstar')^2 + (`ratio5')*(`sigvi2')))*(`sigwi')*(( /*
 */ (`sigstar')^2 + (`sigwi2'))) -2*(`ratio1')^2*(`ratio1a')*(`sigstar')*(( /*
 */ 2*(`sigsta2')*(`sigstar')^2 + (`ratio5')*(`sigvi2')))* /*
 */ ((2*(`ratio1a')*(`sigsta2')*(`sigstar')^2*(`sigwi') + /*
 */ (`ratio1a')*(`ratio4')*(`sigwi')^3 - 2*(`ratio2')*(`sigsta2')*(`sigstar')*(`sigwi2')) /*
 */ ) + 2*(`ratio1')*(`ratio1a')*(`sigstar')*((2*(`ratio5')*(`sigsta2')^2*(`sigvi2')*(`sigwi') + /*
 */ 2*(`ratio4')*(`sigsta2')^2*(`sigwi')^3 + 3*(`ratio4')*(`ratio5')*(`sigvi2')*(`sigwi')^3 - /*
 */ 2*(`ratio5')*(`sigsta2')*(`sigvi2')*(`sigwi')^3 + /*
 */ 4*(`ratio6')*(`ratio7')*(`sigsta2')^2*(`sigvi2')*(`sigwi')^3 + /*
 */ 2*(`ratio6')*(`sigsta2')*(`sigstar')^2*(`sigvi2')*(`sigwi')^3 + /*
 */ 4*(`ratio1a')*(`ratio2')*(`sigsta2')^2*(`sigstar')^3*(`sigwi2') + /*
 */ 2*(`ratio1a')*(`ratio2')*(`ratio5')*(`sigsta2')*(`sigstar')*(`sigvi2')*(`sigwi2'))) - /*
 */ 4*(`epsi')*(`ratio1a')*(`sigsta2')*(((-(`sigsta2'))* /*
 */ ((2*(`ratio1a')*(`ratio2')*(`sigstar')^3 + (`ratio4')*(`sigwi') + /*
 */ 2*(`ratio6')*(`ratio7')*(`sigvi2')*(`sigwi')))*(`sigwi2') + /*
 */ (`ratio1')^2*(`sigsta2')*(`sigstar')^2*(`sigwi')*(((`sigstar')^2 + (`sigwi2')) /*
 */ ) + (`ratio1')*(`sigstar')^2*((2*(`ratio1a')*(`sigsta2')*(`sigstar')^2*(`sigwi') + /*
 */ (`ratio1a')*(`ratio4')*(`sigwi')^3 - /*
 */ 2*(`ratio2')*(`sigsta2')*(`sigstar')*(`sigwi2')))))))/ /*
 */ ((8*(`sigsta2')^2*(`sigstar')*(`sigvi2')*(`sigwi')*(`sigwi2'))))), eq(2,3)

 mlmatsum `lnf' `h33' =   -( (1/4*(( /*
 */ 2*(`ratio3')^2*(`sigvi2') + (2*(`sigstar')^4)/(`sigwi2')^2 - /*
 */ (2*(`sigsta2'))/(`sigwi2') - /*
 */ (4*(`ratio3')^2*(`sigsta2')*(`sigvi2'))/(`sigwi2') - /*
 */ ((`ratio1a')^2* /*
 */ ((2*(`ratio1')*(`sigstar')^4 - 2*(`ratio2')*(`sigstar')^3*(`sigwi') + /*
 */ (`ratio1')*(`ratio4')*(`sigwi2')))^2)/((`sigstar')^4*(`sigwi2')^2) - /*
 */ (1/((`sigstar')^3*(`sigwi2')^2)*(( /*
 */ (`ratio1')*(`ratio1a')*(( /*
 */ 2*(`ratio1')*(`sigstar')^4 - 2*(`ratio2')*(`sigstar')^3*(`sigwi') + /*
 */ (`ratio1')*(`ratio4')*(`sigwi2')))* /*
 */ (((-2)*(`ratio2')*(`sigsta2')*(`sigwi') + /*
 */ (`ratio1')*(`sigstar')*(((`sigsta2') + (`sigwi2')))))))) + /*
 */ (1/((`sigsta2')^2*(`sigwi2')^2)*(( /*
 */ (`ratio1a')*(( /*
 */ 4*(`sigstar')^7*(((`ratio1')*(`sigstar') - 2*(`ratio2')*(`sigwi'))) + /*
 */ 2*(`sigstar')^5*(((`ratio1')*(`sigstar') + 2*(`ratio2')*(`sigwi')))*(`sigwi2') /*
 */ + 3*(`ratio1')*(`ratio4')^2*(`sigwi2')^2 - /*
 */ 2*(`sigstar')^3*(`sigwi2')*(( /*
 */ 2*(`ratio2')*(`ratio4')*(`sigwi') + /*
 */ (`ratio1')*(`sigstar')*(((-2)*(`ratio4') + (`sigwi2'))))))))))) ))), eq(3)

matrix `H' = -(`h11', `h12', `h13'\ `h12'', `h22', `h23' \ `h13'', `h23'', `h33')


end
