*ohsmerge1995
*prepares OHS 1995 data to be merged with other OHS data
*Andrew Kerr July 2011

clear
set mem 600m
set more off

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHS95"

use "`datafolder'\OHS 1995 House_1996 Weights"
renvars, lower
duplicates tag hhid, gen(tag)
tab tag
*no duplicates
drop tag
destring *, replace
tostring(enano), gen (ea2digit)
replace ea2digit="0"+ea2digit if length(ea2digit)==1
tostring( district), gen (districtstr)
gen str eaunique=districtstr+ea2digit
destring eaunique, replace
drop ea2digit districtstr
sort hhid
save "`datafolder'\ohs1995htemp", replace

use "`datafolder'\ohs1995.cewgt.dta", replace
renvars, lower

merge 1:1 hhid using "`datafolder'\ohs1995htemp.dta"
tab _merge
rename _merge mergeh1
sort hhid
save "`datafolder'\ohs1995h.dta", replace

use "`datafolder'\OHS 1995 Person_1996 Weights"
renvars, lower
destring persno, replace
gen double personid=hhid*100+persno
duplicates tag personid, gen(tag)
tab tag
*no duplicates
drop tag
rename newwgt pweight

destring *, replace
*destringing all variables, should be ok!!

sort personid
save "`datafolder'\ohs1995p", replace

use "`datafolder'\OHS 1995 Worker_1996 Weights", replace
renvars, lower
destring persno, replace
gen double personid=hhid*100+persno
duplicates tag personid, gen(tag)
tab tag
*no duplicates
drop tag

sort personid
save "`datafolder'\ohs1995w", replace



merge 1:1 personid using  "`datafolder'\ohs1995p.dta"
rename _merge mergepw
sort hhid
save "`datafolder'\ohs1995pw.dta", replace

merge m:1 hhid using  "`datafolder'\ohs1995h.dta"
rename _merge mergeh



order hhid personid
sort personid
numlabel, add


*create variables ..
rename type type1
gen type=.
replace type=1 if type1>=11 & type1<=14
replace type=2 if type1>=21 & type1<=38
*assuming semi-urban areas are non-urban areas

gen status1=0 if age>14
replace status1=1 if workers==1 |workers==2
replace status1=2 if strictun==1


gen status2=0 if age>14
replace status2=1 if workers==1 |workers==2
replace status2=2 if expandun==1

gen occup=.
replace occup=1 if q315>=11 & q315<200
replace occup=2 if q315>=200 & q315<300
replace occup=3 if q315>=300 & q315<400
replace occup=4 if q315>=400 & q315<500
replace occup=5 if q315>=500 & q315<600
replace occup=6 if q315>=600 & q315<700
replace occup=7 if q315>=700 & q315<800
replace occup=8 if q315>=800 & q315<900
replace occup=9 if q315>=900 & q315<1000 &q315!=913 & q315!=913
replace occup=11 if q315==913 | q315==910

replace occup=1 if q319occ>=11 & q319occ<200
replace occup=2 if q319occ>=200 & q319occ<300
replace occup=3 if q319occ>=300 & q319occ<400
replace occup=4 if q319occ>=400 & q319occ<500
replace occup=5 if q319occ>=500 & q319occ<600
replace occup=6 if q319occ>=600 & q319occ<700
replace occup=7 if q319occ>=700 & q319occ<800
replace occup=8 if q319occ>=800 & q319occ<900
replace occup=9 if q319occ>=900 & q319occ<1000 &q319occ!=910 &q319occ!=913
replace occup=11 if q319occ==910 | q319occ==913

gen indust=.
replace indust=1 if q311>0 &q311<=3
replace indust=2 if q311>3 &q311<=9
replace indust=3 if q311>9 &q311<=19
replace indust=4 if q311>=20 &q311<=21
replace indust=5 if q311==22
replace indust=6 if q311>=23 & q311<=26
replace indust=7 if q311>=27 &q311<=31
replace indust=8 if q311>=32 &q311<=39
replace indust=9 if q311>=40 &q311<=47
replace indust=10 if q311==48
replace indust=12 if q311==49 | q311==50

replace indust=1 if q319ind>0 &q319ind<=3
replace indust=2 if q319ind>3 &q319ind<=9
replace indust=3 if q319ind>9 &q319ind<=19
replace indust=4 if q319ind>=20 &q319ind<=21
replace indust=5 if q319ind==22
replace indust=6 if q319ind>=23 & q319ind<=26
replace indust=7 if q319ind>=27 &q319ind<=31
replace indust=8 if q319ind>=32 &q319ind<=39
replace indust=9 if q319ind>=40 &q319ind<=47
replace indust=10 if q319ind==48
replace indust=12 if q319ind==49 | q319ind==50



gen fuelcook3=.
replace fuelcook3=1 if  cook_epu==1 | cook_egn==1 | cook_eso==1
replace fuelcook3=2 if   cook_gas==1
replace fuelcook3=3 if   cook_par==1
replace fuelcook3=4 if    cook_woo ==1
replace fuelcook3=5 if   cook_coa==1
replace fuelcook3=7 if    cook_dng==1
replace fuelcook3=8 if    cook_oth ==1 |cook_cha==1 | cook_wst==1


gen fuelheat3=.
replace fuelheat3=1 if   heat_epu==1 | heat_egn==1 | heat_eso==1 |  heat_ebt==1
replace fuelheat3=2 if   heat_gas==1
replace fuelheat3=3 if   heat_par==1
replace fuelheat3=4 if   heat_woo ==1
replace fuelheat3=5 if   heat_coa==1
replace fuelheat3=7 if   heat_dng==1
replace fuelheat3=8 if   heat_oth ==1 |heat_cha==1 | heat_wst==1

gen fuellight3=.
replace fuellight3=1 if  lite_epu==1 | lite_egn==1 | lite_eso==1 |  lite_ebt==1
replace fuellight3=2 if   lite_gas==1
replace fuellight3=3 if   lite_par==1
replace fuellight3=6 if    lite_cdl==1
replace fuellight3=8 if    lite_oth ==1

quietly do "`mergefolder'\OHSrename1995.do"
quietly do "`mergefolder'\OHSrename2.do"


quietly do "`mergefolder'\ohslabelvars.do"
quietly do "`mergefolder'\ohslabeldefine.do"
quietly do "`mergefolder'\ohslabelvalues.do"

replace empsalary1=. if empsalary1==9999999


order uqnr personid
sort personid
numlabel, add

save "`mergefolder'\ohs1995.dta", replace


clear 
insheet using "`mergefolder'\OHS Master codebook.csv"
keep var1995 newcode2
keep if var1995!=""
keep newcode2


use "`mergefolder'\ohs1995.dta", replace
*this keep must be updated using the list of vars left in stata data from OHS Master codebook, since I haven't yet automated the updating of new variables..
keep uqnr	personid  personnr ceweight hweight pweight	province ea urbrur gender	age	popgroup2	whynotwork4	willacceptwork	empstat1	empstat2 employer1 selfformalreg selfvatreg selfpaidemp selfunpaidemp	empsalary1	empsalperiod3	empsalcat2	selfempincome	selfempincperiod2	selfempinccat3	selfempexpall	educhigh5 enrollment3	jobocccode1 occupation3 occupation4	jobindcode1 hrslstwk	dwelltype2	toindw	toionsite3	toiofsit3	watersource4	fuelcook3	fuelheat3	fuellight3	marstat4	jobunion	searchhow3


save "`mergefolder'\ohs1995small.dta", replace
