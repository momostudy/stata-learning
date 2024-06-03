*! version 2.01
*! 2008.08.23
*! Author: Lian Yu-jun, Sun Yat-Sen University
*! E-mail: arlionn@163.com
*! 2009.08.09 
*  新增 gen() 选项，用于标示平行面板的样本，受 -panelthin- 启发

cap program drop xtbalance
program define xtbalance
version 8.0

   syntax , Range(numlist min=2 max=2 int ascending) [Miss(varlist)]
   
   qui capture tsset
   capture confirm e `r(panelvar)'
   if ( _rc != 0 ) {
     dis as error "You must {help tsset} your data before using {cmd:xtbalance},see help {help xtbalance}."
     exit
   }
   
   qui tsset
   local id   "`r(panelvar)'"
   local t    "`r(timevar)'" 
   
   gettoken byear oyear : range
   
   qui count if (`t'<`byear') | (`t'>`oyear')
   if `r(N)' != 0 {
      dis _n in g "(" in y `r(N)' in g " observations deleted due to out of range) "
   }
   cap drop if (`t'<`byear') | (`t'>`oyear')  /*减少搜索量*/
   
   tempvar  missv                     /*删除 varlist 中的缺漏值*/
   egen `missv' = rmiss(`miss')
   qui count if `missv' !=0
   qui drop if `missv' != 0
   if "`miss'" != "" & `r(N)'!=0{
      dis _n in g "(" in y `r(N)' in g " observations deleted due to missing) "
   }
    
   qui sum `t', meanonly  /*判断用户输入的区间是否超出了样本的时间区间*/ 
   local rmin = r(min)
   local rmax = r(max)
   if `byear'<r(min){
     dis in g "#1" in r " in option "   ///
         in g "range(#1,#2)", in r "i.e., "       ///
         in g `byear', in r "must be greater than "  ///
         in g "`rmin'," in r " the smallest year in sample."
     exit
   }
   else if `oyear'>r(max){
     dis in g "#2" in r " in option "   ///
         in g "range(#1,#2)", in r "i.e., "       ///
         in g `oyear', in r "must be less than "  ///
         in g "`rmax'," in r " the largest year in sample."
     exit
   }
   
   tempvar pt
   qui xtpattern, gen(`pt')  /*调用外部命令xtpattern*/
   
   * 样本区间
   local r2 = `oyear' - `byear' + 1             
   
   local dot  ""            /*产生xtpattern对应的模式，"11111"*/
   forvalues i = 1/`r2'{
     local dot "`dot'1"
   }
   
   qui count if `pt' ! = "`dot'"
   if `r(N)' != 0 {
      dis _n in g "(" in y `r(N)' in g " observations deleted due to discontinues) "
   }
   cap drop if `pt' ! = "`dot'"
   
   qui tsset
   
end

     
program def xtpattern, sortpreserve   
* NJC 1.0.1 29 January 2002 
	version 7 
	syntax [if], Generate(string) 
	marksample touse
	local g "`generate'" 

	qui tsset 
	
	if "`r(panelvar)'" == "" { 
		di as err "no panel variable set"
		exit 198 
	} 
	else local panel "`r(panelvar)'"
	
	local time "`r(timevar)'" 

	capture confirm new variable `g' 
	if _rc { 
		di as err "`g' should be new variable"
		exit 198 
	} 	

	tempvar T occ
	
	qui egen `T' = group(`time') if `touse' 
	
	* update for Stata/SE 11 February 2002 
	local smax = cond("$S_StataSE" == "SE", 244, 80) 

	su `T', meanonly 
	if `r(max)' > `smax' { 
		di as err "number of times > `smax': no variable created"
		exit 198 
	} 
	else local max = `r(max)'
	
	qui gen str1 `g' = "" 
	gen byte `occ' = 0 

	sort `touse' `panel' 
	
	qui forval t = 1/`max' { 
		by `touse' `panel': replace `occ' = sum(`T' == `t') 
		by `touse' `panel': replace `occ' = `occ'[_N] 
		by `touse' `panel': /* 
	*/ replace `g' = `g' + cond(`occ', "1", ".") if `touse'
	}
end           
               
                    
                              
