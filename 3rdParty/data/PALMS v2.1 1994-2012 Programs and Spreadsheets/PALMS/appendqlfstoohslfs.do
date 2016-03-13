

*Putting the QLFS together with the OHS and LFS data. 
*Jan 2013
*A Kerr

clear all
set more off

local ohslfsmergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSlfs"
local qlfsmergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"
local palmsmergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\PALMS"
local ceweightsfolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\From Takwanisa"

use "`ohslfsmergefolder'\ohslfsdatav1.0.14.dta"
 /*june 2013: no longer neccessary: tostring uqnr, replace format (%20.0f)
 drop personid*/

 *must fix up inperson to be consistent with qlfs
 replace inperson=8 if inperson==. &wave>6 &age<15
 replace inperson=9 if inperson==. &wave>6 &age>15 &age<.
 label drop inperson
 label define inperson 1"Yes" 2"No" 8"Not Applicable" 9"Unspecified"
 
 *adding in a don't know option which was introduced in QLFSs
 label drop educhigh
 label var educhigh "Highest level of education"
label define educhigh 0 "No schooling" 1 "Grade 0" 2 "Grade 1"  3 "Grade 2" 4 "Grade 3" 5 "Grade 1/grade2/grade 3" 6 "Grade 4" 7 "Grade 5" 8"Grade 6" 9 "Grade 7" 10 "Grade 8" 11 "Grade 9" ///
	12 "Grade 10/NTC I"	13 "Grade 11/NTC II" 14 "Grade 12/NTC III" 15 "Certificate or diploma with less than grade 12" 16 "Certificate or diploma with grade 12" ///
	17 "Undergraduate degree" 18 "Post-graduate degree/diploma" 19 "Degree (undergrad or postgrad)" 20 "Other" 21 "Don't know"



 
label var numworkers "Number of regular workers at job, LFS"

gen writtencontract=.
replace writtencontract=1 if jobcontract== 1
replace writtencontract=0 if jobcontract== 2
label var writtencontract "=1 if employee has written contract, LFS+QLFS"
drop jobcontract*

label var enrollment3 "Enrollment, OHS and LFS only" 

*now add in the QLFS data 
append using "`qlfsmergefolder'\palmsconsistentqlfs.dta"


*June 2013, replacing the educhigh variable with a years of education variable.
recode educhigh (0 1 = 0) (2 = 1) (3 5 = 2) (4 = 3) (6 = 4) (7 = 5) (8 = 6) (9 = 7) (10 = 8) (11 = 9) (12 = 10) (13 = 11) (14 = 12) (15 = 11) (16 = 13) (17 19 = 15) (18 = 16) (20 21=.), gen(yrseduc)
label var yrseduc "Years of education, derived variable"
drop educhigh



label drop wave
label variable wave "Survey wave, OHS 1994=1, QLFS Mar 2012=39"
label define wave 1"OHS 1994" 2"OHS 1995" 3"OHS 1996" 4"OHS 1997" 5"OHS 1998" 6"OHS 1999" 7"LFS 00:1" 8"LFS 00:2" 9"LFS 01:1" 10"LFS 01:2" 11"LFS 02:1" ///
	12"LFS 02:2" 13"LFS 03:1" 14"LFS 03:2" 15"LFS 04:1" 16"LFS 04:2" 17"LFS 05:1" 18"LFS 05:2" 19"LFS 06:1" 20"LFS 06:2" ///
	21"LFS 07:1" 22"LFS 07:2" 23 "QLFS 08:1" 24 "QLFS 08:2" 25 "QLFS 08:3" 26 "QLFS 08:4" 27 "QLFS 09:1" 28 "QLFS 09:2" 29 "QLFS 09:3" 30 "QLFS 09:4" ///
	31 "QLFS 2010:1" 32 "QLFS 2010:2" 33 "QLFS 2010:3" 34 "QLFS 2010:4" 35 "QLFS 2011:1" 36 "QLFS 2011:2" 37 "QLFS 2011:3" 38 "QLFS 2011:4" 39 "QLFS 2012:1" 
label values wave wave

label var educhigh2 "Highest level of educ, QLFS only"
label var jobstartyear "Year started working for employer, LFS+QLFS only"
label var jobstartmonth "Month started working for employer, LFS+QLFS only"
label var ceweight "Older Cross entropy weight, OHS+LFS only, ASSA 2003 model"
label var industry "3 digit industry SIC code, OHS 96 onwards"
label var occupation "4 digit occupation code, OHS 96 onwards"
label var jobunion " Member of trade union, OHS+LFS only"
label var publicemp "Dummy: Employed by govt/public enterprise, LFS+QLFS only"
*label var earnperiodaddjob "Earnings Period for 2nd job, OHS only"
/*label drop jobsector
label define formalreg 1"Formal employment" 2"Informal Employment" 3"Don't Know" 7"Other" 8"Not Applicable" 9"Unspecified"
label values formalreg formalreg
variabel label formalreg "LFS and QLFS variable for wage/self/domestic: business is formal,registered"
*/





****************************Now add in new 2008 ASSA model derived cross entropy weights*********
sort wave uqnr personnr
merge 1:1 wave uqnr personnr using "`ceweightsfolder'\palmsceweightsv1.2.dta"
drop _merge



**************************************************************************************************

compress

order uqnr /*uqnr_orig*/ personnr year wave province urbrur ea dc ceweight ceweight2 pweight hweight inperson popgroup gender age marstat  yrseduc educhigh0 educhigh1 educhigh2 enrolled enrollment3 empstat1 empstat2 ///
employer employer1 employer2 numworkers numworkers2 jobstartyear jobstartmonth writtencontract selfformalreg selfvatreg selfpaidemp selfunpaidemp wageformalreg formalreg formalreg2 /// 
jobindcode industry jobocccode occupation occupation1 jobunion publicemp ///
businesstype1 businesstype2 businesstype3 hrslstwk earnperiod earnperiod_wage earnperiod_self jobsalary jobsalcat wageempincome wageempincome2 empsalcat1 empsalcat2 empsalcat3 selfempincome1 ///
selfempincome2 imputed salary_impute impute_gross emp_impute deduc1 deducamt1 selfempinccat1 selfempinccat2 selfempinccat3 selfempinccat4 selfempexpgoods selfempexprenum selfempexpoth ///
selfempexpall tipscomm jobsalperiod2 monthlyjobsalary salaryrefusedontknow selfemppayperiod2 monthlyjobearn earningsrefusedontknow earningscat jobcontract2
	

label data "PALMS data: OHS 1994-1999, LFS Feb 2000-Sept 2007, QLFS Mar 2008-Mar 2012"

notes
notes drop _dta


numlabel, add 

save "`palmsmergefolder'\palmsv1.1.4.dta", replace

*I'm also going to have to do some label adjusting, eg note that occuption codes are only for OHS 96 onwards. Maybe I don't have to specify in the data though as long as I do it in variable list?
