Graph CUSUM and CUSUM squared
-----------------------------

	^cusum9^ varlist [^, noc^onstant ^d^ate(varname) ^nop^lot  other-options]

Description
-----------

^cusum9^ calculates and graphs the cumulative sums (CUSUM) of the recursive
residuals and their squares from the regression specified by "varlist".  Each
graph includes a 95 percent confidence band. This is an updated version of 
^cusum6^, which used the pre-version 8 Stata graphics.

^cusum9^ is for use with time series data.

Options
-------

^noc^onstant eliminates the constant from the regressions.

^nop^lot suppresses the graphs.


Other options
-------------

The CUSUM statistics and the confidence bands can be stored for later use.
The options for storing these variables are

    CUSUM information
    -----------------

    ^rr^(varname) stores the recursive residuals.
    
    ^c^s(varname) stores the CUSUM.

    ^l^w(varname) stores the lower limit of the confidence band.

    ^u^w(varname) stores the upper limit of the confidence bankd.


    CUSUM of squares information
    ----------------------------

    ^c^s2(varname) stores the CUSUM of squares.

    ^lww^(varname) stores the lower limit of the confidence band.

    ^s^qline(varname) stores the reference line.

    ^uww^(varname) stores the upper limit of the confidence band.


Examples
--------
	 . webuse wpi1
     . cusum9 wpi L.wpi L2.wpi
     . cusum9 wpi L.wpi L2.wpi, cs(cusum) cs2(cusum2) noplot
     . cusum9 ln_wpi L(1/4).ln_wpi
     
References
----------

Brown, R.L., J. Durbin, and J.M. Evans (1975). "Techniques for testing the
  constancy of regression relationships over time (with discussion)," ^Journal^
  ^of the Royal Statistical Society^. Series B, Volume 37, pp. 149-192.

Harvey, A.C. (1990).  ^The Econometric Analysis of Time Series^.  MIT Press.


Author
------
Sean Becketti (original version), November 1993, STB-24 sts7_6
Modified for Stata 9 by Christopher F Baum (baum@@bc.edu), September 2020
