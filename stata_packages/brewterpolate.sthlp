{smcl}
{* *! version 1.0.0 21MAR2016}{...}

{hline}
Interpolation of colors between starting and ending color values.
{hline}

{title:help for brewterpolate}

{p 4 4 8}{hi:brewterpolate {hline 2}} Stata program to interpolate an arbitrary number of 
colors between a starting and ending color.{p_end}

{title:Syntax}

{p 4 4 4}{cmd:brewterpolate}, {cmdab:sc:olor(}{it:string}{opt )} 
{cmdab:ec:olor(}{it:string}{opt )} {cmdab:c:olors(}{it:int}{opt )} 
[{cmdab:cm:od(}{it:string}{opt )} {cmdab:ics:pace(}{it:string}{opt )} 
{cmdab:rcs:pace(}{it:string}{opt )} {cmdab:inv:erse} {cmdab:g:rayscale} ] {break}

{title:Description}

{p 4 4 4}{cmd:brewterpolate} is a program used to interpolate color values between 
the start and end colors for an arbitrary number of points.  The program can 
accept input in several formats and provides output in rgb, rgba, srgb, srgba, 
hsv, and hsva formats. {p_end}

{marker required}{title:Options}

{p 4 4 8}{cmdab:sc:olor} is a required argument that takes a value conforming to 
one of the formats listed in {help brewterpolate##icspace:Input Color Spaces}.{p_end}

{p 4 4 8}{cmdab:sc:olor} is a required argument that takes a value conforming to 
one of the formats listed in {help brewterpolate##icspace:Input Color Spaces}.{p_end}

{p 4 4 8}{cmd:colors} is a required argument that takes a value to define the 
number of points between the starting and ending colors to interpolate. {p_end}

{p 4 4 8}{cmdab:cm:od} is an optional argument that can take one of the 
following values:  brighter, darker, saturated, desaturated, or nothing and is 
used to modify the interpolated colors.  A value of "brighter" will return 
colors that are arbitrarily brighter than the normal interpolated value, 
"darker" will return colors that are arbitrarily darker than the normal 
interpolated colors, "saturated" will return arbitrarily more saturated colors, 
and "desaturated" will return arbitrarily less saturated colors.  If no argument 
is passed to this parameter, the colors are interpolated without modification.{p_end}

{p 4 4 8}{cmdab:ics:pace} is an optional argument used to specify the input color 
space used for the starting and ending colors.  If no argument is passed, RGB is 
assumed. {p_end}

{p 4 4 8}{cmdab:rcs:pace} is an optional argument used to specify the return color 
space used for passing the interpolated colors back to Stata.  This can be any 
of the values listed in {help brewterpolate##icspace:Input Color Spaces} except 
for the web-based formats.  {p_end}

{p 4 4 8}{cmdab:inv:erse} is an optional argument used to return the inverse of 
the interpolated colors.  This is implemented after any of the luminance modifications 
have been made to the colors.  {p_end}

{p 4 4 8}{cmdab:g:rayscale} is an optional argument used to force the returned 
color values into a grayscale.  This is the last transformation that is applied 
to the colors.  In other words, if you requested the inverse of the colors that 
are arbitrarily less saturated, the method would first get the less saturated 
interpolated color, invert it, and then transform it to a gray scale value. {p_end}

{marker icspace}
{col 10}{hline 80}
{col 10}{hi:Argument} {col 35}{hi: Input Colorspace}
{col 10}{hline 80}
{col 10}{hi:rgb}{col 35}{it:Red, Green, Blue (ex., 0 0 255).}
{col 10}{hi:rgba}{col 35}{it:Red, Green, Blue, Alpha (ex., 0 0 255 0.5)}
{col 10}{hi:srgb}{col 35}{it:RGB Decimal (ex., 0.0 0.0 1.0).}
{col 10}{hi:srgba}{col 35}{it:RGB Decimal (ex., 0.0 0.0 1.0 0.5).}
{col 10}{hi:hsb}{col 35}{it:Hue, Saturation, Brightness (ex., 270.0 1.0 1.0)}
{col 10}{hi:hsba}{col 35}{it:Hue, Saturation, Brightness (ex., 270.0 1.0 1.0 0.5)}
{col 10}{hi:web}{col 35}{it:Hex string (ex., 0000FF) {hi:[returned with leading # added]}}
{col 10}{hi:weba}{col 35}{it:Hex string w/Decimal Alpha (ex., 0000FF .27) {hi:[returned with leading # added]}}
{col 10}{hi:weba}{col 35}{it:Hex string w/Hex Alpha (ex., 0000FF00)  {hi:[returned with leading # added]}}
{col 10}{hi:hex}{col 35}{it:Hexadecimal (ex., 0000FF)}
{col 10}{hi:hexa}{col 35}{it:Hexadecimal w/Alpha (ex., 0000FF 0.5)}
{col 10}{hi:hexa}{col 35}{it:Hex w/Alpha scaled as RGB Integer (e.g., 0000FFFF)}
{col 10}{hi:hexa web}{col 35}{it:Web Hexadecimal w/Alpha (ex., )}
{col 10}{hi:rgb web}{col 35}{it:Web RGB (ex., )}
{col 10}{hi:rgba web}{col 35}{it:Web RGB w/Alpha (ex., )}
{col 10}{hi:srgb}{col 35}{it:Web sRGB (ex., )}
{col 10}{hi:srgba}{col 35}{it:Web sRGB w/Alpha (ex., )}
{col 10}{hi:hsl}{col 35}{it:Hue, Saturation, Lightness (ex., hex, rgb, hsl)}
{col 10}{hi:hsla}{col 35}{it:Hue, Saturation, Lightness w/Alpha (ex., hex, rgb, hsl)}
{col 10}{hline 80}
 
{marker examples}{title:Examples}

{p 4 4 8}{stata brewterpolate, sc("197 115 47") ec("5, 37, 249") c(4)}{p_end}
{p 4 4 8}{stata brewterpolate, sc("197 115 47") ec("5, 37, 249") c(9) inv}{p_end}
{p 4 4 8}{stata brewterpolate, sc("197 115 47") ec("5, 37, 249") c(3) g}{p_end}
{p 4 4 8}{stata brewterpolate, sc("197 115 47") ec("5, 37, 249") c(5) rcs(web) cm(saturated)}{p_end}
{p 4 4 8}{stata brewterpolate, sc("197 115 47") ec("5, 37, 249") c(5) rcs(hexa) cm(desaturated)}{p_end}
{p 4 4 8}{stata brewterpolate, sc("197 115 47") ec("5, 37, 249") c(18) rcs(hsb)}{p_end}
{p 4 4 8}{stata brewterpolate, sc("197 115 47") ec("5, 37, 249") c(37) inv cm(brighter) rcs(hsb)}{p_end}
 
{marker references}{title:References}

{p 4 4 4}{browse "https://docs.oracle.com/javase/8/docs/api/java/awt/Color.html":Java Color Documentation}{p_end}
 
{title:Author}{break}
{p 4 4 8}William R. Buchanan, Ph.D.{p_end}
{p 4 4 8}Data Scientist{p_end}
{p 4 4 8}{browse "http://mpls.k12.mn.us":Minneapolis Public Schools}{p_end}
{p 4 4 8}William.Buchanan at mpls [dot] k12 [dot] mn [dot] us{p_end}
