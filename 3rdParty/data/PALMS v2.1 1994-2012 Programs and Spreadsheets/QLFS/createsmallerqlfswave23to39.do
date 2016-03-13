
*create a smaller version of the qlfss for eventual incorporation into extended PALMS
* Andrew Kerr April 2012

clear all
set more off

global mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"

use "$mergefolder\qlfswaves23to39.dta"


	keep  wave uqnr personnr popgroup province psu weight  gender age marstat marstat3 educhigh2  jobindcode jobocccode occupation industry status /* sector1 sector2*/ totalhrswrklastwk_onejob ///
	totalhrswrklastwk_alljo jobsector2 formalreg2 businesstype3 employer2 numworkers2 jobstartyear jobstartmonth jobcontract2 ///
	jobsalperiod tipscomm monthlyjobsalary salaryrefusedontknow selfemppayperiod2 monthlyjobearn earningsrefusedontknow earningscat ///
	year inperson 
	
	order uqnr personnr year wave province psu weight popgroup gender age marstat3 educhigh2  status employer2 jobindcode jobocccode businesstype3 totalhrswrklastwk_onejob ///
	totalhrswrklastwk_alljo jobsalperiod tipscomm monthlyjobsalary salaryrefusedontknow selfemppayperiod2 monthlyjobearn earningsrefusedontknow earningscat
	
	save "$mergefolder\qlfswaves23to39small.dta", replace

	*main task now for 2013 for me is to check labels and var names and then put in weights and incomes from AM and FP.
	
	*so which vars need to be put in here because they're in PALMS and QLFS but not in my qlfs above:
	*geotype comes back in 2011 and can be used for rural/urban...Is it comparable to PALMS urbrur var?

	*the obv one is that we are missing all the earnings data, but this is coming from Alex via FP!
	
	*add some vars to PALMS? JA- the point is that we left out some stuff from LFS because it wasn't in OHSs. But now that we have QLFSs we probably want to add some of this stuff into PALMS!
	*to do this I should label things clearly to say which surveys they were or were not asked in, to prevent confusion!
	*(perhaps relabel in the final PALMS do file putting together OHS, LFS and QLFS?)
		*QLFS has LOTS of questions on search and unemployment but that was a part of the LFS that I didn't take much from for PALMS! 
	*EG- time unemployed, reason for not working, ever worked, prev occ/ind
	*next time- continue checking the QLFS for things I should add in from LFS and QLFS!
	*other vars to maybe add into PALMS from lfs and qlfs:

	*q41multiplejobs
	*tenure- only for employees in LFS but for all in QLFS. 
	*q411contracttype 
	
	*whether the firm is registered company- LFS, not QLFS but there is a direct question asking if business is formal or informal. 
	*registered for VAT- LFS, QLFS- but only self-employed in QLFS

	
	****DONE****
	*status1 and status2, to be created from status variable. DONE
	*infempl can become a formalreg var maybe? DONE
	*check on qlfs hrswrk var. Is it comparable? FP made notes on this! DONE, made comparable!
	*qlfs sector 1 and sector 2 are really just aggregation variabls, not that useful, could drop...
		*Whether the person is responding in person or not?
		*firm size- lfs and qlfs question is not quite the same!
