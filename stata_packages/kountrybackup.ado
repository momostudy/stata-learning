program define kountrybackup
version 8.2
   syntax [, replace]
   if "`replace'" == "replace" {
      quietly copy `c(sysdir_plus)'k/k_other_extras.txt `c(sysdir_plus)'k/k_other_extras.bak, text replace
      di
      di in green "A backup copy of your country names dictionary is located at:"
      di in yellow "`c(sysdir_plus)'k/k_other_extras.bak"
      di
   }
   else {
      quietly copy `c(sysdir_plus)'k/k_other_extras.txt `c(sysdir_plus)'k/k_other_extras.bak, text
      di
      di in green "A backup copy of your country names dictionary is located at:"
      di in yellow "`c(sysdir_plus)'k/k_other_extras.bak"
      di
   }
   
end
exit
