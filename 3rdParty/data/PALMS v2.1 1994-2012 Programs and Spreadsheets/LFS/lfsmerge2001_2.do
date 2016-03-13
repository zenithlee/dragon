* lfsmerge2001_2.do
* Merge all modules of South Africa Labour Force Survey for each wave
* assign new standardized variable names and value labels
* D. Lam 12 Feb 2007
* last updated june 2008 by k.goostrey
* Modified by Andrew Kerr, May 2011

clear
set mem 600m

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFS2001\LFS2001_2"
use "`datafolder'\LFS 2001_2 House.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Sep2001
	}*/
	*rename UqNr_Sep2001 UqNr
	gen str10 dataset="2001h2"
	gen wave=4
	gen double hhid=UqNr
	*creating a string version of uqnr/hhid that helps to make merging in other data easier for PALMS end users:
	gen str20 uqnr_orig=string(hhid, "%16.0f" )
	sort hhid
	save "`datafolder'\lfs2001h2temp.dta", replace
	
	use "`datafolder'\lfs2001_2.cewgt.dta", replace


	merge 1:1 UqNr using "`datafolder'\lfs2001h2temp.dta"
	tab _merge
	rename _merge mergeh1
	
	sort UqNr
	by UqNr: gen onememb=1 if _n==1
	gen str20 hhidstring=string( UqNr, "%13.0f")
	gen hhidsub1=substr(hhidstring,1, 7)
	sort  hhidsub1
	by  hhidsub1: egen hhperea=total(onememb)
	by  hhidsub1: gen oneea=1 if _n==1
	tab  hhperea
	destring hhidsub1, gen(psu)
	drop oneea onememb
	
	sort hhid
save "`datafolder'\lfs2001h2temp2.dta", replace


use "`datafolder'\LFS 2001_2 Stratum_psu.dta", replace
	*psu in data is not correct, create new one from first 7 digits of uqnr


	tostring   stratum_Sep2001, gen (stratumstr)
	replace stratumstr="0"+ stratumstr if length( stratumstr)==1
	tab  stratumstr
	drop  stratumstr Psu_Sep2001 
	sort  UqNr
	merge 1:1  UqNr using  "`datafolder'\lfs2001h2temp2.dta"
	rename _merge mergeh2


	sort hhid
	save "`datafolder'\lfs2001h2.dta", replace
	
use "`datafolder'\LFS 2001_2 Person.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Sep2001
	}*/
	*rename UqNr_Sep2001 UqNr
	*rename PersonNr_Sep2001 PersonNr
	gen str10 dataset="2001p2"
	gen wave=4
	gen double hhid=UqNr
	gen double personid=hhid*100+PersonNr
	gen str20 uqnr_orig=string(hhid, "%16.0f" )
	sort personid
	save "`datafolder'\lfs2001p2.dta", replace
use "`datafolder'\LFS 2001_2 Worker.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Sep2001
	}*/
	*rename UqNr_Sep2001 UqNr
	*rename PersonNr_Sep2001 PersonNr
	gen str10 dataset="2001w2"
	gen wave=4
	gen double hhid=UqNr
	gen double personid=hhid*100+PersonNr
	sort personid
	save "`datafolder'\lfs2001w2.dta", replace
merge personid using "`datafolder'\lfs2001p2.dta"
rename _merge mergepw
sort hhid
merge hhid using "`datafolder'\lfs2001h2.dta"
rename _merge mergeh
format personid %16.0f
format hhid %14.0f
order hhid personid
compress
label data "South Africa Labour Force Survey 2001_2 merged"
quietly do "`mergefolder'\LFSrename2001_2.do"
quietly do "`mergefolder'\LFSrename2.do"
**generate vars consisten with other waves**
	/*keeping var as whynotwork, since that is how marital status was coded after a similar change in value codes and whynotwork was missing value labels as a result of ///
	not being properly coded.
	gen whynotwork=1 if whynotwork1==1
	forval i=2/12 {
	replace whynotwork=`i' if whynotwork1==`i'
	}
	replace whynotwork=88 if whynotwork1==88
	replace whynotwork=99 if whynotwork1==99
	*/
	gen searchhow=1 if searchhow1==1
	replace searchhow=2 if searchhow1==2
	replace searchhow=3 if searchhow1==3
	replace searchhow=4 if searchhow1==4
	replace searchhow=5 if searchhow1==5
	replace searchhow=6 if searchhow1==7
	replace searchhow=7 if searchhow1==8
	replace searchhow=7 if searchhow1==6
	replace searchhow=8 if searchhow1==9
	replace searchhow=88 if searchhow1==88
	replace searchhow=99 if searchhow1==99
	gen whenlastjob=1 if whenlastjob2==1
	replace whenlastjob=2 if whenlastjob2>=2 & whenlastjob2<=6
	replace whenlastjob=3 if whenlastjob2==7
	replace whenlastjob=4 if whenlastjob2==8
	replace whenlastjob=5 if whenlastjob2==9
	replace whenlastjob=6 if whenlastjob2==10
	replace whenlastjob=7 if whenlastjob2==11
	replace whenlastjob=8 if whenlastjob2==88
	replace whenlastjob=9 if whenlastjob2==99
	gen roofmaterial=1 if roofmaterial2==1
	forval i=2/12 {
	replace roofmaterial=`i' if roofmaterial2==`i'
	}
	replace roofmaterial=99 if roofmaterial2>=13 & roofmaterial2<=99
	gen wallsmaterial=1 if wallsmaterial2==1
	forval i=2/12 {
	replace wallsmaterial=`i' if wallsmaterial2==`i'
	}
	replace wallsmaterial=99 if wallsmaterial2>=13 & wallsmaterial2<=99
	gen teldistance=1 if teldistance2>=1 & teldistance2<=2
	replace teldistance=2 if teldistance2==3
	replace teldistance=3 if teldistance2==4
	replace teldistance=4 if teldistance2>=5 & teldistance2<=6
	replace teldistance=8 if teldistance2==8
	replace teldistance=9 if teldistance2==9
	gen searchlength=1 if searchlength2==1
	replace searchlength=2 if searchlength2>=2 & searchlength2<=5
	replace searchlength=3 if searchlength2==6
	replace searchlength=4 if searchlength2==7
	replace searchlength=5 if searchlength2==8
	replace searchlength=6 if searchlength2==9
	replace searchlength=8 if searchlength2>=10 & searchlength2<=88
	replace searchlength=9 if searchlength2==99
quietly do "`mergefolder'\lfslabelvars.do"
quietly do "`mergefolder'\lfslabeldefine.do"
quietly do "`mergefolder'\lfslabelvalues.do"
sort personid
compress
numlabel, add

*june 2013: dropping 1 obs with no data!
drop if uqnr==7221252009501 &hhid==.


save "`datafolder'\lfs2001_2.dta", replace
save "`mergefolder'\lfs2001_2.dta", replace

