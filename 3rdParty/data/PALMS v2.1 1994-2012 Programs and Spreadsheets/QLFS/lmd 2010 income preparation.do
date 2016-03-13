*prepare LMD incomes to merge with QLFSs
*A Kerr Feb 2013, adjusted slightly July 2013 for PALMv2 release

clear all
set more off

cd "C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"

use "LMD 2010 with QLFS Quarter.dta", replace
renvars, lower

keep uqno personno quarter q52salaryinterval q53tipscommission q54a_monthly q54brefuse q56salaryinterval q57a_monthly q58salarycategory q57brefuse

save "`lmdfolder'\lmdincomes2010.dta", replace

drop if quarter !=1

sort uqno personno

save lmdincomes2010q1.dta, replace

use "`lmdfolder'\lmdincomes2010.dta", replace
drop if quarter !=2

sort uqno personno

save lmdincomes2010q2.dta, replace

use "`lmdfolder'\lmdincomes2010.dta", replace
drop if quarter !=3

sort uqno personno

save lmdincomes2010q3.dta, replace

use "`lmdfolder'\lmdincomes2010.dta", replace
drop if quarter !=4

sort uqno personno

save lmdincomes2010q4.dta, replace
