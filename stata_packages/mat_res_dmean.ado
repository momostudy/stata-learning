*! version 3.0 13Mar2017 
*! by Hung-Jen Wang and Chia-Wen Ho
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw


capture program  drop mat_res_dmean
program define mat_res_dmean

                version 9.0
                syntax [if] [in],   NOFFIRM(string)  ID(varname) EPSIlon(varname)  HFUN(varname) /* [if] [in] */

                marksample touse

                local noff = `noffirm'


                mata: matcacul4( "`id'", "`epsilon'", "`hfun'", "`touse'")
                matrix m1=r(m1)
                matrix m2=r(m2)
                matrix m3=r(m3)
        end


version 9.0

mata:
void matcacul4( string scalar m_id, string scalar m_ep, string scalar m_h, string scalar touse )
    {
     N_firm = strtoreal(st_local("noff"))
     mepsi= st_data(.,(m_ep),touse)
     mh   = st_data(.,(m_h),touse)
     ifirm= st_data(.,(m_id),touse)
     info=panelsetup(ifirm,1)
     m1 = J(N_firm,1,0)
     m2 = J(N_firm,1,0)
     m3 = J(N_firm,1,0)

 for(qq=1;qq<=rows(info);qq++) {

     mepsi_i = panelsubmatrix(mepsi,qq,info)
     mh_i    = panelsubmatrix(mh,qq,info)
     n  = info[qq,2]-info[qq,1]+1
     string scalar key1
     key1 = strofreal(n)
     sigma_inv = st_matrix("sigma_inv" + key1)

     m1[qq,1]   = (mepsi_i)'* sigma_inv * (mh_i)
     m2[qq,1]   = (mh_i)'* sigma_inv * (mh_i)
     m3[qq,1]   = (mepsi_i)' * sigma_inv* (mepsi_i)


        }
     st_matrix("r(m1)",m1)
     st_matrix("r(m2)",m2)
     st_matrix("r(m3)",m3)
     }
     end
