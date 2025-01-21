*! version 1.1.1  25jan2021

/*
	utils__quaidsce.mata
	
	Mata routines called by
		nlsur__quaidsce.ado
		quaidsce_estat.ado
		quaidsce_p.ado
*/

mata

mata set matastrict on

void _quaidsce__fullvector(string scalar ins,
			real scalar neqn,
			string scalar quadratics,
			real scalar ndemo,
			string scalar outs,
			string scalar censor)
{

	real vector	in
	real vector	alpha, beta, lambda, rho, delta
	real matrix	gamma, eta
	
	in = st_matrix(ins)
	_quaidsce__getcoefs_wrk(in, neqn, quadratics, censor, ndemo,
		alpha, beta, gamma, lambda, delta, eta, rho)
	
	

	//Censoring, quadratics, and demographics
	if (censor == "" & quadratics == ""  &  ndemo >  0) st_matrix(outs, (alpha, beta, (vech(gamma)'), lambda, delta, (vec(eta')'), rho))
	//Censoring and quadratics
	if (censor == "" & quadratics == ""  &  ndemo == 0) st_matrix(outs, (alpha, beta, (vech(gamma)'), lambda, delta))
	//Censoring and demographics
	if (censor == "" & quadratics != ""  &  ndemo >  0) st_matrix(outs, (alpha, beta, (vech(gamma)'), delta, (vec(eta')'), rho))
	//Censoring
	if (censor == "" & quadratics != ""  &  ndemo == 0) st_matrix(outs, (alpha, beta, (vech(gamma)'), delta))
	//Quadratics and demographics
	if (censor != "" & quadratics == ""  &  ndemo >  0) st_matrix(outs, (alpha, beta, (vech(gamma)'), lambda, (vec(eta')'), rho))
	//Quadratics 
	if (censor != "" & quadratics == ""  &  ndemo == 0) st_matrix(outs, (alpha, beta, (vech(gamma)'), lambda))
	//Demographics
	if (censor != "" & quadratics != ""  &  ndemo >  0) st_matrix(outs, (alpha, beta, (vech(gamma)'), (vec(eta')'), rho))
	
	//No censoring, no quadratics, and no demographics
	
	if (censor != "" & quadratics != ""  &  ndemo == 0) st_matrix(outs, (alpha, beta, (vech(gamma)')))
	//else st_matrix(outs, (alpha, beta, (vech(gamma)')))
		
	
}

void _quaidsce__getcoefs(string scalar ins,
		       real   scalar neqn,
		       string scalar quadratics,
			   string scalar censor,
		       real   scalar ndemo,
		       string scalar alphas,
		       string scalar betas,
		       string scalar gammas,
		       string scalar lambdas,
			   string scalar deltas,
		       string scalar etas,
		       string scalar rhos)
{
	
	external scalar quadratics
	real scalar	np
	real vector	in
	real vector	alpha, beta, lambda, delta, rho 
	real matrix	gamma, eta

	in = st_matrix(ins)

	if (quadratics == "" & censor == "") {
		np = 4*neqn + neqn*(neqn-1)/2  
	}
	else if (censor == "" ) {
		np = 3*neqn + neqn*(neqn-1)/2
	}

	else if (quadratics == "") {
		np = 3*(neqn-1) + neqn*(neqn-1)/2
	}
	else {
		np = 2*(neqn-1) + neqn*(neqn-1)/2
	}
	
	if (ndemo > 0) {
		np = np + ndemo*(neqn-1) + ndemo
	}
	if (cols(in) != np) {
		errprintf("_quaidsce__getcoefs received invalid vector\n")
		exit(9999)
	}
	
	_quaidsce__getcoefs_wrk(in, neqn, quadratics, censor, ndemo, 
				alpha, beta, gamma, lambda, delta, eta, rho)
	
	st_matrix(alphas, alpha)
	st_matrix(betas, beta)
	st_matrix(gammas, gamma)
	
	if (censor == "") {
		st_matrix(deltas, delta)
	}
	
	if (quadratics == "") {
		st_matrix(lambdas, lambda)
	}
	if (ndemo > 0) {
		st_matrix(etas, eta)
		st_matrix(rhos, rho)
	}
	
}

void _quaidsce__getcoefs_wrk(real rowvector 	in,
			   real scalar		neqn,
			   string scalar	quadratics,
			   string scalar	censor,
			   real scalar		ndemo,
			   real rowvector	alpha,
			   real rowvector	beta,
			   real matrix		gamma,
			   real rowvector	lambda,
			   real rowvector 	delta, 
			   real matrix		eta,
			   real rowvector	rho)
{

	real scalar	col, i, j

	col = 1
	alpha = J(1, neqn, 1)		// NB initialize to 1
	for(i=1; i<neqn; ++i) {
		alpha[i] = in[col]
		alpha[neqn] = alpha[neqn] - alpha[i]
		++col
	}
	if (censor == "") {
	alpha[neqn] = in[col]
	++col
	}
	
	beta = J(1, neqn, 0)		// NB initialize to 0
	for(i=1; i<neqn; ++i) {
		beta[i] = in[col]
		beta[neqn] = beta[neqn] - beta[i]
		++col
	}
	if (censor == "") {
	beta[neqn] = in[col]
	++col
	}
			
	gamma = J(neqn, neqn, 0)	// NB initialize to 0
		// j is in outer loop, so that what we are doing corresponds
		// to standard vech() and invvech() functions.
	for(j=1; j<neqn; ++j) {
		for(i=j; i<neqn; ++i) {
			gamma[i, j] = in[col]
			if (j != i) gamma[j, i] = in[col]
			++col
		}
	}
	for(i=1; i<neqn; ++i) {
		for(j=1; j<neqn; ++j) {
			gamma[i, neqn] = gamma[i, neqn] - gamma[i,j]
		}
		gamma[neqn, i] = gamma[i, neqn]
	}
	for(i=1; i<neqn; ++i) {
		gamma[neqn,neqn] = gamma[neqn,neqn]-gamma[i,neqn]
	}
	
	if (quadratics == "") {
		lambda = J(1, neqn, 0)		// NB initialize to zero
		for(i=1; i<neqn; ++i) {
			lambda[i] = in[col]
			lambda[neqn] = lambda[neqn] - lambda[i]
			++col
		}
		if (censor == "") {
		lambda[neqn] = in[col]
		++col
		}
	}
	
	
	delta = J(1, neqn, 1)		// NB initialize to one
	if (censor == "") {
		for(i=1; i<=neqn; ++i) {
			delta[i] = in[col]
			++col
		}
	}
		
	if (ndemo > 0) {
		eta = J(ndemo, neqn, 0)
		for(i=1; i<=ndemo; ++i) {
			for(j=1; j<neqn; ++j) {
				eta[i,j] = in[col]
				eta[i,neqn] = eta[i,neqn] - eta[i,j]
				++col
			}
		}
		rho = J(1, ndemo, 0)
		for(i=1; i<=ndemo; ++i) {
			rho[i] = in[col]
			++col
		}
	}
}


void _quaidsce__expshrs(string scalar shrs,			///
		      string scalar touses,			///
		      string scalar lnexps,			///
		      string scalar lnps,			///
			  string scalar cdfis,			///
			  string scalar pdfis,			///			 
		      real scalar neqn,				///
		      real scalar ndemo,			///
		      real scalar a0,				///
		      string scalar quadratics,			///
			  string scalar censor,			///
		      string scalar ats,			///
		      string scalar demos)
			  
{
	real scalar i, j 
	real vector at, alpha, beta, lambda, rho, delta
	real vector lnexp, lnpindex, bofp, cofp, mbar
	real matrix gamma, eta
	real matrix lnp, shr, demo, cdfi, pdfi
		
	st_view(shr=.,   .,    shrs, touses)
	st_view(lnp=.,   .,    lnps, touses)
	st_view(cdfi=.,   .,    cdfis, touses)
	st_view(pdfi=.,   .,    pdfis, touses)
	st_view(lnexp=., .,  lnexps, touses)
	st_view(demo=.,   .,  demos, touses)
	
	at = st_matrix(ats)
	
	if (censor == "") {
		if (cols(shr) != (neqn)) {
		exit(9998)
		}
	}
	else {
		if (cols(shr) != (neqn-1)) {
		exit(9998)
		}
	}
	
	// Get all the parameters
	_quaidsce__getcoefs_wrk(at, neqn, quadratics, censor, ndemo, 
		alpha, beta, gamma, lambda, delta, eta, rho)

	// First get the price index
	lnpindex = a0 :+ lnp*alpha'
	for(i=1; i<=rows(lnpindex); ++i) {
		lnpindex[i] = lnpindex[i] + 0.5*lnp[i,.]*gamma*lnp[i,.]'
	}
	
	if (ndemo > 0) {
		cofp = J(rows(lnp), 1, 0)
		for(i=1; i<=rows(lnp); ++i) {
			cofp[i] = lnp[i,.]*(eta'*demo[i,.]')
		}
		cofp = exp(cofp)
		mbar = 1 :+ demo*rho'
	}
	else {
		cofp = J(rows(lnp), 1, 1)
		mbar = J(rows(lnp), 1, 1)
	}
	if (quadratics == "") {
		// The b(p) term
		bofp = exp(lnp*beta')
	}
	else {
		bofp = J(rows(lnp), 1, 1)
	}

		if (censor == "") {
			for(i=1; i<=neqn; ++i) {
			shr[.,i] = (alpha[i] :+ lnp*gamma[i,.]')
			if (ndemo > 0) {
				shr[., i] = (shr[., i] + 
					(J(rows(lnp), 1, beta[i]) + demo*eta[.,i]):*
					(lnexp - lnpindex - ln(mbar)))
			}
			else {
				shr[., i] = (shr[., i] + beta[i]*(lnexp - lnpindex))
			}
			if (quadratics == "") {
				shr[., i] = (shr[., i] + lambda[i]:/(bofp:*cofp):*(
					(lnexp - lnpindex - ln(mbar)):^2))
			}
			shr[., i] = shr[., i]:*cdfi[., i] + delta[i]*pdfi[., i]
			
			//for(j=1; j<=rows(shr); ++j) {
			//	if (shr[j, i] > 0) {
			//	shr[j, i] = shr[j, i]*cdfi[j, i] + delta[i]*pdfi[j, i]
			//	}
			//	else {
			//	shr[j, i] = 0
			//	}
			//}
			
			}
		}
		else {
			for(i=1; i<neqn; ++i) {
			shr[.,i] = (alpha[i] :+ lnp*gamma[i,.]')
			if (ndemo > 0) {
				shr[., i] = (shr[., i] + 
					(J(rows(lnp), 1, beta[i]) + demo*eta[.,i]):*
					(lnexp - lnpindex - ln(mbar)))
			}
			else {
				shr[., i] = (shr[., i] + beta[i]*(lnexp - lnpindex))
			}
			if (quadratics == "") {
				shr[., i] = (shr[., i] + lambda[i]:/(bofp:*cofp):*(
					(lnexp - lnpindex - ln(mbar)):^2))
			}
			}
		}
}

void _quaidsce__predshrs(string scalar shrs,			///
		      string scalar touses,			///
		      string scalar lnexps,			///
		      string scalar lnps,			///
			  string scalar cdfs,			///
			  string scalar pdfs,			///			 
		      real scalar neqn,				///
		      real scalar ndemo,			///
		      real scalar a0,				///
		      string scalar quadratics,			///
			  string scalar censor,			///
		      string scalar demos)
{

	real scalar i
	real vector alpha, beta, lambda, rho, delta
	real vector lnexp, lnpindex, bofp, cofp, mbar
	real matrix gamma, eta
	real matrix lnp, shr, demo, cdf, pdf

	st_view(shr=.,   .,    shrs, touses)
	st_view(lnp=.,   .,    lnps, touses)
	st_view(lnexp=., .,  lnexps, touses)
	st_view(demo=.,   .,  demos, touses)
	
	alpha  = st_matrix("e(alpha)")
	beta   = st_matrix("e(beta)")
	gamma  = st_matrix("e(gamma)")
	lambda = st_matrix("e(lambda)")
	rho    = st_matrix("e(rho)")
	eta    = st_matrix("e(eta)")
	
	if (censor == "") {
		delta  = st_matrix("e(delta)")
		st_view(cdf=.,   .,    cdfs, touses)
		st_view(pdf=.,   .,    pdfs, touses)
	}
	
	if (cols(shr) != neqn) {
		exit(9998)
	}
	
	// First get the price index
	lnpindex = a0 :+ lnp*alpha'
	for(i=1; i<=rows(lnpindex); ++i) {
		lnpindex[i] = lnpindex[i] + 0.5*lnp[i,.]*gamma*lnp[i,.]'
	}
	
	if (ndemo > 0) {
		cofp = J(rows(lnp), 1, 0)
		for(i=1; i<=rows(lnp); ++i) {
			cofp[i] = lnp[i,.]*(eta'*demo[i,.]')
		}
		cofp = exp(cofp)
		mbar = 1 :+ demo*rho'
	}
	else {
		cofp = J(rows(lnp), 1, 1)
		mbar = J(rows(lnp), 1, 1)
	}
	if (quadratics == "") {
		// The b(p) term
		bofp = exp(lnp*beta')
	}
	else {
		bofp = J(rows(lnp), 1, 1)
	}	
	for(i=1; i<=neqn; ++i) {
		shr[.,i] = alpha[i] :+ lnp*gamma[i,.]'
		if (ndemo > 0) {
			shr[., i] = shr[., i] + 
				(J(rows(lnp), 1, beta[i]) + demo*eta[.,i]):*
				(lnexp - lnpindex - ln(mbar))
		}
		else {
			shr[., i] = shr[., i] + beta[i]*(lnexp - lnpindex)

		}
		if (quadratics == "") {
			shr[., i] = shr[., i] + lambda[i]:/(bofp:*cofp):*(
				(lnexp - lnpindex - ln(mbar)):^2)
			
		}
		if (censor == "") {
			shr[., i] = shr[., i]:*cdf[., i] + delta[i]*pdf[., i]
		}
	}

}


/*
	This program assumes the Gamma parameters are stored as vech(Gamma) 

	Derivatives for the Gamma parameters.

	Let N = number of goods

	Case 1: We have Gamma_{i,j} for i,j < N.  The derivative is
		simply unity
		
	Case 2: We have Gamma_{i,j} for i==N and j < N.  In this case
		
			Gamma_{N,j} = 0 - Gamma_{1,j} - Gamma_{2,j} - ...
		
		So the required derivative is minus one.
		
	Case 3: We are at Gamma_{N,N}.
	
			Gamma_{N,N} = 0 - Gamma_{1,N} - Gamma_{2,N} - ...
		(Slutsky symm.)	    = 0 - Gamma_{N,1} - Gamma_{N,2} - ...
				    = 0 - (0 - Sum_{j=1}^{j=N-1} Gamma_{1,j})
				    	- (0 - Sum_{j=1}^{j=N-1} Gamma_{2,j})
				    	- ...                           ^
				    	                    Call that i |
				    	
		So the required derivative is one if i==j and two if i!=j.
		
*/

void _quaidsce__delta(real scalar ng, 
		    string scalar quadratics,
			string scalar censor,		
		    real scalar ndemo,
		    string scalar Dmats)
{
	real scalar	i, j, ic, jc, m, n
	real scalar	ngm1
	real matrix	block, blockd, Delta, Gamma

	ngm1 = ng - 1
	
	if (censor == "") {
	block = I(ng) 
	}
	else {
	block = I(ngm1) \ J(1, ngm1, -1)
	}
	blockd = I(ngm1) \ J(1, ngm1, -1)
	Delta = block				// alpha
	Delta = blockdiag(Delta, block)		// beta

	// Gamma
	Gamma = J((ng+1)*ng/2, (ngm1+1)*ngm1/2, 0)
	m = 1
	for(j=1; j<=ng; ++j) {
		for(i=j; i<=ng; ++i) {
			n = 1
			for(jc=1; jc<ng; ++jc) {
				for(ic=jc; ic<ng; ++ic) {
					if (j < ng & i < ng) {     /* Case 1 */
						if (jc==j && ic==i) 
							Gamma[m,n] = 1
					}
					else if (j < ng & i==ng) { /* Case 2 */
						if (jc==j || ic==j)
							Gamma[m,n]=-1
					}
					else if (j==ng & i==ng) {  /* Case 3 */
						Gamma[m,n] = Gamma[m,n]+1
						if (ic != jc) 
							Gamma[m,n] =
								Gamma[m,n] + 1
					}
					++n
				}
			}
			++m
		}
	}
	
	Delta = blockdiag(Delta, Gamma)

	if (quadratics == "") {
		Delta = blockdiag(Delta, block)		// lambda	
	}
	
	if (censor == "") {
		Delta = blockdiag(Delta, block)		// delta	
	}
	
	if (ndemo > 0) {
		for(i=1; i<= ndemo; ++i) Delta = blockdiag(Delta, blockd)
		Delta = blockdiag(Delta, I(ndemo))
	}
	
	st_matrix(Dmats, Delta)
	
}
	
end



exit
