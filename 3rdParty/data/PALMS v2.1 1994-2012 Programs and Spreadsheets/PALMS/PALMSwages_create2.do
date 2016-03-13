*** This is the second file in the creation of the PALMS income variable
*** We take the continuous income variable (created in the first file) and flag the outliers
*** We adopt three approaches:
***		a) flag incomes above R1 million per month (real Rands, 2000)
***		b) multivariate outlier detection via the BACON command
***		c) flag extreme residuals in a multivariate regression

/*this code is by Martin Wittenberg, and used by A Kerr for inclusion into the PALMS do files and data.*/


set more off
cap log close
clear
set matsize 1500
set emptycells drop

version 12.1
local palmsmergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\PALMS"
use "`palmsmergefolder'\palmsv1.1.4tempa.dta",  clear

*** in case we want to rerun this file without rerunning everything
cap drop highsalary
cap drop inc_outlier
cap drop highresid
cap drop outlier2
cap drop outlier


*** Approach a)

gen byte highsalary=realearnings>=1000000/12 if realearnings<.		// millionaires

table wave highsalary

**** Approach b)

gen logwage=log(realearnings)

gen byte no_ed = yrseduc==0 
gen byte low_ed = yrseduc>0 & yrseduc<8 
gen byte med_ed = (yrseduc>=8 & yrseduc<12)
gen byte matric= yrseduc==12
gen byte hi_ed = yrseduc>12&yrseduc<=16
gen byte miss_ed = (yrseduc==. | educhigh0 ==26 | (educhigh1>20 & educhigh1<.) | (educhigh2>=25 & educhigh2<.))

*table wave [pw=ceweight2], c(m no_ed m low_ed m med_ed m matric m hi_ed)

tab wave jobocccode if empstat1==1, missing
tabulate  jobocccode, gen(occup)
drop occup11 occup12
gen byte occupmiss=jobocccode>10
tab wave occupmiss if empstat1>0 & empstat1<.

/*
bacon logwage no_ed - occup10 occupmiss, gen (inc_outlier incdist) percentile(.01) replace
assert occupmiss==1 if inc_outlier==1

bacon logwage no_ed - occup10 if occupmiss!=1, gen (inc_outlier incdist) percentile(.1) replace
assert inc_outlier!=1

*this one is as MW did it and gives way too many outliers!
bacon logwage no_ed low_ed med_ed matric hi_ed if occupmiss!=1, gen(inc_outlier incdist) percentile(15) replace
list realearnings wave yrseduc if inc_outlier==1			// These are almost definitely garbage!	


*ak bacon checks:
bacon  logwage no_ed - occup10 if occupmiss!=1, gen(inc_outlier incdist) percentile(15) replace

drop incdist
*/
drop occup1-occupmiss

** Approach c)

gen int age2=age^2
assert age==. if age2==.		// we shouldn't go beyond the storage limit of int if age is in the appropriate range, but it's good to check anyhow

regress logwage i.gender#i.wave i.popgroup#i.wave i.yrseduc age age2 i.jobocccode
predict residstd, rstudent
di 2*ttail(500000,4)
di 2*ttail(500000,4)*e(N)								// we would expect to see this many "outliers"
di 2*ttail(500000,5)
di 2*ttail(500000,5)*e(N)								// we would expect to see this many "outliers"

gen byte highresid=abs(residstd)>4 if e(sample)==1
gen byte outlier2=abs(residstd)>5 if e(sample)==1		// more conservative approach. Also trims both ends. But it does drop everyone who has missing info on the explanatory variables
count if outlier2==.&highsalary==1
list wave uqnr personnr realearnings popgroup yrseduc age jobocccode employer1 empstat1 if outlier2==.&highsalary==1


table highresid highsalary /*inc_outlier*/

gen byte outlier=highresid==1&highsalary==1		// all the BACON outliers will also be flagged
replace outlier=1 if highresid==.&highsalary==1	// these will be the same three dubious observations

replace outlier2=1 if outlier2==.&highsalary==1
replace outlier2=0 if outlier2==.&realearnings<.&highsalary==0			// no info. Give the benefit of the doubt?

tab wave outlier
tab wave outlier2


*** Approach c.1) run a robust regression to check that outliers aren't contaminating the regression results
rreg logwage i.gender#i.wave i.popgroup#i.wave i.yrseduc age age2 i.jobocccode, genwt(w1)
gen outlier3=w1==0 if e(sample)
replace outlier3=1 if outlier3==.&highsalary==1

assert outlier3==1 if outlier2==1
tab outlier3 outlier, missing
list wave uqnr personnr realearnings popgroup yrseduc age jobocccode employer1 empstat1 if outlier3==0&outlier==1
replace outlier=0 if outlier==1&outlier3==0

drop w1 outlier3


gen real2=realearnings if outlier==0
gen real3=realearnings if outlier2==0
table wave [pw=ceweight2], c(m realearnings m real2 m real3)

drop no_ed low_ed med_ed matric hi_ed miss_ed
drop residstd age2
drop real2 real3
drop logwage

sort wave uqnr personnr
compress
save "`palmsmergefolder'\palmsv1.1.4tempb.dta", replace
*erase  "`palmsmergefolder'\palmsv1.1.4tempa.dta"

