***********************************************************************
*                           Warning:
*            The code contained in this ado file
*            is provided for informational purposes only.
*            It comes with no support or warranties. 
*            If you use it, do so at your own risk.
***********************************************************************

***********************************************************************
*                   Note to Mac and Unix users:
*
*         This code was developed in a Microsoft Windows 
*         environment. Using this program gives a syntax error 
*         on Unix-based computers and from what I understand is 
*         related to the size specification in the title option
*         of the plot command. This issue might be addressed in 
*         the future.
*
***********************************************************************

*********************************************************************** 
* BUNCHING PROGRAM
* 
* OBJECTIVE: PLOTTING AND QUANTIFYING BUNCHING AT KINK POINTS
* TORE OLSEN, 2008 with formatting update in 2012
*
* For detailed information on the technique used to calculate 
* bunching at kink points, see:
*
*            Chetty, Friedman, Olsen and Pistaferri
*               Adjustment Costs, Firm Responses, 
*        and Micro vs. Macro Labor Supply Elasticities:
*               Evidence from Danish Tax Records
*
*  The Quarterly Journal of Economics, 2011, 126 (2): 749-804
***********************************************************************

***********************************************************************
* NOTE: This version of the program requires that data has been 
* collapsed in (income) bins and a count variable already created.
*
* The basic syntax is:
* bunch_count income_variable count_variable
* 
* There are a wealth of options so for more details see the help file.
***********************************************************************



*********************************************************************** 
* THIS PROGRAM CALCULATES THE SIZE OF "BUNCHING" (HUMP) IN A DENSITY
*********************************************************************** 
***Size of Bunching
	*set trace on
	*set tracedepth 1

cap program drop bunch_count
program define bunch_count, rclass
	version 9.1
	syntax varlist(min=2 max=2 numeric) [if] [in] [,            	        ///
	 																		///
			/* BunchEngine Options */  										///
			int2one(integer 1)	max_it(integer 200) nboot(integer 0)        ///
            degree(integer 7)                                               ///
            binwidth(real 200) bpoint(real 0)                               ///
            ig_low(integer -50) ig_high(integer 50)                         ///
            low_bunch(integer -7)                                           ///
            high_bunch(integer 7)                                           ///
                                                                            ///
            /* PlotEngine Options */                                        ///
            plot(integer 0) plot_fit(integer 1)                             ///
            graph_dir(string)  graph_name(string)                           ///
            graph_step(integer 10)                                          ///
            pct_hgt(integer 101)                                            ///
            zoom_low (integer 0) zoom_high(integer 0)                       ///
            use_xline(integer 1) xline(integer 0)                           ///
            use_xline2(integer 0) xline2(integer 0)                         ///
            use_xline3(integer 0) xline3(integer 0)                         ///
            use_xtitle(integer 1) xtitle(string)                            ///
            outvar(string) png_export(integer 0) wmf_export(integer 1)      ///            
                                                                            ///            
            /* Debug Options */                                             ///
            set_trace(integer 0)    di_time(integer 0)  ]                                                                 
            
        
    if `di_time'==1 noi di as yellow "$S_TIME begin" 
    

    quietly{
        * LOGISTICS
        
                local income "`1'"
                local count  "`2'"
                
                if substr(`"`count'"',-1,1)==","{
                    local lngth=length(`"`count'"')-1
                    local count = substr(`"`count'"',1,`lngth')
                }
        
            * DEFINING TEMPORARY VARIABLES
                tempvar                                                     ///
                touse relevant_est relevant_plot near_bunchpoint            ///
                inc_grp_est inc_grp_plot                                    ///
                people_in_incgrp people_in_incgrp_HAT  
                
            * Mark relevant observations
	            mark `touse' `if' `in' 
        
            * SET TRACE OPTION (for debugging purporses)
                if `set_trace'~=0{
                    cap set trace on
                    set tracedepth `set_trace'
                }
                            else{
                    cap set trace off
                }
                

                
            * Dealing with unspecified xtitle
                if `use_xtitle'==0 {
                    local xtitle_command = ""
                }
                else {
                    if `"`xtitle'"'=="" {
                        local xtitle_command `" xtitle("Bin group") "'
                    }
                    else {
                        local xtitle_command `" xtitle(`"`xtitle'"') "'
                    }
                }
            
            * Extract sort order to be able to sort data back 
            * in original order when program is over
                qui describe, short varlist
                local sortlist=r(sortlist)
        
            * Get working directory
                local init_dir = c(pwd)
            
            * Set graph directory
                if "`graph_dir'"==""{
                    local graph_dir "`init_dir'"  
                }
                else {
                    tore_cd, dir("`graph_dir'") quiet(1) mkdir(1)
                    * so far `graph_dir' could be an absolute or relative path
                    * - from here on it will be an absolute path
                    local graph_dir = c(pwd)
                }
                
            * Setting options that might have been left empty
                if "`outvar'"==""{
                    local outvar "plotabc"
                }
                if "`graph_name'"==""{
                    local graph_name "bunching"
                }
                if "`step_method'"==""{
                    local step_method "round"  
                }
                if `zoom_low'==0 {
                    local zoom_low     = `ig_low'
                }
                if `zoom_high'==0 {
                    local zoom_high     = `ig_high'
                }
                
            * other basic stuff
                local yaxis_min=0
                local yaxis_max=0

            * getting # bins in graph and in bunching window
                local n_ig            = `ig_high'            - `ig_low'+1
                local n_ig_nearbunch    = `high_bunch'    - `low_bunch'+1       
                
        
        * CHECK THAT EACH BIN ONLY OCCURS ONCE
        * - data is supposed to be pre-collapsed in such a way that
        * conditional on `if' `in'
        * there is one observation per income-bin 
        * in the income-range analysed
        *
        * Data example:
        * Income    Gender  Count
        * 1000           0     12
        * 1000           1     23
        * 2000           0     15
        * 2000           1     26
        * 3000           0     13
        * 3000           1     27
        * 4000           0     10
        * 4000           1     25
        * - etc
        * - here the each bin is unique contional on a gender=0 (or gender=1)
        * - but data would NOT be ready for analysis without having a specific gender condition
        
            local lw      = (`bpoint'+`ig_low'*`binwidth') 
            local hi      = (`bpoint'+`ig_high'*`binwidth')
            local incomerange     `" `income'>= `lw' & `income'<= `hi' "'
            
            qui tab `income' if `touse' &  `incomerange', matcell(FREQcheck)
            local nrf = rowsof(FREQcheck)
            * if uniqueness is satisfied, FREQcheck should be a column of ones,
            * so the sum over this column should equal the number of rows it has.
            matrix help=J(1,`nrf',1)*FREQcheck
            if help[1,1]!=`nrf' {
                di as error "Bins are not unique"
                exit 110
            }


        * DEFINING SAMPLE (as income relative to bunching point)
            
            * DEFINING BINS RELATIVE TO BUNCH-POINT
                g `inc_grp_est'            = `step_method'((`income'  - `bpoint')/`binwidth')
                g `inc_grp_plot'            = `inc_grp_est'
                
            * NOTE: now we work on data looking like
            * Income    Gender  Count   `inc_grp_est'
            * 1000           0     12             -2
            * 1000           1     23             -2
            * 2000           0     15             -1
            * 2000           1     26             -1
            * 3000           0     13              0
            * 3000           1     27              0
            * 4000           0     10              1
            * 4000           1     25              1
            * etc (if bunch point belongs to the $3000 bin)
            
            * FORMING INDICATOR VARIABLES FOR OBSERVATIONS RELEVANT TO ESTIMATION
                g byte `relevant_est'         = `touse' & (`inc_grp_est' <= `ig_high') & (`inc_grp_est' >= `ig_low')
                    replace `inc_grp_est'            = . if `relevant_est'~=1            
            
            * FORMING INDICATOR VARIABLES FOR OBSERVATIONS THAT WILL BE PLOTTED
                g byte `relevant_plot'        = `touse' & (`inc_grp_plot' <= `zoom_high') & (`inc_grp_plot' >= `zoom_low')  
                    replace `inc_grp_plot'            = . if `relevant_plot'~=1
            
            * CHECK THAT BUNCH-POINT EXISTS IN DATA
                qui count if `inc_grp_est'==0
                local bpoint_cnt=r(N)
                if `bpoint_cnt'==0 {
                    di as error "Bunchpoint `bpoint' does not exist as an income group in the data"
                    exit 110
                }
            
            * CHECK THAT THERE ARE NO HOLES IN THE SAMPLE DISTRIBUTION
            
                * COUNTING RELEVANT OBSERVATIONS
                qui count if `relevant_est'==1
                
                if r(N)!=`n_ig' {
                    di as error "There are holes in the distribution"                _newline ///
                                "of observations that satisfy "                      _newline ///
                                "`if' `in'"                                          _newline ///
                                "and for whom income bins are between "              _newline ///
                                `lw' " and " `hi'                                    _newline ///
                                "when using binwidth `binwidth' around bpoint `bpoint'"        
                    exit 110
                }            
            
            * OBS IN PRE-COLLAPSE SAMPLE 
                tempvar numobs1
                egen double `numobs1'       = sum(`count') if `relevant_est'==1
                    qui su `numobs1'
                    local numobs     = r(max)
                scalar numobs   = `numobs'
                    drop `numobs1'

            * OBS IN THE PRE-COLLAPSE SAMPLE THAT ARE AFFECTED BY THE KINK/BUNCH POINT
            * - FOR USE WITH THE INTEGRATE TO 1 CONDITON
            * Bunchers come from the right of the (lower bound of the) bunching window
            * -> therefore when we construct the counterfactual distribution, we must 
            * know how many observations should be in the area affected by the kink/bunch-point. 
                tempvar numobs1
                egen double `numobs1'       = sum(`count') if `touse' & `inc_grp_est' > `low_bunch'
                qui su `numobs1'
                local mass_bunch_to_infinity     = r(max)
                drop `numobs1'

            * NUMBER OF OBS PER INCOME GROUP
                if `di_time'==1 noi di as yellow "$S_TIME tab" 
                
                    sort `inc_grp_est'
                    tempname hlp
                    mkmat `inc_grp_est' `count' if `relevant_est'==1, matrix(`hlp')
                    matrix IG         = `hlp'[1...,1] 
                    matrix FREQ       = `hlp'[1...,2] 
                    
                    * constructing # obs for plot
                    if `zoom_low'~=`ig_low' | `zoom_high'~=`ig_high' {
                        sort `inc_grp_plot'
                        mkmat `inc_grp_plot' `count' if `relevant_plot'==1, matrix(`hlp')
                        matrix IG_plot         = `hlp'[1...,1] 
                        matrix FREQ_plot         = `hlp'[1...,2] 
                    }
                    else {
                        matrix IG_plot    =IG
                        matrix FREQ_plot=FREQ
                    }
                    
        ***** BunchingCalc ******

            * MATA REGRESSION TO GET BUNCHING
                
                if `di_time'==1 noi di as yellow "$S_TIME regress begin" 
                mata: bunch_reg("IG", "FREQ", "IG_plot", "FREQ_plot", `mass_bunch_to_infinity', `degree', `low_bunch',`high_bunch', `pct_hgt', `max_it', `nboot', `int2one')
                if `di_time'==1 noi di as yellow "$S_TIME regress end" 
                local n_it=scalar(n_it)
                if -n_it<=-`max_it' noi di as red "No convergence"
                
                * EXCESS MASS
                    local bn                         = scalar(bn)
                    local people_nearbunch  = scalar(people_nearbunch)
                    local bf                         = scalar(bf)
                    local b                 = scalar(b)

                * STANDARD ERRORS
                    local bn_se                      = scalar(bn_se)
                    local bf_se                   = scalar(bf_se)
                    local b_se                      = scalar(b_se)

                local rows                = rowsof(IG)    
                local rows_plot           = rowsof(IG_plot)
                local bn_atkink           = scalar(bn_atkink)
                scalar concentration      = `bn_atkink'/`bn'
                local concentration       = scalar(concentration)


        
            * FORMATTING OUTPUT (produces locals: bn2 bn2_atkink bf2 b2 bn_se2 bf_se2 b_se2 concentration)
                local bn2         = round(`bn')
                local bn_atkink2    = round(`bn_atkink')
                local output "bf b bn_se bf_se b_se concentration"
                foreach outp of local output{
                        bunch_count_pseudo_sigdig, ndig(4) inval(``outp'') 
                        local `outp'2 = r(sigstring)
                }
                

            * OUTPUTTING RESULTS BEFORE PLOT
            noi di as green "Number of obs in plot: `numobs'"
            noi di as green "nearbunch `people_nearbunch'"
            noi di as green "bn `bn2'"
            noi di as green "bn_se `bn_se2'"
            noi di as green "b `b2'"
            noi di as green "b_se `b_se2'"
            noi di as green "bf `bf2'"
            noi di as green "bf_se `bf_se2'"
            noi di as green "bn_atkink `bn_atkink2'"
            noi di as green "concentration `concentration2'"
            noi di as green "iterations: `n_it' (`max_it' means did not converge)"
        **** BunchingPlot ******
                
                
            if `plot'==1 | "`outvar'"~=""  {
                bunch_count_plot `income' , condition(`"`if' `in'"')                         ///
                plot(`plot') plot_fit(`plot_fit')                                      ///
                graph_dir(`graph_dir')  graph_name(`graph_name')                       ///
                graph_step(`graph_step')                                               ///
                pct_hgt(`pct_hgt')                                                     ///
                zoom_low(`zoom_low') zoom_high(`zoom_high')                            ///
                use_xline(`use_xline')    xline(`xline')                               ///
                use_xline2(`use_xline2')  xline2(`xline2')                             ///
                use_xline3(`use_xline3')  xline3(`xline3')                             ///
                yaxis_min(`yaxis_min') yaxis_max(`yaxis_max')                          ///
                step_method(`step_method') bpoint(`bpoint') binwidth(`binwidth')       ///
                di_time(`di_time') bn2(`bn2') b2(`b2') b_se2(`b_se2')                  ///
                use_xtitle(`use_xtitle') `xtitle_command'                              ///
                   wmf_export(`wmf_export') png_export(`png_export') outvar(`outvar')  ///
                   degree(`degree') n_it(`n_it')
            }
                       
                     
        
        **** return to main program *******

    
                
        * RETURN SCALARS
        
            local returns "bn bf b bn_se bf_se b_se bn_atkink concentration"
            foreach rtn of local returns {
                return scalar `rtn'        = ``rtn''
                return scalar `rtn'2        = ``rtn'2'
            }
            return scalar n_it            = `n_it'
            return scalar yaxis_min        = `yaxis_min'
            return scalar yaxis_max        = `yaxis_max'
            return scalar rows        = `rows_plot'
            return scalar numobs        = `numobs'
        
    * end quietly statement
    }

    qui cd "`init_dir'"
    cap sort `sortlist'
    if `di_time'==1 noi di as yellow "$S_TIME"
    

end


* PLOTTING FITTED AND ACTUAL VALUES
* Tore Olsen 2008
cap program drop bunch_count_plot
program define bunch_count_plot
version 10
syntax varname(numeric) , condition(string) degree(integer) n_it(integer)     ///
	outvar(string)                                                        ///
	[graph_name(string) graph_dir(string) graph_step(integer 4)           ///
	plot(integer 1) plot_fit(integer 1)                                   ///
    pct_hgt(integer 101) yaxis_min(integer 0) yaxis_max(integer 0)        ///
	step_method(string)  bpoint(integer 0) binwidth(integer 1000)         ///
    zoom_low(integer 0) zoom_high(integer 0)                              ///
    use_xline(integer 1) use_xline2(integer 0) use_xline3(integer 0)      ///
    xline(integer 0) xline2(integer 0) xline3(integer 0)                  ///
    di_time(integer 0) bn2(real 0) b2(real 0) b_se2(real 0)               ///
    use_xtitle(integer 1) xtitle(string)                                  ///
    png_export(integer 1) wmf_export(integer 1)  ]
       
    local income "`1'"
       
    if `use_xtitle'==0 {
        local xtitle_command = ""
    }
    else {
        if `"`xtitle'"'=="" {
            local xtitle_command `" xtitle("Bin Group") "'
        }
        else {
            local xtitle_command `" xtitle(`"`xtitle'"') "'
        }
    }
                
    local rows_plot                = rowsof(IG_plot)
  
    if `pct_hgt'~=101 {
            local yaxis_min    = floor(scalar(yaxis_min))
            local yaxis_max    = ceil(scalar(yaxis_max))
    }
    

    if `di_time'==1 noi di as yellow "Write matrix to data $S_TIME"
    * SAVING MATRIX OF INCOME, FREQUENCIES AND COUNTERFACTUALS


    local justafter = `rows_plot'+1
    local a_bit_more=`rows_plot'+10    
    forval i=1/3 {            
        cap confirm variable `outvar'`i', exact
        if _rc~=0{
            qui g float `outvar'`i'=.
        } 
        else if _N<100000 {
            qui replace `outvar'`i'=. 
        }
        else {
            * In case `outvar'1-3 already exists, AND there are many obs, 
            * then `outvar'1-3 are not deleted but overwritten for the sake of speed
            * In case something is left in the variable from previous runs, we clean up a bit below row `rows_plot'
            * - this does not affect the plots as they only take info from row 1/`rows_plot', but in case someone would look
            * in the data browser at `outvar' we want to make it clear where the info from last run of bunching stops
            forval j= `justafter' / `a_bit_more' {
                qui replace `outvar'`i' = . in `j'
            }
        }
    }
    
    * writing data from matrices to variables
    forval i=1/`rows_plot'{
        replace `outvar'1 = IG_plot[`i',1] in `i'
        replace `outvar'2 = FREQ_plot[`i',1] in `i'
        replace `outvar'3 = y_hat_pred[`i',1] in `i'
    }

    replace `outvar'1     = `outvar'1 + `step_method'(`bpoint'/`binwidth')
        
    ****************** PLOT **********************

    if `plot'==1{
        if `pct_hgt'~=101 {
            noi di as yellow "ymin `yaxis_min' ymax `yaxis_max'"
        }
        local zoom_low    = `zoom_low'+ `step_method'(`bpoint'/`binwidth')
        local zoom_high    = `zoom_high'+ `step_method'(`bpoint'/`binwidth')

        if `di_time'==1 noi di "$S_TIME end svmat, start plot"
        if `use_xline'==0 local uxl "0"
        if `use_xline'==1 local uxl "1"
        if `use_xline'==2 local uxl "0 1"
        if `use_xline2'==0 local uxl2 "0"
        if `use_xline2'==1 local uxl2 "1"
        if `use_xline2'==2 local uxl2 "0 1"
        if `use_xline3'==0 local uxl3 "0"
        if `use_xline3'==1 local uxl3 "1"
        if `use_xline3'==2 local uxl3 "0 1"
        foreach num of numlist `uxl' {
        foreach num2 of numlist `uxl2' {
        foreach num3 of numlist `uxl3' {

            if `num'==0 local xlineopt ""
            if `num'==1 {
                local xl = (`bpoint'/`binwidth')+`xline'
                local xlineopt ="xline(`xl')"
            }
            if `num2'==0 local xlineopt2 ""
            if `num2'==1 {
                local xl = (`bpoint'/`binwidth')+`xline'
                local xlineopt2 ="xline(`xl')"
            }
            if `num3'==0 local xlineopt3 ""
            if `num3'==1 {
                local xl = (`bpoint'/`binwidth')+`xline'
                local xlineopt3 ="xline(`xl')"
            }
            if `pct_hgt'==101{
                local yscale ""
            }
            else {
                local yscale " yscale(range(`yaxis_min',`yaxis_max')) "
            }
            * ACTUAL PLOT COMMANDS
           noi di `"`income'"' `"`condition' "' `"bn `bn2' b `b2' b_se `b_se2' degree `degree' nit `n_it' "'
                if `plot_fit' == 1{
                    * ACTUAL PLOT COMMANDS IF COUNTERFACTUAL SHOULD BE PLOTTED
                    qui scatter `outvar'2 `outvar'1 in 1/`rows_plot', ///
                        c(l) xlabel(`zoom_low'(`graph_step')`zoom_high') msize(small) msymbol(o) graphregion(fcolor(white)) legend(off) `xlineopt' `xlineopt2' `xlineopt3'  ///
                        title("`income'" "`condition'" "bn `bn2' b `b2' b_se `b_se2' degree `degree' nit `n_it'", size(small) ) ///
                        `xtitle_command' ytitle("Frequency") `yscale' ///
                    || scatter `outvar'3 `outvar'1 in 1/`rows_plot', c(l) msymbol(none) `yscale'
                }
                else {
                    * ACTUAL PLOT COMMANDS IF COUNTERFACTUAL SHOULD **NOT** BE PLOTTED
                    qui scatter `outvar'2 `outvar'1 in 1/`rows_plot', ///
                        c(l) xlabel(`zoom_low'(`graph_step')`zoom_high') msize(small) msymbol(o) graphregion(fcolor(white)) legend(off) `xlineopt' `xlineopt2' `xlineopt3'  ///
                        title("`income'" "`condition'" "bn `bn2' b `b2' b_se `b_se2' degree `degree' nit `n_it'", size(small) ) ///
                        xtitle("Income Relative to Kink in EITC Schedule (1000s USD)") ytitle("Frequency") `yscale'
                }
            * SAVING GRAPH    
            if "`graph_name'"~=""{
                qui cap "`graph_dir'"
                if _rc!=0{
                    tore_cd, dir("`graph_dir'") quiet(1) mkdir(1)
                }
                local extenz ""
                if `num'==1 local extenz "`extenz'_xl_`xline'"
                if `num2'==1 local extenz "`extenz'_xl2_`xline2'"
                if `num3'==1 local extenz "`extenz'_xl3_`xline3'"
                graph save "`graph_name'`extenz'",replace
                if `wmf_export'==1{
                    graph export "`graph_name'`extenz'.wmf",replace
                }
                if `png_export'==1{
                    graph export "`graph_name'`extenz'.png",replace
                }
            * end if "`graph_name'"~="" clause
            } 
        * end foreach num of numlist `uxl' clause
        }
        * end foreach num2 of numlist `uxl2' clause
        }
        * end foreach num3 of numlist `uxl3' clause
        }
    * end `plot'==1 condition
    }                
end

******************************************************
* BUNCH_COUNT_PSEUDO_SIGDIG
* Tore Olsen 2008
*
* TAKES VALUE AND GENERATES NICELY FORMATTED STRING 
*     example1:
*         bunch_count_pseudo_sigdig, ndig(3) inval(.341) 
*         local tst =r(sigstring)
*        noi di "`tst'"
*         0.34
*     example 2:
*        bunch_count_pseudo_sigdig, ndig(2) inval(123.741) 
*        local tst =r(sigstring)
*        noi di "`tst'"
*         124
*******************************************************

    cap program drop bunch_count_pseudo_sigdig
    program define bunch_count_pseudo_sigdig, rclass
    version 10
    syntax, ndig(integer) inval(real) 
        local in = round(`inval'*(10^(`ndig'))) / (10^(`ndig'))
        noi di "i: `in'"
        local sign ""
        if substr("`in'",1,1)=="-"{
            local sign "-"
            local in=abs(`in')
        }
            
        local n =`ndig'+1
        if `in'<1 {
            local out =substr("`in'",1,`n')
            local out "`sign'0`out'"
        }
        else if `in'<(10^(`ndig'-1)) & `in'>=1 {
            local out =substr("`in'",1,`n')
            local out "`sign'`out'"
        }
        else {
            local out =string(abs(round(`inval')))
            local out "`sign'`out'"
        }
        return local sigstring "`out'"
    end
        
*******************************************************************************
* BUNCH_COUNT_CD program 
* Tore Olsen 2008
* Problem:    Unix uses "/" to separate directories, while Windows and DOS use "\"
*             Unix example:    /home/user/documents/data.dta
*             Windows example: C:\user\documents\data.dta
*             If we want the same programs to run on Windows and Unix
*             - without changing the path specifications -
*             then this poses a challenge for STATAs cd command.
*
* Solution:   Parse user specified directory for hierachical separators
*             and change them to fit.
*
* Extra:      Option to allow the creation of specified directories, if they 
*             do not exist prior to issuing issuing the tore_cd commnand.
*
*             bunch_count_cd, dir("c:\users\tore\test\example") mkdir(1)
*
*             will create every folder along the path if they do not already 
*             exist, whereas a regular cd statement would fail if the folders 
*             along the path did not exist. However:
*             - use mkdir(1) option with caution!
* 
* Note:       On Unix based systems incl Mac OSX, the program makes the   
*             assumption that "\ " in the directory name is meant to 
*             indicate a space in a folder-name.
*
* Limitations: Currently the program does not properly support specification  
*              of network options in the file path. Also it does not properly 
*              handle Windows formatted paths to network drives on Unix 
*              flavored systems and vice versa.
*
*******************************************************************************
cap program drop bunch_count_cd    
program define bunch_count_cd
version 10
syntax, dir(string) [quiet(integer 1) mkdir(integer 0) heroic(integer 0) set_trace(integer 0)]
    
    * LOGISTICS
        * Set_trace option
        if `set_trace'!=0{
            set trace on
            set tracedepth `set_trace'
        }
        
        * Set quiet option 
        if `quiet'==1 local qui "qui"
        
        * Get operating system flavor
        if (c(os)=="Unix")|(c(os)=="MacOSX") {
            local os_flavor = "Unix"
            local dirsep "/"
        }
        else {
            local os_flavor = "Windows"
            local dirsep "\"
        }
        local CIFS_SMB_issue=0
    
    * TRY REGULAR cd COMMAND
    `qui' cap cd `"`dir'"'
    if _rc==0 {
        * We're done
        exit
    }
    * FIX UNIX SPECIFICATION WITH "\ " INDICATING SPACE
    else {
        local dir = subinstr(`"`dir'"',"\ "," ",.)
        `qui' cap cd `"`dir'"'
         if _rc==0 {
            * We're done
            exit
        }     
    }
    
    * FIX UNIX PATH ON WINDOWS
    else if (`"`os_flavor'"'=="Windows") {
        * Fix for home dir specification
        if substr(`"`dir'"',1,11)=="~/Documents" {                  
            local dir = "C:\Documents and Settings\"+`"`c(username)'"'+"\My Documents\"'+substr(`"`dir'"',13,.)
        }
        else if substr(`"`dir'"',1,1)=="~" {
            local dir = "C:\Documents and Settings\"+`"`c(username)'\"'+substr(`"`dir'"',3,.)
        }
        * change Unix "/" to Windows "\"
        local dir = subinstr(`"`dir'"',"/","\",.)
        * change Unix "SMB://" to Windows "//"
        if (upper(substr(`"`dir'"',1,4))=="SMB:") {
            local dir = substr(`"`dir'"',5,.)
        }
        * change Unix "CIFS://" to Windows "//"
        else if (upper(substr(`"`dir'"',1,5))=="CIFS:") {
            local dir = substr(`"`dir'"',6,.)
        }
        `qui' cap cd `"`dir'"'
        if _rc==0 {
            * We're done
            exit
        } 
 
    } 
    * FIX WINDOWS PATH ON UNIX
    else if (`"`os_flavor'"'=="Unix") {
        * CHANGE WINDOWS "\" TO UNIX "/"
        local dir = subinstr(`"`dir'"',"\","/",.)
        * DEALING WITH WINDOWS USER PATH
        * And recalling that we just changed all "\" to "/"
        local windows_user = "C:/Documents and Settings/"+`"`c(username)'"' 
        if (strpos(`"`dir'"',`"`windows_user'"')~=0){
            local n = length(`"`windows_user'"')+1
            local dir = "~"+substr(`"`dir'"',`n',.)
            if upper(substr(`"`dir'"',1,14))=="~/MY DOCUMENTS"{
                local dir = "~/Documents"+substr(`"`dir'"',15,.) 
            }
        }
        * TRYING IT OUT
        `qui' cap cd `"`dir'"'
        if _rc==0 {
            * We're done
            exit
        } 
        * Dealing with "\\" on Windows 
        * corresponding to either CIFS:// or SMB:// on Unix
        if (substr(`"`dir'"',1,2))=="//" {
            local CIFS_SMB_issue=1
            local fix1 = "CIFS:"+`"`dir'"' 
            `qui' cap cd `"`fix1'"'
            if _rc==0 {
                * We're done
                exit
            }
            local fix2 = "SMB:"+`"`dir'"' 
            `qui' cap cd `"`fix2'"'
            if _rc==0 {
                * We're done
                exit
            }
        * end if statement regarding "\\" on Windows.
        }
    * end if os_flavor=Unix statement
    } 
    
   
    if `mkdir' == 0 {
        di as error "could not change to "`"`dir'"'". Perhaps set option of mkdir=1 in bunch_count_cd"
        noi lookup _rc
        exit 110
    }
    * Trying to create hierachy given by `dir'
    else {
    

                
        *SETTING PREFIX TO PATH            
        *UNIX
        if `"`os_flavor'"'=="Unix" {
            local dir0 ="/"
            if substr(`"`dir'"',1,1)=="~" {
                local dir0 =""  
            }
            else if upper(substr(`"`dir'"',1,4))=="SMB:" {
                local dir0 = "SMB://"
                local dir  = substr(`"`dir'"',7,.))
            }
            else if upper(substr(`"`dir'"',1,5))=="CIFS:" {
                local dir0 = "CIFS://"
                local dir  = substr(`"`dir'"',8,.))
            }
        }
        * WINDOWS
        else {
            local dir0 = ""
            if substr(`"`dir'"',1,2) == "\\" {
                local dir0 = "\\"
                local dir  = substr(`"`dir'"',3,.))
            }
            else if substr(`"`dir'"',1,1) == "\" {
                local dir0 = "\"
                local dir  = substr(`"`dir'"',2,.))
            }
        }
                        
        * GETTING PATH HIERACHY
        local i = 0
        tokenize `"`dir'"', parse(`"`dirsep'"')
        while `"`1'"'~="" {
            if `"`1'"'~=`"`dirsep'"' {
                local j         = `i' + 1
                local subdir`j' = `"`1'"'
                local dir`j'    = `"`dir`i''"'+`"`1'"'+`"`dirsep'"'
                local i         = `j'
             }
             macro shift
        }
                    
                    
                        
        * FINDING HIGHEST LEVEL THAT STATA CAN CHANGE TO
        local end=0
        forval k    = `i'(-1)0{
            if `end'  == 0 {
                `qui' cap cd `"`dir`k''"'
                if _rc==0 {
                    local level = `k'
                    local end = 1
                }
                * Dealing with CIFS/SMB issues 
                * that arises when Windows paths 
                * are used on Unix
                else if `CIFS_SMB_issue'==1 {
                    local fix1 = "CIFS:/"+`"`dir'"' 
                    `qui' cap cd `"`fix1'"')
                    if _rc==0 {
                        local level = `k'
                        local end = 1
                    }
                    else {
                        local fix2 = "SMB:/"+`"`dir'"' 
                        `qui' cap cd `"`fix1'"')
                        if _rc==0 {
                            local level = `k'
                            local end = 1
                        }
                    }
                * end CIFS_SMB issue fix
                }
            * end: if `end'  == 0 statement
            }
        * end: forval k    = `i'(-1)0 statement
        }
            
        * CREATING SUBDIRECTORIES FROM THIS LEVEL AND UP
        local level  = `level' + 1
        forval k     = `level'/`i' {
            `qui' cap mkdir `"`subdir`k''"'
            if _rc~=170& _rc~=0 {
               noi lookup _rc
               exit 110
            }   
            `qui' cd `"`subdir`k''"'
        }
    * end if mkdir=1 statement                     
    }
    end
    

******************************************************************
* SUPPORTING MATA PROGRAMS
* Tore Olsen 2009
******************************************************************
version 10
mata:
mata set matastrict on

void bunch_reg(
            string scalar     IG_name,
            string scalar     FREQ_name, 
            string scalar     IG_plot_name,  
            string scalar     FREQ_plot_name,
            real scalar        mass_bunch_to_infinity,
            real scalar     degree, 
            real scalar     low,  
            real scalar     high, 
            real scalar     pct_hgt, 
            real scalar     max_it, 
            real scalar     NBOOT, 
            real scalar     inttoone)
    {
        real matrix     X, X_plot, X_nodum, XXinvX, Poly, Poly_plot, Dummies, XXinv, get_beta_poly, get_beta_dummy
        real colvector      IG, IG_plot, FREQ, FREQ_plot, FREQ_j, cons, cons_plot, iota, iota_plot, poly1, poly1_plot, agg, 
                    y_hat, y_counter, Y_new, y_hat_pred, y_hat_org, y_counter_j, 
                    beta_hat, beta_hat_poly, beta_hat_dum, beta_hat_dum_atkink, beta_hat_j, beta_hat_poly_j, beta_hat_dum_j,
                    b_boot, bf_boot, bn_boot,  
                    error_adj, draw_j, pick_right, pick_bunch_and_right, resample
        real scalar     ndum, rows, rows_plot, xcols, minim, first_bunch_rX, people_nearbunch, bn, bn_se, bf, bf_se, i ,j, bn_atkink, yaxis_pctbunch, yaxis_min, yaxis_min_plot, max_fit, max_act, yaxis_max, first_dummy_b, last_poly_b, mn, se, n_it, first_atkink_b, last_atkink_b, last_bunch_rX, b , n_it_j, b_j, bf_j, bn_j, b_se, first_right_rX, last_left_rX, mass_bunch_to_infinity_j
    
        /* GETTING MATRICES FOR ESTIMATION */
            IG            =st_matrix(IG_name)
            FREQ            =st_matrix(FREQ_name)
            /* and characterizing them */
            minim            =colmin(IG)
            rows            =rows(IG)

        /* NUMBER OF DUMMIES AND NUMBER OF COLUMNES IN X*/
            ndum            =(high-low+1)
            xcols            =1+degree+ndum


        /* ROW NUMBERS IN X */
            last_left_rX    = low-minim
            first_bunch_rX    = last_left_rX+1
            last_bunch_rX    = last_left_rX+ndum
            first_right_rX    = last_bunch_rX+1

        /* ROW NUMBERS IN BETA */
            last_poly_b        = 1+degree
            first_dummy_b    = 1+degree+1
            /* Rown number for dummies representing bin just under bunch point */
            first_atkink_b    = last_poly_b-low
            /* Rown number for dummies representing bin just over bunch point */
            last_atkink_b    = last_poly_b-low+2

        /* USEFULL SCALARS, VECTORS and MATRICES */
            pick_right            = J(last_bunch_rX,1,0)\J((rows-last_bunch_rX),1,1)
            pick_bunch_and_right    = J(last_left_rX,1,0)\J((rows-last_left_rX),1,1)

            get_beta_poly        = diag(J((1+degree),1,1)),J((1+degree),ndum,0)
            get_beta_dummy        = J(ndum,(1+degree),0),diag(J((ndum),1,1))

        /* CONSTRUCTING CONSTANT, POLYNOMIAL TERM, AND DUMMIES TERM */
            iota            =J(rows,1,1)
            cons            =iota
            mn            =(iota'*IG)/(iota'*iota)
            poly1            =IG:-mn
            /* NORMALIZE PLOY1 - DEMEAN AND DIVIDE BY SE */
                se            =(sqrt(cross(poly1,poly1)/rows))
                poly1            =poly1 / se
                Poly            =poly1
                for (i=2; i<=degree; i++) Poly = Poly,poly1:^i
            /* CREATING DUMMIES */
                Dummies        =J(rows,ndum,.)
                agg            =J(rows,1,0)
                i            =0
                for (j=first_bunch_rX; j<=last_bunch_rX; j++) {
                    i        =i+1
                    Dummies[.,i]=e(j,rows)'
                    agg[j]    =1
                }
        
                /* Counting number of people in bunching window */
                    people_nearbunch    =agg' * FREQ
                    st_numscalar("people_nearbunch", people_nearbunch)
            /* CONSTRUCTING X*/
                X_nodum        =cons,Poly
                X            =X_nodum,Dummies
                st_matrix("X",X)
                XXinv            =invsym(cross(X,X))
                XXinvX        =XXinv*X'
                
        /* REPEATING CONSTRUCTION OF X, NOW FOR THE PREDICTION MATRIX (ONLY CONSTANT AND POLYNOMIAL*/
                    /* getting matrices for estimation */
                        IG_plot        =st_matrix(IG_plot_name)
                        FREQ_plot        =st_matrix(FREQ_plot_name)
                        /* and characterizing them */
                        rows_plot        =rows(IG_plot)
                        iota_plot        =J(rows_plot,1,1)

                    /* constructing constant */
                        cons_plot        =iota_plot
                    /* NOTE: normalizing with mean and se from estimation matrix to make predictions meaningfull */
                        poly1_plot        =IG_plot:-mn
                        poly1_plot        =poly1_plot:/se
                        Poly_plot        =poly1_plot
                        for (i=2; i<=degree; i++) Poly_plot = Poly_plot,poly1_plot:^i
                    /* Constructing X_Plot*/
                        X_plot    =(cons_plot,Poly_plot)
                        st_matrix("X_plot",X_plot)    



        /* CONSTRUCTING BETAHAT */
            beta_hat        = XXinvX*FREQ
            beta_hat_poly    = get_beta_poly*beta_hat
            beta_hat_dum    = get_beta_dummy*beta_hat

        /* CONSTRUCTING FITTED DATA */
            y_hat_org        =X*beta_hat
            y_counter        =(cons,Poly) * beta_hat_poly

        /* CALCULATING EXCESS MASS MEASURES */
            bn            =colsum(beta_hat_dum)
            bf             = (bn/(people_nearbunch-bn))*100
            b            =ndum*bf/100

        if (inttoone==1) {
            /* IMPOSING INTEGRATE2ONE CONSTRAINT                        */
            /* PROGRAM UPDATES Y_COUNTER, Y_NEW, BETA_HAT, B, BN, AND N_IT     */
            /* SETTING ITERATION COUNTER                             */
                n_it=0
            /* SETTING Y_NEW                                     */
                Y_new = FREQ

                /*THINK OF Y_NEW AS THE BIN-COUNTS WE WOULD NEED TO HAVE, TO GET A COUNTERFACTUAL (WO DUMMIES) THAT "INTEGRATES TO 1" */
                /* WE PASS THE ORIGINAL BIN-COUNTS TO THE CORRECTION PROGRAM AND IT THEN MODIFIES Y_NEW ACCORDINGLY */
                /* UNDER THE CONSTRAINT THAT THE EXCESS MASS HAS SHIFTED FROM THE RIGHT */

            /* EXECUTING CORRECTION PROGRAM */
            bunch_corr_prop(max_it, n_it, b, bf, bn, beta_hat, 
                            FREQ, y_counter, Y_new, X_nodum, XXinvX, 
                            agg, iota, pick_right, pick_bunch_and_right, 
                            last_poly_b, first_dummy_b, xcols, ndum, mass_bunch_to_infinity)
            beta_hat_poly    = beta_hat[1..last_poly_b]
            beta_hat_dum    = beta_hat[first_dummy_b..xcols]
        }
        else {
            n_it=.
            Y_new = FREQ
        }
            

        
            st_numscalar("n_it", n_it)
            st_numscalar("b", b)
            st_numscalar("bf", bf)
            st_numscalar("bn", bn)
            st_matrix("y_hat",y_counter)
            st_matrix("beta_hat",beta_hat)

        /* CONSTRUCTING NEW FITTED DATA */
            y_hat        =X * beta_hat
            y_hat_pred    =X_plot * beta_hat_poly
            st_matrix("y_hat_pred",y_hat_pred)    

        /* BOOTSTRAPPING for standard errors */
            
            error_adj        =Y_new-y_hat
            b_boot        =J(NBOOT,1,0)
            bf_boot        =J(NBOOT,1,0)
            bn_boot        =J(NBOOT,1,0)
            
            for (j=1; j<=NBOOT; j++) {

                /* GENERATE NEW DATASET */
                    draw_j            = ceil(uniform(rows,1)*rows)
                    resample            = error_adj[draw_j]
                    FREQ_j            = y_hat_org + resample
                    mass_bunch_to_infinity_j= mass_bunch_to_infinity + (pick_bunch_and_right'* resample)
    
                /* REESTIMATE WITH ADJUSTMENT */
                    beta_hat_j         = XXinvX * FREQ_j
                    beta_hat_poly_j    = get_beta_poly * beta_hat_j
                    beta_hat_dum_j    = get_beta_dummy * beta_hat_j

                /* CONSTRUCTING FITTED DATA */
                    y_counter_j        = X_nodum * beta_hat_poly_j            
        
                /* CALCULATING EXCESS MASS MEASURES */
                    bn_j            =colsum(beta_hat_dum_j)
                    bf_j             = (bn_j/(people_nearbunch-bn_j))*100
                    b_j            =ndum*bf_j/100


                if (inttoone==1) {
                    n_it_j=0
                    Y_new = FREQ_j

                    bunch_corr_prop(max_it, n_it_j, b_j, bf_j,  bn_j, beta_hat_j, 
                                FREQ_j, y_counter_j, Y_new, X_nodum, XXinvX, 
                                agg, iota, pick_right, pick_bunch_and_right, 
                                last_poly_b, first_dummy_b, xcols, ndum, mass_bunch_to_infinity_j)        
                    /* program updates y_counter_j, Y_new, beta_hat_j, and b_j*/
                }
    
                /* WRITE B TO B_BOOT AND BN TO BN_BOOT */
                    b_boot[j] =b_j
                    /*bf_boot[j]=bf_j*/
                    /*bn_boot[j]=bn_j*/
    
             /* end bootstrap loop */
            }

            b_se        =sqrt(quadvariance(b_boot))
            bf_se        =. /*sqrt(quadvariance(bf_boot))*/
            bn_se        =. /*sqrt(quadvariance(bn_boot))*/
            st_numscalar("b_se", b_se)
            st_numscalar("bf_se", bf_se)
            st_numscalar("bn_se", bn_se)

        /* LOGISTICS FOR -MIN- GRAPH SCALE */
            /* we want the (average height of the plot in the bunch window)*pct_hgt-option so set scaling of graph */
                 yaxis_pctbunch    = ((agg' * y_hat)/ndum)*(pct_hgt/100)
            /* however, if the graph is very steep, we need to consider the minimum hight as well to not cut curve */
                yaxis_min_plot    = colmin(FREQ_plot)
                yaxis_min        = colmin(yaxis_pctbunch\ yaxis_min_plot)
                st_numscalar("yaxis_min", yaxis_min)

        /* LOGISTICS FOR -MAX- GRAPH SCALE */
            max_act        = colmax(FREQ_plot)
            max_fit        = colmax(y_hat_pred)
            yaxis_max        = colmax(max_act\ max_fit)
            st_numscalar("yaxis_max", yaxis_max)

        /* CONSTRUCTING CONCENTRATION MEASURE RIGHT AT KINK*/ 
            beta_hat_dum_atkink    =beta_hat[first_atkink_b..last_atkink_b]
            bn_atkink        =colsum(beta_hat_dum_atkink)
            st_numscalar("bn_atkink", bn_atkink)        
        

    }
end

version 10
mata:
mata set matastrict on

void    bunch_corr_prop(real scalar max_it, 
            real scalar n_it, 
            real scalar b,
            real scalar bf,
            real scalar bn,
            real colvector beta_hat,    
            real colvector Y, 
            real colvector y_counter, 
            real colvector Y_new,
            real matrix X_nodum,
            real matrix XXinvX,
            real colvector agg,
            real colvector iota,
            real colvector pick_right,
            real colvector pick_bunch_and_right,
            real scalar last_poly_b,
            real scalar first_dummy_b,
            real scalar xcols,
            real scalar ndum,
            real scalar mass_bunch_to_infinity        
        )
    {
        real scalar     extra, mass_right_counter, mass_bunch_and_right_counter, mass_bunch_and_right_actual, mass_bunch_and_right_posited
        real colvector    shift    

        mass_bunch_and_right_actual = pick_bunch_and_right' * Y    
        
        extra=1000
        n_it=0

        while (abs(extra)>1 & n_it<max_it) {
            n_it                    = n_it+1
            mass_right_counter        = pick_right' * y_counter
            mass_bunch_and_right_counter    = pick_bunch_and_right' * y_counter
            mass_bunch_and_right_posited    = mass_bunch_and_right_actual - bn*(1-(mass_bunch_and_right_actual /mass_bunch_to_infinity))
            extra                    = mass_bunch_and_right_posited - mass_bunch_and_right_counter
            shift                    = iota + ( pick_right*(extra/mass_right_counter) )
            Y_new                    = Y_new:*(shift)
            beta_hat                = XXinvX * Y_new
            y_counter                = X_nodum * beta_hat[1..last_poly_b]
        }
        
        bn            = colsum(beta_hat[first_dummy_b..xcols])
        bf             = ( bn / (agg'*y_counter) )*100
        b            = ndum*bf/100

    }


end

exit
