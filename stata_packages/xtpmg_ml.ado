capture program drop xtpmg_ml

program define xtpmg_ml
  	version 9
      args todo b lnf
      tempname beta ttl touse
	marksample touse
      mleval `beta' = `b'
      tempname ec
	quie generate double `ec'=$LRy-`beta'
	scalar `ttl'=0
      ml hold
	foreach ivar of global iis{
		quie regress $SRy $SRx `ec' if `touse' & `_dta[iis]'==`ivar', $nocons
		scalar `ttl' = `ttl' + e(ll)
	}
      ml unhold
      scalar `lnf' = `ttl'
end
