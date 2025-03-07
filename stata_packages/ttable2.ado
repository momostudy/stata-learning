*! Authors:
*! Xuan Zhang, Ph.D., Zhongnan Univ. of Econ. & Law (zhangx@znufe.edu.cn)
*! Chuntao Li, Ph.D. , Zhongnan Univ. of Econ. & Law (chtl@znufe.edu.cn)
*! January 22, 2013
*! Updated by Lian Yujun, Sun Yat-sen University (2013-06-22)
*  more siutable format of table


capture program drop ttable2 
program define ttable2, rclass
version 12.0
syntax varlist(min=1) [if] [in], by(varname) [Format(string)]
 
		  
  tokenize `varlist'
  local k : word count `varlist'
	forval i=1(1) `k' {
	  confirm numeric variable ``i''
	  }
	  
  qui tab `by' `if' `in'
    if r(r) ~=2 {
	     di in red "cannot find two groups"
         exit 198
	}
	   
	   
*----------Arlion new added --------begin--------------
    if `"`format'"' != "" {
       capt local tmp : display `format' 1
       if _rc {
          di as err `"invalid %fmt in format(): `format'"'
          exit 120
       }
    }
	else{
	   local format %8.3f
	}	
*----------Arlion new added --------over--------------   
	  
	  
  tempname mat ttable 
  qui tabstat `varlist' `if' `in', s(N mean) by(`by') save
  mat `ttable'=  r(Stat1)' , r(Stat2)',J(`k',2,0)
  local Group1_name = r(name1)
  local Group2_name = r(name2)
  forval i = 1(1) `k' {
    qui ttest ``i'' `if' `in', by(`by')
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
	
		 local star0=""
		 local star1= "*"
		 local star2= "**"
		 local star3= "***"

	  di in smcl in gr _n "{hline 74}"
	  disp "Variables" in smcl _col(13) "G1(" abbrev("`Group1_name'",8) ")"  _col(28) _c
	  disp "  Mean1" _col(40) "G2(" abbrev("`Group2_name'",8) ")"  _col(53) _c 
	  disp "  Mean2" _col(64) "  MeanDiff" 
	  di in smcl in gr  "{hline 74}"
	  
    forval i = 1(1)`k' {
      disp in g abbrev(`"``i''"',10) _c 
	  *disp "``i''," _c 
	  disp _col(15) in y scalar(`ttable'[`i', 1]) _c
	  disp _col(28) in y `format' scalar(`ttable'[`i', 2]) _c
	  disp _col(43) in y scalar(`ttable'[`i', 3]) _c
	  disp _col(53) in y `format' scalar(`ttable'[`i', 4]) _c
	  disp _col(64) in y `format' scalar(`ttable'[`i', 5]) _c
	  local star = scalar(`ttable'[`i', 6])
	  disp in g "`star`star''" 
	}
	
	di in smcl in gr  "{hline 74}"
	 
	 
	/*
	 abbrev(`"`i'"',8)
	_ttest botline
	di as txt _col(6) "mean(diff) = mean(" as res /// 
		abbrev(`"`xvar1'"',16) as txt ///
		" - " as res abbrev(`"`xvar2'"',16) as txt ")" ///
		as txt _col(67) "t = " as res %8.4f `t'
    */
    
end
