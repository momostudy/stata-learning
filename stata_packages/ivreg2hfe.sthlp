{smcl}
{* 25aug2024}{...}
{hline}
help for {hi:ivreg2hfe}
{hline}

{title:Instrumental variables fixed effects estimation using heteroskedasticity-based instruments}

{title:Description}

{p}{cmd:ivreg2hfe} estimates an instrumental variables fixed effects regression model providing the
option to generate instruments using Lewbel's (2012) method. This technique allows
the identification of structural parameters in regression models with endogenous or 
mismeasured regressors in the absence of traditional identifying information such as 
external instruments or repeated measurements. Identification is achieved in this context 
by having regressors that are uncorrelated with the product of heteroskedastic errors, 
which is a feature of many models where error correlations are due to an unobserved common factor.
The greater the degree of scale heteroskedasticity in the error process, the higher will 
be the correlation of the generated instruments with the included endogenous variables 
which are the regressands in the auxiliary ('first stage') regressions.

{p}Using this form of Lewbel's method, instruments may be constructed as simple functions of the model's data.
 This approach may be ({cmd:a}) applied when no external instruments are available, or, alternatively, 
({cmd:b})  used to supplement external instruments to improve the efficiency of the IV estimator.
Supplementing external instruments can also allow Sargan-Hansen tests of the orthogonality conditions
or overidentifying restrictions to be performed, which would not be available in the case 
of exact identification by external instruments.

{p}Lewbel (2016, 2018) discusses how this estimation technique may be used, under certain conditions,
where an endogenous regressor is binary rather than continuous, such as an endogenous treatment
indicator. Under the same assumptions, the technique could be employed where both the outcome 
and regressor are binary.

{p}This implementation has been built using the existing {cmd:xtivreg2} (Schaffer) 
and {cmd:ivreg2} (Baum, Schaffer, Stillman) routines. It can be used on panel data using the 
within transformation of a fixed effects model: see the {cmd:fe} option described below. 
As {cmd:ivreg2hfe} is a variant of {cmd:ivreg2}, essentially
all of the features and options of that program are available in {cmd:ivreg2h}. For that
reason, you should consult {help ivreg2:help ivreg2} for details of the available options.

{p}{cmd:ivreg2hfe} provides three additional options: {cmd:gen}, {cmd:gen(}{it:string}{cmd:[,replace])}, and {cmd:z()}.
If the {cmd:gen} option is given, the generated instruments are saved, with names built from
the original variable names suffixed with {cmd:_g}. 
If greater control over the naming
of the generated instruments is desired, use the {cmd:gen(}{it:string}{cmd:[,replace]} option. 
The {it:string} argument allows the specification of a stub, or prefix, for the generated variable names,
which will also be suffixed with {cmd:_g}. 
You can remove earlier instruments with those same names with the {cmd:replace} suboption.
In order to use a subset of the included exogenous variables to construct instruments, include
them in the {cmd:z()} option. Make sure that the variables listed here are in the list of included
instruments. Time-series operators cannot be used in the {cmd:z()} option.

{cmd:ivreg2hfe} requires that the data have been declared as a panel using {cmd:tsset}
or {cmd:xtset}. In other cases, you should use {cmd:ivreg2h}, which can handle cross-section,
time-series or pooled cross-section time-series data.

{p}{cmd:ivreg2hfe} can be invoked to estimate a traditionally identified single equation, 
or a single equation that--before augmentation with the generated instruments--fails the 
order condition for identification:
either ({cmd:a}) by having no excluded instruments, 
or ({cmd:b}) by having fewer excluded instruments than needed for 
traditional identification. 

{p}In the former case ({cmd:a}), of adequate external instruments augmented by 
generated instruments, the program provides three sets of estimates: the traditional IV 
estimates, estimates using only generated instruments, and estimates using both 
generated and excluded instruments. 
{cmd:ivreg2hfe} automatically produces a Hayashi "C" test of the excluded instruments' validity 
(equivalent to use of the {cmd:orthog} option in {cmd:ivreg2}). 
The results of the third estimation (that including both generated and excluded instruments) are saved in the ereturn list. All three sets of estimates are saved, named {it:StdIV}, {it:GenInst} and {it:GenExtInst}, respectively.

{p}In the latter case ({cmd:b}), of an underidentified equation, either one or two sets
of estimates will be produced and displayed. 
If there are no excluded instruments, only the estimates using 
generated instruments are displayed. 
If there are excluded instruments but too few to produce identification by 
the order condition, the estimates using only generated instruments and those produced by 
generated and excluded instruments will be displayed.
Unlike {cmd:ivreg2} or {cmd:ivregress}, {cmd:ivreg2hfe} allows the syntax 
{it:ivreg2hfe depvar exogvar (endogvar=)}, as after augmentation with the generated regressors, 
the order condition for identification will be satisfied.
The resulting estimates are saved in the 
ereturn list and as a set of estimates named {it:GenInst} and, optionally, {it:GenExtInst}.

{title:Saved Results}

{p}Note that in the {cmd:estimates table} output, the displayed results {it:j}, {it:jdf} and
{it:jp} refer to the Hansen J statistic, its degrees of freedom, and its p-value. 
If i.i.d. errors are assumed, and a Sargan test is displayed in the standard output,
 the Sargan statistic, degrees of freedom and p-value are displayed in {it:j}, {it:jdf} and 
 {it:jpval}, as the Hansen and Sargan statistics coincide in that case.

{p}The results of the most recent estimation are saved in the ereturn list. Please see
{cmd:help ivreg2} for details. 
 
{title:Examples}


{p 8 12}Example using panel data and HAC standard errors. 

{p 8 12}{inp:.} {stata "webuse grunfeld ": webuse grunfeld}

{p 8 12}{inp:.} {stata "ivreg2hfe invest L(1/2).kstock (mvalue=) ": ivreg2hfe invest L(1/2).kstock (mvalue=)}

{p 8 12}{inp:.} {stata "ivreg2hfe invest L(1/2).kstock (mvalue=L(1/4).mvalue), gen robust bw(2)": ivreg2hfe invest L(1/2).kstock (mvalue=L(1/4).mvalue), gen robust bw(2)}

{title:Acknowledgements}

{p 0 4}We thank participants in the 2012 UK Stata Users Group, 2013 Mexican Stata Users Group
 and 2013 German Stata Users Group  meetings for their constructive comments.
We are grateful to Federico Belotti for diagnosing and providing corrected code for the -generate- option.

{title:References}

{p 0 4} Baum CF,  Lewbel A, Schaffer ME, Talavera O, 2012. Instrumental variables estimation using heteroskedasticity-based instruments.
 {browse "http://repec.org/usug2012/UK12_baum.pdf":http://repec.org/usug2012/UK12_baum.pdf}.

{p 0 4} Lewbel, A, 2012.  Using Heteroscedasticity to Identify and Estimate Mismeasured and Endogenous Regressor Models.
Journal of Business and Economic Statistics, 30:1, 67-80. {browse "http://fmwww.bc.edu/EC-P/wp587.pdf":http://fmwww.bc.edu/EC-P/wp587.pdf}.

{p 0 4} Lewbel, A, 2016. Identification and Estimation Using Heteroscedasticity Without Instruments: The Binary Endogenous Regressor Case.
Boston College Economics Working Paper 927. {browse "http://fmwww.bc.edu/EC-P/wp927.pdf":http://fmwww.bc.edu/EC-P/wp927.pdf}

{p 0 4} Lewbel, A, 2018. Identification and Estimation Using Heteroscedasticity Without Instruments: The Binary Endogenous Regressor Case.
Economics Letters, 165, 10-12.

{p 0 4} Baum CF, Lewbel, A, 2019. Advice on using Heteroscedasticity based identificatiom. Stata Journal, 19:4, 757-767. 

{title:Citation}

{p}{cmd:ivreg2hfe} is not an official Stata command. It is a free contribution
to the research community, like a paper. Please cite it as such: {p_end}

{phang}Baum, CF, Schaffer, ME, 2012.
ivreg2h: Stata module to perform instrumental variables fixed effects estimation using heteroskedasticity-based instruments.
{browse "http://ideas.repec.org/c/boc/bocode/s457555.html":http://ideas.repec.org/c/boc/bocode/s457555.html}{p_end}

{title:Authors}

{p 0 4}Christopher F Baum, Boston College, USA{p_end}
{p 0 4}baum@bc.edu{p_end}
{p 0 4}Mark E Schaffer, Heriot-Watt University, UK{p_end}
{p 0 4}M.E.Schaffer@hw.ac.uk{p_end}


