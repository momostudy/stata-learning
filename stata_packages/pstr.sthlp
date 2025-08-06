{smcl}
{* *! version 1.1  19jun2020}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "str" "sregress"}{...}
{vieweralsosee "" "--"}{...}
{viewerjumpto "Syntax" "pstr##syntax"}{...}
{viewerjumpto "Examples" "pstr##examples"}{...}
{viewerjumpto "Stored results" "pstr##saved"}{...}
{viewerjumpto "Author" "pstr##author"}{...}
{p2colset 1 16 18 2}{...}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 16 2}
{cmd:pstr} {depvar} [{indepvars}] {ifin}
[{cmd:,}  {opt lstr(spec)}  {opt lstr(spec)}  {opt lstr(spec)}   ...  {opt noconstant} {opt nolog} {opt vce(type) ] 

{space 5}where, {depvar} is the dependent variable, {indepvars} are the regime-independent explaining variables and time series and factor operators are allowed. 

The format of {it: spec} is :

{space 5}  {it: transition variable, regime-dependent variables, if has constant, number of threshold}

{space 5}where

{it: if has constant}: it should be {hi:0} (no constant) or {hi:1} (has constant).  

{it: number of threshold}: it should be {hi:1} or {hi:2}.


{synoptset 15}
{synopthdr}
{synoptline}
{synopt:{opt lstr(spec)} } LSTR specification.{p_end}
{synopt:{opt estr(spec)} } ESTR specification.{p_end}
{synopt:{opt nstr(spec)} } NSTR specification.{p_end}
{synopt:{opt noconstant} } if there is constant in linear part.{p_end}
{synopt:{opt nolog}} supress the optimization iteration log. {p_end}
{synoptline}


{marker examples}{...}
{title:Examples}

{pstd}

{stata ". hansen1999, clear"}
{stata `". pstr i L.q1 q2 q3 d1 qd1, lstr(c1, d1) "'}
{stata `". est store lstr"'}
{stata `". estat stcoef"'}
{stata ". estat stplot"}

{stata ". estat linear"}
{stata ". estat reslinear"}
{stata ". estat pconstant"}

{stata `". pstr i L.q1 q2 q3 d1 qd1, estr(c1, d1) "'}
{stata `". pstr i L.q1 q2 q3 d1 qd1, nstr(c1, d1) "'}
{stata `". est table lstr estr nstr, star(.1 .05 .01) stat(r2w ai bic hqic) b(%12.4f) "'}

{stata `". est restore estr"'}
{stata ". estat stplot"}
{stata ". estat linear"}
{stata ". estat reslinear"}
{stata ". estat pconstant"}


{marker saved}{...}
{title:Saved result}

Except the standard saved results of estimtation command, such as matrix {hi:e(b), e(V)} , scalar {hi:e(N)} etc., {cmd:pstr} also saves the following results.
{col 5}scalars:
{col 5}{hi:e(N)} {col 20}number of observation
{col 5}{hi:e(rank)} {col 20}rank
{col 5}{hi:e(ll)} {col 20}log-likelihood
{col 5}{hi:e(aic)} {col 20}AIC
{col 5}{hi:e(bic)} {col 20}BIC
{col 5}{hi:e(hqic)} {col 20}HQIC
{col 5}{hi:e(r2w)} {col 20}within r2
{col 5}{hi:e(r2b)} {col 20}between r2
{col 5}{hi:e(r2o)} {col 20}overall r2
{col 5}{hi:e(corr)} {col 20}corr(xb,u)

{col 5}macros:
{col 5}{hi:e(depvar)} {col 20} dependent variable
{col 5}{hi:e(ix)} {col 20} regime independent variables
{col 5}{hi:e(rx)} {col 20} regime-dependent variables
{col 5}{hi:e(cstlist)} {col 20} constant specification
{col 5}{hi:e(stflist)} {col 20} transition fundtion code list
{col 5}{hi:e(mata)} {col 20} class name stored in mata



