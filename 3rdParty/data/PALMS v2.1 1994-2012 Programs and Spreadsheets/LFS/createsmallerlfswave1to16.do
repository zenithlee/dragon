*Creating a smaller dataset from 16 LFSs with a limited number of variables
*Andrew Kerr June 2011

clear all
set mem 1150m
set more off

global mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge"

use "$mergefolder\lfswaves1to16.dta"

keep  wave year round personid hhid uqnr_orig personnr gender age popgroup inperson weight ceweight weighthh psu dc urbrur province inperson ///
		whynotwork  willacceptwork searchwork searchhow searchagency searchwkplace searchad searchfriends searchpermit searchtraining searchstreet searchother searchunsure ///
		/*lstwk* */ empstat1 empstat2 employer	empsector jobbusreg numworkers jobsector jobstartyear jobstartmonth jobcontract ///
		/*sup* */ ///
		jobsalary jobsalperiod jobsalcat  ///
		educhigh fullpart enrolled ///
		jobocccode jobindcode occupation industry empsector businesstype2 businesstype1 totalwork_hrslstwk ///
		 incpension incdisabgrnt inctstmaint incdepgrnt incfostcrgrnt hhpension hhdisablegrant hhchildsuppgrant hhcaredependgrant hhfostercaregrant ///
		dwelltype toimaintype  watersource1 watersource3 watersource3 fuelcook fuelheat fuellight ///
		marstat ///
		jobunion    
		
* now do re-coding of missings to . instead of 9 or 99 or 999 or 99999999
*I  leave the categorical variables with original code..
	replace gender=. if gender==9
	replace age=. if age==999
	replace popgroup=. if popgroup==9
	replace inperson=. if inperson==9


	label var occupation "Occupation, 4 digit code"
	label var industry "Industry, 3 digit code"
	
	

	replace totalwork_hrslstwk=. if totalwork_hrslstwk==999 | totalwork_hrslstwk==888 | (totalwork_hrslstwk>168 & totalwork_hrslstwk<888)
	
	replace jobsalary=. if jobsalary==9999999 | jobsalary==8888888
	compress
	label data "South Africa Labour Force Surveys, only incl a subset of variables"
	save "$mergefolder\lfswaves1to16small.dta", replace
	

	
	*this code below creates a helpful dataset (and excel file) of the variables and their labels and shows which are defined in what waves..
	descsave, saving("$mergefolder\lfsdesc.dta", replace) 
	use "$mergefolder\lfsdesc.dta"
	rename name newcode2
	sort newcode2
	save "$mergefolder\lfsdesc.dta", replace
	
	clear
	insheet using "C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge\LFS master codebook.csv"
	duplicates tag newcode2, gen(tag)
	drop if tag==1 & newcode!=""
	drop tag
	sort newcode2
	
	merge newcode2 using "$mergefolder\lfsdesc.dta"
	
	drop type format order vallab notes newcode newid id varlab var2008_1 var2008_2
	*dropping 2008 because thats QLFS and am not incl that at the moment..
	drop if _merge==1
	drop _merge
	outsheet using "$mergefolder\lfsvardesc.csv", comma replace
exit


use "C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge\lfswaves1to16small.dta", replace
