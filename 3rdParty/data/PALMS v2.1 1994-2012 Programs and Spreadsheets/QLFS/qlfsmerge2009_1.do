*prepares QLFS 2009 wave 1 to append to other QLFSs
*A Kerr, April 2012

clear all


local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\LFS 2009_1\Data\STATA"

	use "`datafolder'\LFS 2009_1 Downloaded.dta"
	*need to check this, maybe other is better??
	renvars, lower
	*no psu creation needed, in the data already...
	
	gen wave=27
		
	quietly do "`mergefolder'\QLFSrename2009_1.do"
	quietly do "`mergefolder'\QLFSrename2.do"
	
	gen marstat=1 if marstat3>=1 & marstat3<=2
	replace marstat=2 if marstat3==3
	replace marstat=3 if marstat3==4
	replace marstat=4 if marstat3==5
	replace marstat=9 if marstat3==9
	
	quietly do "`mergefolder'\qlfslabelvars.do"	
	
compress
*sort personid
numlabel, add
save "`mergefolder'\qlfs2009_1.dta", replace
