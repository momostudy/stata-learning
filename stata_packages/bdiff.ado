*! Version 1.04  24Nov2020
*  Author: Yujun Lian, Sun Yat-sen University
*          Email: arlionn@163.com
*          Blog: https://www.lianxh.cn
*  Version 1.01  14Jun2016
*  Version 1.02  20Apr2019

*-References:
*  Efron, B., Tibshirani, R., 1993. 
*    An Introduction to the Bootstrap, Chapmann & Hall.

*-update list
* 2019/4/20 fix the bug of -seed()- option, thanks Jingxin Hu from Syracuse University


cap program drop bdiff
program define bdiff, rclass
version 13
*anything(name=any_thing id="exp_list" equalok)
syntax , ///
	  Group(varname)        ///
	  Model(string)         ///
	  [                     ///
	    Reps(int 100)       ///
		Seed(int -13579999)     ///
		BSample             ///
		SURtest             ///
		First               ///
		Gap                 ///
		NOdots              ///
		Dec(int -99)  ///
		BDec(int 3)   ///
		PDec(int 3)   ///
		DETail        ///
	  ]
    

	
  *-check the group() option
    *local group "rep78"
    qui tab `group'
	if `r(r)'!=2{
	  di in red "variable `group' in group() option must be a dummy vairable (0/1)"
	  exit 198
	}
	
  *-check the model() option	
	local m2 = subinword("`model'", "if", "I-S-F", .)
	local m2 = subinword("`m2'", "in", "I-S-N", .)
	if strpos("`m2'","I-S-F")>0 | strpos("`m2'","I-S-N")>0{
	   dis as error "[if] or [in] can not specified in model() option"
	   exit 198	   
	}
	
  *-check the -surtest- and -bsample- options	 
	if ("`surtest'"!="")&("`bsample'"!=""){
	   di in red "may not specify both bsample and surtest options"
	   exit 198  
	}
	
	
  *-display begin time
    if "`surtest'"==""{
	  dis _n in g "Begin Time: " in y "`c(current_date)' `c(current_time)'"
	  qui timer clear 99
	  qui timer on    99
	}
	 
  *-seed
    if `seed'==-13579999{
	   local tempseed = int(uniform()*10^8)
	   set seed  `tempseed'
	}
	else{
	   set seed `seed'
	}	
	
	
preserve   //=========================================preserve================
  
    qui keep if `group'!=.
	
	marksample touse
	qui keep if `touse'
	*if "`bsample'"!=""{ 
	  tempfile _origdata
	  qui save "`_origdata'.dta", replace
	*}
	
	
    local m2 = subinstr("`model'", ",", "++", .)
	tokenize `m2', parse("++")
	local cmdvlist "`1'"
	
	if strpos("`m2'","++")!=0{
	  local opts ", `4'"  // options 
	}
	else{
	  local opts ""
	}
	
	gettoken cmd vlist: cmdvlist  // before ,
	
	if substr("`cmd'",1,2)=="xt"{   //panel data
	   local cmdtype "xt"  // panel data
	   qui xtset
       local id   "`r(panelvar)'"
       local t    "`r(timevar)'" 
	}
	else{
	   local cmdtype "cs"  // cross-sectional
	}

	gettoken depvar indepvar: vlist
	*dis "`depvar'"     //dependent variable
	*dis "`indepvar'"   //independent variables	


	
 *-Record the observed difference of coefficients, 记录真实系数差异
     *tempname g1 g2
       qui `cmdvlist' if `group'==0 `opts'
	   est store GrouP1
		 *-other parameters
         mat b1 = e(b)  
		 global k = colsof(b1)
		 local k1 = colsof(b1)
		 global n1 = e(N)  //第一组公司的观察值个数
		 if ("`cmdtype'"=="xt"){ 
		    global Ng1 = e(N_g)  //公司个数
		 }
       qui `cmdvlist' if `group'==1 `opts'  
	     est store GrouP2
         mat b2 = e(b)
		 local k2 = colsof(b2)
		 
		 if `k1'!=`k2'{
		    dis in red "Note: The numbers of effective independent variables in Group1 (`group'=0) and group2 (`group'=1) are not equal"
			dis in red "This may occur because you use the factor variable to indicate the dummy varaibles"
		    exit
		 }
		 else{
           mat D0 = b1 - b2
	   	   global diffcha = D0[1,1]  //temp
		 }

    if "`surtest'" != ""{
  
       NotSupported `cmd'
	   
       qui suest GrouP1 GrouP2
	   *-equation name
		 local eqfullname: coleq e(b)
	     tokenize  "`eqfullname'"
		 local eqname = subinstr("`1'","GrouP1_","",1)
	   *-SUR test
	   mat P = J($k,3,.)
	   local j=1
	   foreach v in `indepvar' _cons{
	     local diff0_`j' = D0[1,`j']
	     qui test [GrouP1_`eqname']`v' = [GrouP2_`eqname']`v'
		 local chi2 = r(chi2)
		 local p = r(p)
		 mat P[`j',1] = (`diff0_`j'' , `chi2', `p')
		 local j = `j'+1
	   } 
    } 
  

    else{   // -----------begin boostrap or permuation test-----------

	 	 if "`nodots'" != ""{
		    local quidots "qui"
		 }
		 
	   tempvar random yesG1 idtag id123
	   qui gen double `random' = .
	   qui gen byte   `yesG1'  = .
	   
	   if `reps'>800{
	     set matsize `reps'
	   }
	   
       mat D = J(`reps', $k, .)   // 存储结果的矩阵
       forvalues j = 1/`reps'{
	    *-Bootstrap the sample
          if "`bsample'"!=""{ 		
		    qui use "`_origdata'.dta", clear
		    if ("`cmdtype'"=="cs"){      // cross-sectional data
			   bsample
			}
			else if ("`cmdtype'"=="xt"){ // panel data
			   tempvar idnew
			   bsample, cluster(`id') idcluster(`idnew')
			   qui xtset `idnew' `t'
			}
		  }
		*-permute test
		  if ("`cmdtype'"=="cs"){  
		    tempvar random 
		    qui gen `random' = runiform()
            sort `random'           // sort the sample randomly
            qui `cmdvlist' in 1/$n1 `opts'       // random group 1
		    matrix b1 = e(b)
		    *gen `yesG1' = e(sample)
            qui `cmdvlist' if ~e(sample) `opts'    // random group 2
            matrix b2 = e(b)
		  }	
		  else if ("`cmdtype'"=="xt"){
		    tempvar randomN random
		    qui gen `random' = runiform()
			qui bysort `idnew': egen `randomN' = min(`random')
            qui sort `randomN'           // sort the sample randomly
			qui egen `idtag' = tag(`idnew')
            qui gen  `id123' = sum(`idtag')
            qui `cmdvlist' if `id123'<=$Ng1 `opts'  // random group 1
		    matrix b1 = e(b)
            qui `cmdvlist' if ~e(sample) `opts'     // random group 2
            matrix b2 = e(b)			
		  }
          matrix diff = b1 - b2
          mat D[`j',1] = diff
		  `quidots'  dis "." _c  //屏幕上打点
		  
       }  
     *--------------------------------------------------------------------
       *qui dropvars diff*
	   tempvar diff
       svmat D, names(`diff')  
       mat P = J($k,3,.)  // 记录系数真实差异和经验p值的矩阵
       forvalues j = 1/$k{
          local diff0_`j' = D0[1,`j']
          qui count if (`diff'`j'>=`diff0_`j'')&`diff'`j'!= .
		  local num = r(N)
          local p = `num'/`reps'
		  if `p'>0.5{
	        local p = 1-`p' 
	      }
          mat P[`j',1] = (`diff0_`j'' , `num', `p')
       }  
  }	        // -----------over boostrap or permuation test-----------
  
       local col = colsof(P)
	   local row = rowsof(P)
  
	   if "`gap'"!=""{    
		  local row2 = `row'*2
		  mat P2 = J(`row2',`col',.)
		  local j=1
		  local i=1
		  while `i'<=`row'{
		     mat P2[`j',1] = P[`i',1..3]
             local j=`j'+2
			 local i=`i'+1
		  }	 
		  *-column names
          local s:  colnames b1
	      local sgap ""
	      foreach v of local s{
	        local sgap `"`sgap' `v' ."'
	      }
          mat rownames P2 = `sgap' 
	   }
	   else{
	      mat P2 = P
          local s:  colnames b1
          mat rownames P2 = `s'           
	   }
	   
	   

	   dis _n
	   *mat list P2 , format(%8.3f) noheader
	   if "`surtest'"!=""{
	   	 local mattile  "-SUR- Test of Group (`group' 0 v.s 1) coeficients difference"
		 local colnames "b0-b1 Chi2 p-value"
		 local mdec = 2
	   }
	   else if "`bsample'"!=""{
	     local mattile "-Bootstrap (`reps' times)- Test of Group (`group' 0 v.s 1) coeficients difference"
		 local colnames "b0-b1 Freq p-value"
		 local mdec = 0
	   }
	   else{
	     local mattile "-Permutaion (`reps' times)- Test of Group (`group' 0 v.s 1) coeficients difference"
		 local colnames "b0-b1 Freq p-value"
		 local mdec = 0
	   }
	   
	   mat colnames P2 = `colnames'
	   
	   if "`gap'"!=""{
	      local a7 ""
		  forvalues i=1/`=`row2'-1'{
		    local a7 "`a7'&"
		  }
	      local a7 "`a7'-"
	   }
	   else{
	      local a7 ""
		  forvalues i=1/`=`row'-1'{
		    local a7 "`a7'&"
		  }
		  local a7 "`a7'-"
	   }
 
	   if `dec' != -99{
	      local bdec = `dec'
		  local pdec = `dec'
	   }

	   matlist P2, rowtitle(Variables) title(`mattile')   ///
          cspec(& %12s | %10.`bdec'f & %6.`mdec'f & %10.`pdec'f &) rspec(&-`a7')

	   
	   *-若用户设定了 onevariable() 选项，则还需要在这里确定改变量在模型中的位置
	   if "`first'"!=""{
	      local var1 : word 1 of `indepvar'
          local bdiff = P2[1,1]
	      local p = P2[1,3]
		  dis "Ho: b0(`var1') = b1(`var1')"
		  dis "  Observed difference = " %6.`pdec'f `bdiff'    // _c
		  dis "    Empirical p-value = " %6.`pdec'f `p' 
	   }
	   
	   if "`detail'"!=""{
	      cap which esttab
		  if _rc~=0 {
		    qui use "`_origdata'.dta", clear
		    qui  `cmdvlist' if `group'==0 `opts'
	        est store `group'_0
            qui `cmdvlist' if `group'==1 `opts'  
	        est store `group'_1
		    est tab `group'_0 `group'_1, b(%7.`bdec'f) se(%7.`bdec'f) stats(N)
		  }
		  else{
		     local mm "GrouP1 GrouP2"
			 local mt "`group'_0 `group'_1"
		     esttab `mm', nogap mtitle(`mt') star(* 0.1 ** 0.05 *** 0.01) s(r2 N)	
		  }
	   }	   
	   
     *-return values   
	   local eret "ret"
	   `eret' clear  
	   
	   tempname pvalues
       mat `pvalues' = P2[1..., 3]
	   
	   `eret' mat observediff = D0
	   `eret' mat           P = P2
	   `eret' mat pvalues     = `pvalues'
	   
	   if "`first'"!=""{
	   	  `eret' scalar bdiff = `bdiff'
		  `eret' scalar p = `p'
       }
	   *-return macros
	     `eret' local model "`model'"
		 
restore   //=========================================restore================
	
	
* dis over time
    if "`surtest'"==""{
       timer off  99
	   qui timer list 99
	   dis _n in g " Over Time:" in y "`c(current_date)' `c(current_time)'" _c
	   dis  in g "   Time used: " in y "`r(t99)'s"	
    }

end	   


*----------sub-programs----------

// NotSupported cmd cmd2  
*  see suest.ado Line.662
program NotSupported
    
	local cmdlist cox xtgee ivreg ivregress areg xtreg sem xtmixed mixed
	local cmdlist `cmdlist' xtmepoisson mepoisson xtmelogit melogit meglm
	local cmdlist `cmdlist' gsem gmm
	local cmdYes : list 0 & cmdlist
	if `"`cmdYes'"' != "" {
		di as err "`:word 1 of `cmdYes'' is not supported by -groupdiff- with option -surtest-"
		exit 322
	}
	if "`e(cmd)'" == "regress" & "`e(model)'" == "iv" {
		di as err ///
		"regression models with instruments are not supported by -groupdiff- with option -surtest-"
		exit 322
	}
	if "`e(cmd)'" == "anova" {
		if 0`e(version)' < 2 {
			di as err ///
			  "anova run with version < 11 not supported by -groupdiff- with option -surtest-"
			exit 322
		}
	}
end



*-可以参考 logout.ado 设定更为一般化的选项和命令格式
*-增加一个 Cluster(varname) 选项
*-增加一个 set(varlist) 选项，局部显示结果
*-如果命令里包含 xt 开头的字样，则自动执行 cluster 
*-矩阵的定义都用暂时性元素
*-默认为permute test, 若添加 bsample 选项，则执行 bsample 动作
*
*   2016-06-13  help matlist  the format of matrix
