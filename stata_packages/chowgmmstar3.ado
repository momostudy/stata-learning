
capture program drop chowgmmstar3
program chowgmmstar3, rclass

version 14.1

args y x z w t heter hac

    local T = rowsof(`x')
	local p = colsof(`x')
	local q = colsof(`z')
	local pi = `t'/`T'
	local k = colsof(`w')
	
	mat y1 = `y'[1..`t',1...]
	mat x1 = `x'[1..`t',1...]
	mat z1 = `z'[1..`t',1...]
	mat w1 = `w'[1..`t',1...]
	mat y2 = `y'[`t'+1..`T',1...]
	mat x2 = `x'[`t'+1..`T',1...]
	mat z2 = `z'[`t'+1..`T',1...]
	mat w2 = `w'[`t'+1..`T',1...]
	
	mat y = `y'
	mat X = x1, J(`t',`p',0), z1\ J(`T'-`t',`p',0), x2, z2
	mat W = w1, J(`t',`k',0)\ J(`T'-`t',`k',0), w2
	
	svmat y, names(yy)
	svmat X, names(XX)
	svmat W, names(WW)

	gen time_chowgmmstar = _n
    tsset time_chowgmmstar
 
    if "`hac'" != "0" {
	    gmm (yy1-{xb:XX1-XX`=colsof(X)'}), instruments(WW1-WW`=colsof(W)', noconstant) wmatrix(hac nw `hac')			
	    }
    else {
	if `heter' == 0 {
	    gmm (yy1-{xb:XX1-XX`=colsof(X)'}), instruments(WW1-WW`=colsof(W)', noconstant) onestep
		}
	if `heter' == 1 {
	    gmm (yy1-{xb:XX1-XX`=colsof(X)'}), instruments(WW1-WW`=colsof(W)', noconstant) twostep
		}
	}
	
	mat b = e(b)'
	mat b1 = b[1..`p',1...]
	mat b2 = b[`p'+1..2*`p',1...]
	if "`e(scorevers)'" != "" {
		* predict changed syntax behavior in 14.2
		local residuals residuals
	}
	predict ee if e(sample), `residuals'
	mkmat ee
	mat ee2 = hadamard(ee,ee)	
	
	drop ee yy1 XX1-XX`=colsof(X)' WW1-WW`=colsof(W)' time_chowgmmstar

	if "`hac'" != "0" {
	    mat SS = e(S)
		mat Sigma1 = SS[1..`k',1..`k']*`T'/(`t')
		mat Sigma2 = SS[`k'+1...,`k'+1...]*`T'/(`T'-`t')	
	}
	else {
	if `heter' == 0 {
	    mat s2 = (J(1,rowsof(y),1)*ee2[1..`T',1])/(`T')		
		mat Sigma1 = s2[1,1]*w1'*w1/`t'
		mat Sigma2 = s2[1,1]*w2'*w2/(`T'-`t')	
	    }
	if `heter' == 1 {
	    mat Sigma1 = w1'*diag(ee2[1..`t',1])*w1/`t'
		mat Sigma2 = w2'*diag(ee2[`t'+1..`T',1])*w2/(`T'-`t')		
		mat SS = e(S)
	    }
	}	
	
	mat draft = `pi'*Sigma1,J(`k',`k',0)\ J(`k',`k',0),(1-`pi')*Sigma2
	mat Gamma = inv(draft)
	mat Swx1 = w1'*x1/`T'
	mat Swz1 = w1'*z1/`T'
	mat Swx2 = w2'*x2/`T'
	mat Swz2 = w2'*z2/`T'
	mat M = Swx1,J(`k',`p',0),Swz1\ J(`k',`p',0),Swx2,Swz2
	mat R = I(`p'),-I(`p'),J(`p',`q',0)\ `pi'*I(`p'),(1-`pi')*I(`p'),J(`p',`q',0)
	mat VRb = R*inv(M'*Gamma*M)*R'
	mat wald = `T'*(b1-b2\ `pi'*b1+(1-`pi')*b2)'*(inv(VRb))*(b1-b2\ `pi'*b1+(1-`pi')*b2)

return scalar result_chowgmmstar = wald[1,1]

end



