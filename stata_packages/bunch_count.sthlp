{smcl}
{* *! version 1.2.0  02jun2011}{...}
{findalias asfradohelp}{...}
{vieweralsosee "" "--"}{...}
{vieweralsosee "[R] help" "help help"}{...}
{viewerjumpto "Syntax" "bunch_count##syntax"}{...}
{viewerjumpto "Description" "bunch_count##description"}{...}
{viewerjumpto "Options" "bunch_count##options"}{...}
{viewerjumpto "Remarks" "bunch_count##remarks"}{...}
{viewerjumpto "Examples" "bunch_count##examples"}{...}
{title:Title}

{phang}
{bf:bunch_count} {hline 2} Calculate bunching statstics for a distribution. The method used is detailed in: {p_end}

                    Chetty, Friedman, Olsen and Pistaferri
                       Adjustment Costs, Firm Responses, 
                and Micro vs. Macro Labor Supply Elasticities:
                       Evidence from Danish Tax Records
           The Quarterly Journal of Economics, 2011, 126 (2): 749-804


{marker syntax}{...}
{title:Syntax}

{p 8 17 2}
{cmdab:bunch_count}
{it:x_var}
{it:count_x_var}
{ifin}
[{cmd:,} 
{it:Bunch_calc_options,} {it:Bunch_plot_options}]

{synoptset 20 tabbed}{...}
{synopthdr}
{synoptline}
{syntab:{it: varlist}}  
{synopt:{opt x_var}}Name of (binned) variable, the distribution of which we are studying.{p_end}
{synopt:{opt count_x_var}}Name of variable containing counts for each bin of {it:x_var}.{p_end}
{synoptline}
{syntab:Bunch_calc_options Options}
{synopt:{opt bpoint(#)}}Bunch point - eg kink point in tax system, measured in $; default is {cmd:bpoint(0)}{p_end}
{synopt:{opt binwidth(#)}}Bin width, measuerd in $; default is {cmd:binwidth(200)}{p_end}
{synopt:{opt degree(#)}}Degree of fitted polynomial; default is {cmd:degree(7)}{p_end}
{synopt:{opt max_it(#)}}Maximum number of iterations; default is {cmd:max_it(200)}{p_end}
{synopt:{opt nboot(#)}}Number of bootstrap samples; default is {cmd:nboot(0)}{p_end}
{synopt:{opt ig_low(#)}}When fitting the polynomial: Number of bins to consider on the left of the bunch point; default is {cmd:ig_low(-50)}{p_end}
{synopt:{opt ig_high(#)}}When fitting the polynomial: Number of bins to consider on the right of the bunch point; default is {cmd:ig_high(50)}{p_end}
{synopt:{opt low_bunch(#)}}Leftmost bin in bunching windows relative to bunch point; default is {cmd:low_bunch(-7)}{p_end}
{synopt:{opt high_bunch(#)}}Rightmost bin in bunching windows relative to bunch point; default is {cmd:low_bunch(7)}{p_end}
{synopt:{opt int2one(#)}}Defaut {cmd:int2one(1)} imposes the assumption that all excess mass in the bunching window comes from the right of the bunching window. {cmd:int2one(1)} ensures: area under counterfactual = area under actual distribution,{p_end}
{synoptline}

{syntab:Bunch_plot_options Options}
{synopt:{opt plot(#)}}{cmd:plot(1)} plots the actual distribution. The default {cmd:plot(0)} does not produce a graph.{p_end}
{synopt:{opt plot_fit(#)}}When {cmd:plot(1)} is specified, {cmd:plot_fit(1)} overlays the graph with the counterfactual distribution. The default is {cmd:plot_fit(1)}.{p_end}
{synopt:{opt graph_dir(string)}}Species the path to the directory where the graph will be stored.{p_end}
{synopt:{opt graph_name(string)}}Species the base name for the graph to be stored.{p_end}
{synopt:{opt graph_step(#)}}specifies the stepsize for Stata's {opth xlabel(axis_label_options)} option; the default is {cmd:graph_step(10)}{p_end}
{synopt:{opt zoom_low(#)}}A value higher than {cmd:ig_low} means that the graph will be zoomed from the left; the default {cmd:zoom_low(0)} imlies no zooming from the left.{p_end}
{synopt:{opt zoom_high(#)}}A value lower than {cmd:ig_high} means that the graph will be zoomed from the right; the default is {cmd:zoom_high(0)} implies not zooming from the right.{p_end}
{synopt:{opt pct_hgt(string)}}Scaling option. Attempts to set the minimum value on the y-axis to {cmd:pct_hgt}% of the average graph height in bunching window; the default value of {cmd:pct_hgt(101)} overrides scaling.{p_end}
{synopt:{opt use_xline(#)}}xline option: {cmd:use_xline(1)} creates a vertical line at a value of at {cmd:xline(#)}; Default value is {cmd:use_xline(1)}. Setting {cmd:use_xline(0)} implies no xline.{p_end}
{synopt:{opt xline(#)}}xline option: set where the first xline is going to be; default value is {cmd:xline(0)}.{p_end}
{synopt:{opt use_xline2(#)}}xline option: {cmd:use_xline2(1)} creates a vertical line at a value of at {cmd:xline2(#)}; Default value is {cmd:use_xline2(0)}. Setting {cmd:use_xline2(0)} implies no second xline.{p_end}
{synopt:{opt xline2(#)}}xline option: set where the second xline is going to be; default value is {cmd:xline(0)}.{p_end}
{synopt:{opt use_xline3(#)}}xline option: {cmd:use_xline3(1)} creates a vertical line at a value of at {cmd:xline3(#)}; Default value is {cmd:use_xline3(0)}. Setting {cmd:use_xline3(0)} implies no third xline.{p_end}
{synopt:{opt xline3(#)}}xline option: set where the third xline is going to be; default value is {cmd:xline(0)}.{p_end}
{synopt:{opt use_xtitle(#)}}xtitle option: Default {cmd:use_xtitle(1)} creates a title under the x-axis. {cmd:use_xtitle(0)} implies no xtitle.{p_end}
{synopt:{opt xtitle(string)}}xtitle option: Sets title of x-axis. If empty and {cmd:use_xtitle(1)} the xtitle will default to "Bin Group".{p_end}
{synopt:{opt outvar(string)}}While creating the graph, the data for it is written to three new variables {it:outvar1}, {it:outvar2}, and {it:outvar3}; default setting is {cmd:outvar(plotabc)}.{p_end}
{synopt:{opt png_export(#)}}Option to export graph in png format; default {cmd:png_export(0)} does not export graph as a png file, while {cmd:png_export(1)} does.{p_end}
{synopt:{opt wmf_export(#)}}Option to export graph in wmf format; default {cmd:wmf_export(1)} exports graph as a wmf file, while {cmd:wmf_export(0)} does not.{p_end}
{synoptline}         

{title:Remarks}

{pstd}
For detailed information on the technique used to calculate bunching at kink points, see:

                    Chetty, Friedman, Olsen and Pistaferri
                       Adjustment Costs, Firm Responses, 
                and Micro vs. Macro Labor Supply Elasticities:
                       Evidence from Danish Tax Records
           The Quarterly Journal of Economics, 2011, 126 (2): 749-804

{marker examples}{...}
{title:Examples}

{phang}{cmd:. bunch_count income freq if gender==1}{p_end}

{phang}{cmd:. bunch_count income freq if gender==1, bpoint(250000) binwidth(1000) nboot(100) plot(1) graph_dir("c:\graphs\") graph_step(4)}{p_end}
