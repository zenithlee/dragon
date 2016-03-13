* program QLFScreatedofiles.do
* A Kerr April 2012, based on a do file from David Lam, University of Michigan

set more off
clear all
set mem 800m

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"

insheet using "`mergefolder'\LFS master codebook with QLFS.csv"

compress


foreach v in 2008_1 2008_2 2008_3 2008_4  2009_1 2009_2 2009_3 2009_4 2010_1 2010_2 2010_3 2010_4  2011_1 2011_2 2011_3 2011_4 2012_1 {
	gen str60 rename`v'="cap rename "+var`v'+" "+newcode if var`v'~=""
	outfile rename`v' using "`mergefolder'\QLFSrename`v'.do", replace noquote
}

*create do file to do second renaming
gen str60 rename2="cap rename "+ newcode + " " + newcode2 if newcode2~="" & newcode~=""
outfile rename2 using "`mergefolder'\QLFSrename2.do", replace noquote

*create a single do file for variable labels
gen str150 dofilelabvar="cap label var "+ newcode2 + " " + `" ""'+desc+ `"""'
outfile dofilelabvar using "`mergefolder'\qlfslabelvars.do", replace noquote




clear
insheet using "`mergefolder'\QLFS master value labels.csv"
compress

gen str10 labnumstr=string(vallabnum)
gen str150 dofilelabdef="cap label define "+newcode2+" "+labnumstr+ `" ""' + vallabel + `"""' +", modify" if vallabnum~=.
compress
outfile dofilelabdef using "`mergefolder'\qlfslabeldefine.do" if vallabnum~=. , replace noquote

bysort id: gen count=_n
gen str150 dofilelabval="cap label values "+ newcode2 + " " + newcode2 if vallabnum~=. & count==1
compress
outfile dofilelabval using "`mergefolder'\qlfslabelvalues.do" if vallabnum~=. & count==1 , replace noquote


exit

