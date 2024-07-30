*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw

* v 1.1: allow zdw and zdv to be vector of vars
capture program drop sf_pan
program define sf_pan

   version 12 /* not sure if the running sum works for version 6 */
   args todo b lnf


   tempvar uniid
   quie gen `uniid' = _n if $ML_samp /* creat a uniqu id for sorting purpose */


  tempvar xb gamma mu zdw zdv

   local ii = 1
   foreach X in xb $mufun2 $gamfun2 zdw zdv {
     mleval ``X'' = `b', eq(`ii')
     local ii = `ii' + 1
   }


if "$gamfun2" == "" {
     quie gen byte `gamma' = 0
}
if "$mufun2" == "" {
     quie gen byte `mu' = 0
}



   tempvar sigwi2 sigwi sigvi2 sigvi sigs2 id t  last addf bt epsi bepsi Sbepsi Sbt2 Sepsi2
   tempvar mustar sigsta2 comp1 astar nofobs Sbt
   tempname noff T


   quie gen double `sigwi2' = exp(`zdw') /* possible heter in one-sided variance */
   quie gen double `sigwi'  = exp(0.5*(`zdw'))
   quie gen double `sigvi2' = exp(`zdv') /* possible heter in two-sided variance */
   quie gen double `sigvi'  = exp(0.5*(`zdv'))
   quie gen double `sigs2'  = (`sigwi2') + (`sigvi2')

*   sort $pan_id
*   quie gen `uniid' = _n if $ML_samp /* creat a uniqu id for sorting purpose */

   sort $pan_id `uniid'
   quie by $pan_id: gen byte `last' = (_n == _N & $ML_samp) /* index the last obs in each panel */
   quie by $pan_id: egen `nofobs' = count($pan_id) if $ML_samp /* number of obs in each panel */


   quie gen double `addf' = sum(`last')
   scalar `noff' = `addf'[_N] /* the number of firms in the dataset */

   quie gen double `epsi'  = ($ML_y1) - (`xb') if $ML_samp
  if $PorC == 2 { /* cost frontier */
   quie replace `epsi' = -(`epsi')
   }


  /* --- the Bt part, which will be summed over t ---- */


 if "$Kumbhakar" ~= "" { /* the Kumbhakar 1991 JE model */
     quie gen double `bt' = 2/(1+ exp(`gamma')) if $ML_samp
 }
 else if "$invariant" ~= "" { /* the simple model where u_it = 1*u_i = u_i (i.e, time invariant randome effect MLE model) */
     quie gen double `bt' = 1 if $ML_samp
 }
 else {   /* a general model, accommodates the decay model of Battese and Coelli (1992) and Lee Schmidt model. */
   quie gen double `bt' = exp(`gamma') if $ML_samp
 }


 /* ---- if fixed effects are requested ---------- */

  if $fixed == 1 { /* fixed effect requested, need to demean the B_t */
    tempvar _ttm1 bt_0
    sort $pan_id
    quie gen double `bt_0' = `bt' if $ML_samp /* non-demanded copy; for E(exp(-u)|e) purpose */
    quie by $pan_id: egen double `_ttm1' = mean(`bt') if $ML_samp
    quie replace `bt' = `bt' - `_ttm1' if $ML_samp
  }


   quie gen double `bepsi' = (`bt')*(`epsi')
   sort $pan_id `uniid'
   quie by $pan_id:  gen double `Sbepsi' = sum(`bepsi') if $ML_samp
   quie by $pan_id:  gen double `Sbt2'   = sum((`bt')^2) if $ML_samp
   quie by $pan_id:  gen double `Sepsi2' = sum((`epsi')^2) if $ML_samp
   quie by $pan_id:  gen double `Sbt'    = sum(`bt') if $ML_samp


   quie gen double `mustar' = ((`mu')*(`sigvi2') - (`Sbepsi')*(`sigwi2'))/((`sigvi2')+(`sigwi2')*(`Sbt2')) if `last' &  $ML_samp
   quie gen double `sigsta2' = (`sigvi2')*(`sigwi2')/((`sigvi2') + (`sigwi2')*(`Sbt2')) if `last' &  $ML_samp

   quie gen double `comp1' = ((`mu'*`sigvi2' - `sigwi2'*`Sbepsi')^2)/((`sigvi2')*(`sigwi2')*(`sigvi2' + `sigwi2'*`Sbt2')) if `last' & $ML_samp
   quie gen double `astar' = (`Sepsi2')/(`sigvi2') + ((`mu')^2)/(`sigwi2') - `comp1' if `last' & $ML_samp


   mlsum `lnf' = lnnormal((`mustar')/sqrt(`sigsta2')) + 0.5*ln(`sigsta2') -0.5*`astar' - 0.5*(`nofobs')*ln(2*_pi) /*
                 */ - (`nofobs')*ln(`sigvi') - ln(`sigwi') - lnnormal((`mu')/(`sigwi'))  if `last' & $ML_samp

*   mlsum `lnf' = ln( normal((`mustar')/sqrt(`sigsta2'))) + 0.5*ln(`sigsta2') -0.5*`astar' - 0.5*(`nofobs')*ln(2*_pi) /*
*                 */ - (`nofobs')*ln(`sigvi') - ln(`sigwi') - ln( normal((`mu')/(`sigwi')) ) if `last' & $ML_samp



  if $fixed == 1 {

   /* --- needed in order to calculate E(exp(-u)|e) ----- */
         * Essentially, terms involving bt need to have this type of operation.
   tempvar bepsi_0 Sbeps_0 Sbt2_0  Sbt_0 musta_0 sigt2_0

   quie gen double `bepsi_0' = (`bt_0')*(`epsi')
   sort $pan_id `uniid'
   quie by $pan_id:  gen double `Sbeps_0' = sum(`bepsi_0') if $ML_samp
   quie by $pan_id:  gen double `Sbt2_0'   = sum((`bt_0')^2) if $ML_samp
   quie by $pan_id:  gen double `Sbt_0'    = sum(`bt_0') if $ML_samp
   quie gen double `musta_0' = ((`mu')*(`sigvi2') - (`Sbeps_0')*(`sigwi2'))/((`sigvi2')+(`sigwi2')*(`Sbt2_0')) if `last' &  $ML_samp
   quie gen double `sigt2_0' = (`sigvi2')*(`sigwi2')/((`sigvi2') + (`sigwi2')*(`Sbt2_0')) if `last' &  $ML_samp

  }



******* for sf_predict **********

/*

capture drop _musta
capture drop _sigst2
capture drop _bt


if $fixed ~= 1 {
  quie gen double _musta = `mustar' if $ML_samp
  quie gen double _sigst2 = `sigsta2' if $ML_samp
  quie gen double _bt = `bt' if $ML_samp
}
if $fixed == 1 {
  quie gen double _musta = `musta_0' if $ML_samp
  quie gen double _sigst2 = `sigt2_0' if $ML_samp
  quie gen double _bt = `bt_0' if $ML_samp
}

sum _musta _sigst2 _bt

*/

end
