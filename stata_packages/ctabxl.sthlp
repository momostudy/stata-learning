{smcl}
{* *! version 1.1  Published on GitHub July 17, 2023}{...}
{p2colset 2 12 14 28}{...}
{right: Version 1.1 }
{p2col:{bf:ctabxl} {hline 2}}Tabulate Pearson and Spearman correlations in Excel{p_end}
{p2colreset}{...}


{marker syntax}{...}
{title:Syntax}

{p 8 18 2}
{cmdab:ctabxl} {varlist}
{ifin}
{cmd:using} {it:{help filename}}
[{cmd:,}
{it:options}]

{synoptset 16 tabbed}{...}
{synopthdr}
{synoptline}
{synopt:{opt sheetname(text)}}specify custom sheet name; default sheet name is "Correlations"{p_end}
{synopt:{opt tablename(text)}}specify custom table name; default table name is "Correlations"{p_end}
{synopt:{opt replace}}required to overwrite an existing sheet in an existing Excel file; not required to add new sheets to an existing Excel file{p_end}
{synopt:{opt sig(#)}}set significance level; # must be between zero and one; p < # receives star, boldface, and/or italic; default is # = 0.05{p_end}
{synopt:{opt bonferroni}}use Bonferroni-adjusted significance level{p_end}
{synopt:{opt sidak}}use Sidak-adjusted significance level{p_end}
{synopt:{opt roundto(#)}}set number of decimal places to round to; # must be integer greater than zero and less than 27; default is # = 2{p_end}
{synopt:{opt nopw}}no pairwise correlations (explained below in {bf:Remarks}){p_end}
{synopt:{opt nozeros}}set zeros to missing to calculate correlations{p_end}
{synopt:{opt bold}}use boldfaced text to indicate statistical significance{p_end}
{synopt:{opt italic}}use italicized text to indicate statistical significance{p_end}
{synopt:{opt nostars}}do not use stars to indicate statistical significance{p_end}
{synopt:{opt pearsononly}}tabulate Pearson correlations in bottom triangle; omit Spearman from top{p_end}
{synopt:{opt spearmanonly}}tabulate Spearman correlations in bottom triangle; omit Pearson from top{p_end}
{synopt:{opt pearsonupper}}tabulate Pearson correlations in top triangle, Spearman in bottom; default is Pearson bottom, Spearman top{p_end}
{synopt:{opt noones}}omit ones from main diagonal of table{p_end}
{synopt:{opt 3stars(# # #)}}use three stars to indicate significance; # # # must contain three numbers between zero and one; p < the largest (smallest, other) # receives one (three, two) star(s){p_end}
{synopt:{opt extrarows(#)}}insert extra rows between correlations; # must be integer between one and 10{p_end}
{synopt:{opt extracols(#)}}insert extra columns between correlations; # must be integer between one and 10{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
  If {opt replace} specified, {opt ctabxl} overwrites sheet given by {opt sheetname(text)} (or "Correlations" if no {opt sheetname(text)} given); it does not alter other sheets in {it:filename}
  {p_end}


{marker description}{...}
{title:Description}

{pstd}{opt ctabxl} provides a variety of options for tabulating Pearson and Spearman correlations in Excel. These options are designed to:{p_end}

{p 8 12}(1) streamline the process of communicating results to coauthors, and{p_end}
{p 8 12}(2) minimize time spent transposing correlations to Word.{p_end}


{marker remarks}{...}
{title:Remarks}

{p 4 6 2}
  {opt ctabxl} tabulates pairwise correlations by default, which use all observations with nonmissing values for a pair of variables even if other variables are missing for the same observation.
  {p_end}

{p 4 6 2}
  The {opt nopw} option can be used to calculate nonpairwise correlations, which use an observation only if all variables in {it:varlist} are nonmissing.
  {p_end}

{p 4 6 2}
  For pairwise and nonpairwise correlations, the sample can be limited using {it:if} or {it:in} as you normally would in any other Stata command.
  {p_end}


{marker examples}{...}
{title:Examples}

{pstd}
Examples provided at {browse "www.zach.prof":zach.prof}
{p_end}


{marker contact}{...}
{title:Author}

{pstd}
Zachary King{break}
Email: {browse "mailto:zacharyjking90@gmail.com":zacharyjking90@gmail.com}{break}
Website: {browse "www.zach.prof":zach.prof}{break}
SSRN: {browse "https://papers.ssrn.com/sol3/cf_dev/AbsByAuth.cfm?per_id=2623799":https://papers.ssrn.com}
{p_end}


{title:Acknowledgements}

{pstd}
I thank the following individuals for helpful feedback and suggestions on {opt ctabxl}, this help file, and the associated documentation on {browse "www.zach.prof":zach.prof}:{p_end}

{pstd}
Derek Christensen{break}
Svenja Dube{break}
Clay Partridge
{p_end}