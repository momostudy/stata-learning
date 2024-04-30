
capture program drop helm
program define helm
*
* This program will do Helmert transformation for a list of variables
* NOTE:  must have variables named id, year   
* to use enter >> helm var1 var2...
* new variables will be names with h_ in front h_var1  and so on
*
qui while "`1'"~="" {
gsort id -year                /*sort years descending */
tempvar one sum n m w 
* capture drop h_`1'         /* IF the variable exist - it will remain and not generated again */
gen `one'=1 if `1'~=.             /*generate one if x is nonmissing */
qui by id: gen `sum'=sum(`1')-`1' /*running sum without current element */
qui by id: gen `n'=sum(`one')-1     /*number of obs included in the sum */
replace `n'=. if `n'<=0             /* n=0 for last observation and =-1 if
                                   last observation is missing*/
gen `m'=`sum'/`n'                 /* m is forward mean of variable x*/
gen `w'=sqrt(`n'/(`n'+1))         /* weight on mean difference */
capture gen h_`1'=`w'*(`1'-`m')             /* transformed variable */ 
sort id year
mac shift
}
end

