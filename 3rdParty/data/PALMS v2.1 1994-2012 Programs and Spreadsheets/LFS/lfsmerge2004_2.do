* lfsmerge2004_2.do
* Merge all modules of South Africa Labour Force Survey for each wave
* assign new standardized variable names and value labels
* D. Lam 12 Feb 2007
* last updated june 2008 by k.goostrey
* Modified by Andrew Kerr, May 2011

clear
set mem 600m

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFS2004\LFS2004_2"

use "`datafolder'\LFS 2004_2 House.dta"
	gen str10 dataset="2004h2"
	gen wave=10
********************************************************
* pull out constant 0 in 4th column of hhid to reduce size and allow creation of personid *
	*gen str20 tempid=string(UqNr, "%16.0f" )
	gen str20 tempid=string(uqnr, "%16.0f" )
	gen tempid1to3=substr(tempid,1,3)
	gen tempid5to14=substr(tempid,5,14)
	gen tempid2=tempid1to3+tempid5to14
	destring tempid2, gen(hhid)
	
*******************************************************
*PSU variable also has an extra 0 so going to remove the extra zero to make comparable to earlier waves (possibly)



	*creating a string version of uqnr/hhid that helps to make merging in other data easier for PALMS end users:
	gen str20 uqnr_orig=string(uqnr, "%16.0f" )
	sort hhid
	save "`datafolder'\lfs2004h2temp.dta", replace
	
	use "`datafolder'\lfs2004_2.cewgt.dta", replace


	merge 1:1 uqnr using "`datafolder'\lfs2004h2temp.dta"
	tab _merge
	rename _merge mergeh1
	sort hhid
save "`datafolder'\lfs2004h2.dta", replace

	
use "`datafolder'\LFS 2004_2 Migrant.dta"
	gen str10 dataset="2004m2"
	gen wave=10
********************************************************
* pull out constant 0 in 4th column of hhid to reduce size and allow creation of personid *
	*gen str20 tempid=string(UqNr, "%16.0f" )
	gen str20 tempid=string(uqnr, "%16.0f" )
	gen tempid1to3=substr(tempid,1,3)
	gen tempid5to14=substr(tempid,5,14)
	gen tempid2=tempid1to3+tempid5to14
	destring tempid2, gen(hhid)
*******************************************************
	sort hhid
	save "`datafolder'\lfs2004m2.dta", replace
use "`datafolder'\LFS 2004_2 Person.dta"
	gen str10 dataset="2004p2"
	gen wave=10
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
	save "`datafolder'\lfs2004p2.dta", replace
duplicates report
duplicates report personid

use "`datafolder'\LFS 2004_2 Worker.dta"
	gen str10 dataset="2004w2"
	gen wave=10
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
	save "`datafolder'\lfs2004w2.dta", replace
duplicates report
duplicates report personid

merge personid using "`datafolder'\lfs2004p2.dta"
rename _merge mergewp
sort hhid
duplicates report personid

* don't merge in migrant file because it does not uniquely match to individuals in person and worker files
*merge hhid using `datafolder'\lfs2004m2.dta
*rename _merge mergem
*sort hhid

merge hhid using "`datafolder'\lfs2004h2.dta"
rename _merge mergeh
format personid %16.0f
format hhid %14.0f
order hhid personid
compress
label data "South Africa Labour Force Survey 2004_2 merged"
quietly do "`mergefolder'\LFSrename2004_2.do"
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
	*gen migeduchigh=0 if migeduchigh2==0
	*forval i=2/16 {
	*replace migeduchigh=`i' if migeduchigh2==`i'
	*}
	*replace migeduchigh=17 if migeduchigh2>=17 & migeduchigh2<=18
	*replace migeduchigh=18 if migeduchigh2>=19 & migeduchigh2<=20
	*replace migeduchigh=19 if migeduchigh2>=21 & migeduchigh2<=23
	*replace migeduchigh=20 if migeduchigh2==24
	*replace migeduchigh=21 if migeduchigh2==25
	*replace migeduchigh=22 if migeduchigh2==26
	*replace migeduchigh=99 if migeduchigh2==99
quietly do "`mergefolder'\lfslabelvars.do"
quietly do "`mergefolder'\lfslabeldefine.do"
quietly do "`mergefolder'\lfslabelvalues.do"
drop tempid*
compress
sort personid
numlabel, add
save "`datafolder'\lfs2004_2.dta", replace
save "`mergefolder'\lfs2004_2.dta", replace

