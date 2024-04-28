*! Author: Lian Yu-jun
*! E-mail: arlionn@163.com
*! Homepage: http://goo.gl/XZlgN 

*! Update: 2014-01-07

cap program drop xttr_graph
program define xttr_graph
version 8.0

   syntax , [Model(int 1) Thres(varname) /*
                      */ Level(int 95) White Save(string)  /*
                      */ TItle(string) YTitle(string) XTitle(string)]
 
   if "`e(cmd)'" != "xtthres"{
       dis as error " xttr_graph only works after {help xtthres:xtthres}" 
       exit 198
   }    

   if "`thres'" == ""{
      local thres = "`e(thres)'"
   }

   local cc = -2*ln(1-sqrt(`level'/100))
   local tname = "`thres'"

   tempname r lr
   if `model'==1{
      mat `r' = e(gama1V)
      mat `lr'= e(LR1)
	  if `"`title'"'==""{
	    local title "Confidence interval construction in single threshold model, size(*0.85)"
	  }
   }
   else if `model'==22{
      mat `r' = e(gama22V)
      mat `lr'= e(LR22)
	  if `"`title'"'==""{
	    local title `" "Confidence interval construction in double threshold model" "(1st round)",size(*0.85)"'
	  }	  
   }
   else if `model'==21{
      mat `r' = e(gama21V)
      mat `lr'= e(LR21)
	  if `"`title'"'==""{
	    local title `" "Confidence interval construction in double threshold model" "(2rd round)",size(*0.85)"'
	  }	  
   }
   else if `model'==3{
      mat `r' = e(gama3V)
      mat `lr'= e(LR3)
	  if `"`title'"'==""{
	    local title "Confidence interval construction in double threshold model, size(*0.85)"
	  }	  
   }
   else{
      dis as error "option model(" in g "#" in r") is error specified: " ///
                   in g "#" in r " must be one of 1, 22, 21 or 3 " 
      exit
   }
   
   if `"`xtitle'"'==""{
       local xtitle "门槛参数 (`tname')"
       }
   if `"`ytitle'"'==""{
       local ytitle "LR 值"
       }

   if "`white'" != ""{
       set scheme s1mono     /*to draw white-black graphs*/
   }

   tempvar rr lrr
   svmat `r',names(`rr')
   svmat `lr'  ,names(`lrr')
   qui sum `lrr'1
   qui replace `lrr'1 =0  if `lrr'1<0
   format `lrr'1 %4.0f
      
   if r(max)<`cc'{
        local ysmin = int(r(min))
        local ysmax = int(`cc'*1.1)
        local ylmin = 0
        local ylmax = `ysmax'
        local gap    "(2)"     
   }

       #delimit ;
       line `lrr'1 `rr'1 ,
                title(`title')
                xtitle(`xtitle', alignment(baseline))
                ytitle(`ytitle')
                yscale(range(`ysmin' `ysmax'))   
                ylabel(`ylmin'`gap'`ylmax')
                xmtick(##5 , tposition(inside))
                ymtick(##5 , tposition(inside))
                yline(`cc', lpattern(dash))
                sort
                ;
       #delimit cr

   set scheme s2color 
    
   if "`save'" != ""{
      graph save "`save'",replace 
   }
   
   drop `rr'1 `lrr'1
   
   dis in g "== " in y "Hi, you can right click the graph and save it!" in g "=="


end
