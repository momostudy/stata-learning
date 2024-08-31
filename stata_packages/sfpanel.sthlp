{smcl}
{* *! version 1.0.0  03jul2010}{...}
{cmd:help sfpanel}{right:also see:  {help sfpanel postestimation}}
{hline}

{title:Title}

{p2colset 5 17 21 2}{...}
{p2col :{hi:sfpanel} {hline 2}}Stochastic frontier models for panel data{p_end}
{p2colreset}{...}

{title:Syntax}


{space 4}{title:Time-varying models}

{phang}
True fixed-effects model (Greene, 2005)

{p 8 16 2}{cmd:sfpanel} {depvar} [{indepvars}] {ifin} {weight}
{cmd:, model(tfe)} [{it:{help sfpanel##tfeoptions:tfe_options}}]

{phang}
True random-effects model (Greene, 2005)

{p 8 16 2}{cmd:sfpanel} {depvar} [{indepvars}] {ifin} {weight}
{cmd:, model(tre)} [{it:{help sfpanel##treoptions:tre_options}}]

{phang}
ML random-effects time-varying inefficiency effects model (Battese and Coelli, 1995)

{p 8 16 2}{cmd:sfpanel} {depvar} [{indepvars}] {ifin} {weight}
{cmd:, model(bc95)} [{it:{help sfpanel##bc95options:bc95_options}}]

{phang}
Iterative Least Squares time-varying fixed-effects model (Lee and Schmidt, 1993)

{p 8 16 2}{cmd:sfpanel} {depvar} [{indepvars}] {ifin} 
{cmd:, model(fels)} [{it:{help sfpanel##felsoptions:fels_options}}]

{phang}
ML random-effects time-varying efficiency decay model (Battese and Coelli, 1992)

{p 8 16 2}{cmd:sfpanel} {depvar} [{indepvars}] {ifin} {weight}
[{cmd:, model(bc92)} {it:{help sfpanel##bc92options:bc92_options}}]

{phang}
ML random-effects flexible time-varying efficiency model (Kumbhakar, 1990)

{p 8 16 2}{cmd:sfpanel} {depvar} [{indepvars}] {ifin} {weight}
{cmd:, model(kumb90)} [{it:{help sfpanel##kumb90options:kumb90_options}}]

{phang}
Modified-LSDV time-varying fixed-effects model (Cornwell, Schmidt and Sickles, 1990)

{p 8 16 2}{cmd:sfpanel} {depvar} [{indepvars}] {ifin} 
{cmd:, model(fecss)} [{it:{help sfpanel##fecssoptions:fecss_options}}]


{space 4}{title:Time-invariant models}

{phang}
ML random-effects model with time-invariant efficiency (Battese and Coelli, 1988)

{p 8 16 2}{cmd:sfpanel} {depvar} [{indepvars}] {ifin} {weight}
{cmd:, model(bc88)} [{it:{help sfpanel##bc88options:bc88_options}}]

{phang}
ML random-effects model with time-invariant efficiency  (Pitt and Lee, 1981)

{p 8 16 2}{cmd:sfpanel} {depvar} [{indepvars}] {ifin} {weight}
{cmd:, model(pl81)} [{it:{help sfpanel##pl81options:pl81_options}}]

{phang}
GLS random-effects model

{p 8 16 2}{cmd:sfpanel} {depvar} [{indepvars}] {ifin} 
{cmd:, model(regls)} [{it:{help sfpanel##reglsoptions:regls_options}}]

{phang}
Fixed-effects model 

{p 8 16 2}{cmd:sfpanel} {depvar} [{indepvars}] {ifin} {weight}
{cmd:, model(fe)} [{it:{help sfpanel##feoptions:fe_options}}]


{marker tfeoptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :tfe_options}
{synoptline}
{syntab :Inefficiency distribution}
{synopt :{cmdab:d:istribution(}{opt e:xponential)}}exponential distribution for the inefficiency term, the default{p_end}
{synopt :{cmdab:d:istribution(}{opt h:normal)}}half-normal distribution for the inefficiency term{p_end}
{synopt :{cmdab:d:istribution(}{opt t:normal)}}truncated-normal distribution for the inefficiency term{p_end}

{syntab :Ancillary equations}
{synopt :{cmdab:e:mean(}{it:{help varlist:varlist_m}}[{cmd:,} {opt nocons:tant}]{cmd:)}}fit conditional mean model; 
    only with {cmd:d(tnormal)}; use {opt noconstant} to suppress constant term{p_end}
{synopt :{cmdab:u:sigma(}{it:{help varlist:varlist_u}}[{cmd:,} {opt nocons:tant}]{cmd:)}}specify explanatory variables for the inefficiency variance function; 
    use {opt noconstant} to suppress constant term{p_end}
{synopt :{cmdab:v:sigma(}{it:{help varlist:varlist_v}}[{cmd:,} {opt nocons:tant}]{cmd:)}}specify explanatory variables for the idiosyncratic error variance function; 
    use {opt noconstant} to suppress constant term{p_end}

{syntab :{help sfpanel##sv_remarks:Starting values}}
{synopt:{opt svfront:ier()}}specify a {it:1 X k} vector of initial values for the coefficients of the frontier{p_end}
{synopt:{opt sve:mean()}}specify a {it: 1 X k_m} vector of initial values for the coefficients of the conditional mean model; only with {cmd:d(tnormal)}{p_end}
{synopt:{opt svu:sigma()}}specify a {it: 1 X k_u} vector of initial values for the coefficients of the inefficiency variance function{p_end}
{synopt:{opt svv:sigma()}}specify a {it: 1 X k_v} vector of initial values for the coefficients of the idiosyncratic error variance function{p_end}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt resc:ale}}determine rescaling of initial values{p_end}

{syntab :Other}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt feshow}}show fixed-effects estimates; seldom used{p_end}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{opt nowarn:ing}}do not display warning message "convergence not achieved"{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help sfpanel##tfe_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help sfpanel##maximize_options:maximize_options}}}control the maximization process; seldom used {p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}

{marker treoptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :tre_options}
{synoptline}
{syntab :Inefficiency distribution}
{synopt :{cmdab:d:istribution(}{opt e:xponential)}}exponential distribution for the inefficiency term, the default{p_end}
{synopt :{cmdab:d:istribution(}{opt h:normal)}}half-normal distribution for the
inefficiency term{p_end}
{synopt :{cmdab:d:istribution(}{opt t:normal)}}truncated-normal distribution for the inefficiency term{p_end}

{syntab :Ancillary equations}
{synopt :{cmdab:e:mean(}{it:{help varlist:varlist_m}}[{cmd:,} {opt nocons:tant}]{cmd:)}}fit conditional mean model; 
    only with {cmd:d(tnormal)}; use {opt noconstant} to suppress constant term{p_end}
{synopt :{cmdab:u:sigma(}{it:{help varlist:varlist_u}}[{cmd:,} {opt nocons:tant}]{cmd:)}}specify explanatory variables for the inefficiency variance function; 
    use {opt noconstant} to suppress constant term{p_end}
{synopt :{cmdab:v:sigma(}{it:{help varlist:varlist_v}}[{cmd:,} {opt nocons:tant}]{cmd:)}}specify explanatory variables for the idiosyncratic error variance function; 
    use {opt noconstant} to suppress constant term{p_end}

{syntab :{help sfpanel##sv_remarks:Starting values}}
{synopt:{opt svfront:ier()}}specify a {it:1 X k} vector of initial values for the coefficients of the frontier{p_end}
{synopt:{opt sve:mean()}}specify a {it: 1 X k_m} vector of initial values for the coefficients of the conditional mean model; only with {cmd:d(tnormal)}{p_end}
{synopt:{opt svu:sigma()}}specify a {it: 1 X k_u} vector of initial values for the coefficients of the inefficiency variance function{p_end}
{synopt:{opt svv:sigma()}}specify a {it: 1 X k_v} vector of initial values for the coefficients of the idiosyncratic error variance function{p_end}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt resc:ale}}determine rescaling of initial values{p_end}

{syntab :Other}
{synopt :{opt nocons:tant}}suppress constant term in the frontier equation{p_end}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}
{synopt :{cmdab:simtype(}{it:{help sfpanel##simtype:simtype}}{cmd:)}}method to produce random draws for simulation{p_end}
{synopt :{opt nsim:ulations(#)}}# of random draws{p_end}
{synopt :{opt base(#)}}prime number used as a base for Halton sequences generation; only with {cmd:simtype(halton)} or {cmd:simtype(genhalton)}{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{opt nowarn:ing}}do not display warning message "convergence not achieved"{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help sfpanel##tre_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help sfpanel##maximize_options:maximize_options}}}control the maximization process; seldom used {p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}

{synoptset 20}{...}
{marker simtype}{...}
{synopthdr :simtype}
{synoptline}
{synopt :{opt ru:niform}}Uniformly distributed random variates{p_end}
{synopt :{opt ha:lton}}Halton sequence with {opt base(#)}{p_end}
{synopt :{opt genha:lton}}Randomized halton sequence with {opt base(#)}{p_end}
{synoptline}
{p2colreset}{...}

{marker bc95options}{...}
{synoptset 33 tabbed}{...}
{synopthdr :bc95_options}
{synoptline}
{syntab :Ancillary equations}
{synopt :{cmdab:e:mean(}{it:{help varlist:varlist_m}}[{cmd:,} {opt nocons:tant}]{cmd:)}}fit
    conditional mean model; use {opt noconstant} to suppress constant term{p_end}
{synopt :{cmdab:u:sigma(}{it:{help varlist:varlist_u}}[{cmd:,} {opt nocons:tant}]{cmd:)}}specify explanatory variables for the inefficiency variance function; use {opt noconstant} to suppress constant term{p_end}
{synopt :{cmdab:v:sigma(}{it:{help varlist:varlist_v}}[{cmd:,} {opt nocons:tant}]{cmd:)}}specify explanatory variables for the idiosyncratic error variance function; use {opt noconstant} to suppress constant term{p_end}

{syntab :{help sfpanel##sv_remarks:Starting values}}
{synopt:{opt svfront:ier()}}specify a {it:1 X k} vector of initial values for the coefficients of the frontier{p_end}
{synopt:{opt sve:mean()}}specify a {it: 1 X k_m} vector of initial values for the coefficients of the conditional mean model{p_end}
{synopt:{opt svu:sigma()}}specify a {it: 1 X k_u} vector of initial values for the coefficients of the inefficiency variance function{p_end}
{synopt:{opt svv:sigma()}}specify a {it: 1 X k_v} vector of initial values for the coefficients of the idiosyncratic error variance function{p_end}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt rescale}}determine rescaling of initial values{p_end}

{syntab :Other}
{synopt :{opt nocons:tant}}suppress constant term in the frontier equation{p_end}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{opt nowarn:ing}}do not display warning message "convergence not achieved"{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help sfpanel##bc95_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help sfpanel##maximize_options:maximize_options}}}control the maximization process; seldom used {p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}

{marker felsoptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :fels_options}
{synoptline}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{it:{help sfpanel##fels_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}


{marker bc92options}{...}
{synoptset 33 tabbed}{...}
{synopthdr :bc92_options}
{synoptline}
{syntab :{help sfpanel##sv_remarks:Starting values}}
{synopt :{opt svfront:ier()}}specify a {it:1 X k} vector of starting values for the frontier {p_end}
{synopt :{opt sve:mean()}}specify a starting value for the truncation mean of the inefficiency term{p_end}
{synopt:{opt svsigma()}}specify a starting value for the sigma parameter{p_end}
{synopt:{opt svgamma()}}specify a starting value for the gamma parameter{p_end}
{synopt :{opt sveta()}}specify a starting value for the variable controlling the behavior of the firm effects over time{p_end}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt rescale}}determine rescaling of initial values{p_end}

{syntab :Other}
{synopt :{opt nocons:tant}}suppress constant term in the frontier equation{p_end}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it:clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{opt nowarn:ing}}do not display warning message "convergence not achieved"{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help sfpanel##bc92_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help sfpanel##maximize_options:maximize_options}}}control the maximization process; seldom used {p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}

{marker kumb90options}{...}
{synoptset 33 tabbed}{...}
{synopthdr :kumb90_options}
{synoptline}
{syntab :Ancillary equations}
{synopt :{cmdab:bt(}{it:{help varlist:varlist_bt}}[{cmd:,}{opt nocons:tant}]{cmd:)}}time
variables specifying the temporal pattern of inefficiency; use {opt noconstant}
to suppress constant term. The default is a quadratic polynomial in time{p_end}

{syntab :{help sfpanel##sv_remarks:Starting values}}
{synopt :{opt svfront:ier()}}specify a {it:1 X k} vector of starting values for the frontier {p_end}
{synopt :{opt svbt()}}specify a {it:1 X k_bt} vector of starting values for the parameters explaining the temporal pattern of the firm effects {p_end}
{synopt :{opt svu:sigma()}}specify a starting value for the variance parameter of the inefficiency term {p_end}
{synopt :{opt svv:sigma()}}specify a starting value for the variance parameter of the idiosyncratic term {p_end}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt rescale}}determine rescaling of initial values{p_end}

{syntab :Other}
{synopt :{opt nocons:tant}}suppress constant term in the frontier equation{p_end}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{opt nowarn:ing}}do not display warning message "convergence not achieved"{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help sfpanel##kumb90_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help sfpanel##maximize_options:maximize_options}}}control the maximization process; seldom used {p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}

{marker fecssoptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :fecss_options}
{synoptline}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{it:{help sfpanel##fecss_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}


{marker bc88options}{...}
{synoptset 33 tabbed}{...}
{synopthdr :bc88_options}
{synoptline}
{syntab :{help sfpanel##sv_remarks:Starting values}}
{synopt :{opt svfront:ier()}}specify a {it:1 X k} vector of starting values for the frontier {p_end}
{synopt :{opt sve:mean()}}specify a starting value for the truncation mean of the inefficiency term{p_end}
{synopt:{opt svsigma()}}specify a starting value for the sigma parameter{p_end}
{synopt:{opt svgamma()}}specify a starting value for the gamma parameter{p_end}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt rescale}}determine rescaling of initial values{p_end}

{syntab :Other}
{synopt :{opt nocons:tant}}suppress constant term in the frontier equation{p_end}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{opt nowarn:ing}}do not display warning message "convergence not achieved"{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help sfpanel##bc88_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help sfpanel##maximize_options:maximize_options}}}control the maximization process; seldom used {p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}


{marker pl81options}{...}
{synoptset 33 tabbed}{...}
{synopthdr :pl81_options}
{synoptline}
{syntab :{help sfpanel##sv_remarks:Starting values}}
{synopt :{opt svfront:ier()}}specify a {it:1 X k} vector of starting values for the frontier {p_end}
{synopt:{opt svu:sigma()}}specify a starting value for the coefficient of the inefficiency variance function{p_end}
{synopt:{opt svv:sigma()}}specify a starting value for the coefficient of the idiosyncratic error variance function{p_end}
{synopt :{opt nosearch}}no attempt is made to improve on the initial values{p_end}
{synopt :{opt restart}}select the random method to improve initial values{p_end}
{synopt :{opt repeat(#)}}# of times the random values are tried; the default is 10{p_end}
{synopt :{opt rescale}}determine rescaling of initial values{p_end}

{syntab :Other}
{synopt :{opt nocons:tant}}suppress constant term in the frontier equation{p_end}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt r:obust}, {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it: clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{opt nocnsr:eport}}do not display constraints{p_end}
{synopt :{opt nowarn:ing}}do not display warning message "convergence not achieved"{p_end}
{synopt :{opt postscore}}save observation-by-observation scores in the estimation results list{p_end}{synopt :{opt posthess:ian}}save the Hessian corresponding to the full set of coefficients in the estimation results list{p_end}
{synopt :{it:{help sfpanel##pl81_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{syntab:Maximization}
{synopt :{it:{help sfpanel##maximize_options:maximize_options}}}control the maximization process; seldom used {p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}


{marker reglsoptions}{...}
{synoptset 33 tabbed}{...}
{synopthdr :regls_options}
{synoptline}
{syntab :Model}
{synopt :{opt nocons:tant}}suppress constant term{p_end}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt oim}, {opt opg}, {opt cl:uster} {it:clustvar}, {opt r:obust}, {opt boot:strap},
    or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it:clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt level(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{it:{help sfpanel##regls_display_options:display_options}}}control
           spacing and display of omitted variables and base and empty cells{p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{synoptset 11 tabbed}{...}

{marker feoptions}{...}
{synoptset 31 tabbed}{...}
{synopthdr :fe_options}
{synoptline}
{syntab:Model}
{synopt :{opt cost}}fit cost frontier model. The default is production frontier model{p_end}
{synopt :{cmdab:const:raints(}{it:{help estimation options##constraints():constraints}}{cmd:)}}apply specified linear constraints{p_end}

{syntab:SE/Robust}
{synopt :{opth vce(vcetype)}}{it:vcetype} may be {opt conventional}, {opt r:obust},
   {opt cl:uster} {it:clustvar}, {opt boot:strap}, or {opt jack:knife}{p_end}
{synopt :{opt r:obust}}synonym for {cmd:vce(robust)}{p_end}{synopt :{opt cl:uster(clustvar)}}synonym for {cmd:vce(cluster}{it:clustvar}{cmd:)}{p_end}

{syntab:Reporting}
{synopt :{opt l:evel(#)}}set confidence level. The default is {cmd:level(95)}{p_end}
{synopt :{it:{help sfpanel##fe_display_options:display_options}}}control spacing
           and display of omitted variables and base and empty cells{p_end}

{p2coldent:+ {opt coefl:egend}}display coefficients' legend instead of coefficient table{p_end}
{synoptline}
{p2colreset}{...}


{p 4 6 2}
A panel and a time variable must be specified. Use {helpb xtset}.{p_end}
{p 4 6 2}
{it:indepvars} may contain factor variables; see {help fvvarlist}.{p_end}
{p 4 6 2}
{it:depvars} and {it:indepvars} may contain time-series operators; see
{help tsvarlist}.{p_end}
{p 4 6 2}
{opt bootstrap}, {opt by}, and {opt jackknife}, are allowed; see {help prefix}.{p_end}
{p 4 6 2}Weights are not allowed with the {helpb bootstrap} prefix.{p_end}
{p 4 6 2}{opt aweight}s, {opt fweight}s, {opt iweight}s, and {opt pweight}s are allowed; see {help weight}.{p_end}
{p 4 6 2}Weights must be constant within panel.{p_end}
{p 4 6 2}
See {help sfpanel postestimation} for
features available after estimation.{p_end}


{title:Description}

{pstd}
{cmd:sfpanel} fits parametric Stochastic production or cost Frontier (SF) models for panel data. 
When estimation is done with likelihood-based methods, the SF model is:

		y_it = alpha + beta*X_it + v_it {c 177} u

{pstd}
where v_it is a normally distributed error term and u is a one-sided strictly non-negative term representing inefficiency. 
The sign of the u term is positive or negative depending on whether the frontier describes a cost or production function, respectively. 
Among the time-varying inefficiency models (u=u_it), {cmd:sfpanel} fits: 

{pstd}
{cmd:i)} the true fixed-effects (TFE) and the true random-effects (TRE) models developed by Greene (2005), 
	in which both time-invariant unmeasured heterogeneity (alpha=alpha_i) and time-varying firm inefficiency are considered;
	
{pstd}	
{cmd:ii)} the Battese and Coelli (1995) model, in which the u_it is obtained by truncation at zero of the normal distribution with mean (Z_it*delta),
	where Z_it is a set of covariates explaining the mean of inefficiency;
	
{pstd}	
{cmd:iii)} the time decay model by Battese and Coelli (1992), in which u_it=u_i*B(t) , and B(t)=[exp(-eta*(t-T_i))]. 
	u_i is assumed to be truncated-normally distributed with non-zero mean and constant variance, while eta governs the temporal pattern
	of inefficiency.
	
{pstd}	
{cmd:iv)} the flexible parametric model by Kumbhakar (1990), in which u_it=u_i*B(t) , and B(t)=[1+exp(bt+ct^2)]^(-1). 

{pstd}
Among the time-invariant inefficiency models (u=u_i), {cmd:sfpanel} fits: 

{pstd}	
{cmd:v)} the Battese and Coelli (1988) model, in which u_i is truncated-normally distributed with non-zero mean and constant variance;

{pstd}	
{cmd:vi)} the Pitt and Lee (1981) model, in which u_i is half-normally distributed with constant variance;

{pstd}	
When estimation is done with least squares methods, the SF production model is:

		y_it = alpha + beta*X_it + v_it

{pstd}
Among the time-varying inefficiency models (alpha=alpha_it), {cmd:sfpanel} fits: 

{pstd}
{cmd:vii)} the Lee and Schmidt (1993) model, in which alpha_it = theta_t*delta_i and theta_t are parameters to be estimated.
	This model is a special case of Kumbhakar (1990), in which B(t) is represented by a set of dummy variables for time.

{pstd}
{cmd:viii)} the Cornwell et al. (1990) model, in which alpha_it = delta_i0 + delta_i1*t + delta_i2*t^2

{pstd}
Among the time-invariant inefficiency models (alpha=alpha_i), {cmd:sfpanel} fits: 

{pstd}
{cmd:ix)} the Schmidt and Sickles (1984) model in which alpha_i can be either fixed or random.


{title:Options for True fixed-effects model (Greene, 2005)}

{dlgtab:Inefficiency distribution}

{phang}
{opt distribution(distname)} specifies the distribution for the inefficiency term 
    as half-normal ({opt hnormal}), truncated-normal ({opt tnormal}) or {opt exponential}.
    The default is {opt exponential}.

{dlgtab:Ancillary equations}

{phang}
{cmd:emean(}{help varlist:varlist_m} [,{opt noconstant}]{cmd:)} may be used only with {cmd:distribution(tnormal)}.
With this option, {opt sfpanel} specifies the mean of the truncated-normal distribution in terms of a linear function of the covariates defined in {it:varlist_m}. 
Specifying {opt noconstant} suppresses the constant in this function.

{phang}
{cmd:usigma(}{help varlist:varlist_u} [,{opt noconstant}]{cmd:)}
specifies that the inefficiency component is heteroskedastic,
with the variance expressed as a function of the covariates defined in
{it:varlist_u}.  Specifying {opt noconstant} suppresses the
constant term in this function. 

{phang}
{cmd:vsigma(}{help varlist:varlist_v} [,{opt noconstant}]{cmd:)}
specifies that the idiosyncratic error component is heteroskedastic,
with the variance expressed as a function of the covariates defined in 
{it:varlist_v}.  Specifying {opt noconstant} suppresses the
constant term in this function. 

{dlgtab:Starting values}

{phang}
{opt svfrontier()} specifies a {it:1 X k} vector of starting values for the frontier. The vector must have the same length as 
there are parameters to estimate in the frontier equation.

{phang}
{opt svemean()} specifies a {it:1 X k_m} vector of starting values for variables parameterizing the truncation mean of the inefficiency term. It
cannot be used when the distribution of the inefficiency term is exponential or half-normal. 

{phang}
{opt svusigma()} specifies a {it:1 X k_u} vector of starting values for variables parameterizing the variance of the inefficiency term. 

{phang}
{opt svvsigma()} specifies a {it:1 X k_v} vector of starting values for variables parameterizing the variance of the idiosyncratic term. 

{phang}
{opt nosearch} determines that no attempts are made to improve on the initial
values via a search technique. In this case, the initial values become the 
starting values.

{phang}
{opt restart} determines that the random method of improving initial values is
to be attempted. See also {help mf_moptimize##init_search:moptimize_init_search()}

{phang}
{opt repeat(#)} controls how many times random values are tried if the random method is turned
on. The default is 10.

{phang}
{opt rescale} determines whether rescaling is attempted. Rescaling is a deterministic method.
It also usually improves initial values, and usually reduces the number of subsequent iterations 
required by the optimization technique.

{phang}
By default the starting values come from an equivalent cross-sectional frontier model. 
For instance, if inefficiency has a truncated-normal distribution and the random shock is a function of some variables, 
{cmd:sfpanel} will first run {help sfcross} with a truncated-normal distribution and the {cmd:vsigma(}{help varlist:varlist_v}{cmd:)} option. 
The estimated coefficients are used as starting values. 

{dlgtab:Other}

{phang}
{opt cost} specifies that {opt sfpanel} fits a cost frontier model.

{phang}
{opt constraints}({it:{help estimation options##constraints():constraints}}) applies specified linear constraints.

{dlgtab:SE}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt feshow} allows the user to display estimates of individual fixed-effects, along with structural parameters. 

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt nocnsreport}; see {helpb estimation options##nocnsreport:[R] estimation options}.

{phang}
{opt nowarning} specifies whether the warning message "convergence not achieved" should
        not be displayed when this stopping rule is invoked. By default the message is displayed.

{phang}
{opt postscore} saves an observation-by-observation matrix of scores in the estimation results list. 
Scores are defined as the derivative of the objective function with respect to the {help mf_moptimize##def_parameter:parameters}.
This option cannot be used when the size of the scores' matrix is greater than Stata matrix limit; see {helpb limits:[R] limits}.

{phang}
{opt posthessian} saves the Hessian matrix corresponding to the full set of coefficients 
in the estimation results list.

{marker tfe_display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

{dlgtab:Maximization}

{phang}
{marker maximize_options}
{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)},
{opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient},
{opt showstep}, {opt hess:ian}, {opt showtol:erance}, {opt tol:erance(#)},
{opt ltol:erance(#)}, {opt nrtol:erance(#)},
{opt nonrtol:erance}; see {manhelp maximize R}.  These
options are seldom used.


{title:Options for True random-effects model (Greene, 2005)}

{dlgtab:Inefficiency distribution}

{phang}
{opt distribution(distname)} specifies the distribution for the inefficiency term 
    as half-normal ({opt hnormal}), truncated-normal ({opt tnormal}) or {opt exponential}.
    The default is {opt exponential}.
    
{dlgtab:Ancillary equations}

{phang}
{cmd:emean(}{help varlist:varlist_m} [,{opt noconstant}]{cmd:)} may be used only with {cmd:distribution(tnormal)}.
With this option, {opt sfpanel} specifies the mean of the truncated-normal distribution in terms of a linear function of the covariates defined in {it:varlist_m}. 
Specifying {opt noconstant} suppresses the constant in this function.

{phang}
{cmd:usigma(}{help varlist:varlist_u} [,{opt noconstant}]{cmd:)}
specifies that the inefficiency component is heteroskedastic,
with the variance expressed as a function of the covariates defined in
{it:varlist_u}.  Specifying {opt noconstant} suppresses the
constant term in this function. 

{phang}
{cmd:vsigma(}{help varlist:varlist_v} [,{opt noconstant}]{cmd:)}
specifies that the idiosyncratic error component is heteroskedastic,
with the variance expressed as a function of the covariates defined in 
{it:varlist_v}.  Specifying {opt noconstant} suppresses the
constant term in this function. 

{dlgtab:Starting values}

{phang}
{opt svfrontier()} specifies a {it:1 X k} vector of starting values for the frontier. The vector must have the same length as 
there are parameters to estimate in the frontier equation.

{phang}
{opt svusigma()} specifies a {it:1 X k_u} vector of starting values for variables parameterizing the variance of the inefficiency term. 

{phang}
{opt svvsigma()} specifies a {it:1 X k_v} vector of starting values for variables parameterizing the variance of the idiosyncratic term. 

{phang}
{opt nosearch} determines that no attempts are made to improve on the initial
values via a search technique. In this case, the initial values become the 
starting values.

{phang}
{opt restart} determines that the random method of improving initial values is
to be attempted. See also {help mf_moptimize##init_search:moptimize_init_search()}

{phang}
{opt repeat(#)} controls how many times random values are tried if the random method is turned
on. The default is 10.

{phang}
{opt rescale} determines whether rescaling is attempted. Rescaling is a deterministic method.
It also usually improves initial values, and usually reduces the number of subsequent iterations 
required by the optimization technique.

{phang}
By default the starting values come from an equivalent cross-sectional frontier model. 
For instance, if inefficiency has a truncated-normal distribution and the random shock is a function of some variables, 
{cmd:sfpanel} will first run {help sfcross} with a truncated-normal distribution and the {cmd:vsigma(}{help varlist:varlist_v}{cmd:)} option. 
The estimated coefficients are used as starting values. 

{dlgtab:Other}

{phang}
{opt noconstant}; see
{helpb estimation options##noconstant:[R] estimation options}.

{phang}
{opt cost} specifies that {opt sfpanel} fits a cost frontier model.

{phang}
{opt constraints}({it:{help estimation options##constraints():constraints}}) applies specified linear constraints.

{phang}
{opt simtype(simtype)} specifies the method to generate random draws. 
{opt runiform} generates uniformly distributed random variates; {opt halton} and {opt genhalton} create 
respectively Halton sequences and generalized Halton sequences where the base is expressed by the prime 
number in {opt base}(#). {opt runiform} is the default. See also {help mf_halton} for more details on Halton sequences generation.

{phang}
{opt nsimulations(#)} specifies the number of draws for simulation. The default is 250.

{phang}
{opt base(#)} specifies the number, preferably a prime, used as a base for the generation of Halton sequences and
generalized Halton sequences. The default is 7. Note that Halton sequences
based on large primes (#>10) can be highly correlated, and their coverage
worse than that of pseudorandom uniform sequences.

{dlgtab:SE}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see
{helpb estimation options##level():[R] estimation options}.

{phang}
{opt nocnsreport}; see
     {helpb estimation options##nocnsreport:[R] estimation options}.

{phang}
{opt nowarning} specifies whether the warning message "convergence not achieved" should
        not be displayed when this stopping rule is invoked. By default the message is displayed.

{phang}
{opt postscore} saves an observation-by-observation matrix of scores in the estimation results list. 
Scores are defined as the derivative of the objective function with respect to the {help mf_moptimize##def_K:coefficients}.
This option cannot be used when the size of the scores' matrix is greater than Stata matrix limit; see {helpb limits:[R] limits}.

{phang}
{opt posthessian} saves the Hessian matrix corresponding to the full set of coefficients 
in the estimation results list.

{marker tre_display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

{dlgtab:Maximization}

{phang}
{marker maximize_options}
{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, {opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient},
    {opt showstep}, {opt hess:ian}, {opt showtol:erance}, {opt tol:erance(#)}, {opt ltol:erance(#)}, {opt nrtol:erance(#)},
    {opt nonrtol:erance}; see {manhelp maximize R}. These options are seldom used.

	
{title:Options for ML random-effects time-varying inefficiency effects model (Battese and Coelli, 1995)}

{dlgtab:Ancillary equations}

{phang}
{cmd:emean(}{help varlist:varlist_m} [,{opt noconstant}]{cmd:)} fits the Battese and Coelli (1995) 
conditional mean model in which the mean of the truncated-normal distribution is expressed
as a linear function of the covariates specified in {it:varlist_m}. 
Specifying {opt noconstant} suppresses the constant in this function.

{phang}
{cmd:usigma(}{help varlist:varlist_u} [,{opt noconstant}]{cmd:)}
specifies that the inefficiency component is heteroskedastic,
with the variance expressed as a function of the covariates defined in
{it:varlist_u}.  Specifying {opt noconstant} suppresses the
constant term in this function. 

{phang}
{cmd:vsigma(}{help varlist:varlist_v} [,{opt noconstant}]{cmd:)}
specifies that the idiosyncratic error component is heteroskedastic,
with the variance expressed as a function of the covariates defined in 
{it:varlist_v}.  Specifying {opt noconstant} suppresses the
constant term in this function. 

{dlgtab:Starting values}

{phang}
{opt svfrontier()} specifies a {it:1 X k} vector of starting values for the frontier. The vector must have the same length as 
there are parameters to estimate in the frontier equation.

{phang}
{opt svemean()} specifies a 1 x k_m vector of initial values for the coefficients of the conditional mean model. 

{phang}
{opt svusigma()} specifies a {it:1 X k_u} vector of starting values for variables parameterizing the variance of the inefficiency term. 

{phang}
{opt svvsigma()} specifies a {it:1 X k_v} vector of starting values for variables parameterizing the variance of the idiosyncratic term. 

{phang}
{opt nosearch} determines that no attempts are made to improve on the initial
values via a search technique. In this case, the initial values become the 
starting values.

{phang}
{opt restart} determines that the random method of improving initial values is
to be attempted. See also {help mf_moptimize##init_search:moptimize_init_search()}

{phang}
{opt repeat(#)} controls how many times random values are tried if the random method is turned
on. The default is 10.

{phang}
{opt rescale} determines whether rescaling is attempted. Rescaling is a deterministic method.
It also usually improves initial values, and usually reduces the number of subsequent iterations 
required by the optimization technique.

{dlgtab:Other}

{phang}
{opt noconstant}; see
{helpb estimation options##noconstant:[R] estimation options}.

{phang}
{opt cost} specifies that {opt sfpanel} fits a cost frontier model.

{phang}
{opt constraints}({it:{help estimation options##constraints():constraints}}) applies specified linear constraints.

{dlgtab:SE}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt nocnsreport}; see {helpb estimation options##nocnsreport:[R] estimation options}.

{phang}
{opt nowarning} specifies whether the warning message "convergence not achieved" should
        not be displayed when this stopping rule is invoked. By default the message is displayed.

{phang}
{opt postscore} saves an observation-by-observation matrix of scores in the estimation results list. 
Scores are defined as the derivative of the objective function with respect to the {help mf_moptimize##def_parameter:parameters}.
This option cannot be used when the size of the scores' matrix is greater than Stata matrix limit; see {helpb limits:[R] limits}.

{phang}
{opt posthessian} saves the Hessian matrix corresponding to the full set of coefficients 
in the estimation results list.

{marker bc95_display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

{dlgtab:Maximization}

{phang}
{marker maximize_options}
{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, {opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient},
    {opt showstep}, {opt hess:ian}, {opt showtol:erance}, {opt tol:erance(#)},{opt ltol:erance(#)}, {opt nrtol:erance(#)},
    {opt nonrtol:erance}; see {manhelp maximize R}.  
    These options are seldom used.
	
	
{title:Options for Iterative Least Squares time-varying fixed-effects model (Lee and Schmidt, 1993)}

{phang}
{opt cost} specifies that {opt sfpanel} fits a cost frontier model.

{dlgtab:SE}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{marker fels_display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

	
{title:Options for ML random-effects time-varying efficiency decay model (Battese and Coelli, 1992)}
{dlgtab:Starting values}

{phang}
{opt svfrontier()} specifies a {it:1 X k} vector of starting values for the frontier. The vector must have the same length as 
there are parameters to estimate in the frontier equation.

{phang}
{opt svemean()} specifies a starting value for the truncation mean of the inefficiency term.

{phang}
{opt svsigma()} specifies a starting value for the sigma parameter.

{phang}
{opt svgamma()} specifies a  starting value for the gamma parameter.

{phang}
{opt sveta()} specifies a starting value for the variable controlling the behavior of the firm effects over time.

{phang}
{opt nosearch} determines that no attempts are made to improve on the initial
values via a search technique. In this case, the initial values become the 
starting values.

{phang}
{opt restart} determines that the random method of improving initial values is
to be attempted. See also {help mf_moptimize##init_search:moptimize_init_search()}

{phang}
{opt repeat(#)} controls how many times random values are tried if the random method is turned
on. The default is 10.

{phang}
{opt rescale} determines whether rescaling is attempted. Rescaling is a deterministic method.
It also usually improves initial values, and usually reduces the number of subsequent iterations 
required by the optimization technique.

{dlgtab:Other}

{phang}
{opt noconstant}; see
{helpb estimation options##noconstant:[R] estimation options}.

{phang}
{opt cost} specifies the frontier model be fit in terms of a cost function
instead of a production function.  By default, {cmd:sfpanel} fits a
production frontier model.

{phang}
{opt constraints}({it:{help estimation options##constraints():constraints}}) applies specified linear constraints.

{dlgtab:SE}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt nocnsreport}; see {helpb estimation options##nocnsreport:[R] estimation options}.

{phang}
{opt nowarning} specifies whether the warning message "convergence not achieved" should
        not be displayed when this stopping rule is invoked. By default the message is displayed.

{phang}
{opt postscore} saves an observation-by-observation matrix of scores in the estimation results list. 
Scores are defined as the derivative of the objective function with respect to the {help mf_moptimize##def_K:coefficients}.
This option cannot be used when the size of the scores' matrix is greater than Stata matrix limit; see {helpb limits:[R] limits}.

{phang}
{opt posthessian} saves the Hessian matrix corresponding to the full set of coefficients 
in the estimation results list.

{marker bc92_display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

{dlgtab:Maximization}

{phang}
{marker maximize_options}
{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, {opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient},
    {opt showstep}, {opt hess:ian}, {opt showtol:erance}, {opt tol:erance(#)},{opt ltol:erance(#)}, {opt nrtol:erance(#)},
    {opt nonrtol:erance}; see {manhelp maximize R}.  
    These options are seldom used.
	

{title:Options for ML random-effects flexible time-varying efficiency model (Kumbhakar, 1990)}

{dlgtab:Ancillary equations}

{phang}
{cmd:bt(}{help varlist:varlist_bt} [,{opt noconstant}]{cmd:)} fits a model 
    that allows a flexible specification of inefficiency handling different types of time behavior, using the formulation
    u_it=u_i*(1+exp({it:varlist_bt}))^(-1).
	Typically explanatory variables in {it:varlist_bt} are represented by a polynomial in time. 
    Specifying {opt noconstant} suppresses the constant in the function. 
    The default includes a linear and a quadratic term in time without the constant, as in Kumbhakar (1990).

{dlgtab:Starting values}

{phang}
{opt svfrontier()} specifies a {it:1 X k} vector of starting values for the frontier. The vector must have the same length as 
there are parameters to estimate in the frontier equation.

{phang}
{opt svbt()} specifies a 1 x k_bt vector  of initial values for the coefficients of the time function controlling the behavior of the firm effects. 

{phang}
{opt svusigma()} specifies a starting value for the parameter of the variance of the inefficiency term. 
   
{phang}
{opt svvsigma()} specifies a starting value for the parameter of the variance of the idiosyncratic term. 

{phang}
{opt nosearch} determines that no attempts are made to improve on the initial
values via a search technique. In this case, the initial values become the 
starting values.

{phang}
{opt restart} determines that the random method of improving initial values is
to be attempted. See also {help mf_moptimize##init_search:moptimize_init_search()}

{phang}
{opt repeat(#)} controls how many times random values are tried if the random method is turned
on. The default is 10.

{phang}
{opt rescale} determines whether rescaling is attempted. Rescaling is a deterministic method.
It also usually improves initial values, and usually reduces the number of subsequent iterations 
required by the optimization technique.

{dlgtab:Other}

{phang}
{opt noconstant}; see
{helpb estimation options##noconstant:[R] estimation options}.

{phang}
{opt cost} specifies the frontier model be fit in terms of a cost function
instead of a production function.  By default, {cmd:sfpanel} fits a
production frontier model.

{phang}
{opt constraints}({it:{help estimation options##constraints():constraints}}) applies specified linear constraints.

{dlgtab:SE}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt nocnsreport}; see {helpb estimation options##nocnsreport:[R] estimation options}.

{phang}
{opt nowarning} specifies whether the warning message "convergence not achieved" should
        not be displayed when this stopping rule is invoked. By default the message is displayed.

{phang}
{opt postscore} saves an observation-by-observation matrix of scores in the estimation results list. 
Scores are defined as the derivative of the objective function with respect to the {help mf_moptimize##def_K:coefficients}.
This option cannot be used when the size of the scores' matrix is greater than Stata matrix limit; see {helpb limits:[R] limits}.

{phang}
{opt posthessian} saves the Hessian matrix corresponding to the full set of coefficients 
in the estimation results list.

{marker kumb90_display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

{dlgtab:Maximization}

{phang}
{marker maximize_options}
{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, {opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient},
    {opt showstep}, {opt hess:ian}, {opt showtol:erance}, {opt tol:erance(#)},{opt ltol:erance(#)}, {opt nrtol:erance(#)},
    {opt nonrtol:erance}; see {manhelp maximize R}.  
    These options are seldom used.	
	

{title:Modified-LSDV time-varying fixed-effects model (Cornwell, Schmidt and Sickles, 1990)}

{phang}
{opt cost} specifies that {opt sfpanel} fits a cost frontier model.

{dlgtab:SE}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{marker fecss_display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.
	
	
{title: ML random-effects model with time-invariant efficiency (Battese and Coelli, 1988)}
{dlgtab:Starting values}

{phang}
{opt svfrontier()} specifies a {it:1 X k} vector of starting values for the frontier. The vector must have the same length as 
there are parameters to estimate in the frontier equation.

{phang}
{opt svemean()} specifies a starting value for the truncation mean of the inefficiency term.

{phang}
{opt svsigma()} specifies a starting value for the sigma parameter.

{phang}
{opt svgamma()} specifies a  starting value for the gamma parameter.

{phang}
{opt nosearch} determines that no attempts are made to improve on the initial
values via a search technique. In this case, the initial values become the 
starting values.

{phang}
{opt restart} determines that the random method of improving initial values is
to be attempted. See also {help mf_moptimize##init_search:moptimize_init_search()}

{phang}
{opt repeat(#)} controls how many times random values are tried if the random method is turned
on. The default is 10.

{phang}
{opt rescale} determines whether rescaling is attempted. Rescaling is a deterministic method.
It also usually improves initial values, and usually reduces the number of subsequent iterations 
required by the optimization technique.

{dlgtab:Other}

{phang}
{opt noconstant}; see
{helpb estimation options##noconstant:[R] estimation options}.

{phang}
{opt cost} specifies the frontier model be fit in terms of a cost function
instead of a production function.  By default, {cmd:sfpanel} fits a
production frontier model.

{phang}
{opt constraints}({it:{help estimation options##constraints():constraints}}) applies specified linear constraints.
{dlgtab:SE}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt nocnsreport}; see {helpb estimation options##nocnsreport:[R] estimation options}.
     
{phang}
{opt nowarning} specifies whether the warning message "convergence not achieved" should
        not be displayed when this stopping rule is invoked. By default the message is displayed.

{phang}
{opt postscore} saves an observation-by-observation matrix of scores in the estimation results list. 
Scores are defined as the derivative of the objective function with respect to the {help mf_moptimize##def_K:coefficients}.
This option cannot be used when the size of the scores' matrix is greater than Stata matrix limit; see {helpb limits:[R] limits}.

{phang}
{opt posthessian} saves the Hessian matrix corresponding to the full set of coefficients 
in the estimation results list.

{marker bc88_display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

{dlgtab:Maximization}

{phang}
{marker maximize_options}
{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, {opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient},
    {opt showstep}, {opt hess:ian}, {opt showtol:erance}, {opt tol:erance(#)}, {opt ltol:erance(#)}, {opt nrtol:erance(#)},
    {opt nonrtol:erance}; see {manhelp maximize R}.  These options are seldom used.


{title: ML random-effects model with time-invariant efficiency (Pitt and Lee, 1981)}
{dlgtab:Starting values}

{phang}
{opt svfrontier()} specifies a {it:1 X k} vector of starting values for the frontier. The vector must have the same length as 
there are parameters to estimate in the frontier equation.

{phang}
{opt svusigma()} specifies a starting value for the parameter of the variance of the inefficiency term. 
   
{phang}
{opt svvsigma()} specifies a starting value for the parameter of the variance of the idiosyncratic term. 

{phang}
{opt nosearch} determines that no attempts are made to improve on the initial
values via a search technique. In this case, the initial values become the 
starting values.

{phang}
{opt restart} determines that the random method of improving initial values is
to be attempted. See also {help mf_moptimize##init_search:moptimize_init_search()}

{phang}
{opt repeat(#)} controls how many times random values are tried if the random method is turned
on. The default is 10.

{phang}
{opt rescale} determines whether rescaling is attempted. Rescaling is a deterministic method.
It also usually improves initial values, and usually reduces the number of subsequent iterations 
required by the optimization technique.

{dlgtab:Other}

{phang}
{opt noconstant}; see
{helpb estimation options##noconstant:[R] estimation options}.

{phang}
{opt cost} specifies the frontier model be fit in terms of a cost function
instead of a production function.  By default, {cmd:sfpanel} fits a
production frontier model.

{phang}
{opt constraints}({it:{help estimation options##constraints():constraints}}) applies specified linear constraints.
{dlgtab:SE}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see {helpb estimation options##level():[R] estimation options}.

{phang}
{opt nocnsreport}; see {helpb estimation options##nocnsreport:[R] estimation options}.
     
{phang}
{opt nowarning} specifies whether the warning message "convergence not achieved" should
        not be displayed when this stopping rule is invoked. By default the message is displayed.

{phang}
{opt postscore} saves an observation-by-observation matrix of scores in the estimation results list. 
Scores are defined as the derivative of the objective function with respect to the {help mf_moptimize##def_K:coefficients}.
This option cannot be used when the size of the scores' matrix is greater than Stata matrix limit; see {helpb limits:[R] limits}.

{phang}
{opt posthessian} saves the Hessian matrix corresponding to the full set of coefficients 
in the estimation results list.

{marker pl81_display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

{dlgtab:Maximization}

{phang}
{marker maximize_options}
{it:maximize_options}: {opt dif:ficult}, {opt tech:nique(algorithm_spec)}, {opt iter:ate(#)}, [{opt no:}]{opt lo:g}, {opt tr:ace}, {opt grad:ient},
    {opt showstep}, {opt hess:ian}, {opt showtol:erance}, {opt tol:erance(#)}, {opt ltol:erance(#)}, {opt nrtol:erance(#)},
    {opt nonrtol:erance}; see {manhelp maximize R}.  These options are seldom used.


{title:Options for GLS random-effects model}

{dlgtab:Model}

{phang}
{opt noconstant}; see
{helpb estimation options##noconstant:[R] estimation options}.

{phang}
{opt cost} specifies the frontier model be fit in terms of a cost function
instead of a production function.  By default, {cmd:sfpanel} fits a
production frontier model.

{dlgtab:SE}

{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see
{helpb estimation options##level():[R] estimation options}.

{marker regls_display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.


{title:Options for Fixed-effects model}

{dlgtab:Model}

{phang}
{opt cost} specifies the frontier model be fit in terms of a cost function
instead of a production function.  By default, {cmd:sfpanel} fits a
production frontier model.

{phang}
{opt constraints}({it:{help estimation options##constraints():constraints}}) applies specified linear constraints.


{dlgtab:SE}
{phang}
{opt vce(vcetype)} specifies the type of standard error reported, which includes types that are derived from asymptotic theory and
that use bootstrap or jackknife methods; see {helpb vce_option:[R] {it:vce_option}}.

{dlgtab:Reporting}

{phang}
{opt level(#)}; see
{helpb estimation options##level():[R] estimation options}.

{marker fe_display_options}{...}
{phang}
{it:display_options}:
{opt noomit:ted},
{opt vsquish},
{opt noempty:cells},
{opt base:levels},
{opt allbase:levels};
    see {helpb estimation options##display_options:[R] estimation options}.

{marker sv_remarks}{...}
{title:Remarks}

{pstd}
{cmd:sv{it:eqname}()} specifies initial values for the coefficients of {it:eqname}. You can specify the initial values in one of three ways:
1) by specifying the name of a vector contained in the initial values (e.g. {cmd:sv{it:frontier}(b0)}, where {cmd:b0} is a conformable 
vector); 2) by specifying coefficient names with the values in the same order as they appear in the command syntax 
(e.g. {cmd:sv{it:frontier}(x1=.5 x2=.3 _cons=1)}, if {cmd: sfpanel y x1 x2}); 3) or by specifying a list of values
(e.g. {cmd:sv{it:frontier}(.5 .3 1)}.


{title:Examples}

{pstd}Setup{p_end}
{phang}{cmd:. webuse xtfrontier1, clear}{p_end}

{pstd}Time-varying models:{p_end}

{phang} - Greene (2005), True fixed-effects model{p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(tfe) dist(exp) usigma(lnworkers)}{p_end}
{phang}{cmd:. constraint define 1 lnmachines + lnworkers = .5}{p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(tfe) dist(exp) constraint(1)}

{phang} - Greene (2005), True random-effects model{p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(tre) dist(hnormal) usigma(lnworkers) difficult rescale nsim(50) simtype(genhalton)}

{phang} - Battese and Coelli (1995){p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(bc95) emean(lnworkers)}

{phang} - Battese and Coelli (1992){p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers}

{phang} - Lee and Schmidt (1993){p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(fels)}

{phang} - Kumbhakar (1990){p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(kumb90) rescale difficult}{p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(kumb90) bt(t, nocons) rescale difficult}

{phang} - Cornwell et al. (1990){p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(fecss)}


{pstd}Time-invariant models:{p_end}

{phang} - Battese and Coelli (1988){p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(bc88)}

{phang} - Schmidt and Sickles (1984){p_end}
{phang}{cmd:. constraint define 1 lnmachines + lnworkers = .5}{p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(fe) constraint(1)}{p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(regls)}

{phang} - Pitt and Lee (1981){p_end}
{phang}{cmd:. sfpanel lnwidgets lnmachines lnworkers, model(pl81)}


{title:Saved results}

{pstd}
{cmd:sfpanel} saves the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(N)}}number of observations{p_end}
{synopt:{cmd:e(N_g)}}number of groups{p_end}
{synopt:{cmd:e(k)}}number of estimated parameters{p_end}
{synopt:{cmd:e(k_eq)}}number of equations{p_end}
{synopt:{cmd:e(k_dv)}}number of dependent variables{p_end}
{synopt:{cmd:e(k_autoCns)}}number of base, empty, and omitted constraints{p_end}
{synopt:{cmd:e(df_m)}}model degrees of freedom{p_end}
{synopt:{cmd:e(ll)}}log likelihood{p_end}
{synopt:{cmd:e(g_min)}}minimum number of observations per group{p_end}
{synopt:{cmd:e(g_avg)}}average number of observations per group{p_end}
{synopt:{cmd:e(g_max)}}maximum number of observations per group{p_end}
{synopt:{cmd:e(sigma2)}}sigma2{p_end}
{synopt:{cmd:e(gamma)}}gamma{p_end}
{synopt:{cmd:e(sigma_u)}}standard deviation of inefficiency{p_end}
{synopt:{cmd:e(sigma_v)}}standard deviation of V_i{p_end}
{synopt:{cmd:e(avg_sigmau)}}average standard deviation of inefficiency{p_end}
{synopt:{cmd:e(avg_sigmav)}}average standard deviation of V_i{p_end}
{synopt:{cmd:e(lambda)}}signal to noise ratio{p_end}
{synopt:{cmd:e(Tcon)}}{cmd:1} if panels balanced; {cmd:0} otherwise{p_end}
{synopt:{cmd:e(chi2)}}chi-squared{p_end}
{synopt:{cmd:e(p)}}model significance{p_end}
{synopt:{cmd:e(rank)}}rank of {cmd:e(V)}{p_end}
{synopt:{cmd:e(ic)}}number of iterations{p_end}
{synopt:{cmd:e(rc)}}return code{p_end}
{synopt:{cmd:e(converged)}}{cmd:1} if converged, {cmd:0} otherwise{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:sfpanel}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(title)}}title in estimation output{p_end}
{synopt:{cmd:e(function)}}{cmd:production} or {cmd:cost}{p_end}
{synopt:{cmd:e(depvar)}}name of dependent variable{p_end}
{synopt:{cmd:e(covariates)}}name of independent variables{p_end}
{synopt:{cmd:e(model)}}name of specified model{p_end}
{synopt:{cmd:e(ivar)}}variable denoting groups{p_end}
{synopt:{cmd:e(tvar)}}variable denoting time{p_end}
{synopt:{cmd:e(crittype)}}optimization criterion{p_end}
{synopt:{cmd:e(dist)}}distribution assumption for U_i{p_end}
{synopt:{cmd:e(het)}}heteroskedastic components{p_end}
{synopt:{cmd:e(Emean)}}{it:varlist} in {cmd:emean()}{p_end}
{synopt:{cmd:e(Usigma)}}{it:varlist} in {cmd:usigma()}{p_end}
{synopt:{cmd:e(Vsigma)}}{it:varlist} in {cmd:vsigma()}{p_end}
{synopt:{cmd:e(simtype)}}method to produce random draws{p_end}
{synopt:{cmd:e(base)}}base number to generate Halton sequences{p_end}
{synopt:{cmd:e(nsim)}}number of random draws{p_end}
{synopt:{cmd:e(predict)}}program used to implement {cmd:predict}{p_end}
{synopt:{cmd:e(opt)}}type of optimization{p_end}
{synopt:{cmd:e(user)}}name of likelihood-evaluator program{p_end}
{synopt:{cmd:e(ml_method)}}type of {cmd:ml} method{p_end}
{synopt:{cmd:e(singularHmethod)}}{cmd:m-marquardt} or {cmd:hybrid}; method used when Hessian is singular{p_end}
{synopt:{cmd:e(technique)}}maximization technique{p_end}
{synopt:{cmd:e(which)}}{cmd:max} or {cmd:min}; whether optimizer is to perform maximization or minimization{p_end}{synopt:{cmd:e(wtype)}}weight type{p_end}
{synopt:{cmd:e(wexp)}}weight expression{p_end}
{synopt:{cmd:e(chi2type)}}{cmd:Wald}; type of model chi-squared test{p_end}
{synopt:{cmd:e(vce)}}{it:vcetype} specified in {cmd:vce()}{p_end}
{synopt:{cmd:e(vcetype)}}title used to label Std. Err.{p_end}
{synopt:{cmd:e(contraints)}}list of specified constraints{p_end}
{synopt:{cmd:e(properties)}}{cmd:b V}{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Matrices}{p_end}
{synopt:{cmd:e(b)}}coefficient vector{p_end}
{synopt:{cmd:e(Cns)}}constraints matrix{p_end}
{synopt:{cmd:e(ilog)}}iteration log (up to 20 iterations){p_end}
{synopt:{cmd:e(gradient)}}gradient vector{p_end}
{synopt:{cmd:e(V)}}variance-covariance matrix of the estimators{p_end}
{synopt:{cmd:e(V_modelbased)}}model-based variance{p_end}
{synopt:{cmd:e(postscore)}}observation-by-observation scores{p_end}
{synopt:{cmd:e(posthessian)}}Hessian corresponding to the full set of coefficients{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Functions}{p_end}
{synopt:{cmd:e(sample)}}marks estimation sample{p_end}
{p2colreset}{...}


{title:Authors}

{pstd}Federico Belotti{p_end}
{pstd}Centre for Economic and International Studies, University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}federico.belotti@uniroma2.it{p_end}

{pstd}Silvio Daidone{p_end}
{pstd}Centre for Health Economics, University of York{p_end}
{pstd}York, UK{p_end}
{pstd}silvio.daidone@york.ac.uk{p_end}

{pstd}Vincenzo Atella{p_end}
{pstd}Centre for Economic and International Studies, University of Rome Tor Vergata{p_end}
{pstd}Rome, Italy{p_end}
{pstd}atella@uniroma2.it{p_end}

{pstd}Giuseppe Ilardi{p_end}
{pstd}Economic and Financial Statistics Department, Bank of Italy{p_end}
{pstd}Rome, Italy{p_end}
{pstd}giuseppe.ilardi@bancaditalia.it{p_end}


{title:Also see}

{psee}
{space 2}Help:  {help sfpanel_postestimation}, {help sfcross}, {help sfcross_postestimation}.
{p_end}
