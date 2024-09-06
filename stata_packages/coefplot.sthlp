{smcl}
{* *! version 1.5.2  21apr2022 Ben Jann}{...}
{vieweralsosee "[G-2] graph" "help graph"}{...}
{vieweralsosee "[R] estimates" "help estimates"}{...}
{vieweralsosee "[R] marginsplot" "help marginsplot"}{...}
{vieweralsosee "[R] margins" "help margins"}{...}
{viewerjumpto "Syntax" "coefplot##syntax"}{...}
{viewerjumpto "Description" "coefplot##description"}{...}
{viewerjumpto "Options" "coefplot##options"}{...}
{viewerjumpto "Examples" "coefplot##examples"}{...}
{viewerjumpto "Remarks" "coefplot##remarks"}{...}
{viewerjumpto "Saved results" "coefplot##saved_results"}{...}
{viewerjumpto "References" "coefplot##references"}{...}
{viewerjumpto "Author" "coefplot##author"}{...}
{viewerjumpto "History" "coefplot##history"}{...}
{hi:help coefplot}{...}
{right:{browse "http://repec.sowi.unibe.ch/stata/coefplot"}}
{right:{browse "http://github.com/benjann/coefplot"}}
{hline}

{title:Title}

{pstd}
    {hi:coefplot} {hline 2} Plotting regression coefficients and other
    results

{marker syntax}{...}
{title:Syntax}

{p 8 15 2}
    {cmd:coefplot} {it:subgraph} [ || {it:subgraph} || ... ]
    [{cmd:,} {help coefplot##globalopts:{it:globalopts}} ]

{pstd}
    where {it:subgraph} is defined as

{p 8 16 2}
    {cmd:(}{it:plot}{cmd:)} [ {cmd:(}{it:plot}{cmd:)} ... ]
    [, {help coefplot##subgropts:{it:subgropts}} ]

{pstd}
    and {it:plot} is either {cmd:_skip} (to skip a plot) or

{p 8 16 2}
    {it:model} [ \ {it:model} \ ... ]
    [, {help coefplot##plotopts:{it:plotopts}} ]

{pstd}
    and {it:model} is

{p 8 16 2}
    {it:namelist} [{cmd:,} {help coefplot##modelopts:{it:modelopts}} ]

{pstd}
    where {it:namelist} is a list of names of stored models
    (see help {helpb estimates}; type {cmd:.} or leave blank to refer to
    the active model). The {cmd:*} and {cmd:?} wildcards are allowed
    in {it:namelist}; see
    {help coefplot##wildcards:{it:Using wildcards in model names}}. Furthermore,
    {it:model} may also be

{p 8 16 2}
    {helpb coefplot##matrix:{ul:m}atrix({it:mspec})} [{cmd:,} {help coefplot##modelopts:{it:modelopts}} ]

{pstd}
    to plot results from a matrix (see
    {help coefplot##matrix:{it:Plotting results from matrices}} below).
    Parentheses around {it:plot} can be omitted if {it:plot} does not contain
    spaces.

{synoptset 25 tabbed}{...}
{marker modelopts}{synopthdr:modelopts}
{synoptline}
{syntab:Main}
{synopt:{helpb coefplot##omitted:{ul:omit}ted}}include omitted
    coefficients
    {p_end}
{synopt:{helpb coefplot##baselevels:{ul:base}levels}}include base levels
    {p_end}
{synopt:{helpb coefplot##b:b({it:mspec})}}specify source to be plotted; default is to
    plot {cmd:e(b)}
    {p_end}
{synopt:{helpb coefplot##at:at{sf:[}({it:spec}){sf:]}}}get plot positions from
    {cmd:e(at)}, or as specified by {it:spec}
    {p_end}
{synopt:{helpb coefplot##keep:keep({it:coeflist})}}keep specified coefficients
    {p_end}
{synopt:{helpb coefplot##drop:drop({it:coeflist})}}drop specified coefficients
    {p_end}

{syntab:Confidence intervals}
{synopt:{helpb coefplot##noci:noci}}omit confidence intervals
    {p_end}
{synopt:{helpb coefplot##levels:{ul:l}evels({it:numlist})}}set level(s) for
    conficence intervals
    {p_end}
{synopt:{helpb coefplot##ci:ci({it:spec})}}provide confidence intervals
    {p_end}
{synopt:{helpb coefplot##v:v({it:name})}}provide variances; default is to use
    {cmd:e(V)}
    {p_end}
{synopt:{helpb coefplot##se:se({it:mspec})}}provide standard errors
    {p_end}
{synopt:{helpb coefplot##df:df({it:spec})}}provide degrees of freedom
    {p_end}
{synopt:{helpb coefplot##citype:citype({it:method})}}method to compute
    confidence intervals; default is {cmd:citype(normal)}
    {p_end}

{syntab:Transform results}
{synopt:{helpb coefplot##eform:eform{sf:[}({it:coeflist}){sf:]}}}plot
    exponentiated point estimates and confidence intervals
    {p_end}
{synopt:{helpb coefplot##rescale:rescale({it:spec})}}rescale point estimates
    and confidence intervals
    {p_end}
{synopt:{helpb coefplot##transform:{ul:trans}form({it:matchlist})}}transform
    point estimates and confidence intervals
    {p_end}

{syntab:Names and labels}
{synopt:{helpb coefplot##rename:rename({it:spec})}}rename coefficients
    {p_end}
{synopt:{helpb coefplot##eqrename:{ul:eqren}ame({it:spec})}}rename
    equations
    {p_end}
{synopt:{helpb coefplot##asequation:{ul:aseq}uation{sf:[}({it:string}){sf:]}}}set equation
    to model name or {it:string}
    {p_end}
{synopt:{helpb coefplot##swapnames:{ul:swap}names}}swap coefficient names and
    equation names
    {p_end}
{synopt:{helpb coefplot##mlabels:mlabels({it:matchlist})}}add custom marker labels
    {p_end}

{syntab:Auxiliary results}
{synopt:{helpb coefplot##aux:aux({sf:{it:mspec} [{it:mspec} ...]})}}make
    additional results available as {cmd:@aux1}, {cmd:@aux2}, etc.
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker plotopts}{synopthdr:plotopts}
{synoptline}
{syntab:Passthru}
{synopt:{help coefplot##modelopts:{it:modelopts}}}plot-specific model options;
    see {help coefplot##place:{it:Placement of options}}
    {p_end}

{syntab:Main}
{synopt:{helpb coefplot##label:{ul:lab}el({it:string})}}label to be used for
    the plot in the legend
    {p_end}
{synopt:{helpb coefplot##key:key{sf:[}(ci {sf:[}#{sf:]}){sf:]}}}key
    symbol to be used for the plot in the legend
    {p_end}
{synopt:{helpb coefplot##nokey:nokey}}do not include the plot in the legend
    {p_end}
{synopt:{helpb coefplot##pstyle:{ul:psty}le({it:pstyle})}}overall
    style of the plot
    {p_end}
{synopt:{helpb coefplot##axis:{ul:ax}is({it:#})}}choice of axis for the plot, {cmd:1} {ul:<} {it:#} {ul:<} {cmd:9}
    {p_end}
{synopt:{helpb coefplot##offset:offset({it:#})}}provide offset for plot
    positions
    {p_end}
{synopt:{helpb coefplot##ifopt:if({it:exp})}}restrict the contents of the plot
    {p_end}
{synopt:{helpb coefplot##weight:{ul:w}eight({it:exp})}}scale size of markers
    {p_end}

{syntab:Markers}
{synopt:{it:{help marker_options}}}change look of
    markers (color, size, etc.)
    {p_end}
{synopt:{helpb coefplot##mlabel:{ul:ml}abel{sf:[}({it:spec}){sf:]}}}add marker
    labels
    {p_end}
{synopt:{it:{help marker_label_options}}}change the look and position of marker
    labels
    {p_end}
{synopt:{helpb coefplot##recast:recast({it:plottype})}}plot results using
    {it:plottype}
    {p_end}

{syntab:Confidence spikes}
{synopt:{helpb coefplot##cionly:cionly}}plot confidence spikes only
    {p_end}
{synopt:{helpb coefplot##citop:citop}}draw confidence spikes in front
    of markers
    {p_end}
{synopt:{helpb coefplot##cirecast:{ul:cire}cast({it:plottype})}}shorthand for {cmd:ciopts(recast())}
    {p_end}
{synopt:{helpb coefplot##ciopts:{ul:ciop}ts({it:options})}}affect rendition
    of confidence spikes
    {p_end}
{synopt:{helpb coefplot##cismooth:{ul:cis}mooth{sf:[}({it:options}){sf:]}}}add smoothed
    confidence intervals
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker subgropts}{synopthdr:subgropts}
{synoptline}
{syntab:Passthru}
{synopt:{help coefplot##modelopts:{it:modelopts}}}subgraph-specific model
    options; see {help coefplot##place:{it:Placement of options}}
    {p_end}
{synopt:{help coefplot##plotopts:{it:plotopts}}}subgraph-specific plot
    options; see {help coefplot##place:{it:Placement of options}}
    {p_end}

{syntab:Main}
{synopt:{helpb coefplot##bylabel:{ul:bylab}el({it:string})}}label to be used
    for the subgraph
    {p_end}
{synoptline}

{synoptset 25 tabbed}{...}
{marker globalopts}{synopthdr:globalopts}
{synoptline}
{syntab:Passthru}
{synopt:{help coefplot##modelopts:{it:modelopts}}}global model options; see
    {help coefplot##place:{it:Placement of options}}
    {p_end}
{synopt:{help coefplot##plotopts:{it:plotopts}}}global plot options; see
    {help coefplot##place:{it:Placement of options}}
    {p_end}
{synopt:{help coefplot##subgropts:{it:subgropts}}}global subgraph options;
    see {help coefplot##place:{it:Placement of options}}
    {p_end}

{syntab:Main}
{synopt:{helpb coefplot##horizontal:{ul:hor}izontal}}coefficient values are
    on x axis; general default
    {p_end}
{synopt:{helpb coefplot##vertical:{ul:vert}ical}}coefficient values are on y
    axis; default with {cmd:at()}
    {p_end}
{synopt:{helpb coefplot##eqstrict:eqstrict}}be strict about equations
    {p_end}
{synopt:{helpb coefplot##order:order({it:coeflist})}}order coefficients
    {p_end}
{synopt:{helpb coefplot##orderby:orderby({it:spec})}}order coefficients by
    specific model
    {p_end}
{synopt:{helpb coefplot##sort:sort{sf:[}({it:spec}){sf:]}}}sort coefficients
    {p_end}
{synopt:{helpb coefplot##relocate:{ul:reloc}ate({it:spec})}}assign
    specific positions to coefficients
    {p_end}
{synopt:{helpb coefplot##bycoefs:{ul:byc}oefs}}arrange subgraphs by
    coefficients
    {p_end}
{synopt:{helpb coefplot##norecycle:{ul:norec}ycle}}increment plot styles across
    subgraphs
    {p_end}
{synopt:{helpb coefplot##nooffsets:{ul:nooff}sets}}do not offset plot
    positions
    {p_end}
{synopt:{helpb coefplot##format:format({it:format})}}set the display format for
    numeric labels
    {p_end}
{synopt:{helpb coefplot##pnum:p{it:#}({it:plotopts})}}options for {it:#}th plot
    {p_end}

{syntab:Labels and grid lines}
{synopt:{helpb coefplot##nolabels:{ul:nolab}els}}use variable names instead of
    labels
    {p_end}
{synopt:{helpb coefplot##coeflabels:{ul:coefl}abels({it:spec})}}specify
    custom labels for coefficients
    {p_end}
{synopt:{helpb coefplot##noeqlabels:{ul:noeql}abels}}suppress equation labels
    {p_end}
{synopt:{helpb coefplot##eqlabels:{ul:eql}abels({it:spec})}}specify labels
    for equations
    {p_end}
{synopt:{helpb coefplot##headings:{ul:head}ings({it:spec})}}add headings between
    coefficients
    {p_end}
{synopt:{helpb coefplot##groups:groups({it:spec})}}add labels for groups of
    coefficients
    {p_end}
{synopt:{helpb coefplot##plotlabels:{ul:plotl}abels({it:spec})}}(re)set plot
    labels
    {p_end}
{synopt:{helpb coefplot##bylabels:bylabels({it:spec})}}(re)set subgraph
    labels
    {p_end}
{synopt:{helpb coefplot##grid:grid({it:options})}}affect rendition of grid lines
    {p_end}

{syntab:Save results}
{synopt:{helpb coefplot##generate:{ul:gen}erate{sf:[}({it:prefix}){sf:]}}}generate
    variables containing the graph data
    {p_end}
{synopt:{helpb coefplot##replace:replace}}overwrite existing variables
    {p_end}

{syntab:Add plots}
{synopt:{helpb addplot_option:addplot({it:plot})}}add other plots to the
    graph
    {p_end}
{synopt:{helpb coefplot##nodrop:nodrop}}do not drop observations
    {p_end}

{syntab:Y axis, X axis, Titles, Legend, Overall, By}
{synopt:{it:{help twoway_options}}}twoway options, other than {cmd:by()}
    {p_end}
{synopt:{cmdab:byop:ts(}{it:{help by_option:byopts}}{cmd:)}}how subgraphs
    are combined
    {p_end}
{synoptline}


{marker description}{...}
{title:Description}

{pstd}
    {cmd:coefplot} plots results from estimation commands or Stata matrices.
    Results from multiple models or matrices can be combined in a single
    graph. The default behavior of {cmd:coefplot} is to draw markers for
    coefficients and horizontal spikes for confidence intervals. However,
    {cmd:coefplot} can also produce various other types of graphs.


{marker options}{...}
{title:Options}
{dlgtab:Model options}

{marker omitted}{...}
{phang}
    {cmd:omitted} includes omitted coefficients. This may be useful if a model
    contains coefficients that have been dropped due to collinearity.

{marker baselevels}{...}
{phang}
    {cmd:baselevels} includes base levels of factor variables.

{marker b}{...}
{phang}
    {cmd:b(}{it:mspec}{cmd:)} specifies the source from which the point
    estimates and coefficient names are to be collected. The default is to use
    (the first row of) {cmd:e(b)} (or {cmd:e(b_mi)} if plotting results from
    {helpb mi estimate}). {cmd:b()} is discarded in matrix mode (see
    {help coefplot##matrix:{it:Plotting results from matrices}} below).
    {it:mspec} may be:

{p2colset 13 25 27 2}{...}
{p2col:{it:name}}use first row of {cmd:e(}{it:name}{cmd:)}
    {p_end}
{p2col:{it:name}{cmd:[}#{cmd:,.]}}use #th row of
    {cmd:e(}{it:name}{cmd:)}; may also type {it:name}{cmd:[}#{cmd:,]}
    or {it:name}{cmd:[}#{cmd:]}
    {p_end}
{p2col:{it:name}{cmd:[.,}#{cmd:]}}use #th column of
    {cmd:e(}{it:name}{cmd:)}; may also type {it:name}{cmd:[,}#{cmd:]}
    {p_end}
{p2colreset}{...}

{marker at}{...}
{phang}
    {cmd:at}[{cmd:(}{it:spec}{cmd:)}] causes plot positions to be determined
    by the values in {cmd:e(at)} (or matrix {cmd:at}) or as specified by
    {it:spec}. The default is to create a categorical axis with coefficients
    matched by their names. However, if {cmd:at} is specified, the axis is
    treated as continuous. Note that labeling options
    {cmd:coeflabels()}, {cmd:eqlabels()}, {cmd:headings()}, or {cmd:groups()}
    are not allowed if {cmd:at} is specified. Also not allowed with {cmd:at}
    are options {cmd:bycoefs}, {cmd:order()}, and {cmd:relocate()}.
    Furthermore, note that {cmd:at} has to be specified for all models or
    for none. {it:spec} is

            [{it:atspec}] [{cmd:,} {opt t:ransform(exp)}]

{pmore}
    where {it:atspec} may be

{p2colset 13 27 29 2}{...}
{p2col:{it:mspec}}as above for {helpb coefplot##b:b()}
    {p_end}
{p2col:#}use #th at-dimension ({helpb margins}) or #th row/column of main matrix
    {p_end}
{p2col:{opt m:atrix(mspec)}}read from matrix instead of {cmd:e()}
    {p_end}
{p2col:{opt _coef}}use coefficient names as plot positions
    {p_end}
{p2col:{opt _eq}}use equation names as plot positions
    {p_end}
{p2colreset}{...}

{pmore}
    If {cmd:at} is specified without argument, the plot positions are taken from the first row
    of {cmd:e(at)} (or matrix {cmd:at}). A special case are results from
    {helpb margins} where recovering the plot positions is more
    complicated. The default in this case is to use the first
    at-dimension. Type, e.g., {cmd:at(2)} if multiple at-dimension were specified
    with {helpb margins} and you want to use the second dimension. Furthermore,
    in matrix mode (see
    {help coefplot##matrix:{it:Plotting results from matrices}} below), {cmd:at(2)}
    would read the plot positions from the 2nd row (or column) of the main matrix.

{pmore}
    When plotting results from {cmd:e()} it is sometimes convenient to
    maintain an external matrix with the plot positions instead of
    adding plot positions to each {cmd:e()}-set. In this case you can use
    syntax {cmd:at(matrix(}{it:mspec}{cmd:))} to read the plot positions. Note
    that the vector of plot positions must have the same length as the
    coefficient vectors of the plotted models; elements are matched by position,
    not by name.

{pmore}
    Furthermore, {cmd:at(_coef)} or {cmd:at(_eq)} will use the coefficient names or
    the equation names as plot positions, respectively. This is useful only if
    the coefficient names or the equation names are numeric. Note that you may
    use {helpb coefplot##rename:rename()} and
    {helpb coefplot##eqrename:eqrename()} to strip a non-numeric prefix or suffix
    from coefficient names or equation names.

{pmore}
    Suboption {cmd:transform()} transforms the plot positions before creating
    the graph. Within the transformation expression, use {cmd:@} as a
    placeholder for the value to be transformed. For example, to take the
    antilogarithm of the plot positions type {cmd:transform(exp(@))}.

{marker keep}{...}
{phang}
    {cmd:keep(}{it:coeflist}{cmd:)} specifies the coefficients to be
    plotted. The default is to include all coefficients from the
    first (nonzero) equation of a model (and discard further equations).
    {it:coeflist} is a space-separated list of
    elements such as:

{p2colset 13 25 27 2}{...}
{p2col:{it:coef}}keep coefficient {it:coef}
    {p_end}
{p2col:{it:eq}{cmd::}}keep all coefficients from equation {it:eq}
    {p_end}
{p2col:{it:eq}{cmd::}{it:coef}}keep coefficient {it:coef} from equation {it:eq}
    {p_end}
{p2colreset}{...}

{pmore}
    where {it:eq} and {it:coef} may contain "{cmd:*}" (any string) and
    "{cmd:?}" (any nonzero character) wildcards. For example, type {cmd:keep(*:)} or
    {cmd:keep(*:*)} to plot all coefficients from all equations.

{pmore}
    If {it:eq} is specified, it is applied to all subsequent
    names until a new {it:eq} is specified. For example,
    {cmd:keep(3:mpg price 4:weight)} will plot coefficients "{cmd:mpg}" and
    "{cmd:price}" from equation "{cmd:3}" and coefficient "{cmd:weight}" from
    equation "{cmd:4}".

{marker drop}{...}
{phang}
    {cmd:drop(}{it:coeflist}{cmd:)} drops the specified coefficients, where
    {it:coeflist} is as above for {helpb coefplot##keep:keep()}.

{marker noci}{...}
{phang}
    {cmd:noci} omits confidence intervals.

{marker levels}{...}
{phang}
    {cmd:levels(}{it:{help numlist}}{cmd:)} sets the level(s), as percentages,
    for confidence intervals. Specified values may be between 10.00 and 99.99
    and can have at most two digits after the decimal point. The default is
    {cmd:levels(95)} or as set by {helpb set level}. If multiple values are
    specified, multiple confidence intervals are plotted. For example, type
    {cmd:levels(99.9 99 95)} to plot the 99.9%, 99%, and 95% confidence
    intervals. The default is to use (logarithmically) increasing line widths
    for multiple confidence intervals. This behavior is disabled as soon as
    {cmd:lwidth()} or {cmd:recast()} is specified within
    {helpb coefplot##ciopts:ciopts()}.

{marker ci}{...}
{phang}
    {cmd:ci(}{it:spec}{cmd:)} specifies the source from which to collect
    confidence intervals. Default is to compute confidence intervals for the
    levels specified in {cmd:levels()} using variances/standard errors (and,
    possibly, degrees of freedom). The {cmd:ci()} option is useful to
    plot confidence intervals that have been provided by the estimation
    command (such as, e.g., {helpb bootstrap}). {it:spec} is

            {it:cispec} [{it:cispec} ...]

{pmore}
    where {it:cispec} is {it:name} to get the lower and upper confidence limits
    from rows 1 and 2 of {cmd:e(}{it:name}{cmd:)} (or matrix {it:name}),
    respectively. Alternatively, {it:cispec} may be {cmd:(}{it:mspec}
    {it:mspec}{cmd:)} to identify the lower and upper confidence limits, with
    {it:mspec} as above for {helpb coefplot##b:b()}. For example, after
    {helpb bootstrap}, {cmd:ci(ci_bc)} would get bias-corrected confidence intervals
    from rows 1 and 2 of {cmd:e(ci_bc)}. The same could be achieved by
    {cmd:ci((ci_bc[1] ci_bc[2]))}.

{pmore}
    {it:cispec} may also be # for a specific confidence level as in
    {helpb coefplot##levels:levels()}. Hence, you may type, e.g.,
    {cmd:ci(95 myci)} to plot the usual 95% confidence intervals along with
    custom confidence intervals provided in {cmd:e(myci)}. Levels specified
    in {cmd:ci()} take precedence over levels specified in {cmd:levels()}),
    however, you may also type {cmd:""} within {cmd:ci()} to leave a
    position blank an use the specified level from {cmd:levels()}.

{pmore}
    In matrix mode (see
    {help coefplot##matrix:{it:Plotting results from matrices}} below),
    {it:cispec} may also be {cmd:(}# #{cmd:)}. For example, {cmd:ci((2 3))} would
    read the lower confidence limit from the 2nd row (or column) and
    the upper confidence limit from the 3rd row (or column) of the main matrix.

{marker v}{...}
{phang}
    {cmd:v(}{it:name}{cmd:)} specifies that the variances for confidence interval
    computation are to be taken from the diagonal of {cmd:e(}{it:name}{cmd:)}
    (or matrix {it:name}). Default is {cmd:e(V)} (or {cmd:e(V_mi)} if plotting
    results from {helpb mi estimate}).

{marker se}{...}
{phang}
    {cmd:se(}{it:mspec}{cmd:)} provides standard errors to be used for
    computation of confidence intervals. Default is to compute confidence
    intervals based on the variances in {cmd:e(V)}
    (see {helpb coefplot##v:v()} above). {it:mspec} is as above for
    {helpb coefplot##b:b()}.
    In matrix mode (see
    {help coefplot##matrix:{it:Plotting results from matrices}} below), you may
    also specify {cmd:se(}#{cmd:)} to read the standard errors from the #th
    row (or column) of the main matrix.

{marker df}{...}
{phang}
    {cmd:df(}{it:spec}{cmd:)} specifies degrees of freedom (DF) to be taken into
    account for confidence interval computation. Default is to obtain DF
    from scalar {cmd:e(df_r)} if defined (as in, e.g., {helpb regress})
    or, for results from {helpb mi estimate}, from matrix {cmd:e(df_mi)}. Otherwise,
    no DF are taken into account. Specify {cmd:df(}{it:spec}{cmd:)} to provide
    custom DF. {it:spec} may be:

{p2colset 13 25 27 2}{...}
{p2col:#}set DF for all coefficients to #
    {p_end}
{p2col:{it:mspec}}as above for {helpb coefplot##b:b()}
    {p_end}
{p2colreset}{...}

{marker citype}{...}
{phang}
    {cmd:citype(}{it:method}{cmd:)} specifies the method to be used to compute the limits of
    confidence intervals. {it:method} can be {cmd:normal}, {cmd:logit}, {cmd:probit},
    {cmd:atanh}, or {cmd:log}.

{pmore}
    {cmd:citype(normal)}, the default, computes confidence
    limits based on untransformed coefficients and standard errors. Let {it:b} be
    the point estimate, {it:se} the standard error, and {it:t} the (1-{it:a}/2)
    quantile of the standard normal distribution or the t-distribution (if degrees
    of freedom are available; see above), where {it:a} is 1 minus the
    confidence level (e.g. {it:a}=5% for a 95% confidence interval). Then the
    limits of the confidence interval are computed as

            {it:b} +/- {it:t} * {it:se}

{pmore}
    {cmd:citype(logit)} uses the logit transformation to compute the limits
    of confidence intervals. This is useful if the estimates to be plotted are
    proportions and the confidence limits are supposed to lie between 0 and
    1. The limits are computed as

            invlogit(logit({it:b}) +/- {it:t} * {it:se} / ({it:b} * (1 - {it:b})))

{pmore}
    {cmd:citype(probit)} is an alternative to {cmd:citype(logit)} and computes the
    limits as

            normal(invnormal({it:b}) +/- {it:t} * {it:se} / normalden(invnormal({it:b})))

{pmore}
    {cmd:citype(atanh)} uses the inverse hyperbolic tangent to compute the
    confidence intervals. This is useful for estimates that lie between -1 and
    1, such as a correlation coefficient. The limits are computed as:

            tanh(atanh({it:b}) +/- {it:t} * {it:se} / (1 - {it:b}^2))

{pmore}
    {cmd:citype(log)} computes log-transformed confidence intervals. This is useful
    for estimates that may only be positive, such as a variance estimate. The limits
    are computed as:

            exp(ln({it:b}) +/- {it:t} * {it:se} / {it:b})

{marker eform}{...}
{phang}
    {cmd:eform}[{cmd:(}{it:coeflist}{cmd:)}] causes point estimates and
    confidence intervals to be exponentiated. This is useful
    if you want to plot hazard ratios (HR), incidence-rate ratios (IRR),
    odds ratios (OR), or relative-risk ratios (RRR). If {cmd:eform} is
    specified without arguments, then all coefficients of the model are
    exponentiated. To exponentiate only selected coefficients, specify
    {it:coeflist} as above for {helpb coefplot##keep:keep()}.

{marker rescale}{...}
{phang}
    {cmd:rescale(}{it:spec}{cmd:)} rescales point estimates and confidence
    intervals. Type {cmd:rescale(}#{cmd:)} to rescale all coefficients
    by a constant factor. For example, {cmd:rescale(100)} will multiply all
    coefficients by 100. Alternatively, {it:spec} may be

            {it:coeflist} {cmd:=} # [{it:coeflist} {cmd:=} # ...]

{pmore}
    with {it:coeflist} as above for {helpb coefplot##keep:keep()}.

{marker transform}{...}
{phang}
    {cmd:transform(}{it:matchlist}{cmd:)} transforms point estimates and confidence
    intervals. {it:machlist} is:

            {it:coeflist} {cmd:= "}{it:{help exp}}{cmd:"}  [{it:coeflist} {cmd:= "}{it:{help exp}}{cmd:"} ...]

{pmore}
    with {it:coeflist} as above for {helpb coefplot##keep:keep()}. Within the
    transformation expression, use {cmd:@} as a placeholder for
    the value to be transformed. For example, to take the square root of all
    coefficients type {cmd:transform(* = sqrt(@))}. In addition, internal
    variables may be used as explained in
    {help coefplot##tempvar:Accessing internal temporary variables}. The
    transformation expression must be enclosed in double quotes if it contains
    spaces. If specified, {cmd:eform()} and {cmd:rescale()} are applied before applying
    {cmd:transform()}.

{marker rename}{...}
{phang}
    {cmd:rename(}{it:spec}{cmd:)} renames coefficients. {it:spec} is:

            {it:coeflist} {cmd:=} {it:newname} [{it:coeflist} {cmd:=} {it:newname} ...] [{cmd:,} {cmdab:r:egex}]

{pmore}
    with {it:coeflist} as above for {helpb coefplot##keep:keep()} except that
    wildcards are only allowed in equation names, and coefficient names may
    be specified as {it:prefix}{cmd:*} to replace a prefix or
    {cmd:*}{it:suffix} to replace a suffix. For example,
    {cmd:rename(*.foreign = .cartype)} will rename coefficients such as
    {cmd:0.foreign} and {cmd:1.foreign} to {cmd:0.cartype} and
    {cmd:1.cartype}. {it:newname} must be enclosed in double quotes if it
    contains spaces. For labeling coefficients, also see
    {helpb coefplot##coeflabels:coeflabels()}.

{pmore}
    Apply option {cmd:regex} to cause coefficient specifications (but not
    equation specifications) to be interpreted as
    {browse "https://en.wikipedia.org/wiki/Regular_expression":regular expressions}. In this
    case, {it:newname} may contain {cmd:\1}, ..., {cmd:\9} to reference back to
    matched subexpressions (and {cmd:\0} for the entire match). For example, type
    {cmd:rename(^AA([0-9]+)BB$ = YY\1ZZ, regex)} to rename
    coefficients such as {cmd:AA123BB}, {cmd:AA0BB}, or {cmd:AA99BB} to
    {cmd:YY123ZZ}, {cmd:YY0ZZ}, or {cmd:YY99ZZ}. If the leading {cmd:^} or the
    tailing {cmd:$} is omitted, only the matched part of a coefficient name is
    subject to substitution; the rest of the name will remain unchanged. Include
    the regular expressions in quotes or compound double quotes if they contain
    funny characters (such as, e.g., quotes, equal signs, or commas).

{marker eqrename}{...}
{phang}
    {cmd:eqrename(}{it:spec}{cmd:)} renames equations. {it:spec} is:

            {it:eqlist} {cmd:=} {it:newname} [{it:eqlist} {cmd:=} {it:newname} ...] [{cmd:,} {cmdab:r:egex}]

{pmore}
    where {it:eqlist} is a space separated list of equation names. Equation
    names may be {it:prefix}{cmd:*} to replace a prefix or
    {cmd:*}{it:suffix} to replace a suffix. For example,
    {cmd:eqrename(rep78* = reprec)} will rename equations such as
    {cmd:rep78_3} and {cmd:rep78_4} to {cmd:reprec_3} and
    {cmd:reprec_4}. {it:newname} must be enclosed in double quotes if it
    contains spaces. For labeling equations, also see
    {helpb coefplot##eqlabels:eqlabels()}.

{pmore}
    Apply option {cmd:regex} to cause equation specifications to be interpreted as
    {browse "https://en.wikipedia.org/wiki/Regular_expression":regular expressions}. In this
    case, {it:newname} may contain {cmd:\1}, ..., {cmd:\9} to reference back to
    matched subexpressions (and {cmd:\0} for the entire match). For example, type
    {cmd:eqrename(^eq([0-9])0$ = Outcome_\1, regex)} to rename
    equations such as {cmd:eq20} or {cmd:eq90} to
    {cmd:Outcome_1} or {cmd:Outcome_9}. If the leading {cmd:^} or the
    tailing {cmd:$} is omitted, only the matched part of an equation name is
    subject to substitution; the rest of the name will remain unchanged. Include the regular expressions in
    quotes or compound double quotes if they contain funny characters (such as, e.g., quotes,
    equal signs, or commas).

{marker asequation}{...}
{phang}
    {cmd:asequation}[{cmd:(}{it:string}{cmd:)}] sets the equation name for all
    included coefficients from the model to {it:string}. This is useful if you
    want to assign an equation name to results that have been stored without
    information on equations. If {cmd:asequation} is specified without
    argument, the name of the model is used. If you apply the
    {cmd:asequation()} option you may also want to specify
    {helpb coefplot##eqstrict:eqstrict}.

{marker swapnames}{...}
{phang}
    {cmd:swapnames} swaps coefficient names and equation names after collecting
    the model's results. The names are swapped after applying model options
    such as {cmd:keep()}, {cmd:drop()}, or {cmd:rename()} but
    before applying global options such as {cmd:coeflabel()}, {cmd:order()},
    or {cmd:eqlabels()}.

{marker mlabels}{...}
{phang}
    {cmd:mlabels(}{it:matchlist}{cmd:)} specifies marker labels for
    selected coefficients. {it:matchlist} is:

            {it:coeflist} {cmd:=} # "{it:label}" [{it:coeflist} {cmd:=} # "{it:label}" ...]

{pmore}
    where {it:coeflist} is as above for {helpb coefplot##keep:keep()} and # is a
    number 0--12 for the location of the marker label (see
    {manhelpi clockposstyle G-4}). Not all of Stata's plot types
    support marker labels. For example, if you use
    {helpb coefplot##recast:recast(bar)} to change the plot type to
    {helpb twoway_bar:bar}, no marker labels will be displayed (this has
    changed with the April 6, 2022, update to Stata 17; plot type 
    {helpb twoway_bar:bar} now displays marker labels).

{marker aux}{...}
{phang}
    {cmd:aux(}{it:mspec} [{it:mspec} ...]{cmd:)} collects additional results
    and makes them available as internal variables. {it:mspec} is as above for
    {helpb coefplot##b:b()}. The internal variables
    are named {cmd:@aux1}, {cmd:@aux2}, ..., and can be used within
    {helpb coefplot##ifopt:if()},
    {helpb coefplot##weight:weight()},
    {helpb coefplot##transform:transform()},
    {helpb marker_label_options:mlabel()},
    {helpb marker_label_options:mlabvposition()}, and
    {helpb addplot_option:addplot()} (see
    {help coefplot##tempvar:Accessing internal temporary variables}
    below). In matrix mode (see
    {help coefplot##matrix:{it:Plotting results from matrices}} below), you may
    also specify {cmd:aux(}# [# ...]{cmd:)} to read the from corresponding
    rows (or column) of the main matrix.

{dlgtab:Plot options}

{marker label}{...}
{phang}
    {cmd:label(}{it:string}{cmd:)} provides a label for the plot to be used
    in the legend. Use double quotes to create multiline labels. For example,
    {cmd:label("This is a" "long label")} would create a two-line label. For
    text effects (bold, italics, greek letters, etc.) use SMCL tags as
    described in {it:{help graph_text}}.

{marker key}{...}
{phang}
    {cmd:key}[{cmd:(ci} [{cmd:#}]{cmd:)}] determines the key symbol
    to be used for the plot in the legend. {cmd:key} without argument uses
    the plot's marker symbol; this is the default. {cmd:key(ci)} determines
    the key symbol from the (first) confidence interval. {cmd:key(ci #)}
    determines the key symbol from the #th confidence interval; this is only
    useful if multiple confidence intervals are included in the plot.

{marker nokey}{...}
{phang}
    {cmd:nokey} prevents including the plot in the legend.

{marker pstyle}{...}
{phang}{cmd:pstyle(}{it:pstyle}{cmd:)} sets the overall style of the
    plot; see help {it:{help pstyle}}. {cmd:pstyle()} affects both,
    coefficient markers and confidence spikes. To use a different plot style
    for confidence spikes, add {cmd:pstyle()} within
    {helpb coefplot##ciopts:ciopts()}.

{marker axis}{...}
{phang}{cmd:axis(}{it:#}{cmd:)} specifies the scale axis to be used for the
    plot, where {cmd:1} {ul:<} {it:#} {ul:<} {cmd:9}. The default is to place
    all plots on the same scale axis.

{marker offset}{...}
{phang}
    {cmd:offset(}{it:#}{cmd:)} specifies a custom offset for the plot
    positions. The default is to create automatic offsets to prevent
    overlap of confidence spikes as soon as there are
    multiple plots. The spacing between coefficients is one unit, so
    {it:#} should usually be within -0.5 and 0.5. {it:#} may also be a scalar
    expression such as, say, {cmd:1/6}.

{marker ifopt}{...}
{phang}
    {cmd:if(}{it:exp}{cmd:)} restricts the contents of the plot to coefficients
    satisfying {it:exp}. The option is useful when you want to select
    coefficients, e.g., based on their values, plot positions, or confidence
    limits. Within {it:exp} refer to internal temporary variables as explained
    in {help coefplot##tempvar:Accessing internal temporary variables} below.
    For example, to include positive coefficients only, you could type
    {cmd:if(@b>=0)}. Note that {cmd:if()} does not affect the rendition of the
    categorical axis (unless {helpb coefplot##at:at} is specified). That is, a
    complete categorical axis is created including labels for all collected
    coefficients, even for the ones that have been removed from the plot by
    {cmd:if()}.

{marker weight}{...}
{phang}
    {cmd:weight(}{it:exp}{cmd:)} scales the size of the markers according to
    the size of the specified weights (see
    {help scatter##remarks14:Weighted markers} in help {helpb scatter}). Within
    {it:exp} refer to internal temporary variables as explained in
    {help coefplot##tempvar:Accessing internal temporary variables} below. For
    example, to scale markers according to the inverse of standard errors, you
    could type {cmd:weight(1/@se)}. {cmd:weight()} has no effect if marker
    labels are specified.

{phang}
    {it:marker_options} change the look of the coefficient markers (color,
    size, etc.); see help {it:{help marker_options}}.

{marker mlabel}{...}
{phang}
    {cmd:mlabel}[{cmd:(}{it:spec}{cmd:)}] adds marker labels to the
    plot. For adding custom labels to specific markers also see model option
    {helpb coefplot##mlabels:mlabels()} above. Furthermore, note that
    not all of Stata's plot types support marker labels. For example, if you use
    {helpb coefplot##recast:recast(bar)} to change the plot type to
    {helpb twoway_bar:bar}, no marker labels will be displayed (this has
    changed with the April 6, 2022, update to Stata 17; plot type 
    {helpb twoway_bar:bar} now displays marker labels).

{pmore}
    The {cmd:mlabel} option can be used in three different ways:

{pmore2}
    (1) {opt mlabel} without argument adds the values of the point estimates as
    marker labels. Use global option
    {helpb coefplot##format:format()} to set the display format.

{pmore2}
    (2) {opth mlabel(varname)} uses the values of the specified variable
    as marker labels. {it:varname} may be an internal variable (see
    {help coefplot##tempvar:Accessing internal temporary variables} below). For example,
    {cmd:mlabel(@b)} is equivalent to {cmd:mlabel} without argument.

{pmore2}
    (3) {opt mlabel(strexp)} sets the marker labels to the evaluation of the
    specified string expression. Internal variables can be used within {it:strexp}
    (see {help coefplot##tempvar:Accessing internal temporary variables}
    below). For example, you can type

{pmore3}
    mlabel("p = " + string(@pval,"%9.3f"))

{pmore2}
    to display labels such as "p = 0.001" or "p = 0.127". Furthermore,

{pmore3}
    mlabel(cond(@pval<.001, "***", cond(@pval<.01, "**", cond(@pval<.05, "*", ""))))

{pmore2}
    would display significance stars.

{phang}
    {it:marker_label_options} change the look and
    position of marker labels; see help {it:{help marker_label_options}}.

{marker recast}{...}
{phang}
    {cmd:recast(}{it:plottype}{cmd:)} plots the coefficients using
    {it:plottype}; supported plot types are
    {helpb scatter},
    {helpb line},
    {helpb twoway_connected:connected},
    {helpb twoway_area:area},
    {helpb twoway_bar:bar},
    {helpb twoway_spike:spike},
    {helpb twoway_dropline:dropline}, and
    {helpb twoway_dot:dot}. The default {it:plottype} is {helpb scatter}. The
    chosen plot type affects the available plot options. For example, if
    the plot type is {helpb twoway_bar:bar} then {it:{help barlook_options}}
    will be available. See the plot type's help file for details.

{marker cionly}{...}
{phang}
    {cmd:cionly} causes markers for point estimates to be suppressed.

{marker citop}{...}
{phang}
    {cmd:citop} specifies that confidence intervals be drawn in front of
    the markers for point estimates; the default is to draw confidence intervals
    behind the markers.

{marker cirecast}{...}
{phang}
    {cmd:cirecast(}{it:plottype}{cmd:)} is shorthand notation for
    {helpb coefplot##ciopts:ciopts(recast())}. If both are provided, the plot types
    specified in {cmd:ciopts(recast())} take precedence over the plot types
    specified in {cmd:cirecast()}.

{marker ciopts}{...}
{phang}
    {cmd:ciopts(}{it:options}{cmd:)} affect the rendition of confidence
    intervals. {it:options} are:

{p2colset 13 31 33 2}{...}
{p2col:{it:{help line_options}}}change look of spikes
    {p_end}
{p2col:{cmd:recast(}{it:plottype}{cmd:)}}plot the confidence intervals using
    {it:plottype}
    {p_end}
{p2colreset}{...}

{pmore}
    Supported plot types are
    {helpb twoway_rarea:rarea},
    {helpb twoway_rbar:rbar},
    {helpb twoway_rspike:rspike},
    {helpb twoway_rcap:rcap},
    {helpb twoway_rcapsym:rcapsym},
    {helpb twoway_rscatter:rscatter},
    {helpb twoway_rline:rline},
    {helpb twoway_rconnected:rconnected},
    {helpb twoway_pcspike:pcspike},
    {helpb twoway_pcspike:pccapsym},
    {helpb twoway_pcarrow:pcarrow} (or {cmd:pcrarrow} for the reverse),
    {helpb twoway_pcbarrow:pcbarrow}, and
    {helpb twoway_pcscatter:pcscatter}. The default {it:plottype} is
    {helpb twoway_rspike:rspike}. The chosen plot type affects the available
    options within {cmd:ciopts()}. For example, if the plot type is
    {helpb twoway_rbar:rbar} then {it:{help barlook_options}} will be
    available. See the plot type's help file for details.

{pmore}
    If multiple confidence intervals are requested, then
    {it:{help stylelists}} may be specified in the options within
    {cmd:ciopts()}. For example, {cmd:recast(rspike rcap ..)} would use
    {helpb twoway_rspike:rspike} for the first confidence interval and
    {helpb twoway_rcap:rcap} for the remaining confidence intervals;
    {cmd:lwidth(thin medium thick)} would use thin lines for the first
    confidence interval, medium width lines for the second, and thick lines
    for the third.

{marker cismooth}{...}
{phang}
    {cmd:cismooth}[{cmd:(}{it:options}{cmd:)}] adds smoothed confidence
    intervals. {it:options} are:

{p2colset 13 33 35 2}{...}
{p2col:{cmd:n(}{it:n}{cmd:)}}number of (equally spaced) confidence levels;
    default is {cmd:n(50)}; levels are placed in steps of 100/{it:n} from 100/2{it:n} to
    100-100/2{it:n} (e.g., 1, 3, 5, ..., 99 for {it:n}=50)
    {p_end}
{p2col:{cmdab:lw:idth(}{it:min max}{cmd:)}}set range of
    (relative) line widths; the default is {cmd:range(2 15)}
    ({it:max} is exact only for {it:n}=50)
    {p_end}
{p2col:{cmdab:i:ntensity(}{it:min max}{cmd:)}}set range of
    color intensities, as percentages; the default is {cmd:intensity(}{it:min} {cmd:100)}
    where {it:min} is determined as 4/(ceil({it:n}/2)+3)*100 (about 14 for n=50)
    {p_end}
{p2col:{cmdab:c:olor(}{help colorstyle:{it:color}}{cmd:)}}set the color (without
    intensity multiplier); the default color is determined by the graph scheme
    {p_end}
{p2col:{cmdab:psty:le(}{help pstyle:{it:pstyle}}{cmd:)}}set the overall style;
    this mainly affects the color
    {p_end}
{p2colreset}{...}

{pmore}
    The confidence intervals produced by {cmd:cismooth} are placed behind
    confidence intervals requested in {helpb coefplot##levels:levels()} and
    {helpb coefplot##ci:ci()}. {helpb coefplot##ciopts:ciopts()} do not
    apply to them.

{dlgtab:Subgraph options}

{marker bylabel}{...}
{phang}
    {cmd:bylabel(}{it:string}{cmd:)} provides a label for the subgraph. Use
    double quotes to create multiline labels. For example,
    {cmd:bylabel("This is a" "long label")} would create a two-line label. For
    text effects (bold, italics, greek letters, etc.) use SMCL tags as
    described in {it:{help graph_text}}.

{pmore}
    Subgraphs are implemented in terms of {helpb graph}'s {cmd:by()} option; see
    {helpb coefplot##byopts:byopts()} below for options on how to combine and
    render the subgraphs.

{dlgtab:Global options}

{marker horizontal}{...}
{phang}
    {cmd:horizontal} places coefficient values on the x axis. This is the
    default unless {helpb coefplot##at:at} is specified.

{marker vertical}{...}
{phang}
    {cmd:vertical} places coefficient values on the y axis. This is the
    default if {helpb coefplot##at:at} is specified.

{marker eqstrict}{...}
{phang}
    {cmd:eqstrict} causes equation names to be taken into account (i.e. match coefficients by
    equation names and plot equation labels) even if there is only one equation per model.

{marker order}{...}
{phang}
    {cmd:order(}{it:coeflist}{cmd:)} specifies the order of coefficients
    (not allowed with {helpb coefplot##at:at}). The default is to use
    the order as found in the input models (and place {cmd:_cons} last, within
    equations). {it:coeflist} is a
    space-separated list of elements such as:

{p2colset 13 25 27 2}{...}
{p2col:{cmd:.}}insert a gap
    {p_end}
{p2col:{it:eq}{cmd::.}}insert a gap within equation {it:eq}
    {p_end}
{p2col:{it:coef}}coefficient {it:coef}
    {p_end}
{p2col:{it:eq}{cmd::}}all coefficients from equation {it:eq}, in their current order
    {p_end}
{p2col:{it:eq}{cmd::}{it:coef}}coefficient {it:coef} from equation {it:eq}
    {p_end}
{p2colreset}{...}

{pmore}
    where {it:coef} may contain "{cmd:*}" (any string) and "{cmd:?}"
    (any nonzero character) wildcards.

{pmore}
    If no equations are specified, then the requested order of coefficients
    is repeated within each equation (keeping the existing order of
    equations). Otherwise, the requested order is applied across equations.
    Note that in the later case the first element in {cmd:order()} must be an
    equation name. {it:eq} is applied to all subsequent elements until a
    new {it:eq} is specified. For example,
    {cmd:order(5:weight mpg * 4:turn *)} would yield the following order:
    "{cmd:weight}" from equation "{cmd:5}", "{cmd:mpg}" from equation "{cmd:5}",
    remaining coefficients from equation "{cmd:5}",
    "{cmd:turn}" from equation "{cmd:4}", remaining coefficients from equation
    "{cmd:4}", remaining equations if any.

{marker orderby}{...}
{phang}
    {cmd:orderby(}[{it:subgraph}{cmd::}][{it:plot}]{cmd:)} orders the
    coefficients by a specific model. By default, the coefficients are ordered
    according to how they are provided to {cmd:coefplot}, with earlier plots
    and subgraphs taking precedence over later ones (and placing {cmd:_cons}
    last). This means that coefficients that only appear in later models will
    be placed after the coefficients that appear in earlier models. Specify the
    {cmd:orderby()} option if you want to change the default behavior and
    arrange the coefficients according to their order in a specific model
    (and, within each equation, place the other coefficients after these coefficients, but
    before {cmd:_cons}). Arguments {it:subgraph} and {it:plot} select the relevant
    model. For example, {cmd:orderby(2:3)} will order coefficients according to
    the model that is displayed in the third plot of the second subgraph. If one
    of the arguments is omitted, it defaults to one. Hence, {cmd:orderby(3)} will
    order the coefficients according to the model displayed in the third plot
    of the first subgraph; {cmd:orderby(2:)} will use the model displayed in the first
    plot of the second subgraph. {cmd:orderby()} will do nothing if a specified subgraph or
    plot does not exist. Furthermore, note that the {it:subgraph} argument
    is not allowed if the {helpb coefplot##norecycle:norecycle} option has been
    specified; plots are numbered uniquely across subgraphs in this case.

{marker sort}{...}
{phang}
    {cmd:sort}[{cmd:(}{it:spec}{cmd:)}] sorts the coefficients by size. {it:spec} is

            [{it:subgraph}{cmd::}][{it:plot}] [, {cmdab:d:escending} {cmd:by(}{it:stat}{cmd:)} ]

{pmore}
    where {it:subgraph} and {it:plot}, being equal to {cmd:.} or a positive
    integer, identify the subgraph and plot to be used
    to establish the sort order. For example, to sort based on all values in
    the second subgraph (possibly including multiple plots), type
    {cmd:sort(2:)} or {cmd:sort(2:.)}; to sort based on all values in the third
    plot (possibly spanning multiple subgraphs), type {cmd:sort(3)} or
    {cmd:sort(.:3)}; to sort based on the values of the third plot in the
    second subgraph, type {cmd:sort(2:3)}. Specifying {cmd:sort} without
    argument is equivalent to {cmd:sort(.:.)}, that is, to sort based on the
    values in all available subgraphs and plots. If you specify a subgraph or
    plot that does not exist, {cmd:sort()} will do nothing. Furthermore, if the
    {helpb coefplot##norecycle:norecycle} option is specified, the {it:subgraph}
    argument can be omitted as the plots will be uniquely numbered across
    subgraphs.

{pmore}
    By default, the coefficients are sorted in ascending order of the values of
    the point estimates. Specify suboption {cmd:descending} to use a
    descending sort order. Furthermore, use {cmd:by(}{it:stat}{cmd:)} to change
    the relevant statistic, where {it:stat} may be:

{p2colset 13 25 27 2}{...}
{p2col:{cmd:b}}sort by point estimate (the default){p_end}
{p2col:{cmd:v} (or {cmd:se})}sort by variance (or standard error){p_end}
{p2col:{cmd:t}}sort by t (or z) statistic{p_end}
{p2col:{cmd:tabs}}sort by absolute t (or z) statistic{p_end}
{p2col:{cmd:p}}sort by p-value{p_end}
{p2col:{cmd:df}}sort by degrees of freedom{p_end}
{p2col:{cmd:ll} [#]}sort by (#th) lower confidence limit; # defaults to 1{p_end}
{p2col:{cmd:ul} [#]}sort by (#th) upper confidence limit; # defaults to 1{p_end}
{p2col:{cmd:aux} [#]}sort by (#th) auxiliary variable (see the
    {helpb coefplot##aux:aux()} option); # defaults to 1{p_end}
{p2colreset}{...}

{pmore}
    In case of multiple equations, coefficients will be sorted separately
    within each equation, keeping the original order of equations. Use the
    {helpb coefplot##order:order()} option the change the order of the equations.

{marker relocate}{...}
{phang}
    {cmd:relocate(}{it:spec}{cmd:)} assigns specific positions to the
    coefficients on the category axis. {it:spec} is:

            [{it:eq}{cmd::}]{it:coef} {cmd:=} # [[{it:eq}{cmd::}]{it:coef} {cmd:=} # ...]

{pmore}
    where {it:eq} and {it:coef} may contain "{cmd:*}" (any string) and
    "{cmd:?}" (any nonzero character) wildcards. If {helpb coefplot##bycoefs:bycoefs} is
    specified, use numbers (1, 2, ...) instead of {it:eq} and {it:coef}
    to address the elements on the categorical axis.

{pmore}The default for {cmd:coefplot} is to place coefficients
    at integer values 1, 2, 3, ... (from top to bottom in horizontal mode,
    from left to right in vertical mode). The {cmd:relocate()} option gives
    you the possibility to specify alternative values. If, for example, you
    want to place coefficient {cmd:mpg} at value 2.5 on the category axis, you
    could type {cmd:relocate(mpg = 2.5)}. If you only want to change the
    order of coefficients and are fine with integer positions, then use the
    {helpb coefplot##order:order()} option. Note that the specified positions
    are assigned before inserting gaps between equations, headings, and
    groups (see {helpb coefplot##eqlabels:eqlabels()},
    {helpb coefplot##headings:headings()}, and
    {helpb coefplot##groups:groups()}). Hence, the final plot positions might
    deviate from the specified positions if there are equation labels, headings,
    or group labels.

{marker bycoefs}{...}
{phang}
    {cmd:bycoefs} flips subgraphs and coefficients (not allowed with
    {helpb coefplot##at:at}). If {cmd:bycoefs} is specified, a
    separate subgraph is produced for each coefficient. In this
    case, use integer numbers (1, 2, ...) instead of coefficient names
    to address the elements on the categorical axis within options
    {helpb coefplot##relocate:relocate()},
    {helpb coefplot##headings:headings()}, and
    {helpb coefplot##groups:groups()}.

{marker norecycle}{...}
{phang}
    {cmd:norecycle} increments plot styles across subgraphs. The default is
    to start over with each new subgraph.

{marker nooffsets}{...}
{phang}
    {cmd:nooffsets} suppresses automatic offsets for plot positions.

{marker format}{...}
{phang}
    {cmd:format(}{it:format}{cmd:)} sets the display format for
    coefficients. This affects the rendition of the axis and marker
    labels. {it:format} may be a numeric format or a date format
    (see help {helpb format}).

{marker pnum}{...}
{phang}
    {cmd:p{it:#}(}{help coefplot##plotopts:{it:plotopts}}{cmd:)} specifies
    options for the {it:#}th plot. For example, type {cmd:p2(nokey)} to exclude
    plot 2 from the legend (see {helpb coefplot##nokey:nokey}). Use the {cmd:p#()}
    options as an alternative to specifying options directly within a plot; in
    case of conflict, options specified within a plot take precedence
    over options specified via {cmd:p#()}.

{marker nolabels}{...}
{phang}
    {cmd:nolabels} causes coefficient names to be used as labels instead of
    variable labels or value labels.

{marker coeflabels}{...}
{phang}
    {cmd:coeflabels(}{it:spec}{cmd:)} specifies custom labels for
    coefficients (not allowed with {helpb coefplot##at:at}). {it:spec} is

{p 12 14 2}
    [{it:coeflist} {cmd:=} {cmd:"}{it:label}{cmd:"} [{it:coeflist} {cmd:=} {cmd:"}{it:label}{cmd:"} ...]]
    [{cmd:,} {cmdab:t:runcate(}#{cmd:)} {cmdab:w:rap(}#{cmd:)} {cmdab:nob:reak}
    {cmdab:i:nteraction(}{it:string}{cmd:)}
    {it:{help axis_label_options:suboptions}}]

{pmore}
    with {it:coeflist} as above for {helpb coefplot##keep:keep()}. Enclose
    {it:label} in double quotes
    if it contains spaces, e.g. {bind:{cmd:coeflabels(foreign = "Car Type")}}.
    Enclose {it:label} in compound double quotes to create a multiline
    label, e.g. {bind:{cmd:coeflabels(foreign = `""This is a" "long label""')}};
    alternatively, apply the {cmd:wrap()} option. For text effects
    (bold, italics, greek letters, etc.) use SMCL tags as described in
    {it:{help graph_text}}.

{pmore}
    Option {cmd:truncate(}#{cmd:)} truncates coefficient labels to
    a maximum length of # characters. Option {cmd:wrap(}#{cmd:)} divides
    coefficient labels into multiple lines, where each line has a maximum
    length of # characters. {cmd:truncate()} and {cmd:wrap()} operate on
    words. That is, they try to fill to the maximum length without breaking
    in the middle of a word. However, if a word is longer than # characters,
    it will be split or truncated. Specify {cmd:nobreak} to prevent
    {cmd:truncate()} and {cmd:wrap()} from splitting or truncating words
    that are longer than # characters. If {cmd:truncate()} and {cmd:wrap()}
    are both specified, {cmd:truncate()} is applied first.
    {cmdab:interaction()} specifies the string to be used as
    delimiter in labels for interaction terms; the default is
    {cmd:interaction(" # ")}. {it:suboptions} are axis label suboptions as
    described in {it:{help axis_label_options}}.

{pmore}
    Note: Labels containing multiple lines are left unchanged by {cmd:truncate()}
    and {cmd:wrap()}. Therefore, if you don't like how {cmd:wrap()} breaks a
    specific label, you can provide a custom variant of it in {cmd:coeflabels()}
    while still using {cmd:wrap()} for the other labels. {cmd:truncate()}
    and {cmd:wrap()} may fail to process a label if it contains compound
    double quotes; the label will be left unchanged in this case.

{marker noeqlabels}{...}
{phang}
    {cmd:noeqlabels} suppresses equation labels.

{marker eqlabels}{...}
{phang}
    {cmd:eqlabels(}{it:spec}{cmd:)} specifies custom labels for equations, one after
    the other (not allowed with {helpb coefplot##at:at}). {it:spec} is:

{p 12 14 2}
    [{cmd:"}{it:label}{cmd:"} [{cmd:"}{it:label}{cmd:"} ...]] [{cmd:,}
    {cmdab:lab:els}[{cmd:(}{it:string}{cmd:)}]
    [{cmd:{ul:no}}]{cmdab:g:ap}[{cmd:(}#{cmd:)}]  {cmdab:ashead:ings}
    {cmdab:off:set(}#{cmd:)} {cmdab:t:runcate(}#{cmd:)} {cmdab:w:rap(}#{cmd:)}
    {cmdab:nob:reak} {it:{help axis_label_options:suboptions}} ]

{pmore}
    Enclose labels in double quotes if they contain spaces,
    e.g. {bind:{cmd:eqlabels("EQ one" "EQ two")}}. Enclose labels in compound
    double quotes to create multiline labels,
    e.g. {bind:{cmd:eqlabels(`""This is a" "long label""')}}. Alternatively,
    apply the {cmd:wrap()} option. For text effects
    (bold, italics, greek letters, etc.) use SMCL tags as described in
    {it:{help graph_text}}.

{pmore}
    Option {cmd:label} causes the equation names to be treated as
    variable names; {cmd:coefplot} will then use the corresponding variable labels
    (and, depending on context, value labels) to label the equations. Specify
    {cmd:label(}{it:string}{cmd:)} to set the string to be used as
    delimiter in labels for interaction terms; typing {cmd:label} without argument
    is equivalent to {cmd:label(" # ")}. {cmd:gap()} specifies the size of the
    gap between equations. The
    default is {cmd:gap(1)}. {cmd:nogap} suppresses the gap between
    equations. {cmdab:asheadings} treats equation labels as headings;
    see {helpb coefplot##headings:headings()}. {cmd:offset()}, only
    allowed with {cmd:asheadings}, offsets the labels. {cmd:truncate()},
    {cmd:wrap()}, {cmd:nobreak}, and {it:suboptions} are as above for
    {helpb coefplot##coeflabels:coeflabels()}.

{marker headings}{...}
{phang}
    {cmd:headings(}{it:spec}{cmd:)} adds headings between
    coefficients (not allowed with {helpb coefplot##at:at}). {it:spec} is:

{p 12 14 2}
    {it:coeflist} {cmd:=} {cmd:"}{it:label}{cmd:"} [{it:coeflist} {cmd:=} {cmd:"}{it:label}{cmd:"} ...]
    [{cmd:,} [{cmd:{ul:no}}]{cmdab:g:ap}[{cmd:(}#{cmd:)}]
    {cmdab:off:set(}#{cmd:)} {cmdab:t:runcate(}#{cmd:)}
    {cmdab:w:rap(}#{cmd:)} {cmdab:nob:reak}
    {it:{help axis_label_options:suboptions}} ]

{pmore}
    with {it:coeflist} as above for {helpb coefplot##keep:keep()}. If
    {helpb coefplot##bycoefs:bycoefs} is specified, use numbers 1, 2,
    ... instead of {it:coeflist} to address the elements on the categorical
    axis. Enclose {it:label} in double quotes if it contains
    spaces. For example, {bind:{cmd:headings(0.foreign = "Car Type")}} will
    print the heading "{cmd:Car Type}" before coefficient "{cmd:0.foreign}".
    Enclose {it:label} in compound double quotes to create a multiline
    label, e.g. {bind:{cmd:headings(foreign = `""This is a" "long heading""')}}.
    Alternatively, apply the {cmd:wrap()} option. For text effects (bold,
    italics, greek letters, etc.) use SMCL tags as
    described in {it:{help graph_text}}.

{pmore}
    {cmd:gap()} and {cmdab:offset()} are as above for
    {helpb coefplot##eqlabels:eqlabels()}. {cmd:truncate()}, {cmd:wrap()},
    {cmd:nobreak}, and {it:suboptions} are as above for
    {helpb coefplot##coeflabels:coeflabels()}.

{marker groups}{...}
{phang}
    {cmd:groups(}{it:spec}{cmd:)} adds labels for groups of
    coefficients (not allowed with {helpb coefplot##at:at}). The specified
    label will be printed beside (or, in vertical mode, below) the identified
    group of coefficients. {it:spec} is:

{p 12 14 2}
    {it:coeflist} {cmd:=} {cmd:"}{it:label}{cmd:"} [{it:coeflist} {cmd:=} {cmd:"}{it:label}{cmd:"} ...]
    [{cmd:,} [{cmd:{ul:no}}]{cmdab:g:ap}[{cmd:(}#{cmd:)}]
    {cmdab:t:runcate(}#{cmd:)} {cmdab:w:rap(}#{cmd:)}
    {cmdab:nob:reak} {it:{help axis_label_options:suboptions}} ]

{pmore}
    with {it:coeflist} as above for {helpb coefplot##keep:keep()}. If
    {helpb coefplot##bycoefs:bycoefs} is specified, use numbers 1, 2,
    ... instead of {it:coeflist} to address the elements on the categorical
    axis. Enclose {it:label} in double quotes if
    it contains spaces. Enclose {it:label} in compound double quotes to create
    a multiline label. Alternatively, apply the {cmd:wrap()} option. For text
    effects (bold, italics, greek letters, etc.) use SMCL tags as described in
    {it:{help graph_text}}.

{pmore}
    {cmd:gap()} is as above for
    {helpb coefplot##eqlabels:eqlabels()}. {cmd:truncate()}, {cmd:wrap()},
    {cmd:nobreak}, and {it:suboptions} are as above for
    {helpb coefplot##coeflabels:coeflabels()}.

{marker plotlabels}{...}
{phang}
    {cmd:plotlabels(}{it:spec}{cmd:)} specifies labels for the plots to be
    used in the legend. Labels specified via {cmd:plotlabels()}
    take precedence over labels specified in the
    {helpb coefplot##label:label()} plot option. {it:spec} is:

{p 12 14 2}
    [{cmd:"}{it:label}{cmd:"} [{cmd:"}{it:label}{cmd:"} ...]] [{cmd:,} {cmdab:t:runcate(}#{cmd:)}
    {cmdab:w:rap(}#{cmd:)} {cmdab:nob:reak} ]

{pmore}
    Enclose labels in double quotes if they contain spaces. Enclose labels in
    compound double quotes to create multiline labels. Alternatively,
    apply the {cmd:wrap()} option. For text effects
    (bold, italics, greek letters, etc.) use SMCL tags as described in
    {it:{help graph_text}}. Options {cmd:truncate()}, {cmd:wrap()}, and {cmd:nobreak} are as
    above for {helpb coefplot##coeflabels:coeflabels()}.

{marker bylabels}{...}
{phang}
    {cmd:bylabels(}{it:spec}{cmd:)} specifies labels for the subgraphs. Labels
    specified via {cmd:bylabels()}
    take precedence over labels specified in the
    {helpb coefplot##bylabel:bylabel()} subgraph option. {it:spec} is:

{p 12 14 2}
    [{cmd:"}{it:label}{cmd:"} [{cmd:"}{it:label}{cmd:"} ...]] [{cmd:,} {cmdab:t:runcate(}#{cmd:)}
    {cmdab:w:rap(}#{cmd:)} {cmdab:nob:reak} ]

{pmore}
    Enclose labels in double quotes if they contain spaces. Enclose labels in
    compound double quotes to create multiline labels. Alternatively,
    apply the {cmd:wrap()} option. For text effects
    (bold, italics, greek letters, etc.) use SMCL tags as described in
    {it:{help graph_text}}. Options {cmd:truncate()}, {cmd:wrap()}, and {cmd:nobreak} are as
    above for {helpb coefplot##coeflabels:coeflabels()}.

{marker grid}{...}
{phang}
    {cmd:grid(}{it:options}{cmd:)} affects the rendition of grid lines on the
    category axis (not allowed with {helpb coefplot##at:at}). {it:options} are:

{p 12 14 2}
    { {cmdab:b:etween} | {cmdab:w:ithin} | {cmdab:n:one} } {it:{help axis_label_options:suboptions}}

{pmore}
    {cmdab:b:etween} places grid lines between coefficient labels;
    {cmdab:w:ithin} places grid lines at the center of coefficient labels;
    {cmdab:n:one} suppress grid lines. {it:suboptions} are axis label suboptions
    as described in {it:{help axis_label_options}}. In horizontal mode, the
    default is {cmd:within} for single plots and {cmd:between} for multiple
    plots. In vertical mode, the default is {cmd:none}. Alternatively, use
    {helpb axis_label_options:ytick()} and {helpb axis_label_options:xtick()}
    to set grid lines.

{marker generate}{...}
{phang}
    {cmd:generate}[{cmd:(}{it:prefix}{cmd:)}] generates variables containing
    the graph data. The variable names will be prefixed by "{cmd:__}"
    or as specified by {it:prefix}.

{marker replace}{...}
{phang}
    {cmd:replace} allows {cmd:coefplot} to overwrite existing variables.

{marker addplot}{...}
{phang}
    {cmd:addplot(}{it:plot}{cmd:)} adds other plots to the graph. See help
    {it:{help addplot_option}}. By default {cmd:addplot()} has access only to
    the first {it:r} observations in the dataset, where {it:r} is the number of
    observations used by {cmd:coefplot} to store its internal results. If the
    graph does not contain multiple subgraphs and
    {helpb coefplot##generate:generate()} or {helpb coefplot##nodrop:nodrop} is
    specified, {cmd:addplot()} has access to all observations.

{marker nodrop}{...}
{phang}
    {cmd:nodrop} causes {cmd:coefplot} to keep all observations when generating
    the graph. The default is to eliminate unused observations temporarily
    to increase speed. {cmd:nodrop} may be useful in connection with the
    {helpb coefplot##addplot:addplot()} option, if the graph does not contain
    multiple subgraphs. {cmd:nodrop} has no effect if
    {helpb coefplot##generate:generate()} is specified.
    {p_end}

{phang}
    {it:twoway_options} are general twoway options, other than
    {cmd:by()}, as documented in help {it:{help twoway_options}}.

{marker byopts}{...}
{phang}
    {cmd:byopts(}{it:byopts}{cmd:)} determines how subgraphs
    are combined. {it:byopts} are as described in help {it:{help by_option}}.


{marker examples}{...}
{title:Examples}

        . {stata sysuse auto}
        . {stata regress price mpg headroom trunk length turn}
        . {stata coefplot, drop(_cons) xline(0)}

        . {stata regress price mpg headroom trunk length turn if foreign==0}
        . {stata estimates store domestic}
        . {stata regress price mpg headroom trunk length turn if foreign==1}
        . {stata estimates store foreign}
        . {stata coefplot domestic foreign, drop(_cons) xline(0)}

        . {stata coefplot domestic || foreign, drop(_cons) xline(0)}

        . {stata coefplot domestic || foreign, yline(0) bycoefs vertical byopts(yrescale)}

{pstd}
    For further examples see the {browse "http://repec.sowi.unibe.ch/stata/coefplot":website},
    the {browse "http://www.stata-journal.com/article.html?article=gr0059":Stata Journal article}, or the
    {browse "http://ideas.repec.org/p/bss/wpaper/1.html":working paper}.


{marker remarks}{...}
{title:Remarks}

{pstd}
    Remarks are presented under the following headings:

        {help coefplot##wildcards:Using wildcards in model names}
        {help coefplot##place:Placement of options}
        {help coefplot##matrix:Plotting results from matrices}
        {help coefplot##tempvar:Accessing internal temporary variables}


{marker wildcards}{...}
{title:Using wildcards in model names}

{pstd}
    Instead of providing distinct model names to {cmd:coefplot}, you can also
    specify a name pattern containing {cmd:*} (any string)
    and {cmd:?} (any nonzero character) wildcards. {cmd:coefplot}
    will then plot the results from all matching
    models. If a name pattern is specified as part of a plot delimited by
    parentheses, the results from the matching models will be combined into the
    same plot. For example, if models {cmd:est11}, {cmd:est12}, {cmd:est13},
    {cmd:est21}, {cmd:est22}, and {cmd:est23} are in
    memory, typing

{com}{...}
        . coefplot (est1*, {txt:{it:opts1}}) (est2*, {txt:{it:opts2}})
{txt}{...}

{pstd}
    is equivalent to

{com}{...}
        . coefplot (est11 est12 est13, {txt:{it:opts1}}) (est21 est22 est23, {txt:{it:opts2}})
{txt}{...}

{pstd}
    Likewise, typing

{com}{...}
        . coefplot (est*1, {txt:{it:opts1}} \ est*2, {txt:{it:opts2}} \, {txt:{it:opts3}})
{txt}{...}

{pstd}
    is equivalent to

{com}{...}
        . coefplot (est11 est21, {txt:{it:opts1}} \ est12 est22, {txt:{it:opts2}} \, {txt:{it:opts3}})
{txt}{...}

{pstd}
    If a name pattern is specified without parentheses,
    the matching models are treated as separate plots. For example, typing

{com}{...}
        . coefplot est1* || est2*
{txt}{...}

{pstd}
    is equivalent to

{com}{...}
        . coefplot est11 est12 est13 || est21 est22 est23
{txt}{...}

{pstd}
    or

{com}{...}
        . coefplot (est11) (est12) (est13) || (est21) (est22) (est23)
{txt}{...}

{pstd}
    Use global options {helpb coefplot##pnum:p1()}, {helpb coefplot##pnum:p2()},
    etc. to provide specific options to the different plots in this case. For
    example, typing

{com}{...}
        . coefplot est1*, p1({txt:{it:opts1}}) p2({txt:{it:opts2}}) p3({txt:{it:opts3}})
{txt}{...}

{pstd}
    is equivalent to

{com}{...}
        . coefplot (est11, {txt:{it:opts1}}) (est12, {txt:{it:opts2}}) (est13, {txt:{it:opts3}})
{txt}{...}


{marker place}{...}
{title:Placement of options}

{pstd}
    {cmd:coefplot} has four levels of options:

{phang}(1) {help coefplot##modelopts:{it:modelopts}} are options that apply to a single
    model (or matrix). They specify the information to be displayed.

{phang}(2) {help coefplot##plotopts:{it:plotopts}} are options that apply to a single
    plot, possibly containing results from multiple models. They affect
    the rendition of markers and confidence intervals and provide a label
    for the plot.

{phang}(3) {help coefplot##subgropts:{it:subgropts}} are options that
    apply to a single subgraph, possibly containing multiple plots.

{phang}(4) {help coefplot##globalopts:{it:globalopts}} are options that apply
    to the overall graph.

{pstd}
    The levels are nested in the sense that upper level options include all
    lower level options. That is,
    {help coefplot##globalopts:{it:globalopts}} includes
    {help coefplot##subgropts:{it:subgropts}},
    {help coefplot##plotopts:{it:plotopts}}, and
    {help coefplot##modelopts:{it:modelopts}};
    {help coefplot##subgropts:{it:subgropts}} includes
    {help coefplot##plotopts:{it:plotopts}}, and
    {help coefplot##modelopts:{it:modelopts}};
    {help coefplot##plotopts:{it:plotopts}} includes
    {help coefplot##modelopts:{it:modelopts}}. However, upper level options
    may not be specified at a lower level.

{pstd}
    If lower level options are specified at an upper level, they serve as
    defaults for all included lower levels elements. For example, if you want
    to draw 99% and 95% confidence intervals for all included models,
    specify {cmd:levels(99 95)} as global option:

{com}{...}
        . coefplot model1 model2 model3, levels(99 95)
{txt}{...}

{pstd}
    Options specified with an individual element override the defaults set
    by upper level options. For example, if you want to draw 99% and 95%
    confidence intervals for model 1 and model 2 and 90% confidence intervals
    for model 3, you could type:

{com}{...}
        . coefplot model1 model2 (model3, level(90)), levels(99 95)
{txt}{...}

{pstd}
    There are some fine distinctions about the placement of options and how they
    are interpreted. For example, if you type

{com}{...}
        . coefplot m1, {txt:{it:opts1}} || m2, {txt:{it:opts2}} {txt:{it:opts3}}
{txt}{...}

{pstd}
    then {it:opts2} and {it:opts3} are interpreted as global options. If you
    want to apply {it:opts2} only to {cmd:m2} then type

{com}{...}
        . coefplot m1, {txt:{it:opts1}} || m2, {txt:{it:opts2}} ||, {txt:{it:opts3}}
{txt}{...}

{pstd}
    Similarly, if you type

{com}{...}
        . coefplot (m1, {txt:{it:opts1}} \ m2, {txt:{it:opts2}})
{txt}{...}

{pstd}
    then {it:opts2} will be applied to both models. To apply {it:opts2} only to
    {cmd:m2} type

{com}{...}
        . coefplot (m1, {txt:{it:opts1}} \ m2, {txt:{it:opts2}} \)
{txt}{...}

{pstd}
    or, if you also want to include {it:opts3} to be applied to both models,
    type

{com}{...}
        . coefplot (m1, {txt:{it:opts1}} \ m2, {txt:{it:opts2}} \, {txt:{it:opts3}})
{txt}{...}

{pstd}
    or

{com}{...}
        . coefplot (m1, {txt:{it:opts1}} \ m2, {txt:{it:opts2}} \), {txt:{it:opts3}}
{txt}{...}

{pstd}
    In case of multiple subgraphs there is some ambiguity about where to
    specify the plot options (unless global option
    {helpb coefplot##norecycle:norecycle} is specified). You can provide plot
    options within any of the subgraphs as plot options are collected across
    subgraphs. However, in case of conflict, the plot options from the rightmost
    subgraph usually take precedence over earlier plot options. In addition,
    you can also use global options {helpb coefplot##pnum:p1()},
    {helpb coefplot##pnum:p2()}, etc. to provide
    options for specific plots. In case of conflict, options specified within a plot take
    precedence over options provided via {helpb coefplot##pnum:p1()},
    {helpb coefplot##pnum:p2()}, etc.

{marker matrix}{...}
{title:Plotting results from matrices}

{pstd}
    Use syntax {helpb coefplot##matrix:{ul:m}atrix({it:mspec})} instead of the
    name of a stored model to plot results from a matrix. {it:mspec} may be:

{p2colset 9 21 23 2}{...}
{p2col:{it:name}}use first row of matrix {it:name}
    {p_end}
{p2col:{it:name}{cmd:[}#{cmd:,.]}}use #th row of
    matrix {it:name}; may also type {it:name}{cmd:[}#{cmd:,]} or
    {it:name}{cmd:[}#{cmd:]}
    {p_end}
{p2col:{it:name}{cmd:[.,}#{cmd:]}}use #th column of
    matrix {it:name}; may also type {it:name}{cmd:[,}#{cmd:]}
    {p_end}
{p2colreset}{...}

{pstd}
    If the {cmd:matrix()} syntax is used, then option {helpb coefplot##b:b()} is discarded
    and names given in {helpb coefplot##at:at()}, {helpb coefplot##ci:ci()},
    {helpb coefplot##v:v()}, {helpb coefplot##se:se()},
    {helpb coefplot##df:df()}, and {helpb coefplot##aux:aux()} refer to regular
    matrices instead of {cmd:e()}-matrices. The matrix name may be omitted in these
    options if results are to be read from the same matrix; only the
    relevant row or column numbers have to be provided in this case (whether the
    numbers are interpreted as row or column numbers
    depends in how {cmd:matrix()} was specified).

{pstd}
    For example, to plot medians and their confidence intervals as computed
    by {helpb centile} you could type:

{com}{...}
        sysuse auto, clear
        matrix C = J(3,3,.)
        matrix rownames C = median ll95 ul95
        matrix colnames C = mpg trunk turn
        local i 0
        foreach v of var mpg trunk turn {
            local ++ i
            centile `v'
            matrix C[1,`i'] = r(c_1) \ r(lb_1) \ r(ub_1)
        }
        matrix list C
        coefplot matrix(C), ci((2 3))
{txt}{...}

{pstd}
    This is equivalent to:

{com}{...}
        coefplot matrix(C[1]), ci((C[2] C[3]))
{txt}{...}

{pstd}
    Note that a single {cmd:coefplot} command can contain both regular syntax
    and {cmd:matrix()} syntax. For example, to add means to the graph above
    you could type:

{com}{...}
        mean mpg trunk turn
        estimates store mean
        coefplot (matrix(C), ci((2 3))) (mean)
{txt}{...}


{marker tempvar}{...}
{title:Accessing internal temporary variables}

{pstd}
    {cmd:coefplot} maintains a number of internal variables that can be
    used within
    {helpb coefplot##ifopt:if()},
    {helpb coefplot##weight:weight()},
    {helpb coefplot##transform:transform()},
    {helpb marker_label_options:mlabel()},
    {helpb marker_label_options:mlabvposition()}, and
    {helpb addplot_option:addplot()}. These
    variables are:

{p2colset 9 21 23 2}{...}
{p2col:{cmd:@b}}point estimates
    {p_end}
{p2col:{cmd:@ll}#}lower limits of confidence interval # (may use {cmd:@ll} for {cmd:@ll1})
    {p_end}
{p2col:{cmd:@ul}#}upper limits of confidence interval # (may use {cmd:@ul} for {cmd:@ul1})
    {p_end}
{p2col:{cmd:@V}}variances
    {p_end}
{p2col:{cmd:@se}}standard errors
    {p_end}
{p2col:{cmd:@t}}t or z statistics, computed as @b/@se
    {p_end}
{p2col:{cmd:@df}}degrees of freedom
    {p_end}
{p2col:{cmd:@pval}}p-values, computed as (1-normal(|@t|))*2 or ttail(@df,|@t|)*2, depending
    on whether df are available
    {p_end}
{p2col:{cmd:@at}}plot positions
    {p_end}
{p2col:{cmd:@plot}}plot ID (labeled)
    {p_end}
{p2col:{cmd:@by}}subgraph ID (labeled)
    {p_end}
{p2col:{cmd:@mlbl}}Marker labels set by {helpb coefplot##mlabels:mlabels()} (string variable)
    {p_end}
{p2col:{cmd:@mlpos}}Marker label positions set by {helpb coefplot##mlabels:mlabels()}
    {p_end}
{p2col:{cmd:@aux}#}auxiliary variables collected by {helpb coefplot##aux:aux()} (may use {cmd:@aux} for {cmd:@aux1})
    {p_end}
{p2colreset}{...}

{pstd}
    The internal variables can be used like other variables in the
    dataset. For example, option {cmd:mlabel(@plot)} would add plot labels as marker
    labels or option {cmd:addplot(line @at @b)} would draw a connecting line
    through all point estimates in the graph.


{marker saved_results}{...}
{title:Saved results}

{pstd}
    {cmd:coefplot} returns the following macros and scalars in {cmd:r()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:r(n_ci)}}number of confidence intervals{p_end}
{synopt:{cmd:r(n_plot)}}number of plots{p_end}
{synopt:{cmd:r(n_subgr)}}number of subgraphs{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:r(graph)}}copy of graph command{p_end}
{synopt:{cmd:r(labels)}}coefficient labels{p_end}
{synopt:{cmd:r(eqlabels)}}equation labels{p_end}
{synopt:{cmd:r(groups)}}group labels{p_end}
{synopt:{cmd:r(headings)}}headings{p_end}
{synopt:{cmd:r(legend)}}contents of legend option{p_end}


{marker author}{...}
{title:Author}

{pstd}
    Ben Jann, University of Bern, ben.jann@unibe.ch

{pstd}
    Thanks for citing this software in one of the following ways:

{pmore}
    Jann, B. (2014). Plotting regression coefficients and other
    estimates. The Stata Journal 14(4): 708-737.

{pmore}
    Jann, B. (2013). Plotting regression coefficients and other estimates
    in Stata. University of Bern Social Sciences Working Papers
    Nr. 1. Available from
    {browse "http://ideas.repec.org/p/bss/wpaper/1.html"}.

{pmore}
    Jann, B. (2013). coefplot: Stata module to plot regression coefficients
    and other results. Available from
    {browse "http://ideas.repec.org/c/boc/bocode/s457686.html"}.


