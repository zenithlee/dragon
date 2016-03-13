*prepares QLFS 2009 wave 3 to append to other QLFSs
*A Kerr, April 2012

clear all


local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\LFS 2009_3\Data\STATA"

	use "`datafolder'\LFS 2009_3 Downloaded.dta"
	*need to check this, maybe other is better??
	renvars, lower
	*no psu creation needed, in the data already...
	destring psuno, replace
		gen wave=29
		
		
	quietly do "`mergefolder'\QLFSrename2009_3.do"
	quietly do "`mergefolder'\QLFSrename2.do"
	
	gen marstat=1 if marstat3>=1 & marstat3<=2
	replace marstat=2 if marstat3==3
	replace marstat=3 if marstat3==4
	replace marstat=4 if marstat3==5
	replace marstat=9 if marstat3==9
	
	quietly do "`mergefolder'\qlfslabelvars.do"	
	
	*march 2013 addition, since no q 4.17 in 2009:3 and later waves!
	*probably not directly comparable since no don't know category here. Other is self-employed formal people I think!
	gen formalreg2=.
	replace formalreg2=1 if infempl==1 | infempl==8
	replace formalreg2=2 if infempl==2
	
compress
*sort personid
numlabel, add
save "`mergefolder'\qlfs2009_3.dta", replace
