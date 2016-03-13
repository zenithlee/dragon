* lfsmerge2002_2.do
* Merge all modules of South Africa Labour Force Survey for each wave
* assign new standardized variable names and value labels
* D. Lam 12 Feb 2007
* last updated june 2008 by k.goostrey
* Modified by Andrew Kerr, May 2011

clear all
set mem 600m

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFS2002\LFS2002_2"

use "`datafolder'\LFS 2002_2 House.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Sep2002
	}*/
	*rename UqNr_Sep2002 UqNr
	gen str10 dataset="2002h2"
	gen wave=6
	gen double hhid=UqNr
	*creating a string version of uqnr/hhid that helps to make merging in other data easier for PALMS end users:
	gen str20 uqnr_orig=string(hhid, "%16.0f" )
	sort hhid
	
	* getting an EA variable, include later!!
		sort UqNr
	by UqNr: gen onememb=1 if _n==1
	gen str20 hhidstring=string( UqNr, "%13.0f")
	gen hhidsub1=substr(hhidstring,1, 7)
	sort  hhidsub1
	by  hhidsub1: egen hhperea=total(onememb)
	by  hhidsub1: gen oneea=1 if _n==1
	tab  hhperea if oneea==1
	destring hhidsub1, gen(psu)
	
	save "`datafolder'\lfs2002h2temp.dta", replace
	
	use "`datafolder'\lfs2002_2.cewgt.dta", replace


	merge 1:1 UqNr using "`datafolder'\lfs2002h2temp.dta"
	tab _merge
	rename _merge mergeh1
	sort hhid
save "`datafolder'\lfs2002h2.dta", replace
	
	/*not yet working, problem with the hh stratpsu file
	use "`datafolder'\LFS 2002_2 Stratpsu_Hhold Level_DataFirst.dta", replace
	*psu in data is not correct, need to fix, done below
	tostring  psu, gen(psustr)
	replace  psustr="00"+ psustr if length( psustr)==1
	replace  psustr="0"+ psustr if length( psustr)==2
	drop psu

	gen psu= stratum+ psustr
	destring psu, replace
	drop   psustr	
	destring uqnr, replace
	gen double UqNr=uqnr
	drop uqnr
	sort  UqNr
	merge 1:1  UqNr using  "`datafolder'\lfs2002h2temp2.dta"
	rename _merge mergeh2


	sort hhid
	save "`datafolder'\lfs2002h2.dta", replace
*/
	
	
use "`datafolder'\LFS 2002_2 Migrant.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Sep2002
	}*/
	*rename UqNr_Sep2002 UqNr
	gen str10 dataset="2002m2"
	gen wave=6
	gen double hhid=UqNr
	sort hhid
	save "`datafolder'\lfs2002m2.dta", replace
use "`datafolder'\LFS 2002_2 Person.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Sep2002
	}*/
	*rename UqNr_Sep2002 UqNr
	gen str10 dataset="2002p2"
	gen wave=6
	gen double hhid=UqNr
	gen double personid=hhid*100+PersonNr
	sort personid
	save "`datafolder'\lfs2002p2.dta", replace
use "`datafolder'\LFS 2002_2 Worker.dta"
	/*foreach v of varlist * {
		rename `v' `v'_Sep2002
	}*/
	*rename UqNr_Sep2002 UqNr
	*rename Person_Wgt_Sep2002_Sep2002 person_wgt_Sep2002_Sep2002
	gen str10 dataset="2002w2"
	gen wave=6
	gen double hhid=UqNr
	gen double personid=hhid*100+PersonNr
	drop Person_Wgt_Sep2002 
	*same as weight in the person data but only defined for workers, so useless AND is confusing..
	sort personid
	save "`datafolder'\lfs2002w2.dta", replace

merge personid using "`datafolder'\lfs2002p2.dta"
rename _merge mergewp
sort hhid

* don't merge in migrant file because it does not uniquely match to individuals in person and worker files
*merge hhid using `datafolder'\lfs2002m2.dta
*rename _merge mergem
*sort hhid

merge hhid using "`datafolder'\lfs2002h2.dta"
rename _merge mergeh
format personid %16.0f
format hhid %14.0f
order hhid personid
compress
label data "South Africa Labour Force Survey 2002_2 merged"
quietly do "`mergefolder'\LFSrename2002_2.do"
quietly do "`mergefolder'\LFSrename2.do"
**generate vars consistent with other waves**
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
	gen whynotwork=1 if whynotwork2==1
	replace whynotwork=2 if whynotwork2==8
	replace whynotwork=3 if whynotwork2==2
	replace whynotwork=4 if whynotwork2==3
	replace whynotwork=5 if whynotwork2==4
	replace whynotwork=6 if whynotwork2==5
	replace whynotwork=7 if whynotwork2==6
	replace whynotwork=8 if whynotwork2==7
	replace whynotwork=9 if whynotwork2==10
	replace whynotwork=10 if whynotwork2==11
	replace whynotwork=11 if whynotwork2==12
	replace whynotwork=12 if whynotwork2==13
	replace whynotwork=12 if whynotwork2==9
	replace whynotwork=88 if whynotwork2==88
	replace whynotwork=99 if whynotwork2==99
quietly do "`mergefolder'\lfslabelvars.do"
quietly do "`mergefolder'\lfslabeldefine.do"
quietly do "`mergefolder'\lfslabelvalues.do"
compress
sort personid
numlabel, add
save "`datafolder'\lfs2002_2.dta", replace
save "`mergefolder'\lfs2002_2.dta", replace

