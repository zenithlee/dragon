clear
set more off

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHS94"

use "`datafolder'\house_v1.3.dta"
renvars, lower
rename uniqnum uqnr
duplicates tag uqnr, gen(tag)
tab tag
*no duplicates
drop tag

tostring number1, gen(ea1)
tostring number2, gen(ea2)
gen eaunique=ea1+ea2
destring eaunique, replace

gen double hhid= uqnr
sort uqnr


save "`datafolder'\ohs1994htemp.dta", replace

use "`datafolder'\ohs1994.cewgt_corrected.dta"
renvars, lower

merge 1:1 uqnr using "`datafolder'\ohs1994htemp.dta"
tab _merge
rename _merge mergeh1
sort hhid
save "`datafolder'\ohs1994h.dta", replace


use "`datafolder'\person_1.3.dta"
*drop idchild
*not in newer DQP data!
renvars, lower
rename uniqnum uqnr
gen double hhid= uqnr
gen double personid=hhid*100+person
drop if person==.
*there were 39 obs with no hhid, now none in dqp data!

duplicates tag personid, gen(tag)
tab tag
*no duplicates (after missing hhid obs drop)
drop tag
sort personid
save "`datafolder'\ohs1994p", replace

*use "`datafolder'\work_v1.3.dta"
*now using the data from MW with incomes corrected as best they can be!
use "`datafolder'\work_impute_v1.3.dta"


renvars, lower
rename uniqnum uqnr
gen double hhid= uqnr
gen double personid=hhid*100+person
duplicates tag personid, gen(tag)
tab tag
*no duplicates 
drop tag

sort personid
save "`datafolder'\ohs1994w", replace

merge 1:1 personid using  "`datafolder'\ohs1994p.dta"
rename _merge mergepw

save "`datafolder'\ohs1994pw.dta", replace

merge m:1 hhid using  "`datafolder'\ohs1994h.dta"
rename _merge mergeh

save "`datafolder'\ohs1994pwh.dta", replace


order hhid personid

*If I am following the structure of the LFS do files then these variables below should be defined and labelled in here and should match the final variable names from the excel file
*at the moment they have pre-renaming names, so this needs to be fixed!
gen status1=0 if age>14 &age<.
replace status1=1 if wk_old15==1 |wk_old15==2
replace status1=2 if strict==1


gen status2=0 if age>14 &age<.
replace status2=1 if wk_old15==1 |wk_old15==2
replace status2=2 if expanded==1

drop number4

rename occ_main occ1
gen occup=.
replace occup=1 if occ1>=11 & occ1<200
replace occup=2 if occ1>=200 & occ1<300
replace occup=3 if occ1>=300 & occ1<400
replace occup=4 if occ1>=400 & occ1<500
replace occup=5 if occ1>=500 & occ1<600
replace occup=6 if occ1>=600 & occ1<700
replace occup=7 if occ1>=700 & occ1<800
replace occup=8 if occ1>=800 & occ1<900
replace occup=9 if occ1>=900 & occ1<1000 &occ1!=913 &occ1!=910
replace occup=11 if occ1==913 | occ1==910


rename ind_main ind1
gen indust=.
replace indust=1 if ind1>0 &ind1<=3
replace indust=2 if ind1>3 &ind1<=9
replace indust=3 if ind1>9 &ind1<=19
replace indust=4 if ind1>=20 &ind1<=21
replace indust=5 if ind1==22
replace indust=6 if ind1>=23 & ind1<=26
replace indust=7 if ind1>=27 &ind1<=31
replace indust=8 if ind1>=32 &ind1<=39
replace indust=9 if ind1>=40 &ind1<=47
replace indust=10 if ind1==48
*coding indust=10 if ind1==48 actually goes against the 94 industry codelist, but is in line with 95 codelist
*basically there are no people listed as working for private hh in 94!
replace indust=12 if ind1==49 | ind1==50

save "`mergefolder'\ohschecktemp.dta", replace

quietly do "`mergefolder'\OHSrename1994.do"
quietly do "`mergefolder'\OHSrename2.do"


quietly do "`mergefolder'\ohslabelvars.do"
quietly do "`mergefolder'\ohslabeldefine.do"
quietly do "`mergefolder'\ohslabelvalues.do"


*MARCH 2013, WORKED OUT THAT MW HAS DONE THE BEST JOB POSSIBLE ON THE (imputed) INCOME DATA from SSA, SO I INCLUDE HIS ESTIMATES AND THEN LEAVE THE RELEASED DATA AS IS ///
*for PEOPLE who ARE INTERESTED IN REPLICATING HIS RESULTS.

label var salary_impute "Est net income per month for employees, OHS 94. See Wittenberg (2008)"
label var emp_impute "Est gross income p/month in own acct activities, OHS 94. See Wittenberg (2008)"
label var imputed "The original net income figure is imputed, OHS 94. See Wittenberg (2008)"
label var impute_gross "The orig gross income from own acc figure is imputed, OHS 94. See Wittenberg (2008)"

order hhid personid
sort personid
numlabel, add
save "`mergefolder'\ohs1994.dta", replace

*this little bit of code creates a list of 94 variables which are labeled and or have values labeled..
clear 
insheet using "`mergefolder'\OHS Master codebook.csv"
keep var1994 newcode2
keep if var1994!=""
keep newcode2


use "`mergefolder'\ohs1994.dta", replace

*this keep must be updated using the list of vars left in stata data from OHS Master codebook, since I haven't yet automated the updating of new variables..
*keep hhid, not uqnr!!
keep uqnr ea	personid personnr	province ceweight pweight	urbrur	gender	age	popgroup4	whynotwork4	willacceptwork	empstat1	empstat2 employer1	selfformalreg selfvatreg selfpaidemp selfunpaidemp imputed salary_impute  impute_gross emp_impute empsalary2  deduc1	deducamt1	empsalperiod3	empsalcat3	selfempincperiod2	selfempincome2 selfempinccat4	selfempexpall	educhigh6 enrollment3	jobocccode1	jobindcode1	hrslstwk dwelltype3	toimaintype2	watersource5	marstat4	jobunion	searchhow3

save "`mergefolder'\ohs1994small.dta", replace

exit
