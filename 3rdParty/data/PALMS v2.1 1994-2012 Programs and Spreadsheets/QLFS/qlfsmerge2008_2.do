*prepares QLFS 2008 wave 2 to append to other QLFSs
*A Kerr, April 2012

clear all


local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"
local datafolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\LFS 2008_2 v2\Data\STATA"

	use "`datafolder'\LFS 2008_2 v2.dta"
	renvars, lower

	gen psunostr=substr(uqno,1,8)
	destring psunostr, gen(psuno)

	gen wave=24
	
	
	quietly do "`mergefolder'\QLFSrename2008_2.do"
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
save "`mergefolder'\qlfs2008_2.dta", replace
