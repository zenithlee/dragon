*** This is the third file in the creation of the PALMS income variable
*** In this file we link every earner to their appropriate earnings bracket. We also create the employerAll variable
*** 	which marks whether we have used the wage earnings or their self-employment earnings (in the case of the OHSs) & is equal to the "employer"
*** We also create a weight variable that can be used with the nonbracket earnings to create a full distribution
****
**** M.Wittenberg June 2013
*adapted for PALMS by A Kerr June 2013

local palmsmergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\PALMS"

cd "`palmsmergefolder'"

set more off
cap log close

version 12.1



*** First make sure that the variables I want to create aren't in the dataset already
*** (this is in case I want to rerun the file without rerunning the first two )
use "`palmsmergefolder'\palmsv1.1.4tempb.dta",  clear
cap drop pr_w
cap drop inc_cat
cap drop pr_se
cap drop sinc_cat
cap drop category
cap drop selfcategory
cap drop Randinfo
cap drop bracket
cap drop bracketperiod
cap drop group
cap drop employerAll
cap drop pr_rand
cap drop bracketweight

save "`palmsmergefolder'\palmsv1.1.4tempc.dta", replace
*erase "`palmsmergefolder'\palmsv1.1.4tempb.dta"

*OHS 94
*** This section of code coomes from OHS94Income.do (cross-checked with OHS94IncomeModify1.do). Note that this doesn't adjust inc_dedc. 
*** But since the adjustment it does make seems to catch many additional spikes it is probably close to what was actually done. 
*** I should actually go back and check this in detail. But life is too short!
gen income=wageempincome2 								// First time round this had a "if gros_pay==2". This means the variable is undefined if gros_pay is undefined
replace deducamt1=0 if deducamt1==.					// This wasn't in the code first time round, making the income variable undefined if gros_pay==1
replace income=wageempincome2+deducamt1 if deduc1==1		/* We need to deal with "gross income" slightly differently */
replace income=(income/22) if earnperiod_wage == 1
replace income = (income/4.33333333) if earnperiod_wage== 2
replace income = income*12 if earnperiod_wage== 4

gen inc_cat=.
replace inc_cat = 1 if income == 0
replace inc_cat = 2 if income >= 1 & income < 100
replace inc_cat = 3 if income >= 100 & income < 200
replace inc_cat = 4 if income >= 200 & income < 500
replace inc_cat = 5 if income >= 500 & income < 1000
replace inc_cat = 6 if income >= 1000 & income < 2000
replace inc_cat = 7 if income >= 2000 & income <4000
replace inc_cat = 8 if income >= 4000 & income < 8000
replace inc_cat = 9 if income >= 8000 & income < 16000
replace inc_cat = 10 if income >= 16000 & income < 33000
replace inc_cat = 11 if income >= 33000 & income ~=.

replace inc_cat =1 if inc_cat==.&empsalcat3==1		// zero income bracket
gen earnperiod_wage94=earnperiod_wage if wave==1	//need another earn period var to be able to adjust it without fiddling with the final one in the dataset...
replace earnperiod_wage94=3 if earnperiod_wage94==.&inc_cat!=.		// default to monthly
* AK: I don't get any changes here, ok(???)

egen category=group(inc_cat earnperiod_wage94)
replace imputed=. if empsalcat3==.		/* These are the nonearners */

keep if wave==1
sort category
save OHS94temp.dta, replace

collapse (mean) pr_w=imputed if imputed~=. [aw=ceweight2], by(category)
sort category
save probtemp, replace

use OHS94temp, clear
merge m:1 category using probtemp
assert _merge ~=2
drop _merge
erase probtemp.dta

replace pr_w = 1-pr_w
label var pr_w "Probability of giving Rand value for wage"

table inc_cat earnperiod_wage94, c(m pr_w)


*** Now do the self-employment income
*** Note that the self-employment income variable is described as "GROSS INCOME OF EMPLOYER (RAND)(CALC PER MNTH)", so
*** it does not appear that the expenses have to be factored in.

*replace expenses=. if expenses==99999
gen grossincome=selfempincome2

replace grossincome=(selfempincome2/22) if earnperiod_self == 1
replace grossincome = (selfempincome2/4.33333333) if earnperiod_self== 2
replace grossincome = selfempincome2*12 if earnperiod_self== 4

gen sinc_cat=.
replace sinc_cat = 2 if grossincome >= 1 & grossincome < 100
replace sinc_cat = 3 if grossincome >= 100 & grossincome < 200
replace sinc_cat = 4 if grossincome >= 200 & grossincome < 500
replace sinc_cat = 5 if grossincome >= 500 & grossincome < 1000
replace sinc_cat = 6 if grossincome >= 1000 & grossincome < 2000
replace sinc_cat = 7 if grossincome >= 2000 & grossincome <4000
replace sinc_cat = 8 if grossincome >= 4000 & grossincome < 8000
replace sinc_cat = 9 if grossincome >= 8000 & grossincome < 16000
replace sinc_cat = 10 if grossincome >= 16000 & grossincome < 32000
replace sinc_cat = 11 if grossincome >= 32000 & grossincome < 64000
replace sinc_cat = 12 if grossincome >= 64000 & grossincome < 128000
replace sinc_cat = 13 if grossincome >= 128000 & grossincome < .

replace sinc_cat = 1 if selfempinccat4==1 & sinc_cat==.		// zero income bracket
gen earnperiod_self94=earnperiod_self if wave==1	//need another earn period var to be able to adjust it without fiddling with the final one in the dataset...
replace earnperiod_self94 = 3 if earnperiod_self==. & sinc_cat !=.		// default to monthly
egen selfcategory=group(sinc_cat earnperiod_self94)

sort selfcategory
save OHS94temp, replace



replace impute_gross=. if selfempinccat4==0
collapse (mean) pr_se=impute_gross if impute_gross~=. [aw=ceweight2], by(selfcategory)
sort selfcategory
save probtemp, replace

use OHS94temp, clear
merge m:1 selfcategory using probtemp
assert _merge ~=2
drop _merge
erase probtemp.dta

replace pr_se = 1-pr_se
label var pr_se "Probability of giving Rand value for self employed"

table sinc_cat earnperiod_self94, c(m pr_se)
count if pr_se==0

keep wave uqnr personnr pr_w inc_cat pr_se sinc_cat category selfcategory
order wave uqnr personnr
sort wave uqnr personnr
save OHS94temp, replace

use "`palmsmergefolder'\palmsv1.1.4tempc.dta", replace

merge 1:1 wave uqnr personnr using OHS94temp
assert _merge==3 if wave==1
drop _merge
sort wave uqnr personnr

save "`palmsmergefolder'\palmsv1.1.4tempc.dta", replace
erase OHS94temp.dta



*** We need to ensure that everyone who gives a Rand amount is assigned to a bracket
* OHS1995
gen byte earnmiss=wageempincome==. if wave==2
gen byte empsalcat2miss=empsalcat2==0|empsalcat2==30|empsalcat2==.
tab earnmiss empsalcat2miss, missing
drop earnmiss empsalcat2miss

replace inc_cat = empsalcat2 if wave==2				// wage brackets for 1995
replace inc_cat= . if empsalcat2==0|empsalcat2==30
replace inc_cat = 1 if wageempincome==0 & wave ==2
replace inc_cat = 2 if wageempincome>=1 & wageempincome<. & wave ==2 
replace inc_cat = 3 if wageempincome>= 1000  & wageempincome<. & wave ==2
replace inc_cat = 4 if wageempincome>= 1250  & wageempincome<. & wave ==2
replace inc_cat = 5 if wageempincome>= 1500  & wageempincome<. & wave ==2
replace inc_cat = 6 if wageempincome>= 2000  & wageempincome<. & wave ==2
replace inc_cat = 7 if wageempincome>= 2500  & wageempincome<. & wave ==2
replace inc_cat = 8 if wageempincome>= 3000  & wageempincome<. & wave ==2
replace inc_cat = 9 if wageempincome>= 4000  & wageempincome<. & wave ==2
replace inc_cat = 10 if wageempincome>= 6000 & wageempincome<. & wave ==2 
replace inc_cat = 11 if wageempincome>= 8000 & wageempincome<. & wave ==2 
replace inc_cat = 12 if wageempincome>= 10000  & wageempincome<. & wave ==2 
replace inc_cat = 13 if wageempincome>= 12500  & wageempincome<. & wave ==2 
replace inc_cat = 14 if wageempincome>= 15000  & wageempincome<. & wave ==2
replace inc_cat = 15 if wageempincome>= 20000  & wageempincome<. & wave ==2
replace inc_cat = 16 if wageempincome>= 25000  & wageempincome<. & wave ==2
replace inc_cat = 17 if wageempincome>= 30000  & wageempincome<. & wave ==2
replace inc_cat = 18 if wageempincome>= 40000  & wageempincome<. & wave ==2
replace inc_cat = 19 if wageempincome>= 60000  & wageempincome<. & wave ==2
replace inc_cat = 20 if wageempincome>= 80000  & wageempincome<. & wave ==2
replace inc_cat = 21 if wageempincome>= 100000  & wageempincome<. & wave ==2
replace inc_cat = 22 if wageempincome>= 125000  & wageempincome<. & wave ==2
replace inc_cat = 23 if wageempincome>= 150000  & wageempincome<. & wave ==2
replace inc_cat = 24 if wageempincome>= 200000  & wageempincome<. & wave ==2
replace inc_cat = 25 if wageempincome>= 250000  & wageempincome<. & wave ==2
replace inc_cat = 26 if wageempincome>= 300000  & wageempincome<. & wave ==2
replace inc_cat = 27 if wageempincome>= 400000  & wageempincome<. & wave ==2
replace inc_cat = 28 if wageempincome>= 500000  & wageempincome<. & wave ==2
replace inc_cat = 29 if wageempincome>= 600000  & wageempincome<. & wave ==2


gen byte selfearnmiss=selfempincome1==. if wave==2
gen byte selfempinccat3miss=(selfempinccat3==0|selfempinccat3==30|selfempinccat3==.) & wave==2
tab selfearnmiss selfempinccat3miss, missing
drop selfearnmiss selfempinccat3miss

replace sinc_cat= selfempinccat3 if wave==2
replace sinc_cat= . if selfempinccat3==0|selfempinccat3==30

replace sinc_cat = 2 if selfempincome1>= 1 & selfempincome1 <. & wave ==2
replace sinc_cat = 3 if selfempincome1>= 1000 & selfempincome1 <. & wave ==2
replace sinc_cat = 4 if selfempincome1>= 1250 & selfempincome1 <. & wave ==2
replace sinc_cat = 5 if selfempincome1>= 1500 & selfempincome1 <. & wave ==2
replace sinc_cat = 6 if selfempincome1>= 2000 & selfempincome1 <. & wave ==2
replace sinc_cat = 7 if selfempincome1>= 2500 & selfempincome1 <. & wave ==2
replace sinc_cat = 8 if selfempincome1>= 3000 & selfempincome1 <. & wave ==2
replace sinc_cat = 9 if selfempincome1>= 4000 & selfempincome1 <. & wave ==2
replace sinc_cat = 10 if selfempincome1>= 6000 & selfempincome1 <. & wave ==2
replace sinc_cat = 11 if selfempincome1>= 8000 & selfempincome1 <. & wave ==2
replace sinc_cat = 12 if selfempincome1>= 10000 & selfempincome1 <. & wave ==2
replace sinc_cat = 13 if selfempincome1>= 12500 & selfempincome1 <. & wave ==2
replace sinc_cat = 14 if selfempincome1>= 15000 & selfempincome1 <. & wave ==2
replace sinc_cat = 15 if selfempincome1>= 20000 & selfempincome1 <. & wave ==2
replace sinc_cat = 16 if selfempincome1>= 25000 & selfempincome1 <. & wave ==2
replace sinc_cat = 17 if selfempincome1>= 30000 & selfempincome1 <. & wave ==2
replace sinc_cat = 18 if selfempincome1>= 40000 & selfempincome1 <. & wave ==2
replace sinc_cat = 19 if selfempincome1>= 60000 & selfempincome1 <. & wave ==2
replace sinc_cat = 20 if selfempincome1>= 80000 & selfempincome1 <. & wave ==2
replace sinc_cat = 21 if selfempincome1>= 100000 & selfempincome1 <. & wave ==2
replace sinc_cat = 22 if selfempincome1>= 125000 & selfempincome1 <. & wave ==2
replace sinc_cat = 23 if selfempincome1>= 150000 & selfempincome1 <. & wave ==2
replace sinc_cat = 24 if selfempincome1>= 200000 & selfempincome1 <. & wave ==2
replace sinc_cat = 25 if selfempincome1>= 250000 & selfempincome1 <. & wave ==2
replace sinc_cat = 26 if selfempincome1>= 300000 & selfempincome1 <. & wave ==2
replace sinc_cat = 27 if selfempincome1>= 400000 & selfempincome1 <. & wave ==2
replace sinc_cat = 28 if selfempincome1>= 500000 & selfempincome1 <. & wave ==2
replace sinc_cat = 29 if selfempincome1>= 600000 & selfempincome1 <. & wave ==2




*** OHS 1996 - 1999
gen byte earnmiss=wageempincome==. if wave>=4&wave<=6
gen byte empsalcat1miss=empsalcat1==0|empsalcat1>14
tab earnmiss empsalcat1miss if wave==4, missing
tab earnmiss empsalcat1miss if wave==5, missing
tab earnmiss empsalcat1miss if wave==6, missing
drop earnmiss empsalcat1miss

replace inc_cat = empsalcat1 if wave>=3 & wave<=6
replace inc_cat = . if (empsalcat1==0|empsalcat1>14) & (wave>=3 & wave<=6)
replace inc_cat = 1 if wageempincome==0 & (wave>=3 & wave<=6)
replace inc_cat = 2 if wageempincome>= 1 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 3 if wageempincome>= 201 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 4 if wageempincome>= 501 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 5 if wageempincome>= 1001 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 6 if wageempincome>= 1501 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 7 if wageempincome>= 2501 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 8 if wageempincome>= 3501 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 9 if wageempincome>= 4501 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 10 if wageempincome>= 6001 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 11 if wageempincome>= 8001 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 12 if wageempincome>= 11001 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 13 if wageempincome>= 16001 & wageempincome<. & (wave>=3 & wave<=6)
replace inc_cat = 14 if wageempincome>= 30001 & wageempincome<. & (wave>=3 & wave<=6)



* Self OHS 1997 & 1998
gen byte selfearnmiss=selfempincome1==. if wave>=4&wave<=6
gen byte selfempinccat2miss=selfempinccat2==0
tab selfearnmiss selfempinccat2miss if wave==4, missing
tab selfearnmiss selfempinccat2miss if wave==5, missing
drop selfempinccat2miss

replace sinc_cat = selfempinccat2 if wave==3|wave==4|wave==5
replace sinc_cat = . if selfempinccat2==0
replace sinc_cat = 2 if selfempincome1>= 1 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 3 if selfempincome1>= 201 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 4 if selfempincome1>= 501 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 5 if selfempincome1>= 1001 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 6 if selfempincome1>= 1501 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 7 if selfempincome1>= 2501 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 8 if selfempincome1>= 3501 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 9 if selfempincome1>= 4501 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 10 if selfempincome1>= 6001 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 11 if selfempincome1>= 8001 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 12 if selfempincome1>= 11001 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 13 if selfempincome1>= 16001 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 14 if selfempincome1>= 30001 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 15 if selfempincome1>= 45001 & selfempincome1<. & (wave==4 | wave==5)
replace sinc_cat = 16 if selfempincome1>= 60001 & selfempincome1<. & (wave==4 | wave==5)

* Self OHS 1999
gen byte selfempinccat1miss=selfempinccat1==0|selfempinccat1==15|selfempinccat1==8888
tab selfearnmiss selfempinccat1miss if wave==6, missing
drop  selfearnmiss  selfempinccat1miss 

replace sinc_cat = selfempinccat1 if wave==6
replace sinc_cat = . if selfempinccat1==0|selfempinccat1==15|selfempinccat1==8888
replace sinc_cat = 2 if selfempincome1>= 1 & selfempincome1<. & wave==6
replace sinc_cat = 3 if selfempincome1>= 201 & selfempincome1<. & wave==6
replace sinc_cat = 4 if selfempincome1>= 501 & selfempincome1<. & wave==6
replace sinc_cat = 5 if selfempincome1>= 1001 & selfempincome1<. & wave==6
replace sinc_cat = 6 if selfempincome1>= 1501 & selfempincome1<. & wave==6
replace sinc_cat = 7 if selfempincome1>= 2501 & selfempincome1<. & wave==6
replace sinc_cat = 8 if selfempincome1>= 3501 & selfempincome1<. & wave==6
replace sinc_cat = 9 if selfempincome1>= 4501 & selfempincome1<. & wave==6
replace sinc_cat = 10 if selfempincome1>= 6001 & selfempincome1<. & wave==6
replace sinc_cat = 11 if selfempincome1>= 8001 & selfempincome1<. & wave==6
replace sinc_cat = 12 if selfempincome1>= 11001 & selfempincome1<. & wave==6
replace sinc_cat = 13 if selfempincome1>= 16001 & selfempincome1<. & wave==6
replace sinc_cat = 14 if selfempincome1>= 30001 & selfempincome1<. & wave==6



*** Now create a dummy variable that records whether the income variable is from wage work or self-employment

/* This is the logic for assembling the info in the OHSs
Assign the category as wage work if wage information is available (i.e. this is the default)
If the "employer1" variable records the individual as being self-employed then use that
If the "employer1" variable suggests the person does both and wage information is missing then assign them as self-employed
If the "employer1" variable is missing, there is no wage information but there is self-employment information then make them self-employed 
*/

gen byte employerAll = .

replace employerAll = 0 if earnings==wage_earnings & earnings<.
replace employerAll = 1 if earnings==selfempincnet & earnings<.
replace employerAll = 0 if employerAll==.&inc_cat!=.							// Default is wage employee
replace employerAll = 1 if employerAll==.&employer1==2&sinc_cat!=.
replace employerAll = 1 if employerAll==.&employer1==3&inc_cat==.&sinc_cat!=.
replace employerAll = 1 if employerAll==.&employer1==.&inc_cat==.&sinc_cat!=.

replace employerAll = 0 if employerAll==.&(employer==1|employer==2)				// LFSs
replace employerAll = 1 if employerAll==.&(employer==3|employer==4)
replace employerAll = 0 if employerAll==.&employer2==1							// QLFSs
replace employerAll = 1 if employerAll==.&(employer2==2|employer2==3)
label define employerAll 0 "wage" 1 "self employ"
label val employerAll employerAll

tab wave employerAll
table wave [pw=ceweight2], c(m employerAll)




*** Now assemble an earnings bracket variable corresponding to the single earnings variable
*** We also need to ensure that people with jobsalary information are put into their correct brackets

gen byte bracket = inc_cat if employerAll==0
replace bracket = sinc_cat if employerAll==1

gen bracketperiod = earnperiod_wage if employerAll==0 & wave<=6
replace bracketperiod = earnperiod_self if employerAll==1 & wave<=6

gen jobsalcatmiss=jobsalcat==15|jobsalcat==16|jobsalcat==88|jobsalcat==99
gen byte jobsalmiss = jobsalary==. if wave>=7&wave<=22
tab jobsalmiss jobsalcatmiss, missing
drop jobsalmiss jobsalcatmiss

*** LFSs
replace bracket = jobsalcat if wave>=7& wave<=22
replace bracket = . if jobsalcat==15|jobsalcat==16|jobsalcat==88|jobsalcat==99

replace bracket = 2 if jobsalary>= 1 & jobsalary<. & wave>=7& wave<=22
replace bracket = 3 if jobsalary>= 201 & jobsalary<. & wave>=7& wave<=22
replace bracket = 4 if jobsalary>= 501 & jobsalary<. & wave>=7& wave<=22
replace bracket = 5 if jobsalary>= 1001 & jobsalary<. & wave>=7& wave<=22
replace bracket = 6 if jobsalary>= 1501 & jobsalary<. & wave>=7& wave<=22
replace bracket = 7 if jobsalary>= 2501 & jobsalary<. & wave>=7& wave<=22
replace bracket = 8 if jobsalary>= 3501 & jobsalary<. & wave>=7& wave<=22
replace bracket = 9 if jobsalary>= 4501 & jobsalary<. & wave>=7& wave<=22
replace bracket = 10 if jobsalary>= 6001 & jobsalary<. & wave>=7& wave<=22
replace bracket = 11 if jobsalary>= 8001 & jobsalary<. & wave>=7& wave<=22
replace bracket = 12 if jobsalary>= 11001 & jobsalary<. & wave>=7& wave<=22
replace bracket = 13 if jobsalary>= 16001 & jobsalary<. & wave>=7& wave<=22
replace bracket = 14 if jobsalary>= 30001 & jobsalary<. & wave>=7& wave<=22

*** QLFSs
gen byte earnmiss = earnings==. if wave>=31
gen byte earncatmiss=earningscat==0|earningscat==20|earningscat==21|earningscat==99|earningscat==. if wave>=31
tab earnmiss earncatmiss, missing
drop earnmiss earncatmiss

replace bracket = earningscat if wave>=23
replace bracket = . if earningscat==0|earningscat==20|earningscat==21|earningscat==99 

replace bracket = 2 if earnings>= 1 & earnings<. & wave>=23
replace bracket = 3 if earnings>= 201 & earnings<. & wave>=23
replace bracket = 4 if earnings>= 501 & earnings<. & wave>=23
replace bracket = 5 if earnings>= 1001 & earnings<. & wave>=23
replace bracket = 6 if earnings>= 1501 & earnings<. & wave>=23
replace bracket = 7 if earnings>= 2501 & earnings<. & wave>=23
replace bracket = 8 if earnings>= 3501 & earnings<. & wave>=23
replace bracket = 9 if earnings>= 4501 & earnings<. & wave>=23
replace bracket = 10 if earnings>= 6001 & earnings<. & wave>=23
replace bracket = 11 if earnings>= 8001 & earnings<. & wave>=23
replace bracket = 12 if earnings>= 11001 & earnings<. & wave>=23
replace bracket = 13 if earnings>= 16001 & earnings<. & wave>=23
replace bracket = 14 if earnings>= 30001 & earnings<. & wave>=23
replace bracket = 15 if earnings>= 37501 & earnings<. & wave>=23
replace bracket = 16 if earnings>= 54168 & earnings<. & wave>=23
replace bracket = 17 if earnings>= 62501 & earnings<. & wave>=23
replace bracket = 18 if earnings>= 70801 & earnings<. & wave>=23
replace bracket = 19 if earnings>= 83301 & earnings<. & wave>=23

***** Create grouping variable
***** We need to redo 1994 because we will have a slightly different count within categories now that we have forced out dual earnings information

drop category selfcategory
drop pr_w pr_se

egen group= group(bracket bracketperiod) if wave<=2
replace group=bracket if wave>=3

gen byte Randinfo=earnings<.&bracket<.
sort wave group employerAll
save palmsv1.1.4tempc.dta, replace

collapse pr_rand=Randinfo if bracket~=. [aw=ceweight2], by(wave group employerAll)
save probtemp.dta, replace

use palmsv1.1.4tempc.dta, clear
merge m:1 wave group employerAll using probtemp
assert _merge!=2
drop _merge

table bracket bracketperiod employerAll if wave==1, c(m pr_rand)
table bracket bracketperiod employerAll if wave==2, c(m pr_rand)
table bracket employerAll wave if wave>2, c(m pr_rand)

drop group inc_cat sinc_cat

label var pr_rand "Probability of giving actual Rand amount"
label var employerAll "Wage worker or Self-employed - all waves"
gen bracketweight = ceweight2/pr_rand
label var bracketweight "Weight to correct for bracket responses"

sort wave uqnr personnr
save palmsv1.1.4tempc.dta, replace


exit

