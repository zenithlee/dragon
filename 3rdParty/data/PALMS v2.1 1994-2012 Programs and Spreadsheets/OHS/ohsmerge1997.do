*ohsmerge1997
*prepares OHS 1997 data to be merged with other OHS data
*Andrew Kerr July 2011
clear all
set mem 600m
set more off

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHS97"

use "`datafolder'\OHS 1997 House.dta", replace
renvars, lower


tostring(eanumber), gen (ea)
replace ea="000"+ea if length(ea)==1
replace ea="00"+ea if length(ea)==2
replace ea="0"+ea if length(ea)==3
tostring(mdnumber), gen (districtstr)
gen str eaunique=districtstr+ea
destring eaunique, replace
drop ea districtstr
sort hhid
save "`datafolder'\ohs1997htemp.dta", replace
duplicates tag hhid, gen(htag)
tab htag
drop htag
*no duplicates

use "`datafolder'\ohs1997.cewgt.dta", replace
renvars, lower

merge 1:1 hhid using "`datafolder'\ohs1997htemp.dta"
tab _merge
rename _merge mergeh1
sort hhid
save "`datafolder'\ohs1997h.dta", replace

use "`datafolder'\OHS 1997 Person.dta", replace
renvars, lower
gen double personid=hhid*100+ ppersno
duplicates tag personid, gen(tag)
tab tag
drop tag
*no duplicates
sort personid
save "`datafolder'\ohs1997p.dta", replace


use "`datafolder'\OHS 1997 Worker.dta", replace
renvars, lower
drop mdnumber eanumber vpnumber  pgender page prace1
*already in person data
gen double personid=hhid*100+ ppersno
duplicates tag personid, gen(tag)
tab tag
*ok so 1 duplicate obs.
duplicates drop personid , force
drop tag
sort personid
save "`datafolder'\ohs1997w.dta", replace

merge 1:1 personid using  "`datafolder'\ohs1997p.dta"
rename _merge mergepw
sort hhid
save "`datafolder'\ohs1997pw.dta", replace

merge m:1 hhid using  "`datafolder'\ohs1997h.dta"
rename _merge mergeh
*merge looks good

order hhid personid

*below is the only place I have seen missing codes in the 97 data I USE, there may be some I have missed though!
replace wsalamt=. if wsalamt==999999
replace wservsa1=. if wservsa1==999999
replace wspgds=. if wspgds==999999
replace wspsal=. if wspsal==999999
replace wspoth=. if wspoth==999999

gen toimaintype1=.
replace toimaintype1=11 if hhtoildw==1
replace toimaintype1=21 if hhtonsit==1
replace toimaintype1=22 if hhtonsit==2
replace toimaintype1=23 if hhtonsit==3
replace toimaintype1=24 if hhtonsit==4
replace toimaintype1=25 if hhtonsit==5
replace toimaintype1=31 if hhtofsit==1
replace toimaintype1=32 if hhtofsit==2
replace toimaintype1=33 if hhtofsit==3
replace toimaintype1=34 if hhtofsit==4
replace toimaintype1=35 if hhtofsit==5
replace toimaintype1=36 if hhtofsit==6
replace toimaintype1=37 if hhtofsit==7

label var toimaintype1 "Main toilet type"

quietly do "`mergefolder'\OHSrename1997.do"

quietly do "`mergefolder'\OHSrename2.do"


quietly do "`mergefolder'\ohslabelvars.do"
quietly do "`mergefolder'\ohslabeldefine.do"
quietly do "`mergefolder'\ohslabelvalues.do"


*lining up OHS 97 with other OHSs:
gen jobocccode1= jobocccode2
replace jobocccode1=11 if jobocccode2==10

gen jobindcode1=.
replace jobindcode1=1 if jobindcode2==1
replace jobindcode1=2 if jobindcode2==0 & industry1>=200 &industry1<300
replace jobindcode1=3 if jobindcode2==2
replace jobindcode1=4 if jobindcode2==3
replace jobindcode1=5 if jobindcode2==4
replace jobindcode1=6 if jobindcode2==5
replace jobindcode1=7 if jobindcode2==6
replace jobindcode1=8 if jobindcode2==7
replace jobindcode1=9 if jobindcode2==8
replace jobindcode1=10 if jobindcode2==9

*ok so what was originally called indust only included the 1 digit codes for employees not self-employed, so need to add this in (unlike in 98)!
replace jobindcode1=1 if industry2>100 & industry2<200 & jobindcode1==.
replace jobindcode1=2 if industry2>200 & industry2<300 & jobindcode1==.
replace jobindcode1=3 if industry2>300 & industry2<400 & jobindcode1==.
replace jobindcode1=4 if industry2>400 & industry2<500 & jobindcode1==.
replace jobindcode1=5 if industry2>500 & industry2<600 & jobindcode1==.
replace jobindcode1=6 if industry2>600 & industry2<700 & jobindcode1==.
replace jobindcode1=7 if industry2>700 & industry2<800 & jobindcode1==.
replace jobindcode1=8 if industry2>800 & industry2<900 & jobindcode1==.
replace jobindcode1=9 if industry2>900 & industry2<1000 & industry2!=931 & jobindcode1==. 
replace jobindcode1=10 if industry2==931  & jobindcode1==.

label var jobindcode1 "Industry of employment, short code"




sort personid
numlabel, add
save "`mergefolder'\ohs1997.dta", replace


clear 
insheet using "`mergefolder'\OHS Master codebook.csv"
keep var1997 newcode2
keep if var1997!=""
keep newcode2

use "`mergefolder'\ohs1997.dta", replace

*this keep must be updated using the list of vars left in stata data from OHS Master codebook, since I haven't yet automated the updating of new variables..
*incl jobindcode1, jobocccode1
keep uqnr	personid  personnr ceweight hweight pweight province ea	urbrur	gender	age	popgroup3	whynotwork3	willacceptwork	empstat1	empstat2 employer1 selfformalreg selfvatreg selfpaidemp selfunpaidemp wageformalreg	empsalary1	empsalperiod2	empsalcat1	selfempincome	selfempincperiod1	selfempinccat2	selfempexpgoods	selfempexprenum	selfempexpoth	educprimsec	educter2 enrollment3 jobocccode1 jobocccode2 occupation1 occupation2 industry1 industry2 jobindcode1	jobindcode2 hrslstwk	incpension incdisabgrnt  inctstmaint incdepgrnt incfostcrgrnt dwelltype1	toindw	toionsite1	toiofsit1	watersource3	fuelcook2	fuelheat2	fuellight2	marstat4	jobunion	searchhow2

save "`mergefolder'\ohs1997small.dta", replace


