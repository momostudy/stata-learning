


{smcl}
{* *! Version: 1.1.0}{...}
{* *! Author:Hejun Liu}{...}
{* *! Date:2016-4-25}{...}
{viewerjumpto "Syntax" "bcoeffs##syntax"}{...}
{viewerjumpto "Options" "bcoeffs##options"}{...}
{viewerjumpto "Description" "bcoeffs##description"}{...}
{viewerjumpto "Examples" "bcoeffs##examples"}{...}
{viewerjumpto "Upgrade Notes" "bcoeffs##upnotes"}{...}
{viewerjumpto "Author" "bcoeffs##author"}{...}
{viewerjumpto "Also see" "bcoeffs##alsosee"}{...}


{marker title }
{title :Title }


{p2colset 5 18 18 2}{...}
{p2col :{cmd:bcoeffs}{space 2}{hline 2}}Saving regression coefficients or standard error to new variables.{p_end}
{p2colreset}{...}

{marker syntax}{...}
{title:syntax}

{phang2}{cmd:bcoeffs} {varlist} [{cmd:,} {opt b:eta(str)} {opt s:e(str)} {opt c:ons(str)} {opt by(varlist)} {opt o:nly(varlist)} {opt m:odel(str)}
{opt n:min(#)} {opt d:ouble} {opt m:issing} {opt mo:ptions(str)}]{p_end}
 
{marker options}
{synoptset 26 tabbed}{...}
{synopthdr}
{synoptline}
{synopt :{opt b:eta(str)}}prefix {it:str} for new variables which will store coefficients of {it:independent variables} that in {it:varlist}.{p_end}

{synopt :{opt s:e(str)}}prefix {it:str} for new variables which will store standard error of {it:independent variables}.{p_end}

{synopt :{opt c:ons(str)}}name new variable which will store the {it:constant coefficient } of your regression by {it:str }.{p_end}

{synopt :{opt by(varlist)}}specifies one or more variables that define distinct groups 
of observations. Stata will regress by the groups.{p_end}

{synopt :{opt o:nly(varlist)}}you can get only the {it:varlist}'s coefficients or {it:se} of all independent variables 
, if you don't want to get all coefficients of the variables .{p_end}

{synopt :{opt m:odel(str)}}indicates the model command used. It defaults to {help regress}.{p_end}

{synopt :{opt n:min(#)}}specifies a minimum required number of observations for each group. 
Regressions will not be performed if the actual number is less than this. 
Default is 2.{p_end}

{synopt :{opt d:ouble}}specifies that each variable generated is to be of type double.{p_end}

{synopt :{opt m:issing }}indicates that observations with missing values for byvarlist 
(either  or "") are to be included in calculations. The default is 
to exclude such observations.
{p_end}

{synopt :{opt mo:ptions}}indicates {opt model}'s options, for example, model {cmd:xtreg} has options of {opt fe} or {opt re}, and you can indicate {cmd:xtreg} with {opt fe} or {opt re}.
{p_end}

{synoptline}
{p2colreset}{...}

{phang}{hi:{cmd:bcoeffs}} can apply it's option of {opt by()} who's effect is equal to that combined with {it:by-prefix} like {help by} or {help bysort} {cmd::}.
However, it would run too slowly if data's subset is too many.{p_end} 
{phang}The {it:"varlist"} after {hi:{cmd:bcoeffs}} must like this: {it:y x1 x2 x3...} {it:y} is your dependent variable
,then, {it:x1,x2,x3...} are your independent variables.{p_end}


{marker description }{...}
{title:Description }

{pstd}{cmd:bcoeffs} can save the varlist's coefficients or standard error to some new variables ,then you can do something further.
This command is a improvement of the command:{help bcoeff}, contributed by {hi:Zhiqiang Wang}(Menzies School of Health Research ,Darwin Australia
 ,email:wang@menzies.edu.au) and {hi:Nicholas J. Cox}(University of Durham, U.K.,email:n.j.cox@durham.ac.uk).{p_end}


{marker examples}
{title :Examples }

{dlgtab:model:regress}
{pstd}{input :.}{stata `"sysuse auto.dta,clear"':sysuse auto.dta,clear}{p_end }
{pstd}{input :.}{stata `"bcoeffs price mpg trunk weight length , b(b) se(se) only(weight)"':bcoeffs price mpg trunk weight length , b(b) se(se) only(weight)}{p_end }

{dlgtab:by()}
{pstd}{input :.}{stata `"bcoeffs price mpg trunk weight length , b(b_by) se(se_by) only(weight) by(foreign  rep78)"':bcoeffs price mpg trunk weight length , b(b_by) se(se_by) only(weight) by(foreign  rep78)}{p_end }

{dlgtab:model:xtreg}
{pstd}{input :.}{stata `"sysuse census.dta,clear"':sysuse census.dta,clear}{p_end}
{pstd}{input :.}{stata `"bysort region:gen year=_n"':bysort region:gen year=_n}{p_end}
{pstd}{input :.}{stata `"xtset region year"':xtset region year}{p_end}
{pstd}{input :.}{stata `"bcoeffs death pop medage ,  beta(b) model(xtreg) moption(fe)"':bcoeffs death pop medage ,  beta(b) model(xtreg) moption(fe)}{p_end}

{marker upnotes}
{title :Upgrade Notes}
{break}
{pstd}First of all, I provide my sincere apologies about the version of {cmd:bcoeffs-1.0.0}(2015-5-24),
because of it's big bug. Since my careless, option of {opt b:eta} in ver 1.0.0 has been mistakenly 
written as {opt g:enerate(str)}, so error message:"{hi:option generate() required}" would obsess many friends 
who use it. I'm sorry again about finding the big bug so late and 
appreciate some friends who feed error massage back to me so much.{p_end}
{phang}This version is 1.1.0, in addition to fixing the bug above, it has some improvements :{break}
1.Abolish option of {opt dxmin},because I think this is a "chicken ribs".{break}
2.Add {opt mo:ptions},In my opinion, this is a very useful option. When you use model like {cmd:xtreg} with 
fixed effect({opt fe}) or random effect({opt re})),
and need to store coefficients of it, what would you do? 
This time ,{opt mo:ptions} would be a effective tool.{p_end}


		
{marker author}
{title :Author }
{break}
{pstd}{cmd:Hejun,Liu(Nisus)} 2016-4-25, Center for Industry and Business Organization, Dongbei University of Finance and Economics,China.{p_end} 
{pstd}E-mail:{browse `"http://email.163.com/"':liuhejun108@163.com}{p_end} 
{pstd}Blog:{browse `"http://liuhejun108.blog.163.com/"':http://liuhejun108.blog.163.com/}{p_end} 

	
{marker alsosee }	
{title :Also see}

{pstd}{help bcoeff}{p_end}
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
