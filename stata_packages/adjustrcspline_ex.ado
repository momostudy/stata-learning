*! version 1.1.3 MLB 13Nov2013
program define adjustrcspline_ex
	Msg preserve
	preserve

	if `1' == 1 {
		Xeq sysuse nlsw88, clear
	
		Xeq recode grade 0/5=5
		
		Xeq mkspline2 grades = grade, cubic nknots(3)
		Xeq logit never_married grades*
		
		Xeq adjustrcspline
	}
	else if `1' == 2 {
		Xeq sysuse uslifeexp, clear
	
		Xeq mkspline2 ys = year, cubic 
		Xeq reg le ys* if year != 1918
		
		Xeq adjustrcspline if year != 1918, ///
    		        addplot(scatter le year if year != 1918, msymbol(Oh) || ///
    		                scatter le year if year == 1918, msymbol(X) )   ///
    		        ytitle("life expectancy")                               ///
		        note("1918 was excluded from the computations because of the Spanish flu")
	}
	else if `1' == 3 {
		Xeq sysuse nlsw88, clear
		
		Xeq recode grade 0/5=5
			
		Xeq mkspline2 grades = grade, cubic nknots(3)
		Xeq logit never_married grades*
			
		Xeq adjustrcspline, custominvlink("invlogit(xb())")
	}
	else if `1' == 4 {
		Xeq sysuse nlsw88, clear

		Xeq recode grade 0/5=5
	
		Xeq mkspline2 grades = grade, cubic nknots(3)
		Xeq logit never_married grades*

		Xeq glm never_married grades* south, link(cloglog) family(binomial)
		Xeq adjustrcspline, at(south=0)	
	}
	else if `1' == 5 {
		Xeq sysuse cancer, clear
		Xeq gen long id = _n
		Xeq stset studytime, failure(died) id(id)
		
		Xeq stsplit t, every(1)
	
		Xeq mkspline2 ts=t, cubic nknots(3)
		Xeq xi: streg i.drug age ts*, dist(exp)
	
		Xeq adjustrcspline , at(_Idrug_2=0 _Idrug_3=0) ///
		                     link("log")               ///
		                     noci                      ///
		                     ytitle(hazard)	
	}

	Msg restore 
	restore
end

program Msg
        di as txt
        di as txt "-> " as res `"`0'"'
end

program Xeq, rclass
        di as txt
        di as txt `"-> "' as res `"`0'"'
        `0'
end
