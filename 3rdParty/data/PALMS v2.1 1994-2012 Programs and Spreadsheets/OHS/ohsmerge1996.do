*ohsmerge1996
*prepares OHS 1996 data to be appended to other OHS data
*Andrew Kerr July 2011


clear all
set mem 600m
set more off

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHS96"

use "`datafolder'\OHS 1996 House"
gen vpnumber2=substr(vpnumber,2,2)
gen hhidstr=mdnumber+eanumber+vpnumber2
gen hhidstralt=mdnumber+eanumber+vpnumber	
duplicates tag hhidstr, gen(tag)
tab tag
gen eaunique=mdnumber+eanumber
destring eaunique, replace
destring hhidstr, gen(hhid)
sort hhid
gen hh=1
save "`datafolder'\ohs1996htemp", replace

use "`datafolder'\ohs1996.cewgt.dta", replace
renvars, lower

merge 1:1 hhid using "`datafolder'\ohs1996htemp.dta"
tab _merge
rename _merge mergeh1
sort hhid
save "`datafolder'\ohs1996h.dta", replace


use "`datafolder'\OHS  1996  Person", replace
gen double hhid=distr*1000000+ea*100+visp
gen double personid=hhid*100+respno
duplicates tag personid, gen(tag1)
tab tag1
*great, no duplicates
sort personid
save "`datafolder'\ohs1996p", replace


use "`datafolder'\OHS  1996  Worker", replace
gen double hhid=distr*1000000+ea*100+visp
gen double personid=hhid*100+respno
duplicates tag personid, gen(tag1)
tab tag1
*great, no duplicates
sort personid
save "`datafolder'\ohs1996w", replace

merge 1:1 personid using  "`datafolder'\ohs1996p.dta"
rename _merge mergepw

sort hhid
save "`datafolder'\ohs1996pw.dta", replace

merge m:1 hhid using  "`datafolder'\ohs1996h.dta"
rename _merge mergeh
drop if mergeh!=3

* only used in creating id numbers, not unique to each ea so drop
drop ea

destring personag popgroup prov eegender findwork rnotwork ejobsoff eeincome ebussinc eeegoods eeewages eeothers attschoo higheted eworkwho actemplo eeindust ejobdesc descwork ///
	edidwork workcate  eworkreg vatnumbe eperpaid eeunpaid ///
	findwork ejobsoff soonstar eabswork enotwork category typedwel eeindwel eeonsite eoffsite mainwate maritals ecooking eheating lighting maritals memunion tothours, replace
*a pesky string variable that must be changed manually..
rename type type1
gen type=.
replace type=1 if type1=="urban"
replace type=2 if type1=="non-urban"



drop province
*related to health facility not location of hh!

gen indust=.
replace indust=1 if actemplo>100 & actemplo<200
replace indust=2 if actemplo>=200 & actemplo<300
replace indust=3 if actemplo>=300 & actemplo<400
replace indust=4 if actemplo>=400 & actemplo<500
replace indust=5 if actemplo>=500 & actemplo<600
replace indust=6 if actemplo>=600 & actemplo<700
replace indust=7 if actemplo>=700 & actemplo<800
replace indust=8 if actemplo>=800 & actemplo<900
replace indust=9 if actemplo>=900 & actemplo<1000 
replace indust=10 if actemplo==010
replace indust=11 if actemplo==020 | actemplo==030

*now include self employed
replace indust=1 if eeindust>100 & eeindust<200
replace indust=2 if eeindust>=200 & eeindust<300
replace indust=3 if eeindust>=300 & eeindust<400
replace indust=4 if eeindust>=400 & eeindust<500
replace indust=5 if eeindust>=500 & eeindust<600
replace indust=6 if eeindust>=600 & eeindust<700
replace indust=7 if eeindust>=700 & eeindust<800
replace indust=8 if eeindust>=800 & eeindust<900
replace indust=9 if eeindust>=900 & eeindust<1000 
replace indust=10 if eeindust==010
replace indust=11 if eeindust==020 | eeindust==030


gen occup=.
replace occup=1 if ejobdesc>1000 & ejobdesc<2000
replace occup=2 if ejobdesc>=2000 & ejobdesc<3000
replace occup=3 if ejobdesc>=3000 & ejobdesc<4000
replace occup=4 if ejobdesc>=4000 & ejobdesc<5000
replace occup=5 if ejobdesc>=5000 & ejobdesc<6000
replace occup=6 if ejobdesc>=6000 & ejobdesc<7000
replace occup=7 if ejobdesc>=7000 & ejobdesc<8000
replace occup=8 if ejobdesc>=8000 & ejobdesc<9000
replace occup=9 if ejobdesc>=9000 & ejobdesc<10000 &ejobdesc!=9131 &ejobdesc!=9132
replace occup=11 if ejobdesc==9131 | ejobdesc==9132

*now include self employed
replace occup=1 if ejobdesc>1000 & descwork<2000
replace occup=2 if descwork>=2000 & descwork<3000
replace occup=3 if descwork>=3000 & descwork<4000
replace occup=4 if descwork>=4000 & descwork<5000
replace occup=5 if descwork>=5000 & descwork<6000
replace occup=6 if descwork>=6000 & descwork<7000
replace occup=7 if descwork>=7000 & descwork<8000
replace occup=8 if descwork>=8000 & descwork<9000
replace occup=9 if descwork>=9000 & descwork<10000 &descwork!=9131 &descwork!=9132
replace occup=11 if descwork==913

*including status1 and 2 variables as the 96 metadata says they should be (but variable was somehow not included in the DF data)
gen status1=0 if age>14
replace status1=1 if edidwork==1 | edidwork==2 | workcate==1 
replace status1=1 if eabswork==1 & (enotwork>0 &enotwork<8 &enotwork!=4)
replace status1=1 if workcate==2 & (enotwork>0 &enotwork<8 &enotwork!=4)
replace status1=2 if eabswork==1 & (enotwork==4 | enotwork>7)
replace status1=2 if workcate==2 & (enotwork==4 | enotwork>7)
replace status1=2 if category==4
replace status1=0 if status1==2 & (ejobsoff==2 |soonstar>3)
replace status1=0 if status1==2 & findwork==1

gen status2=0 if age>14
replace status2=1 if edidwork==1 | edidwork==2 | workcate==1 
replace status2=1 if eabswork==1 & (enotwork>0 &enotwork<8 &enotwork!=4)
replace status2=1 if workcate==2 & (enotwork>0 &enotwork<8 &enotwork!=4)
replace status2=2 if eabswork==1 & (enotwork==4 | enotwork>7)
replace status2=2 if workcate==2 & (enotwork==4 | enotwork>7)
replace status2=2 if category==4
replace status2=0 if status2==2 & ejobsoff==2

replace eeegoods=. if eeegoods==99999
replace eeewages=. if eeewages==99999 
replace eeothers=. if eeothers==99999

quietly do "`mergefolder'\OHSrename1996.do"
quietly do "`mergefolder'\OHSrename2.do"


quietly do "`mergefolder'\ohslabelvars.do"
quietly do "`mergefolder'\ohslabeldefine.do"
quietly do "`mergefolder'\ohslabelvalues.do"

order uqnr personid
sort personid
numlabel, add

save "`mergefolder'\ohs1996.dta", replace

*yearmove movedmdn epservic




clear 
insheet using "`mergefolder'\OHS Master codebook.csv"
keep var1996 newcode2
keep if var1996!=""
keep newcode2

use "`mergefolder'\ohs1996.dta", replace
*this keep must be updated using the list of vars left in stata data from OHS Master codebook, since I haven't yet automated the updating of new variables..
*ea
keep uqnr	personid  personnr province urbrur ea ceweight pweight hweight gender age	popgroup2 whynotwork4	willacceptwork	empstat1	empstat2 employer1 selfformalreg selfvatreg selfpaidemp selfunpaidemp	empsalcat1	selfempinccat2	selfempexpgoods	selfempexprenum	selfempexpoth	educhigh4 enrollment3	jobocccode1 occupation1 occupation2 industry1 industry2	jobindcode1	hrslstwk dwelltype2	toindw	toionsite2	toiofsit2	watersource3	fuelcook3	fuelheat3	fuellight3	marstat4	jobunion	searchhow3

save "`mergefolder'\ohs1996small.dta", replace
