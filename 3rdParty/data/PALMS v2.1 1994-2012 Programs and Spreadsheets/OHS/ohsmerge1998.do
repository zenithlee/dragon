*ohsmerge1998
*prepares OHS 1998 data to be merged with other OHS data
*Andrew Kerr June 2011
clear all
set mem 600m
set more off

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHS98"

use "`datafolder'\OHS 1998 House.dta", replace
set more off
renvars, lower

gen double hhid= uqnr
tostring uqnr, gen(hhidstr)
gen eaunique=substr(hhidstr,1,7)
destring eaunique, replace
gen district=substr(hhidstr,1,3)
drop hhidstr

sort uqnr
save "`datafolder'\ohs1998htemp.dta", replace
duplicates tag hhid, gen(htag)
tab htag
*no duplicates in hh data
*drop htag

use "`datafolder'\ohs1998.cewgt.dta", replace
renvars, lower

merge 1:1 uqnr using "`datafolder'\ohs1998htemp.dta"
tab _merge
rename _merge mergeh1
sort hhid
save "`datafolder'\ohs1998h.dta", replace


use "`datafolder'\OHS 1998 Person.dta", replace
renvars, lower
gen double hhid=uqnr
gen double personid=hhid*100+ personnr

/*
duplicates tag personid, gen(tag)
*ok, so there are some duplicates here! but none in house data?? weird..
drop if personnr!=1
drop tag
duplicates tag hhid, gen(tag)
tab tag
*ok so duplicate houses in the person data? 22 of them.. 
drop tag
*/

duplicates drop personid, force
*50 indivs from 22 duplicate hh dropped. Need to come back to sometime..


sort personid
save "`datafolder'\ohs1998p.dta", replace



use "`datafolder'\OHS 1998 Worker.dta", replace
renvars, lower

drop  c_age b_gender d_race
*because already in person data.
gen double hhid=uqnr
gen double personid=hhid*100+ personnr
sort personid
duplicates tag personid, gen(tag)
tab tag
*ok, no duplicates in worker data!
*drop tag


save "`datafolder'\ohs1998w.dta", replace

merge 1:1 personid using  "`datafolder'\ohs1998p.dta"
rename _merge mergepw
sort hhid
save "`datafolder'\ohs1998pw.dta", replace


merge m:1 hhid using  "`datafolder'\ohs1998h.dta"
rename _merge mergeh
drop if mergeh==1
*come back to when duplicates issues have been sorted out
order hhid personid
*compress


quietly do "`mergefolder'\OHSrename1998.do"
quietly do "`mergefolder'\OHSrename2.do"


quietly do "`mergefolder'\ohslabelvars.do"
quietly do "`mergefolder'\ohslabeldefine.do"
quietly do "`mergefolder'\ohslabelvalues.do"

sort personid
numlabel, add


*1998 metadata says actual weights are the weights in the data divided by 10000!
replace pweight=pweight/10000
replace hweight=hweight/10000

save "`mergefolder'\ohs1998.dta", replace

clear 
insheet using "`mergefolder'\OHS Master codebook.csv"
keep var1998 newcode2
keep if var1998!=""
keep newcode2

use "`mergefolder'\ohs1998.dta", replace

*this keep must be updated using the list of vars left in stata data from OHS Master codebook, since I haven't yet automated the updating of new variables..
keep 	uqnr	personid  personnr ceweight hweight pweight province ea	urbrur	gender	age	popgroup3	whynotwork3	willacceptwork	empstat1	empstat2 employer1 selfformalreg selfvatreg selfpaidemp selfunpaidemp wageformalreg		empsalary1	empsalperiod2	empsalcat1	selfempincome	selfempincperiod1	selfempinccat2	selfempexpgoods	selfempexprenum	selfempexpoth	educprimsec	educter1 enrollment3	jobocccode1 occupation1 occupation2 industry1 industry2	jobindcode1	hrslstwk incpension incdisabgrnt  inctstmaint incdepgrnt incfostcrgrnt dwelltype1	toimaintype1	watersource3	fuelcook2	fuelheat2	fuellight2	marstat3	jobunion	searchhow2


save "`mergefolder'\ohs1998small.dta", replace

exit

