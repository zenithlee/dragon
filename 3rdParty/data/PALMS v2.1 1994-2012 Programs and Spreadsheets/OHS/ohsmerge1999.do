
*ohsmerge1999
*prepares OHS 1999 data to be merged with other OHS data
*Andrew Kerr June 2011
*coding @@ as 8888 following David Lam's LFS convention
*coding ** as . 
*ignoring DataFirst suggestions on coding at http://www.datafirst.uct.ac.za/catalogue3/index.php/ddibrowser/64/download/555
*(these are wrong! and Lynn has/is fixed them)
*see "http://www.datafirst.uct.ac.za/catalogue3/index.php/ddibrowser/64/download/550" 

clear all
set mem 600m
set more off

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHS99"

use "`datafolder'\OHS 1999 House.dta", replace
set more off
renvars, lower
drop hhwgt
*because already numeric, add back in below
drop   d_race
*because already in person data
	foreach v of varlist * {
		quietly replace `v'="8888" if `v'=="@" 
		quietly replace `v'="8888" if `v'=="@@" 
		quietly replace `v'="8888" if `v'=="@@@" 
		quietly replace `v'="8888" if `v'=="@@@@" 
		quietly replace `v'="8888" if `v'=="@@@@@@" 
		quietly replace `v'="." if `v'=="*" 
		quietly replace `v'="." if `v'=="**"
		quietly replace `v'="." if `v'=="***"
		quietly replace `v'="." if `v'=="****"
		quietly replace `v'="." if `v'=="******"
		quietly replace `v'="." if `v'=="*******"
		}
	destring, replace
	sort uqnr
save "`datafolder'\temph.dta", replace
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHS99"
use "`datafolder'\OHS 1999 House.dta", replace
renvars, lower

destring uqnr, replace
keep uqnr hhwgt

sort uqnr

merge 1:1 uqnr using  "`datafolder'\temph.dta"
drop _merge
gen double hhid= uqnr
sort uqnr
save "`datafolder'\ohs1999htemp.dta", replace


use "`datafolder'\ohs1999.cewgt.dta", replace
renvars, lower

merge 1:1 uqnr using "`datafolder'\ohs1999htemp.dta"
tab _merge
rename _merge mergeh1
sort hhid
save "`datafolder'\ohs1999h.dta", replace


*use "`datafolder'\OHS 1999 Stratpsu.dta"
use "`datafolder'\OHS 1999 Person.dta", replace
renvars, lower

drop  wgt4 weight

	foreach v of varlist * {
		quietly replace `v'="8888" if `v'=="@" 
		quietly replace `v'="8888" if `v'=="@@" 
		quietly replace `v'="8888" if `v'=="@@@" 
		quietly replace `v'="." if `v'=="*" 
		quietly replace `v'="." if `v'=="**"
		quietly replace `v'="." if `v'=="***"
		quietly replace `v'="." if `v'=="****"
	*see "http://www.datafirst.uct.ac.za/catalogue3/index.php/ddibrowser/64/download/550" for explanation of what @ and * mean
	}
	
destring, replace
gen double hhid=uqnr
gen double personid=hhid*100+ personnr
sort personid
save "`datafolder'\tempp.dta", replace

use "`datafolder'\OHS 1999 Person.dta", replace
renvars, lower
destring uqnr personnr, replace
gen double hhid=uqnr
gen double personid=hhid*100+ personnr
keep personid  wgt4 weight
sort personid
merge personid using  "`datafolder'\tempp.dta"
* merge 1:1 personid using  "`datafolder'\tempp.dta" is the new way of merging I think..
drop _merge
order  personid uqnr personnr
sort personid
save "`datafolder'\ohs1999p.dta", replace

use "`datafolder'\OHS 1999 Worker_DataFirst.dta", replace
renvars, lower
drop  wgt4 q3_4busu2 
*because already numeric, add back in below
drop  c1_age b_gender d_race
*because already in person data
*do I need to check this?

	foreach v of varlist * {
		quietly replace `v'="8888" if `v'=="@" 
		quietly replace `v'="8888" if `v'=="@@" 
		quietly replace `v'="8888" if `v'=="@@@" 
		quietly replace `v'="8888" if `v'=="@@@@" 
		quietly replace `v'="888888" if `v'=="@@@@@@" 
		quietly replace `v'="." if `v'=="*" 
		quietly replace `v'="." if `v'=="**"
		quietly replace `v'="." if `v'=="***"
		quietly replace `v'="." if `v'=="****"
		quietly replace `v'="." if `v'=="******"
		}
	destring, replace
	gen double hhid=uqnr
	gen double personid=hhid*100+ personnr
	sort personid
	save "`datafolder'\tempw.dta", replace
	
use "`datafolder'\OHS 1999 Worker_DataFirst.dta", replace
set more off
renvars, lower
destring uqnr personnr, replace
gen double hhid=uqnr
gen double personid=hhid*100+ personnr
keep personid  q3_4busu2 
sort personid
merge 1:1 personid using  "`datafolder'\tempw.dta"
drop _merge
order  personid uqnr personnr
sort personid
save "`datafolder'\ohs1999w.dta", replace


merge 1:1 personid using  "`datafolder'\ohs1999p.dta"
rename _merge mergepw
sort hhid
save "`datafolder'\ohs1999pw.dta", replace

merge m:1 hhid using  "`datafolder'\ohs1999h.dta"
rename _merge mergeh
order hhid personid
compress

*local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHS99"
save "`datafolder'\ohs1999temp.dta", replace

duplicates tag personid, gen(tag)
drop tag
*so no individual duplicates, or hh by inference.



quietly do "`mergefolder'\OHSrename1999.do"
quietly do "`mergefolder'\OHSrename2.do"

/*create searchwork var, not straightforward like in LFSs! I should check comparability!
*incomplete, must come back to!!
gen searchwork=.
replace searchwork=1 if (q3_32awh>2 & q3_32awh<=9) | (q3_32bwh>2 & q3_32bwh<=9) | (q3_32cwh>2 & q3_32cwh<=9)
replace searchwork=2 if (q3_32awh==1  & (q3_32bwh<3 &) | (q3_32awh==2  & q3_32bwh==1)
replace searchwork=8888 if q3_32awh==8888
*/




quietly do "`mergefolder'\ohslabelvars.do"
quietly do "`mergefolder'\ohslabeldefine.do"
quietly do "`mergefolder'\ohslabelvalues.do"

compress
sort personid
numlabel, add


replace enrollment3=3 if enrollment3==8888
*since enrollment question differed between OHS 99 and other OHSs a small adjustment needed here (didn't want to create a whole new variable..)

save "`mergefolder'\ohs1999.dta", replace

clear 
insheet using "`mergefolder'\OHS Master codebook.csv"
keep var1999 newcode2
keep if var1999!=""
keep newcode2

use "`mergefolder'\ohs1999.dta", replace

*this keep must be updated using the list of vars left in stata data from OHS Master codebook, since I haven't yet automated the updating of new variables..
keep 	uqnr	personid  personnr ceweight hweight pweight province ea	urbrur	gender	age	popgroup2	whynotwork3	willacceptwork	empstat1	empstat2 employer1 selfformalreg selfvatreg selfpaidemp selfunpaidemp wageformalreg		empsalary1	empsalperiod1	empsalcat1	selfempincome	selfempincperiod1	selfempinccat1	educhigh3 enrollment3	jobocccode1	occupation1 occupation2 industry1 industry2 jobindcode1	hrslstwk incpension incdisabgrnt  inctstmaint incdepgrnt incfostcrgrnt dwelltype1	toimaintype1	watersource3	fuelcook1	fuelheat1	fuellight1	marstat3	jobunion	searchhow2

save "`mergefolder'\ohs1999small.dta", replace

exit

/*
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHS99"
use "`datafolder'\ohs1999temp.dta", replace








