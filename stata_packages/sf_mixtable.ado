*! version 3.0 13Mar2017 
*! by Hung-Jen Wang
*!    Department of Economics, National Taiwan University
*!    wangh@ntu.edu.tw

capture program drop sf_mixtable
program define sf_mixtable

* usage: sf_mixtable, dof(4)

syntax , DOF(string)

if "`dof'"=="" {
     di in red "You need to specify the degrees of freedom in -dof()-."
     exit 198
}

if (`dof' > 40) | (`dof' < 1) {
     di in red "The degrees of freedom should be between 1 and 40."
     exit 198
}

di " "
di in gre "critical values of the mixed chi-square distribution"
di " "
di in gre "                              significance level"

di in gre _col(2) "dof" _col(7) "|" _col(10) "0.25"  _col(19) "0.1"  _col(29) "0.05" _col(39) "0.025" _col(49) "0.01"  _col(59) "0.005" _col(69) "0.001"
di in gre "-------------------------------------------------------------------------"


if `dof' == 1 {
di in yel _col(3)   "1"    _col(10)  "0.455"     _col(19)  "1.642"     _col(29)  "2.705"     _col(39)  "3.841"     _col(49)  "5.412"     _col(59)  "6.635"     _col(69)  "9.500"
}
else if `dof' == 2 {
di in yel _col(3)   "2"    _col(10)  "2.090"     _col(19)  "3.808"     _col(29)  "5.138"     _col(39)  "6.483"     _col(49)  "8.273"     _col(59)  "9.634"     _col(69)  "12.810"
}
else if `dof' == 3 {
di in yel _col(3)   "3"    _col(10)  "3.475"     _col(19)  "5.528"     _col(29)  "7.045"     _col(39)  "8.542"     _col(49)  "10.501"    _col(59)  "11.971"    _col(69)  "15.357"
}
else if `dof' == 4 {
di in yel _col(3)   "4"    _col(10)  "4.776"     _col(19)  "7.094"     _col(29)  "8.761"     _col(39)  "10.383"    _col(49)  "12.483"    _col(59)  "14.045"    _col(69)  "17.612"
}
else if `dof' == 5 {
di in yel _col(3)   "5"    _col(10)  "6.031"     _col(19)  "8.574"     _col(29)  "10.371"    _col(39)  "12.103"    _col(49)  "14.325"    _col(59)  "15.968"    _col(69)  "19.696"
}
else if `dof' == 6 {
di in yel _col(3)   "6"    _col(10)  "7.257"     _col(19)  "9.998"     _col(29)  "11.911"    _col(39)  "13.742"    _col(49)  "16.704"    _col(59)  "17.791"    _col(69)  "21.666"
}
else if `dof' == 7 {
di in yel _col(3)   "7"    _col(10)  "8.461"     _col(19)  "11.383"    _col(29)  "13.401"    _col(39)  "15.321"    _col(49)  "17.755"    _col(59)  "19.540"    _col(69)  "23.553"
}
else if `dof' == 8 {
di in yel _col(3)   "8"    _col(10)  "9.648"     _col(19)  "12.737"    _col(29)  "14.853"    _col(39)  "16.856"    _col(49)  "19.384"    _col(59)  "21.232"    _col(69)  "25.370"
}
else if `dof' == 9 {
di in yel _col(3)   "9 "   _col(10)  "10.823"    _col(19)  "14.067"    _col(29)  "16.274"    _col(39)  "18.354"    _col(49)  "20.972"    _col(59)  "22.879"    _col(69)  "27.133"
}
else if `dof' == 10 {
di in yel _col(2)   "10"   _col(10)  "11.987"    _col(19)  "15.377"    _col(29)  "17.670"    _col(39)  "19.824"    _col(49)  "22.525"    _col(59)  "24.488"    _col(69)  "28.856"
}
else if `dof' == 11 {
di in yel _col(2)   "11"   _col(10)  "13.142"    _col(19)  "16.670"    _col(29)  "19.045"    _col(39)  "21.268"    _col(49)  "24.049"    _col(59)  "26.065"    _col(69)  "30.542"
}
else if `dof' == 12 {
di in yel _col(2)   "12"   _col(10)  "14.289"    _col(19)  "17.949"    _col(29)  "20.410"    _col(39)  "22.691"    _col(49)  "25.549"    _col(59)  "27.616"    _col(69)  "32.196"
}
else if `dof' == 13 {
di in yel _col(2)   "13"   _col(10)  "15.430"    _col(19)  "19.216"    _col(29)  "21.742"    _col(39)  "24.096"    _col(49)  "27.026"    _col(59)  "29.143"    _col(69)  "33.823"
}
else if `dof' == 14 {
di in yel _col(2)   "14"   _col(10)  "16.566"    _col(19)  "20.472"    _col(29)  "23.069"    _col(39)  "25.484"    _col(49)  "28.485"    _col(59)  "30.649"    _col(69)  "35.425"
}
else if `dof' == 15 {
di in yel _col(2)   "15"   _col(10)  "17.696"    _col(19)  "21.718"    _col(29)  "24.384"    _col(39)  "26.856"    _col(49)  "29.927"    _col(59)  "32.136"    _col(69)  "37.005"
}
else if `dof' == 16 {
di in yel _col(2)   "16"   _col(10)  "18.824"    _col(19)  "22.956"    _col(29)  "25.689"    _col(39)  "28.219"    _col(49)  "31.353"    _col(59)  "33.607"    _col(69)  "38.566"
}
else if `dof' == 17 {
di in yel _col(2)   "17"   _col(10)  "19.943"    _col(19)  "24.186"    _col(29)  "26.983"    _col(39)  "29.569"    _col(49)  "32.766"    _col(59)  "35.063"    _col(69)  "40.109"
}
else if `dof' == 18 {
di in yel _col(2)   "18"   _col(10)  "21.060"    _col(19)  "25.409"    _col(29)  "28.268"    _col(39)  "30.908"    _col(49)  "34.167"    _col(59)  "36.505"    _col(69)  "41.636"
}
else if `dof' == 19 {
di in yel _col(2)   "19"   _col(10)  "22.174"    _col(19)  "26.625"    _col(29)  "29.545"    _col(39)  "32.237"    _col(49)  "35.556"    _col(59)  "37.935"    _col(69)  "43.148"
}
else if `dof' == 20 {
di in yel _col(2)   "20"   _col(10)  "23.285"    _col(19)  "27.835"    _col(29)  "30.814"    _col(39)  "33.557"    _col(49)  "36.935"    _col(59)  "39.353"    _col(69)  "44.646"
}
else if `dof' == 21 {
di in yel _col(2)   "21"   _col(10)  "24.394"    _col(19)  "29.040"    _col(29)  "32.077"    _col(39)  "34.869"    _col(49)  "38.304"    _col(59)  "40.761"    _col(69)  "46.133"
}
else if `dof' == 22 {
di in yel _col(2)   "22"   _col(10)  "25.499"    _col(19)  "30.240"    _col(29)  "33.333"    _col(39)  "36.173"    _col(49)  "39.664"    _col(59)  "42.158"    _col(69)  "47.607"
}
else if `dof' == 23 {
di in yel _col(2)   "23"   _col(10)  "26.602"    _col(19)  "31.436"    _col(29)  "34.583"    _col(39)  "37.470"    _col(49)  "41.016"    _col(59)  "43.547"    _col(69)  "49.071"
}
else if `dof' == 24 {
di in yel _col(2)   "24"   _col(10)  "27.703"    _col(19)  "32.627"    _col(29)  "35.827"    _col(39)  "38.761"    _col(49)  "42.360"    _col(59)  "44.927"    _col(69)  "50.524"
}
else if `dof' == 25 {
di in yel _col(2)   "25"   _col(10)  "28.801"    _col(19)  "33.813"    _col(29)  "37.066"    _col(39)  "40.045"    _col(49)  "43.696"    _col(59)  "46.299"    _col(69)  "51.968"
}
else if `dof' == 26 {
di in yel _col(2)   "26"   _col(10)  "29.898"    _col(19)  "34.996"    _col(29)  "38.301"    _col(39)  "41.324"    _col(49)  "45.026"    _col(59)  "47.663"    _col(69)  "53.403"
}
else if `dof' == 27 {
di in yel _col(2)   "27"   _col(10)  "30.992"    _col(19)  "36.176"    _col(29)  "39.531"    _col(39)  "42.597"    _col(49)  "46.349"    _col(59)  "49.020"    _col(69)  "54.830"
}
else if `dof' == 28 {
di in yel _col(2)   "28"   _col(10)  "32.085"    _col(19)  "37.352"    _col(29)  "40.756"    _col(39)  "43.865"    _col(49)  "47.667"    _col(59)  "50.371"    _col(69)  "56.248"
}
else if `dof' == 29 {
di in yel _col(2)   "29"   _col(10)  "33.176"    _col(19)  "38.524"    _col(29)  "41.977"    _col(39)  "45.128"    _col(49)  "48.978"    _col(59)  "51.715"    _col(69)  "57.660"
}
else if `dof' == 30 {
di in yel _col(2)   "30"   _col(10)  "34.266"    _col(19)  "39.694"    _col(29)  "43.194"    _col(39)  "46.387"    _col(49)  "50.284"    _col(59)  "53.054"    _col(69)  "59.064"
}
else if `dof' == 31 {
di in yel _col(2)   "31"   _col(10)  "35.354"    _col(19)  "40.861"    _col(29)  "44.408"    _col(39)  "47.641"    _col(49)  "51.585"    _col(59)  "54.386"    _col(69)  "60.461"
}
else if `dof' == 32 {
di in yel _col(2)   "32"   _col(10)  "36.440"    _col(19)  "42.025"    _col(29)  "45.618"    _col(39)  "48.891"    _col(49)  "52.881"    _col(59)  "55.713"    _col(69)  "61.852"
}
else if `dof' == 33 {
di in yel _col(2)   "33"   _col(10)  "37.525"    _col(19)  "43.186"    _col(29)  "46.825"    _col(39)  "50.137"    _col(49)  "54.172"    _col(59)  "57.035"    _col(69)  "63.237"
}
else if `dof' == 34 {
di in yel _col(2)   "34"   _col(10)  "38.609"    _col(19)  "44.345"    _col(29)  "48.029"    _col(39)  "51.379"    _col(49)  "55.459"    _col(59)  "58.352"    _col(69)  "64.616"
}
else if `dof' == 35 {
di in yel _col(2)   "35"   _col(10)  "39.691"    _col(19)  "45.501"    _col(29)  "49.229"    _col(39)  "52.618"    _col(49)  "56.742"    _col(59)  "59.665"    _col(69)  "65.989"
}
else if `dof' == 36 {
di in yel _col(2)   "36"   _col(10)  "40.773"    _col(19)  "46.655"    _col(29)  "50.427"    _col(39)  "53.853"    _col(49)  "58.020"    _col(59)  "60.973"    _col(69)  "67.357"
}
else if `dof' == 37 {
di in yel _col(2)   "37"   _col(10)  "41.853"    _col(19)  "47.808"    _col(29)  "51.622"    _col(39)  "55.085"    _col(49)  "59.295"    _col(59)  "62.276"    _col(69)  "68.720"
}
else if `dof' == 38 {
di in yel _col(2)   "38"   _col(10)  "42.932"    _col(19)  "48.957"    _col(29)  "52.814"    _col(39)  "56.313"    _col(49)  "60.566"    _col(59)  "63.576"    _col(69)  "70.078"
}
else if `dof' == 39 {
di in yel _col(2)   "39"   _col(10)  "44.010"    _col(19)  "50.105"    _col(29)  "54.003"    _col(39)  "57.539"    _col(49)  "61.833"    _col(59)  "64.871"    _col(69)  "71.432"
}
else if `dof' == 40 {
di in yel _col(2)   "40"   _col(10)  "45.087"    _col(19)  "51.251"    _col(29)  "55.190"    _col(39)  "58.762"    _col(49)  "63.097"    _col(59)  "66.163"    _col(69)  "72.780"
}
else {
 di in red "You did not specify the degrees of freedom option -dof- correctly.
 exit 198
}


di " "
di in gre "source: Table 1, Kodde and Palm (1986, Econometrica)."
di " "

end
