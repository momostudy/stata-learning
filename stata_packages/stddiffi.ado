program define stddiffi, rclass
	version 13.0
	* Ahmed Bayoumi
	* version 2.2
	* 12Jan2022
	syntax anything, [ /// mean1 sd1 mean 2 sd2 FOR CONTINUOUS OR #11 #12 [...] \ #21 #22 [...] FOR CATEGORICAL
		COHensd  ///  report cohensd as calculated by esize
		HEDgesg ///  report hedgesg as calculated by esize 
		CONTinuous /// specify continuous variable
		CATegorical /// specify categorical variable
		abs /// calculate absolute value
		]
	tempname rw tab

	if(strpos("`anything'","\")==0){
		local continuous = "continuous"
	}
	
	if("`continuous'"=="continuous"){
		if("`cohensd'"=="cohensd" | "`hedgesg'"=="hedgesg"){
			if( `: word count `anything''!=6){
				di as error "Incorrect number of inputs for continuous variables"
				error 198
			}
			else{
				if ("`cohensd'"=="cohensd" & "`hedgesg'"=="hedgesg") local hedgesg=""
				qui esizei `anything', `cohensd' `hedgesg'
				if ("`cohensd'"=="cohensd") local sd=r(d)
				else local sd=r(g)
			}
		}
		else{
			if( `: word count `anything''!=4){
				di as error "Incorrect number of inputs for continuous variables"
				error 198
			}
			else{
				tokenize `anything'
				local sd= (`1'-`3') /  sqrt((`2'^2+`4'^2 )/2)
			}
		}
	}
	else{
		tokenize "`anything'", parse("\")
		while "`1'"!=""{
			if "`1'"!="\"{
				foreach w in `1'{
					mat `rw'=nullmat(`rw'), `w'
				}
			}
			else{
				mat `tab'=nullmat(`tab') \ `rw'
				capture mat drop `rw'
			}
			macro shift
		}
		
		mat `tab'=nullmat(`tab') \ `rw'
		if(colsof(`tab')!=2){
			di as error "Table must have 2 columns"
			error 198
		}
		tabi `anything', col
		mata: _matasd(st_matrix("`tab'"))
		local sd=r(std)
		return matrix table=`tab'
	
	}
	if("`abs'"=="abs") local sd=abs(`sd')
	di as result _n "Standardized difference: " %06.5f `sd' 
	return scalar std_diff =`sd'
end program


mata:
        void _matasd(real matrix f){
                        p=f:/colsum(f)
                        out=f[,1],p[,1]*100,f[,2],p[,2]*100,J(rows(p),1,.z)
                        T=p[|2,1 \ .,1|]
                        C=p[|2,2 \ .,2|]
                        S=-(T*T' + C*C' )/2
                        s=rowsum(p:*(1:-p))/2
                        for(i=1;i<rows(p);i++){
                                S[i,i]=s[i+1]
                        }
                        std=sqrt((T-C)'*invsym(S)*(T-C))
                        out[1,5]=std
                        st_numscalar("r(std)",std)
                        st_matrix("r(output)",out)
        }
end
