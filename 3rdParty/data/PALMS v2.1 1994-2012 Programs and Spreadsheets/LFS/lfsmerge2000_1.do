
* lfsmerge2000_1.do
* Merge all modules of South Africa Labour Force Survey for each wave
* assign new standardized variable names and value labels
* D. Lam 12 Feb 2007
* last updated june 2008 k.goostrey
* Modified by Andrew Kerr, May 2011

clear all
set mem 600m

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFS2000\LFS2000_1"
use "`datafolder'\LFS 2000_1 General.dta"

	gen double hhid=UqNr
	*creating a string version of uqnr that helps to make merging in other data easier for PALMS end users:
	gen str20 uqnr_orig=string(hhid, "%16.0f" )
	
	gen str10 dataset="2000h1"
	gen wave=1
	sort hhid
	drop if Q113aMst_Feb2000==88
	*roughly 1100 with no person or worker info attached to them, drop!
	
/*creating an EA var..*/
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
	save "`datafolder'\lfs2000h1temp.dta", replace
	
use "`datafolder'\lfs2000_1.cewgt.dta", replace


	merge 1:1 UqNr using "`datafolder'\lfs2000h1temp.dta"
	tab _merge
	rename _merge mergeh1
	sort hhid
save "`datafolder'\lfs2000h1.dta", replace

	
use "`datafolder'\LFS 2000_1 Person.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Feb2000
	}*/
	*rename hhid_Feb2000 hhid
	gen double hhid=UqNr
	*rename PersonNr_Feb2000 PersonNr
	gen str10 dataset="2000p1"
	gen wave=1
	gen double personid=hhid*100+PersonNr
	gen str20 uqnr_orig=string(hhid, "%16.0f" )
	sort personid
	save "`datafolder'\lfs2000p1.dta", replace
use "`datafolder'\LFS 2000_1 Worker.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Feb2000
	}*/
	*rename hhid_Feb2000 hhid
	gen double hhid=UqNr
	*rename PersonNr_Feb2000 PersonNr
	rename Sector_Feb2000 Sector_Feb2000_Feb2000
	gen str10 dataset="2000w1"
	gen wave=1
	gen double personid=hhid*100+PersonNr
	sort personid
	save "`datafolder'\lfs2000w1.dta", replace
merge personid using "`datafolder'\lfs2000p1.dta"
rename _merge mergepw
*these next 3 lines were commented out, not sure why??
sort hhid
merge hhid using "`datafolder'\lfs2000h1.dta"
rename _merge mergeh
format personid %16.0f
format hhid %14.0f
order hhid personid
compress

label data "South Africa Labour Force Survey 2000_1 merged"
quietly do "`mergefolder'\LFSrename2000_1.do"
quietly do "`mergefolder'\LFSrename2.do"
**generate vars consistent with other waves**
	gen marstat=1 if marstat1==2
	replace marstat=2 if marstat1==3
	replace marstat=3 if marstat1==4
	replace marstat=4 if marstat1==1
	replace marstat=9 if marstat1==9
	gen empsector=1 if empsector1==3
	replace empsector=2 if empsector1==2
	replace empsector=3 if empsector1==7
	replace empsector=4 if empsector1==1
	replace empsector=8 if empsector1==8
	replace empsector=9 if empsector1==9
	/*AK: keeping var as whynotwork, since that is how marital status was coded after a similar change in value codes and whynotwork was missing value labels as a result of ///
	not being properly coded.
	gen whynotwork=1 if whynotwork1==1
	forval i=2/12 {
	replace whynotwork=`i' if whynotwork1==`i'
	}
	replace whynotwork=88 if whynotwork1==88
	replace whynotwork=99 if whynotwork1==99
	*/
foreach m in jan feb mar apr may jun jul aug sep oct nov dec {
	recode farmyr`m'1 (0=2) (1=1)
	rename farmyr`m'1 farmyr`m'
}


quietly do "`mergefolder'\lfslabelvars.do"
quietly do "`mergefolder'\lfslabeldefine.do"
quietly do "`mergefolder'\lfslabelvalues.do"

drop if uqnr_orig==""
compress
sort personid
numlabel, add


save "`datafolder'\lfs2000_1.dta", replace
save "`mergefolder'\lfs2000_1.dta", replace

