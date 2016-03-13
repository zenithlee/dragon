*use the QLFS to create a PALMS consistent dataset
*November 2012
* A Kerr

clear all
set more off

	global mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"
	use "$mergefolder\qlfswaves23to39small.dta", replace
	
	*add together hours worked for those with one job and those few with more than one job to make a PALMS consistent variable...
	replace totalhrswrklastwk_onejob=. if totalhrswrklastwk_onejob==8888
	replace totalhrswrklastwk_alljo=. if totalhrswrklastwk_alljo==8888
	replace totalhrswrklastwk_onejob=. if totalhrswrklastwk_onejob==888
	replace totalhrswrklastwk_alljo=. if totalhrswrklastwk_alljo==888
	replace totalhrswrklastwk_onejob=. if totalhrswrklastwk_onejob==999
	replace totalhrswrklastwk_alljo=. if totalhrswrklastwk_alljo==999
	replace totalhrswrklastwk_alljo=. if totalhrswrklastwk_alljo==88
	
	gen hrslstwk=totalhrswrklastwk_onejob if totalhrswrklastwk_alljo==.
	replace hrslstwk=totalhrswrklastwk_alljo if totalhrswrklastwk_alljo!=.
	label var hrslstwk "Total Hours worked in last week"
	drop totalhrswrklastwk_onejob totalhrswrklastwk_alljo
	
	*create the PALMS empstat1 and 2 variables
	*the QLFS status var is never missing but equals zero for all those under 15, except in the first 2 waves, so must change this to be consistent!
	gen empstat1=. 
	replace empstat1=0 if status==4 | status==3
	replace empstat1=1 if status==1
	replace empstat1=2 if status==2

	gen empstat2=.
	replace empstat2=0 if status==4
	replace empstat2=1 if status==1
	replace empstat2=2 if status==2 | status==3
	*looks like there has been some shifting around of the way these guys are defined (seen by comparing PALMS and QLFS tabs of empstat2)
	
	replace employer2=8 if employer2==0
	
	drop status
	drop marstat3
	
	label var empstat1 "Employment status, official"
	label var empstat2 "Employment status, expanded"
	
	*creating a formalreg var comparable to LFS formalreg var. Now done earlier in 2009 q3 and later waves where no jobsector2 variable from q 4.17 (for some reason SSA left it out!)
	*gen formalreg2=.
	replace formalreg2=1 if jobsector2==1
	replace formalreg2=2 if jobsector2==2
	replace formalreg2=3 if jobsector2==3
	replace formalreg2=4 if jobsector2==4
	replace formalreg2=8 if jobsector2==8
	replace formalreg2=8 if jobsector2==0
	label var formalreg "QLFS question about whether business is formal"
	label define formalreg2 1"Formal employment" 2"Informal Employment" 3"Private Household" 4"Don't Know"  8"Not Applicable" 
	label values formalreg formalreg2
	drop jobsector2
	
	replace occupation=9999 if occupation==0
	replace occupation=9999 if occupation==9998
	*how to change one or only a few of the value labels???! cut out all of them?
	label drop Q42OCCUPATION
	
	replace industry=999 if industry==0
	replace industry=999 if industry==998
	label drop Q43INDUSTRY
	
	label var occupation "Occupation, 4 digit code"
	label var industry "Industry, 3 digit code"
	
	replace inperson=8 if inperson==0


	gen educhigh=.
	replace educhigh=educhigh2 if educhigh2<5
	replace educhigh=6 if educhigh2==5
	replace educhigh=7 if educhigh2==6
	replace educhigh=8 if educhigh2==7
	replace educhigh=9 if educhigh2==8
	replace educhigh=10 if educhigh2==9
	replace educhigh=11 if educhigh2==10
	replace educhigh=12 if educhigh2==11 | educhigh2==14
	replace educhigh=13 if educhigh2==12 | educhigh2==15
	replace educhigh=14 if educhigh2==13 | educhigh2==16
	replace educhigh=15 if educhigh2==17 | educhigh2==18 
	replace educhigh=16 if educhigh2==19 | educhigh2==20
	replace educhigh=17 if educhigh2==21 | educhigh2==22
	replace educhigh=18 if educhigh2==23 | educhigh2==24
	replace educhigh=20 if educhigh2==25
	replace educhigh=21 if educhigh2==26

	replace jobindcode=. if jobindcode==0 | jobindcode==88
	replace jobocccode=. if jobocccode==0 | jobocccode==88
	
	replace businesstype3=8 if businesstype3==0
	
	gen publicemp=.
	replace publicemp=0 if businesstype3==3| businesstype3==4 | businesstype3==5
	replace publicemp=1 if businesstype3==1| businesstype3==2
	
	replace numworkers2=88 if numworkers2==0 
	
	replace jobstartyear=8888 if jobstartyear==88888
	replace  jobstartmonth=88 if  jobstartmonth==0
	
	replace jobcontract2=8 if jobcontract2==0
	gen writtencontract=.
	replace writtencontract=0 if jobcontract2==2
	replace writtencontract=1 if jobcontract2==1
		label define writtencontract 0"No" 1"Yes" 
	label values writtencontract writtencontract
	
	
*must include label for don't know that comes in qlfs
	
	*some basic renaming
	rename psu ea
	rename weight pweight
	
	save "$mergefolder\palmsconsistentqlfs.dta", replace
