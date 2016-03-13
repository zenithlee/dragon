* program LFScreatedofiles.do
* uses LFS master codebook spreadsheet to create do files 
*    for renaming variables in each year to consistent names and labeling variables and values
* D. Lam, 8 Feb 2007, updated 6 June 2008, updated 10 Jan 2009 to include 2007_2
* Modified by Andrew Kerr, May 2011

set more off
clear
set mem 800m

local mergefolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge"

*create a separate do file to rename variables in each LFS wave
*odbc load, dsn("Excel Files;DBQ=W:\davidl\southafrica\LabourForceSurvey\LFSMasterCodebook\LFS master codebook.xls") table("master$") clear 
*odbc load, dsn("Excel Files;DBQ=C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge\LFS master codebook.xlsx") table("master$") clear 
insheet using "`mergefolder'\LFS master codebook.csv"

compress


foreach v in 2000_1 2000_2 2001_1 2001_2 2002_1 2002_2 2003_1 2003_2 2004_1 2004_2 2005_1 2005_2 2006_1 2006_2 2007_1 2007_2 {
	gen str60 rename`v'="cap rename "+var`v'+" "+newcode if var`v'~=""
	outfile rename`v' using "`mergefolder'\LFSrename`v'.do", replace noquote
}

*create do file to do second renaming
gen str60 rename2="cap rename "+ newcode + " " + newcode2 if newcode2~="" & newcode~=""
outfile rename2 using "`mergefolder'\LFSrename2.do", replace noquote

*create a single do file for variable labels
gen str150 dofilelabvar="cap label var "+ newcode2 + " " + `" ""'+desc+ `"""'
outfile dofilelabvar using "`mergefolder'\lfslabelvars.do", replace noquote

*now create do files for value labels
*odbc load, dsn("Excel Files;DBQ=W:\davidl\southafrica\LabourForceSurvey\LFSMasterCodebook\LFS Master value labels.xls") table("lfslabels$") clear 
clear
insheet using "`mergefolder'\LFS Master value labels.csv"
compress


gen str10 labnumstr=string(vallabnum)
gen str150 dofilelabdef="cap label define "+newcode2+" "+labnumstr+ `" ""' + vallabel + `"""' +", modify" if vallabnum~=.
compress
outfile dofilelabdef using "`mergefolder'\lfslabeldefine.do" if vallabnum~=. , replace noquote

bysort id: gen count=_n
gen str150 dofilelabval="cap label values "+ newcode2 + " " + newcode2 if vallabnum~=. & count==1
compress
outfile dofilelabval using "`mergefolder'\lfslabelvalues.do" if vallabnum~=. & count==1 , replace noquote




