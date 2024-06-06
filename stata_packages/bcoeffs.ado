

		*_* bcoeffs 1.1.0 *_*
	

*--------------------------------------------

/* 
*!version:1.1.0
*!author:Nisus
*!date:2016-4-25

*-上传的包由于我疏忽导致-beta()-被误写为-generate()-
*-取消选项-dxmin-
*-增加：-moptions-用户可以指定回归模型的选项，如-xtreg-时用-fe-或-re-



 */

*----------------

*!version:1.0.0
*!author:Nisus
*!date:2015-5-24

/* 改进方法：
	对自变量来个逐个迭代
	将原 bcoeff 微调下。。---2015-5-24 01:20:43
	可以得到若干个自变量的系数，而不是一个变量的。。。
	
	若要得到 x1 的系数、标准误、、，储存在变量：_b_x1 、 _se_x1  _cons
	
 */
	// 主要用途：储存干变量的估计系数！ 参见：-bcoeff-



*============================================================

cap pro drop bcoeffs
program define bcoeffs
*------bcoeff's syntax below-------
/* version 13.0 
syntax varlist(min=2 numeric) [if] [in] , Generate(str) ///
		[by(varlist) Se(str) Cons(str) Double MISSing]

program define bcoeff
*! 1.2.0 ZW/NJC 20 June 2000 
* 1.1.0 NJC 15 June 2000 
* after deltaco 1.0.5 Z.WANG 16Jun2000
* deltaco 1.0.1 Z.WANG 1May1999 */
*-------------------------------------------
        version 13.0
        syntax varlist(min=2 numeric)  /* 
        */ [, Beta(str) by(varlist) /* 
        */  Model(str)  MOptions(str)  Nmin(real 2)  Only(varlist numeric)/* 
        */ Se(str) Cons(str) Double MISSing ]
        	// v1.1.0?óè???1é?￡Dí????￡o-MOption
			
			
		marksample touse

    quietly {

        *--错误提示---------------------------------     

            *- 虽然所有选项都是可选项，但是什么选项都不选，你想做什么呢？
            if "`beta'"=="" & "`se'"=="" & "`cons'"==""  {
            	dis in red "You should indicate whcih coefficient to store, {opt beta /se /sons ?}"
            	exit 198
            }

		*--初始设置-----------------------
	        local model = cond(trim(`"`model'"') == "", "regress", "`model'")   //model -- regress y x1 x2 ...
	       /*  if "`dxmin'" == "" { 
				local dxmin = 0 
			}    (v1.1.0  cancel)*/
           	
			local moptions=cond(trim(`"`moptions'"')=="" , "" , ",`moptions'") // (v1.1.0 add) -- options of regression, like xtreg's fe or re 

            *- get independent varible whose coeffient to store  and how many ... -- nvar
            if "`only'"==""  {    
				gettoken y x : varlist
				
				local nvar : word count `x'
				
				tokenize `x'  //split inpen...
                 
			}
			else {
				local nvar : word count `only'
				tokenize `only'
				
			}
			
			*- by option
			if "`by'" != "" {
				loc bylab "by(`by')"
			}
		
		
	*--gen null variable for store ... and labels----------------
		
		forval var=1/`nvar'  {

		
				*- regress and store coeffients
				
                if "`cons'" != ""  { 
					
					if `var'==1  {	
						local xcons "__`cons'"
                        confirm new variable `xcons' 
                        gen `double' `xcons' = . 
                        local lbl /* 
                        */ `"constant: `model' `varlist'`if' `in' `moptions'`bylab'"'  
                        if length("`lbl'") > 80 { 
                                note `xcons' : `"`lbl'"' 
                                label var `xcons' "see notes->type cmd:note"
                        } 
                        else  {
							label var  `xcons'  `"`lbl'"' 
						}
					}
				}
				else loc nocons "*"		
			
                
                *- beta
                if "`beta'" !="" {
				
					
						confirm new variable  _`beta'_``var''
						local xb "_`beta'_``var''"
						gen `double' `xb' = .
						local lbl `"b[``var'']: `model' `varlist'`ifn' `moptions'`bylab'"' 
						if length("`lbl'") > 80 { 
	                        note `xb' : `"`lbl'"'  
	                        label var `xb' "see notes->type cmd:note"
						} 
						else { 
							dis in r "`inx'"
							label var `xb' `"`lbl'"'  
						}
						
					}
				else local nobeta "*"

        		*- se
                if "`se'" != "" { 
						local xse "_`se'_``var''"
                        confirm new variable `xse' 
                        gen `double' `xse' = .
						local lbl /* 
                        */ `"se[``var'']: `model' `varlist'`ifn' `moptions'`bylab'"' 
                        if length("`lbl'") > 80 { 
                                note `xse' : `"`lbl'"'
                                label var `xse' "see notes->type cmd:note"
                        } 
                        else label var `xse' `"`lbl'"'  
                } 
                else local nose "*" 

       

		}  //forval  end 



	
	*--group to regress ,...---------
	                            
                
				
				tempvar  group
				
                sort `touse' `by'
                by `touse' `by': replace `touse' = 0 if _N < `nmin'  //exclude obs <[nimin]
               /*  egen `xmax' = max(`x1'), by(`touse' `by')
                egen `xmin' = min(`x1'), by(`touse' `by')
                replace `touse' = 0 if (`xmax' - `xmin') <= `dxmin'  */
                
                egen `group' = group(`by') if `touse', `missing'  
                su `group', meanonly  
                local ng = r(max)  //get count of groups
				if `ng'>50 {
					dis in green "Note:count of goups is greater than 50, would run slowly."
				}
                
                local i = 1
                while `i' <= `ng' {                     
                        cap `model' `varlist' if `group' == `i'  `moptions'   //     EX:   xtreg y x if group == i & ... in ... , fe
						//dis in r "`model' `varlist' if `group' == `i'"
                        if _rc == 0 { 


                        	forval var=1/`nvar'   {


								`nose' replace _`se'_``var'' = /* 
	                                */ _se[``var''] if `group' == `i' 
	                                
	                            `nocons' if `var'==1   replace __`cons' = /* 
	                                */ _b[_cons] if `group' == `i' 
	                                
	                            `nobeta' replace _`beta'_``var'' = _b[``var''] if `group' == `i' 

                        	}
                                
                        } 
                        local i = `i' + 1
                }       
       
		
		
}  //quietly end	
		
		
		
		
end 	
		

		
		
		
		
		
		
		
		
/* test */

/*

cls
sysuse auto.dta , clear
set trace on

bcoeffs_t price mpg , b(b) se(s) c(c)  by(foreign)  //ok
bcoeffs_t price mpg trunk weight length, b(b) se(s) c(c)  by(foreign rep78) only(weight length)  //ok
bcoeffs_t price mpg trunk weight length, b(b) se(s) c(c)  by(foreign rep78) only(weight length)  nmin(4)  //ok



bcoeffs_t price mpg , b(b) se(s) c(c)  //ok
set trace on 
bcoeffs_t price mpg , b(b)  // ok

drop _*
bcoeffs_t price mpg , b(b) se(s)  //ok

cls
sysuse census.dta ,clear
bysort region:gen year=_n
xtset region year
set trace on
bcoeffs_t death pop medage , beta(b) model(xtreg) moption(fe) 
 
sysuse census.dta ,clear
bysort region:gen year=_n
xtset region year
gen gr=.
replace gr=1 in 1/10
replace gr=2 in 11/15
replace gr=3 in 16/40
replace gr=4 in 41/50
set trace on 
bcoeffs_t death pop medage , beta(b) se(se) cons(c) model(xtreg) moption(re) by(gr) // 有的组变量不够

*/	
		
		
		
		
		
		

