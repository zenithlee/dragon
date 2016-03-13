*PALMS earnings, incorporating code from Martin Wittenberg into the PALMS do files. 
*July 2013
*Andrew Kerr

set more off
cap log close
clear all
version 12

local palmsmergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\PALMS"


use "`palmsmergefolder'\palmsv1.1.4.dta", replace


*OHs 94
gen wage_earnings=wageempincome2 if imputed==0
*replace wage_earnings=wageempincome2-deduc if gros_pay==1	& deduc<salary_r		// The assumption here is that the "wageempincome2" figure is not actually net - based on the CDFs
																			// We are forcing net earnings to be positive
gen selfempinc=selfempincome2  if impute_gross==0
replace selfempinc=. if selfempincome2 ==0								// selfempincome2 has no missings at all. It contains 98083 values of zero.\
gen expenses=selfempexpall
replace expenses=. if expenses==99999|expenses==99998
replace expenses=round(expenses/12,1) if earnperiod_self==4

gen selfempincnet=selfempinc-expenses 

*** Generate earnings for OHS 95-99

replace wage_earnings = wageempincome if wave!=1		// This means that the missing earnings period info in 1998 and 1999 is assigned to the monthly	category
replace wage_earnings = int(wageempincome*22) if earnperiod_wage==1 & wave!=1
replace wage_earnings = round(wageempincome*4.333333,1) if earnperiod_wage==2 & wave!=1
replace wage_earnings = round(wageempincome/12,1) if earnperiod_wage==4 & wave!=1

replace selfempinc=selfempincome1 if selfempinc==.		// Note that Missing self-earnings period is set to monthly
replace selfempinc=selfempinc*22 if earnperiod_self==1 & wave!=1
replace selfempinc=round(selfempinc*4.333333,1) if earnperiod_self==2 & wave!=1
replace selfempinc=round(selfempinc/12,1) if earnperiod_self==4 & wave!=1

replace selfempexpall=. if selfempexpall==99999
replace expenses=selfempexpall if wave==2

replace selfempexpgoods=0 if selfempexpgoods==. & selfempinc<.
replace selfempexprenum=0 if selfempexprenum==. & selfempinc<.
replace selfempexpoth=0 if selfempexpoth==. & selfempinc<.
replace selfempexpgoods=0 if selfempexpgoods==. & selfempinccat2<.
replace selfempexprenum=0 if selfempexprenum==. & selfempinccat2<.
replace selfempexpoth=0 if selfempexpoth==. & selfempinccat2<.

replace expenses=selfempexpgoods+ selfempexprenum+ selfempexpoth if expenses==.
table wave earnperiod_self, c(m expenses)
replace expenses=round(expenses/12,1) if earnperiod_self==4

replace selfempincnet=selfempinc-expenses if wave==2|wave==4|wave==5
replace selfempincnet=selfempinc if wave==6								// figure is net in 1999
gen byte negearnings=selfempincnet<0 if selfempincnet<.
table wave earnperiod_self, c(n negearnings m negearnings)
drop negearnings

replace selfempincnet=. if selfempincnet<0




***** Now we need to assemble the different types of earnings into one variable

gen byte wageinfo=(wage_earnings>=0&wage_earnings<.)| (empsalcat1>0&empsalcat1<=14) | (empsalcat2>0&empsalcat2<=29) | empsalcat3<=11
gen byte selfinfo=(selfempincnet>0&selfempincnet<.)|( selfempinccat1>1& selfempinccat1<=14)|(selfempinccat2>1&selfempinccat2<=16)|(selfempinccat3>2&selfempinccat3<=29)|(selfempinccat4>2&selfempinccat4<=13)
		// note that I have presumed that zero self employment income is not informative, but have allowed it for wage income

gen byte earningsinfo=0
replace earningsinfo=1 if wageinfo==1
replace earningsinfo=2 if selfinfo==1
replace earningsinfo=3 if wageinfo==1&selfinfo==1

tab earningsinfo employer1, missing
tab wave earningsinfo if wave<=6
tab wave earningsinfo if wave<=6&earningsinfo>0, row

gen earnings=wage_earnings
replace earnings=selfempincnet if employer1==2
replace earnings=selfempincnet if employer1==3 & (earnings==. | (earnings==0 & selfempincnet<.))
replace earnings=selfempincnet if employer1==. & earningsinfo==2

*LFS data
replace earnings = jobsalary if earnperiod==3 & wave>=7				// LFSs
replace earnings = jobsalary*4.33 if earnperiod==2 & wave>=7
replace earnings = jobsalary/12 if earnperiod==4 & wave>=7

*QLFS data
replace monthlyjobsalary=. if monthlyjobsalary==888888 /*90 obs higher than 100000 pm, highest monthly salary 400000, but odd that 11 obs with that amount*/
replace earnings=monthlyjobsalary if wave>=23
replace monthlyjobearn=. if monthlyjobearn==88888888 /* 142 obs higher than 100000 pm, 12 higher than 1 million pm*/
replace earnings=monthlyjobearn if wave>=23 & earnings==.

tab wave, summ(earnings)
table wave, c(p1 earnings p5 earnings p50 earnings p95 earnings p99 earnings)
table wave [pw=ceweight2], c(p1 earnings p5 earnings p50 earnings p95 earnings p99 earnings)
table wave if earnings>0 [pw=ceweight2], c(p1 earnings p5 earnings p50 earnings p95 earnings p99 earnings)
table wave if earnings>0 [pw=ceweight2], c(m earnings)


*** Create a real earnings variable

global CPI94Oct = 68.9
global CPI95Oct = 73.3
global CPI96Oct = 79.9
global CPI97Oct = 86
global CPI98Oct = 93.7
global CPI99Oct = 95.3
global CPI00Feb = 96.6
global CPI00Sep = 101.7
global CPI01Feb = 104.1
global CPI01Sep = 106.2
global CPI02Feb = 110.2
global CPI02Sep = 118.1
global CPI03Mar = 122.7
global CPI03Sep = 122.5
global CPI04Mar = 123.2
global CPI04Sep = 124.1
global CPI05Mar = 126.9
global CPI05Sep = 129.5
global CPI06Mar = 131.2
global CPI06Sep = 136.3
global CPI07Mar = 139.2
global CPI07Sep = 146.1


global CPI10Mar = 111.1*1.6			//177.76 Figure taken from P0141 December 2011, conversion of 1.6 Base year 2008 vs 2000, see P0141 Jan 2010 vs P0141 Dec 2008
global CPI10Jun = 111.5*1.6			//178.4
global CPI10Sep = 112.4*1.6			//179.84
global CPI10Dec = 113*1.6			//180.8
global CPI11Mar = 115.7*1.6			//185.12
global CPI11Jun = 117.1*1.6			//187.36
global CPI11Sep = 118.8*1.6			//190.08
global CPI11Dec = 119.9*1.6			//191.84

gen realearnings=earnings/$CPI94Oct*100 if wave==1
replace realearnings=earnings/$CPI95Oct*100 if wave==2
*replace realearnings=earnings if wave==3 /*there are no actual income amounts in OHS1996*/
replace realearnings=earnings/$CPI97Oct*100 if wave==4
replace realearnings=earnings/$CPI98Oct*100 if wave==5
replace realearnings=earnings/$CPI99Oct*100 if wave==6
replace realearnings=earnings/$CPI00Feb*100 if wave==7
replace realearnings=earnings/$CPI00Sep*100 if wave==8
replace realearnings=earnings/$CPI01Feb*100 if wave==9
replace realearnings=earnings/$CPI01Sep*100 if wave==10
replace realearnings=earnings/$CPI02Feb*100 if wave==11
replace realearnings=earnings/$CPI02Sep*100 if wave==12
replace realearnings=earnings/$CPI03Mar*100 if wave==13
replace realearnings=earnings/$CPI03Sep*100 if wave==14
replace realearnings=earnings/$CPI04Mar*100 if wave==15
replace realearnings=earnings/$CPI04Sep*100 if wave==16
replace realearnings=earnings/$CPI05Mar*100 if wave==17
replace realearnings=earnings/$CPI05Sep*100 if wave==18
replace realearnings=earnings/$CPI06Mar*100 if wave==19
replace realearnings=earnings/$CPI06Sep*100 if wave==20
replace realearnings=earnings/$CPI07Mar*100 if wave==21
replace realearnings=earnings/$CPI07Sep*100 if wave==22

replace realearnings=(earnings/$CPI10Mar)*100 if wave==31
replace realearnings=(earnings/$CPI10Jun)*100 if wave==32
replace realearnings=(earnings/$CPI10Sep)*100 if wave==33
replace realearnings=(earnings/$CPI10Dec)*100 if wave==34
replace realearnings=(earnings/$CPI11Mar)*100 if wave==35
replace realearnings=(earnings/$CPI11Jun)*100 if wave==36
replace realearnings=(earnings/$CPI11Sep)*100 if wave==37
replace realearnings=(earnings/$CPI11Dec)*100 if wave==38


save "`palmsmergefolder'\palmsv1.1.4tempa.dta", replace

