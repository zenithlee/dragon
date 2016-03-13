* qlfsappend.do
* Append all waves of South Africa Q Labour Force Survey
* Andrew Kerr, April 2012, Based on a do file by D Lam, University of Michigan
*for now its working until 2011_2 inclusive..

clear all

set more off

global mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"

/************************************************************************/
*re-run files that merge person and worker modules for each year:

forval y=2008/2011 {
	forval i=1/4 {
		do "$mergefolder\qlfsmerge`y'_`i'.do"
	}
}

do "$mergefolder\qlfsmerge2012_1.do"

***************************************************************************/

cap clear


use "$mergefolder\qlfs2008_1.dta"
gen int year=2008
gen byte round=1
append using "$mergefolder\qlfs2008_2.dta"
replace year=2008 if year==.
replace round=2 if round==.

append using "$mergefolder\qlfs2008_3.dta"
replace year=2008 if year==.
replace round=3 if round==.

append using "$mergefolder\qlfs2008_4.dta"
replace year=2008 if year==.
replace round=4 if round==.

forval y=2009/2011 {
	forval i=1/4 {
		qui append using "$mergefolder\qlfs`y'_`i'.dta"
		qui replace year=`y' if year==.
		qui replace round=`i' if round==.
		tab wave
	}
}
*2012 first wave here for now
		qui append using "$mergefolder\qlfs2012_1.dta"
		qui replace year=2012 if year==.
		qui replace round=1 if round==.


compress

tab wave
tab year round

gen uqnr


order wave uqnr personnr gender age 
sort wave uqnr personnr
save "$mergefolder\qlfswaves23to39.dta", replace
/*
keep WhyNotWork
WhyNotWork2
WillAcceptWork
*/
