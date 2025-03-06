mata:
	mata clear
	struct TVPresult {
		real matrix beta, beta_lb, beta_ub, Omega, weight, beta_const, residual
		real scalar qLL
	}
	
	struct VARresult {
		real matrix irf, irf_lb, irf_ub
	}
	
	struct WEAKresult {
		real matrix m, mu, alpha
	}
	
	struct Dlogresult {
		real scalar l
		real matrix ld_B, ld_o, ld_o_r, ld_BB, ld_oB_r, ld_oo, ld_oo_r
		real matrix ld_A, ld_a, ld_l, ld_Ba, ld_Bl, ld_aa, ld_al, ld_ll // for cholesky
	}
	
	struct GMMresult {
		real scalar val, J
		real matrix e, Shat, eff_var
	}
	
	struct cholresult {
		real matrix o, Sigma
	}
	
	struct GMMresult scalar gmm(real matrix Y, real matrix X, real matrix Zt, real matrix Winv, real scalar nlag) {
		real scalar T, p, TG, k, G, i, tt, val, J
		real matrix Z, e, res, u, g, Shat, eff_var
		struct GMMresult scalar result
		
		// real dimensions
		T = rows(Zt); p = cols(Zt)
		TG = rows(X); k = cols(X)
		G = TG / T
		
		// Construct TG*Gp instrument matrix
		Z = J(T*G, G*p, 0)
		for (i=1;i<=G;i++) {
			if (i == 1) Z[.,p*(i-1)+1..p*i] = Zt # (1 \ J(G-i,1,0))
			else Z[.,p*(i-1)+1..p*i] = Zt # (J(i-1,1,0) \ 1 \ J(G-i,1,0))
		}
		e = pinv(X' * Z * pinv(Winv) * Z' * X) * X' * Z * pinv(Winv) * Z' * Y
		res = Y - X * e
		val = 1/T * res' * Z * pinv(Winv) * Z' * res
		u = J(G, T, 0)
		for (tt=1;tt<=T;tt++) u[.,tt] = res[(tt-1)*G+1..tt*G,.]
		g = J(T, G*p, 0)
		for (i=1;i<=G;i++) g[.,p*(i-1)+1..p*i] = (J(1,p,1) # (u[i,.])') :* Zt
		Shat = nws(g, nlag)
		eff_var = T * pinv(X' * Z * pinv(Shat) * Z' * X)
		J = 1/T * res' * Z * pinv(Shat) * Z' * res
		
		result.val = val
		result.J = J
		result.e = e
		result.Shat = Shat
		result.eff_var = eff_var
		return(result)
	}
	
	struct TVPresult scalar tvpest(real matrix c, real matrix s_T, real matrix H, real matrix theta_const, real scalar T, real scalar q, real scalar nlag, real scalar getband, real scalar level) {
		real scalar qqq, rowc, nG, tt, weights, ii, qq, stat, kk, kkk
		real matrix wl, V, gamma, S, Sinv, S_beta, y_tilde, x, r, z, z_tilde, z_bar, beta_hat_nG, qLL, qLL_k, weight_tilde, beta_hat, rbarvect, tempcoeff, tempres, ratio, kappa_c, Omega, Omega_nG, add, D_h, F, P, C_i, Sigma_delta_i, K_i, Sigma_i, lag, weight, Sigma, e, std, beta_ub, beta_lb
		struct TVPresult scalar result
		
		/////// Step 1: construct x_t and \tilde{y}_t ///////
		qqq = rows(theta_const)
		if (nlag == 0) V = s_T * s_T' / T
		else {
			wl = s_T' - J(T,1,1) * mean(s_T')
			V = wl' * wl / T
			for (tt=1;tt<=nlag;tt++) {
				lag = (J(tt,cols(wl),0) \ wl[1..T-tt,.])
				gamma = (wl' * lag + lag' * wl) / T
				weights = 1 - (tt / (nlag + 1));
				V = V + weights * gamma
			}
		}
		S = pinv(H) * V * pinv(H)
		if (q == qqq) {
			y_tilde = H * pinv(V) * s_T
			x = pinv(H) * s_T
		}
		else {
			Sinv = pinv(S)
			S_beta = pinv(Sinv[1..q,1..q])
			y_tilde = H * pinv(V) * s_T
			y_tilde = y_tilde[1..q,.]
			x = S_beta * y_tilde
		}
		
		/////// Step 2: compute (a) - (e) ///////
		rowc = rows(c); nG = cols(c)
		if (rowc == 1) r = J(q,nG,1) - J(q,1,1) * c / T
		else r = J(q,nG,1) - c / T
		z = J(nG*q, T, 0)
		z_tilde = J(nG*q, T, 0)
		z_bar = J(nG*q, T, 0)
		beta_hat_nG = J(nG*q, T, 0)
		qLL = J(1, nG, 0)
		qLL_k = J(q, nG, 0)
		weight_tilde = J(1, nG, 1)

		for (ii=1;ii<=nG;ii++) {
		// (a)
			z[(ii-1)*q+1..ii*q,1] = x[.,1]
			for (tt=2;tt<=T;tt++) {
				z[(ii-1)*q+1..ii*q,tt] = r[.,ii] :* z[(ii-1)*q+1..ii*q,tt-1] + x[.,tt] - x[.,tt-1]
			}
		// (b)
			rbarvect = cumprod(J(T,1,1)*r[1,ii]) / r[1,ii]
			for (qq=1;qq<=q;qq++) {
				tempcoeff = (pinv(rbarvect' * rbarvect) * rbarvect' * (z[(ii-1)*q+qq,.])')'
				tempres = (z[(ii-1)*q+qq,.])' - rbarvect * tempcoeff'
				z_tilde[(ii-1)*q+qq,.] = tempres'
			}
		// (c)
			z_bar[(ii-1)*q+1..ii*q,T] = z_tilde[(ii-1)*q+1..ii*q,T]
			for (tt=T-1;tt>=1;tt--) {
				z_bar[(ii-1)*q+1..ii*q,tt] = r[.,ii] :* z_bar[(ii-1)*q+1..ii*q,tt+1] + z_tilde[(ii-1)*q+1..ii*q,tt] - z_tilde[(ii-1)*q+1..ii*q,tt+1]
			}
		// (d)
			beta_hat_nG[(ii-1)*q+1..ii*q,.] = theta_const[1..q] * J(1,T,1) + x - (r[.,ii] * J(1,T,1)) :* z_bar[(ii-1)*q+1..ii*q,.]
		// (e)
			qLL_k[.,ii] = rowsum(((r[.,ii] * J(1,T,1)) :* z_bar[(ii-1)*q+1..ii*q,.] - x) :* y_tilde)
			qLL[1,ii] = colsum(qLL_k[.,ii])
			ratio = sqrt(T * (J(q,1,1) - r[.,ii]:^2) :* (r[.,ii]:^(T - 1)) :/ (J(q,1,1) - r[.,ii]:^(2 * T)))
			weight_tilde[1,ii] = prod(ratio:^(1/q)) * exp(-1/2 * qLL[1,ii])
			if (weight_tilde[1,ii] == .) weight_tilde[1,ii] = 1
		}

		/////// Step 3 ///////
		weight = weight_tilde / rowsum(weight_tilde)

		/////// Step 4 ///////
		beta_hat = J(q,T,0)
		for (ii=1;ii<=nG;ii++) {
			beta_hat = beta_hat + weight[1,ii] * beta_hat_nG[(ii-1)*q+1..ii*q,.]
		}
		
		/////// Step 5 (only for scalar c and grid 0:5:50) ///////
		stat = qLL[1,3]

		/////// Compute accuracy measurement Omega ///////
		Omega = J(q,q*T,0)
		if (getband == 1) {
			S_beta = S[1..q,1..q]
			if (rowc == 1) { // Muller-Petalas formula of Omega_t on page 1513 (only for scalar c_i)
				if (q == qqq) {
					kappa_c = (J(T,1,1) * c) :* ((J(T,nG,1) + exp(2 * J(T,1,1) * c) + exp(2 * (1::T) * c / T)) + exp(2 * (J(T,1,1) - (1::T) / T) * c)) :/ (2 * exp(2 * J(T,1,1) * c) - J(T,nG,2))
					kappa_c[.,1] = J(T,1,1)
					Omega = J(q,q*T,0)
					Omega_nG = J(q*nG,q*T,0)
					for (ii=1;ii<=nG;ii++) {
						add = (kappa_c[.,ii])' # S_beta / T
						for (tt=1;tt<=T;tt++) {
							add[.,(tt-1)*q+1..tt*q] = add[.,(tt-1)*q+1..tt*q] + (beta_hat_nG[(ii-1)*q+1..ii*q,.] - beta_hat)[.,tt] * ((beta_hat_nG[(ii-1)*q+1..ii*q,.] - beta_hat)[.,tt])'
						}
						Omega = Omega + weight[1,ii] * add
						Omega_nG[(ii-1)*q+1..ii*q,.] = add
					}
				}
				else {
					kappa_c = (J(T,1,1) * c) :* ((J(T,nG,1) + exp(2 * J(T,1,1) * c) + exp(2 * (1::T) * c / T)) + exp(2 * (J(T,1,1) - (1::T) / T) * c)) :/ (2 * exp(2 * J(T,1,1) * c) - J(T,nG,2)) - J(T,nG,1)
					kappa_c[.,1] = J(T,1,0)
					Omega = J(1,T,1) # (1 / T * S[1..q,1..q])
					Omega_nG = J(q*nG,q*T,0)
					for (ii=1;ii<=nG;ii++) {
						add = (kappa_c[.,ii])' # S_beta / T
						for (tt=1;tt<=T;tt++) {
							add[.,(tt-1)*q+1..tt*q] = add[.,(tt-1)*q+1..tt*q] + (beta_hat_nG[(ii-1)*q+1..ii*q,.] - beta_hat)[.,tt] * ((beta_hat_nG[(ii-1)*q+1..ii*q,.] - beta_hat)[.,tt])'
						}
						Omega = Omega + weight[1,ii] * add
						Omega_nG[(ii-1)*q+1..ii*q,.] = add + Omega
					}
				}
			}
			else { // for vector c_i, compute Omega using Muller-Petalas eq (19)
				D_h = I(T) # H
				Sigma = J(T*q, T*q, 0)
				e = J(T,1,1) # I(q)
				F = lowertriangle(J(T,T,1))
				P = cholesky(S_beta)
				for (ii=1;ii<=nG;ii++) {
					C_i = diag((c[.,ii]):^2)
					Sigma_delta_i = 1 / T^2 * ((I(T) - J(T,1,1) * J(1,T,1) / T) * F * F' * (I(T) - J(T,1,1) * J(1,T,1) / T)) # (P * C_i * P')
					K_i = Sigma_delta_i * luinv(D_h * Sigma_delta_i + I(T*q)) // this line will cause crash!
					Sigma_i = K_i + (I(T*q) - K_i * D_h) * e * luinv(e' * D_h * e - e' * D_h * K_i * D_h * e) * e' * (I(T*q) - D_h * K_i) // this line will cause crash!
					Sigma = Sigma + weight[.,ii] * (Sigma_i + vec(beta_hat_nG[(ii-1)*q+1..ii*q,.] - beta_hat) * (vec(beta_hat_nG[(ii-1)*q+1..ii*q,.] - beta_hat))')
				}
				for (tt=1;tt<=T;tt++) {
					Omega[.,(tt-1)*q+1..tt*q]  = Sigma[(tt-1)*q+1..tt*q,(tt-1)*q+1..tt*q]
				}
			}
		}
		
		std = J(q, T, 0)
		for (tt=1;tt<=T;tt++) {
			std[.,tt] = diagonal(Omega[.,(tt-1)*q+1..tt*q])
		}
		std = sqrt(std)
		beta_lb = beta_hat - invnormal(1-(1-level/100)/2) * std
		beta_ub= beta_hat + invnormal(1-(1-level/100)/2) * std
		
		result.beta_const = theta_const
        result.beta = beta_hat
		result.beta_lb = beta_lb
		result.beta_ub = beta_ub
		result.Omega = Omega
		result.weight = weight
		result.qLL = stat
		return(result)
	}
	
	struct cholresult scalar chol(real matrix Sigma) {
		real matrix temp, l, a, Sigma1, Sigma2, A
		real scalar n, na, kk, kkk
		struct cholresult scalar result
		
		n = rows(Sigma)
		temp = (cholesky(Sigma))'
		l = log(diagonal(temp))
		A = I(n)
		if (n > 1) {
			Sigma1 = diag(diagonal(temp))
			temp = pinv(pinv(Sigma1) * temp) - I(n)
			a = J(n*(n-1)/2,1,0)
			na = 0
			for (kk=1;kk<=n-1;kk++) {
				for (kkk=kk+1;kkk<=n;kkk++) {
					na = na + 1
					a[na,1] = temp[kk,kkk]
					A[kkk,kk] = temp[kk,kkk]
				}
			}
		}
		Sigma2 = diag(exp(l))
		result.Sigma = pinv(A) * Sigma2 * Sigma2' * pinv(A')
		if (n == 1) result.o = l
		else result.o = (a \ l)
		return(result)
	}
	
	struct TVPresult scalar MPpath(real matrix yy, real matrix xx, real scalar lag, real matrix c, real scalar getband, real scalar chol, real scalar q, real scalar level) {
        real scalar T, nq, na, nl, n, rowc, nG, tt, weights, ii, qq, stat, k, kk, kkk, nqcovar
		real matrix  y, X_p, b_OLS, a_OLS, l_OLS, theta_const, res_u, res_U, Sigma_u_OLS, temp, Sigma_OLS, b, a, l, Sigma, Sigma_u, s_T, h_T, H, betanow, residual
		struct TVPresult scalar result
		struct cholresult scalar result_chol
		struct Dlogresult scalar resultDlog
		
		/////// preparation ////////
        T = rows(xx); k = cols(xx); n = cols(yy)
		nq = n * k; na = n * (n - 1) / 2; nl = n
		nqcovar = n * (n + 1) / 2
		qq = nq + nqcovar // total number of parameters
		
		/////// get data for regression ///////
		y = yy'; X_p = J(n*T,n*k,1)
		for (tt=1;tt<=T;tt++) X_p[n*(tt-1)+1..n*tt,.] = I(n) # xx[tt,.]
		
		/////// constant parameter estimation ///////
		b_OLS = pinv(X_p' * X_p) * X_p' * vec(y)
		res_u = vec(y) - X_p * b_OLS
		res_U = J(n,T,0)
		for (tt=1;tt<=T;tt++) res_U[.,tt] = res_u[(tt-1)*n+1..tt*n,1]
		Sigma_u_OLS = res_U * res_U' / T
		result_chol = chol(Sigma_u_OLS)
		if (chol == 1) theta_const = (b_OLS \ result_chol.o) // cholesky
		else theta_const = (b_OLS \ vech(Sigma_u_OLS)) // no decomposition
		
		/////// get scores and hessians ///////
		s_T = J(qq,T,0)
		H = J(qq,qq,0)
		for (tt=1;tt<=T;tt++) {
			if (chol == 1) resultDlog = Dloglik_t_multi_chol(y[.,tt], X_p[n*(tt-1)+1..n*tt,.], b_OLS, result_chol.Sigma) // cholesky
			else resultDlog = Dloglik_t_multi(y[.,tt], X_p[n*(tt-1)+1..n*tt,.], b_OLS, Sigma_u_OLS) // no decomposition
			s_T[.,tt] = (resultDlog.ld_B \ resultDlog.ld_o_r)
			h_T = - ((resultDlog.ld_BB, resultDlog.ld_oB_r') \ (resultDlog.ld_oB_r, resultDlog.ld_oo_r))
			H = H + h_T / T     
		}

		/////// estimation ///////
		result = tvpest(c, s_T, H, theta_const, T, q, lag, getband, level)
		
		/////// get residuals ///////
		residual = J(n, T, 0)
		if (q >= nq) {
			for (tt=1;tt<=T;tt++) {
				betanow = J(n,k,0)
				for (kk=1;kk<=n;kk++) betanow[kk,.] = (result.beta[(kk-1)*k+1..kk*k,tt])'
				residual[.,tt] = (yy[tt,.])' - betanow * (xx[tt,.])'
			}
		}
		result.residual = residual
        return(result)
    }
		
	struct TVPresult scalar MPIVpath(real matrix y1, real matrix y2, real matrix z1, real matrix z2, real scalar lag, real matrix c, real scalar getband, real scalar chol, real scalar q, real scalar level, string estimator) {
		real scalar rowc, nG, T, n1, n2, k1, k2, n, k, nq, nqbar, nqcovar, qqq, tt, jj, nwlags
		real matrix y, z, X_p, X1p, X2p, b_OLS, u_OLS, U_OLS, Sigmau_OLS, b1_2SLS, alpha_vec_2SLS, alpha_p_2SLS, u1_2SLS, U1_2SLS, alphaz_2SLS, b2_2SLS, m_vec_2SLS, mp_2SLS, mu_vec_2SLS, u2_2SLS, U2_2SLS, Sigmau_2SLS, theta_2SLS, m_vec_gmm, mp_gmm, mu_vec_gmm, U2_gmm, Sigmau_gmm, theta_GMM, theta_const, dBBar_p, dBBar, Delta, Delta0_p, e0_alpha_p, e0_m_p, e0_m, s_T, h_T, H, residual, alpha_vec, m_vec, mu_vec, alpha_vec_t, alpha_p_t, m_vec_t, m_p_t, mu_vec_t, mu_p_t, malphanow, coeffnow_z
		struct cholresult scalar result_chol_OLS, result_chol_2SLS, result_chol_gmm
		struct TVPresult scalar result
		struct Dlogresult scalar resultDlog
		struct GMMresult scalar result_GMM1, result_GMM2
		
		//////// preparation ///////
		rowc = rows(c); nG = cols(c)
		T = rows(y1); n1 = cols(y1); n2 = cols(y2); k1 = cols(z1); k2 = cols(z2)
		if (z1 == J(T, 1, 0)) k1 = 0
		n = n1 + n2; k = k1 + k2; nq = n * k; 
		nqbar = n1 * k + n2 * (n1 + k1); nqcovar = n * (n + 1) / 2
		qqq = nqbar + nqcovar // total number of parameters
		
		//////// construct y, Xp ////////
		y = (y1' \ y2')
		if (k1 > 0) z = (z2' \ z1')
		else z = z2'
		X_p = J(n*T, n*k, 0)
		for (tt=1;tt<=T;tt++) X_p[n*(tt-1)+1..n*tt,.] = I(n) # (z[.,tt])'
		
		// n1*k: alpha; first stage regression (regress y1 on z2, z1)
		// n2*n1: m; second statge regression (endogeneous, effect of y1 on y2)
		// n2*k1: mu; second statge regression (exogenous, effect of z1 on y2)
		
		//////// estimation assuming constant parameters ////////
		// OLS estimation
		b_OLS = pinv(X_p' * X_p) * X_p' * vec(y)
		u_OLS = vec(y) - X_p * b_OLS
		U_OLS = J(n, T, 0)
		for (tt=1;tt<=T;tt++) U_OLS[.,tt] = u_OLS[(tt-1)*n+1..tt*n,.]
		Sigmau_OLS = U_OLS * U_OLS' / T
		result_chol_OLS = chol(Sigmau_OLS)

		// 2SLS estimation
		X1p = J(n1*T, n1*k, 0) // ols for y1
		for (tt=1;tt<=T;tt++) X1p[n1*(tt-1)+1..n1*tt,.] = I(n1) # (z[.,tt])'
		b1_2SLS = pinv(X1p' * X1p) * X1p' * vec(y1')
		alpha_vec_2SLS = b1_2SLS[1..n1*k,1]
		alpha_p_2SLS = J(k, n1, 0)
		for (tt=1;tt<=n1;tt++) alpha_p_2SLS[.,tt] = alpha_vec_2SLS[(tt-1)*k+1..tt*k,1]
		u1_2SLS = vec(y1') - X1p * b1_2SLS
		U1_2SLS = J(n1, T, 0)
		for (tt=1;tt<=T;tt++) U1_2SLS[.,tt] = u1_2SLS[(tt-1)*n1+1..tt*n1,.]
		X2p = J(n2*T, n2*(n1+k1), 0) // 2sls for y2
		alphaz_2SLS = alpha_p_2SLS' * z
		for (tt=1;tt<=T;tt++) {
			if (k1 > 0) X2p[n2*(tt-1)+1..n2*tt,.] = ((I(n2) # (alphaz_2SLS[.,tt])'), (I(n2) # z1[tt,.]))
			else X2p[n2*(tt-1)+1..n2*tt,.] = I(n2) # (alphaz_2SLS[.,tt])'
		}
		b2_2SLS = pinv(X2p' * X2p) * X2p' * vec(y2')
		m_vec_2SLS = b2_2SLS[1..n2*n1,1]
		mp_2SLS = J(n1, n2, 0)
		for (tt=1;tt<=n2;tt++) mp_2SLS[.,tt] = m_vec_2SLS[(tt-1)*n1+1..tt*n1,.]
		if (k1 > 0) mu_vec_2SLS = b2_2SLS[n2*n1+1..n2*n1+n2*k1,1]
		u2_2SLS = vec(y2') - X2p * b2_2SLS
		U2_2SLS = J(n2, T, 0)
		for (tt=1;tt<=T;tt++) U2_2SLS[.,tt] = u2_2SLS[(tt-1)*n2+1..tt*n2,1]
		Sigmau_2SLS = (U1_2SLS \ U2_2SLS) * (U1_2SLS \ U2_2SLS)' / T
		result_chol_2SLS = chol(Sigmau_2SLS)
		if (chol == 1) {
			if (k1 > 0) theta_2SLS = (alpha_vec_2SLS \ m_vec_2SLS \ mu_vec_2SLS \ result_chol_2SLS.o)
			else theta_2SLS = (alpha_vec_2SLS \ m_vec_2SLS \ result_chol_2SLS.o)
		}
		else {
			if (k1 > 0) theta_2SLS = (alpha_vec_2SLS \ m_vec_2SLS \ mu_vec_2SLS \ vech(Sigmau_2SLS))
			else theta_2SLS = (alpha_vec_2SLS \ m_vec_2SLS \ vech(Sigmau_2SLS))
		}

		// GMM estimation
		X1p = J(n1*T, n1*k, 0) // ols for y1
		for (tt=1;tt<=T;tt++) X1p[n1*(tt-1)+1..n1*tt,.] = I(n1) # (z[.,tt])'
		b1_2SLS = pinv(X1p' * X1p) * X1p' * vec(y1')
		alpha_vec_2SLS = b1_2SLS[1..n1*k,1]
		alpha_p_2SLS = J(k, n1, 0)
		for (tt=1;tt<=n1;tt++) alpha_p_2SLS[.,tt] = alpha_vec_2SLS[(tt-1)*k+1..tt*k,1]
		u1_2SLS = vec(y1) - X1p * b1_2SLS
		U1_2SLS = J(n1, T, 0)
		for (tt=1;tt<=T;tt++) U1_2SLS[.,tt] = u1_2SLS[(tt-1)*n1+1..tt*n1,.]
		nwlags = 4 // gmm for y2
		if (k1 > 0) {
			result_GMM1 = gmm(y2, (y1, z1), z' , I(k), nwlags)
			result_GMM2 = gmm(y2, (y1, z1), z' , result_GMM1.Shat, nwlags)
		}
		else {
			result_GMM1 = gmm(y2, y1, z' , I(k), nwlags)
			result_GMM2 = gmm(y2, y1, z' , result_GMM1.Shat, nwlags)
		}
		m_vec_gmm = result_GMM2.e[1..n1,1]
		mp_gmm = J(n1, n2, 0)
		for (tt=1;tt<=n2;tt++) mp_gmm[.,tt] = m_vec_gmm[(tt-1)*n1+1..tt*n1,.]
		if (k1 > 0) mu_vec_gmm = result_GMM2.e[n1+1..n1+k1,1]
		if (k1 > 0) U2_gmm = y2' - (result_GMM2.e)' * (y1' \ z1')
		else U2_gmm = y2' - (result_GMM2.e)' * y1'
		Sigmau_gmm = (U1_2SLS \ U2_gmm) * (U1_2SLS \ U2_gmm)' / T
		result_chol_gmm = chol(Sigmau_gmm)
		if (chol == 1) {
			if (k1 > 0) theta_GMM = (alpha_vec_2SLS \ m_vec_gmm\ mu_vec_gmm \ result_chol_gmm.o)
			else theta_GMM = (alpha_vec_2SLS \ m_vec_gmm \ result_chol_gmm.o)
		}
		else {
			if (k1 > 0) theta_GMM = (alpha_vec_2SLS \ m_vec_gmm\ mu_vec_gmm \ vech(Sigmau_gmm))
			else theta_GMM = (alpha_vec_2SLS \ m_vec_gmm \ vech(Sigmau_gmm))
		}

		if (estimator == "2sls") theta_const = theta_2SLS
		else if (estimator == "variv") theta_const = theta_2SLS
		else if (estimator == "gmm") theta_const = theta_GMM
		
		/////// get scores and hessians ///////
		dBBar_p = J(nq, nqbar, 0)
		dBBar_p[1..n1*k,1..n1*k] = I(n1 * k)
		dBBar_p[n1*k+1..n1*k+n2*k,1..n1*k] = mp_gmm' # I(k)
		dBBar_p[n1*k+1..n1*k+n2*k,n1*k+1..n1*k+n2*n1] = I(n2) # alpha_p_2SLS
		if (k1 > 0) dBBar_p[n1*k+n2*k2+1..n1*k+n2*k2+n2*k1,n1*k+n1*n2+1..n1*k+n1*n2+n2*k1] = I(n2*k1)
		dBBar = dBBar_p'
		
		// get Delta
		Delta = J(nqbar, nq*(n1*k+n1*n2+n2*k1), 0)
		// element 1:n1k2, get e_{\alpha}'
		for (tt=1;tt<=n1;tt++) {
			for (jj=1;jj<=k;jj++) {
				e0_alpha_p = J(k, n1, 0)
				e0_alpha_p[jj,tt] = 1
				Delta0_p = J(nq, nqbar, 0)
				Delta0_p[n1*k+1..n1*k+n2*k,n1*k+1..n1*k+n1*n2] = I(n2) # e0_alpha_p
				Delta[.,((tt-1)*k+jj-1)*nq+1..((tt-1)*k+jj)*nq] = Delta0_p'
			}
		}
		
		// element n1k+1:n1k+n1n2, get e_{m}
		for (tt=1;tt<=n2;tt++) {
			for (jj=1;jj<=n1;jj++) {
				e0_m_p = J(n1, n2, 0)
				e0_m_p[jj,tt] = 1
				e0_m = e0_m_p'
				Delta0_p = J(nq, nqbar, 0)
				Delta0_p[n1*k+1..n1*k+n2*k,1..n1*k] = e0_m # I(k)
				Delta[.,n1*k*nq+((tt-1)*k+jj-1)*nq+1..n1*k*nq+((tt-1)*k+jj)*nq] = Delta0_p'
			}
		}
		
		// construct s and H
		s_T = J(qqq,T,0)
		H = J(qqq,qqq,0)
		for (tt=1;tt<=T;tt++) {
			if (chol == 1) resultDlog = Dloglik_t_multi_chol(y[.,tt], X_p[n*(tt-1)+1..n*tt,.], b_OLS, result_chol_OLS.Sigma)
			else resultDlog = Dloglik_t_multi(y[.,tt], X_p[n*(tt-1)+1..n*tt,.], b_OLS, Sigmau_OLS)
			s_T[.,tt] = (dBBar * resultDlog.ld_B \ resultDlog.ld_o_r)
			h_T = - (((dBBar * resultDlog.ld_BB * dBBar' + Delta * (I(nqbar) # resultDlog.ld_B)), dBBar * (resultDlog.ld_oB_r)') \ (resultDlog.ld_oB_r * dBBar', resultDlog.ld_oo_r))
			H = H + h_T / T     
		}
		
		/////// estimation ///////
		result = tvpest(c, s_T, H, theta_const, T, q, lag, getband, level)
		
		/////// get residuals ///////
		residual = J(n, T, 0)
		if (q >= nqbar) {
			alpha_vec = result.beta[1..n1*k,.]
			m_vec = result.beta[n1*k+1..n1*k+n1*n2,.]
			if (k1 > 0) mu_vec = result.beta[n1*k+n1*n2+1..n1*k+n1*n2+n2*k1,.]
			if (k1 > 0) z = (z2' \ z1')
			else z = z2'
			for (tt=1;tt<=T;tt++) {
				alpha_vec_t = alpha_vec[.,tt]
				alpha_p_t = J(k, n1, 0)
				for (jj=1;jj<=n1;jj++) alpha_p_t[.,jj] = alpha_vec_t[(jj-1)*k+1..jj*k,1]
				m_vec_t = m_vec[.,tt]
				m_p_t = J(n1, n2, 0)
				for (jj=1;jj<=n2;jj++) m_p_t[.,jj] = m_vec_t[(jj-1)*n1+1..jj*n1,1]
				if (k1 > 0) {
					mu_vec_t = mu_vec[.,tt]
					mu_p_t = J(k1, n2, 0)
					for (jj=1;jj<=n2;jj++) mu_p_t[.,jj] = mu_vec_t[(jj-1)*k1+1..jj*k1,1]
					malphanow = m_p_t' * alpha_p_t' + (J(n2, k2, 0), mu_p_t')
				}
				else malphanow = m_p_t' * alpha_p_t'
				coeffnow_z = (alpha_p_t' \ malphanow)
				residual[.,tt] = y[.,tt] - coeffnow_z * z[.,tt]
			}
		}
		result.residual = residual
		return(result)
	}
	
	struct TVPresult scalar MPweakIVpath(real matrix y1, real matrix y2, real matrix z1, real matrix z2, struct TVPresult scalar result_TVPLV, real scalar q, real scalar R, real scalar level, real scalar fix, real scalar getband) {
		real scalar T, n1, n2, k1, k2, n, k, nq, nqbar, nqcovar, qq, qqq, tt, jj, rr, seed
		real matrix y, z, para, Omega, para_Omega, beta, beta_ub, beta_lb, beta_all_t, para_t, para_Omega_t, C_t, paranow, beta_all_t_jj, residual, alpha_vec, m_vec, mu_vec, alpha_vec_t, alpha_p_t, m_vec_t, m_p_t, mu_vec_t, mu_p_t, malphanow, coeffnow_z
		struct TVPresult scalar result
		struct WEAKresult scalar result_weak
		
		//////// preparation ///////
		T = rows(y1); n1 = cols(y1); n2 = cols(y2); k1 = cols(z1); k2 = cols(z2)
		if (z1 == J(T, 1, 0)) k1 = 0
		n = n1 + n2; k = k1 + k2; nq = n * k
		nqbar = n1 * k + n2 * (n1 + k1); nqcovar = n * (n + 1) / 2
		qq = nq + nqcovar
		qqq = nqbar + nqcovar // total number of parameters
		if (q < qqq) q = qqq

		// get parameters
		y = (y1' \ y2')
		if (k1 > 0) z = (z2' \ z1')
		else z = z2'
		para = result_TVPLV.beta
		para_Omega = result_TVPLV.Omega
		
		//////// draw from distributions ////////
		if (getband == 0) {
			beta = J(q, T, 0)
			for (tt=1;tt<=T;tt++) {
				para_t = para[.,tt]
				result_weak = strucpara(para_t, n1, n2, k1, k2)
				beta[.,tt] = (result_weak.alpha \ result_weak.m \ result_weak.mu\ para_t[nq+1..qq,1])
			}
			result = result_TVPLV
			result.beta = beta
			result.beta_lb = beta
			result.beta_ub = beta
		}
		else {
			beta = J(q, T, 0); beta_lb = J(q, T, 0); beta_ub = J(q, T, 0)
			for (tt=1;tt<=T;tt++) {
				beta_all_t = J(q, R, 0)
				for (rr=1;rr<=R;rr++) {
					if (fix == 1) {
						seed = (tt - 1) * R + rr
						rseed(seed)
					}
					para_t = para[.,tt]
					para_Omega_t = para_Omega[.,(tt-1)*qq+1..tt*qq]
					C_t = cholesky(para_Omega_t)
					paranow = para_t + C_t * rnormal(qq,1,0,1)	
					result_weak = strucpara(paranow, n1, n2, k1, k2)
					beta_all_t[.,rr] = (result_weak.alpha \ result_weak.m \ result_weak.mu \ paranow[nq+1..qq,1])
				}
				for (jj=1;jj<=q;jj++) {
					beta_all_t_jj = sort((beta_all_t[jj,.])',1)
					beta_lb[jj,tt] = beta_all_t_jj[floor(R/100*(50-level/2)),1] // lower bound
					beta[jj,tt] = beta_all_t_jj[floor(R/100*50),1] // median
					beta_ub[jj,tt] = beta_all_t_jj[floor(R/100*(50+level/2)),1] // upper bound
				}
			}
			result = result_TVPLV
			result.beta = beta
			result.beta_lb = beta_lb
			result.beta_ub = beta_ub
		}
		
		/////// get residuals ///////
		residual = J(n, T, 0)
		if (q >= nqbar) {
			alpha_vec = result.beta[1..n1*k,.]
			m_vec = result.beta[n1*k+1..n1*k+n1*n2,.]
			if (k1 > 0) mu_vec = result.beta[n1*k+n1*n2+1..n1*k+n1*n2+n2*k1,.]
			for (tt=1;tt<=T;tt++) {
				alpha_vec_t = alpha_vec[.,tt]
				alpha_p_t = J(k, n1, 0)
				for (jj=1;jj<=n1;jj++) alpha_p_t[.,jj] = alpha_vec_t[(jj-1)*k+1..jj*k,1]
				m_vec_t = m_vec[.,tt]
				m_p_t = J(n1, n2, 0)
				for (jj=1;jj<=n2;jj++) m_p_t[.,jj] = m_vec_t[(jj-1)*n1+1..jj*n1,1]
				if (k1 > 0) {
					mu_vec_t = mu_vec[.,tt]
					mu_p_t = J(k1, n2, 0)
					for (jj=1;jj<=n2;jj++) mu_p_t[.,jj] = mu_vec_t[(jj-1)*k1+1..jj*k1,1]
					malphanow = m_p_t' * alpha_p_t' + (J(n2, k2, 0), mu_p_t')
				}
				else malphanow = m_p_t' * alpha_p_t'
				coeffnow_z = (alpha_p_t' \ malphanow)
				residual[.,tt] = y[.,tt] - coeffnow_z * z[.,tt]
			}
		}
		result.residual = residual
		return(result)
	}
	
	struct WEAKresult scalar strucpara(real matrix para, real scalar n1, real scalar n2, real scalar k1, real scalar k2) {
		real scalar jj, n, k
		real matrix alpha, alpha12p, alpha12, malphamu, malpha12mup, malpha12mu, alpha1, alpha2, malpha2, malpha1mu, m, mu
		struct WEAKresult scalar result
		
		n = n1 + n2
		k = k1 + k2
		alpha = para[1..n1*k,1]
		alpha12p = J(k, n1, 0)
		for (jj=1;jj<=n1;jj++) alpha12p[.,jj] = alpha[(jj-1)*k+1..jj*k,1]
		alpha12 = alpha12p'
		malphamu = para[n1*k+1..n*k,1]
		malpha12mup = J(k, n2, 0)
		for (jj=1;jj<=n2;jj++) malpha12mup[.,jj] = malphamu[(jj-1)*k+1..jj*k,1]
		malpha12mu = malpha12mup'
		alpha2 = alpha12[.,1..k2]
		alpha1 = alpha12[.,k2+1..k]
		malpha2 = malpha12mu[.,1..k2]
		malpha1mu = malpha12mu[.,k2+1..k]
		m = malpha2 * alpha2' * pinv(alpha2 * alpha2')
		mu = malpha1mu - m * alpha1
		
		result.alpha = alpha
		result.m = m'
		result.mu = mu'
		return(result)
	}
	
	struct VARresult scalar MPVARpath(real matrix beta, real matrix Omega, real scalar K, real scalar cons, real scalar nhor, real scalar R, real scalar level,real scalar fix, real scalar chol, real scalar getband) {
		real scalar T, q, p, rr, tt, k, kk
		real matrix irf, irf_lb, irf_ub, beta_now, para_t, para_Omega_t, C_t, irf_rr, vecirf, vecirf_lb, vecirf_ub, Sigmaut, alpha_path, logsig_path
		struct cholresult scalar result_chol_t
		struct VARresult scalar result

		T = cols(beta); q = rows(beta); 
		p = (q - K * (K + 1) / 2) / (K * K) - cons / K
		
		if (chol == 0) {
			if (K > 1) alpha_path = J(K*(K-1)/2,T,0)
			logsig_path = J(K,T,0)
			for (tt=1;tt<=T;tt++) {
				Sigmaut = invvech(beta[K*(K*p+cons)+1..q,tt])
				result_chol_t = chol(Sigmaut)
				if (K > 1) alpha_path[.,tt] = result_chol_t.o[1..K*(K-1)/2]
				logsig_path[.,tt] = result_chol_t.o[K*(K-1)/2+1..K*(K+1)/2]
			}
			if (K > 1) beta[K*(K*p+cons)+1..K*(K*p+cons)+K*(K-1)/2,.] = alpha_path
			beta[K*(K*p+cons)+K*(K-1)/2+1..q,.] = logsig_path
		}
		irf = vartvpirf(beta, K, cons, nhor)
		irf_lb = irf
		irf_ub = irf
		
		if (getband == 1) {
			irf_all = J(R*(nhor+1)*K,K*T,0)
			for (rr=1;rr<=R;rr++) {
				beta_now = J(q, T, 0)
				for (tt=1;tt<=T;tt++) {
					if (fix == 1) {
						seed = (tt - 1) * R + rr
						rseed(seed)
					}
					para_t = beta[.,tt]
					para_Omega_t = Omega[.,(tt-1)*q+1..tt*q]
					C_t = cholesky(para_Omega_t)
					beta_now[.,tt] = para_t + C_t * rnormal(q,1,0,1)
				}
				irf_all[(rr-1)*(nhor+1)*K+1..rr*(nhor+1)*K,.] = vartvpirf(beta_now, K, cons, nhor)
			}
			for (tt=1;tt<=T;tt++) {
				for (hh=1;hh<=nhor+1;hh++) {
					for (k=1;k<=K;k++) {
						for (kk=1;kk<=K;kk++) {
							irf_rr = J(R,1,0)
							for (rr=1;rr<=R;rr++) irf_rr[rr] = irf_all[(rr-1)*(nhor+1)*K+(hh-1)*K+k,(tt-1)*K+kk]
							irf_rr = sort(irf_rr,1)
							irf_lb[(hh-1)*K+k,(tt-1)*K+kk] = irf_rr[floor(R/100*(50-level/2)),1] // lower bound

							irf_ub[(hh-1)*K+k,(tt-1)*K+kk] = irf_rr[floor(R/100*(50+level/2)),1] // upper bound
						}
					}
					
				}
			}
		}
		
		vecirf = J((nhor+1)*K*K,T,0)
		vecirf_lb = J((nhor+1)*K*K,T,0)
		vecirf_ub = J((nhor+1)*K*K,T,0)
		for (tt=1;tt<=T;tt++) {
			for (hh=1;hh<=nhor+1;hh++) {
				vecirf[(hh-1)*K*K+1..hh*K*K,tt] = vec((irf[(hh-1)*K+1..hh*K,(tt-1)*K+1..tt*K])')
				vecirf_lb[(hh-1)*K*K+1..hh*K*K,tt] = vec((irf_lb[(hh-1)*K+1..hh*K,(tt-1)*K+1..tt*K])')
				vecirf_ub[(hh-1)*K*K+1..hh*K*K,tt] = vec((irf_ub[(hh-1)*K+1..hh*K,(tt-1)*K+1..tt*K])')
			}
		}
		
		result.irf = vecirf
		result.irf_lb = vecirf_lb
		result.irf_ub = vecirf_ub
		return(result)
	}
	
	real matrix vartvpirf(real matrix beta, real scalar K, real scalar cons, real scalar nhor) {
		real scalar T, q, p, tt, hh, k, kk
		real matrix irf, BB_path, alpha_path, logsig_path, BB_t, Atemp, A_path, Sigma_path, Sigmau_path, Hsd_now, diagonal_now, Hsd, BB_big_path, Sigmau_big_path, BB_big_H0_path, Sigmau_big_H0_path
		
		T = cols(beta); q = rows(beta); 
		p = (q - K * (K + 1) / 2) / (K * K) - cons / K
		irf = J((nhor+1)*K,K*T,0)
		BB_path = J(K,(K*p+cons)*T,0)
		for (tt=1;tt<=T;tt++) {
			beta_t = beta[1.. q-K*(K+1)/2,tt]
			BB_t = J(K, K*p+cons, 0)
			for (k=1;k<=K;k++) BB_t[k,.] = (beta_t[(k-1)*(K*p+cons)+1..k*(K*p+cons),.])'
			if (cons == 1) BB_t = (BB_t[.,K*p+1] , BB_t[.,1..K*p])
			BB_path[.,(tt-1)*(K*p+cons)+1..tt*(K*p+cons)] = BB_t
		}

		if (K > 1) alpha_path = beta[K*(K*p+cons)+1..K*(K*p+cons)+K*(K-1)/2,.]
		logsig_path = beta[K*(K*p+cons)+K*(K-1)/2+1..q,.]
		A_path = J(K,K*T,0); Sigma_path = J(K,K*T,0); Sigmau_path = J(K,K*T,0); Hsd = J(K,K*T,0)
		BB_big_path = J(K*p,(K*p+cons)*T,0)
// 		Sigmau_big_path = J(K*p,K*p*T,0)
		for (tt=1;tt<=T;tt++) {
			Atemp = I(K)
			ii = 1
			if (K > 1) {
				for (k=2;k<=K;k++) {
					for (kk=1;kk<=k-1;kk++) {
						Atemp[k,kk] = alpha_path[ii,tt]
						ii = ii + 1
					}
				}
			}
			A_path[.,(tt-1)*K+1..tt*K] = Atemp
			Sigma_path[.,(tt-1)*K+1..tt*K] = diag(exp(logsig_path[.,tt]))
			Sigmau_path[.,(tt-1)*K+1..tt*K] = pinv(Atemp) * Sigma_path[.,(tt-1)*K+1..tt*K] * Sigma_path[.,(tt-1)*K+1..tt*K] * (pinv(Atemp))'
			Hsd_now = cholesky(Sigmau_path[.,(tt-1)*K+1..tt*K])
			diagonal_now = diag(diagonal(Hsd_now))
			Hsd[.,(tt-1)*K+1..tt*K] = pinv(diagonal_now) * Hsd_now // Unit initial shock
			BB_big_path[.,(tt-1)*(K*p+cons)+1..tt*(K*p+cons)] = (BB_path[.,(tt-1)*(K*p+cons)+1..tt*(K*p+cons)] \ (J(K*(p-1),cons,0), I(K*(p-1)), J(K*(p-1),K,0)))
// 			Sigmau_big_path[.,(tt-1)*K*p+1..tt*K*p] = ((Sigmau_path[.,(tt-1)*K+1..tt*K], J(K,K*(p-1),0)) \ J(K*(p-1),K*p,0))
		}
		BB_big_H0_path = J((nhor+1)*K*p,(K*p+cons)*T,0)
		BB_big_H0_path[1..K*p,.] = BB_big_path
// 		Sigmau_big_H0_path = J((nhor+1)*K*p,K*p*T,0)
// 		Sigmau_big_H0_path[1..K*p,.] = Sigmau_big_path
		for (hh=2;hh<=nhor+1;hh++) {
			for (tt=hh;tt<=T;tt++) {
				if (cons == 1) BB_big_H0_path[(hh-1)*K*p+1..hh*K*p,(tt-1)*(K*p+cons)+1] = BB_big_path[.,(tt-1)*(K*p+cons)+cons+1..tt*(K*p+cons)] * BB_big_H0_path[(hh-2)*K*p+1..(hh-1)*K*p,(tt-2)*(K*p+cons)+1]
				BB_big_H0_path[(hh-1)*K*p+1..hh*K*p,(tt-1)*(K*p+cons)+cons+1..tt*(K*p+cons)] = BB_big_path[.,(tt-1)*(K*p+cons)+cons+1..tt*(K*p+cons)] * BB_big_H0_path[(hh-2)*K*p+1..(hh-1)*K*p,(tt-2)*(K*p+cons)+cons+1..(tt-1)*(K*p+cons)]
// 				Sigmau_big_H0_path[(hh-1)*K*p+1..hh*K*p,(tt-1)*K*p+1..tt*K*p] = Sigmau_big_path[.,(tt-1)*K*p+1..tt*K*p] + BB_big_path[.,(tt-1)*(K*p+cons)+cons+1..tt*(K*p+cons)] * Sigmau_big_H0_path[(hh-2)*K*p+1..(hh-1)*K*p,(tt-2)*K*p+1..(tt-1)*K*p] * (BB_big_path[.,(tt-1)*(K*p+cons)+cons+1..tt*(K*p+cons)])'
			}
		}
		irf[1..K,.] = Hsd
		for (hh=2;hh<=nhor+1;hh++) {
			for (tt=hh;tt<=T;tt++) {
				irf[(hh-1)*K+1..hh*K,(tt-1)*K+1..tt*K] = BB_big_H0_path[(hh-1)*K*p+1..(hh-1)*K*p+K,(tt-1)*(K*p+cons)+cons+1..(tt-1)*(K*p+cons)+cons+K] * Hsd[.,(tt-hh)*K+1..(tt-hh+1)*K]
			}
		}
		return(irf)
	}
	
	real matrix varirf(real matrix beta, real scalar K, real scalar cons, real scalar nhor, real scalar chol) {
		real scalar q, hh, k
		real matrix irf, vecirf, BB, alpha, logsig, A, Sigma, Sigmau, Hsd_now, diagonal_now, Hsd, BB_big, Sigmau_big, BB_big_H0, Sigmau_big_H0
		struct cholresult scalar result_chol
		
		q = rows(beta); p = (q - K * (K + 1) / 2) / (K * K) - cons / K
		irf = J((nhor+1)*K,K,0)
		
		BB = J(K, K*p+cons, 0)
		for (k=1;k<=K;k++) BB[k,.] = (beta[(k-1)*(K*p+cons)+1..k*(K*p+cons),.])'
		if (cons == 1) BB = (BB[.,K*p+1] , BB[.,1..K*p])
		
		if (chol == 1) {
			if (K > 1) alpha = beta[K*(K*p+cons)+1..K*(K*p+cons)+K*(K-1)/2]
			logsig = beta[K*(K*p+cons)+K*(K-1)/2+1..q]
			A = I(K)
			ii = 1
			if (K > 1) {
				for (k=2;k<=K;k++) {
					for (kk=1;kk<=k-1;kk++) {
						A[k,kk] = alpha[ii]
						ii = ii + 1
					}
				}
			}
			Sigma = diag(exp(logsig))
			Sigmau = pinv(A) * Sigma * Sigma * (pinv(A))'
		}
		else {
			Sigmau = invvech(beta[K*(K*p+cons)+1..q])
			result_chol = chol(Sigmau)
			if (K > 1) alpha = result_chol.o[1..K*(K-1)/2]
			logsig = result_chol.o[K*(K-1)/2+1..K*(K+1)/2]
			Sigma = diag(exp(logsig))
		}
		Hsd_now = cholesky(Sigmau)
		diagonal_now = diag(diagonal(Hsd_now))
		Hsd = pinv(diagonal_now) * Hsd_now // Unit initial shock
		BB_big = (BB \ (J(K*(p-1),cons,0), I(K*(p-1)), J(K*(p-1),K,0)))
// 		Sigmau_big = ((Sigmau, J(K,K*(p-1),0)) \ J(K*(p-1),K*p,0))
		BB_big_H0 = J((nhor+1)*K*p,K*p+cons,0)
		BB_big_H0[1..K*p,.] = BB_big
// 		Sigmau_big_H0 = J((nhor+1)*K*p,K*p,0)
// 		Sigmau_big_H0[1..K*p,.] = Sigmau_big
		for (hh=2;hh<=nhor+1;hh++) {
			if (cons == 1) BB_big_H0[(hh-1)*K*p+1..hh*K*p,1] = BB_big[.,cons+1..K*p+cons] * BB_big_H0[(hh-2)*K*p+1..(hh-1)*K*p,1]
			BB_big_H0[(hh-1)*K*p+1..hh*K*p,cons+1..K*p+cons] = BB_big[.,cons+1..K*p+cons] * BB_big_H0[(hh-2)*K*p+1..(hh-1)*K*p,cons+1..K*p+cons]
// 			Sigmau_big_H0_path[(hh-1)*K*p+1..hh*K*p,.] = Sigmau_big + BB_big[.,cons+1..K*p+cons] * Sigmau_big_H0[(hh-2)*K*p+1..(hh-1)*K*p,.] * (BB_big[.,cons+1..K*p+cons])'
		}
// 		Hsd = I(K)
		irf[1..K,.] = Hsd
		for (hh=2;hh<=nhor+1;hh++) {
			irf[(hh-1)*K+1..hh*K,.] = BB_big_H0[(hh-2)*K*p+1..(hh-2)*K*p+K,cons+1..cons+K] * Hsd
		}
		
		vecirf = J((nhor+1)*K*K,1,0)
		for (hh=1;hh<=nhor+1;hh++) vecirf[(hh-1)*K*K+1..hh*K*K,.] = vec((irf[(hh-1)*K+1..hh*K,1..K])')
		return(vecirf)
	}
	
	real matrix cum(real matrix y, real scalar h) {
		real scalar T, p, hh
		real matrix yy
		
		T = rows(y); p = cols(y)
		yy = J(T-h, p, 0)
		for (hh=0;hh<=h;hh++) yy = yy + y[hh+1..T-h+hh,.]
		
		return(yy)
	}

	real matrix sortvar(real matrix lags, real scalar K, real scalar cons) {
		real scalar P, p, l
		real matrix A, Atemp, Atemp2
		
		p = rows(lags); P = max(lags)
		A = J(P, p, 0)
		for (l=1;l<=p;l++) A[lags[l],l] = 1
		if (cons == 1) A = ((I(K) # A, J(K*P,1,0)) \ (J(1,K*p,0), 1))
		A = ((I(K) # A), J(K*(K*P+cons),K*(K+1)/2,0)) \ (J(K*(K+1)/2,K*(K*p+cons),0), I(K*(K+1)/2))
		return(A)
	}

	real matrix movmean(real scalar T, real scalar K) {
		real scalar k, sk, ek, dk
		real matrix A
		
		A = J(T,T,0)
		for (k=1;k<=T;k++) {
			sk = floor(max((1,k-(K-1)/2)))
			ek = floor(min((T,k+(K-1)/2)))
			dk = ek - sk + 1
			A[k,sk..ek] = J(1, dk, 1/dk)
		}
		return(A)
	}

	real matrix nws(real matrix g, real scalar nlag) {
		real scalar n, l, weight
		real matrix S
		
		n = rows(g)
		g = g - (J(n,1,1) # mean(g))
		S = g' * g
		for (l=1;l<=nlag;l++) {
			weight = 1 - l / (nlag + 1)
			S = S + weight * ((g[1..(n-l),.])' * g[(l+1)..n,.] + (g[(l+1)..n,.])' * g[1..(n-l),.])
		}
		S = S / n
		return(S)
	}
	
	real matrix cumprod(real matrix A) { // row cumprod
		real scalar N, i
		real matrix B
		
		N = rows(A)
		B = A
		if (N > 1) {
			for (i=2;i<=N;i++) {
				B[i,1] = B[i,1] * B[i-1,1]
			}
		}
		return(B)
	}
	
	real scalar prod(real matrix A) {
		real scalar prodA, N, i
		
		N = rows(A)
		prodA = 1
		for (i=1;i<=N;i++) {
			prodA = prodA * A[i,1]
		}
		return(prodA)
	}
	
	real matrix cumsum(A) { // col cumsum
		real scalar nA, i
		real matrix B
		
		nA = cols(A)
		B = A
		if (nA > 1) for (i=2;i<=nA;i++) B[.,i] = B[.,i-1] + A[.,i]
		return(B)
	}
	
	real matrix getDup(real scalar n) {
		real scalar m, nsq, r, a, i, j
		real matrix v, D
		
		m = n * (n + 1) / 2
		nsq = n * n
		r = 1
		a = 1
		v = J(1, nsq, 0)
		for (i=1;i<=n;i++) {
			if (i > 1) v[r..(r+i-2)] = J(1,i-1,i-n) + cumsum(J(1,i-1,n) - (0::(i-2))')
			r = r + i - 1
			v[r..(r+n-i)] = (a::(a + n - i))'
			r = r + n - i + 1
			a = a + n - i + 1
		}
		D = J(nsq, m, 0)
		for (i=1;i<=nsq;i++) D[i,v[i]] = 1
		return(D)
	}
	
	struct Dlogresult scalar Dloglik_t_multi(real matrix yt, real matrix Xtp, real matrix Bt, real matrix Sigmau) {
		real scalar K
		real matrix D, ld_omega, invSigmau
		struct Dlogresult scalar result
		
		K = rows(yt)
		D = getDup(K)
		invSigmau = pinv(Sigmau)
		
		result.l = - K / 2 * log(pi()) - 1 / 2 * log(det(Sigmau)) - 1 / 2 * (yt - Xtp * Bt)' * invSigmau * (yt - Xtp * Bt)
		result.ld_B = Xtp' * pinv(Sigmau) * (yt - Xtp * Bt)
		ld_omega = - 1 / 2 * invSigmau + 1 / 2 * invSigmau * (yt - Xtp * Bt) * (yt - Xtp * Bt)' * invSigmau
		result.ld_o_r = D' * vec(ld_omega)
		result.ld_o = D * result.ld_o_r
		result.ld_BB = - Xtp' * invSigmau * Xtp
		result.ld_oo_r = D' * (invSigmau # (1 / 2 * invSigmau - invSigmau * (yt - Xtp * Bt) * (yt - Xtp * Bt)' * invSigmau)) * D
		result.ld_oo = D * result.ld_oo_r * D'
		result.ld_oB_r = - D' * ((invSigmau * (yt - Xtp * Bt)) # invSigmau) * Xtp
		return(result)
	}
	
	struct Dlogresult scalar Dloglik_t_multi_chol(real matrix yt, real matrix Xpt, real matrix Bt, real matrix Sigmaut) {
		real scalar K, M, k, kk, mm, nn, i, rowpos, colpos, lt, ii, jj
		real matrix temp, Sigmat, At, ut, ld_B, ld_A, ld_a, ld_l, ld_BB, ld_Ba, ld_Bl, ld_aa, ld_al, ld_ll, temp_Bl, ld_BA_mm
		struct Dlogresult scalar result
		
		// get dimensions
		K = rows(yt)
		M = cols(Xpt)

		// Cholesky parameterization: At * Sigmaut * At' = Sigmat * Sigmat'
		temp = (cholesky(Sigmaut))'
		Sigmat = diag(temp)
		temp = pinv(pinv(Sigmat) * temp) - I(K)
		At = I(K)
		if (K > 1) for (k=1;k<=K-1;k++) for (kk=k+1;kk<=K;kk++) At[kk,k] = temp[k,kk]
		
		// log likelihood
		ut = yt - Xpt * Bt
		lt = -K/2 * log(2*pi()) - 1/2 * log(det(Sigmaut)) - 1/2 * ut' * pinv(Sigmaut) * ut

		// first order derivatives
		ld_B = Xpt' * pinv(Sigmaut) * ut
		ld_A = - pinv(Sigmat) * pinv(Sigmat) * At * ut * ut'
		ld_a = 0
		i = 0
		if (K > 1) {
			ld_a = J(K*(K-1)/2,1,0)
			for (k=1;k<=K-1;k++) {
				for (kk=k+1;kk<=K;kk++) {
					i = i + 1
					ld_a[i,1] = ld_A[kk,k]
				} 
			}
		}
		ld_l = J(K,1,-1) + (diagonal(Sigmat):^(-2)) :* ((At * ut):^2)
		
		// second order derivatives
		ld_Bl = J(M,K,1)
		ld_ll = J(K,K,1)
		ld_Ba = 0
		ld_aa = 0
		ld_al = 0
		if (K > 1) {
			ld_Ba  = J(M,K*(K-1)/2,0)
			ld_aa = J(K*(K-1)/2,K*(K-1)/2,0)
			ld_al = J(K*(K-1)/2,K,0)
		}
		ld_BB = - Xpt' * pinv(Sigmaut) * Xpt
		ld_ll = diag(- 2 * (ld_l + J(K,1,1)))
		temp_Bl = - 2 * Xpt' * At'
		for (mm=1;mm<=M;mm++) {
			ld_Bl[mm,.] = ((temp_Bl[mm,.])' :* ((pinv(Sigmat))' * pinv(Sigmat) * At * ut))'
			if (K > 1) {
				ld_BA_mm = (pinv(Sigmat))' * pinv(Sigmat) * At * (Xpt[.,mm] * ut' + ut * (Xpt[.,mm])')
				i = 0
				for (k=1;k<=K-1;k++) {
					for (kk=k+1;kk<=K;kk++) {
						i = i + 1
						ld_Ba[mm,i] = ld_BA_mm[kk,k]
					} 
				}
			}
		}
		
		if (K > 1) {
			rowpos = 0
			for (ii=2;ii<=K;ii++) {
				for (jj=1;jj<=ii-1;jj++) {
					rowpos = rowpos + 1
					colpos = 0
					ld_al[rowpos,ii] = 2 * ld_A[ii,jj]
					for (mm=2;mm<=K;mm++) {
						for (nn=1;nn<=mm-1;nn++) {
							colpos = colpos + 1
							if ((mm == ii) & (nn <= ii)) {
								ld_aa[rowpos,colpos] = - (Sigmat[ii,ii])^(-2) * ut[jj,1] * ut[nn,1]
							}
						}
					}
				}
			}
		}
		
		// store results
		result.l = lt
		result.ld_B = ld_B
		result.ld_A = ld_A
        result.ld_a = ld_a
        result.ld_l = ld_l
        result.ld_BB = ld_BB
        result.ld_Ba = ld_Ba
		result.ld_Bl = ld_Bl
        result.ld_aa = ld_aa
        result.ld_al = ld_al
        result.ld_ll = ld_ll
		if (K > 1) result.ld_o_r = (ld_a \ ld_l)
		else result.ld_o_r = ld_l
		if (K > 1) result.ld_oB_r = (ld_Ba, ld_Bl)'
		else result.ld_oB_r = ld_Bl'
		if (K > 1) result.ld_oo_r = ((ld_aa, ld_al) \ (ld_al', ld_ll))
		else result.ld_oo_r = ld_ll
		return(result)
	}
end
