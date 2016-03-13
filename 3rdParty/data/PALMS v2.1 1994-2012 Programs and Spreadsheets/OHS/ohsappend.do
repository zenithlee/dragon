*this do file appends small OHS 94-99 datasets that are labelled (and are still to be properly cleaned) and creates variables consistent with LFS variables
*Andrew Kerr, July 2011

clear all
set more off


global mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHSmerge"

/* run code to generate a dataset for each wave of the OHSs: 94-99
forval y=1994/1999 {
		do "$mergefolder\ohsmerge`y'.do"
	}
	*/

*global mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHSmerge"

	use "$mergefolder\ohs1999small.dta"
	gen year=1999
	foreach var in 1998 1997 1996 1995 1994 {
	append using "$mergefolder\ohs`var'small.dta"
		qui replace year=`var' if year==.
	
	}

save "$mergefolder\ohsallsmall.dta", replace

*creating a string version of uqnr that helps to make merging in other data easier for PALMS end users.
	gen str20 uqnr_orig=string(uqnr, "%16.0f" )
	
	*June 2013, now using the string instead of the double as uqnr.
	drop uqnr
	rename uqnr_orig uqnr
	label var uqnr "household id variable"
	

*creating variables consistent with LFS
gen popgroup=.
replace popgroup=popgroup2 if popgroup2!=.
replace popgroup=popgroup3 if popgroup3!=.
replace popgroup=5 if popgroup3==5 | popgroup3==6
replace popgroup=1 if popgroup4==4
replace popgroup=3 if popgroup4==1
replace popgroup=4 if popgroup4==3
replace popgroup=2 if popgroup4==2
label var popgroup "Population Group"

label define popgroup 1 "African/Black" 2 "Coloured" 3 "Indian/Asian" 4 "White" 5 "Other"
label values popgroup popgroup

*need to do some adjustment to paid and unpaid employees of the self-employed:
replace selfpaidemp=. if selfpaidemp ==0 & (employer1==0 | employer1==1)
replace selfunpaidemp=. if selfunpaidemp ==0 & (employer1==0 | employer1==1)
*the above is done because OHS 94 and 95 have all as zero whether or not they are actually self-employed
replace selfpaidemp=. if selfpaidemp==8888
replace selfunpaidemp=. if selfunpaidemp==8888
*the above is done because 99 had 8888 as missing code.
replace selfpaidemp=. if selfpaidemp==999
replace selfunpaidemp=. if selfunpaidemp==999
*the above is done because 96 and 97 had 999 as missing code
replace selfpaidemp=0 if selfpaidemp==. & (employer1==2 |employer==3)
replace selfunpaidemp=0 if selfunpaidemp==. & (employer1==2 |employer==3)
*the above is done because 98 and 96 has missing if the person didn't have any employees.
*the end result looks ok for paid employees: tab selfpaidemp year, col
*the result for unpaid employees looks dodgy, but because of the actual numbers reported rather than because of the fixes implemented above: tab selfunpaidemp year, col

replace selfformalreg=. if (selfformalreg==0 & (year==1994 | year==1995)) | (selfformalreg==8888 )
replace selfvatreg=. if (selfvatreg==0 & (year==1994 | year==1995)) | (selfvatreg==8888 )
replace wageformalreg=. if wageformalreg==8888

/* July 2013 redoing earnperiod to be separate for wage and self employment, see below
gen earnperiod=.
replace earnperiod=2 if empsalperiod1==1
replace earnperiod=3 if empsalperiod1==2
replace earnperiod=4 if empsalperiod1==3
replace earnperiod=1 if empsalperiod2==1
replace earnperiod=2 if empsalperiod2==2
replace earnperiod=3 if empsalperiod2==3
replace earnperiod=empsalperiod3 if empsalperiod3!=0 & empsalperiod3!=.

gen earnperiodaddjob=.
replace earnperiodaddjob=selfempincperiod2 if selfempincperiod2!=. & selfempincperiod2!=0 &earnperiod!=.
replace earnperiodaddjob=2 if selfempincperiod1==1 &earnperiod!=.
replace earnperiodaddjob=3 if selfempincperiod1==2 &earnperiod!=.
replace earnperiodaddjob=4 if selfempincperiod1==3 &earnperiod!=.

replace earnperiod=selfempincperiod2 if selfempincperiod2!=. & selfempincperiod2!=0 &earnperiod==.
replace earnperiod=2 if selfempincperiod1==1 &earnperiod==.
replace earnperiod=3 if selfempincperiod1==2 &earnperiod==.
replace earnperiod=4 if selfempincperiod1==3 &earnperiod==.
*not asked in 96!

label var earnperiod "Earnings Period"
label define earnperiod 1 "Per day" 2 "Per week" 3 "Per month" 4 "Per year"
label values earnperiod  earnperiod 



label var earnperiodaddjob "Earnings Period for 2nd job"
label define earnperiodaddjob 1 "Per day" 2 "Per week" 3 "Per month" 4 "Per year"
label values earnperiodaddjob earnperiodaddjob
*/

//periods not asked in OHS- brackets only

gen earnperiod_wage=.
replace earnperiod_wage=2 if empsalperiod1==1
replace earnperiod_wage=3 if empsalperiod1==2
replace earnperiod_wage=4 if empsalperiod1==3
replace earnperiod_wage=1 if empsalperiod2==1
replace earnperiod_wage=2 if empsalperiod2==2
replace earnperiod_wage=3 if empsalperiod2==3
replace earnperiod_wage=empsalperiod3 if empsalperiod3!=0 & empsalperiod3!=.

gen earnperiod_self=.
replace earnperiod_self=selfempincperiod2 if selfempincperiod2!=. & selfempincperiod2!=0 
replace earnperiod_self=2 if selfempincperiod1==1 
replace earnperiod_self=3 if selfempincperiod1==2 
replace earnperiod_self=4 if selfempincperiod1==3 

label var earnperiod_wage "Earnings Period, employees, OHS only"
label define earnperiod_wage 1 "Per day" 2 "Per week" 3 "Per month" 4 "Per year"
label values earnperiod_wage  earnperiod_wage 

label var earnperiod_self "Earnings Period, self-employed, OHS only"
label define earnperiod_self 1 "Per day" 2 "Per week" 3 "Per month" 4 "Per year"
label values earnperiod_self earnperiod_self



gen dwelltype=.
replace dwelltype=1 if dwelltype1==1 | dwelltype2==1 | dwelltype3==1
replace dwelltype=2 if dwelltype1==2 | dwelltype2==2 | dwelltype3==4
replace dwelltype=3 if dwelltype1==3 | dwelltype2==3 | dwelltype3==2
replace dwelltype=4 if dwelltype1==4 | dwelltype2==4 | dwelltype3==3
replace dwelltype=5 if dwelltype1==7 | dwelltype2==6 | dwelltype3==6
replace dwelltype=6 if dwelltype1==8 | dwelltype2==7 | dwelltype3==5
replace dwelltype=7 if dwelltype1==5 | dwelltype1==6 | dwelltype1==9 | dwelltype1==10 | dwelltype1==11  | dwelltype2==5 | dwelltype2==8 | dwelltype2==9 | dwelltype3==7 | dwelltype3==8 

*so option "Dwelling/House/Flat/Room in backyard" is going into other, but in OHS 94 that would have gone into dwelltype==1.
label var dwelltype "Type of Dwelling of Household"
label define dwelltype 1 "Dwelling/house or brick structure on a separate stand or yard or on farm" 2 "Traditional dwelling/hut/structure made of traditional materials" ///
3 "Flat or apartment in a block of flats" 4 "Town/cluster/semi-detached house (simplex, duplex or triplex)" 5 "Informal dwelling/shack in backyard" ///
6 "Informal dwelling/Shack not in backyard" 7 "Other (includes caravan, retirement village, room/flatlet, Dwelling/House/Flat/Room in backyard)"
label values dwelltype dwelltype


gen watersource=.
replace watersource=1 if watersource3==1 | watersource4==1 | watersource5==1
replace watersource=2 if watersource3==2 | watersource4==2 | watersource5==2
replace watersource=3 if watersource3==3 | watersource4==4 | watersource5==4 | watersource5==5
replace watersource=4 if watersource3==4 | watersource4==3 | watersource5==3
replace watersource=5 if watersource3==5 | watersource4==5 | watersource4==7 | watersource5==6 | watersource5==8
replace watersource=6 if watersource3==6 | watersource4==6 | watersource4==8 | watersource5==7 | watersource5==9
replace watersource=7 if watersource3==7 | watersource4==9 | watersource5==10
replace watersource=8 if watersource3==8 | watersource4==10 | watersource5==11
replace watersource=9 if watersource3==9 | watersource4==11 | watersource5==12
replace watersource=10 if watersource3==10 | watersource4==12 | watersource4==13 | watersource5==13 | watersource5==14
replace watersource=11 if watersource3==11 | watersource4==14 | watersource4==15 | watersource5==15 | watersource5==16
replace watersource=12 if watersource3==12 | watersource4==16 |  watersource5==17

label var watersource "Household's source of water"
label define watersource 1 "Piped (Tap) Water in dwelling" 2 "Piped (Tap) Water on site or in yard" 3 "Public tap" 4 "Water-Carrier/Tanker" 5 "Borehole on site" ///
			6 "Borehole off site/communal" 7 "Rain-water tank on site" 8 "Flowing water/stream river" 9 "Dam/Pool/Stagnant water" 10 "Well" 11 "Spring" 12 "Other" 
label values  watersource watersource

*cant include 94 or 96 as the variable wasn't asked in a helpful way in those surveys..
gen toiletmaintype=.
replace toiletmaintype=1 if toimaintype1==11 | (toindw==1 &year!=1996)
replace toiletmaintype=2 if toimaintype1==21 | toionsite1==1 |  toionsite3==1
replace toiletmaintype=3 if toimaintype1==31 | toiofsit1==1  |  toiofsit3==1
replace toiletmaintype=4 if toimaintype1==22 | toionsite1==2 |  toionsite3==2
replace toiletmaintype=5 if toimaintype1==32 | toiofsit1==2  |  toiofsit3==2
replace toiletmaintype=6 if toimaintype1==23 | toionsite1==3 |  toionsite3==3
replace toiletmaintype=7 if toimaintype1==33 | toiofsit1==3  |  toiofsit3==2
replace toiletmaintype=8 if toimaintype1==24 | toionsite1==4 |  toionsite3==4
replace toiletmaintype=9 if toimaintype1==34 | toiofsit1==4  |  toiofsit3==2
replace toiletmaintype=10 if toimaintype1==25 | toionsite1==5 |  toionsite3==5
replace toiletmaintype=11 if toimaintype1==35 | toiofsit1==5  |  toiofsit3==5
replace toiletmaintype=12 if toimaintype1==37 | toiofsit1==7  |  toionsite3==7 | toiofsit3==7
replace toiletmaintype=13 if toimaintype1==36 | toiofsit1==6  | toiofsit3==6

label var toiletmaintype  "Main toilet used by household"
label define toiletmaintype 1 "Flush toilet in dwelling" 2 "Flush toilet on site" 3"Flush toilet off-site" 4"Chemical toilet on-site" 5"Chemical toilet off-site" ///
6 "Pit latrine with ventilation pipe, on site" 7 "Pit latrine with ventilation pipe, off site" 8 "Pit latrine without ventilation pipe, on-site" ///
9 "Pit latrine without ventilation pipe, off-site" 10 "Bucket toilet on-site" 11 "Bucket toilet off-site" 12 "Other" 13 "None"
label values toiletmaintype toiletmaintype


cap label drop marstat
gen marstat=.
replace marstat=1 if marstat4==2 | marstat4==3 | marstat4==4 |marstat3==1 |marstat3==2 |marstat3==3
replace marstat=2 if marstat4==5 |marstat3==4
replace marstat=3 if marstat4==6|marstat3==5
replace marstat=4 if marstat4==1 |marstat3==6

label var marstat "Marital status"
label define marstat 1 "Married or living together as husband and wife" 2 "Widow/widower" 3 "Divorced or separated" 4 "Never married"
label values marstat marstat



gen educhigh=.
replace educhigh=0 if educprimsec==0 | educhigh3==0 | educhigh4==0 | educhigh5==0 | educhigh6==0
replace educhigh=1 if educprimsec==1 | educhigh3==1 
replace educhigh=2 if educprimsec==2 | educhigh3==2 | educhigh4==1
replace educhigh=3 if educprimsec==3 | educhigh3==3 | educhigh4==2
replace educhigh=4 if educprimsec==4 | educhigh3==4 | educhigh4==3
replace educhigh=5 if educhigh5==1 | educhigh6==1
replace educhigh=6 if educprimsec==5 | educhigh3==5 | educhigh4==4 | educhigh5==2 | educhigh6==2
replace educhigh=7 if educprimsec==6 | educhigh3==6 | educhigh4==5 | educhigh5==3 | educhigh6==3
replace educhigh=8 if educprimsec==7 | educhigh3==7 | educhigh4==6 | educhigh5==4 | educhigh6==4
replace educhigh=9 if educprimsec==8 | educhigh3==8 | educhigh4==7 | educhigh5==5 | educhigh6==5
replace educhigh=10 if educprimsec==9 | educhigh3==9 | educhigh4==8 | educhigh5==6 | educhigh6==6
replace educhigh=11 if educprimsec==10 | educhigh3==10 | educhigh4==9 | educhigh5==7 | educhigh6==7
replace educhigh=12 if educprimsec==11 | educhigh3==11 | educhigh3==14 | educhigh4==10 | educhigh4==13 | educhigh5==8 | educhigh6==8
replace educhigh=13 if educprimsec==12 | educhigh3==12 | educhigh3==15 | educhigh4==11 | educhigh4==14 | educhigh5==9 | educhigh6==9
replace educhigh=14 if educprimsec==13 | educhigh3==13 | educhigh3==16 | educhigh4==12 | educhigh4==15 | educhigh5==10 | educhigh6==10
replace educhigh=15 if ((educter1==1 | educter1==2) &educprimsec<13)  | educter2==1 |  educhigh3==17 | educhigh4==16 | educhigh5==11 | educhigh6==11
replace educhigh=16 if ((educter1==1 | educter1==2) &educprimsec==13)  | educter2==2 |  educhigh3==18 | educhigh4==17 | educhigh5==12 | educhigh6==12
replace educhigh=17 if educter1==3 | educter1==4 |  educter2==3 | educter2==4 |  educhigh3==19
replace educhigh=18 if educter1==5 | educter1==6 | educter1==7 |  educter2==5 | educter2==6 | educter2==7 |  educhigh3==20
replace educhigh=19 if educhigh4==18 | educhigh5==13 | educhigh6==13
replace educhigh=20 if educter1==8 |  educter2==8 | educhigh3==21 | educhigh4==19  | educhigh5==14 | educhigh6==14
*NTC were lumped with grade 10,11,12 in 95, 97 and 98. 94-95 didn't distinguish bet grade 1,2 and 3. 94-96 did not include gr 0 option. 
*94, 95, 96 and 99 didn't distinguish bet diplomas and certificates or different post grad degrees. 94-96 didn't distinguish bet undergrad and post-grad degrees.

label var educhigh "Highest education level completed"
label define educhigh 0 "No schooling" 1 "Grade 0" 2 "Grade 1"  3 "Grade 2" 4 "Grade 3" 5 "Grade 1/grade 2/grade 3" 6 "Grade 4" 7 "Grade 5" 8"Grade 6" 9 "Grade 7" 10 "Grade 8" 11 "Grade 9" ///
	12 "Grade 10/NTC I"	13 "Grade 11/NTC II" 14 "Grade 12/NTC III" 15 "Certificate or diploma with less than grade 12" 16 "Certificate or diploma with grade 12" ///
	17 "Undergraduate degree" 18 "Post-graduate degree" 19 "Degree (undergrad or postgrad)" 20 "Other"
label values educhigh educhigh

*June 2013, creating a new educ variable for the OHSs with more info and categories.
gen educhigh0=educhigh if educhigh<=11
replace  educhigh0=12 if educhigh4==10 | educhigh3==11
replace  educhigh0=13 if educhigh4==11 | educhigh3==12
replace  educhigh0=14 if educhigh4==12 | educhigh3==13

replace  educhigh0=15 if educhigh5==8 | educhigh6==8 | educprimsec==11
replace  educhigh0=16 if educhigh5==9 | educhigh6==9 | educprimsec==12
replace  educhigh0=17 if educhigh5==10 | educhigh6==10 | educprimsec==13


replace educhigh0=18 if educhigh4==13 | educhigh3==14
replace educhigh0=19 if educhigh4==14 |educhigh3==15
replace educhigh0=20 if educhigh4==15 | educhigh3==16
replace educhigh0=21 if ((educter1==1 | educter1==2) &educprimsec<13)  | educter2==1 |  educhigh3==17 | educhigh4==16 | educhigh5==11 | educhigh6==11
replace educhigh0=22 if ((educter1==1 | educter1==2) &educprimsec==13)  | educter2==2 |  educhigh3==18 | educhigh4==17 | educhigh5==12 | educhigh6==12
replace educhigh0=23 if educter1==3 | educter1==4 |  educter2==3 | educter2==4 |  educhigh3==19
replace educhigh0=24 if educter1==5 | educter1==6 | educter1==7 |  educter2==5 | educter2==6 | educter2==7 |  educhigh3==20
replace educhigh0=25 if educhigh4==18 | educhigh5==13 | educhigh6==13
replace educhigh0=26 if educter1==8 |  educter2==8 | educhigh3==21 | educhigh4==19  | educhigh5==14 | educhigh6==14

label var educhigh0 "Highest education level, OHSs only"
label define educhigh0 0 "No schooling" 1 "Grade 0" 2 "Grade 1"  3 "Grade 2" 4 "Grade 3" 5 "Grade 1/grade 2/grade 3 (OHS 94-95)" 6 "Grade 4" 7 "Grade 5" 8"Grade 6" 9 "Grade 7" 10 "Grade 8" 11 "Grade 9" ///
	12 "Grade 10"	13 "Grade 11" 14 "Grade 12" 15 "Grade 10/NTC I"	16 "Grade 11/NTC II" 17 "Grade 12/NTC III" 18 "NTC I" 19"NTC II" 20"NTC III" 21 "Certificate or diploma with less than grade 12" 22 "Certificate or diploma with grade 12" ///
	23 "Undergraduate degree" 24 "Post-graduate degree" 25 "Degree (undergrad or postgrad)" 26 "Other"
label values educhigh0 educhigh0


*make missings consistent with LFS variable
replace enrollment3=9 if enrollment3==0


gen selfearncatmin=.
gen selfearncatmax=. 
replace selfearncatmin=1 if selfempinccat1==2 | selfempinccat2==2 | selfempinccat3==2 | selfempinccat4==2
replace selfearncatmin=2401 if selfempinccat1==3 | selfempinccat2==3
replace selfearncatmin=6001 if selfempinccat1==4 | selfempinccat2==4
replace selfearncatmin=12001 if selfempinccat1==5 | selfempinccat2==5
replace selfearncatmin=18001 if selfempinccat1==6 | selfempinccat2==6
replace selfearncatmin=30001 if selfempinccat1==7 | selfempinccat2==7
replace selfearncatmin=42001 if selfempinccat1==8 | selfempinccat2==8
replace selfearncatmin=54001 if selfempinccat1==9 | selfempinccat2==9
replace selfearncatmin=72001 if selfempinccat1==10 | selfempinccat2==10
replace selfearncatmin=96001 if selfempinccat1==11 | selfempinccat2==11
replace selfearncatmin=132001 if selfempinccat1==12 | selfempinccat2==12
replace selfearncatmin=192001 if selfempinccat1==13 | selfempinccat2==13
replace selfearncatmin=360001 if selfempinccat1==14 | selfempinccat2==14
replace selfearncatmin=540001 if selfempinccat2==15
replace selfearncatmin=720001 if selfempinccat2==16

replace selfearncatmax=2400 if selfempinccat1==2 | selfempinccat2==2
replace selfearncatmax=6000 if selfempinccat1==3 | selfempinccat2==3
replace selfearncatmax=12000 if selfempinccat1==4 | selfempinccat2==4
replace selfearncatmax=18000 if selfempinccat1==5 | selfempinccat2==5
replace selfearncatmax=30000 if selfempinccat1==6 | selfempinccat2==6
replace selfearncatmax=42000 if selfempinccat1==7 | selfempinccat2==7
replace selfearncatmax=54000 if selfempinccat1==8 | selfempinccat2==8
replace selfearncatmax=72000 if selfempinccat1==9 | selfempinccat2==9
replace selfearncatmax=96000 if selfempinccat1==10 | selfempinccat2==10
replace selfearncatmax=132000 if selfempinccat1==11 | selfempinccat2==11
replace selfearncatmax=192000 if selfempinccat1==12 | selfempinccat2==12
replace selfearncatmax=360000 if selfempinccat1==13 | selfempinccat2==13
replace selfearncatmax=. if  selfempinccat1==14 
replace selfearncatmax=540000 if selfempinccat2==14
replace selfearncatmax=720000 if selfempinccat2==15
replace selfearncatmax=. if selfempinccat2==16

replace selfearncatmin=1000 if  selfempinccat3==3
replace selfearncatmin=1250 if selfempinccat3==4
replace selfearncatmin=1500 if selfempinccat3==5
replace selfearncatmin=2000 if selfempinccat3==6
replace selfearncatmin=2500 if selfempinccat3==7
replace selfearncatmin=3000 if selfempinccat3==8
replace selfearncatmin=4000 if selfempinccat3==9
replace selfearncatmin=6000 if selfempinccat3==10
replace selfearncatmin=8000 if selfempinccat3==11
replace selfearncatmin=10000 if selfempinccat3==12
replace selfearncatmin=12000 if selfempinccat3==13
replace selfearncatmin=15000 if selfempinccat3==14
replace selfearncatmin=20000 if selfempinccat3==15
replace selfearncatmin=25000 if selfempinccat3==16
replace selfearncatmin=30000 if selfempinccat3==17
replace selfearncatmin=40000 if selfempinccat3==18
replace selfearncatmin=60000 if selfempinccat3==19
replace selfearncatmin=80000 if selfempinccat3==20
replace selfearncatmin=100000 if selfempinccat3==21
replace selfearncatmin=125000 if selfempinccat3==22
replace selfearncatmin=150000 if selfempinccat3==23
replace selfearncatmin=200000 if selfempinccat3==24
replace selfearncatmin=250000 if selfempinccat3==25
replace selfearncatmin=300000 if selfempinccat3==26
replace selfearncatmin=400000 if selfempinccat3==27
replace selfearncatmin=500000 if selfempinccat3==28
replace selfearncatmin=600000 if selfempinccat3==29

replace selfearncatmax=999 if selfempinccat3==2
replace selfearncatmax=1249 if selfempinccat3==3
replace selfearncatmax=1499 if selfempinccat3==4
replace selfearncatmax=1999 if selfempinccat3==5
replace selfearncatmax=2499 if selfempinccat3==6
replace selfearncatmax=2999 if selfempinccat3==7
replace selfearncatmax=3999 if selfempinccat3==8
replace selfearncatmax=5999 if selfempinccat3==9
replace selfearncatmax=7999 if selfempinccat3==10
replace selfearncatmax=9999 if selfempinccat3==11
replace selfearncatmax=12499 if selfempinccat3==12
replace selfearncatmax=14999 if selfempinccat3==13
replace selfearncatmax=19999 if selfempinccat3==14
replace selfearncatmax=24999 if selfempinccat3==15
replace selfearncatmax=29999 if selfempinccat3==16

replace selfearncatmax=39999 if selfempinccat3==17
replace selfearncatmax=59999 if selfempinccat3==18
replace selfearncatmax=79999 if selfempinccat3==19
replace selfearncatmax=99999 if selfempinccat3==20
replace selfearncatmax=124999 if selfempinccat3==21
replace selfearncatmax=149999 if selfempinccat3==22
replace selfearncatmax=199999 if selfempinccat3==23
replace selfearncatmax=249999 if selfempinccat3==24
replace selfearncatmax=299999 if selfempinccat3==25
replace selfearncatmax=399999 if selfempinccat3==26
replace selfearncatmax=499999 if selfempinccat3==27
replace selfearncatmax=599999 if selfempinccat3==28
replace selfearncatmax=. if selfempinccat3==29


replace selfearncatmin=100 if selfempinccat4==3
replace selfearncatmin=200 if selfempinccat4==4
replace selfearncatmin=500 if selfempinccat4==5
replace selfearncatmin=1000 if selfempinccat4==6
replace selfearncatmin=2000 if selfempinccat4==7
replace selfearncatmin=4000 if selfempinccat4==8
replace selfearncatmin=8000 if selfempinccat4==9
replace selfearncatmin=16000 if selfempinccat4==10
replace selfearncatmin=32000 if selfempinccat4==11
replace selfearncatmin=64000 if selfempinccat4==12
replace selfearncatmin=128000 if selfempinccat4==13

replace selfearncatmax=99 if selfempinccat4==2
replace selfearncatmax=199 if selfempinccat4==3
replace selfearncatmax=499 if selfempinccat4==4
replace selfearncatmax=999 if selfempinccat4==5
replace selfearncatmax=1999 if selfempinccat4==6
replace selfearncatmax=3999 if selfempinccat4==7
replace selfearncatmax=7999 if selfempinccat4==8
replace selfearncatmax=15999 if selfempinccat4==9
replace selfearncatmax=31999 if selfempinccat4==10 
replace selfearncatmax=63999 if selfempinccat4==11 
replace selfearncatmax=127999 if selfempinccat4==12
replace selfearncatmax=. if selfempinccat4==13

replace selfearncatmin=selfearncatmin*12 if earnperiod_self==3 & (selfempinccat3!=. | selfempinccat4!=. )
replace selfearncatmin=selfearncatmin*52 if earnperiod_self==2 & (selfempinccat3!=. | selfempinccat4!=. )
replace selfearncatmin=selfearncatmin*260 if earnperiod_self==1 & (selfempinccat3!=. | selfempinccat4!=.)

replace selfearncatmax=selfearncatmax*12 if earnperiod_self==3 & (selfempinccat3!=. | selfempinccat4!=. )
replace selfearncatmax=selfearncatmax*52 if earnperiod_self==2 & (selfempinccat3!=. | selfempinccat4!=. )
replace selfearncatmax=selfearncatmax*260 if earnperiod_self==1 & (selfempinccat3!=. | selfempinccat4!=.)

label var selfearncatmin "Minimum of self-employment earnings category (OHS), adjusted to annual figure"
label var selfearncatmax "Maximum of self-employment earnings category (OHS), adjusted to annual figure"

gen wageearncatmin=.
gen wageearncatmax=. 
replace wageearncatmin=1 if empsalcat1==2 | empsalcat2==2 | empsalcat3==2
replace wageearncatmin=2401 if empsalcat1==3 
replace wageearncatmin=6001 if empsalcat1==4 
replace wageearncatmin=12001 if empsalcat1==5
replace wageearncatmin=18001 if empsalcat1==6 
replace wageearncatmin=30001 if empsalcat1==7 
replace wageearncatmin=42001 if empsalcat1==8 
replace wageearncatmin=54001 if empsalcat1==9 
replace wageearncatmin=72001 if empsalcat1==10 
replace wageearncatmin=96001 if empsalcat1==11 
replace wageearncatmin=132001 if empsalcat1==12 
replace wageearncatmin=192001 if empsalcat1==13 
replace wageearncatmin=360001 if empsalcat1==14 


replace wageearncatmax=2400 if empsalcat1==2 
replace wageearncatmax=6000 if empsalcat1==3 
replace wageearncatmax=12000 if empsalcat1==4 
replace wageearncatmax=18000 if empsalcat1==5 
replace wageearncatmax=30000 if empsalcat1==6 
replace wageearncatmax=42000 if empsalcat1==7 
replace wageearncatmax=54000 if empsalcat1==8 
replace wageearncatmax=72000 if empsalcat1==9 
replace wageearncatmax=96000 if empsalcat1==10 
replace wageearncatmax=132000 if empsalcat1==11 
replace wageearncatmax=192000 if empsalcat1==12 
replace wageearncatmax=360000 if empsalcat1==13 
replace wageearncatmax=. if empsalcat1==14 


replace wageearncatmin=1000 if empsalcat2==3 
replace wageearncatmin=1250 if empsalcat2==4 
replace wageearncatmin=1500 if empsalcat2==5 
replace wageearncatmin=2000 if empsalcat2==6 
replace wageearncatmin=2500 if empsalcat2==7 
replace wageearncatmin=3000 if empsalcat2==8 
replace wageearncatmin=4000 if empsalcat2==9 
replace wageearncatmin=6000 if empsalcat2==10 
replace wageearncatmin=8000 if empsalcat2==11 
replace wageearncatmin=10000 if empsalcat2==12 
replace wageearncatmin=12000 if empsalcat2==13 
replace wageearncatmin=15000 if empsalcat2==14 
replace wageearncatmin=20000 if empsalcat2==15 
replace wageearncatmin=25000 if empsalcat2==16 
replace wageearncatmin=30000 if empsalcat2==17 
replace wageearncatmin=40000 if empsalcat2==18 
replace wageearncatmin=60000 if empsalcat2==19 
replace wageearncatmin=80000 if empsalcat2==20 
replace wageearncatmin=100000 if empsalcat2==21 
replace wageearncatmin=125000 if empsalcat2==22 
replace wageearncatmin=150000 if empsalcat2==23 
replace wageearncatmin=200000 if empsalcat2==24 
replace wageearncatmin=250000 if empsalcat2==25 
replace wageearncatmin=300000 if empsalcat2==26 
replace wageearncatmin=400000 if empsalcat2==27 
replace wageearncatmin=500000 if empsalcat2==28 
replace wageearncatmin=600000 if empsalcat2==29 

replace wageearncatmax=999 if empsalcat2==2 
replace wageearncatmax=1249 if empsalcat2==3 
replace wageearncatmax=1499 if empsalcat2==4 
replace wageearncatmax=1999 if empsalcat2==5 
replace wageearncatmax=2499 if empsalcat2==6 
replace wageearncatmax=2999 if empsalcat2==7 
replace wageearncatmax=3999 if empsalcat2==8 
replace wageearncatmax=5999 if empsalcat2==9 
replace wageearncatmax=7999 if empsalcat2==10
replace wageearncatmax=9999 if empsalcat2==11 
replace wageearncatmax=12499 if empsalcat2==12
replace wageearncatmax=14999 if empsalcat2==13
replace wageearncatmax=19999 if empsalcat2==14
replace wageearncatmax=24999 if empsalcat2==15 
replace wageearncatmax=29999 if empsalcat2==16 

replace wageearncatmax=39999 if empsalcat2==17 
replace wageearncatmax=59999 if empsalcat2==18 
replace wageearncatmax=79999 if empsalcat2==19 
replace wageearncatmax=99999 if empsalcat2==20 
replace wageearncatmax=124999 if empsalcat2==21 
replace wageearncatmax=149999 if empsalcat2==22 
replace wageearncatmax=199999 if empsalcat2==23 
replace wageearncatmax=249999 if empsalcat2==24 
replace wageearncatmax=299999 if empsalcat2==25 
replace wageearncatmax=399999 if empsalcat2==26 
replace wageearncatmax=499999 if empsalcat2==27 
replace wageearncatmax=599999 if empsalcat2==28 
replace wageearncatmax=. if empsalcat2==29 


replace wageearncatmin=100 if empsalcat3==3 
replace wageearncatmin=200 if empsalcat3==4 
replace wageearncatmin=500 if empsalcat3==5 
replace wageearncatmin=1000 if empsalcat3==6 
replace wageearncatmin=2000 if empsalcat3==7 
replace wageearncatmin=4000 if empsalcat3==8 
replace wageearncatmin=8000 if empsalcat3==9 
replace wageearncatmin=16000 if empsalcat3==10 
replace wageearncatmin=33000 if empsalcat3==11 


replace wageearncatmax=99 if empsalcat3==2 
replace wageearncatmax=199 if empsalcat3==3 
replace wageearncatmax=499 if empsalcat3==4 
replace wageearncatmax=999 if empsalcat3==5 
replace wageearncatmax=1999 if empsalcat3==6 
replace wageearncatmax=3999 if empsalcat3==7 
replace wageearncatmax=7999 if empsalcat3==8 
replace wageearncatmax=15999 if empsalcat3==9
replace wageearncatmax=32999 if empsalcat3==10 
replace wageearncatmax=. if empsalcat3==11 

replace wageearncatmin=wageearncatmin*12 if earnperiod_wage==3 & (empsalcat2!=. | empsalcat3!=.)
replace wageearncatmin=wageearncatmin*52 if earnperiod_wage==2 & ( empsalcat2!=. | empsalcat3!=.)
replace wageearncatmin=wageearncatmin*260 if earnperiod_wage==1 & ( empsalcat2!=. | empsalcat3!=.)

replace wageearncatmax=wageearncatmax*12 if earnperiod_wage==3 & (empsalcat2!=. | empsalcat3!=.)
replace wageearncatmax=wageearncatmax*52 if earnperiod_wage==2 & (empsalcat2!=. | empsalcat3!=.)
replace wageearncatmax=wageearncatmax*260 if earnperiod_wage==1 & (empsalcat2!=. | empsalcat3!=.)

label var wageearncatmin "Minimum of wage-employment earnings category (OHS), adjusted to annual figure"
label var wageearncatmax "Maximum of wage-employment earnings category (OHS), adjusted to annual figure"

gen jobindcode=.
replace jobindcode=jobindcode1 if jobindcode1>=1 & jobindcode1<=10
replace jobindcode=99 if jobindcode1>10 & jobindcode1<8888
cap label drop jobindcode 
label var jobindcode "Industry of Employment"
label define jobindcode 1 "Agriculture, hunting, forestry and fishing" 2 "Mining and quarrying" 3 "Manufacturing" 4 "Utilities" 5 "Construction" 6 "Trade" 7 "Transport" ///
8 "Finance" 9 "Services" 10 "Domestic Services" 99 "Missing"
label values jobindcode  jobindcode 


gen industry=industry1
replace industry=industry2 if industry==.
gen occupation= occupation1
replace occupation= occupation2 if occupation==.
drop occupation1 occupation2
label var industry "3 digit industry SIC code"
label var occupation "4 digit occupation code"
gen occupation1= occupation3
replace occupation1=occupation4 if occupation1==.
label var occupation1 "3 digit occupation code, OHS 94+95"

gen jobocccode=.
replace jobocccode=jobocccode1 if jobocccode1>=1 & jobocccode1<=11
replace jobocccode=10 if jobocccode==11

label var jobocccode "Occupation of Employment"
label define jobocccode 1 "Managers" 2 "Professionals" 3 "Semi-professionals, Technicians" 4 "Clerks" 5 "Sales persons and skilled service workers" 6 "Skilled agricultural workers" ///
	7 "Artisans" 8 "Operators" 9 "Elementary, routine workers" 10 "Domestic workers"
label values jobocccode jobocccode

gen wave=1 if year==1994
replace wave=2 if year==1995
replace wave=3 if year==1996
replace wave=4 if year==1997
replace wave=5 if year==1998
replace wave=6 if year==1999


keep /*personid*/ uqnr /*uqnr_orig*/ personnr year wave ea ceweight hweight pweight province urbrur gender age popgroup marstat educhigh educhigh0 enrollment3 employer1 selfformalreg selfvatreg selfpaidemp selfunpaidemp wageformalreg ///
		jobunion earnperiod_wage earnperiod_self  empsalary1 empsalary2  selfempincome1 selfempexpgoods selfempexprenum selfempexpall selfempexpoth imputed salary_impute  impute_gross emp_impute ///
		selfempincome2 deduc1 deducamt1 ///
	empsalcat1 empsalcat2 empsalcat3 selfempinccat1 selfempinccat2  selfempinccat3 selfempinccat4 selfearncatmin selfearncatmax wageearncatmin wageearncatmax empstat1 empstat2 ///
	jobindcode industry  jobocccode occupation occupation1 hrslstwk incpension incdisabgrnt inctstmaint incdepgrnt incfostcrgrnt dwelltype ///
		 watersource toiletmaintype 

*some more cleaning 
replace jobunion =. if jobunion==0 &(year==1994 | year==1995)
replace jobunion=. if jobunion==8888 &year==1999
replace jobunion=9 if jobunion==0
replace jobunion=. if jobunion==8

replace  jobocccode=. if  jobocccode==88
replace  jobocccode=99 if  jobocccode==91 | jobocccode==97

replace hrslstwk=. if hrslstwk==999 | hrslstwk==8888

replace  selfempincome1=. if  selfempincome1==9999999 | selfempincome1==888888 | selfempincome1==0
replace empsalary1=. if empsalary1==0 | empsalary1==888888

numlabel, add
save "$mergefolder\ohssmall.dta", replace

exit
