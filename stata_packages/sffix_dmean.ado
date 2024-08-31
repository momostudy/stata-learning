*! version 3.0 13Mar2017 
*! by Hung-Jen Wang and Chia-Wen Ho
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw


capture program drop sffix_dmean
program define sffix_dmean

version 11
args todo b lnf

tempvar  xb  zd  zd2  last   num   meanz   zLd  zLd2
tempvar   mu_star sigma2_star  lnlsub mu sigma_uc  sigma_vc dif
tempname  sigma_u  sigma_v   uni  m1 m2  m3  s1  s2  s3  mepsi  mh

mleval `xb'          = `b'    ,       eq(1)
mleval `zd'          = `b'    ,       eq(2)
mleval `sigma_vc'    = `b'    ,       eq(3)  scalar

if $h_dist == 1 {
  scalar `mu'        = 0
  mleval `sigma_uc'  = `b'    ,       eq(4)  scalar
}
else {
  mleval `mu'        = `b'    ,       eq(4)  scalar
  mleval `sigma_uc'  = `b'    ,       eq(5)  scalar
}



scalar   `sigma_v'   =     exp(0.5*(`sigma_vc'))
scalar   `sigma_u'   =     exp(0.5*(`sigma_uc'))

quie gen double `zd2'   =    exp(`zd')



tempvar id time


quie egen double `id'   = group($MY_panel)
quie egen double `time' = group($MY_time)



************************************************  count Ti by firm
sort `id' `time'
quie by `id' : gen `last'= 1 if (_n==_N)
quie by `id' : egen `num'= count(`id')

************************************************* total_firms
quie sum `id'
local N_firm=r(max)
*************************************************  put  unique Ti into  matrix uni
sort `num'
quie gen  double  `dif'=`num'[_n]-`num'[_n-1]
mkmat  `num'   if   `dif'!=0  ,  mat(`uni')
local total_sigma= rowsof(`uni')
sort `id' `time'

* set trace on

*************************************************  def sigma with unique  Ti
  forvalues x = 1 /`total_sigma'   {
  local    ti =`uni'[`x',1]
  matrix   sigma1`ti'   = J(`ti',`ti',(`sigma_v')^2*(-1/(`ti')))
  matrix   sigma2`ti'   = I(`ti')*((`sigma_v')^2)
  matrix sigma`ti'=sigma1`ti'+sigma2`ti'


  mata: ha = st_matrix("sigma`ti'")
  mata: tmp1 = pinv(ha)
  mata: st_matrix("sigma_inv`ti'", tmp1)

}

**************************************************def : epsi  and   h

tempvar epsi h meanz

sort `id' `time'
quie by `id': egen double `meanz' = mean(`zd2')
quie gen double `epsi' =  $ML_y1 - `xb'

  if $PorC == 2 { /* cost frontier */
   quie replace `epsi' = -(`epsi')
   }

quie gen double `h' = `zd2' - `meanz'

*************************************************calculate lnL by firm


mat_res_dmean,  noffirm(`N_firm') id(`id') epsilon(`epsi')  hfun(`h')


capture drop s1v1 s2v1 s3v1
tempvar s1vv s2vv s3vv

tempvar tem1
sort `id' `time'
quie by `id': gen `tem1' = 1 if _n == 1
sort `tem1' `id'
svmat double m1, names(s1v)
svmat double m2, names(s2v)
svmat double m3, names(s3v)


sort `id' `time'
quie by `id': egen double `s1vv' = mean(s1v1)
quie by `id': egen double `s2vv' = mean(s2v1)
quie by `id': egen double `s3vv' = mean(s3v1)



quie gen double  `sigma2_star' =  1/((`s2vv')+(1/(`sigma_u')^2))

* sum `sigma2_star'

quie gen double  `mu_star'     =  (((`mu')/((`sigma_u')^2)) - `s1vv')* (`sigma2_star')
quie gen double  `lnlsub'      =  -(`num'-1)*log((`sigma_v'))-0.5* (`num' -1)* log(2*c(pi)) /* /* note: the preceding term of 2*c(pi) is changed from num to num-1; not sure */
                                */ - 0.5* (`s3vv')+ 0.5* ((`mu_star')^2/(`sigma2_star')) /*
                                */ - 0.5* ((`mu'/`sigma_u')^2) + 0.5* log(`sigma2_star') /*
                                */ - 0.5* log((`sigma_u')^2)+ lnnormal((`mu_star')/sqrt(`sigma2_star'))- lnnormal((`mu')/(`sigma_u'))

capture drop s1v1 s2v1 s3v1

*****************************************************Sum of lnL

mlsum `lnf'=  `lnlsub'   if   `last'  ==1




end
