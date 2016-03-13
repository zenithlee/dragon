*Master do-file setting out how the PALMS dataset is created.
*the LFSs are coded using do files from David Lam at the University of Michigan, modified slightly.

*this master do file is, at the moment, not going to run for other researchers without changing the code listing the location of mergefolder, and sometimes datafolder as well, ///
*at the top of EACH of the do files listed below.
*in addition to using the data files for each survey that are released by Stats SA and that can be found on the DataFirst website, the do files below also use the Cross Entropy Weights///
*created by Nicola Branson and Martin Wittenberg. These can be obtained by requesting access to the LFS sept 2007 at http://www.datafirst.uct.ac.za/catalogue3/index.php/catalog/139
*Andrew Kerr, January 2013.

clear all
set mem 1150m
set more off

local ohsfolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSdata\OHSmerge"
local lfsfolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge"
local lfsfolder2="C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata"
local lfsohsfolder="C:\Users\admin\Desktop\Andy\DataFirst\main project\OHSlfs"
local qlfsfolder= "C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS\QLFSmerge"
local qlfsfolder2= "C:\Users\admin\Desktop\Andy\DataFirst\main project\Quarterly LFS"
local palmsfolder= "C:\Users\admin\Desktop\Andy\DataFirst\main project\PALMS"

*****first prepare OHSs*****

	*the following do file requires the csv files "OHS Master codebook.csv" and "OHS Master value labels.csv" to be in the ohsfolder to run:
	do "`ohsfolder'\OHScreatedofiles.do"

	*these do files prepare each wave of the OHSs, renaming and creating some new variables, as well as giving value labels. 
	*the do files used in each of the do files below are created when running "`ohsfolder'\OHScreatedofiles.do" 
	do "`ohsfolder'\ohsmerge1994.do"
	do "`ohsfolder'\ohsmerge1995.do"
	do "`ohsfolder'\ohsmerge1996.do"
	do "`ohsfolder'\ohsmerge1997.do"
	do "`ohsfolder'\ohsmerge1998.do"
	do "`ohsfolder'\ohsmerge1999.do"
	
	*the following do file creates some new variables consistent with the LFSs and does a little cleaning at the end. 
	*It also keeps only the variables that are consistently named and have value labels.
	do "`ohsfolder'\ohsappend.do"

**********then prepare LFSs*************

	*the following do file requires the csv files "LFS master codebook.csv" and "LFS Master value labels.csv" to be in the lfsfolder to run:
	do "`lfsfolder'\LFScreatedofiles.do"

	*the following do files prepare each wave of the LFSs, renaming and creating some new variables, as well as giving value labels 
		*the do files used in each of the do files below are created when running "`lfsfolder'\LFScreatedofiles.do"
	do "`lfsfolder'\lfsmerge2000_1.do"
	do "`lfsfolder'\lfsmerge2000_2.do"
	do "`lfsfolder'\lfsmerge2001_1.do"	
	do "`lfsfolder'\lfsmerge2001_2.do"
	do "`lfsfolder'\lfsmerge2002_1.do"
	do "`lfsfolder'\lfsmerge2002_2.do"
	do "`lfsfolder'\lfsmerge2003_1.do"
	do "`lfsfolder'\lfsmerge2003_2.do"
	do "`lfsfolder'\lfsmerge2004_1.do"
	do "`lfsfolder'\lfsmerge2004_2.do"
	do "`lfsfolder'\lfsmerge2005_1.do"
	do "`lfsfolder'\lfsmerge2005_2.do"
	do "`lfsfolder'\lfsmerge2006_1.do"
	do "`lfsfolder'\lfsmerge2006_2.do"
	do "`lfsfolder'\lfsmerge2007_1.do"
	do "`lfsfolder'\lfsmerge2007_2.do"
	
	*the following do files append the LFSs together and create a smaller version that is used for the PALMS dataset by only keeping some variables
	do "`lfsfolder'\lfsappend.do"
	*(at this stage the LFS is VERY large, and researchers may wish to not drop much of this data, which WAS done to create PALMS)
	do "`lfsfolder2'\createsmallerlfswave1to16.do"
	*the following do file creates variables consistent with the OHSs:
	do "`lfsfolder2'\createohsconsistentlfs.do"
	
*the following do file puts OHS and LFS together, doing some final cleaning and renaming:
	do "`lfsohsfolder'\appendlfstoohs.do"
	
	*************Modify Labour Market Dynamics 2010 and 2011 to include with the QLFS***************
	/*do files not complete for PALMSv2 (yet)
	do "lmd 2010 incomes preparation.do"
	do "lmd 2011 incomes preparation.do"
	*/
	******************then prepapre QLFS****************
	do "`qlfsfolder'\qlfsmerge2008_1.do"
	do "`qlfsfolder'\qlfsmerge2008_2.do"
	do "`qlfsfolder'\qlfsmerge2008_3.do"
	do "`qlfsfolder'\qlfsmerge2008_4.do"
	do "`qlfsfolder'\qlfsmerge2009_1.do"
	do "`qlfsfolder'\qlfsmerge2009_2.do"
	do "`qlfsfolder'\qlfsmerge2009_3.do"
	do "`qlfsfolder'\qlfsmerge2009_4.do"
	do "`qlfsfolder'\qlfsmerge2010_1.do"
	do "`qlfsfolder'\qlfsmerge2010_2.do"
	do "`qlfsfolder'\qlfsmerge2010_3.do"
	do "`qlfsfolder'\qlfsmerge2010_4.do"
	do "`qlfsfolder'\qlfsmerge2011_1.do"
	do "`qlfsfolder'\qlfsmerge2011_2.do"
	do "`qlfsfolder'\qlfsmerge2011_3.do"
	do "`qlfsfolder'\qlfsmerge2011_4.do"
	do "`qlfsfolder'\qlfsmerge2012_1.do"
	
	do "`qlfsfolder'\qlfsappend.do"
	
	do "`qlfsfolder2'\createsmallerqlfs.do"
	do "`qlfsfolder2'\createpalmsconsistentqlfs.do"
	
*the following do file appends QLFS to the combined OHS and LFS data to create PALMS.
	do "`palmsfolder'\appendqlfstoohslfs.do"
	
*the following do files create the consistent income variables for PALMSv2:
	do "`palmsfolder'\PALMSwages_create.do"
	do "`palmsfolder'\PALMSwages_create2.do"
	do "`palmsfolder'\PALMSwages_create3.do"
	do "`palmsfolder'\PALMSfinal_create.do"

	
