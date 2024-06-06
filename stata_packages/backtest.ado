  ** mvport package v2
  * backtest command 
  * Author: Alberto Dorantes, July, 2016
  * cdorante@itesm.mx
capture program drop backtest
program define backtest, rclass
version 11.0
syntax varlist(numeric) [if] [in], Weights(string)
tempname numvariables HRS HRPORT W i
marksample touse 
local numvariables: word count `varlist'
capture matrix `W' = `weights'
if (_rc!=0) {
	    display as error "The weight Matrix `weights' does not exist; define a Stata Matrix for the portfolio weights"
	    exit
}
else if (rowsof(`weights')!=`numvariables' | colsof(`weights')!=1) {
	    display as error "The weight Matrix must have 1 column and the number of rows has to be equal to the number of assets of the portfolio"
		exit
}

  qui holdingrets `varlist' if `touse'
  matrix `HRS'=r(holdingrets)
  matrix `HRPORT'=`weights''*`HRS'
  matrix colnames `weights' = "Weight"
  display "It was assumed that the dataset is sorted chronologically"
  display "The holding return of the portfolio is " `HRPORT'[1,1]
  display r(N) " observations/periods were used for the calculation (casewise deletion was applied)" 
  display "The holding return of each price variable for the specified period was:"
  matlist `HRS', rowtitle(Price variable) noblank twidth(30) border
  display "The portfolio weights used were: " 
  matlist `weights', rowtitle(Asset) noblank twidth(30) border
  return scalar retport=`HRPORT'[1,1]
  return scalar N=r(N)
end

