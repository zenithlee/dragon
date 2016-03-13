*prepares QLFS 2012 wave 1 to append to other QLFSs
*A Kerr, Jan 2013


clear all


local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\LFS 2012_1\Data"

	use "`datafolder'\QLFS 2012_1 Worker_v1.0.dta"
	*need to check this, maybe other is better??
	renvars, lower
	gen psunostr=substr(uqno,1,8)
	destring psunostr, gen(psuno)
		gen wave=39
		
		
	quietly do "`mergefolder'\QLFSrename2012_1.do"
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
save "`mergefolder'\qlfs2012_1.dta", replace
