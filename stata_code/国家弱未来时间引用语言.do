cd C:\Download
import exc L, clear 
drop in 1/63
nrow 1 
drop if mi(C)
drop in 199/281 
compress 
split B, p(,)
keep C B1 
ren B B 
split B, p(;)
keep C B1 
ren B B 
split B, p("(")
keep C B1 
ren B B
forv i = 0/9{
split B, p(`i')
keep C B1 
ren B B  
}
save 0, replace
*
clear 
input strL v1 strL v2 strL v3 strL v4 strL v5 strL v6 strL v7 
Azerbaijani 100.0 100.0 Strong
Basque 98.4 100.0 Strong
Catalan 100.0 100.0 Strong
Greek 97.4 100.0 Strong
Hebrew 100.0 100.0 Strong
Irish 100.0 100.0 Strong
Korean 82.2 100.0 Strong
French 95.8 97.6 Strong
Albanian 98.4 97.5 Strong
Lithuanian 93.2 97.2 Strong
Belarusian 93.5 96.4 Strong
Bulgarian 93.8 95.5 Strong
Romanian 96.1 95.1 Strong
Slovenian 81.5 94.4 Strong
English (UK) 88.1 92.9 Strong
Italian 90.0 92.9 Strong
English (US) 76.9 87.5 Strong
Maltese 86.4 82.4 Strong
Portuguese (EU) 85.0 81.3 Strong
Russian 72.2 80.8 Strong
Croatian 78.6 80.0 Strong
Spanish 71.6 74.1 Strong
Turkish 55.8 66.7 Strong
Vietnamese 59.6 66.7 Strong
Latvian 58.3 55.2 Strong
Czech 46.4 54.5 Strong
Arabic 41.7 52.9 Strong
Polish 28.2 34.4 Strong
Hungarian 25.0 32.3 Strong
Norwegian 15.3 20.9 Weak
Danish 10.0 12.5 Weak
Swedish 4.9 6.3 Weak
Chinese 0.0 0.0 Weak
Dutch 0.0 0.0 Weak
Estonian 0.0 0.0 Weak
Finnish 0.0 0.0 Weak
German 0.0 0.0 Weak
Japanese 0.0 0.0 Weak
Portuguese (BR) 0.0 0.0 Weak
end 
g weak = 0
foreach v of var v*{
replace w = 1 if regexm(`v',"Weak")
}
keep v1 w 
duplicates drop 
save 1, replace
*
use 0, clear 
g weak = 0 
foreach i in Norwegian Danish Swedish Chinese Dutch Estonian Finnish German Japanese Portuguese{
replace w = 1 if regexm(B,"`i'")
}
drop B 
ren w Weak_FTR
la var W 国家弱未来时间引用语言
save 国家弱未来时间引用语言, replace
d
ta W  