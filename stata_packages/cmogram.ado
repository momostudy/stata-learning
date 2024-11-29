/* 
	cmogram y x [ , options ]
	
	Draw histogram-style conditional mean or median graph.
	
	by Christopher Robert, Harvard Kennedy School, chris_robert@hksphd.harvard.edu
	
	v1.11, September 6, 2011
*/	

program define cmogram, rclass
	syntax varlist(min=2 max=2) [if] [, Histopts(string) CONtrols(string) CONTROLvars(string) CUTpoint(string) CUTRight CI(string) MEDian LEGend COUNT FRACtion NOTEn NOTEPFX(string) NOTESFX(string) NONotes Lineat(string) TITle(string) Graphopts(string) SAVing(string) GENerate(string) BY(string) BYValues(string) BYTitle(string) SCatter LFit LFITCi QFit QFITCi LOWess LFITOpts(string) CIOpts(string) RCAPOpts(string) LOWOpts(string) GRAPHOPTS1(string) GRAPHOPTS2(string) GRAPHOPTS3(string) GRAPHOPTS4(string) LFITOPTS1(string) LFITOPTS2(string) LFITOPTS3(string) LFITOPTS4(string) RCAPOPTS1(string) RCAPOPTS2(string) RCAPOPTS3(string) RCAPOPTS4(string) LOWOPTS1(string) LOWOPTS2(string) LOWOPTS3(string) LOWOPTS4(string) TITLE1(string) TITLE2(string) TITLE3(string) TITLE4(string)]
	version 9.2
	marksample marked, strok
	quietly {
		* initialize variables
		tokenize `varlist'
		local yvar "`1'"
		local xvar "`2'"
		local xvarLabel : variable label `xvar'
		if "`xvarLabel'"=="" {
			local xvarLabel="`xvar'"
		}
		local yvarLabel : variable label `yvar'
		if "`yvarLabel'"=="" {
			local yvarLabel="`yvar'"
		}
		if "`controls'"~="" {
			local controlvars="`controls'"
			local controldesc=", controlling for '`controls''"
		}
		else {
			local controldesc=""
		}
		if "`median'"~="" {
			local oper="median"
		}
		else if "`fraction'"~="" {
			local oper="fraction"
		}
		else if "`count'"~="" {
			local oper="count"
		}
		else if "`ci'"~="" {
			local oper="confidence intervals"
		}
		else {
			local oper="mean"
		}
		if "`by'"~="" {
			local bydesc=", by '`by''"
		}
		else {
			local bydesc=""
		}
		if "`legend'"~="" {
			local legendoff=""
		}
		else {
			local legendoff="legend(off)"
		}

		* show overall output header
		count if `marked'
		local totcount0=r(N)
		noisily disp ""
		noisily disp "Plotting `oper' of `yvar', conditional on `xvar'`bydesc'`controldesc'."
		noisily disp ""
		noisily disp "n = `totcount0'"
		noisily disp ""

		* run regression if controlling; set y axis label
		if "`controlvars'"~="" {
			reg `yvar' `controlvars' if `marked'
			tempvar _resid
			predict `_resid', resid
			local yvar="`_resid'"

			if "`median'"~="" {
				local ylabel="Median residual of `yvarLabel'"
			}
			else if "`count'"~="" {
				local ylabel="Frequency"
			}
			else if "`fraction'"~="" {
				local ylabel="Proportion"
			}
			else {
				local ylabel="Mean residual of `yvarLabel'"
			}
		}
		else {
			if "`median'"~="" {
				local ylabel="Median of `yvarLabel'"
			}
			else if "`count'"~="" {
				local ylabel="Frequency"
			}
			else if "`fraction'"~="" {
				local ylabel="Proportion"
			}
			else {
				local ylabel="Mean of `yvarLabel'"
			}
		}
		
		* loop through and set up bins, potentially by sub-group
		if "`by'"~="" {
			if "`byvalues'"~="" {
				local byvals="`byvalues'"
			}
			else {
				levelsof `by', local(byvals)
			}
		}
		else {
			local byvals="1"
		}
		local miny=999999
		local maxy=-999999
		local num0=0
		local num1=1
		foreach byval of local byvals {
			if "`by'"~="" {
				local byif=" & `by'==`byval'"
				cap: count if `marked' `byif'
				if _rc~=0 {
					local byif=`" & `by'=="`byval'""'
					local bystg="1"
					count if `marked' `byif'
				}
				local totcount`num0'=r(N)
				if `num0'>0 {
					noisily disp ""
				}
				noisily disp "`by'==`byval' (n = `totcount`num0'')"
				noisily disp ""
			}
			else {
				local byif=""
			}
			* define bins and specify their heights
			forvalues right=`num0'/`num1' {
				tempvar _bn`right'
				gen `_bn`right''=.
				if `right'==`num0' | "`cutpoint'"~="" {
					tempvar _y`right' _x`right' _yh`right' _yl`right'
					gen `_yh`right''=.
					gen `_yl`right''=.
					if "`cutpoint'"~="" {
						count if `marked' & `xvar'==`cutpoint' `byif'
						local atcut=r(N)
						if `right'==`num0' {
							twoway__histogram_gen `xvar' if `marked' & `xvar'<=`cutpoint' `byif', freq `histopts' gen(`_y`right'' `_x`right'') display
						}
						else {
							twoway__histogram_gen `xvar' if `marked' & `xvar'>=`cutpoint' `byif', freq start(`cutpoint') `histopts' gen(`_y`right'' `_x`right'') display
							* note that the left and right both include the cut-point; the bar heights will be adjusted below
						}
					}
					else {
						local atcut=0
						twoway__histogram_gen `xvar' if `marked' `byif', freq `histopts' gen(`_y`right'' `_x`right'') display
					}
					local nbins=r(bin)
					local binstart=r(start)
					local binwidth`right'=r(width)
					local binleft=`binstart'
					local lastmax=r(max)
					
					* check for and manage missing (empty) bins
					replace `_x`right''=. if `_y`right''==.
					count if `_x`right''<.
					if r(N) < `nbins' {
						* fill in missing bins
						sort `_x`right''
						local binmid=(`binstart'+`binwidth`right''/2)
						forvalues bn=1/`nbins' {
							count if `_x`right''>(`binmid'-`binwidth`right''/2) & `_x`right''<(`binmid'+`binwidth`right''/2)
							if r(N) < 1 {
								replace `_x`right''=`binmid' if _n==(`nbins'+`bn')
								replace `_y`right''=0 if _n==(`nbins'+`bn')
							}
							local binmid=(`binmid'+`binwidth`right'')
						}
					}
					
					sort `_x`right''
					replace `_bn`right''=_n
					forvalues bn=1/`nbins' {
						local binright=`binleft'+`binwidth`right''
						* round up for last bin, to be sure to catch boundary points
						if `bn'==`nbins' {
							local binright=`lastmax'
						}
						if "`ci'"~="" {
							local sumcmd="ci"
							local sumopt="level(`ci') `ciopts'"
						}
						else {
							local sumcmd="sum"
							local sumopt="d"
						}
						if "`cutright'"=="" {
							if (`right'==`num0' & `bn'==1) | (`right'==`num1' & `bn'==1 & `atcut'==0) {
								`sumcmd' `yvar' if `xvar'>=`binleft' & `xvar'<=`binright' & `marked' `byif', `sumopt'
								local rangedesc="[`binleft',`binright']"
							}
							else {
								`sumcmd' `yvar' if `xvar'>`binleft' & `xvar'<=`binright' & `marked' `byif', `sumopt'
								local rangedesc="(`binleft',`binright']"
							}
						}
						else {
							if (`right'==`num1' & `bn'==`nbins') | ("`cutright'"=="" & `right'==`num0' & `bn'==`nbins') {
								`sumcmd' `yvar' if `xvar'>=`binleft' & `xvar'<=`binright' & `marked' `byif', `sumopt'
								local rangedesc="[`binleft',`binright']"
							}
							else {
								`sumcmd' `yvar' if `xvar'>=`binleft' & `xvar'<`binright' & `marked' `byif', `sumopt'
								local rangedesc="[`binleft',`binright')"
							}
						}
						local rangen=r(N)
						if "`median'"~="" {
							local rangeydesc="median"
							local rangey=r(p50)
						}
						else if "`count'"~="" {
							local rangeydesc="count"
							local rangey=r(N)
						}
						else if "`fraction'"~="" {
							local rangeydesc="fraction"
							local rangey=r(N)/`totcount`num0''
						}
						else {
							local rangeydesc="mean"
							local rangey=r(mean)
						}
						if "`ci'"~="" {
							local cih=r(ub)
							local cil=r(lb)
							replace `_y`right''=`rangey' if `_bn`right''==`bn'
							replace `_yh`right''=`cih' if `_bn`right''==`bn'
							replace `_yl`right''=`cil' if `_bn`right''==`bn'
							if `cil'<`miny' {
								local miny=`cil'
							}
							if `cih'>`maxy' & `cih'<. {
								local maxy=`cih'
							}
							noisily disp "Bin #`bn': `rangedesc' (n = `rangen') (`rangeydesc' = `rangey'; CI = (`cil',`cih'))"
						}
						else {
							replace `_y`right''=`rangey' if `_bn`right''==`bn'
							if `rangey'<`miny' {
								local miny=`rangey'
							}
							if `rangey'>`maxy' & `rangey'<. {
								local maxy=`rangey'
							}
							noisily disp "Bin #`bn': `rangedesc' (n = `rangen') (`rangeydesc' = `rangey')"
						}
						
						local binleft=`binright'
					}
				}
			}
		
			local num0=`num0'+2
			local num1=`num1'+2
		}	
			
		* output graph(s)	and save results
		return clear
		local graphnames=""
		local num0=0
		local num1=1
		local graphno1=1
		local graphno2=2
		local titleno=1
		foreach byval of local byvals {
			if "`by'"~="" {
				if "`bystg'"=="1" {
					local byif=`" & `by'=="`byval'""'
				}
				else {
					local byif=" & `by'==`byval'"
				}
			}
			else {
				local byif=""
			}
			* assemble code to draw (and possibly save) graph
			local graphname="_graph`num0'"
			local nameopts="name(`graphname')"
			cap: graph drop `graphname'
			if "`lineat'"=="" {
				local lineopts ""
			}
			else {
				local lineopts "xline(`lineat', lpattern(dash))"
			}
			* define a y axis, making it common across sub-groups
			if "`by'"~="" | ("`count'"=="" & "`fraction'"=="") {
				local diff=(`maxy'-`miny')
				if `diff'<0.0005 {
					local roundingto=0.00001
					local decimals=5
				}
				else if `diff'<0.005 {
					local roundingto=0.0001
					local decimals=4
				}
				else if `diff'<0.05 {
					local roundingto=0.001
					local decimals=3
				}
				else if `diff'<0.5 {
					local roundingto=0.01
					local decimals=2
				}
				else if `diff'<5 {
					local roundingto=0.1
					local decimals=1
				}
				else {
					local roundingto=1
					local decimals=0
				}
				if "`count'"~="" | "`fraction'"~="" {
					local floor=0
				}
				else {
					local floor=round(`miny'-(`maxy'-`miny')/16,`roundingto')
					if `floor'<0 & `miny'>=0 {
						local floor=0
					}
				}
				local ceil=round(`maxy',`roundingto')
				local ystep=(`ceil'-`floor')/4
				local ceil=round(`maxy',`roundingto')
				local bottom=min(`miny',`floor')
				local top=max(`maxy',`ceil')
				if "`scatter'"~="" {
					local yrangeopts "ylabel(`floor'(`ystep')`ceil', format(%9.`decimals'f)) yscale(range(`bottom' `top'))"
				}
				else {
					local yrangeopts "base(`bottom') ylabel(`floor'(`ystep')`ceil', format(%9.`decimals'f)) yscale(range(`bottom' `top'))"
				}
			}
			else {
				local yrangeopts "yscale(range(0 .)) ylabel(#7)"
			}
			if "`by'"~="" & "`nonotes'"=="" {
				if "`noten'"~="" {
					local noteopt=`"note("`notepfx'`by'=`byval', n=`totcount`num0''`notesfx'")"' 
				}
				else {
					local noteopt=`"note(`notepfx'"`by'=`byval'`notesfx'")"' 
				}
			}
			else if "`noten'"~="" & "`nonotes'"=="" {
				local noteopt=`"note("`notepfx'n=`totcount`num0''`notesfx'")"'
			}
			else {
				local noteopt=""
			}
			
			if "`scatter'"~="" {
				local gtype="scatter"
				local barwid0=""
				local barwid1=""
			}
			else {
				local gtype="bar"
				local barwid0="barwidth(`binwidth`num0'')"
				local barwid1="barwidth(`binwidth`num1'')"
			}
			
			* potentially add line(s) of best fit
			if "`lfit'"~="" | "`lfitci'"~="" | "`qfit'"~="" | "`qfitci'"~="" {
				local lfplot=""
				if "`qfitci'"~="" {
					local lfcmd="qfitci"
					if strpos("`lfitopts'","cip") == 0 {
						local lfplot="ciplot(rline)"
					}
				}
				else if "`qfit'"~=""{
					local lfcmd="qfit"
				}
				else if "`lfitci'"~="" {
					local lfcmd="lfitci"
					if strpos("`lfitopts'","cip") == 0 {
						local lfplot="ciplot(rline)"
					}
				}
				else {
					local lfcmd="lfit"
				}
				if "`cutpoint'"~="" {
					if "`cutright'"~="" {
						local lfopt1=`"|| `lfcmd' `yvar' `xvar' if `marked' & `xvar'<`cutpoint' `byif', `legendoff' range(. `cutpoint') `lfplot' `lfitopts' `lfitopts`graphno1''"'
						local lfopt2=`"|| `lfcmd' `yvar' `xvar' if `marked' & `xvar'>=`cutpoint' `byif', `legendoff' range(`cutpoint' .) `lfplot' `lfitopts' `lfitopts`graphno2''"'
					}
					else {
						local lfopt1=`"|| `lfcmd' `yvar' `xvar' if `marked' & `xvar'<=`cutpoint' `byif', `legendoff' range(. `cutpoint') `lfplot' `lfitopts' `lfitopts`graphno1''"'
						local lfopt2=`"|| `lfcmd' `yvar' `xvar' if `marked' & `xvar'>`cutpoint' `byif', `legendoff' range(`cutpoint' .) `lfplot' `lfitopts' `lfitopts`graphno2''"'
					}
				}
				else {
					local lfopt1=`"|| `lfcmd' `yvar' `xvar' if `marked' `byif', `legendoff' `lfplot' `lfitopts' `lfitopts`graphno1''"'
					local lfopt2=""
				}
			}
			else {
				local lfopt1=""
				local lfopt2=""
			}
			
			* potentially add lowess plot
			if "`lowess'"~="" {
				if "`cutpoint'"~="" {
					if "`cutright'"~="" {
						local lowopt1=`"|| lowess `yvar' `xvar' if `marked' & `xvar'<`cutpoint' `byif', `legendoff' `lowopts' `lowopts`graphno1''"'
						local lowopt2=`"|| lowess `yvar' `xvar' if `marked' & `xvar'>=`cutpoint' `byif', `legendoff' `lowopts' `lowopts`graphno2''"'
					}
					else {
						local lowopt1=`"|| lowess `yvar' `xvar' if `marked' & `xvar'<=`cutpoint' `byif', `legendoff' `lowopts' `lowopts`graphno1''"'
						local lowopt2=`"|| lowess `yvar' `xvar' if `marked' & `xvar'>`cutpoint' `byif', `legendoff' `lowopts' `lowopts`graphno2''"'
					}
				}
				else {
					local lowopt1=`"|| lowess `yvar' `xvar' if `marked' `byif', `legendoff' `lowopts' `lowopts`graphno1''"'
					local lowopt2=""
				}
			}
			else {
				local lowopt1=""
				local lowopt2=""
			}
			
			* potentially add confidence intervals
			if "`ci'"~="" {
				if "`cutpoint'"~="" {
					local ciopt1="|| rcap `_yl`num0'' `_yh`num0'' `_x`num0'', `legendoff' `rcapopts' `rcapopts`graphno1''"
					local ciopt2="|| rcap `_yl`num1'' `_yh`num1'' `_x`num1'', `legendoff' `rcapopts' `rcapopts`graphno2''"
				}
				else {
					local ciopt1="|| rcap `_yl`num0'' `_yh`num0'' `_x`num0'', `legendoff' `rcapopts' `rcapopts`graphno1''"
					local ciopt2=""
				}
			}
			else {
				local ciopt1=""
				local ciopt2=""
			}
			
			* potentially adjust title
			if "`title`titleno''"~="" {
				local titleval="`title`titleno''"
			}
			else {
				local titleval="`title'"
			}
			
			* actually draw a graph
			if "`cutpoint'"~="" {
				twoway `gtype' `_y`num0'' `_x`num0'', `barwid0' `yrangeopts' `graphopts' `graphopts`graphno1'' || `gtype' `_y`num1'' `_x`num1'', `barwid1' title("`titleval'") ytitle("`ylabel'") graphregion(fcolor(white)) `legendoff' `noteopt' `nameopts' `lineopts' `yrangeopts' `graphopts' `graphopts`graphno2'' `lfopt1' `lfopt2' `ciopt1' `ciopt2' `lowopt1' `lowopt2'
				if "`generate'"~="" {
					cap: gen `generate'x`num0'=.
					cap: gen `generate'y`num0'=.
					cap: gen `generate'x`num1'=.
					cap: gen `generate'y`num1'=.
					replace `generate'x`num0'=`_x`num0''
					replace `generate'y`num0'=`_y`num0''
					replace `generate'x`num1'=`_x`num1''
					replace `generate'y`num1'=`_y`num1''
				}
				return scalar bw`num0'=`binwidth`num0''
				return scalar bw`num1'=`binwidth`num1''
				local graphno1=`graphno1'+2
				local graphno2=`graphno2'+2
			}
			else {
				twoway `gtype' `_y`num0'' `_x`num0'', `barwid0' title("`titleval'") ytitle("`ylabel'") graphregion(fcolor(white)) `noteopt' `nameopts' `lineopts' `yrangeopts' `graphopts' `graphopts`graphno1'' `lfopt1' `lfopt2' `ciopt1' `ciopt2' `lowopt1' `lowopt2'
				if "`generate'"~="" {
					cap: gen `generate'x`num0'=.
					cap: gen `generate'y`num0'=.
					replace `generate'x`num0'=`_x`num0''
					replace `generate'y`num0'=`_y`num0''
				}
				return scalar bw`num0'=`binwidth`num0''
				local graphno1=`graphno1'+1
				local graphno2=`graphno2'+1
			}
			
			* optionally save a graph
			local graphnames="`graphnames' `graphname'"
			if "`saving'"~="" & "`by'"=="" {
				graph export "`saving'", name(`graphname') replace
				graph drop `graphname'
			}
			
			local num0=`num0'+2
			local num1=`num1'+2
			local titleno=`titleno'+1
		}

		* if using by option, combine graphs together and possibly save
		if "`by'"~="" {
			cap: graph drop combined
			graph combine `graphnames', name(combined) title("`bytitle'")
			graph drop `graphnames'
			if "`saving'"~="" {
				graph export "`saving'", name(combined) replace
				graph drop combined
			}
		}
	}
end
