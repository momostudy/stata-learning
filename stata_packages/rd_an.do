  /**********************************************************************************/
  /* program capdrop : Drop a bunch of variables without errors if they don't exist */
  /**********************************************************************************/
  cap prog drop capdrop
  prog def capdrop
  {
    syntax anything
    foreach v in `anything' {
      cap drop `v'
    }
  }
  end
  /* *********** END program capdrop ***************************************** */

  
  /*************************************************************************************/
  /* program rd : produce a nice RD graph, using polynomial (quartic default) for fits */
  /*************************************************************************************/
  global rd_start -120
  global rd_end 120
  cap prog drop rd
  prog def rd
  {
    syntax varlist(min=2 max=2) [aweight pweight] [if], [degree(real 4) name(string) Bins(real 100) Start(real -9999) End(real -9999) MSize(string) YLabel(string) NODRAW bw xtitle(passthru) title(passthru) ytitle(passthru) xlabel(passthru) xline(passthru) absorb(string) control(string) xq(varname) cluster(passthru) nofit]

    tokenize `varlist'
    local xvar `2'

    preserve

    // Create convenient weight local
    if ("`weight'"!="") local wt [`weight'`exp']

    /* set start/end to global defaults (from include) if unspecified */
    if `start' == -9999 & `end' == -9999 {
      local start $rd_start
      local end   $rd_end
    }

    if "`msize'" == "" {
      local msize small
    }

    if "`ylabel'" == "" {
      local ylabel ""
    }
    else {
      local ylabel "ylabel(`ylabel') "
    }

    if "`name'" == "" {
      local name `1'_rd
    }

    /* set colors */
    if mi("`bw'") {
      local color_b "red"
      local color_se "blue"
    }
    else {
      local color_b "black"
      local color_se "gs8"
    }

    if "`se'" == "nose" {
      local color_se "white"
    }

    capdrop pos_rank neg_rank xvar_index xvar_group_mean rd_bin_mean rd_tag mm2 mm3 mm4 l_hat r_hat l_se l_up l_down r_se r_up r_down total_weight rd_resid
    qui {
      /* restrict sample to specified range */
      if !mi("`if'") {
        keep `if'
      }
      keep if inrange(`xvar', `start', `end')

      /* get residuals of yvar on absorbed variables */
      if !mi("`absorb'")  | !mi("`control'") {
        if !mi("`absorb'") {
          areg `1' `wt' `control' `if', absorb(`absorb')
        }
        else {
          reg `1' `wt' `control' `if'
        }
        predict rd_resid, resid
        local 1 rd_resid
      }

      /* GOAL: cut into `bins' equally sized groups, with no groups crossing zero, to create the data points in the graph */
      if mi("`xq'") {

        /* count the number of observations with margin and dependent var, to know how to cut into 100 */
        count if !mi(`xvar') & !mi(`1')
        local group_size = floor(`r(N)' / `bins')

        /* create ranked list of margins on + and - side of zero */
        egen pos_rank = rank(`xvar') if `xvar' > 0 & !mi(`xvar'), unique
        egen neg_rank = rank(-`xvar') if `xvar' < 0 & !mi(`xvar'), unique

        /* hack: multiply bins by two so this works */
        local bins = `bins' * 2

        /* index `bins' margin groups of size `group_size' */
        /* note this conservatively creates too many groups since 0 may not lie in the middle of the distribution */
        gen xvar_index = .
        forval i = 0/`bins' {
          local cut_start = `i' * `group_size'
          local cut_end = (`i' + 1) * `group_size'

          replace xvar_index = (`i' + 1) if inrange(pos_rank, `cut_start', `cut_end')
          replace xvar_index = -(`i' + 1) if inrange(neg_rank, `cut_start', `cut_end')
        }
      }
      /* on the other hand, if xq was specified, just use xq for bins */
      else {
        gen xvar_index = `xq'
      }

      /* generate mean value in each margin group */
      bys xvar_index: egen xvar_group_mean = mean(`xvar') if !mi(xvar_index)

      /* generate value of depvar in each X variable group */
      if mi("`weight'") {
        bys xvar_index: egen rd_bin_mean = mean(`1')
      }
      else {
        bys xvar_index: egen total_weight = total(wt)
        bys xvar_index: egen rd_bin_mean = total(wt * `1')
        replace rd_bin_mean = rd_bin_mean / total_weight
      }

      /* generate a tag to plot one observation per bin */
      egen rd_tag = tag(xvar_index)

      /* run polynomial regression for each side of plot */
      gen mm2 = `xvar' ^ 2
      gen mm3 = `xvar' ^ 3
      gen mm4 = `xvar' ^ 4

      /* set covariates according to degree specified */
      if "`degree'" == "4" {
        local mpoly mm2 mm3 mm4
      }
      if "`degree'" == "3" {
        local mpoly mm2 mm3
      }
      if "`degree'" == "2" {
        local mpoly mm2
      }
      if "`degree'" == "1" {
        local mpoly
      }

      reg `1' `xvar' `mpoly' `wt' if `xvar' < 0, `cluster'
      predict l_hat
      predict l_se, stdp
      gen l_up = l_hat + 1.65 * l_se
      gen l_down = l_hat - 1.65 * l_se

      reg `1' `xvar' `mpoly' `wt' if `xvar' > 0, `cluster'
      predict r_hat
      predict r_se, stdp
      gen r_up = r_hat + 1.65 * r_se
      gen r_down = r_hat - 1.65 * r_se
    }

    if "`fit'" == "nofit" {
      local color_b white
      local color_se gray
    }

    /* fit polynomial to the full data, but draw the points at the mean of each bin */
    sort `xvar'
    twoway ///
      (line r_hat  `xvar' if inrange(`xvar', 0, `end') & !mi(`1'), color(`color_b') lpattern(solid) msize(vtiny)) ///
      (line l_hat  `xvar' if inrange(`xvar', `start', 0) & !mi(`1'), color(`color_b') lpattern(solid) msize(vtiny)) ///
      (line l_up   `xvar' if inrange(`xvar', `start', 0) & !mi(`1'), color(`color_se') lpattern(solid) msize(vtiny)) ///
      (line l_down `xvar' if inrange(`xvar', `start', 0) & !mi(`1'), color(`color_se') lpattern(solid) msize(vtiny)) ///
      (line r_up   `xvar' if inrange(`xvar', 0, `end') & !mi(`1'), color(`color_se') lpattern(solid) msize(vtiny)) ///
      (line r_down `xvar' if inrange(`xvar', 0, `end') & !mi(`1'), color(`color_se') lpattern(solid) msize(vtiny)) ///
      (scatter rd_bin_mean xvar_group_mean if rd_tag == 1 & inrange(`xvar', `start', `end'), xline(0, lcolor(black) lpattern(dot)) msize(`msize') color(black) mstyle(circle)),  `ylabel'  name(`name', replace) legend(off) `title' `xline' `xlabel' `ytitle' `xtitle' `nodraw' graphregion(color(white)) 
    restore
  }
  end
  /* *********** END program rd ***************************************** */

  /*
  
  twoway ///
  (line r_hat  `xvar' if inrange(`xvar', 0, `end') & !mi(`1'), color(`color_b') msize(vtiny)) ///
  (line l_hat  `xvar' if inrange(`xvar', `start', 0) & !mi(`1'), color(`color_b') msize(vtiny)) ///
  (line l_up   `xvar' if inrange(`xvar', `start', 0) & !mi(`1'), color(white) msize(vtiny)) ///
  (line l_down `xvar' if inrange(`xvar', `start', 0) & !mi(`1'), color(white) msize(vtiny)) ///
  (line r_up   `xvar' if inrange(`xvar', 0, `end') & !mi(`1'), color(white) msize(vtiny)) ///
  (line r_down `xvar' if inrange(`xvar', 0, `end') & !mi(`1'), color(white) msize(vtiny)) ///
  (scatter rd_bin_mean xvar_group_mean if rd_tag == 1 & inrange(`xvar', `start', `end'), xline(0, lcolor(black) lpattern(dot)) msize(`msize') color(black)),  `ylabel'  name(`name', replace) legend(off) `title' `xline' `xlabel' `ytitle' `xtitle' `nodraw' graphregion(color(white))

  