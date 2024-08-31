*! Version 1.0 2006.10.20
*! Author: Lian Yu-Jun 
*! E-mail: arlionn@163.com

cap program drop SFA2tier_sigs
program define SFA2tier_sigs, rclass
version 8.2
   if e(title) == "Two-tier SFA Model (2TSFA) : HOMO"{
      local _sigv = exp([sigma_v]_cons)
      local _sigu = exp([sigma_u]_cons)
      local _sigw = exp([sigma_w]_cons)
   }
   else{
      local _sigv = exp([sigma_v]_cons)
      qui predict _sigu if e(sample), eq(sigma_u)
      qui replace _sigu = exp(_sigu)
      qui sum _sigu
      local _sigu = r(mean)
      qui predict _sigw if e(sample), eq(sigma_w)
      qui replace _sigw = exp(_sigw)
      qui sum _sigw
      local _sigw = r(mean) 
   }
      local uw_diff   = `_sigu' - `_sigw'
      local sigs_sum  = `_sigv'^2 + `_sigu'^2 + `_sigw'^2
      local sigs_uw_r = (`_sigu'^2 + `_sigw'^2)/`sigs_sum'
      local sigs_u_r  = `_sigu'^2/(`_sigu'^2 + `_sigw'^2) 
      local sigs_w_r  = 1 - `sigs_u_r'

      dis
      dis in g "               Variance Estimation          " 
      dis in g in smcl "{hline 47}"
      dis in g "sigma_u    : " _col(20) in y %6.4f `_sigu' 
      dis in g "sigma_w    : " _col(20) in y %6.4f `_sigw'
      dis in g "sigma_v    : " _col(20) in y %6.4f `_sigv'
      dis in g "sigma_u_sq : " _col(20) in y %6.4f `_sigu'^2 
      dis in g "sigma_w_sq : " _col(20) in y %6.4f `_sigw'^2 
      dis in g "sigma_v_sq : " _col(20) in y %6.4f `_sigv'^2       
      dis in g in smcl "{hline 47}"      
      dis in g "               Variance Analysis          " 
      dis in g in smcl "{hline 47}"
      dis in g "Total sigma_sqs     : " _col(20) in y %6.4f `sigs_sum'
      dis in g "(sigu2+sigw2)/Total : " _col(20) in y %6.4f `sigs_uw_r'
      dis in g "sigu2/(sigu2+sigw2) : " _col(20) in y %6.4f `sigs_u_r' 
      dis in g "sigw2/(sigu2+sigw2) : " _col(20) in y %6.4f `sigs_w_r'
      dis in g "sig_u - sig_w       : " _col(20) in y %6.4f `uw_diff'
      dis in g in smcl "{hline 47}"  
      
      return scalar sigma_u = `_sigu'
      return scalar sigma_w = `_sigw'
      return scalar sigma_v = `_sigv'
      return scalar sigma_u_sq = `_sigu'^2
      return scalar sigma_w_sq = `_sigw'^2
      return scalar sigma_v_sq = `_sigv'^2
      return scalar totoal_sigma_sq = `sigs_sum'
      
end
