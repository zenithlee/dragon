* lfsmerge2000_2.do
* Merge all modules of South Africa Labour Force Survey for each wave
* assign new standardized variable names and value labels
* D. Lam 12 Feb 2007
* last updated june 2008 by k.goostrey
* Modified by Andrew Kerr, May 2011

clear
set mem 600m

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFS2000\LFS2000_2"
use "`datafolder'\LFS 2000 _2 House_rw.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Sep2000
	}*/

	*rename hhid_Sep2000 hhid
	gen double hhid=UqNr
	*creating a string version of uqnr/hhid that helps to make merging in other data easier for PALMS end users:
	gen str20 uqnr_orig=string(hhid, "%16.0f" )
	gen str10 dataset="2000h2"
	gen wave=2
	sort hhid
	
	*creating an EA var..
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
	
	save "`datafolder'\lfs2000h2temp.dta", replace
	
	use "`datafolder'\lfs2000_2.cewgt.dta", replace


	merge 1:1 UqNr using "`datafolder'\lfs2000h2temp.dta"
	tab _merge
	rename _merge mergeh1
	sort hhid
/*need to come back to when worked out if I can use older data with non dodgy PSU and strata info..
	sort  UqNr
	save "`datafolder'\lfs2000h2temp1.dta", replace
	
	use "`datafolder'\LFS 2000 _2 Stratum_psu_rw.dta", replace

	sort  UqNr
	merge 1:1  UqNr using  "`datafolder'\lfs2000h2temp1.dta"
	*/
	
	
save "`datafolder'\lfs2000h2.dta", replace

	
use "`datafolder'\LFS 2000 _2 Person_rw.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Sep2000
	}*/
	
	*rename hhid_Sep2000 hhid
	*rename PersonNr_Sep2000 PersonNr
	gen double hhid=UqNr
	gen str10 dataset="2000p2"
	gen wave=2
	gen double personid=hhid*100+PersonNr
	sort personid
	save "`datafolder'\lfs2000p2.dta", replace
use "`datafolder'\LFS 2000 _2 Worker_rw.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Sep2000
	}*/
	*rename hhid_Sep2000 hhid
	*rename PersonNr_Sep2000 PersonNr
	gen double hhid=UqNr
	gen str10 dataset="2000w2"
	gen wave=2
	gen double personid=hhid*100+PersonNr
	sort personid
	save "`datafolder'\lfs2000w2.dta", replace
merge personid using "`datafolder'\lfs2000p2.dta"
rename _merge mergepw
sort hhid
merge hhid using "`datafolder'\lfs2000h2.dta"
rename _merge mergeh
format personid %16.0f
format hhid %14.0f
order hhid personid
compress
label data "South Africa Labour Force Survey 2000_2 merged"
quietly do "`mergefolder'\LFSrename2000_2.do"
quietly do "`mergefolder'\LFSrename2.do"
**generate vars consistent with other waves**
	gen empsector=1 if empsector1==3
	replace empsector=2 if empsector1==2
	replace empsector=3 if empsector1==7
	replace empsector=4 if empsector1==1
	replace empsector=8 if empsector1==8
	replace empsector=9 if empsector1==9
	gen teldistance=1 if teldistance1==1
	replace teldistance=2 if teldistance1==2
	replace teldistance=3 if teldistance1>=3 & teldistance1<=4
	replace teldistance=4 if teldistance1==5
	replace teldistance=8 if teldistance1==8
	replace teldistance=9 if teldistance1==9
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
quietly do "`mergefolder'\lfslabelvars.do"
quietly do "`mergefolder'\lfslabeldefine.do"
quietly do "`mergefolder'\lfslabelvalues.do"



*gen double hhid=uqnr
compress
sort personid
numlabel, add
save "`datafolder'\lfs2000_2.dta", replace
save "`mergefolder'\lfs2000_2.dta", replace

