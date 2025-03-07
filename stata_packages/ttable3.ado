*! v 2.01, 2020/11/24
*  more siutable format of table

*-2013-10-12 return ttable matrix
*            option rowname

*-2013-10-15 more options provided by -ttest- 
*            unequal variance of the two-groups

*-2013-12-13 option  nostar Tvalue Pvalue

*-2015-03-31 realized the option NOStar, Tvalue and Pvalue

*-2017-04-19 fix bug for "ttable3 x1, by(g) median format(%6.4f)"

*-future work: see ttestplus.ado to allow by(varlist) instead of by(varname)
*              see meantab.ado for various output statistics

*capture program drop ttable3 
program define ttable3, rclass
version 10.0
syntax varlist(min=1) [if] [in], by(varname) /*
      */ [Format(string) UNEqual Welch MEDian Rowname Moption NOTitle ///
		NOStar Tvalue Pvalue ]
 

	tokenize `varlist'
	local k : word count `varlist'
	forval i=1(1)`k' {
		confirm numeric variable ``i''
	}
	  
	qui tab `by' `if' `in'
	if r(r) ~=2 {
		 di in red "more than 2 groups found, only 2 allowed"
		 exit 198
	}
	   

    if `"`format'"' != "" {
       capt local tmp : display `format' 1
       if _rc {
          di as err `"invalid %fmt in format(): `format'"'
          exit 120
       }
	   else{  // the suitable display format is %8.#f
	      tokenize "`format'", p(".")    
		  local 1 "%8"
		  local format `1'`2'`3'
	   }
    }
	else{
	   local format %8.3f
	}	
 
if "`median'"!="" & "`welch'"!=""{
    *dis in red "welch invalid when median is specified"
	dis in red "cannot specify both " in w "welch" in red " and " in w "median"
	exit 198
} 

if "`median'"!="" & "`unequal'"!=""{
    *dis in red "unequal invalid when median is specified"
	dis in red "cannot specify both " in w "unequal" in red " and " in w "median"
	exit 198
}  

if "`tvalue'"!=""&"`pvalue'"!=""{
    *dis in red "either -tvalue- or -pvalue- option can be specified, not both."
	dis in red "cannot specify both " in w "tvalue" in red " and " in w "pvalue"
	exit 198
}
 
*----------- 
*- t-test	  
*-----------

if "`median'"==""{	
	if "`welch'"==""&"`unequal'"==""{
	 local ttitle "Two-sample t test with equal variances"  
	}
	else{
	 local ttitle "Two-sample t test with unequal variances"
	}

	tempname mat ttable 
	qui tabstat `varlist' `if' `in', s(N mean) by(`by') save
	*mat `ttable'=  r(Stat1)' , r(Stat2)',J(`k',2,0)
	mat `ttable'=  r(Stat1)' , r(Stat2)',J(`k',3,0)		// by Lu
	local Group1_name = r(name1)
	local Group2_name = r(name2)
	
	//by Lu
	local matout = 0
	local linelength = 74
	if "`tvalue'"!=""{
		local matout = "r(t)"					
		local laststring = "t-Value"
		local linelength = `linelength' + 10
	}
	else if "`pvalue'"!=""{
		local matout = "r(p)" 					
		local laststring = "p-Value"
		local linelength = `linelength' + 10
	}
	//by Lu

	tokenize `varlist'
	forval i = 1(1) `k' {
		qui ttest ``i'' `if' `in', by(`by') `unequal' `welch'
		
		mat `ttable'[`i', 7] = `matout'			//by Lu

		mat `ttable'[`i',5]=r(mu_1)-r(mu_2)
		if r(p)<=.1 {
			mat `ttable'[`i',6]= 1
		}
		if r(p)<=.05 {
			mat `ttable'[`i',6]= 2
		}
		if r(p)<=.01 {
			mat `ttable'[`i',6]= 3
		}	 
	}
	
	// by Lu
	/* for debug
	dis "`nostar'"
	dis "`notitle'"
	*/
	if "`nostar'"==""{
		local star0= ""
		local star1= "*"
		local star2= "**"
		local star3= "***"
		*dis "hasstar" // for debug
	}
	// by Lu
		 
	if "`notitle'"==""{
		di in g _n "`ttitle'"
	} 
		
	// by Lu
	*di in smcl in gr "{hline 74}"
	di in smcl in gr "{hline `linelength'}"						
	disp "Variables" in smcl _col(13) "G1(" abbrev("`Group1_name'",8) ")"  _col(28) _c
	disp "  Mean1" _col(40) "G2(" abbrev("`Group2_name'",8) ")"  _col(53) _c 
	disp "  Mean2" _col(64) "  MeanDiff" _col(75) _c 				
	disp "  `laststring'"											
	*di in smcl in gr  "{hline 74}"
	di in smcl in gr "{hline `linelength'}"	
	// by Lu
	
	forval i = 1(1)`k' {
		disp in g abbrev(`"``i''"',10) _c 
		disp _col(15) in y scalar(`ttable'[`i', 1]) _c
		disp _col(28) in y `format' scalar(`ttable'[`i', 2]) _c
		disp _col(43) in y scalar(`ttable'[`i', 3]) _c
		disp _col(53) in y `format' scalar(`ttable'[`i', 4]) _c
		disp _col(64) in y `format' scalar(`ttable'[`i', 5]) _c
		
		// by Lu
		if "`tvalue'"!="" | "`pvalue'"!=""{
			disp _col(75) in y `format' scalar(`ttable'[`i', 7]) _c		
		}
		
		
		if "`nostar'" == ""{
			local star = scalar(`ttable'[`i', 6])
		}
		// by Lu
		
		disp in g "`star`star''" 
	}
	 
	mat colnames `ttable' = N1 Mean1 N2 Mean2 Diff Tstar TValue		// by Lu
	if "`rowname'"!=""{
	   mat rownames `ttable' = `by'
	}

	ret matrix rtable = `ttable'   
}

*--------------
*-Median test
*--------------
else{
	local ttitle "Nonparametric equality-of-medians test"
	tempname mat ttable 
	qui tabstat `varlist' `if' `in', s(N p50) by(`by') save
	*mat `ttable' =  r(Stat1)', r(Stat2)', J(`k',2,0)
	mat `ttable'=  r(Stat1)' , r(Stat2)',J(`k',3,0)		// by Lu
	local Group1_name = r(name1)
	local Group2_name = r(name2)

	//by Lu
	local matout = 0
	local linelength = 74
	if "`tvalue'"!=""{
		local matout = "r(t)"					
		local laststring = "t-Value"
		local linelength = `linelength' + 10
	}
	else if "`pvalue'"!=""{
		local matout = "r(p)" 					
		local laststring = "p-Value"
		local linelength = `linelength' + 10
	}
	//by Lu 
	tokenize `varlist'                                       // 2017.04.19 add
	forval i = 1(1) `k' {
		qui median ``i'' `if' `in', by(`by') `moption'       // 2017.04.19 bug
		mat `ttable'[`i', 5] = r(chi2)
		mat `ttable'[`i', 7] = `matout'			//by Lu

		if r(p)<=.1 {
			mat `ttable'[`i',6]= 1
		}
		if r(p)<=.05 {
			mat `ttable'[`i',6]= 2
		} 
		if r(p)<=.01 {
			mat `ttable'[`i',6]= 3
		} 
	}

	// by Lu
	/* for debug
	dis "`nostar'"
	dis "`notitle'"
	*/
	if "`nostar'"==""{
		local star0= ""
		local star1= "*"
		local star2= "**"
		local star3= "***"
		*dis "hasstar" // for debug
	}
	// by Lu
	 
	if "`notitle'"==""{
		di in g _n "`ttitle'"
	}
	
	// by Lu
	*di in smcl in gr "{hline 74}"
	di in smcl in gr "{hline `linelength'}"						
	disp "Variables" in smcl _col(13) "G1(" abbrev("`Group1_name'",8) ")"  _col(28) _c
	disp "  Median1" _col(40) "G2(" abbrev("`Group2_name'",8) ")"  _col(53) _c 
	disp "  Median2" _col(64) "  Diff" _col(75) _c 				
	disp "  `laststring'"											
	*di in smcl in gr  "{hline 74}"
	di in smcl in gr "{hline `linelength'}"	
	// by Lu	  

	forval i = 1(1)`k' {
		disp in g abbrev(`"``i''"',10) _c 
		disp _col(15) in y scalar(`ttable'[`i', 1]) _c
		disp _col(25) in y `format' scalar(`ttable'[`i', 2]) _c
		disp _col(42) in y scalar(`ttable'[`i', 3]) _c
		disp _col(50) in y `format' scalar(`ttable'[`i', 4]) _c
		disp _col(62) in y `format' scalar(`ttable'[`i', 5]) _c
		
		// by Lu
		if "`tvalue'"!="" | "`pvalue'"!=""{
			disp _col(75) in y `format' scalar(`ttable'[`i', 7]) _c		
		}
		
		
		if "`nostar'" == ""{
			local star = scalar(`ttable'[`i', 6])
		}
		// by Lu
		disp in g "`star`star''" 
	}

	mat colnames `ttable' = N1 Median1 N2 Median2 Chi2 star 
	if "`rowname'"!=""{
		mat rownames `ttable' = `by'
	}

	ret matrix rtable = `ttable' 	
}

	di in smcl in gr "{hline `linelength'}"  // by Lu
	 
    
end
