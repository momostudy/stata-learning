{smcl}
{* 30aug2012}{...}
{cmd:help boot_drf}{right: ({browse "http://www.stata-journal.com/article.html?article=st0412":SJ15-4: st0412})}
{hline}

{title:Title}

{p2colset 5 17 19 2}{...}
{p2col :{hi:boot_drf }{hline 2}}Bootstrapped standard errors for the dose-response function{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 17 2}
{cmd:boot_drf}{cmd:,}
{cmd:rep}{cmd:(}{it:number}{cmd:)}
[{cmd:size}{cmd:(}{it:number}{cmd:)}
{cmd:saving}{cmd:(}{it:filename}{cmd:)}
{cmd:bca}]


{title:Description}

{pstd} 
The postestimation command {cmd:boot_drf} is for use after the user-written
command {helpb ctreatreg}.  {cmd:boot_drf} calculates and plots in a graph the
bootstrapped standard errors of the dose-response function as estimated by
{cmd:ctreatreg}.  The statistical significance level is the same as the one
indicated in the option {cmd:ci()} of {cmd:ctreatreg}.

     
{title:Options}
    
{phang}
{cmd:rep}{cmd:(}{it:number}{cmd:)} specifies the number of bootstrap
replications.  {cmd:rep()} is required.

{phang}
{cmd:size}{cmd:(}{it:number}{cmd:)} specifies the sample size of a single
bootstrap replication.  By default, it is equal to the current sample size.

{phang}
{cmd:saving}{cmd:(}{it:filename}{cmd:)} specifies to save the resulting graph
in {it:filname}{cmd:.gph}.

{phang}
{cmd:bca} specifies to estimate confidence intervals by the bias-corrected
and accelerated method.


{title:Remarks} 

{pstd}
{cmd:boot_drf} creates the variables {cmd:_G1}, {cmd:_G2}, {cmd:_G3}, and
{cmd:_G4}.  These variables indicate the confidence interval lower bound
({cmd:_G1}) and upper bound ({cmd:_G3}), the dose-response function
({cmd:_G2}), and the grid ({cmd:_G4}).


{title:Example}

{phang}{cmd:. clear}{p_end}
{phang}{cmd:. set obs 5000}{p_end}
{phang}{cmd:. set seed 1010}{p_end}
{phang}{cmd:. generate treatment=rbinomial(1,0.5)}{p_end}
{phang}{cmd:. generate dose=runiform()*100}{p_end}
{phang}{cmd:. replace dose=0 if treatment==0}{p_end}
{phang}{cmd:. generate outcome =rnormal(7,1)}{p_end}
{phang}{cmd:. generate x1=rnormal(2,1)}{p_end}
{phang}{cmd:. generate x2=rnormal(5,2)}{p_end}
{phang}{cmd:. generate z1=rnormal(0,1)}{p_end}
{phang}{cmd:. generate z2=rnormal(3,2)}{p_end}

{phang}{cmd:. ctreatreg outcome treatment x1 x2, delta(10) hetero(x1 x2) model(ct-ols) ct(dose) ci(5) m(3) s(25)}

{phang}{cmd:. boot_drf, rep(5) size(50)}

   
{title:Author}

{pstd}Giovanni Cerulli{p_end}
{pstd}Ceris-CNR{p_end}
{pstd}National Research Council of Italy{p_end}
{pstd}Institute for Economic Research on Firms and Growth{p_end}
{pstd}Rome, Italy{p_end}
{pstd}{browse "mailto:g.cerulli@ceris.cnr.it":g.cerulli@ceris.cnr.it}{p_end}


{title:Also see}

{p 4 14 2}Article:  {it:Stata Journal}, volume 15, number 4: {browse "http://www.stata-journal.com/article.html?article=st0412":st0412}

{p 7 14 2}Help:  {helpb ctreatreg}, {helpb ivtreatreg}, {helpb treatrew}, {helpb pscore}, {helpb psmatch2}, {helpb nnmatch} (if installed), {manhelp etregress TE}, {manhelp ivregress R}{p_end}
