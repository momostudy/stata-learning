*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw

capture program drop sf_SWd
program define sf_SWd

   version 11
     args todo b lnf g H


   tempvar xb zd mu c0 zdv
   mleval `xb' = `b', eq(1)
   mleval `zd' = `b', eq(2)
   mleval `mu' = `b', eq(3)
   mleval `c0' = `b', eq(4)
   mleval `zdv' = `b', eq(5)

   tempvar sigwi sigvi sigs2 epsi mustar sigstar sigwi0 sigsta2

   quie gen double `sigwi0'= exp(`zd')
   quie gen double `sigwi' = exp(0.5*(`c0')+`zd')
   quie gen double `sigvi' = exp(0.5*(`zdv'))
   quie gen double `sigs2' = (`sigwi')^2 + (`sigvi')^2
   quie gen double `epsi'  = $ML_y1 - `xb'
   scalar cst = 1
  if $PorC == 2 { /* cost frontier */
   quie replace `epsi' = -(`epsi')
   scalar cst = -1
   }
   quie gen double `mustar' = (((`sigvi')^2)* `mu'*`sigwi0' - ((`sigwi')^2)* `epsi')/(`sigs2')
   quie gen double `sigstar' = (`sigvi'*`sigwi')/sqrt(`sigs2')
   quie gen double `sigsta2' = ((`sigvi'*`sigwi')^2)/(`sigs2')

   mlsum `lnf' = -0.5* ln(`sigs2') + lnnormalden((`epsi' + (`mu')*(`sigwi0'))/(sqrt(`sigs2'))) /*
                  */    + lnnormal((`mustar')/(`sigstar')) /*
                  */    - lnnormal((`mu')*exp(-0.5*(`c0')))


   if (`todo' == 0 | `lnf' == .) exit

   tempname ratio1 ratio2 ratio3 ratio4 ratio5 ratio6 ratio7 ratio8 ratio9
   tempname ratio1a  ratio9a rat8 rat4 munum
   tempname sigz rat2 rat2a rat3 ratio6a ratio7a

   quie {
      gen double `ratio1' = `mustar'/`sigstar'
      gen double `ratio2' = `mustar'/`sigvi'
      gen double `ratio3' = `mustar'/`sigwi'
      gen double `ratio4' = `sigsta2'/`sigvi'
      gen double `ratio5' = `sigsta2'/`sigwi'
      gen double `ratio6' = (`sigvi')^2/`sigstar'
      gen double `ratio7' = (`sigwi')^2/`sigstar'
      gen double `ratio6a' = (`ratio6')/(`sigs2')
      gen double `ratio7a' = (`ratio7')/(`sigs2')
      gen double `ratio8' = (`sigvi')^2/`sigs2'
      gen double `ratio9' = `mu'/`sigwi'
      gen double `rat8'   = (`sigwi')^2/`sigs2'
      gen double `ratio1a' = normalden(`ratio1')/normal(`ratio1')
      gen double `ratio9a' = normalden(`ratio9')/normal(`ratio9')
      gen double `rat4' = (`ratio4')/(`sigvi')
      gen double `munum' = (`epsi' + `mu'*`sigwi0')/(`sigs2')
      gen double `sigz' = exp(0.5*(`c0'))
      gen double `rat2' = (`mu')/(exp(0.5*(`c0')))
      gen double `rat2a' = normalden(`rat2')/normal(`rat2')
      gen double `rat3' = (-2*(`epsi')*((`sigwi')^2) + (`mu')*((`sigvi')^2)*(`sigwi0'))/(`sigs2')
   }

   tempname g1 g2 g3 g4 g5



   mlvecsum `lnf' `g1'= /*
             */ cst*(((`munum') + ((`ratio1a')*(`ratio7'))/(`sigs2'))), eq(1)


   mlvecsum `lnf' `g2'= /*
        */ ((-1)*(`rat8') + /*
        */ sqrt(2)*(`ratio1a')*(( /*
        */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') + /*
        */ (`rat3')/(sqrt(2)*(`sigstar')))) + (`munum')^2*(`sigwi')^2 - (`mu')*(`munum')*(`sigwi0')), eq(2)



   mlvecsum `lnf' `g4'= 0.5*( /*
        */ ((`rat2')*(`rat2a') - 1*(`rat8') + /*
        */ sqrt(2)*(`ratio1a')*(( /*
        */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') - /*
        */ (sqrt(2)*(`epsi')*(`ratio7'))/(`sigs2'))) + (`munum')^2*(`sigwi')^2)), eq(4)



   mlvecsum `lnf' `g3' = /*
        */ ((-(`munum'))*(`sigwi0') + ((`ratio1a')*(`ratio6')*(`sigwi0'))/(`sigs2') - (`rat2a')/(`sigz')), eq(3)


   mlvecsum `lnf' `g5'= 0.5*( /*
        */ ((-1)*(`ratio8') + (`munum')^2*(`ratio8')*(`sigs2') + /*
        */ sqrt(2)*(`ratio1a')*(( /*
        */ (-sqrt(2))*(`ratio1')*(`ratio8') - /*
        */ ((`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(2*sqrt(2)*(`sigsta2') /*
        */ ) + (sqrt(2)*(`mu')*(`ratio6')*(`sigwi0'))/(`sigs2'))))), eq(5)


   matrix `g' = (`g1', `g2', `g3', `g4', `g5')

   if (`todo' == 1 | `lnf'>=.) exit

tempname h11 h12 h13 h14 h15 h22 h23 h24 h25 h33 h34 h35 h44 h45 h55 h25a h25b

mlmatsum `lnf' `h11' = /*
   */ -((-(1/(`sigs2'))) - ((`rat8')*(`ratio1')*(`ratio1a'))/(`sigvi')^2 - /*
   */ ((`rat8')*(`ratio1a')^2)/(`sigvi')^2), eq(1)

mlmatsum `lnf' `h12'= cst*( /*
   */ -((-sqrt(2))*(`ratio1a')^2*(`ratio7a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') + /*
   */ (`rat3')/(sqrt(2)*(`sigstar')))) + /*
   */ (`ratio1a')*(`ratio7a')*(( /*
   */ 2 + (`ratio1')^2 + (`ratio2')^2 - ((`rat3')*(`ratio1'))/(`sigstar'))) + /*
   */ ((((-1) + (`rat4')))*(`rat8')*(`ratio1a'))/(`sigstar') - /*
   */ (2*(`rat8')^2*(`ratio1a'))/(`sigstar') - (2*(`munum')*(`sigwi')^2)/(`sigs2') + /*
   */ ((`mu')*(`sigwi0'))/(`sigs2'))), eq(1,2)

mlmatsum `lnf' `h14'= cst*( 0.5*( /*
   */ -((-sqrt(2))*(`ratio1a')^2*(`ratio7a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') - /*
   */ sqrt(2)*(`epsi')*(`ratio7a'))) + /*
   */ ((((-1) + (`rat4')))*(`rat8')*(`ratio1a'))/(`sigstar') - /*
   */ (2*(`rat8')^2*(`ratio1a'))/(`sigstar') + /*
   */ (`ratio1a')*(`ratio7a')*(( /*
   */ 2 + (`ratio1')^2 + (`ratio2')^2 + (2*(`epsi')*(`ratio2'))/(`sigvi'))) - /*
   */ (2*(`munum')*(`sigwi')^2)/(`sigs2')))), eq(1,4)

mlmatsum `lnf' `h13'= cst*( /*
   */ -((`sigwi0')/(`sigs2') - ((`ratio1')*(`ratio1a')*(`sigwi0'))/(`sigs2') - /*
   */ ((`ratio1a')^2*(`sigwi0'))/(`sigs2'))), eq(1,3)

mlmatsum `lnf' `h15'= cst*( 0.5*( /*
   */ -((-2)*(`munum')*(`ratio8') - /*
   */ ((`rat8')*(`ratio1a')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(2*(`sigsta2')* /*
   */ (`sigstar')) - (2*(`ratio1a')*(`ratio6a')*(`sigwi')^2)/(`sigs2') - /*
   */ sqrt(2)*(`ratio1a')^2*(`ratio7a')*(( /*
   */ (-sqrt(2))*(`ratio1')*(`ratio8') - /*
   */ ((`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(2*sqrt(2)*(`sigsta2') /*
   */ ) + sqrt(2)*(`mu')*(`ratio6a')*(`sigwi0'))) + /*
   */ (`ratio1a')*(`ratio7a')*(( /*
   */ (`ratio1')^2 + (`ratio3')^2 - (2*(`mu')*(`ratio1')*(`sigstar')*(`sigwi0'))/(`sigwi')^2) /*
   */ )))), eq(1,5)

mlmatsum `lnf' `h22'= /*
   */ -((-2)*(`rat8') + 2*(`rat8')^2 - /*
   */ 2*(`ratio1a')^2* /*
   */ ((((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') + /*
   */ (`rat3')/(sqrt(2)*(`sigstar'))))^2 + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') + /*
   */ (`rat3')/(sqrt(2)*(`sigstar'))))* /*
   */ (((`ratio1')^2 + (`ratio2')^2 - ((`rat3')*(`ratio1'))/(`sigstar'))) + /*
   */ 2*(`munum')^2*(`sigwi')^2 - (4*(`munum')^2*(`sigwi')^4)/(`sigs2') - /*
   */ (`mu')*(`munum')*(`sigwi0') + (4*(`mu')*(`munum')*(`sigwi')^2*(`sigwi0'))/(`sigs2') - /*
   */ ((`mu')^2*(`sigwi0')^2)/(`sigs2') + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ (3*(((-1) + (`rat4')))^2*(`ratio1'))/sqrt(2) - 2*sqrt(2)*(`rat8')*(`ratio1') - /*
   */ 2*sqrt(2)*(((-1) + (`rat4')))*(`rat8')*(`ratio1') + 4*sqrt(2)*(`rat8')^2*(`ratio1') - /*
   */ 2*sqrt(2)*(`rat3')*(`ratio7a') + (sqrt(2)*(`rat3')*(((-1) + (`rat4'))))/(`sigstar') - /*
   */ ((`ratio1')*(( /*
   */ (-12)*(`ratio4')^2 + 4*(`sigsta2') + (8*(`ratio4')^3)/(`sigvi')) /*
   */ ))/(2*sqrt(2)*(`sigsta2')) + /*
   */ ((-4)*(`epsi')*(`sigwi')^2 + (`mu')*(`sigvi')^2*(`sigwi0'))/(sqrt(2)*(`sigs2')* /*
   */ (`sigstar'))))), eq(2)

mlmatsum `lnf' `h24'= 0.5*( /*
   */ -((-2)*(`rat8') + 2*(`rat8')^2 - /*
   */ 2*(`ratio1a')^2*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') - /*
   */ sqrt(2)*(`epsi')*(`ratio7a')))* /*
   */ ((((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') + /*
   */ (`rat3')/(sqrt(2)*(`sigstar')))) + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ (3*(((-1) + (`rat4')))^2*(`ratio1'))/sqrt(2) - 2*sqrt(2)*(`rat8')*(`ratio1') - /*
   */ 2*sqrt(2)*(((-1) + (`rat4')))*(`rat8')*(`ratio1') + 4*sqrt(2)*(`rat8')^2*(`ratio1') - /*
   */ 2*sqrt(2)*(`epsi')*(`ratio7a') - sqrt(2)*(`rat3')*(`ratio7a') + /*
   */ ((`rat3')*(((-1) + (`rat4'))))/(sqrt(2)*(`sigstar')) - /*
   */ (sqrt(2)*(`epsi')*(((-1) + (`rat4')))*(`rat8'))/(`sigstar') + /*
   */ (2*sqrt(2)*(`epsi')*(`rat8')^2)/(`sigstar') - /*
   */ ((`ratio1')*(( /*
   */ (-12)*(`ratio4')^2 + 4*(`sigsta2') + (8*(`ratio4')^3)/(`sigvi')) /*
   */ ))/(2*sqrt(2)*(`sigsta2')))) + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') + /*
   */ (`rat3')/(sqrt(2)*(`sigstar'))))* /*
   */ (((`ratio1')^2 + (`ratio2')^2 + (2*(`epsi')*(`ratio2'))/(`sigvi'))) + /*
   */ 2*(`munum')^2*(`sigwi')^2 - (4*(`munum')^2*(`sigwi')^4)/(`sigs2') + /*
   */ (2*(`mu')*(`munum')*(`sigwi')^2*(`sigwi0'))/(`sigs2'))), eq(2,4)

mlmatsum `lnf' `h23'= /*
   */ -((-(`munum'))*(`sigwi0') - /*
   */ sqrt(2)*(`ratio1a')^2*(`ratio6a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') + /*
   */ (`rat3')/(sqrt(2)*(`sigstar'))))*(`sigwi0') - /*
   */ (sqrt(2)*(`ratio1')*(`ratio1a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') + /*
   */ (`rat3')/(sqrt(2)*(`sigstar'))))*(`sigstar')*(`sigwi0'))/(`sigwi')^2 + /*
   */ (2*(`munum')*(`sigwi')^2*(`sigwi0'))/(`sigs2') - ((`mu')*(`sigwi0')^2)/(`sigs2') + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ ((`ratio6a')*(`sigwi0'))/sqrt(2) + /*
   */ ((((-1) + (`rat4')))*(`ratio8')*(`sigwi0'))/(sqrt(2)*(`sigstar')) - /*
   */ (sqrt(2)*(`ratio6a')*(`sigwi')^2*(`sigwi0'))/(`sigs2')))), eq(2,3)

mlmatsum `lnf' `h25'= 0.5*( /*
   */ -((-4)*(`munum')^2*(`ratio8')*(`sigwi')^2 + (2*(`ratio8')*(`sigwi')^2)/(`sigs2') + /*
   */ 2*(`mu')*(`munum')*(`ratio8')*(`sigwi0') - /*
   */ 2*(`ratio1a')^2*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') + /*
   */ (`rat3')/(sqrt(2)*(`sigstar'))))* /*
   */ (((-sqrt(2))*(`ratio1')*(`ratio8') - /*
   */ ((`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(2*sqrt(2)*(`sigsta2') /*
   */ ) + sqrt(2)*(`mu')*(`ratio6a')*(`sigwi0'))) + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') + /*
   */ (`rat3')/(sqrt(2)*(`sigstar'))))* /*
   */ (((`ratio1')^2 + (`ratio3')^2 - (2*(`mu')*(`ratio1')*(`sigstar')*(`sigwi0'))/(`sigwi')^2) /*
   */ ) + sqrt(2)*(`ratio1a')*(( /*
   */ (-sqrt(2))*(`rat3')*(`ratio6a') - sqrt(2)*(((-1) + (`rat4')))*(`ratio1')*(`ratio8') - /*
   */ (3*(((-1) + (`rat4')))*(`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2')) /*
   */ ))/(2*sqrt(2)*(`sigsta2')) + /*
   */ ((`rat8')*(`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(sqrt(2)*(`sigsta2') /*
   */ ) - ((`rat3')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(2*sqrt(2)* /*
   */ (`sigsta2')*(`sigstar')) + /*
   */ (4*sqrt(2)*(`ratio1')*(`ratio8')*(`sigwi')^2)/(`sigs2') - /*
   */ ((`ratio1')*(( /*
   */ (-4)*(`ratio4')^2 - 4*(`ratio5')^2 + 4*(`sigsta2') + /*
   */ (8*(`ratio8')^2*(`sigwi')^4)/(`sigs2'))))/(2*sqrt(2)*(`sigsta2')) + /*
   */ sqrt(2)*(`mu')*(`ratio6a')*(`sigwi0') + /*
   */ (sqrt(2)*(`mu')*(((-1) + (`rat4')))*(`ratio8')*(`sigwi0'))/(`sigstar') - /*
   */ (2*sqrt(2)*(`mu')*(`ratio6a')*(`sigwi')^2*(`sigwi0'))/(`sigs2'))))), eq(2,5)

mlmatsum `lnf' `h44'= 0.25*( /*
   */ -((`rat2')*(((-1) + (`rat2')^2))*(`rat2a') + (`rat2')^2*(`rat2a')^2 - 2*(`rat8') + /*
   */ 2*(`rat8')^2 - /*
   */ 2*(`ratio1a')^2* /*
   */ ((((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') - /*
   */ sqrt(2)*(`epsi')*(`ratio7a')))^2 + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ (3*(((-1) + (`rat4')))^2*(`ratio1'))/sqrt(2) - 2*sqrt(2)*(`rat8')*(`ratio1') - /*
   */ 2*sqrt(2)*(((-1) + (`rat4')))*(`rat8')*(`ratio1') + 4*sqrt(2)*(`rat8')^2*(`ratio1') - /*
   */ 2*sqrt(2)*(`epsi')*(`ratio7a') - /*
   */ (2*sqrt(2)*(`epsi')*(((-1) + (`rat4')))*(`rat8'))/(`sigstar') + /*
   */ (4*sqrt(2)*(`epsi')*(`rat8')^2)/(`sigstar') - /*
   */ ((`ratio1')*(( /*
   */ (-12)*(`ratio4')^2 + 4*(`sigsta2') + (8*(`ratio4')^3)/(`sigvi')) /*
   */ ))/(2*sqrt(2)*(`sigsta2')))) + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') - /*
   */ sqrt(2)*(`epsi')*(`ratio7a')))* /*
   */ (((`ratio1')^2 + (`ratio2')^2 + (2*(`epsi')*(`ratio2'))/(`sigvi'))) + /*
   */ 2*(`munum')^2*(`sigwi')^2 - (4*(`munum')^2*(`sigwi')^4)/(`sigs2'))), eq(4)

mlmatsum `lnf' `h34'= 0.5*( /*
   */ -((-sqrt(2))*(`ratio1a')^2*(`ratio6a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') - /*
   */ sqrt(2)*(`epsi')*(`ratio7a')))*(`sigwi0') - /*
   */ (sqrt(2)*(`ratio1')*(`ratio1a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') - /*
   */ sqrt(2)*(`epsi')*(`ratio7a')))*(`sigstar')*(`sigwi0'))/(`sigwi')^2 + /*
   */ (2*(`munum')*(`sigwi')^2*(`sigwi0'))/(`sigs2') + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio8')*(`sigwi0'))/(sqrt(2)*(`sigstar')) - /*
   */ (sqrt(2)*(`ratio6a')*(`sigwi')^2*(`sigwi0'))/(`sigs2'))) - /*
   */ ((`mu')^2*(`rat2a'))/(`sigz')^3 - ((`mu')*(`rat2a')^2)/(`sigz')^2 + (`rat2a')/(`sigz'))), eq(3,4)

mlmatsum `lnf' `h45'= 0.5*(0.5*( /*
   */ -((-4)*(`munum')^2*(`ratio8')*(`sigwi')^2 + (2*(`ratio8')*(`sigwi')^2)/(`sigs2') - /*
   */ 2*(`ratio1a')^2*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') - /*
   */ sqrt(2)*(`epsi')*(`ratio7a')))* /*
   */ (((-sqrt(2))*(`ratio1')*(`ratio8') - /*
   */ ((`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(2*sqrt(2)*(`sigsta2') /*
   */ ) + sqrt(2)*(`mu')*(`ratio6a')*(`sigwi0'))) + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ ((((-1) + (`rat4')))*(`ratio1'))/sqrt(2) - sqrt(2)*(`rat8')*(`ratio1') - /*
   */ sqrt(2)*(`epsi')*(`ratio7a')))* /*
   */ (((`ratio1')^2 + (`ratio3')^2 - (2*(`mu')*(`ratio1')*(`sigstar')*(`sigwi0'))/(`sigwi')^2) /*
   */ ) + sqrt(2)*(`ratio1a')*(( /*
   */ (-sqrt(2))*(((-1) + (`rat4')))*(`ratio1')*(`ratio8') - /*
   */ (3*(((-1) + (`rat4')))*(`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2')) /*
   */ ))/(2*sqrt(2)*(`sigsta2')) + /*
   */ ((`rat8')*(`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(sqrt(2)*(`sigsta2') /*
   */ ) + ((`epsi')*(`rat8')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(sqrt(2)* /*
   */ (`sigsta2')*(`sigstar')) + (2*sqrt(2)*(`epsi')*(`ratio6a')*(`sigwi')^2)/(`sigs2') + /*
   */ (4*sqrt(2)*(`ratio1')*(`ratio8')*(`sigwi')^2)/(`sigs2') - /*
   */ ((`ratio1')*(( /*
   */ (-4)*(`ratio4')^2 - 4*(`ratio5')^2 + 4*(`sigsta2') + /*
   */ (8*(`ratio8')^2*(`sigwi')^4)/(`sigs2'))))/(2*sqrt(2)*(`sigsta2')) + /*
   */ (sqrt(2)*(`mu')*(((-1) + (`rat4')))*(`ratio8')*(`sigwi0'))/(`sigstar') - /*
   */ (2*sqrt(2)*(`mu')*(`ratio6a')*(`sigwi')^2*(`sigwi0'))/(`sigs2')))))), eq(4,5)

mlmatsum `lnf' `h33'= /*
   */ -((-((`sigwi0')^2/(`sigs2'))) - /*
   */ ((`ratio1')*(`ratio1a')*(`ratio8')*(`sigwi0')^2)/(`sigwi')^2 - /*
   */ ((`ratio1a')^2*(`ratio8')*(`sigwi0')^2)/(`sigwi')^2 + ((`mu')*(`rat2a'))/(`sigz')^3 + /*
   */ (`rat2a')^2/(`sigz')^2), eq(3)

mlmatsum `lnf' `h35'= 0.5*( /*
   */ -(2*(`munum')*(`ratio8')*(`sigwi0') - (2*(`ratio1a')*(`ratio8')^2*(`sigwi0'))/(`sigstar') - /*
   */ ((`ratio1a')*(`ratio8')*(((-2)*(`ratio5')^2 + 2*(`sigsta2')))*(`sigwi0'))/(2* /*
   */ (`sigsta2')*(`sigstar')) - /*
   */ sqrt(2)*(`ratio1a')^2*(`ratio6a')*(`sigwi0')*(( /*
   */ (-sqrt(2))*(`ratio1')*(`ratio8') - /*
   */ ((`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(2*sqrt(2)*(`sigsta2') /*
   */ ) + sqrt(2)*(`mu')*(`ratio6a')*(`sigwi0'))) + /*
   */ (`ratio1a')*(`ratio6a')*(`sigwi0')*(( /*
   */ 2 + (`ratio1')^2 + (`ratio3')^2 - /*
   */ (2*(`mu')*(`ratio1')*(`sigstar')*(`sigwi0'))/(`sigwi')^2)))), eq(3,5)


mlmatsum `lnf' `h55'= 0.25*( /*
   */ -((-2)*(`ratio8') + 2*(`ratio8')^2 + 2*(`munum')^2*(`ratio8')*(`sigs2') - /*
   */ 4*(`munum')^2*(`ratio8')^2*(`sigs2') - /*
   */ 2*(`ratio1a')^2* /*
   */ (((-sqrt(2))*(`ratio1')*(`ratio8') - /*
   */ ((`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(2*sqrt(2)*(`sigsta2') /*
   */ ) + sqrt(2)*(`mu')*(`ratio6a')*(`sigwi0')))^2 + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ (-2)*sqrt(2)*(`ratio1')*(`ratio8') + 4*sqrt(2)*(`ratio1')*(`ratio8')^2 + /*
   */ (sqrt(2)*(`ratio1')*(`ratio8')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(`sigsta2') /*
   */ + (3*(`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2')))^2)/(4* /*
   */ sqrt(2)*(`sigsta2')^2) - /*
   */ ((`ratio1')*(( /*
   */ (-12)*(`ratio5')^2 + 4*(`sigsta2') + (8*(`ratio5')^3)/(`sigwi')) /*
   */ ))/(2*sqrt(2)*(`sigsta2')) + 2*sqrt(2)*(`mu')*(`ratio6a')*(`sigwi0') - /*
   */ (4*sqrt(2)*(`mu')*(`ratio8')^2*(`sigwi0'))/(`sigstar') - /*
   */ (sqrt(2)*(`mu')*(`ratio8')*(((-2)*(`ratio5')^2 + 2*(`sigsta2')))*(`sigwi0') /*
   */ )/((`sigsta2')*(`sigstar')))) + /*
   */ sqrt(2)*(`ratio1a')*(( /*
   */ (-sqrt(2))*(`ratio1')*(`ratio8') - /*
   */ ((`ratio1')*(((-2)*(`ratio5')^2 + 2*(`sigsta2'))))/(2*sqrt(2)*(`sigsta2') /*
   */ ) + sqrt(2)*(`mu')*(`ratio6a')*(`sigwi0')))* /*
   */ (((`ratio1')^2 + (`ratio3')^2 - (2*(`mu')*(`ratio1')*(`sigstar')*(`sigwi0'))/(`sigwi')^2) /*
   */ ))) , eq(5)

matrix `H' = -(`h11', `h12', `h13', `h14', `h15' \ `h12'', `h22', `h23', `h24', `h25' \ `h13'', `h23'', `h33', `h34', `h35' \ `h14'', `h24'', `h34'', `h44', `h45' \ `h15'', `h25'', `h35'', `h45'', `h55')


end
