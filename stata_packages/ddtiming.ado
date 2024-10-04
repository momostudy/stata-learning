*! version 0.2  13may2019  Thomas Goldring, thomasgoldring@gmail.com

/* CC0 license information:
To the extent possible under law, the author has dedicated all copyright and related and neighboring rights
to this software to the public domain worldwide. This software is distributed without any warranty.

This code is licensed under the CC0 1.0 Universal license.  The full legal text as well as a
human-readable summary can be accessed at http://creativecommons.org/publicdomain/zero/1.0/
*/

program define ddtiming, eclass sortpreserve
  version 13
  
  syntax varlist(min=2 max=2 numeric) [if], [i(varname numeric) ///
    t(varname numeric) Msymbols(string) MColors(string) MSIZes(string) ///
    DDLine(string) noLine SAVEGraph(string) SAVEData(string) replace *]
  
  * Perform checks
  if "`i'" == "" {
    di as err `"A panel variable must be specified using option "i({it:panelvar})""'
    exit 198
  }
  
  if "`t'" == "" {
    di as err `"A time variable must be specified using option "t({it:timevar})""'
    exit 198
  }
  
  if "`ddline'" != "" & "`line'" != "" {
    di as err `"Cannot specify options "ddline" and "noline" together"'
    exit 198
  }

  if "`replace'" == "" {
    if `"`savegraph'"' != "" {
      if regexm(`"`savegraph'"', "\.[a-zA-Z0-9]+$") confirm new file `"`savegraph'"'
      else confirm new file `"`savegraph'.gph"'
    }
    if `"`savedata'"' != "" {
      confirm new file `"`savedata'.csv"'
      confirm new file `"`savedata'.do"'
    }
  }
  
  * Mark sample
  marksample touse
  markout `touse' `i' `t'

  * Parse varlist
  tokenize `varlist'
  local y `1'
  local tr `2'
  
  * Check treatment variable is binary
  if !inlist(`tr',0,1) {
    di as error "Treatment variable must be binary 0/1"
    exit 198
  }
  
  * Create temporary names and variables
  tempname untr_samp_share contr_samp_share tr_samp_share total_untr_samp_share ///
    tr_grps tr_share sigma_term1 sigma_term2 sigma ///
    tmp tmp_s tmp_mu tmp_s_mu tmp_s_1mu ///
    wt_untr wt_untr_tot wt_contr wt_contr_tot wt_tr_e wt_tr_e_tot ///
    wt_tr_l wt_tr_l_tot lrange urange savedatafile ///
    dd_untr_est dd_contr_est dd_e dd_l dd_e_tr_est dd_l_tr_est ///
    dd_est dd_wt dd_mat ///
    untr_est_avg contr_est_avg e_tr_est_avg l_tr_est_avg 
  tempvar tr_time tr_never tr_before gr_dd_est gr_dd_wt gr_dd_type
  
  quietly {
  
  * Calculate treatment time
  noisily di as txt "Calculating treatment times..."
  bys `i' (`t'): gen `tr_time' = `t' * (sum(`tr') == 1 & sum(`tr'[_n-1]) == 0) if `touse'
  bys `i' (`tr_time'): replace `tr_time' = `tr_time'[_N] if `touse'
  
  * Indicators for never treated and already treated groups
  bys `i' (`t'): gen `tr_never' = (`tr'[_N] == 0 & `touse')
  bys `i' (`t'): gen `tr_before' = (`tr'[1] == 1 & `touse')
  replace `tr_time' = 0 if `tr_before' == 1 & `touse'
  
  * Indicator for presence of untreated group
  count if `tr_never' == 1
  if r(N) > 0 local untr 1
  else local untr 0
  
  * Indicator for presence of already treated group
  count if `tr_before' == 1
  if r(N) > 0 local contr 1
  else local contr 0
  
  * CREATE WEIGHTS

  * Group fraction of sample
  tab `tr_time' if `tr_time' == 0 & `tr_before' == 0 & `touse', matcell(`untr_samp_share')
  tab `tr_time' if `tr_time' == 0 & `tr_before' == 1 & `touse', matcell(`contr_samp_share')
  tab `tr_time' if `tr_time' != 0 & `touse', matcell(`tr_samp_share')

  tab `tr_time' if `touse'
  cap mat `untr_samp_share' = `untr_samp_share' / r(N)
  cap mat `contr_samp_share' = `contr_samp_share' / r(N)
  cap mat `tr_samp_share' = `tr_samp_share' / r(N)
  
  if `untr' == 1 & `contr' == 1 {
    mat `total_untr_samp_share' = `untr_samp_share' + `contr_samp_share'
  }
  else if `untr' == 1 & `contr' == 0 {
    mat `total_untr_samp_share' = `untr_samp_share'
  }
  else if `untr' == 0 & `contr' == 1 {
    mat `total_untr_samp_share' = `contr_samp_share'
  }
  
  * Fraction of time spent treated
  tab `tr_time' if `tr_time' != 0 & `touse', matrow(`tr_grps') // Treatment groups by treatment time
  
  forval k = 1/`= rowsof(`tr_grps')' {
    sum `tr' if `tr_time' == `tr_grps'[`k',1] & `touse', meanonly
    mat `tr_share' = nullmat(`tr_share')\r(mean)
  }
  
  * Variance of treatment
  if `untr' == 1 | `contr' == 1 {
    forval k = 1/`= rowsof(`tr_grps')' {
      scalar `tmp' = `tr_samp_share'[`k',1] * `total_untr_samp_share'[1,1] * `tr_share'[`k',1] * (1 - `tr_share'[`k',1])
      mat `sigma_term1' = nullmat(`sigma_term1')\\`tmp'
    }
  }
  forval k = 1/`= rowsof(`tr_grps')' {
    local l = `k' + 1
    while `l' <= `= rowsof(`tr_grps')' {
	  mat `tmp' = `tr_samp_share'[`k',1] * `tr_samp_share'[`l',1] * (`tr_share'[`k',1] - `tr_share'[`l',1]) * (1 - (`tr_share'[`k',1] - `tr_share'[`l',1]))
      mat `sigma_term2' = nullmat(`sigma_term2')\\`tmp'
      local ++l
    }
  }
  
  if `untr' == 1 | `contr' == 1 {
    mata : st_matrix("`sigma'", colsum(st_matrix("`sigma_term1'")) + colsum(st_matrix("`sigma_term2'")))
  }
  else {
    mata : st_matrix("`sigma'", colsum(st_matrix("`sigma_term2'")))
  }
  
  noisily di as txt "Calculating weights..."
  
  * Weights where comparison group is untreated (never treated)
  if `untr' == 1 {
    forvalues k = 1/`= rowsof(`tr_grps')' {
      mat `tmp' = `k',0,((`tr_samp_share'[`k',1] * `untr_samp_share'[1,1] * `tr_share'[`k',1] * (1 - `tr_share'[`k',1])) / `sigma'[1,1]),3
      mat `wt_untr' = nullmat(`wt_untr')\\`tmp'
    }
	mata : st_matrix("`wt_untr_tot'", colsum(st_matrix("`wt_untr'")[1...,3]))
	mata : st_matrix("`tmp'", st_matrix("`wt_untr'")[1...,3] / st_matrix("`wt_untr_tot'"))
	mat `wt_untr' = `wt_untr',`tmp'  // Columns: treatment group, comparison group, weight, comparison type, weight scaled to 1
  }
  
  * Weights where comparison group is untreated (already treated)
  if `contr' == 1 {
    forvalues k = 1/`= rowsof(`tr_grps')' {
      mat `tmp' = `k',0,((`tr_samp_share'[`k',1] * `contr_samp_share'[1,1] * `tr_share'[`k',1] * (1 - `tr_share'[`k',1])) / `sigma'[1,1]),4
      mat `wt_contr' = nullmat(`wt_contr')\\`tmp'
    }
	mata : st_matrix("`wt_contr_tot'", colsum(st_matrix("`wt_contr'")[1...,3]))
	mata : st_matrix("`tmp'", st_matrix("`wt_contr'")[1...,3] / st_matrix("`wt_contr_tot'"))
	mat `wt_contr' = `wt_contr',`tmp'
  }
  
  * Weights where comparison group is ever treated
  forvalues k = 1/`= rowsof(`tr_grps')' {
    local l = `k' + 1
    while `l' <= `= rowsof(`tr_grps')' {
      mat `tmp_s' = (`tr_samp_share'[`k',1] * `tr_samp_share'[`l',1] * (`tr_share'[`k',1] - `tr_share'[`l',1]) * (1 - (`tr_share'[`k',1] - `tr_share'[`l',1]))) / `sigma'[1,1]
      mat `tmp_mu' = (1 - `tr_share'[`k',1]) / (1 - (`tr_share'[`k',1] - `tr_share'[`l',1]))
      
      mat `tmp_s_mu' = `k',`l',(`tmp_s' * `tmp_mu'),1
      mat `tmp_s_1mu' = `l',`k',(`tmp_s' * (1 - `tmp_mu')),2
      
      mat `wt_tr_e' = nullmat(`wt_tr_e')\\`tmp_s_mu'   // e = Treatment's treatment earlier than comparison's treatment
      mat `wt_tr_l' = nullmat(`wt_tr_l')\\`tmp_s_1mu'  // l = Treatment's treatment later than comparison's treatment
      
      local ++l
    }
  }
  mata : st_matrix("`wt_tr_e'", sort(st_matrix("`wt_tr_e'"), (1,2)))
  mata : st_matrix("`wt_tr_l'", sort(st_matrix("`wt_tr_l'"), (1,2)))
  
  mata : st_matrix("`wt_tr_e_tot'", colsum(st_matrix("`wt_tr_e'")[1...,3]))
  mata : st_matrix("`tmp'", st_matrix("`wt_tr_e'")[1...,3] / st_matrix("`wt_tr_e_tot'"))
  mat `wt_tr_e' = `wt_tr_e',`tmp'  // Columns: treatment group, comparison group, weight, comparison type, weight scaled to 1

  mata : st_matrix("`wt_tr_l_tot'", colsum(st_matrix("`wt_tr_l'")[1...,3]))
  mata : st_matrix("`tmp'", st_matrix("`wt_tr_l'")[1...,3] / st_matrix("`wt_tr_l_tot'"))
  mat `wt_tr_l' = `wt_tr_l',`tmp'
  
  * ESTIMATE 2x2 DIFF-IN-DIFF REGRESSIONS
  
  noisily di as text "Estimating 2x2 diff-in-diff regressions..."
  
  * Never treated diff-in-diff estimates
  if `untr' == 1 {
    forvalues k = 1/`= rowsof(`tr_grps')' {
      sum `t'
      mat `tmp' = `k',0,`tr_grps'[`k',1],0,r(min),r(max),3
      areg `y' `tr' i.`i' if (`tr_never' == 1 | `tr_time' == `tr_grps'[`k',1]) & `touse', a(`t')
      mat `tmp' = `tmp',_b[`tr'] 
      mat `dd_untr_est' = nullmat(`dd_untr_est')\\`tmp'
     // Columns: (1) treatment group (2) comparison group (3) treatment's treatment time
     //  (cont.) (4) comparison's treatment time (5) start time (6) end time
     //  (cont.) (7) comparison category (8) diff-in-diff estimate
    }
  }
  
  * Already treated diff-in-diff estimates
  if `contr' == 1 {
    forvalues k = 1/`= rowsof(`tr_grps')' {
      sum `t'
      mat `tmp' = `k',0,`tr_grps'[`k',1],0,r(min),r(max),4
      areg `y' `tr' i.`i' if (`tr_before' == 1 | `tr_time' == `tr_grps'[`k',1]) & `touse', a(`t')
      mat `tmp' = `tmp',_b[`tr'] 
      mat `dd_contr_est' = nullmat(`dd_contr_est')\\`tmp'
    }
  }
  
  * Calculate lower and upper ranges for treatment time (only one range is used in each regression)
  sum `t'
  forvalues k = 1/`= rowsof(`tr_grps')' {
    mat `lrange' = nullmat(`lrange')\[r(min),`tr_grps'[`k',1] - 1]
    mat `urange' = nullmat(`urange')\[`tr_grps'[`k',1],r(max)]
    // Columns: (1) time lower bound (2) time upper bound
  }
  forvalues k = 1/`= rowsof(`tr_grps')' {           // Treatment index
    forvalues l = 1/`= rowsof(`tr_grps')' {         // Comparison index
      if `k' != `l' {
        mat `tmp' = `k',`l',`tr_grps'[`k',1],`tr_grps'[`l',1]
        
        if `tmp'[1,3] < `tmp'[1,4] {                // If treatment's treatment time < comparison's treatment time
          mat `tmp' = `tmp',`lrange'[`l',1...],1    // ... use range below comparison's treatment time
        }
        else mat `tmp' = `tmp',`urange'[`l',1...],2 // ... else use range above comparison's treatment time
        
        if `k' < `l' mat `dd_e' = nullmat(`dd_e')\\`tmp'
        else mat `dd_l' = nullmat(`dd_l')\\`tmp'
      }
    }
  }
  
  local earlylate "e l"
  foreach x of local earlylate {
    forvalues k = 1/`= rowsof(`dd_`x'')' {
      areg `y' `tr' i.`i' if ///
        (`tr_time' == `dd_`x''[`k',3] | `tr_time' == `dd_`x''[`k',4]) & ///
        `t' >= `dd_`x''[`k',5] & `t' <= `dd_`x''[`k',6] & `touse', a(`t')
      mat `dd_`x'_tr_est' = nullmat(`dd_`x'_tr_est')\_b[`tr']
    }
    mat `dd_`x'_tr_est' = `dd_`x'',`dd_`x'_tr_est'
    mata : st_matrix("`dd_`x'_tr_est'", sort(st_matrix("`dd_`x'_tr_est'"), (1,2)))
  }
  
  * Stitch DD and weights matrices together
  mat `dd_est' = `dd_e_tr_est'\\`dd_l_tr_est'
  mat `dd_wt' = `wt_tr_e'\\`wt_tr_l'
  
  if `untr' == 1 {
    mat `dd_est' = `dd_est'\\`dd_untr_est'
    mat `dd_wt' = `dd_wt'\\`wt_untr'
  }
  if `contr' == 1 {
    mat `dd_est' = `dd_est'\\`dd_contr_est' // 2x2 DD estimates matrix
    mat `dd_wt' = `dd_wt'\\`wt_contr'       // Weights matrix
  }
  
  * Put matrices in tempvars for graphing
  gen `gr_dd_est' = .
  gen `gr_dd_wt' = .
  gen `gr_dd_type' = .

  forval k = 1/`= rowsof(`dd_est')' {
    replace `gr_dd_est' = `dd_est'[`k',8] in `k'
    replace `gr_dd_wt' = `dd_wt'[`k',3] in `k'
    replace `gr_dd_type' = `dd_est'[`k',7] in `k'
  }
  
  } // Ends quietly
  
  * Calculate DD estimate
  mata : st_matrix("`dd_mat'", st_matrix("`dd_est'")[1...,8] :* st_matrix("`dd_wt'")[1...,3])
  mata : st_matrix("`dd_mat'", colsum(st_matrix("`dd_mat'"))) // Two-way FE estimate
  
  * Calculate weighted DD estimates by comparison type
  if `untr' == 1 {
    mata : st_matrix("`untr_est_avg'", st_matrix("`dd_untr_est'")[1...,8] :* st_matrix("`wt_untr'")[1...,5])
    mata : st_matrix("`untr_est_avg'", colsum(st_matrix("`untr_est_avg'")))
  }
  
  if `contr' == 1 {
    mata : st_matrix("`contr_est_avg'", st_matrix("`dd_contr_est'")[1...,8] :* st_matrix("`wt_contr'")[1...,5])
    mata : st_matrix("`contr_est_avg'", colsum(st_matrix("`contr_est_avg'")))
  }
  
  mata : st_matrix("`e_tr_est_avg'", st_matrix("`dd_e_tr_est'")[1...,8] :* st_matrix("`wt_tr_e'")[1...,5])
  mata : st_matrix("`l_tr_est_avg'", st_matrix("`dd_l_tr_est'")[1...,8] :* st_matrix("`wt_tr_l'")[1...,5])
  
  mata : st_matrix("`e_tr_est_avg'", colsum(st_matrix("`e_tr_est_avg'")))
  mata : st_matrix("`l_tr_est_avg'", colsum(st_matrix("`l_tr_est_avg'")))
  
  * PREPARE GRAPH
  
  * Define scatter command
  forval k = 1/4 {
    local scatter`k' "scatter `gr_dd_est' `gr_dd_wt' if `gr_dd_type' == `k'"
  }
  
  * Define labels
  local legend1 `"lab(1 "Earlier Group Treatment vs. Later Group Comparison")"'
  local legend2 `"lab(2 "Later Group Treatment vs. Earlier Group Comparison")"'
  
  if `untr' == 1 local legend3 `"lab(3 "Treatment vs. Never Treated")"'
  
  if `untr' == 1 & `contr' == 1 local legend4 `"lab(4 "Treatment vs. Already Treated")"'
  if `untr' == 0 & `contr' == 1 local legend4 `"lab(3 "Treatment vs. Already Treated")"'
    
  * Define marker symbols
  local msym1 "X"
  local msym2 "X"
  local msym3 "T"
  local msym4 "Oh"
  
  if "`msymbols'" != "" {
    forval k = 1/`: word count `msymbols'' {
      local msym`k' : word `k' of `msymbols'
    }
  }
  
  * Define marker colors
  local mcol1 "gs8"
  local mcol2 "black"
  local mcol3 "gs6"
  local mcol4 "black"
  
  if "`mcolors'" != "" {
    forval k = 1/`: word count `mcolors'' {
      local mcol`k' : word `k' of `mcolors'
    }
  }
  
  * Define marker sizes
  local msiz1 "medium"
  local msiz2 "medium"
  local msiz3 "medium"
  local msiz4 "medium"
  
  if "`msizes'" != "" {
    forval k = 1/`: word count `msizes'' {
      local msiz`k' : word `k' of `msizes'
    }
  }
  
  forval k = 1/4 {
    local scatter`k' "(`scatter`k'', ms(`msym`k'') mc(`mcol`k'') msiz(`msiz`k''))"
  }
  if `untr' == 0 local scatter3 ""
  if `contr' == 0 local scatter4 ""
  
  if "`line'" == "" {
    local gr_dd = `dd_mat'[1,1]
    local yline "yline(`gr_dd',`ddline')"
  }
  else local yline ""

  local graphcmd tw `scatter1' `scatter2' `scatter3' `scatter4', ///
    xlabel(,format(%5.2f)) ytitle("2x2 DD Estimate") xtitle("Weight") ///
	`yline' graphregion(color(white)) legend(col(1) `legend_order' ///
	`legend1' `legend2' `legend3' `legend4') `options'
  `graphcmd'
  
  local graphsave tw (scatter dd_est dd_wt if dd_type == 1) ///
    (scatter dd_est dd_wt if dd_type == 2)
  
  if `untr' == 1 local graphsave `graphsave' (scatter dd_est dd_wt if dd_type == 3)
  if `contr' == 1 local graphsave `graphsave' (scatter dd_est dd_wt if dd_type == 4)
  
  local graphsave_opts xlabel(,format(%5.2f)) ytitle("2x2 DD Estimate") xtitle("Weight") ///
    `yline' graphregion(color(white)) legend(col(1) `legend_order' ///
	`legend1' `legend2' `legend3' `legend4') `options'
  
  * Save graph
  if `"`savegraph'"' != "" {
    if regexm(`"`savegraph'"',"\.[a-zA-Z0-9]+$") local graphextension = regexs(0) /// Check file extension using a regular expression
    if inlist(`"`graphextension'"',".gph","") graph save `"`savegraph'"', `replace'
    else graph export `"`savegraph'"', `replace'
  }
  
  * Return scalars
  ereturn clear
  ereturn scalar dd = `dd_mat'[1,1]
  ereturn scalar dd_avg_e = `e_tr_est_avg'[1,1]
  ereturn scalar dd_avg_l = `l_tr_est_avg'[1,1]
  if `untr' == 1 {
    ereturn scalar dd_avg_u = `untr_est_avg'[1,1]
  }
  if `contr' == 1 {
    ereturn scalar dd_avg_a = `contr_est_avg'[1,1]
  }
  ereturn scalar wt_sum_e = `wt_tr_e_tot'[1,1]
  ereturn scalar wt_sum_l = `wt_tr_l_tot'[1,1]
  if `untr' == 1 {
    ereturn scalar wt_sum_u = `wt_untr_tot'[1,1]
  }
  if `contr' == 1 {
    ereturn scalar wt_sum_a = `wt_contr_tot'[1,1]
  }
  
  * Print output
  di as smcl as txt ""
  di as smcl as txt "Diff-in-diff estimate: " as res %-9.3f `dd_mat'[1,1]
  di as smcl as txt ""
  di as smcl as txt "DD Comparison              Weight      Avg DD Est"
  di as smcl as txt "{hline 49}"
  di as smcl as txt "Earlier T vs. Later C       " as res %5.3f `wt_tr_e_tot'[1,1] "       " as res %9.3f `e_tr_est_avg'[1,1]
  di as smcl as txt "Later T vs. Earlier C       " as res %5.3f `wt_tr_l_tot'[1,1] "       " as res %9.3f `l_tr_est_avg'[1,1]
  if `untr' == 1 {
    di as smcl as txt "T vs. Never treated         " as res %5.3f `wt_untr_tot'[1,1] "       " as res %9.3f `untr_est_avg'[1,1]
  }
  if `contr' == 1 {
    di as smcl as txt "T vs. Already treated       " as res %5.3f `wt_contr_tot'[1,1] "       " as res %9.3f `contr_est_avg'[1,1]
  }
  di as smcl as txt "{hline 49}"
  di as smcl as txt "T = Treatment; C = Comparison"

  * Save data
  if "`savedata'" != "" {
    file open `savedatafile' using `"`savedata'.csv"', write text `replace'
    file write `savedatafile' "dd_est,weight,weight_rescale,time_lower,time_upper,dd_type" _n // Row headers
    
    forvalues k = 1/`= rowsof(`dd_est')' {
      file write `savedatafile' (`dd_est'[`k',8]) "," (`dd_wt'[`k',3]) "," (`dd_wt'[`k',5]) "," (`dd_est'[`k',5]) "," (`dd_est'[`k',6]) "," (`dd_est'[`k',7]) _n
    }
    
    file close `savedatafile'
    di as smcl as txt ""
    di as smcl as txt `"File `savedata'.csv written containing saved data"'

    * Save a do-file with the commands to generate a labeled dataset and re-create the ddtiming graph
    file open `savedatafile' using `"`savedata'.do"', write text `replace'
    file write `savedatafile' `"insheet using `savedata'.csv"' _n _n
    
    file write `savedatafile' `"label var dd_est "2x2 DD estimate""' _n
    file write `savedatafile' `"label var weight "2x2 DD weight""' _n
	file write `savedatafile' `"label var weight_rescale "2x2 DD weight rescaled within comparison type""' _n
    file write `savedatafile' `"label var time_lower "2x2 DD time lower bound""' _n
    file write `savedatafile' `"label var time_upper "2x2 DD time upper bound""' _n
    file write `savedatafile' `"label var dd_type "2x2 DD types""' _n _n
    file write `savedatafile' `"label define dd_type 1 "Earlier T vs. Later C" 2 "Later T vs. Earlier C" 3 "T vs. Never T" 4 "T vs. Already T""' _n
    file write `savedatafile' `"label values dd_type dd_type"' _n _n

	file write `savedatafile' `"`graphsave'"' `"`graphsave_opts'"' _n
	
    file close `savedatafile'
    di as smcl as txt `"File `savedata'.do written containing commands to process saved data"'

  }

end

