* lfsmerge2005_1.do
* Merge all modules of South Africa Labour Force Survey for each wave
* assign new standardized variable names and value labels
* D. Lam 12 Feb 2007
* last updated june 2008 by k.goostrey
* Modified by Andrew Kerr, May 2011

clear
set mem 600m

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFS2005\LFS2005_1"

use "`datafolder'\LFS 2005_1 House.dta"
	gen str10 dataset="2005h1"
	gen wave=11
********************************************************
* pull out constant 0 in 4th column of hhid to reduce size and allow creation of personid *
	gen str20 tempid=string(uqnr, "%16.0f" )
	gen tempid1to3=substr(tempid,1,3)
	gen tempid5to14=substr(tempid,5,14)
	gen tempid2=tempid1to3+tempid5to14
	destring tempid2, gen(hhid)
*******************************************************
*but also keep orig id as a string so PALMS users can merge in their own data more easily
gen uqnr_orig=tempid

	sort hhid
	save "`datafolder'\lfs2005h1temp.dta", replace
	
	use "`datafolder'\lfs2005_1.cewgt.dta", replace


	merge 1:1 uqnr using "`datafolder'\lfs2005h1temp.dta"
	tab _merge
	rename _merge mergeh1
	sort hhid
save "`datafolder'\lfs2005h1.dta", replace

	
use "`datafolder'\LFS 2005_1 Person.dta"
	gen str10 dataset="2005p1"
	gen wave=11
********************************************************
* pull out constant 0 in 4th column of hhid to reduce size and allow creation of personid *
	*gen str20 tempid=string(UqNr, "%16.0f" )
	gen str20 tempid=string(uqnr, "%16.0f" )
	gen tempid1to3=substr(tempid,1,3)
	gen tempid5to14=substr(tempid,5,14)
	gen tempid2=tempid1to3+tempid5to14
	destring tempid2, gen(hhid)
*******************************************************
	*gen double personid=hhid*100+PersonNR
	gen double personid=hhid*100+personnr
	sort personid
duplicates report
duplicates report personid
	save "`datafolder'\lfs2005p1.dta", replace
use "`datafolder'\LFS 2005_1 Worker.dta"
	gen str10 dataset="2005w1"
	gen wave=11
********************************************************
* pull out constant 0 in 4th column of hhid to reduce size and allow creation of personid *
	*gen str20 tempid=string(UqNr, "%16.0f" )
	gen str20 tempid=string(uqnr, "%16.0f" )
	gen tempid1to3=substr(tempid,1,3)
	gen tempid5to14=substr(tempid,5,14)
	gen tempid2=tempid1to3+tempid5to14
	destring tempid2, gen(hhid)
*******************************************************
	*gen double personid=hhid*100+PersonNr
	gen double personid=hhid*100+personnr
	sort personid
duplicates report
duplicates report personid
	save "`datafolder'\lfs2005w1.dta", replace

merge personid using "`datafolder'\lfs2005p1.dta"
rename _merge mergewp
sort hhid
merge hhid using "`datafolder'\lfs2005h1.dta"
rename _merge mergeh
format personid %16.0f
format hhid %14.0f
order hhid personid
duplicates report personid
compress
label data "South Africa Labour Force Survey 2005_1 merged"
quietly do "`mergefolder'\LFSrename2005_1.do"
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
	gen marstat=1 if marstat3>=1 & marstat3<=2
	replace marstat=2 if marstat3==3
	replace marstat=3 if marstat3==4
	replace marstat=4 if marstat3==5
	replace marstat=9 if marstat3==9
	gen educhigh=0 if educhigh2==0
	forval i=1/16 {
	replace educhigh=`i' if educhigh2==`i'
	}
	replace educhigh=17 if educhigh2>=17 & educhigh2<=18
	replace educhigh=18 if educhigh2>=19 & educhigh2<=20
	replace educhigh=19 if educhigh2>=21 & educhigh2<=23
	replace educhigh=20 if educhigh2==24
	replace educhigh=21 if educhigh2==25
	replace educhigh=22 if educhigh2==26
	replace educhigh=99 if educhigh2==99
	gen enrolled=1 if enrolled2>=1 & enrolled2<=2
	replace enrolled=2 if enrolled2==3
	replace enrolled=3 if enrolled2==4
	replace enrolled=4 if enrolled2==5
	replace enrolled=5 if enrolled2==6
	replace enrolled=6 if enrolled2==7
	replace enrolled=7 if enrolled2==8
	replace enrolled=8 if enrolled2==9
quietly do "`mergefolder'\lfslabelvars.do"
quietly do "`mergefolder'\lfslabeldefine.do"
quietly do "`mergefolder'\lfslabelvalues.do"
drop tempid*
compress
sort personid
numlabel, add
save "`datafolder'\lfs2005_1.dta", replace
save "`mergefolder'\lfs2005_1.dta", replace

