*prepare 2011 LMD incomes to merge with QLFSs
*no info on refuses.
*and lots of imputations :(
*A Kerr Feb 2013, adjusted slightly July 2013 for PALMv2 release

clear all
set more off

cd "C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"

use "LMD 2011 with QLFS Quarter.dta", replace
renvars, lower

keep uqno personno quarter q52salaryinterval q53tipscommission q54a_monthly q56salaryinterval q57a_monthly q58salarycategory

save "`lmdfolder'\lmdincomes2011.dta", replace

drop if quarter !=1

sort uqno personno

save lmdincomes2011q1.dta, replace

use "`lmdfolder'\lmdincomes2011.dta", replace
drop if quarter !=2

sort uqno personno

save lmdincomes2011q2.dta, replace

use "`lmdfolder'\lmdincomes2011.dta", replace
drop if quarter !=3

sort uqno personno

save lmdincomes2011q3.dta, replace

use "`lmdfolder'\lmdincomes2011.dta", replace
drop if quarter !=4

sort uqno personno

save lmdincomes2011q4.dta, replace
