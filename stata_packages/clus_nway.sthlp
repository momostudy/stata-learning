{smcl}
{* *! version 3.0.0 09Oct2017}{...}
{cmd:help clus_nway}
{hline}

{title:Multi-way Clustering for Various Model Specifications}

{phang}
{bf:clus_nway} {hline 2} Perform clustering around arbitrarily many variables in variance-covariance 
matrix estimation for any model specification for which Stata allows 1 way clustering


{title:Syntax}

{p 8 17 2}
{cmdab:clus_nway}
{it:estimation_command}
{depvar} [{indepvars}] {ifin} 
[{it:{help regress##weight:weight}}],
{cmd:vce(cluster}
[{varlist}]
{cmd:)}
[{it:other options}]


{title:Description}

{pstd}
{cmd:clus_nway} performs n-way clustering for variance-covariance matrix estimation for any model specification for which 
Stata allows 1 way clustering.

{pstd}
This approach is based on Cameron, Gelbach and Miller (JBES 4/2011), especially equation 2.13 and on cgmreg.ado.
clus_nway is a generalization of cgmreg, which permits two-way clustering in ordinary least-squares regression,
because it allows arbitrarily many clustering variables and works as a wrapper around any of Stata's estimation commands.

{pstd}
The argument of clus_nway is the estimation command as it would normally be issued, except that instead of including 
only one clustering variable, all should be listed.  Note that the clustering variables must be integers (but see
the Examples section below to create integers based on string clustering variables).

{pstd}
This is a beta version of clus_nway. Feedback, comments, or questions are welcomed.


{title:Remarks}

{pstd}
Instead of running the regression once and using the residuals to calculate the appropriately clustered covariance matrix, this 
program uses combinatorial calculations to determine all the ways in which the observations should be clustered, runs the 
regression command for each, and combines the resulting cluster-based covariance matrices as appropriate. The underlying 
assumption is that execution time is cheap.  It does rise (somewhat faster than linearly) with the number of clustering variables.

{pstd}
Any display options included with the command are ignored.

{pstd}
The 'by' prefix cannot be used in any way with clus_nway, including prefixing it to the estimation_command that clus_nway calls.

{pstd}
Code for dealing with covariance matrices that are not positive-semi-definite is based on cgmreg.ado by
Cameron, Gelbach and Miller (2011).

{error}
{bf}
{title:Words to the Wise}

       {error}{bf}******************************************************************************
      {error}{bf}**                                                                            **
     *** {it}{text}It may be {bf:PROBLEMATIC} if the smallest number of clusters in any            {error}{bf}***
    {error}{bf}**** {it}{text}dimension is too small.                                                    {error}{bf}****
   *****                                                                            *****
  {error}{bf}****** {it}{text}Angrist and Pischke (2009, sec 8.2.3) are skeptical about the reliability  {error}{bf}******
 {error}{bf}******* {it}{text}of (1-way) clustered errors when the number of clusters is less than 42.   {error}{bf}*******
{error}{bf}********                                                                            ********
 {error}{bf}******* {it}{text}Bertrand, Duflo and Mullainathan (QJE 2004, Table VIII) present evidence   {error}{bf}*******
  {error}{bf}****** {it}{text}that as few as 20 clusters may be sufficient.                              {error}{bf}******
   {error}{bf}*****                                                                            *****
    {error}{bf}**** {it}{text}Also see Hansen (2007, JEcts 140, pp. 670-604) and                         {error}{bf}****
     {error}{bf}*** {it}{text}                (2007, JEcts 141, pp. 597-620).                            {error}{bf}***
      **                                                                            **
       ******************************************************************************
{smcl}
{text}
{sf}

{title:Examples}

{pstd}
One-way clustering:

	{cmd:. regress y x if z, vce(cluster clus_1)}

{pstd}
Two-way clustering:

	{cmd:. clus_nway regress y x if z, vce(cluster clus_1 clus_2)}
	{cmd:. clus_nway logit BinaryY x if z, vce(cluster clus_1 clus_2)}
	{cmd:. clus_nway poisson CountY x if z, vce(cluster clus_1 clus_2)}

{pstd}
If your cluster variables are strings, the following lines will 
create integer versions, which can be used with clus_nway:

	{cmd:. encode clus_1_string, generate(clus_1_int)}
	{cmd:. encode clus_n_string, generate(clus_n_int)}
	{cmd:. clus_nway regress y x if z, vce(cluster clus_1_int clus_n_int)}

{pstd}
clus_nway will still work with estimation commands that employ out-dated
syntax for clustering (e.g., relogit by King & Zeng 2001):

	{cmd:. clus_nway relogit RareEventY x if z, cluster (clus_1 clus_2)}


{title:Citation Information}

{pstd}
When using this .ado file, please cite both of the following papers:

{pstd}
Kleinbaum, Adam M., Toby E. Stuart, and Michael L. Tushman (2013). "Discretion within Constraint: Homophily and Structure 
in a Formal Organization." Organization Science 24(5): 1316-1336 (available at bit.ly/clus_nway).

{pstd}
Cameron, A. Colin, Jonah B. Gelbach, and Douglas L. Miller. 2011. "Robust Inference with Multi-way Clustering." 
Journal of Business and Economic Statistics 29(2): 238-49.


{title:Statement on Copyrights}

{pstd}
Copyright 2011-12 Paul Wolfson and Adam M. Kleinbaum

{pstd}
This program is free software: you can redistribute it and/or modify it under the terms of the GNU General 
Public License (version 3) as published by the Free Software Foundation.

{pstd}
This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied 
warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

{pstd}
A copy of the GNU General Public License is available at http://www.gnu.org/licenses/.


{title:Authors}

{pstd}
Paul J. Wolfson, 
Senior Statistical Research Associate, 
Tuck School of Business at Dartmouth

{pstd}
Adam M. Kleinbaum, 
Associate Professor, 
Tuck School of Business at Dartmouth 
