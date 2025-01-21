{smcl}
{* *! version 2.0  June 2023}{...}
{right:also see:  {help quaidsce} {space 1}}
{hline}

{title:Title}

{p2colset 5 30 32 2}{...}
{p2col :{cmd:quaidsce postestimation} {hline 2}}Postestimation tools for quaidsce{p_end}
{p2colreset}{...}

{title:Description}

{pstd}
The following postestimation commands are available after {cmd:quaidsce}: 

{synoptset 21}{...}
{p2coldent :Command}Description{p_end}
{synoptline}
{synopt :{helpb quaidsce postestimation##predict:predict}}predicted expenditure shares{p_end}
{synoptline}
{p2colreset}{...}


{marker predict}{...}
{title:Syntax for predict}

{p 8 16 2}
{cmd:predict} 
{c -(}{it:stub}{cmd:*}}
{ifin}

{pstd}
These statistics are available both in and out of sample; type 
{cmd:predict ... if e(sample) ...} if wanted only for the estimation
sample.

{pstd}
You must specify a variable {it:stub} or {it:k} new variables, where {it:k}
is the number of goods in the demand system.

{title:Corresponding author}

{pstd}Juan C. Caro{p_end}
{pstd}Universidad de Concepcion{p_end}
{pstd}juancaros@udec.cl{p_end}


{title:Also see}

{p 7 14 2}Help:  {helpb quaidsce}{p_end}
