*********************************************************************************************************************************
*********************************************************************************************************************************
*     											ACREGPACKCHECK - companion program for 	   										*
*																																*
*     						ACREG: Program for computing corrected standard errors for Arbitrary Clustering		   				*
*		   		 					 Copyright: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig								    *
*																																*
*									Beta Version, please do not circulate - This Version: December 2020							*    
*																																*
* 									Before using this program, please read to our companion papers								*
*																																*
*  			"Acreg: arbirtrary correlation regression", F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig (2020)					*
*																																*
*  	"Inference with Arbitrary Clustering", F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig, (2019) IZA Discussion Papaer		*
*																																*
*********************************************************************************************************************************
*********************************************************************************************************************************

*! Version December 2020  (1.1.0)
*! ACREG: Arbitrary Correlation Regression
*! Authors: F. Colella, R. Lalive, S.O. Sakalli, M. Thoenig


*******************************************************************************************	
capt program drop acregpackcheck
program acregpackcheck, rclass
	syntax ,
	foreach package in ivreg2 ranktest hdfe {
		capture which `package'
		if _rc!=111 di in ye "`package' already installed"
		if _rc==111 ssc install `package' , replace
		}
	di " "
	di in gr "all packages were succesfully installed"
end 
