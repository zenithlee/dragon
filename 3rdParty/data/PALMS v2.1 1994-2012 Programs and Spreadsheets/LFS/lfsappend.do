* lfsappend.do
* Append all waves of South Africa Labour Force Survey
* uses new versions of data with standardized variable names and value labels
* D. Lam June 2008
* Modified by Andrew Kerr, May 2011

clear

set more off

global mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge"

/************************************************************************
*re-run files that merge person and worker modules for each year:

forval y=2000/2007 {
	forval i=1/2 {
		do "$mergefolder\lfsmerge`y'_`i'.do"
	}
}
***************************************************************************/

cap clear
set mem 1500m

use "$mergefolder\lfs2000_1.dta"
gen int year=2000
gen byte round=1
append using "$mergefolder\lfs2000_2.dta"
replace year=2000 if year==.
replace round=2 if round==.

forval y=2001/2007 {
	forval i=1/2 {
		qui append using "$mergefolder\lfs`y'_`i'.dta"
		qui replace year=`y' if year==.
		qui replace round=`i' if round==.
		tab wave
	}
}
compress
*drop a bunch of variables that are only in wave 3:
drop pipedwater-sanlevel
drop buselectric-busphyswork

/* the following is necessary if you just have one round in the last year:
append using $mergefolder\lfs2007_1.dta
replace year=2007 if year==.
replace round=1 if round==.
*/

*drop 84 observations that have household data but no person data:
drop if mergeh==2

*fix compatibilities in some variables:
replace staymarchprev=b_mar06 if b_mar06~=.
drop b_mar06
replace staymarchprev=b_mar07 if b_mar07~=.
drop b_mar07

*drop original household identifier, replace by hhid
drop uqnr
label var hhid "household ID (not unique across waves)"
label var personid "person ID (not unique across waves)"
format hhid %14.0f
duplicates report personid wave

* note: to get rid of a large number of additional variables, delete child variables that are unique to wave 13
* this drops file size by about 100mb
*des ch*
drop ch*

compress

tab wave
tab year round

order wave year round personid hhid personnr gender age spouseinhh spousenum
sort wave personid
save "$mergefolder\lfswaves1to16.dta", replace
/*
keep WhyNotWork
WhyNotWork2
WillAcceptWork
*/
