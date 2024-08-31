** To calculate the inefficiency in 2TSFA model
** Refs: []Kumbhakar05a
** 2006.6.18

program define SFA2tier_eff
version 8.2

    tempvar yhat ehat
    predict double `yhat' if e(sample)
    gen double `ehat' = `e(depvar)' - `yhat' if e(sample)

   if e(title) == "Two-tier SFA Model (2TSFA) : HOMO"{
      local sig_u = exp([sigma_u]_cons)
      local sig_w = exp([sigma_w]_cons)
      local sig_v = exp([sigma_v]_cons)
      local lamda  = 1/`sig_u' + 1/`sig_w'
      local lamda1 = 1/`lamda'
      local lamda2 = `lamda'/(1+`lamda')
   }
   else{
      tempvar sig_u sig_w lamda lamda1 lamda2
      local sig_v = exp([sigma_v]_cons)
      qui predict `sig_u' if e(sample), eq(sigma_u) 
      qui replace `sig_u' = exp(`sig_u') if e(sample)
      qui predict `sig_w' if e(sample) , eq(sigma_w)
      qui replace `sig_w' = exp(`sig_w')
      gen double `lamda'  = 1/`sig_u' + 1/`sig_w'
      gen double `lamda1' = 1/`lamda'
      gen double `lamda2' = `lamda'/(1+`lamda')
   }


tempvar aa bb betahat etahat Eta1 Eta2
qui gen double `aa'      =  `ehat'/`sig_u' + `sig_v'^2/(2*`sig_u'^2)
qui gen double `bb'      =  `ehat'/`sig_v' - `sig_v'/`sig_w'
qui gen double `etahat'  =  (0.5*`sig_v'^2)/(`sig_w'^2) - `ehat'/`sig_w'
qui gen double `betahat' = - `ehat'/`sig_v' - `sig_v'/`sig_u' 
qui gen double `Eta1'    = norm(`bb') + exp(`aa' - `etahat')*norm(`betahat')
qui gen double `Eta2'    = exp(`etahat' - `aa')*`Eta1'


tempvar pp2 pp3
qui gen double `pp2' = normden(-`betahat') + `betahat'*norm(`betahat')
qui gen double `pp3' = normden(-`bb') + `bb'*norm(`bb')

qui gen double u_hat = `lamda1' + (`sig_v'*`pp2')/`Eta2'            /*E(u_i | epselon_i)*/ 
qui gen double w_hat = `lamda1' + (`sig_v'*`pp3')/`Eta1'            /*E(w_i | epselon_i)*/
qui gen double uw_diff = u_hat - w_hat


tempvar qq1 qq2 qq3 qq4 
qui gen double `qq1' = `sig_v'^2/2 - `sig_v'*`betahat'
qui gen double `qq2' = norm(`bb') + exp(`aa' - `etahat')*exp(`qq1')*norm(`betahat' - `sig_v')
qui gen double `qq3' = `sig_v'^2/2 - `sig_v'*`bb'
qui gen double `qq4' = norm(`betahat') + exp(`etahat' - `aa')*exp(`qq3')*norm(`bb' - `sig_v')

qui gen double u_hat_exp = 1 - `lamda2'*`qq2'/`Eta1'      /*E(1-e^{-u} | epselon)*/
qui gen double w_hat_exp = 1 - `lamda2'*`qq4'/`Eta2'      /*E(1-e^{-w} | epselon)*/
qui gen double uw_diff_exp = u_hat_exp - w_hat_exp        /*E(e^{-w}-e^{-u}) | epselon*/ 
qui gen double uw_diff_exp2= 1 - (1-u_hat_exp)/(1-w_hat_exp)  /*E[e^{w-u}-1], see KP05b, pp.16*/

sum *hat_exp uw_diff_exp
sum uw_diff_exp* ,de

end
