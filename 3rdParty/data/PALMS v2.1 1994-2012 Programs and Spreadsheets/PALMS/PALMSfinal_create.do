*adjust the PALMS data with MW's income variables for final release
*keep old income data in a separate file in case users want to try and replicate MW's work.
*A Kerr, July 2013



local palmsmergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\PALMS"

cd "`palmsmergefolder'"

set more off
cap log close

version 12.1



use "`palmsmergefolder'\palmsv1.1.4tempc.dta",  clear
numlabel, add

drop earnperiod earnperiod_wage earnperiod_self jobsalary jobsalcat wageempincome wageempincome2 empsalcat1 empsalcat2 empsalcat3 selfempincome1 selfempincome2 ///
imputed salary_impute impute_gross emp_impute deduc1 deducamt1 selfempinccat1 selfempinccat2 selfempinccat3 selfempinccat4 selfempexpgoods selfempexprenum ///
selfempexpoth selfempexpall tipscomm jobsalperiod2 monthlyjobsalary salaryrefusedontknow selfemppayperiod2 monthlyjobearn earningsrefusedontknow earningscat ///
wage_earnings selfempinc expenses selfempincnet wageinfo selfinfo earningsinfo /*inc_outlier*/ outlier bracket bracketperiod highsalary highresid Randinfo

rename outlier2 outlier

label var earnings "consistent monthly earnings (rand amt) variable for PALMSv2"
label var realearnings "consistent REAL monthly earnings (rand amt) variable for PALMSv2"
label var outlier "outlier flag based on regression+showing a studentised residual with value of 5 or higher"


datasignature set, reset

save "`palmsmergefolder'\palmsv2.dta", replace


*do this again and KEEP all the extra income variables in another file:

use "`palmsmergefolder'\palmsv1.1.4tempc.dta",  clear

keep uqnr personnr wave earnperiod earnperiod_wage earnperiod_self jobsalary jobsalcat wageempincome wageempincome2 empsalcat1 empsalcat2 empsalcat3 selfempincome1 selfempincome2 ///
imputed salary_impute impute_gross emp_impute deduc1 deducamt1 selfempinccat1 selfempinccat2 selfempinccat3 selfempinccat4 selfempexpgoods selfempexprenum ///
selfempexpoth selfempexpall tipscomm jobsalperiod2 monthlyjobsalary salaryrefusedontknow selfemppayperiod2 monthlyjobearn earningsrefusedontknow earningscat ///
/*wage_earnings selfempinc expenses selfempincnet wageinfo selfinfo earningsinfo /*inc_outlier*/ highresid Randinfo*/
note: PALMS data version v2, created by Andrew Kerr, July 2013
datasignature set, reset
save "`palmsmergefolder'\palmsv2incomes.dta", replace


