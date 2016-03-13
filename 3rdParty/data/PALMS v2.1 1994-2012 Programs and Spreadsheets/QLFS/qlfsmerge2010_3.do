*prepares QLFS 2010 wave 3 to append to other QLFSs
*A Kerr, Nov 2012
*Back to the QLFSs after 6 months break!

clear all


local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\LFS 2010_3\Data"

	use "`datafolder'\QLFS 2010_3 Worker_v2.0.dta"
	*need to check this, maybe other is better??
	renvars, lower
	gen psunostr=substr(uqno,1,8)
	destring psunostr, gen(psuno)
		gen wave=33
	
	*Q3 2010 was the quarter where Stats SA accidentally released earnings data with the other data, and then released the LMD. 
	*taking the decision to only incl LMD earnings data, even though QLFS data is better quality! 
	drop q52salaryinterval q53tipscommission q54asalarywage q54brefuse q56salaryinterval q57asalarywage q57brefuse q58salarycategory
	
	*easy for others to reverse this and keep QLFS earnings data
	
		*now here I must put in the income data from the LMD...
	sort uqno personno
	merge 1:1 uqno personno using "`mergefolder'\lmdincomes2010q3.dta"
		
	quietly do "`mergefolder'\QLFSrename2010_3.do"
	quietly do "`mergefolder'\QLFSrename2.do"
	
	gen marstat=1 if marstat3>=1 & marstat3<=2
	replace marstat=2 if marstat3==3
	replace marstat=3 if marstat3==4
	replace marstat=4 if marstat3==5
	replace marstat=9 if marstat3==9
	
	*march 2013 addition, since no q 4.17 in 2009:3 and later waves!
	*probably not directly comparable since no don't know category here. Other is self-employed formal people I think!
	gen formalreg2=.
	replace formalreg2=1 if infempl==1 | infempl==8
	replace formalreg2=2 if infempl==2	
	
	
	quietly do "`mergefolder'\qlfslabelvars.do"	
	quietly do "`mergefolder'\qlfslabeldefine.do"
	quietly do "`mergefolder'\qlfslabelvalues.do"
	
compress
*sort personid
numlabel, add
save "`mergefolder'\qlfs2010_3.dta", replace
