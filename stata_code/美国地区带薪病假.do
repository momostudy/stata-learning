clear 
input strL statename LawEffective
Arizona 2017
California 2015
Connecticut 2012
DC 2014
Maryland 2018
Massachusetts 2015
Oregon 2016
Rhode_Island 2018
Vermont 2017
Washington 2017
end 
compress
merge 1:1 s using statename, nogen 
replace stateid = "DC" if staten == "DC"
replace L = 9999 if mi(L)
drop staten
forv i=2010/2024{
g y`i' = `i'>= L 
}
gather y* 
ren val SickPay 
g year = substr(v,2,.)
destring *, replace  
drop v L 
la var S 美国地区带薪病假
la var s 州代码
order s y 
sa 美国地区带薪病假, replace 
d
ta y S 