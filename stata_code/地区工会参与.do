cd C:\Download
********** 2021
import exc "10-2 各地区工会会员人数2021年", clear
keep A C 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/3
replace P = subinstr(P," ","",.)
destring n, force replace
compress
save 2021, replace
import exc "1-6 分地区就业人员数2021年底数", clear
keep A C 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/4
replace P = subinstr(P," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
merge 1:1 P using 2021, nogen 
g year = 2021
save 2021, replace
********** 2020
import exc 2023_12_18_22_03_04_N2022020102000156-, clear
keep A F
ren F C 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
destring n, force replace
compress
save 2020, replace
import exc 2023_12_18_22_02_12_N2022020102000013-, clear
keep A E
ren E C 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
merge 1:1 P using 2020, nogen 
g year = 2020
save 2020, replace
********** 2019
import exc 2023_12_18_22_16_07_N2021020042000161-, clear
keep B F
ren (B F) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
destring n, force replace
compress
g i=_n
save 2019, replace
import exc 2023_12_18_22_15_52_N2021020042000016-, clear
keep A C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2019, nogen 
g year = 2019
drop i
save 2019, replace
********** 2018
import exc 2023_12_18_22_23_49_N2020030068000164-, clear
keep B F
ren (B F) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
destring n, force replace
compress
g i=_n
save 2018, replace
import exc 2023_12_18_22_23_36_N2020030068000015-, clear
keep A C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2018, nogen 
g year = 2018
drop i
save 2018, replace
********** 2017
import exc 2023_12_18_22_26_54_N2019030251000164-, clear
keep A G
ren (A G) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
destring n, force replace
compress
g i=_n
save 2017, replace
import exc 2023_12_18_22_25_48_N2019030251000015-, clear
keep A D
ren D C
drop if mi(C)
ren (A C) (Prov n)
drop in 1
replace P = subinstr(P," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2017, nogen 
g year = 2017
drop i
save 2017, replace
********** 2016
import exc 2023_12_18_22_39_42_N2018070151000169-, clear
keep A I
ren (A I) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
keep in 1/31
save 2016, replace
import exc 2023_12_18_22_39_16_N2018070151000015-, clear
keep A H
ren H C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2016, nogen 
g year = 2016
drop i
drop if mi(n)
save 2016, replace
********** 2015
import exc 2023_12_18_22_40_29_N2017060032000168-, clear
keep A I
ren (A I) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
keep in 1/31
save 2015, replace
import exc 2023_12_18_22_40_19_N2017060032000015-, clear
keep A F
ren F C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2015, nogen 
g year = 2015
drop i
drop if mi(n)
save 2015, replace
********** 2014
import exc 2023_12_18_22_41_00_N2016030140000171-, clear
keep A E
ren (A E) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
keep in 1/31
save 2014, replace
import exc 2023_12_18_22_44_35_N2016030140000016-, clear
keep A D
ren D C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2014, nogen 
g year = 2014
drop i
drop if mi(n)
save 2014, replace
********** 2013
import exc 2023_12_18_22_45_14_N2015040016000170-, clear
keep A H
ren (A H) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
keep in 1/31
save 2013, replace
import exc 2023_12_18_22_44_55_N2015040016000016-, clear
keep A D
ren D C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2013, nogen 
g year = 2013
drop i
drop if mi(n)
save 2013, replace
********** 2012
import exc 2023_12_18_22_48_42_N2014030148000173-, clear
keep A H
ren (A H) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
keep in 1/31
save 2012, replace
import exc 2023_12_18_22_45_14_N2015040016000170-, clear
keep A H
ren H C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
*replace m=m*10^4
g i=_n
merge 1:1 i using 2012, nogen 
g year = 2012
drop i
drop if mi(n)
save 2012, replace
********** 2011
import exc 2023_12_18_22_49_08_N2013040132000171-, clear
keep A N
ren (A N) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
keep in 1/31
save 2011, replace
import exc 2023_12_18_22_48_57_N2013040132000017-, clear
keep A J
ren J C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2011, nogen 
g year = 2011
drop i
drop if mi(n)
save 2011, replace
********** 2010
import exc 2023_12_18_22_49_52_N2012040044000171-, clear
keep A J
ren (A J) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
keep in 1/31
save 2010, replace
import exc 2023_12_18_22_49_42_N2012040044000016-, clear
keep A N
ren N C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2010, nogen 
g year = 2010
drop i
drop if mi(n)
save 2010, replace
********** 2009
import exc 2023_12_18_22_50_19_N2011010069000182-, clear
keep A L
ren (A L) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
keep in 1/31
save 2009, replace
import exc 2023_12_18_22_50_05_N2011010069000016-, clear
keep A I
ren I C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2009, nogen 
g year = 2009
drop i
drop if mi(n)
save 2009, replace
********** 2008
*【需要特殊处理】
*import exc 2023_12_18_22_50_46_N2010060111000203-, clear
clear
input strL a strL b
北京
Beijing
3704450
859216
158024
103549
天津
Tianjin
3677518
838289
188269
136310
河北
Hebei
11437422
1576632
607617
296347
山西
Shanxi
6800172
1686868
601357
136276
内蒙古
Inner Mongolia
5231312
866260
104151
152493
辽宁
Liaoning
11338255
2482023
901425
175537
吉林
Jilin
4250009
778692
105038
102580
黑龙江
Heilongjiang
6965658
2674126
276008
185877
上海
Shanghai
6907844
888920
404497
155848
江苏
Jiangsu
13584627
1068464
413658
587873
浙江
Zhejiang
11900356
496597
240693
1364867
安徽
Anhui
6003181
973602
410115
217533
福建
Fujian
6082845
494772
196652
99832
江西
Jiangxi
5515966
838144
157037
93079
山东
Shandong
17464638
1760826
1213239
667161
河南
Henan
11050401
1877051
654805
295428
湖北
Hubei
10732180
1086977
731928
574085
湖南
Hunan
9327045
1339761
473813
261438
广东
Guangdong
17999576
1128852
827023
529120
广西
Guangxi
4507002
749013
168617
68919
海南
Hainan
792045
297078
32117
6490
重庆
Chongqing
4238907
407165
156336
86860
四川
Sichuan
12287146
1107889
294464
167101
贵州
Guizhou
4104760
577392
75614
46493
云南
Yunnan
3305492
600766
71053
45145
西藏
Tibet
189448
0
0
0
陕西
Shaanxi
4963037
1158457
294433
98213
甘肃
Gansu
2811208
597805
89175
89979
青海
Qinghai
767692
140906
11829
9928
宁夏
Ningxia
881024
161690
14477
26728
新疆
Xinjiang
3088116
1330508
36823
29977
end 
g j=_n 
keep if mod(j,6)==3
keep a
ren a n
g i=_n
destring n, replace 
save 0, replace
import exc 2023_12_18_22_50_33_N2010060111000017-, clear
keep A K
ren K C
drop if mi(C)
ren (A C) (Prov n)
keep in 3/33
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 0, nogen 
g year = 2008
drop i
drop if mi(n)
compress
save 2008, replace
********** 2007
import exc 2023_12_18_22_51_41_N2009030130000204-, clear
keep A E
ren (A E) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
keep in 2/32
save 2007, replace
import exc 2023_12_18_22_51_30_N2009030130000018-, clear
keep A D
ren D C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2007, nogen 
g year = 2007
drop i
drop if mi(n)
replace P = substr(P,1,6)
replace P = "黑龙江" if regexm(P,"黑")
replace P = "内蒙古" if regexm(P,"内")
compress
save 2007, replace
********** 2006
import exc 2023_12_18_22_52_07_N2008070112000200-, clear
keep A I
ren (A I) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
save 2006, replace
import exc 2023_12_18_22_51_55_N2008070112000018-, clear
keep A L
ren L C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2006, nogen 
g year = 2006
drop i
drop if mi(n)
save 2006, replace
********** 2005
import exc 2023_12_18_22_52_35_N2007091064000217-, clear
tostring E, replace force 
replace G = E if mi(G) & E != "."
keep A G
ren (A G) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
save 2005, replace
import exc 2023_12_18_22_52_23_N2007091064000018-, clear
tostring F, replace force 
replace I = F if mi(I) & F != "."
keep A I
ren I C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2005, nogen 
g year = 2005
drop i
save 2005, replace
********** 2004
import exc 2023_12_18_22_52_57_N2006090325000238-, clear
keep A F
ren (A F) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
save 2004, replace
import exc 2023_12_18_22_52_50_N2006090325000018-, clear
keep A D
ren D C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2004, nogen 
g year = 2004
drop i
save 2004, replace
********** 2003
import exc 2023_12_18_22_53_23_N2005120198000216-, clear
keep A F
ren (A F) (A C) 
*drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
keep in 5/35
g i=_n
save 2003, replace
import exc 2023_12_18_22_53_19_N2005120198000009-, clear
keep A F
ren F C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2003, nogen 
g year = 2003
drop i
save 2003, replace
********** 2002
import exc 2023_12_18_22_53_50_N2005120197000213-, clear
keep A E
ren (A E) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
g i=_n
save 2002, replace
import exc 2023_12_18_22_53_41_N2005120197000009-, clear
keep A I
ren I C
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
replace n = subinstr(n," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2002, nogen 
g year = 2002
drop i
save 2002, replace
********** 2001
import exc 2023_12_18_22_54_19_N2005120196000201-, clear
keep A L
ren (A L) (A C) 
drop if mi(C)
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
destring n, force replace
compress
g i=_n
ren P a 
save 2001, replace
*
clear
input strL a strL b
西 藏
Tibet
24.0
15.8
0.9
0.7
6.6
陕 西
Shaanxi
451.5
265.1
28.0
40.0
118.4
甘 肃
Gansu
244.9
163.1
20.4
14.5
46.9
青 海
Qinghai
66.3
37.2
3.8
3.7
21.6
宁 夏
Ningxia
77.6
48.8
4.0
8.7
16.1
新 疆
Xinjiang
320.0
201.1
12.0
38.5
68.4
end 
g j=_n 
keep if inlist(j,3,10,17,24,31,38)
keep a
ren a C
save 0, replace
import exc 2023_12_18_22_54_14_N2005120196000009-, clear
keep A H
ren H C
drop if mi(C)
drop in 28/33
append using 0
ren (A C) (Prov n)
drop in 1/2
replace P = subinstr(P," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2001, nogen 
g year = 2001
drop i
drop P 
ren a Prov
order P 
save 2001, replace
********** 2000
import exc 2023_12_18_22_54_50_N2006010415000243-, clear
keep in 15/17
keep A I 
save 0, replace
clear
input strL A strL b strL c strL h strL e strL f strL D 
北  京        Beijing           12023              2416136        1023391      2280730
天  津        Tianjin           15029              2425198        1017579      2326931
河  北        Hebei             51805              5917152        2275616      5523908
山  西        Shanxi            22741              3997046        1141822      3563775
内蒙古        Inner Mongolia    18881              2855607        1039010      2680283
辽  宁        Liaoning          41167              8018747        3360629      7515909
吉  林        Jilin             12364              2999113        1181610      2719278
黑龙江        Heilong jiang     24602              4943863        1839698      4556196
上  海        Shanghai          47719              4230155        1745665      3738962
江  苏        Jiangsu           37160              6919654        2888113      6266704
浙  江        Zhejiang          65176              5666602        2233742      4493615
安  徽        Anhui             31912              3536165        1334967      3192764
福  建        Fujian            38096              3131939        1255760      2665834
江  西        Jiangxi           18208              2671220        826047       2373043
山  东        Shandong          50251              8435972        3276344      7665306
河  南        Henan             36092              6727909        2550043      6076572
湖  北        Hubei             45251              5323145        1978079      4755675
湖  南        Hunan             40975              4870111        1860886      4584605
广  东        Guangdong         65551              7606529        4238155      6158817
广  西        Guangxi           26278              2356357        841591       2191912
海  南        Hainan            5239               764118         312727       673948
重  庆        Chongqing         12566              1887058        674334       1752854
四  川        Sichuan           47964              4785355        1825928      44551
贵 州 Guizhou 16521 1680037 616072 1579501
云 南 Yunnan 19904 2312741 876411 2155388
西 藏 Tibet 2398 164574 65830 136128
陕 西 Shaanxi 18989 2983415 1101078 2789496
甘 肃 Gansu 10768 1682491 608605 1546931
end 
keep A D
append using 0
ren (A D) (Prov n)
replace P = subinstr(P," ","",.)
destring n, force replace
compress
g i=_n
save 2000, replace
import exc 2023_12_18_22_54_40_N2006010415000010-, clear
keep in 5/36
drop in 27
keep A J
ren J C
drop if mi(C)
ren (A C) (Prov n)
replace P = subinstr(P," ","",.)
destring n, force replace
compress
ren n m 
replace m=m*10^4
g i=_n
merge 1:1 i using 2000, nogen 
g year = 2000
drop i
save 2000, replace
* 
use 2000, clear
replace m = . 
replace n = . 
replace y = 2022
save 2022, replace
********** combined 
clear
forv x=2000/2022{
append using `x'
}
compress
bys P: ipolate m y, epolate g(M)
bys P: ipolate n y, epolate g(N)
keep P M N y 
so P y 
g LaborUnion = N/M
replace L = 1/L if L > 1
save LLL, replace
keep P y L 
la var L 地区工会参与
save 地区工会参与, replace 
d
ta y 
kdensity L 