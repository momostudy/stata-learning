*! First version  2006.4.14  17:58
*! This  version  2014.5.21  17:46
*! Author: Lian Yu-jun
*! E-mail: arlionn@163.com
*! Homepage: http://goo.gl/XZlgN 

*-Update: 2014-01-07
*         2014-05-21

cap program drop xtthres2
program define xtthres2, eclass
version 11.0

    syntax varlist [if] [in] , THres(varname) Dthres(varname)    /*
        */ [ Qn(int 400)  BS1(int 300) BS2(int 300) BS3(int 300) /*
        */ Level(int 95) Minobs(int 10)]

/*		
    cap which gsample  // -gsample- command is required
    if _rc {
        di _n as error "-gsample- command is required;"
		di in y "To install, click {stata ssc install gsample, replace}"
        error 499
    }	 
*/	
*set trace on 
	local m = max(`qn',`bs1',`bs2',`bs3')
	if `m'>`c(max_matsize)'{
	   dis as error "# in qn(#) or bsi(#) must be smaller than `c(max_matsize)'."
	   exit 199
	}
	if `m'>`c(matsize)'&`m'<`c(max_matsize)'{
	   if `m'>8000{
	     dis in yellow "Warning: The program may not run with too high value in bs(#)"
		 dis in yellow "         You can set a smaller value in bs(#)"
	   }
	   nois set matsize `m'
	}
	if `m'<=`c(matsize)'{
	   set matsize `m'
	}
*set trace off
	 
     qui capture tsset
     capture confirm e `r(panelvar)'
     if ( _rc != 0 ) {
     dis as error "You must {help tsset} your data before using {cmd:xtthres},see help {help xtthres}."
     exit
     }	
	 
/*
     local N = _N
     if `N'>400{
        qui set matsize `N'
     }
*/
     
    /* check collinearity */
    xt_iis `i'
    local ivar "`s(ivar)'"
    qui _rmcoll `varlist'
    local retlist `r(varlist)' `ivar'
    qui _rmcoll `retlist'
    if "`r(varlist)'" ~= "`retlist'" {
        di as err "independent variables " _c
        di as err "are collinear with the panel variable" _c
        di as err " `ivar'"
        exit 198
    }
	
    /* check balance */
    qui xtdes
    if r(min)!=r(max){
        dis as err "The dataset must be balance"
        exit
    }
     
	 
     dis _n in g "Begin Time: " in y "`c(current_date)' `c(current_time)'"
	 qui timer clear 99
	 qui timer on    99

     
     marksample touse
     markout `touse' `varlist'     
     gettoken depvar indvars: varlist  

     qui  sum                            /*基本信息，包括样本数、CC*/
     local level = `level'/100
     local cc    = -2*ln(1-sqrt(`level'))
     qui tsset
     local id   "`r(panelvar)'"
     local t    "`r(timevar)'" 
     

 qui{                 /*qui begin*/
     tempname pc
     preserve
     keep if `touse'
     qui duplicates report `thres'    //非重复门槛值的个数         
     local qnt = r(unique_value)      /*对于门槛变量的观察值小于400的情况，采用真实个数*/
     if `qnt'<`qn'{
          local qn = int(0.94*`qnt')
     }
     else if `qn'>`qnt'{
       local qn = `qnt'
       n dis in g "Note: there are only " in y `qnt' in g " unique values in threshold variable " in y "`thres'" 
       n dis in g "      qn is now specified as " in y `qnt'
     }      

 /*
     mat `pc' = J(`qn',1,0)            /*存储分位数的向量*/
     _pctile `thres' , n(`=`qn'+1')
       forvalues i = 1(1)`qn'{
          mat `pc'[`i',1]= r(r`i')
       }
 */
     tempvar pcq 
	 pctile `pcq'=`thres', n(`=`qn'+1')
	 mkmat `pcq' if `pcq'<., mat(`pc')
	 cap drop `pcq'
	 
    restore,preserve
    keep if `touse'  
    sum
    local NT    = r(N)
    tempname data
    save "`data'",replace              /*以备后面BS时调用*/
    eret clear
    local lim_obs = `minobs'            
    }                  /*qui over*/

*==========================================================
*================Single Model==============================
*==========================================================
Get_rhat 0 0 `qn' `pc' `thres' `dthres' `lim_obs' 1 `NT' `cc' "`varlist'" 

di _n _n
tab_title, title(单一门槛面板模型)
dis
dis in g "第一个门槛估计值(gamma1)：" in y %6.3f e(rhat) _n 

tempname sse1V gama1V LR1 
local gama1  = e(rhat)                  /*为了后面计算F_true，和估计模型参数*/
local Smin1  = e(Smin)
 mat `sse1V' = e(sse)
 mat `gama1V'= e(gama)
 mat  `LR1'  = e(LR)                    /*待返回值，LR1，置信区间[minc,maxc]，下同*/ 
local minc1  = e(minc)
local maxc1  = e(maxc)


*---计算F真实值-----  test  
Xttr_F `varlist', thres(`thres') dthres(`dthres') rhat1(`gama1') yhatout(0)  /*single model*/ 
local g1 = round(`gama1',0.001)
  dis `"Note: `dthres'_1: `dthres'*I(`thres'<`g1') "'
  dis `"      `dthres'_2: `dthres'*I(`thres'>=`g1')"'
local sse1 = e(sse)
qui xtreg `varlist' `dthres',fe
local sse0 = e(rss)
local F1_true = (`sse0'/`sse1'-1)*`NT'

dis _n in w "STATA 自抽样中，请等待 ... ..." _n

*---Bootstrap--F 的置信区间---------
qui{
   tempfile order_id order_data

*1 为原始数据增加一个新的标号idnew，按1,2,...,N 排序。此部分得到的order_data可以被三个模型公用。  
   /*                       M0107
   use "`data'",clear
   tsset 
   keep if `t'==r(tmin)
   keep `id'
   gen idnew = _n
   sort `id'
   save "`order_id'",replace
   */
   
   use "`data'",clear  
   tsset  
   bysort `id': gen idnew = (_n==1)    // M0107
   replace idnew = sum(idnew)
   tsset idnew `t'
   save "`order_data'",replace       /*得到增加idnew后的数据*/

*2 生成bs样本，并用它计算bs的F值。
*  思路：生成包含yhat的数据M1_data, 残差向量数据ehat_data,对后者BS得到e_bs_data;
*        merge M1_data和e_bs_data得到BS样本，分别估计M0和M1，计算F_bs。
  
* -----------Model 1--BS--begin----------这部分可以做成子程序的，future work------
      tempfile  M1_data  ehat_data  e_bs_data
      tempname VF1_bs F1_bs
      mat `VF1_bs' = J(`bs1',1,0) 
     
      use "`order_data'",clear                           /*data added with idnew*/
      Xttr_F `varlist', dthr(`dthres') model(0) out(0)    
      tsset idnew `t'
      save "`M1_data'",replace                           /*包含yhat 和 idnew*/ 
     
      use "`data'",clear 
      Xttr_F `varlist', dthr(`dthres') model(0) out(0)   /*no thre model,get yhat*/
      keep `id' `t' ehat
      save "`ehat_data'",replace
     
   forvalues i = 1(1)`bs1'{ 
       use "`ehat_data'",clear
	   bsample, cluster(`id') idcluster(idnew)
       *gsample, cluster(`id') idcluster(idnew)
	   rename ehat e_bs
	 /*  
	   reshape wide ehat, i(`id') j(`t')
       bsample 
       gen idnew = _n
       reshape long ehat, i(idnew) j(`t')
       rename ehat e_bs
       tsset idnew `t'
	 */  
	   merge 1:1 idnew `t' using "`M1_data'",nogen   // M0107
       *cap drop _merge
	   *save "`e_bs_data'",replace
       /*
       use "`M1_data'",clear
       cap drop _merge
       merge idnew `t' using "`e_bs_data'" 
       drop _merge
       */
       gen y_bs = yhat + e_bs      
             
       Xttr_F y_bs `indvars', th(`thres') dth(`dthres') out(0) yhatout(0) model(0)
       local sse0 = e(sse)
       Xttr_F y_bs `indvars', th(`thres') dth(`dthres') out(0) yhatout(0) model(1) rhat1(`gama1')
       local sse1 = e(sse)
       mat `VF1_bs'[`i',1] = (`sse0'/`sse1'-1)*`NT'
   }   

       svmat `VF1_bs',names(`F1_bs')
       sum `F1_bs'1  ,d
       local F1_bs10 = r(p90)         /* 10%,5%,1%临界值 */
       local F1_bs5  = r(p95)
       local F1_bs1  = r(p99)
       count if `F1_true' < `F1_bs'1 & `F1_bs'1 != .
       local P1_bs = r(N)/`bs1'  

}           
* -----------Model 1--BS--over----------
outreg2 using out.doc, tstat bdec(3) tdec(2) replace

*==========================================================
*===================Double Model===========================
*==========================================================

*----第一轮搜索-----
Get_rhat `gama1' 0 `qn' `pc' `thres' `dthres' `lim_obs' 2 `NT' `cc' "`varlist'" 

dis _n
tab_title, title(双重门槛面板模型)
dis
tab_title, titl(搜索第二个门槛值) s
dis
dis in g "第二个门槛估计值(gamma2)：" in y %6.3f e(rhat) _n

tempname sse22V gama22V LR22
local gama22  = e(rhat)                   /*为了后面计算F_true，和估计模型参数*/
local Smin22  = e(Smin)
mat  `sse22V' = e(sse)
mat  `gama22V'= e(gama)
mat   `LR22'  = e(LR)                     /*待返回值，LR1，置信区间[minc,maxc]，下同*/ 
local minc22  = e(minc)
local maxc22  = e(maxc)
local rr2 = e(rhat)                      /*作为三重门槛模型的输入值*/


*----第二轮搜索-----
Get_rhat `gama22' 0 `qn' `pc' `thres' `dthres' `lim_obs' 2 `NT' `cc' "`varlist'" 

dis
tab_title, titl(重新搜索第一个门槛值) s
dis
dis in g "更新后的第一个门槛估计值(gamma1)：" in y %6.3f e(rhat) _n

tempname sse21V gama21V LR21
local gama21  = e(rhat)                  /*为了后面计算F_true，和估计模型参数*/
local Smin21  = e(Smin)
mat  `sse21V' = e(sse)
mat  `gama21V'= e(gama)
mat   `LR21'  = e(LR)                /*待返回值，LR1，置信区间[minc,maxc]，下同*/ 
local minc21  = e(minc)
local maxc21  = e(maxc)


*---计算F真实值-----  test
Xttr_F `varlist', th(`thres') dt(`dthres') rhat22(`gama22') rhat21(`gama21') model(2) yhatout(0)
local sse1 = e(sse)

    est store mDouble        // M 0106  store the results of double threshold model

Xttr_F `varlist', thres(`thres') dthres(`dthres') rhat1(`gama1') out(0) yhatout(0)  /*single model*/

    est store mSingle        // M 0106  store the results of single threshold model

  local g01 = min(`gama21',`gama22')
  local g02 = max(`gama21',`gama22')
  local g1  = round(`g01',0.001)
  local g2  = round(`g02',0.001)
  
  dis `"Note: `dthres'_1: `dthres'*I(`thres'<`g1') "'
  dis `"      `dthres'_2: `dthres'*I(`g1'<=`thres'<`g2')"'
  dis `"      `dthres'_3: `dthres'*I(`thres'>=`g2') "'
  
local sse0 = e(sse)
local F2_true = (`sse0'/`sse1'-1)*`NT'

dis _n in w "STATA 自抽样中，请等待 ... ..." _n

* -----------Model 2--BS--begin----------
qui{
      tempfile  M1_data  ehat_data  e_bs_data
      tempname VF2_bs F2_bs
      mat `VF2_bs' = J(`bs2',1,0) 
     
      use "`order_data'",clear                           
      Xttr_F `varlist', dthr(`dthres') thr(`thres') model(1) out(0) rhat1(`gama1')    
      tsset idnew `t'
      save "`M1_data'",replace                          
      
      use "`data'",clear 
      Xttr_F `varlist', dthr(`dthres') thr(`thres') model(1) out(0) rhat1(`gama1')   
      keep `id' `t' ehat
      save "`ehat_data'",replace
     
   forvalues i = 1(1)`bs2'{ 
       use "`ehat_data'",clear

	   bsample, cluster(`id') idcluster(idnew)
       *gsample, cluster(`id') idcluster(idnew)
	   rename ehat e_bs
	 /*  
	   reshape wide ehat, i(`id') j(`t')
       bsample 
       gen idnew = _n
       reshape long ehat, i(idnew) j(`t')
       rename ehat e_bs
       tsset idnew `t'
	 */  
	   merge 1:1 idnew `t' using "`M1_data'", nogen    // M0107
       
	   *save "`e_bs_data'",replace
       /*
       use "`M1_data'",clear
       cap drop _merge
       merge idnew `t' using "`e_bs_data'" 
       drop _merge
       */
       gen y_bs = yhat + e_bs     
             
       Xttr_F y_bs `indvars', th(`thres') dth(`dthres') out(0) yhatout(0) model(1) /*
                            */ rhat1(`gama1')
       local sse0 = e(sse)
       Xttr_F y_bs `indvars', th(`thres') dth(`dthres') out(0) yhatout(0) model(2) /*
                            */ rhat21(`gama21') rhat22(`gama22')
       local sse1 = e(sse)
       mat `VF2_bs'[`i',1] = (`sse0'/`sse1'-1)*`NT'
   }   

       svmat `VF2_bs',names(`F2_bs')
       sum `F2_bs'1  ,d
       local F2_bs10 = r(p90)         /* 10%,5%,1%临界值 */
       local F2_bs5  = r(p95)
       local F2_bs1  = r(p99)
       count if `F2_true' < `F2_bs'1 & `F2_bs'1 != .
       local P2_bs = r(N)/`bs2'    
}           
* -----------Model 2--BS--over----------
outreg2 using out.doc, tstat bdec(3) tdec(2)  append

*==========================================================
*================Triple Model==============================
*==========================================================
Get_rhat `gama21' `gama22' `qn' `pc' `thres' `dthres' `lim_obs' 3 `NT' `cc' "`varlist'" 

dis _n
tab_title, title(三重门槛面板模型)
dis
dis in g "第三个门槛估计值(gamma3)：" in y %6.3f e(rhat) _n 


tempname sse3V gama3V LR3
local gama3  = e(rhat)                  /*为了后面计算F_true，和估计模型参数*/
local Smin3  = e(Smin)
mat  `sse3V' = e(sse)
mat  `gama3V'= e(gama)
mat   `LR3' = e(LR)                     /*待返回值，LR1，置信区间[minc,maxc]，下同*/ 
local minc3 = e(minc)
local maxc3 = e(maxc)

*---计算F真实值-----  test
Xttr_F `varlist', th(`thres') dt(`dthres') /*    Triple model
                */rhat22(`gama22') rhat21(`gama21') rhat3(`gama3') model(3) yhatout(0)
local sse1 = e(sse)

    est store mTriple        // M 0106  store the results of triple threshold model

  *local g01 = min(`gama21',`gama22')
  *local g02 = max(`gama21',`gama22')

    local r31 = min(`gama21',`gama22',`gama3')
    local r33 = max(`gama21',`gama22',`gama3')
    foreach rrr of numlist `gama21' `gama22' `gama3'{
        if `rrr'<=`r33'&`rrr'>=`r31'{                  /*test*/
           local r32 = `rrr'
           continue,break
        }
    }
  
  local g1  = round(`r31',0.001)
  local g2  = round(`r32',0.001)
  local g3  = round(`r33',0.001)
  
  dis `"Note: `dthres'_1: `dthres'*I(`thres'<`g1') "'
  dis `"      `dthres'_2: `dthres'*I(`g1'<=`thres'<`g2')"'
  dis `"      `dthres'_3: `dthres'*I(`g2'<=`thres'<`g3')"'
  dis `"      `dthres'_4: `dthres'*I(`thres'>=`g3') "'
  
Xttr_F `varlist', th(`thres') dt(`dthres') rhat22(`gama22') rhat21(`gama21') model(2) out(0) yhatout(0)
local sse0 = e(sse)
local F3_true = (`sse0'/`sse1'-1)*`NT'

  

dis _n in w "STATA 自抽样中，请等待 ... ..." _n

* -----------Model 3--BS--begin----------
qui{
      tempfile  M1_data  ehat_data  e_bs_data
      tempname VF3_bs F3_bs
      mat `VF3_bs' = J(`bs3',1,0) 
     
      use "`order_data'",clear                          
      Xttr_F `varlist', dthr(`dthres') thr(`thres') model(2) out(0) rhat21(`gama21') rhat22(`gama22')    
      tsset idnew `t'
      save "`M1_data'",replace                            
      
      use "`data'",clear 
      Xttr_F `varlist', dthr(`dthres') thr(`thres') model(2) out(0) rhat21(`gama21') rhat22(`gama22')    
      keep `id' `t' ehat
      save "`ehat_data'",replace
     
   forvalues i = 1(1)`bs3'{ 
       use "`ehat_data'",clear
	   bsample, cluster(`id') idcluster(idnew)
       *gsample, cluster(`id') idcluster(idnew)
	   rename ehat e_bs

	   merge 1:1 idnew `t' using "`M1_data'", nogen    // M0107
       
       gen y_bs = yhat + e_bs      
             
       Xttr_F y_bs `indvars', th(`thres') dth(`dthres') out(0) yhatout(0) model(2) /*
                            */ rhat21(`gama21') rhat22(`gama22')
       local sse0 = e(sse)
       Xttr_F y_bs `indvars', th(`thres') dth(`dthres') out(0) yhatout(0) model(3) /*
                            */ rhat21(`gama21') rhat22(`gama22') rhat3(`gama3')
       local sse1 = e(sse)
       mat `VF3_bs'[`i',1] = (`sse0'/`sse1'-1)*`NT'
   }   

       svmat `VF3_bs',names(`F3_bs')
       sum `F3_bs'1  ,d
       local F3_bs10 = r(p90)         /* 10%,5%,1%临界值 */
       local F3_bs5  = r(p95)
       local F3_bs1  = r(p99)
       count if `F3_true' < `F3_bs'1 & `F3_bs'1 != .
       local P3_bs = r(N)/`bs3'    
}           
* -----------Model 3--BS--over----------
outreg2 using out.doc, tstat bdec(3) tdec(2)  append
 
* -----确定BS得到的F值的显著水平-----
forvalues i = 1(1)3{
    local pp = `P`i'_bs'
    if `pp'>0.1{
       local star`i' = "   "
    }
    else if `pp'<=0.1&`pp'>0.05{
       local star`i' = "*  "
    }
    else if `pp'<=0.05&`pp'>0.01{
       local star`i' = "** "
    }
    else{
       local star`i' = "***"
    }
}


* -------------门槛估计值和置信区间---------------
di _n _n 
tab_title, t(门槛估计值和置信区间)
di

dis in g in smcl "{hline 79}"
dis in g _col(27) "门槛估计值" _col(56) "95% 置信区间"
dis in g in smcl _col(3) "{hline 77}"

dis in g _col(3) "单一门槛模型(g1)" in y _col(29) %7.3f `gama1' in g _col(52) "[ " /*
    */in y _col(53) %7.3f `minc1' in g _col(62) " , " in y _col(65) %7.3f  `maxc1'  in g _col(72) " ]"
dis in g in smcl _col(3) "{hline 77}"

dis in g _col(3) "双重门槛模型："
dis in g _col(7) "Ito1(g1)" in y _col(29) %7.3f `gama22' in g _col(52) "[ " /*
    */in y _col(53) %7.3f `minc22' in g _col(62) " , " in y _col(65) %7.3f  `maxc22'  in g _col(72) " ]"
dis in g _col(7) "Ito2(g2)" in y _col(29) %7.3f `gama21' in g _col(52) "[ " /*
    */in y _col(53) %7.3f `minc21' in g _col(62) " , " in y _col(65) %7.3f  `maxc21'  in g _col(72) " ]"
dis in g in smcl _col(3) "{hline 77}"

dis in g _col(3) "三重门槛模型(g3)：" in y _col(29) %7.3f `gama3' in g _col(52) "[ " /*
    */in y _col(53) %7.3f `minc3' in g _col(62) " , " in y _col(65) %7.3f  `maxc3'  in g _col(72) " ]"
dis in g in smcl "{hline 79}"
dis in g "Note: g# denotes gamma#, the estimated threshold values, #=1,2,3"


* ------------门槛效果检验---------------
di _n _n
tab_title,t(门槛效果自抽样检验)
di

dis in g in smcl "{hline 79}"
dis in g _col(61) "临界值"
dis in g in smcl _col(14) "{hline 66}"
dis in g _col(5) "模型" _col(18) "F值" _col(30) "P值" _col(39) "BS次数" /*
        */_col(54) "1%" _col(63) "5%" _col(72) "10%"
dis in g in smcl "{hline 79}"

dis in g _col(3) "单一门槛" in y _col(14) %8.3f `F1_true' "`star1'" _col(28) %6.3f `P1_bs' /*
  */_col(40) %4.0f `bs1' _col(50) %8.3f `F1_bs1' _col(59) %8.3f `F1_bs5'  _col(68) %8.3f `F1_bs10'

dis in g _col(3) "双重门槛" in y _col(14) %8.3f `F2_true' "`star2'" _col(28) %6.3f `P2_bs' /*
  */_col(40) %4.0f `bs2' _col(50) %8.3f `F2_bs1' _col(59) %8.3f `F2_bs5'  _col(68) %8.3f `F2_bs10'

dis in g _col(3) "三重门槛" in y _col(14) %8.3f `F3_true' "`star3'" _col(28) %6.3f `P3_bs' /*
  */_col(40) %4.0f `bs3' _col(50) %8.3f `F3_bs1' _col(59) %8.3f `F3_bs5'  _col(68) %8.3f `F3_bs10'

dis in g in smcl "{hline 79}"



* ------------估计结果--------------
di _n 
tab_title,t(门槛模型系数估计结果)
local m "mSingle mDouble mTriple"
cap which esttab
if _rc==0{
  esttab `m', mtitle(Single Double Triple) star(* 0.1 ** 0.05 *** 0.01) ///
              s(r2_w r2_b r2_o N) nogap label
}
else{
  est table `m', b(%7.3f) se(%7.2f) stats(r2_w r2_b r2_o N)
  dis in y "Note: You can install -esttab- command to get more beautiful output"
  dis in y `"     To install, click {stata "net install estout.pkg, replace":net install estout.pkg, replace} to install"'
}


* ------------绘图---------------
di _n 
dis  " 你可以输入或点击如下命令查看各个门槛的置信区间图："
dis  "   Single Threshold: "  _col(35) "{stata xttr_graph}"   
dis  "   Double Threshold(1st round): " _col(35) "{stata xttr_graph, m(22)}"
dis  "   Double Threshold(2ed round): " _col(35) "{stata xttr_graph, m(21)}" 
dis  "   Triple Threshold: "  _col(35) "{stata xttr_graph, m(3)}"
dis  " For details, see: {help xttr_graph}"

*-----------return values---------------
* est related
eret scalar rhat1 = `gama1'
eret scalar minc1 = `minc1'
eret scalar maxc1 = `maxc1'

eret scalar rhat22 = `gama22'
eret scalar minc22 = `minc22'
eret scalar maxc22 = `maxc22'
eret scalar rhat21 = `gama21'
eret scalar minc21 = `minc21'
eret scalar maxc21 = `maxc21'

eret scalar rhat3 = `gama3'
eret scalar minc3 = `minc3'
eret scalar maxc3 = `maxc3'

* bs related
eret scalar F1_true = `F1_true'
eret scalar F1_bs10 = `F1_bs10'
eret scalar F1_bs5  = `F1_bs5'
eret scalar F1_bs1  = `F1_bs1'
eret scalar P1_bs   = `P1_bs'

eret scalar F2_true = `F2_true'
eret scalar F2_bs10 = `F2_bs10'
eret scalar F2_bs5  = `F2_bs5'
eret scalar F2_bs1  = `F2_bs1'
eret scalar P2_bs   = `P2_bs'

eret scalar F3_true = `F3_true'
eret scalar F3_bs10 = `F3_bs10'
eret scalar F3_bs5  = `F3_bs5'
eret scalar F3_bs1  = `F3_bs1'
eret scalar P3_bs   = `P3_bs'

* LR test related
eret mat LR1     = `LR1'
eret mat gama1V  = `gama1V'

eret mat LR21    = `LR21'
eret mat gama21V = `gama21V'
eret mat LR22    = `LR22'
eret mat gama22V = `gama22V'

eret mat LR3     = `LR3'
eret mat gama3V  = `gama3V'

* F test related
eret mat F1_bs = `VF1_bs'
eret mat F2_bs = `VF2_bs'
eret mat F3_bs = `VF3_bs'

*basic information
eret scalar cc   = `cc'
eret scalar NT   = `NT'
eret mat    pc   = `pc'
eret local  cmd xtthres2
eret local  thres "`thres'"
eret local  depvar "`depvar'"

* dis over time
timer off  99
qui timer list 99
dis _n in g " Over Time:" in y "`c(current_date)' `c(current_time)'" _c
dis  in g "   Time used: " in y "`r(t99)'s"

restore 

end
*=================================== Main over ===============================================


*=======================sub programs=========================

*-----------cal gama_min------------
program define Min_r, rclass
version 8.0
args  gama sse
qui sum `sse'     
local S1_rhat = r(min)                    /*S1(r^),pp.7*/
qui sum `gama'  if `sse' == r(min)
local rhat = r(mean)
return scalar rhat = `rhat'
return scalar S1   = `S1_rhat'
end


/*
*-保留小数点后 # 位
cap program drop dec123
program define dec123, rclass
version 11
  args number left  // 9.4456 2, 2表示保留小数点后两位
  loca deca: dis %10.`left'f `number'
  return scalar deca = `deca'
end 
*/

program define tab_title
version 8.0

     syntax , Title(string) [ Simple]

local strl   = length(`"`title'"')
local  lenth = `strl' + 18
if "`simple'" != ""{
    dis in w in smcl "{hline 3}" as input "`title'" in w in smcl "{hline 3}"
}
else{
#delimit ;
dis    as text "{c TLC}" "{hline `lenth'}" "{c TRC}" _n  /*line color*/
       "{c |}"                       
       "{col 8}---" 
       in y "`title'"                                /*title color*/
       as text "---{col `=6+`strl'+6'}"                  /*line color*/
       "{col `=`lenth'+2'}{c |}" _n
       "{c BLC}" "{hline `lenth'}" "{c BRC}" ;
#delimit cr
}
end



program define Get_rhat,eclass
version 8.0
args  rhat1 rhat2 qn pc thres dthres lim_obs model NT cc control_vars
   tempname se se1 se2 v
   qui{
          mat `se'=J(`qn',2,.) 
          tempvar d1 d2 d3 d4 cv1 cv2 cv3 cv4
          gen `d1' = 0
          gen `d2' = 0
          gen `d3' = 0
          gen `d4' = 0 
          gen `cv1'= 0 
          gen `cv2'= 0
          gen `cv3'= 0
          gen `cv4'= 0                     
      forvalues i=1(1)`qn'{                /*loop1*/
          local cutregion = 0

          local r = `pc'[`i',1]
          if `model'==1{                   /*single thres model*/
             replace `d1' = `thres'<`r'
             replace `d2' = 1 - `d1'
             local dlist `d1' `d2'
          }
          else if `model' ==2{
             local maxr = max(`r',`rhat1')
             local minr = min(`r',`rhat1')
             replace `d1' = `thres'<`minr'
             replace `d3' = `thres'>`maxr'
             replace `d2' = 1-`d1'-`d3'
             local dlist `d1' `d2' `d3'
          }
          else if `model' ==3{
             local maxr = max(`r',`rhat1',`rhat2')
             local minr = min(`r',`rhat1',`rhat2')
            *local maxr = int(`maxr'*10^4)/10^4            /*new added*/
            *local minr = int(`minr'*10^4)/10^4            /*new added*/
			 local maxr = round(`maxr',0.00001)  //四舍五入，否则影响排序; 20140512
			 local minr = round(`minr',0.00001)  //四舍五入，否则影响排序; 20140512
             foreach rrr of numlist `r' `rhat1' `rhat2'{
                *local rrr = int(`rrr'*10^4)/10^4            /*new added*/
				 local rrr = round(`rrr',0.00001)    //20140512
                 if `rrr'<`maxr'&`rrr'>=`minr'{       /*若 3 2 3,此处可能无法正常赋值，需要考虑一下。*/
                     local midr = `rrr'
                     continue,break
                 }
             }
             
             replace `d1' = `thres'<`minr'
             replace `d2' = `thres'>=`minr'&`thres'<`midr'
             replace `d4' = `thres'>`maxr'
			 replace `d3' = 1-`d1'-`d2'-`d4'
             local dlist `d1' `d2' `d3' `d4'
          }          
   
            
        foreach var of varlist `dlist'{
            count if `var' == 1
            if r(N)<`lim_obs'{
               local cutregion = 1          /*标示样本数小于lim_obs(default 20)的区间*/
               continue,break
            }
        }
        if `cutregion' == 1{
            continue                      /*jump to loop1*/
        }
        
        replace `cv1' = `d1'*`dthres'
        replace `cv2' = `d2'*`dthres'
        replace `cv3' = `d3'*`dthres'
        replace `cv4' = `d4'*`dthres'
        xtthres_fe `control_vars' `cv1' `cv2' `cv3' `cv4' `if'
 //        xtreg      `control_vars' `cv1' `cv2' `cv3' `cv4' `if' ,fe
        mat `se'[`i',1]=`r'
        mat `se'[`i',2]=e(rss)
      }
      svmat `se',names(`v')
      Min_r `v'1 `v'2
      mat `se1' = `se'[....,1]
      mat `se2' = `se'[....,2]
   }
   local rhat = r(rhat)
   local Smin = r(S1)
   
 /*  
   dis "se2 = " 
   dis in y "mat list se"
   mat list `se'
   dis "r(S1) = "  r(S1)
   dis "c1" `c1'
   dis "NT" `NT'
 */    
   
   
* Calculate LR values and confidence region
   tempname LR c1 g lr
   mat `c1' = J(`qn',1,1)
   cap mat `LR' = (`se2'/r(S1)-`c1')*`NT'
   if _rc{
     dis as error "sample size too small."
	 exit 198
   }

   svmat `se1',names(`g')
   svmat `LR' ,names(`lr')
   qui sum `g'1 if `lr'1<`cc'
   
   eret scalar minc = r(min)
   eret scalar maxc = r(max)
   eret mat      LR = `LR'   
 
   eret scalar rhat = `rhat'
   eret scalar Smin = `Smin'
   eret mat    SSE   = `se'
   eret mat    gama  = `se1'   /*vecter gama*/
   eret mat    sse   = `se2'   /*vecter sse*/

end


program define xtthres_fe, eclass
version 8.0
    version 6, missing
    local options "Level(integer $S_level)"
        syntax varlist [if] [, `options'  I(varname) Nocons]
        tokenize `varlist'

        xt_iis `i'
        local ivar "`s(ivar)'"

        tempvar x touse 
        tempname  sse 
        local dv `1'
        
        quietly {
            mark `touse' `if'
            markout `touse' `varlist' `ivar'
            sort `ivar' `touse'
            preserve
            keep if `touse'
            keep `varlist' `ivar' `userwgt'

            summ `1'         

                    /* del mean of depvar      */
            by `ivar': gen double `x' = sum(`1')/_n
            summ `1'
            by `ivar': replace `x' = (`1' - `x'[_N]) + r(mean)
            drop `1'
            rename `x' `1'
            mac shift

                    /* del mean of indepvar      */
            while ("`1'"!="") {
                by `ivar': gen double `x' = sum(`1')/_n
                summ `1'
                by `ivar': replace `x' = /*
                    */ (`1' - `x'[_N]) + r(mean)
                drop `1'
                rename `x' `1'
                count if `1'!=`1'[1]
                if r(N)==0 {
                    replace `1' = 0
                }
                mac shift
            }

            //est clear
            if "`nocons'"!=""{
               regress `varlist',nocons
            }
            else {
               regress `varlist'
            }
            scalar `sse' = e(rss)
            est scalar rss = `sse'                  
            restore
        }
end


program define Xttr_F,eclass

version 8.0
* 返回三种门槛模型的sse,e_hat,y_hat

syntax varlist [if] [, rhat1(real 0) rhat22(real 0) rhat21(real 0) rhat3(real 0) /*
               */ Thres(varname) Dthres(varname) /*
               */ Model(int 1) OUTput(int 1) Yhatout(int 1) ]
  
    tempvar d1 d2 d3 d4
    tempname ehat yhat ehatV yhatV
if `model' != 0{
          gen `d1' = 0
          gen `d2' = 0
          gen `d3' = 0
          gen `d4' = 0
          
    local r21 = min(`rhat22',`rhat21')
    local r22 = max(`rhat22',`rhat21')

    local r31 = min(`rhat22',`rhat21',`rhat3')
    local r33 = max(`rhat22',`rhat21',`rhat3')
    foreach rrr of numlist `rhat22' `rhat21' `rhat3'{
        if `rrr'<=`r33'&`rrr'>=`r31'{                  /*test*/
           local r32 = `rrr'
           continue,break
        }
    }
       qui{
          if `model'==1{                   /*single thres model*/
             replace `d1' = `thres'<`rhat1'
             replace `d2' = 1 - `d1'
          }
          else if `model' ==2{
             replace `d1' = `thres'<`r21'
             replace `d3' = `thres'>=`r22'
             replace `d2' = 1-`d1'-`d3'
          }
          else if `model' ==3{
             replace `d1' = `thres'<`r31'
			 replace `d2' = `thres'>=`r31'&`thres'<`r32'
			 replace `d3' = `thres'>=`r32'&`thres'<`r33'
             replace `d4' = 1-`d1'-`d2'-`d3'
          }                 

        gen `dthres'_1 = `d1'*`dthres'
		*label var `dthres'_1 `"`dthres'*I(`thres'>`r(deca)')"'  //add 2012-04-12
        gen `dthres'_2 = `d2'*`dthres'
		*label var `dthres'_1 "`thres'<`r31'"  //add 2012-04-12
        gen `dthres'_3 = `d3'*`dthres'
        gen `dthres'_4 = `d4'*`dthres'        
          if `model' ==1{
             local cvlist `dthres'_1 `dthres'_2  
			* label var `dthres'_1 `"`dthres'*I(`thres'<g1)"'
			* label var `dthres'_2 `"`dthres'*I(`thres'>=g1)"'
          }
          else if `model' ==2{
             local cvlist `dthres'_1 `dthres'_2 `dthres'_3
			 * label var `dthres'_1 `"`dthres'*I(`thres'<g1)"'
			 * label var `dthres'_2 `"`dthres'*I(g1<=`thres'<g2)"'
			 * label var `dthres'_3 `"`dthres'*I(`thres'>=g2)"'
          }
          else if `model' ==3{
             local cvlist `dthres'_1 `dthres'_2 `dthres'_3 `dthres'_4
			 * label var `dthres'_1 `"`dthres'*I(`thres'<g1)"'
			 * label var `dthres'_2 `"`dthres'*I(g1<=`thres'<g2)"'
			 * label var `dthres'_3 `"`dthres'*I(g2<=`thres'<g3)"'
			 * label var `dthres'_4 `"`dthres'*I(`thres'>=g3)"'			 
          }

        qui xtreg `varlist' `cvlist' `if',fe        
        if `output'==1{
            n xtreg
        }
        predict `ehat',e
        predict `yhat'
        }
        drop `d1'-`d4' `dthres'_1-`dthres'_4 
}       
else {    /*no threshold model*/ 
        qui xtreg `varlist' `dthres' `if' ,fe
        qui predict `ehat',e
        qui predict `yhat'
     }
        eret scalar sse = e(rss)
        
        if `yhatout' == 1{
            gen yhat = `yhat'
            gen ehat = `ehat'
        }
		
		
end
*================================================



