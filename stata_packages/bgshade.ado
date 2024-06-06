*! version 1.0 Eric Haavind-Berman 12July2017

// Eric Haavind-Berman and Aaron Markiewitz

// bgshade, which makes a twoway plot and adds shading with added lines while
// changing their width to get the approximately right amount of shading
// also, it has hard-coded nber recessions which is nice.

/*
TODO: have someone else check the daily, weekly, and quarterly recession numbers
*/

capture program drop bgshade
prog def bgshade, rclass
	syntax varlist [if] [in] [,shaders(string) sstyle(string asis) twoway(string asis) ///
		NOXEXTend LEGend OLDshaders HORIZontal]	

	////////////////////////
	// set default values //
	////////////////////////
	
	if c(version) >= 15 version 15
	else version 8
	
	local intensity_shifter *.4
	local noxextend_val 25
	
	if "`horizontal'" == "" local xy_axis x
	else local xy_axis y
	
	local num_shaders : word count `shaders'
	if `num_shaders' == 1 {
		local def_pattern
		local def_color gs12
	}
	if `num_shaders' >= 2 {
		local def_pattern l _ - -.
		local def_color sienna orange sand eltgreen
	}
	
	if c(version) >= 15 & "`oldshaders'" == "" {
		local intensity_shifter %50
		local def_pattern
	}
	
	// change the default color to gs12 if it is an NBER shader
	forvalues ii = 1/`num_shaders' {
		local shader : word `ii' of `shaders'
		local color : word `ii' of `def_color'
		if inlist("`shader'","quarter","month","week","day") {
			local def_color : subinstr local def_color "`color'" "gs12"
		}
	}
	/////////////////////
	// PARSE ARGUMENTS //
	/////////////////////

	local shade_if `if'
	local shade_in `in'
	local xvar `varlist'
	local yvar : word 2 of `twoway'
	
	// make sure that there is a comma in twoway, if not, add one at the end
	local twoway_check : subinstr local twoway "," " , ", all
	local twoway_check : list posof "," in twoway_check
	if `twoway_check' == 0 local twoway `twoway' ,
	
	// parse sstyle
	local 0 ,`sstyle'
	syntax [,STYle(string) NOEXTend LSTYle(string) LPattern(string) LWidth(string) LColor(string asis) ///
		intensity(string) noxextend(string) axis(string)]
	// default settings if necessary
	if "`lpattern'" == "" & "`lstyle'" == "" local lpattern `def_pattern'
	if `""`lcolor'""' == `""""' & "`lstyle'" == ""  local lcolor `def_color'
	if "`intensity'" != "" & "`lstyle'" == "" local intensity `intensity'
	if "`intensity'" == "" & "`lstyle'" == "" local intensity `intensity_shifter'
	if "`noxextend'" == "on" local noxextend `noxextend_val'
	
	
	////////////////////
	// ERROR CHECKING //
	////////////////////
	
	// make sure we have twoway
	if `""`twoway'""' == "," {
		di as err "twoway command required"
		error 198
		exit
	}
	
	// make sure we have xvar
	if wordcount("`xvar'") != 1 {
		di as err "Only one xvar allowed"
		error 198
		exit
	}
	
	// only allow four shaders for now (if they don't specify themselves a bunch more)
	if `num_shaders' > 4 {
		
		// allow them to specify more if they want
		local pc : word count `lpattern'
		local cc : word count `lcolor'
		local sc : word count `lstyle'
		if (`num_shaders' == `pc' & `num_shaders' == `cc') | `num_shaders' != `sc' {
			// let them go
		}
		else {
			di as err "Okay, ha ha very funny. Up to four shaders allowed currently unless you specify thier sstyles"
			error 198
			exit
		}
	}
	
	foreach shader in `shaders' {
		// check that shader is either an nber option or variable in data
		qui capture ds `shader'
		if _rc == 111 & ~inlist("`shader'","quarter","month","week","day","") {
			di as err "Shaders must be either variable or nber option"
			error 198
			exit
		}
		// check that shaders are numeric dummy variables
		if ~inlist("`shader'","quarter","month","week","day","") {
			qui levelsof `shader', local(values)
			if ~inlist("`values'","0 1","1 0") {
				di as err "Shaders must be numeric dummy variables with 1 = shaded, 0 = not shaded"
				error 450
				exit
			}
		}
	}
	
	
	
	//////////////////////////////////////////////////////////////
	// MAKE SURE TO ONLY INCLUDE SHADED AREAS WTIHIN CONDITIONS //
	//////////////////////////////////////////////////////////////
	qui sum `xvar' `shade_if' `shade_in' 
	local xmin = floor(`r(min)')
	local xmax = ceil(`r(max)')
	// max values for numlist is 2500, so we split here if we need to
	if `xmax'-`xmin' >= 2500 {
		local bottom = `xmin' 
		local top = `xmin'+2499
		local x_range
		while `bottom' <= `xmax' {
			numlist "`bottom'/`top'", sort
			local x_range `x_range' `r(numlist)'
			local bottom = `bottom'+2500
			local top = `top'+2500
			if `top' > `xmax' local top = `xmax'
		}
	}
	else {
		numlist "`xmin'/`xmax'", sort
	}
	local x_range `r(numlist)'
	local x_count: word count `x_range'
	
	
	///////////////////////////
	// LOOP OVER ALL SHADERS //
	///////////////////////////
	// if no shaders specified it just skips 
	local legend_ghosts
	local added_lines
	forvalues ii = 1/`num_shaders' {
	
		// SET ALL PARAMETERS FOR EACH SHADER
		local wc: word count `lwidth'
		if `wc' == `num_shaders' local user_width : word `ii' of `lwidth'
		else local user_width `lwidth'

		local wc: word count `axis'
		if `wc' == `num_shaders' local user_axis : word `ii' of `axis'
		else local user_axis `axis'
		
		local wc: word count `intensity'
		if `wc' == `num_shaders' local int : word `ii' of `intensity'
		else local int `intensity'
		
		local shader : word `ii' of `shaders'
		local pattern : word `ii' of `lpattern'
		local colororig : word `ii' of `lcolor'
		if "`colororig'" != "gs12" local color `colororig'`int'
		else local color gs12
		local sty : word `ii' of `style'
		local lsty : word `ii' of `lstyle'
	
		get_numlist `shader' `xvar'
		local shading_list `r(shading_list)'
		// find intersection of shading dates and date range in data
		local shading_regions : list x_range & shading_list
		local wc : word count `shading_regions'
		local shading_regions_`shader' `shading_regions'

	
		/////////////////
		// ADD SHADING //
		/////////////////

		// make sure we actually want to add lines
		if `wc' == 0 {
			continue
		}
		else {
			if "`oldshaders'" == "" {
				get_regular_xlines , shading_regions(`shading_regions') x_count(`x_count') user_width(`user_width') color(`color') pattern(`pattern') lsty(`lsty') sty(`sty') `noextend' axis(`xy_axis') axis_num(`user_axis')
				local added_line `r(added_line)'
			}
			else {
				get_old_way_xlines , shading_regions(`shading_regions') x_count(`x_count') user_width(`user_width') color(`color') pattern(`pattern') lsty(`lsty') sty(`sty') `noextend' axis(`xy_axis') axis_num(`user_axis') noxextend(`noxextend') xmin(`xmin') xmax(`xmax')
				local added_line `r(added_line)'
			}

			
			//////////////////
			// ADDED LEGEND //
			//////////////////
		
			if "`legend'" != "" {
				// find the middle of the graph so we can place a function there and
				// recast as an invisible area plot
				qui su `yvar' `shade_if' `shade_in' 
				local ymiddle = (`r(min)' +`r(max)') / 2
				local xmiddle = (`xmin' + `xmax') / 2
				// use the same x and y format as the xvar and yvar
				local xfmt : format `xvar' 
				local yfmt : format `yvar'
						
				
				if inlist("`shader'","quarter","month","week","day") {
					local ylab "NBER Recession"
				}
				else {
					local ylab : var l `shader'
					if "`ylab'" == "" local ylab `shader'
				}
				// if the colororig is an rgb, then put quotes around the fcolor and lcolor options
				local wc : word count `colororig'
				if `wc' == 3 local color `""`colororig'"`intensity'"'
				
				// create the legend ghost
				local legend_ghost = `"(function `shader'=`ymiddle', range(`xmiddle' `xmiddle') recast(area) fcolor(`color') lcolor(`color') lstyle(`lsty') lwidth(0) base(`ymiddle') yvarf(`yfmt') xvarf(`xfmt') yvarlab("`ylab'")) || "'
			}
		}
		local added_lines `added_lines' `added_line'
		local legend_ghosts `legend_ghosts' `legend_ghost'
	}
	
	
	
	///////////
	// GRAPH //	
	///////////
	twoway `legend_ghosts' `twoway' `added_lines' `extra_line_min' `extra_line_max'
	
	
	///////////////////////////
	// SHOW USER SOME VALUES //
	///////////////////////////
	if "`oldshaders'" == "" {
		if "`axis'" == "x" local unit_width = 130/(1.01*`x_count')
		else local unit_width = 90/(1.01*`x_count')
	}
	else {
		if "`axis'" == "x" local numerator = 470
		else local numerator = 350
		local old_width = `numerator'/`x_count'
		local old_width "*`old_width'"
	}
	
	
	return local tw_cmd "twoway `legend_ghosts' `twoway' `added_lines' `extra_line_min' `extra_line_max'"
	if "`unit_width'" != "" return local unit_width "`unit_width'"
	if "`old_width'" != ""  return local old_width "`old_width'"
	foreach shader in `shaders' {
		return local `shader'_list `shading_regions_`shader''
	}

end



// if the user does not specify that they want to use the old way to set the shaders
capture prog drop get_regular_xlines
prog def get_regular_xlines, rclass

	syntax [anything] [ , shading_regions(string) x_count(string) user_width(string) ///
		 color(string asis) pattern(string) lsty(string) sty(string) NOEXTend axis(string) axis_num(string)]
	
	// find discrete pieces and put ranges and averages into local macros
	local start
	local added_line
	local wc : word count `shading_regions'
	
	forvalues ii = 1/`wc' {
		
		local v : word `ii' of `shading_regions'
		
		local jj = `ii' + 1
		local v_next : word `jj' of `shading_regions'
		
		
		// corner cases
		if `ii' == 1 {
			local start = `v'
		}
		if `ii' == `wc' {
			local end = `v'
		}
		
		// check for continuity
		else if `v'+1 == `v_next' {
			continue
		}
		else {
			local end = `v'
		}
		
		local average =  `start' + (`end'-`start') / 2
		local shade_range = `end'-`start'+1
		
		if "`axis'" == "x" local width = 130*`shade_range'/(1.01*`x_count')
		else local width = 90*`shade_range'/(1.01*`x_count')
		
		// use lwidth if user specified it
		if "`user_width'" != "" local width = `user_width'*`shade_range'
		
		
		local start `v_next'
		local added_line `added_line' `axis'line(`average' , axis(`axis_num') lwidth(`width') lcolor(`color') lpattern(`pattern') lstyle(`lsty') style(`sty') `noextend') 
	}
	
	return local added_line `added_line'

end




// if the user wants to use the old way of specifying the shaders
capture prog drop get_old_way_xlines
prog def get_old_way_xlines, rclass

	syntax [ , shading_regions(string) x_count(string) user_width(string) ///
		color(string asis) pattern(string) lsty(string) sty(string) ///
		NOEXTend axis(string) axis_num(string) noxextend(string) xmin(string) xmax(string)]
	
	
	// calculate lwidth here (rough approximation detailed below)
	if "`user_width'" == "" {
		if "`axis'" == "x" local numerator = 470
		else local numerator = 350
		local width = `numerator'/`x_count'
		local width "*`width'"
		
		//( NOXEXTEND ONLY BITES WHEN OLD WAY IS SPECIFIED )
		
		//////////////////////
		// noxextend OPTION //
		//////////////////////
		/* 
		 For noxextend, we divide the shading range [x-.5,x] (which is
		 what each shaed area is by default) into 200 individula pieces.
		 Then, we take the noxextend number as a % to throw out of the 
		 top or bottom and make the range [x+%/200,x] for mins
		 or [x,x+.5-%/200] for maxes where % is the number provided
		 in the string or 25 if the user sets noxextend to on. We also divide
		 the line width by 200 for these added lines so that they look right.
		 We also do [x,x+.25] or [x-.25,x] with half of the normal line 
		 width for the other half of the xline.
		 
		 There will be an error (only deals with min side) if it is the
		 top and bottom, but maybe they shouldn't be calling this in that case...
		*/
		local extra_line_min
		local extra_line_max
		if "`noxextend'" != "" {
			local edge_width = `numerator'/(200*`x_count')+1 	// decide width
			local increment = 1/200				// find increment
			local half_width = `numerator'/(2*`x_count') // find half of width
			
			// take out min if it's shaded
			foreach s in `shading_regions' {
				if `s' == `xmin' {
					local shading_regions : list shading_regions - xmin 
					local bottom = `xmin' - .5 + `noxextend'/200
					local top = `xmin' + .25
					numlist "`bottom'(`increment')`xmin'", sort
					local mins `r(numlist)'
					local extra_line_min `axis'line(`mins' , lwidth(*`edge_width') lcolor(`color') lpattern(`pattern') lstyle(`lsty') style(`sty') `noextend')
					local extra_line_min `extra_line_min' `axis'line(`top', lwidth(*`half_width') lcolor(`color') lpattern(`pattern') lstyle(`lsty') style(`sty') `noextend')
					di "`extra_line_min'"
					continue
				}
				// take out max if it's shaded
				if `s' == `xmax' {
					
					local shading_regions : list shading_regions - xmax 
					local bottom = `xmax' - .25
					local top = `xmax' + .5 - `noxextend'/200
					numlist "`xmax'(`increment')`top'", sort
					local maxes `r(numlist)'

					local extra_line_max `axis'line(`maxes' , lwidth(*`edge_width') lcolor(`color') lpattern(`pattern') lstyle(`lsty') style(`sty') `noextend')
					local extra_line_max `extra_line_max' `axis'line(`bottom', lwidth(*`half_width') lcolor(`color') lpattern(`pattern') lstyle(`lsty') style(`sty') `noextend')
					di "`extra_line_max'"
					continue
				}
			}
		}
	}
	else {
		// allow user to specify all lwidth or individual shader lwidth
		local wc: word count `lwidth'
		if `wc' == `num_shaders' local width : word `ii' of `lwidth'
		else local width `lwidth'
	}

	// if we use noextend and it takes out the only value in shading regions, then we have an error, so we make sure we don't here
	local wc : word count `shading_regions'
	if `wc' > 0 local added_line `axis'line(`shading_regions' , lwidth(`width') lcolor(`color') lpattern(`pattern') lstyle(`lsty') style(`sty') `noextend') 

	return local added_line `added_line' `extra_line_max' `extra_line_min'

end




// returns a numlist of the shader within the bounds of the xvar
capture prog drop get_numlist
prog def get_numlist, rclass
	local shader `1'
	local xvar `2'
	////////////////////////////////
	// NUMLIST FOR CUSTOM SHADERS //
	////////////////////////////////
	if ~inlist("`shader'","quarter","month","week","day","") {
		// no need to condition on `full_if' or `full_in' because we do that below
		qui levelsof `xvar' if `shader'==1, c l(date_list)
		
		numlist "`date_list'", sort
		local shading_list `r(numlist)'
	}
	
	
	/////////////////////////////////
	// NUMLIST FOR RECESSION DATES //
	/////////////////////////////////
	else if "`shader'" == "day" {
	
		local dailies1 -38381 -37438/-36920 -36219/-36007 -34577/-33633 -33055/-32537  
		local dailies2 -31471/-29525 
		local dailies3 -28398/-27272 -26572/-26206 -25354/-25081 -24439/-23954 
		local dailies4 -23375/-22858 -22098/-21580 -20911/-20241 -19207/-18841
		local dailies5 -18231/-17532 -17135/-16467 -15097/-14916 -14579/-14063 -13363/-12967 
		local dailies6 -12114/-11749 -11079/-9802 -8249/-7884 -5419/-5205 
		local dailies7 -4048/-3744 -2344/-2071 -852/-640 121/397 3653/3957 5083/5538 7336/7487 7883/8340 
		local dailies8 11170/11382 15066/15280 17532/18049
		local dailies9 3653/3957 5083/5538 7336/7487 7883/8340 11170/11382 15066/15280 17532/18049
				
		local daily_list `" "`dailies1'" "`dailies2'" "`dailies3'" "`dailies4'" "`dailies5'" "`dailies6'" "`dailies7'" "`dailies8'" "`dailies9'" "'
		local shading_list
		foreach daily in `daily_list' {	
			numlist "`daily'", sort
			local shading_list `shading_list' `r(numlist)'
		}
	}
	
	else if "`shader'" == "week" {
		// these are all of the end of nber nber recession dates (in ymd format)
		local weeklies -5465 -5331/-5257 -5157/-5127 -4923/-4789 ///
			-4707/-4633 -4481/-4204 -4044/-3883 -3784/-3731 -3610/-3571 ///
			-3480/-3411 -3328/-3255 -3147/-3073 -2977/-2882 -2735/-2683 ///
			-2596/-2496 -2440/-2345 -2150/-2124 -2076/-2003 -1903/-1846 ///
			-1725/-1673 -1578/-1396 -1175/-1123 -772/-741 -577/-533 ///
			-334/-295 -122/-92 17/56 520/563 723/788 1044/1066 1122/1187 ///
			1590/1620 2144/2175 2496/2569

		numlist "`weeklies'", sort
		local shading_list `r(numlist)'
	}
	
	else if "`shader'" == "month" {
		// these are all of the dates (in ym format) that correspond to nber recessions
		local monthlies -1261 -1230/-1213 -1190/-1183 -1136/-1105 -1086/-1069 ///
			-1034/-970 -933/-896 -873/-861 -833/-824 -803/-787 -768/-751 ///
			-726/-709 -687/-665 -631/-619 -599/-576 -563/-541 -496/-490 ///
			-479/-462 -439/-426 -398/-386 -364/-322 -271/-259 -178/-171 ///
			-133/-123 -77/-68 -28/-21 4/13 120/130 167/182 241/246 259/274 ///
			367/374 495/502 576/593

		numlist "`monthlies'", sort
		local shading_list `r(numlist)'	
	}
	
	else if "`shader'" == "quarter" {
		// these are all of the end of period nber recession dates (in yq format) 
		local quarterlies -421 -410/-405 -397/-395 -379/-369 -362/-357 -345/-324 ///
			-311/-300 -291/-288 -278/-276 -268/-263 -256/-251 -242/-237 ///
			-229/-223 -211/-207 -200/-193 -188/-181 -166/-164 -160/-155 ///
			-147/-143 -133/-130 -122/-108 -91/-87 -60/-58 -45/-42 -26/-24 ///
			-10/-8 1/3 40/42 55/60 80/81 86/90 122/124 165/166 192/197

		numlist "`quarterlies'",sort
		local shading_list `r(numlist)'
	}
	return local shading_list `shading_list'
end





/*
the shader width is calculated by calling:

set obs 2000
gen date = _n
gen series = _n
gen shader = series > 2 & series < 5
set more off

local n 50

bgshade series if inlist(date,1,`n'), shaders(shader) ///
	twoway(line series date if date <= `n', ylab(2.5(2)4.5)) ///
								 sstyle(lwidth(#))

								 
over and over changing the lwidth until it is just right 
I then record the value of lwidth along with the number of units on the x axis
Finally, I increment the units on the x axis. I pasted my results below.
I then run this quick script to get the coefficient on 1/date_count:

clear
input x y
n_list lwidth_list
end

gen x_over = 1/x
reg y x_over


the coefficient is ~470 when using * and ~130 without, the y-axis also changes 
things, so the coefficients are ~*350 and ~90. I also added a 1% multiplier to
the x count, so that teh x count is increased by 1% because it just seemed to
make all values of `n' look better. 
Any thoughts on a better way are much appreciated!

*/
