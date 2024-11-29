{smcl}
{* *! version 1.0.0  03may2013}{...}

{vieweralsosee "returnsyh" "help returnsyh"}{...}
{vieweralsosee "meanrets" "help meanrets"}{...}
{vieweralsosee "varrets" "help varrets"}{...}
{vieweralsosee "efrontier" "help efrontier"}{...}
{vieweralsosee "gmvport" "help gmvport"}{...}
{vieweralsosee "mvport" "help mvport"}{...}
{vieweralsosee "ovport" "help ovport"}{...}
{vieweralsosee "simport" "help simport"}{...}
{vieweralsosee "holdingrets" "help holdingrets"}{...}
{vieweralsosee "backtest" "help backtest"}{...}
{vieweralsosee "cbacktest" "help cbacktest"}{...}

{viewerjumpto "Syntax" "cmline##syntax"}{...}
{viewerjumpto "Description" "cmline##description"}{...}
{viewerjumpto "Options" "cmline##options"}{...}
{viewerjumpto "Remarks" "cmline##remarks"}{...}
{viewerjumpto "Examples" "cmline##examples"}{...}
{viewerjumpto "Results" "cmline##results"}{...}

{title:Title}

{phang}
{bf:cmline} {hline 2} Calculates and makes a graph of the Capital Market Line along with the efficient frontier of financial portfolios given a set of return variables. It also performs risk decomposition of the portfolio.

{marker syntax}{...}
{title:Syntax}


{p 8 17 2}
{opt cmline} {varlist} {ifin} 
{cmd:} {it: [,options]} 

{synoptset 25 tabbed}{...}

{synopthdr}
{synoptline}
{synopt :{opt rfrate(#)}}risk-free rate of the period (e.g. if monthly data, then specify the risk-free rate per month). The default value is zero (if it is not specified).{p_end}
{synopt :{opt nport(#)}}number of portfolios along the efficient frontier to be computed. The default is 100.{p_end}
{synopt :{opt nos:hort}}Indicates that no short sales are allowed (no negative weights for the instruments). The default is to allow for short sales.{p_end}
{synopt :{opt case:wise}}Specifies casewise deletion of observations. If casewise is specified, then expected returns and variance-covariance matrix are 
computed using only the observations that have nonmissing values for all variables in varlist. If casewise is not specified, 
then all possible data of the sample for all variables will be used to compute the expected returns and variance-covariance matrix.
The default is to use all the nonmissing values for each variable.{p_end}
{synopt :{opt min:weight(#)}}Specifies the minimum weight to be allowed for all instruments. In case of specifying the noshort option, the default value for minweight is zero. {p_end}
{synopt :{opt rmin:weights}}In case of specific restrictions of minimum weights for each instrument or return, a list of minimum weights have to be indicated here.
This is a list of decimal numbers usually from 0 to 1. If the list has less numbers than the number of instruments, zero is assumed for the rest. Order of instruments is important here {p_end}
{synopt :{opt max:weight}}Specifies the maximum weight to be allowed for all instruments.{p_end}
{synopt :{opt rmax:weights}}In case of specific restrictions of maximum weights for each instrument or return, a list of maximum weights have to be indicated here.
This is a list of decimal numbers usually from 0 to 1. If the list has less numbers than the number of instruments, 1 is assumed for the rest. Order of instruments is important here {p_end}
{synopt :{opt covm:atrix(cov_matrix)}}If cov_matrix exists and has the right dimension according to the number of variables, instead of calculating the variance-covariance
matrix, then the cov_matrix will be used as the variance-covariance matrix to estimate the capital market line.{p_end}
{synopt :{opt mr:ets(ret_matrix)}}If ret_matrix exists and has the right dimension according to the number of variables, instead of calculating the expected returns of the
assets, then the ret_matrix will be used as the vector of expected returns to estimate the capital market line.{p_end}
{synopt :{opt nog:raph}}If nograph is specified, then the Capital Market Line will not be graphed. {p_end}

{marker description}{...}
{title:Description}

{pstd}
{cmd:cmline} calculates and graph the capital market line and the efficient frontier of different financial portfolio configurations formed with the stock/bond returns specified in the   
{varlist}. The {varlist} must be a list of continuously compounded returns of financial instruments to be considered for the portfolio.
The efficient frontier starts with the global minimum variance portfolio and continues with all portfolio combinations that minimize return variance given specific incremental values of expected portfolio return.
The capital market line goes from the risk-free rate to the tangency portfolio. 
The option nport specifies the the number of different portfolios to be calculated along the efficient frontier. 
The option rfrate is the risk-free rate of the corresponding period to be used to compute the capital market line. Both options, nport and rfrate, must be specified.  	
The series can be daily, weekly, monthly, quarterly or annual returns. The risk-free rate has to correspond to the same frequency of the variables.
The option casewise is optional. If this  option is specified, for any missing value in any return series, casewise deletion is performed before doing the computations. If the option casewise is not specified, 
then for each return series the expected returns will be calculated according to its own missing values, and the variance-covariance matrix will be calculated 
with by pairs of returns to avoid casewise deletion. 
If the noshort option is specified, short sales are not allowed; the default value is to allow short sales (allowing negative weights).  	
{it: cmline} also performs the risk decomposition of the portfolio. 
It estimates the contribution to portfolio risk of each asset (see Stored results). 

{marker remarks}{...}
{title:Remarks}

{pstd}
The optimal (tangency) portfolio is a close approximation to the actual optimal portfolio. The accuracy will depend on the number of portfolios to be used
to estimate the efficient frontier (it is recommended to use 100 or more portfolios to maximize accuracy). Check the "Also See" Menu for related commands.
The return variables must be continuously compounded returns, not simple returns.

{marker examples}{...}
{title:Examples}

    {hline}
	
{pstd} Collect online monthly stock data (adjusted prices) from Yahoo Finance with the user command returnsyh. This command also calculates simple and continuous compounded returns: {p_end}
{phang}{cmd:. returnsyh AAPL MSFT GE GM WMT XOM, fm(1) fd(1) fy(2012) lm(12) ld(31) ly(2015) frequency(m) price(adjclose)}{p_end}

{pstd} Run the capital market line using a monthly risk-free rate of 0% with the continuously compounded returns, and creates 100 portfolios along the efficient frontier: {p_end}
{phang}{cmd:. cmline r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM}, nport(100) rfrate(0){p_end}

{pstd} Run the capital market line without allowing for short sales: {p_end}
{phang}{cmd:. cmline r_AAPL r_MSFT r_GE r_GM r_WMT r_XOM}, nport(100) rfrate(0) noshort{p_end}

     {hline}
	 
{pstd} Run the capital market line without allowing for short sales, restricting periods starting from Jan 2013. The default values for risk-free rate (0%) and number of portfolios (100) will be used:{p_end}
{phang}{cmd:. cmline r_* if period>=tm(2013m1)}, noshort{p_end}

{pstd} Calculates the capital market line restricting the weights to be at least 10% for all instruments:{p_end}
{phang}{cmd:. cmline r_* , noshort minweight(0.10)}{p_end}

{pstd} Calculates the capital market line restricting the weights to be less or equal to 30% :{p_end}
{phang}{cmd:. cmline r_* , noshort maxweight(0.30)}{p_end}

{pstd} Calculates the capital market line restricting the weights to be less or equal to 30% and greater or equal to 10%:{p_end}
{phang}{cmd:. cmline r_* , noshort maxw(0.30) minw(0.10)}{p_end}

{pstd} Calculates the capital market line with different minimum weights for each instrument:{p_end}
{phang}{cmd:. cmline r_* , rminweights(0 0.1 0.1 0 0.16 0)}{p_end}
{pstd} Negative minimum weights for each instrument can also be specified.{p_end}

{pstd} Calculates the capital market line with different maximum weights for each instrument:{p_end}
{phang}{cmd:. cmline r_* , rmaxweights(0.5 0.2 0.4 0.4 0.25 0.15)}{p_end}

     {hline}

{pstd} Calculates the expected returns of the instruments using the Exponential Weighted Moving Average (EWMA) method with a constant lamda=0.94:{p_end}
{phang}{cmd:. meanrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)}{p_end}
{pstd} Saving the matrix of expected returns in a vector:{p_end}
{phang}{cmd:. matrix mrets=r(meanrets)}{p_end}

{pstd} Calculates the variance-covariance matrix of the instruments using the EWMA method with a constant lamda=0.94:{p_end}
{phang}{cmd:. varrets r_AAPL r_MSFT r_GE r_GM , lew(0.94)}{p_end}
{pstd} Saving the variance-covariance matrix in a local matrix:{p_end}
{phang}{cmd:. matrix cov=r(cov)}{p_end}

{pstd} Calculates the capital market line using the calculated expected returns and variance-covariance matrix using the EWMA method:{p_end}
{phang}{cmd:. cmline r_AAPL r_MSFT r_GE r_GM, covm(cov) mrets(mrets)}{p_end}
{pstd} Any variance-covariance matrix can be used for the calculation of the global minimum variance portfolio.{p_end}

{pstd} Store stock weights, standard deviation and expected return of the 100 portfolios that lie on the efficient frontier (using Stata matrices): {p_end}
{phang}{cmd:. matrix alphacml_weights=r(walphacml)}{p_end}
{phang}{cmd:. matrix cml_port_ret=r(vrcml)}{p_end}
{phang}{cmd:. matrix cml_port_sd=r(vsdcml)}{p_end}
{phang}{cmd:. matrix sharpe_ratio=r(sharpe)}{p_end}
{phang}{cmd:. matrix port_weights_no_shorting=r(wef)}{p_end}
{phang}{cmd:. matrix port_std_dev_no_shorting=r(vsdef)}{p_end}
{phang}{cmd:. matrix port_ret_no_shorting=r(vref)}{p_end}
{phang}{cmd:. matrix port_sharpe_ratios=r(vsharpe)}{p_end}

{pstd} Display the return and risk of the tangency (optimal) portfolio: {p_end}
{phang}{cmd:. display "The expected return of the tangency portfolio is " r(rop) ", and its standard deviation of returns is " r(sdop)}{p_end}

{pstd} Display the weight vector of the tangency portfolio: {p_end}
{phang}{cmd:. matrix list r(wop)}{p_end}

{pstd} Storing weights, standard deviation, expected returns and Sharpe ratios of the efficient frontier portfolios in one matrix: {p_end}
{phang}{cmd:. matrix portfolios = port_weights_no_shorting, port_std_dev_no_shorting, port_ret_no_shorting, port_sharpe_ratios} {p_end}

{pstd} Storing weights, standard deviation, expected returns of the portfolios that lie on the capital market line : {p_end}
{phang}{cmd:. matrix cml = alphacml_weights, cml_port_sd, cml_port_ret} {p_end}

{pstd} Write both matrices to an Excel Workbook (cmline.xls) in 2 sheets using the user command xml_tab: {p_end}
{phang}{cmd:. xml_tab portfolios using "cmline.xls", replace sheet("Efrontier w Sharpe R") format ((S3120) (N1118)) title(Efficient Frontier Portfolios and its Sharpe Ratios (without allowing for short sales))}{p_end}
{phang}{cmd:. xml_tab cml using "cmline.xls", append sheet("Portfolios along the CML") format ((S3120) (N1118)) title(Capital Market Line Portfolios)}{p_end}

     {hline}
	 

{marker results}{...}
{title:Stored results}

{pstd}
{cmd:cmline} stores results in {cmd:r()} in the following scalars and matrices/vectors:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(rfrate):}}Risk-free rate {p_end}
{synopt:{cmd:r(sharpewos): }}Sharpe ratio of the tagency portfolio {p_end}
{synopt:{cmd:r(sdopwos): }}Expected standard deviation of the tangency portfolio {p_end}
{synopt:{cmd:r(rop): }}Expected return of the tangency portfolio {p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:r(exprets): }}(n x 1) expected returns of each return serie or variable (n variables) {p_end}
{synopt:{cmd:r(cov): }}(n x n) variance-covariance matrix of returns {p_end}
{synopt:{cmd:r(wop): }}(n x 1) weight vector of the tangency portfolio {p_end}
{synopt:{cmd:r(vref): }}(nport x 1) vector of expected return of each portfolio in the efficient frontier{p_end}
{synopt:{cmd:r(vsdef): }}(nport x 1) vector of expected standard deviation of each portoflio in the efficient frontier {p_end}
{synopt:{cmd:r(vsharpe): }}(nport x 1) vector of Sharpe ratios of each portfolio in the efficient frontier {p_end}
{synopt:{cmd:r(vrcml): }}(nport x 1) vector of expected returns of each portfolio in the capital market line {p_end}
{synopt:{cmd:r(vsdcml): }}(nport x 1) vector of expected standard deviations of each portoflio in the capital market line {p_end}
{synopt:{cmd:r(walphacml):}}(nport x 1) vector of weights allocated to the risk-free instrument {p_end}
{synopt:{cmd:r(wef): }}(nport x n) matrix (or set of nport horizontal vectors) of portfolio weights for each of the nport portfolios in the frontier{p_end}
{synopt:{cmd:r(mcr):}}(n x 1) Decomposition of risk: vector of asset marginal contributions to portfolio risk. 
   Risk decomposition is performed using the Euler's theorem, so the marginal contributions to risk is a set of partial derivatives of portfolio risk with respect to each asset weight.{p_end}
{synopt:{cmd:r(cr):}}(n x 1) Decomposition of risk: vector of asset contributions to portfolio risk. This is equal to the marginal contributions multiplied by its respective weights.
   The sum of the elements of this vector is equal to the portfolio risk (portfolio standard deviation). {p_end}
{synopt:{cmd:r(pcr):}}(n x 1) Decomposition of risk: vector of asset percent contributions to portfolio risk. This is equal to the contributions divided by portfolio risk.
   The sum of the elements of this vector is equal to one. {p_end}  
{synopt:{cmd:r(betas):}}(n x 1) vector of asset betas with respect to the portfolio. An asset beta is defined as the covariance between the asset returns and the portfolio returns divided by the portfolio variance. {p_end} 

{p2colreset}{...}


{title: Author}

Carlos Alberto Dorantes, Tecnológico de Monterrey, Querétaro Campus, Querétaro, México.
Email: cdorante@itesm.mx
