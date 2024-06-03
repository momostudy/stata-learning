*! 1.0.3 NJC 25 Feb 2023 
*! 1.0.2 NJC 4 Dec 2015 
*! 1.0.1 NJC 22 May 2011 
*! 1.0.0 NJC 21 May 2011 
program aaplot
	version 11 
	syntax varlist(numeric min=2 max=2) [if] [in] [,   ///
	bformat(str) aformat(str) cformat(str) rsqformat(str) ///
	rmseformat(str) QUADratic both lopts(str) qopts(str) rsqfix(str) ///
	backdrop(str) addplot(str asis) abbrev(int 10) by(str) * ]

	if "`by'" != "" { 
		di as err "by() option not supported"
		exit 191
	}

	local roman 0 
	local space 0 

	if "`rsqfix'" != "" { 
		local len = length("`rsqfix'") 
		if "`rsqfix'" == substr("roman", 1, `len') { 
			local roman 1 
		} 
		else if "`rsqfix'" == substr("space", 1, `len') { 
			local space 1     
		} 
		else { 
			di as err "rsqfix() not understood"
			exit 198
		} 
	}

	quietly { 
		marksample touse 
		count if `touse' 
		if r(N) == 0 error 2000 
		if r(N) == 1 error 2001 

		tokenize `varlist' 
		args y x
		local X = abbrev("`x'", `abbrev') 
		local Y = abbrev("`y'", `abbrev')

		if "`aformat'" == "" local aformat %7.0g 
		if "`bformat'" == "" local bformat %7.0g 
		if "`cformat'" == "" local cformat %7.0g 
		if "`rsqformat'" == "" local rsqformat %3.1f 
		if "`rmseformat'" == "" local rmseformat : format `y' 

		if "`quadratic'`both'" != "" {
			tempvar xsq 
			gen double `xsq' = `x'^2
		}

		if "`quadratic'" == "" { 
			regress `y' `x' if `touse'
			local sign1 = sign(_b[`x']) 
			local aval1 : di `aformat' _b[_cons]   
			local bval1 : di `bformat' abs(_b[`x']) 
			local rsqval1 : di `rsqformat' 100 * e(r2)     
			local aval1 = trim("`aval1'") 
			local bval1 = trim("`bval1'") 
			local rsqval1 = trim("`rsqval1'") 
			local op1 = cond(`sign1' >= 0, "+", "{&minus}")

			if `roman' { 
				local desc1 "`Y' = `aval1' `op1' `bval1' `X'    R{sup:2} = `rsqval1'%" 
			}
			else if `space' { 
				local desc1 "`Y' = `aval1' `op1' `bval1' `X'    {it:R} {sup:2} = `rsqval1'%" 
			}
			else local desc1 "`Y' = `aval1' `op1' `bval1' `X'    {it:R}{sup:2} = `rsqval1'%" 

			local rmse1 : di `rmseformat' e(rmse) 
		}

		if "`quadratic'`both'" != "" { 
			regress `y' `x' `xsq' if `touse' 
			local sign1 = sign(_b[`x']) 
			local sign2 = sign(_b[`xsq']) 
			local aval2 : di `aformat' _b[_cons]   
			local bval2 : di `bformat' abs(_b[`x']) 
			local cval2 : di `cformat' abs(_b[`xsq']) 
			local rsqval2 : di `rsqformat' 100 * e(r2)     
			local aval2 = trim("`aval2'") 
			local bval2 = trim("`bval2'") 
			local cval2 = trim("`cval2'") 
			local rsqval2 = trim("`rsqval2'") 
			local op1 = cond(`sign1' >= 0, "+", "{&minus}")
			local op2 = cond(`sign2' >= 0, "+", "{&minus}")

			if `roman' { 
				local desc2 "`Y' = `aval2' `op1' `bval2' `X' `op2' `cval2' `X'{sup:2}   R{sup:2} = `rsqval2'%" 
			}
			else if `space' { 
				local desc2 "`Y' = `aval2' `op1' `bval2' `X' `op2' `cval2' `X'{sup:2}   {it:R} {sup:2} = `rsqval2'%" 
			}
			else  local desc2 "`Y' = `aval2' `op1' `bval2' `X' `op2' `cval2' `X'{sup:2}   {it:R}{sup:2} = `rsqval2'%" 

			local rmse2 : di `rmseformat' e(rmse) 
		}

		local N = e(N) 
	}

	local ydesc : var label `y' 
	if `"`ydesc'"' == "" local ydesc "`y'"
	local legend legend(off)  

	if "`quadratic'" != "" { 
		graph twoway			///
		(`backdrop')                    /// 
		(qfit `y' `x' if `touse',	///
		sort				///
		subtitle(`"`desc2'"')   	///
		lc(gs12) 	               	/// 
		`qopts'				///
		)				///
		(scatter `y' `x' if `touse',	///
		ms(oh) pstyle(p1)               ///
		note("{it:n} = `N'    RMSE = `rmse2'") ///
		ytitle(`"`ydesc'"')     	///
			`legend' `options'	///
		)				///
		|| `addplot'	   		
	}
	else if "`both'" != "" { 
		graph twoway			///
		(`backdrop')                    /// 
		(lfit `y' `x' if `touse',	///
		sort				///
		lc(gs12)        	        /// 
		`lopts'	 			///
		)				///
		(qfit `y' `x' if `touse',	///
		sort				///
		t1title(`"`desc1'"')    	///
		subtitle(`"`desc2'"')   	///
		lc(gs6) lp(dash)          	/// 
		`qopts'				///
		)				///
		(scatter `y' `x' if `touse',	///
		ms(oh) pstyle(p1)       	///
		note("{it:n} = `N'    RMSE linear = `rmse1' quad = `rmse2'") ///
		ytitle(`"`ydesc'"')     ///
		`legend' `options'	///
		)				///
		|| `addplot'	   		
	}
	else { 
		graph twoway			///
		(`backdrop')                    /// 
		(lfit `y' `x' if `touse',	///
		sort				///
		subtitle(`"`desc1'"')   	///
		lc(gs12)        	        /// 
		`lopts'	 			///
		)				///
		(scatter `y' `x' if `touse',	///
		ms(oh) pstyle(p1)       	///
		note("{it:n} = `N'    RMSE = `rmse1'") ///
		ytitle(`"`ydesc'"')     ///
		`legend' `options'	///
		)				///
		|| `addplot'	   		
	}
end

