{smcl}
{* *! version 1.0.0  23jun2016}{...}

{vieweralsosee "returnsyh" "help returnsyh"}{...}
{vieweralsosee "meanrets" "help meanrets"}{...}
{vieweralsosee "cmline" "help cmline"}{...}
{vieweralsosee "efrontier" "help efrontier"}{...}
{vieweralsosee "gmvport" "help gmvport"}{...}
{vieweralsosee "mvport" "help mvport"}{...}
{vieweralsosee "varrets" "help varrets"}{...}
{vieweralsosee "ovport" "help ovport"}{...}
{vieweralsosee "simport" "help simport"}{...}
{vieweralsosee "holdingrets" "help holdingrets"}{...}
{vieweralsosee "cbacktest" "help cbacktest"}{...}

{viewerjumpto "Syntax" "backtest##syntax"}{...}
{viewerjumpto "Description" "backtest##description"}{...}
{viewerjumpto "Options" "backtest##options"}{...}
{viewerjumpto "Remarks" "backtest##remarks"}{...}
{viewerjumpto "Examples" "backtest##examples"}{...}
{viewerjumpto "Results" "backtest##results"}{...}

{title:Title}

{phang}
{bf:backtest} {hline 2} performs a backtest of a financial portfolio.

{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{opt backtest} {varlist} {ifin} 
{cmd:,} {it:weights(matrix_name)} 


{synoptset 25 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt w:eights(matrix_name)}} matrix_name is the name of a Stata matrix (Nx1) where the weights of the portfolio are stored. 
 This must be a vertical matrix with dimensions (N x 1), where N is the number of price variables.{p_end}


{marker description}{...}
{title:Description}

{pstd}
{cmd:backtest} calculates the holding period return of a financial portfolio composed of the price variables specified in {varlist}. The portfolio weights must be
located in a (Nx1) Stata matrix, which must be specified in the weights option.{p_end}

{marker remarks}{...}
{title:Remarks}

{pstd}
Check the "Also See" Menu for related commands.

{marker examples}{...}
{title:Examples}

    {hline}
	
{pstd} Collects online daily stock data from Yahoo Finance for 2014 and 2015. {p_end}
{phang}{cmd:. returnsyh AAPL MSFT GE, fm(1) fd(1) fy(2014) lm(12) ld(31) ly(2015) frequency(d) price(adjclose)}{p_end}

     {hline}

{pstd} Defines a portfolio weight matrix indicating 30% for Apple, Inc, 20% for Microsoft Corp, and 50% for General Electric Co.: {p_end}
{phang}{cmd:. matrix WPORT1=(0.3\0.2\0.5)}{p_end}

     {hline}

{pstd} Labels the row names for the matrix with the company/ticker names: {p_end}
{phang}{cmd:. matrix  rownames WPORT1=APPLE MICROSOFT GENERAL_ELECTRIC}{p_end}


     {hline}

	 
{pstd} Performs the backtest for the whole period. The holding period return of the portfolio for the whole period is calculated: {p_end}
{phang}{cmd:. backtest p_adjclose_AAPL p_adjclose_MSFT p_adjclose_GE, weights(WPORT1)} {p_end}

     {hline}

{pstd} Performs the backtest for a specified period. The holding period return of the portfolio for 2015 is calculated: {p_end}
{phang}{cmd:. backtest p_adjclose_AAPL p_adjclose_MSFT p_adjclose_GE if period>=td(01jan2015) & period<=td(31dec2015), weights(WPORT1)} {p_end}

     {hline}


{marker results}{...}
{title:Stored results}

{pstd}
{cmd:backtest} stores results in {cmd:r()} in the following scalars:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(N): }}Number of observations used for the calculations {p_end}
{synopt:{cmd:r(retport): }}Holding period return of the portfolio {p_end}

{p2colreset}{...}


{title: Author}

Carlos Alberto Dorantes, Tecnológico de Monterrey, Querétaro Campus, Querétaro, México.
Email: cdorante@itesm.mx
