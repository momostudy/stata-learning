{smcl}
{* *! version 0.9 June 2009}{...}
{cmd:help bayerhanck}
{hline}

{title:Title}

bayerhanck -- Test for Non-Cointegration

{title:Syntax}

{cmd:bayerhanck} LHSvar {ifin} {cmd:,} rhs(RHSvarlist) [{it:options}]

{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:Model}
{synopt :{opt l:ags(#)}}use {it:#} for the maximum number of augmentation lags (>=0), default is 1 {p_end}
{synopt :{opt t:rend}{cmd:(}{opt constant}{cmd:)}}include an unrestricted constant in model; the default{p_end}
{synopt :{opt t:rend}{cmd:(}{opt trend}{cmd:)}}include a linear trend in the
  cointegrating equations and a quadratic trend in the undifferenced data{p_end}
{synopt :{opt t:rend}{cmd:(}{opt none}{cmd:)}}do not include a trend or a constant{p_end}

{syntab:Reporting}
{synopt :{opt c:rit}{cmd:(}{opt 1 | 5 | 10}{cmd:)}} Level-alpha in % for the critical value of the test to be reported{p_end}

{hline}

{title:Description}

{pstd}
{cmd:bayerhanck} produces a joint test-statistic for the null of no-cointegration based on 
Engle-Granger, Johansen maximum eigenvalue, Boswijk, and Banerjee tests (see Bayer and Hanck, 2009,
for details).


{title:Saved results}

{pstd}

{cmd:bayerhanck} saves the following in {cmd:e()}:

{synoptset 17 tabbed}{...}
{p2col 5 17 21 2: Scalars}{p_end}
{synopt:{cmd:e(EJ) }} test statistics based on Engle-Granger and Johansen tests{p_end}
{synopt:{cmd:e(BECREJ)}} test statistics based on all four tests{p_end}
{synopt:{cmd:e(CRIT_EJ) }} critical value for the test statistics based on Engle-Granger and Johansen tests{p_end}
{synopt:{cmd:e(CRIT_BECREJ)}} critical value for the test statistics based on all four tests{p_end}

{p2col 5 17 21 2: Matrices}{p_end}
{synopt:{cmd:e(STAT) }} test statistics of all four underlying tests{p_end}
{synopt:{cmd:e(PV) }} corresponding p-values{p_end}

{title:Examples}

{pstd} {it:Example 1: (underlying tests produce conflicting results)}{p_end}

{pstd}Setup{p_end}
{phang2}{cmd:. webuse lutkepohl}{p_end}

{pstd}Test for non-cointegration {p_end}
{phang2}{cmd:. bayerhanck  linvestment, rhs(lincome lconsumption)}{p_end}


{pstd}Same as above, but use 4 lags in the underlying VECM
model{p_end}
{phang2}{cmd:. bayerhanck  linvestment, rhs(lincome lconsumption) lags(4)}{p_end}

{pstd}Same as above, but report 10% critical values instead of 5%{p_end}
{phang2}{cmd:. bayerhanck y, rhs(i c) lags(4) crit(10)}{p_end}


{pstd} {it:Example 2: Monte Carlo Study}{p_end}

{phang2}{cmd:	clear all}{p_end}
{phang2}{cmd:	set more off}{p_end}
{phang2}{cmd:	set matsize 100}{p_end}
{phang2}{cmd:	local rep=100}{p_end}
{phang2}{cmd:	mat def testPower=J(`rep',2,999)} {p_end}
{phang2}{cmd:	mat def testSize=J(`rep',2,999)}{p_end}
{phang2}{cmd:	forv z=1/`rep'} {{p_end}
{phang3}{cmd:		clear }{p_end}
{phang3}{cmd:		qui } {{p_end}
{phang3}{cmd:			set obs 400	}{p_end}
{phang3}{cmd:			gen dx=rnormal()}{p_end}
{phang3}{cmd:			gen x=sum(dx)+50 }{p_end}
{phang3}{cmd:			forv j=1/5 } {{p_end}
{phang3}{cmd:				gen dz`j'=rnormal()}{p_end}
{phang3}{cmd:				gen z`j'=sum(dz`j')}{p_end}
{phang3}			}{p_end}
{phang3}{cmd:			gen T=_n}{p_end}
{phang3}{cmd:			tsset T}{p_end}
{phang3}{cmd:			gen u=rnormal()}{p_end}
{phang3}{cmd:			replace u=u+0.95*l.u if T>1}{p_end}
{phang3}{cmd:			gen y=x+u}{p_end}
{phang3}{cmd:			drop if T<200}{p_end}
{phang3}{cmd:			replace x=x+T}{p_end}	
{phang3}{cmd:			di "Power Example"}{p_end}
{phang3}{cmd:			bayerhanck x, rhs(y) trend(trend) lags(1)}{p_end}
{phang3}{cmd:			mat testPower[`z',1]=`e(EJ)'}{p_end}
{phang3}{cmd:			mat testPower[`z',2]=`e(BECREJ)'}{p_end}
{phang3}{cmd:			di "Size Example"}{p_end}
{phang3}{cmd:			bayerhanck x, rhs(z*) trend(trend) lags(1) crit(10)}{p_end}
{phang3}{cmd:			mat testSize[`z',1]=`e(EJ)'}{p_end}
{phang3}{cmd:			mat testSize[`z',2]=`e(BECREJ)'}{p_end}
{phang3}		}{p_end}
{phang2}	}{p_end}
{phang2}{cmd:	ereturn list }{p_end}
{phang2}{cmd:	svmat testPower }{p_end}
{phang2}{cmd:	svmat testSize }{p_end}
{phang2}{cmd:	keep test* }{p_end}
{phang2}{cmd:	drop if testPower1==. }{p_end}
{phang2}{cmd:	count if testSize1>e(CRIT_EJ) }{p_end}
{phang2}{cmd:	count if testSize2>e(CRIT_BECREJ) }{p_end}
{phang2}{cmd:	count if testPower1>e(CRIT_EJ) }{p_end}
{phang2}{cmd:	count if testPower2>e(CRIT_BECREJ) }{p_end}


{title:Also see}

{psee}
Bayer, Christian and Christoph Hanck: "Combining Non-Cointegration tests", METEOR RM/09/012, University of Maastricht.

{title:Installation Files}
{phang2}bayerhanck.ado{p_end}
{phang2}NullDistr.dta{p_end}
{phang2}bayerhanck.sthlp{p_end}
