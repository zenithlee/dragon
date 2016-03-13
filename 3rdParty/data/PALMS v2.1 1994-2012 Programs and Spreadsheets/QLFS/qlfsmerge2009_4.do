*prepares QLFS 2009 wave 4 to append to other QLFSs
*A Kerr, April 2012

clear all


local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\LFS 2009_4\Data"

	use "`datafolder'\QLFS 2009_4 Worker_v2.0.dta"
	*need to check this, maybe other is better??
	renvars, lower
	gen psunostr=substr(uqno,1,8)
	destring psunostr, gen(psuno)
		gen wave=30
		
		
	quietly do "`mergefolder'\QLFSrename2009_4.do"
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
	
compress
*sort personid
numlabel, add
save "`mergefolder'\qlfs2009_4.dta", replace
