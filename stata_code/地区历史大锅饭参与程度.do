cd C:\Download
clear
input strL a b 
Anhui 90.5 0.83 01/1949
Fujian 67.2 1.06 08/1949
Gansu 47.7 1.54 08/1949
Guangdong 77.6 0.93 11/1949
Guangxi 91.0 0.85 11/1949
Guizhou 92.6 0.86 11/1949
Hebei 74.4 3.14 11/1947
Heilongjiang 26.5 1.38 10/1948
Henan 97.8 1.08 06/1948
Hubei 68.2 0.77 05/1949
Hunan 97.6 0.80 08/1949
InnerMongolia 16.7 1.78 09/1949
Jiangsu 56.0 1.37 04/1949
Jiangxi 61.0 1.39 05/1949
Jilin 29.4 1.62 10/1948
Liaoning 23.0 1.75 11/1948
Ningxia 52.9 N.A. 09/1949
Qinghai 29.9 1.04 09/1949
Shaanxi 60.8 1.15 05/1949
Shandong 35.5 2.14 09/1948
Shanxi 70.6 2.92 10/1948
Sichuan 96.7 0.71 11/1949
Yunnan 96.5 0.98 12/1949
Zhejiang 81.6 0.78 05/1949
end 
compress
save 1, replace
*
clear
input i strL c strL a
1 安徽 Anhui AH
2 北京 Beijing BJ
3 福建 Fujian FJ
4 甘肃 Gansu GS
5 广东 Guangdong GD
6 广西 Guangxi GX
7 贵州 Guizhou GZ
8 海南 Hainan HI
9 河北 Hebei HE
10 河南 Henan HA
11 黑龙江 Heilongjiang HL
12 湖北 Hubei HB
13 湖南 Hunan HN
14 吉林 Jilin JL
15 江苏 Jiangsu JS
16 江西 Jiangxi JX
17 辽宁 Liaoning LN
18 内蒙古自治区 InnerMongolia IM（NM）
19 宁夏 Ningxia NX
20 青海 Qinghai QH
21 山东 Shandong SD
22 山西 Shanxi SX
23 陕西 Shaanxi SN
24 上海 Shanghai SH
25 四川 Sichuan SC
26 天津 Tianjing TJ
27 西藏 Tibet XZ
28 新疆 Xinjiang XJ
29 云南 Yunnan YN
30 浙江 Zhejiang ZJ
31 重庆 Chongqing CQ
end
compress
merge 1:1 a using 1, nogen 
g q = 0
replace q = 1 if c == "北京" | c == "天津" | c == "河北" 
replace q = 2 if c == "四川" | c == "重庆" 
bys q: fillmissing b
keep c b
ren (c b) (Province MHPR)
so M
save 地区历史大锅饭参与程度, replace
d
kdensity M