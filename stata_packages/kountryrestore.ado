program define kountryrestore
version 8.2
   
   capture confirm file `c(sysdir_plus)'k/k_other_extras.bak
   if _rc {
      di
      di in red "Nothing to restore, most probably you did not use {help kountrybackup:kountrybackup} in the first place."
      di
      exit
   }
   
   quietly copy `c(sysdir_plus)'k/k_other_extras.bak `c(sysdir_plus)'k/k_other_extras.txt, text replace
   quietly copy `c(sysdir_plus)'k/k_other_extras.bak `c(sysdir_plus)'k/k_other_extras.ado, text replace
   
   capture file close extrasado
   file open extrasado using `c(sysdir_plus)'k/k_other_extras.ado, write text append
   file write extrasado _n
   file write extrasado "end" _n
   file write extrasado "exit" _n
   file close extrasado
   discard
   
   di
   di in green "A previous version of k_other_extras.txt has been restored"
   di
   
end
exit
