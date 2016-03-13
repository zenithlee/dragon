* program OHScreatedofiles.do
* uses OHS master codebook spreadsheet to create do files ///
*    for renaming variables in each year to consistent names and labeling variables and values
*based on a version for the LFSs created by David Lam, University of Michigan
*  Andrew Kerr, June 2011

set more off
clear
set mem 800m

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHSmerge"

*create a separate do file to rename variables in each OHS wave

insheet using "`mergefolder'\OHS Master codebook.csv"

compress


foreach v in 1994 1995 1996 1997 1998 1999 {
	gen str60 rename`v'="cap rename "+var`v'+" "+newcode if var`v'~=""
	outfile rename`v' using "`mergefolder'\OHSrename`v'.do", replace noquote
}

*create do file to do second renaming
gen str60 rename2="cap rename "+ newcode + " " + newcode2 if newcode2~="" & newcode~=""
outfile rename2 using "`mergefolder'\OHSrename2.do", replace noquote



*create a single do file for variable labels
gen str150 dofilelabvar="cap label var "+ newcode2 + " " + `" ""'+desc+ `"""'
outfile dofilelabvar using "`mergefolder'\ohslabelvars.do", replace noquote




*now create do files for value labels 
clear
insheet using "`mergefolder'\OHS Master value labels.csv"
compress


gen str10 labnumstr=string(vallabnum)
gen str150 dofilelabdef="cap label define "+newcode2+" "+labnumstr+ `" ""' + vallabel + `"""' +", modify" if vallabnum~=.
compress
outfile dofilelabdef using "`mergefolder'\ohslabeldefine.do" if vallabnum~=. , replace noquote

bysort id: gen count=_n
gen str150 dofilelabval="cap label values "+ newcode2 + " " + newcode2 if vallabnum~=. & count==1
compress
outfile dofilelabval using "`mergefolder'\ohslabelvalues.do" if vallabnum~=. & count==1 , replace noquote

exit


