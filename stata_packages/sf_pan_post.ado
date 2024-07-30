*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw

*! Modified from sf_pan.ado. Called by sf_predict.

capture program drop sf_pan_post
program define sf_pan_post

   version 8 /* not sure if the running sum works for version 6 */


 tempvar myid

 quie gen `myid' = $pan_id if e(sample)  /* important, to deal with `if' `in' sample */


  tempvar xb gamma mu zdw zdv

        quie predict double `xb'  if e(sample)  , eq(frontier) xb
        quie predict double `zdw' if e(sample)  , eq(usigmas) xb
        quie predict double `zdv' if e(sample)  , eq(vsigmas) xb

        if "$gamfun2" == "" {
             quie gen byte `gamma' = 0 if e(sample)
        }
        else {
             predict double `gamma' if e(sample), eq(gamma) xb
        }

        if "$mufun2" == "" {
             quie gen byte `mu' = 0 if e(sample)
        }
        else {
             predict double `mu' if e(sample), eq(mu) xb
        }



   tempvar sigwi2 sigwi sigvi2 sigvi sigs2 id t uniid last addf bt epsi bepsi Sbepsi Sbt2 Sepsi2
   tempvar mustar sigsta2 comp1 astar nofobs Sbt
   tempname noff T


   quie gen double `sigwi2' = exp(`zdw') if e(sample) /* possible heter in one-sided variance */
   quie gen double `sigwi'  = exp(0.5*(`zdw')) if e(sample)
   quie gen double `sigvi2' = exp(`zdv') if e(sample) /* possible heter in two-sided variance */
   quie gen double `sigvi'  = exp(0.5*(`zdv')) if e(sample)
   quie gen double `sigs2'  = (`sigwi2') + (`sigvi2') if e(sample)

   sort `myid'
   quie gen `uniid' = _n if e(sample) /* creat a uniqu id for sorting purpose */

   sort `myid' `uniid'
   quie by `myid': gen byte `last' = (_n == _N   & e(sample)  ) if e(sample) /* index the last obs in each panel */
   quie by `myid': egen `nofobs' = count(`myid') if e(sample) /* number of obs in each panel */


   quie gen double `addf' = sum(`last') if e(sample)
   scalar `noff' = `addf'[_N] /* the number of firms in the dataset */

   quie gen double `epsi'  = ($hj_sfpan_dep) - (`xb') if e(sample)
  if $PorC == 2 { /* cost frontier */
   quie replace `epsi' = -(`epsi') if e(sample)
   }

  /* --- the Bt part, which will be summed over t ---- */


 if "$Kumbhakar" ~= "" { /* the Kumbhakar 1991 JE model */
     quie gen double `bt' = 2/(1+ exp(`gamma')) if e(sample)
 }
 else if "$invariant" ~= "" { /* the simple model where u_it = 1*u_i = u_i (i.e, time invariant randome effect MLE model) */
     quie gen double `bt' = 1 if e(sample)
 }
 else {   /* a general model, accommodates the decay model of Battese and Coelli (1992) and Lee Schmidt model. */
   quie gen double `bt' = exp(`gamma') if e(sample)
 }


 /* ---- if fixed effects are requested ---------- */

  if $fixed == 1 { /* fixed effect requested, need to demean the B_t */
    tempvar _ttm1 bt_0
    sort `myid'
    quie gen double `bt_0' = `bt' if e(sample) /* non-demanded copy; for E(exp(-u)|e) purpose */
    quie by `myid': egen double `_ttm1' = mean(`bt') if e(sample)
    quie replace `bt' = `bt' - `_ttm1' if e(sample)
  }


   quie gen double `bepsi' = (`bt')*(`epsi') if e(sample)
   sort `myid' `uniid'
   quie by `myid':  gen double `Sbepsi' = sum(`bepsi') if e(sample)
   quie by `myid':  gen double `Sbt2'   = sum((`bt')^2) if e(sample)
   quie by `myid':  gen double `Sepsi2' = sum((`epsi')^2) if e(sample)
   quie by `myid':  gen double `Sbt'    = sum(`bt') if e(sample)


   quie gen double `mustar' = ((`mu')*(`sigvi2') - (`Sbepsi')*(`sigwi2'))/((`sigvi2')+(`sigwi2')*(`Sbt2')) if `last' &  e(sample)
   quie gen double `sigsta2' = (`sigvi2')*(`sigwi2')/((`sigvi2') + (`sigwi2')*(`Sbt2')) if `last' &  e(sample)

   quie gen double `comp1' = ((`mu'*`sigvi2' - `sigwi2'*`Sbepsi')^2)/((`sigvi2')*(`sigwi2')*(`sigvi2' + `sigwi2'*`Sbt2')) if `last' & e(sample)
   quie gen double `astar' = (`Sepsi2')/(`sigvi2') + ((`mu')^2)/(`sigwi2') - `comp1' if `last' & e(sample)



   * mlsum `lnf' = ln( norm((`mustar')/sqrt(`sigsta2'))) + 0.5*ln(`sigsta2') -0.5*`astar' - 0.5*(`nofobs')*ln(2*_pi) /*
   *              */ - (`nofobs')*ln(`sigvi') - ln(`sigwi') - ln( norm((`mu')/(`sigwi')) ) if `last' & e(sample)


  if $fixed == 1 {

   /* --- needed in order to calculate E(exp(-u)|e) ----- */
         * Essentially, terms involving bt need to have this type of operation.
   tempvar bepsi_0 Sbeps_0 Sbt2_0  Sbt_0 musta_0 sigt2_0

   quie gen double `bepsi_0' = (`bt_0')*(`epsi') if e(sample)
   sort `myid' `uniid'
   quie by `myid':  gen double `Sbeps_0' = sum(`bepsi_0') if e(sample)
   quie by `myid':  gen double `Sbt2_0'   = sum((`bt_0')^2) if e(sample)
   quie by `myid':  gen double `Sbt_0'    = sum(`bt_0') if e(sample)
   quie gen double `musta_0' = ((`mu')*(`sigvi2') - (`Sbeps_0')*(`sigwi2'))/((`sigvi2')+(`sigwi2')*(`Sbt2_0')) if `last' &  e(sample)
   quie gen double `sigt2_0' = (`sigvi2')*(`sigwi2')/((`sigvi2') + (`sigwi2')*(`Sbt2_0')) if `last' &  e(sample)

  }



******* for sf_predict **********


capture drop _musta
capture drop _sigst2
capture drop _bt


if $fixed ~= 1 {
  quie gen double _musta = `mustar' if e(sample)
  quie gen double _sigst2 = `sigsta2' if e(sample)
  quie gen double _bt = `bt' if e(sample)
}
if $fixed == 1 {
  quie gen double _musta = `musta_0' if e(sample)
  quie gen double _sigst2 = `sigt2_0' if e(sample)
  quie gen double _bt = `bt_0' if e(sample)
}



end
