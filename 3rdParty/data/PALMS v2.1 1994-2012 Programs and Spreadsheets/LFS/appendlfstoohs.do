*this do file appends LFS data to OHS data
*created by Andrew Kerr, July 2011.

clear all
set mem 1150m
set more off

local ohsmergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHSmerge"
local lfsmergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge"
local ohslfsmergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSlfs"


use "`ohsmergefolder'\ohssmall.dta", replace
rename empsalary1 wageempincome
rename empsalary2 wageempincome2
*rename empsalary3 wageempincome3
label var wageempincome "Wage employment earnings in OHSs"
*label var wageempincome2 "Wage employment gross earnings in OHS 94"
*label var wageempincome3 "Wage employment NET earnings in OHS 94"
label var selfempincome1 "Self employment earnings in OHSs"
save "`ohsmergefolder'\ohssmalltemp.dta", replace

use "`lfsmergefolder'\ohsconsistentlfs.dta", clear
/*rename jobsalary jobearn
label var jobearn "Earnings in main job"
*/
label var jobsalary "Earnings in wage or self-employment, LFSs"
append using "`ohsmergefolder'\ohssmalltemp.dta"

*some extra cleaning, as a result of being outside metadata valid range in waves 4 and 21
replace wageempincome=. if wageempincome==10000000 &wave==4
replace jobsalary=. if jobsalary==3501380 & wave==21

label define wave 1"OHS 1994" 2"OHS 1995" 3"OHS 1996" 4"OHS 1997" 5"OHS 1998" 6"OHS 1999" 7"LFS 00:1" 8"LFS 00:2" 9"LFS 01:1" 10"LFS 01:2" 11"LFS 02:1" ///
	12"LFS 02:2" 13"LFS 03:1" 14"LFS 03:2" 15"LFS 04:1" 16"LFS 04:2" 17"LFS 05:1" 18"LFS 05:2" 19"LFS 06:1" 20"LFS 06:2" ///
	21"LFS 07:1" 22"LFS 07:2"
label values wave wave

/*now must create versions of these at hh level for OHS 97-99 and LFS sept 00! LEAVING THIS FOR NOW!!
gen incpensionD=1 if incpension
sort uqnr wave
by uqnr wave: egen hhpension1 =total(incpension) incpension incdisabgrnt inctstmaint incdepgrnt incfostcrgrnt 
hhpension
hhdisablegrant
hhchildsuppgrant
hhcaredependgrant
hhfostercaregrant
*/



order uqnr /*uqnr_orig personid*/ personnr year wave  province urbrur ea dc ceweight pweight hweight popgroup gender age marstat educhigh educhigh0 enrolled enrollment3 empstat1 empstat2 employer employer1 numworkers jobstartmonth jobstartyear jobcontract ///
selfformalreg selfvatreg selfpaidemp selfunpaidemp wageformalreg formalreg ///
jobindcode industry jobocccode occupation occupation1 jobunion publicemp businesstype1 businesstype2  hrslstwk  earnperiod_wage earnperiod_self earnperiod jobsalary jobsalcat earncatmin earncatmax wageempincome  wageempincome2 ///
  empsalcat1 empsalcat2 empsalcat3 selfempincome1 selfempincome2 imputed salary_impute  impute_gross emp_impute deduc1 deducamt1 selfempinccat1 selfempinccat2 selfempinccat3 selfempinccat4 ///
  selfempexpgoods selfempexprenum selfempexpoth selfempexpall selfearncatmin selfearncatmax wageearncatmin wageearncatmax ///
dwelltype watersource toiletmaintype hhpension hhdisablegrant hhchildsuppgrant hhcaredependgrant hhfostercaregrant incpension incdisabgrnt inctstmaint incdepgrnt incfostcrgrnt

*march 2013- dropping the min and max cat variables earnings cat variables
drop earncatmin earncatmax selfearncatmin selfearncatmax wageearncatmin wageearncatmax


*final cleaning of the data:

replace jobsalary=. if jobsalary==888888 | jobsalary==999999
replace wageempincome=. if wageempincome==888888 | wageempincome==999999
replace selfempincome1=. if selfempincome1==888888 | selfempincome1==999999
compress
notes drop _dta

datasignature set

label data "OHS/LFS data: OHS 1994-1999 and LFS February 2000-September 2007"
notes: OHS/LFS data version 1.0.14, created by Andrew Kerr July 2013
save "`ohslfsmergefolder'\ohslfsdatav1.0.14.dta", replace

*drop  empsalcat1 selfempinccat1 selfempinccat2 empsalcat2 selfempinccat3 empsalcat3 selfempinccat4 ea

