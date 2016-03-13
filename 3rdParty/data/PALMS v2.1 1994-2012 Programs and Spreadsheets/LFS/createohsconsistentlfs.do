*this do file uses the smaller lfs appended all wave data and creates some consistent vars across LFS and OHS to then append to OHS

clear
set mem 350m
set more off
use "C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge\lfswaves1to16small.dta", replace

*rename hhid uqnr

drop hhid personid
*June 2013: hhid and personid dropped because created off a non-orig hhid in later LFSs and we have decided to do away with this non-orig hhid and just keep the orig hhid in string form

*label var uqnr_orig "household ID from original data(uqnr variable shortened by 1 digit in later LFSs)"
rename uqnr_orig uqnr
label var uqnr "household id variable, as in original data"
rename psu ea

rename weight pweight 
rename weighthh hweight
label var pweight "Stats SA person weight"
label var hweight "Stats SA household weight"

gen dcnum=1 if dc=="DC1"
forvalues num= 1/44{
	replace dcnum=`num' if dc=="DC`num'"
}
	replace dcnum=45 if dc=="CBDC1"
	replace dcnum=46 if dc=="CBDC2"
	replace dcnum=47 if dc=="CBDC3"
    replace dcnum=48 if dc=="CBDC4"
	replace dcnum=49 if dc=="CBDC8"
	replace dcnum=50 if dc=="Cape Town"
	replace dcnum=51 if dc=="Durban"
	replace dcnum=52 if dc=="East Rand"
	replace dcnum=53 if dc=="Johannesburg"
	replace dcnum=54 if dc=="Port Elizabeth"
	replace dcnum=55 if dc=="Pretoria"

 label define dc 1"West Coast" 2"Boland" 3"Overberg" 4"Eden" 5"Central Karoo" 6"Namakwa" 7"Karoo" 8"Siyanda" 9"Frances Baard" 10"Cacadu" 12"Amatole" 13"Chris Hani" 14"Ukhahlamba" ///
 15"O.R.Tambo" 16"Xhariep" 17"Motheo" 18"Lejweleputswa" 19"Thabo Mofutsanyane" 20"Northern Free State" 21"Ugu" 22"UMgungundlovu" 23"Uthukela" 24"Umzinyathi" 25"Amajuba" ///
 26"Zululand" 27"Umkhanyakude" 28"Uthungulu" 29"iLembe" 30"Gert Sibande" 31"Nkangala" 32"Ehlanzeni" 33"Mopani" 34"Vhembe" 35"Capricorn" 36"Waterberg" 37"Bojanala" 38"Central" ///
 39"Bophirima" 40"Southern" 42"Sedibeng" 43"Sisonke" 44"Alfred Nzo" 45"Kgalagadi" 46"Metsweding" 47"Sekhukhune" 48"Bohlabela" 49"West Rand" 50"City of Cape Town" ///
 51"Ethekwini" 52"Ekurhuleni/East Rand" 53"City of Johannesburg" 54"Nelson Mandela Bay" 55"City of Tshwane/Pretoria"
label values dcnum  dc
rename dc dcstring
rename dcnum dc
label var dc "District Council/Municipality"

rename totalwork_hrslstwk hrslstwk
rename jobsector formalreg
label var formalreg "LFS variable for wage/self/domestic: business is formal, registered"

gen earnperiod=.
replace earnperiod =2 if jobsalperiod==1
replace earnperiod =3 if jobsalperiod==2
replace earnperiod =4 if jobsalperiod==3
label var earnperiod "Earnings Period"
label define earnperiod 1 "Per day" 2 "Per week" 3 "Per month" 4 "Per year"
label values earnperiod  earnperiod 

gen publicemp=.
replace publicemp=0 if businesstype1==5 | businesstype1==6 | businesstype1==7 | businesstype2==5 | businesstype2==6 | businesstype2==7 | businesstype2==8 | businesstype2==9
replace publicemp=1 if businesstype1==1 | businesstype1==2 | businesstype1==3  | businesstype1==4 | businesstype2==1 | businesstype2==2 | businesstype2==3  | businesstype2==4
label var publicemp "Dummy: Employed by government or public enterprise"

rename dwelltype dwelltype1
gen dwelltype =.
replace dwelltype=1 if dwelltype1==1
replace dwelltype=2 if dwelltype1==2
replace dwelltype=3 if dwelltype1==3
replace dwelltype=4 if dwelltype1==4
replace dwelltype=5 if dwelltype1==7
replace dwelltype=6 if dwelltype1==8
replace dwelltype=7 if dwelltype1==5 | dwelltype1==6 | dwelltype1==9 | dwelltype1==10 | dwelltype1==11

label var dwelltype "Type of Dwelling of Household"
label drop dwelltype
label define dwelltype 1 "Dwelling/house or brick structure on a separate stand or yard or on farm" 2 "Traditional dwelling/hut/structure made of traditional materials" ///
3 "Flat or apartment in a block of flats" 4 "Town/cluster/semi-detached house (simplex, duplex or triplex)" 5 "Informal dwelling/shack in backyard" ///
6 "Informal dwelling/Shack not in backyard" 7 "Other (includes caravan, retirement village, room/flatlet, Dwelling/House/Flat/Room in backyard)"
label values dwelltype dwelltype

gen watersource=.
replace watersource=1 if watersource1==1 | watersource3==1
replace watersource=2 if watersource1==2 | watersource3==2
replace watersource=3 if watersource1==3 | watersource3==6
replace watersource=4 if watersource1==4 | watersource3==7
replace watersource=5 if watersource1==5 | watersource3==4
replace watersource=6 if watersource1==6 | watersource3==8
replace watersource=7 if watersource1==7 | watersource3==5
replace watersource=8 if watersource1==8 | watersource3==9
replace watersource=9 if watersource1==9 | watersource3==10
replace watersource=10 if watersource1==10 | watersource3==11
replace watersource=11 if watersource1==11 | watersource3==12
replace watersource=12 if watersource1==12 | watersource3==13 | watersource3==3

label var watersource "Household's source of water"
label define watersource 1 "Piped (Tap) Water in dwelling" 2 "Piped (Tap) Water on site or in yard" 3 "Public tap" 4 "Water-Carrier/Tanker" 5 "Borehole on site" ///
			6 "Borehole off site/communal" 7 "Rain-water tank on site" 8 "Flowing water/stream river" 9 "Dam/Pool/Stagnant water" 10 "Well" 11 "Spring" 12 "Other" 
label values  watersource watersource

rename toimaintype toimaintype1
*label values toimaintype toimaintype1
*this label change  above not working!!
label drop toimaintype

gen toiletmaintype=.
replace toiletmaintype=1 if toimaintype1==11 | toimaintype1==11
replace toiletmaintype=2 if toimaintype1==12 | toimaintype1==22
replace toiletmaintype=3 if toimaintype1==13 | toimaintype1==23
replace toiletmaintype=4 if toimaintype1==32
replace toiletmaintype=5 if toimaintype1==33
replace toiletmaintype=6 if toimaintype1==42
replace toiletmaintype=7 if toimaintype1==43
replace toiletmaintype=8 if toimaintype1==52
replace toiletmaintype=9 if toimaintype1==53
replace toiletmaintype=10 if toimaintype1==62
replace toiletmaintype=11 if toimaintype1==63
replace toiletmaintype=13 if toimaintype1==73

label var toiletmaintype "Household's Main toilet"
*toilet options: 
label define toiletmaintype 1 "Flush toilet in dwelling" 2 "Flush toilet on site" 3"Flush toilet off-site" 4"Chemical toilet on-site" 5"Chemical toilet off-site" ///
6 "Pit latrine with ventilation pipe, on site" 7 "Pit latrine with ventilation pipe, off site" 8 "Pit latrine without ventilation pipe, on-site" ///
9 "Pit latrine without ventilation pipe, off-site" 10 "Bucket toilet on-site" 11 "Bucket toilet off-site" 12 "Other" 13 "None"

label values toiletmaintype toiletmaintype

rename educhigh educhigh1
label var  educhigh1 "Highest level of Education, LFS only"
label copy educhigh educhigh1
label values educhigh1 educhigh1

gen educhigh=.
replace educhigh=educhigh1 if educhigh1<5
replace educhigh=6 if educhigh1==5
replace educhigh=7 if educhigh1==6
replace educhigh=8 if educhigh1==7
replace educhigh=9 if educhigh1==8
replace educhigh=10 if educhigh1==9
replace educhigh=11 if educhigh1==10
replace educhigh=12 if educhigh1==11 | educhigh1==14
replace educhigh=13 if educhigh1==12 | educhigh1==15
replace educhigh=14 if educhigh1==13 | educhigh1==16
replace educhigh=15 if educhigh1==17 
replace educhigh=16 if educhigh1==18 
replace educhigh=17 if educhigh1==19 
replace educhigh=18 if educhigh1==20
replace educhigh=20 if educhigh1==21 

capture label drop educhigh

label var educhigh "Highest level of education"
label define educhigh 0 "No schooling" 1 "Grade 0" 2 "Grade 1"  3 "Grade 2" 4 "Grade 3" 5 "Grade 1/grade2/grade 3" 6 "Grade 4" 7 "Grade 5" 8"Grade 6" 9 "Grade 7" 10 "Grade 8" 11 "Grade 9" ///
	12 "Grade 10/NTC I"	13 "Grade 11/NTC II" 14 "Grade 12/NTC III" 15 "Certificate or diploma with less than grade 12" 16 "Certificate or diploma with grade 12" ///
	17 "Undergraduate degree" 18 "Post-graduate degree/diploma" 19 "Degree (undergrad or postgrad)" 20 "Other"
label values educhigh educhigh



gen enrollment3=.
replace enrollment3=1 if fullpart==1
replace enrollment3=2 if fullpart==2
replace enrollment3=3 if fullpart==8 
replace enrollment3=9 if fullpart==9
replace enrollment3=3 if fullpart==9 &(wave==8 | wave==10 | wave==15)
label define enrollment3 1"Full-Time" 2"Part-time" 3 "Not enrolled" 9 "Unspecified"
label values enrollment3  enrollment3
label var enrollment3 "Educational enrollment status"

label var enrolled "More detailed enrollment status variable, for LFS only"


gen earncatmin=.
gen earncatmax=. 
replace earncatmin=1 if jobsalcat==2
replace earncatmin=2401 if jobsalcat==3
replace earncatmin=6001 if jobsalcat==4
replace earncatmin=12001 if jobsalcat==5
replace earncatmin=18001 if jobsalcat==6
replace earncatmin=30001 if jobsalcat==7
replace earncatmin=42001 if jobsalcat==8
replace earncatmin=54001 if jobsalcat==9
replace earncatmin=72001 if jobsalcat==10
replace earncatmin=96001 if jobsalcat==11
replace earncatmin=132001 if jobsalcat==12
replace earncatmin=192001 if jobsalcat==13
replace earncatmin=360001 if jobsalcat==14

replace earncatmax=2400 if jobsalcat==2 
replace earncatmax=6000 if jobsalcat==3 
replace earncatmax=12000 if jobsalcat==4
replace earncatmax=18000 if jobsalcat==5
replace earncatmax=30000 if jobsalcat==6
replace earncatmax=42000 if jobsalcat==7
replace earncatmax=54000 if jobsalcat==8
replace earncatmax=72000 if jobsalcat==9
replace earncatmax=96000 if jobsalcat==10 
replace earncatmax=132000 if jobsalcat==11 
replace earncatmax=192000 if jobsalcat==12 
replace earncatmax=360000 if jobsalcat==13 
replace earncatmax=. if jobsalcat==14 

label var earncatmin "Minimum of earnings category, adjusted to annual figure, LFS only"
label var earncatmax "Maximum of earnings category, adjusted to annual figure, LFS only"

replace jobindcode=. if jobindcode==88
replace jobindcode=99 if jobindcode==11 | jobindcode==12 | jobindcode==90
label drop jobindcode
label define jobindcode 1 "Agriculture, hunting, forestry and fishing" 2 "Mining and quarrying" 3 "Manufacturing" 4 "Utilities" 5 "Construction" 6 "Trade" 7 "Transport" ///
8 "Finance" 9 "Services" 10 "Domestic Services"
label values jobindcode  jobindcode 

replace  jobocccode=. if  jobocccode==88
replace  jobocccode=99 if  jobocccode==91 | jobocccode==97


replace jobunion=. if jobunion==8



numlabel, add
rename wave waveold
gen wave= waveold+6
label var wave "Survey wave, OHS 1994=1, LFS Sept 2007==22"
label var year "Survey year"
keep /*personid*/ uqnr /*uqnr_orig*/ personnr year wave province ea urbrur dc ceweight pweight hweight gender age popgroup  inperson marstat educhigh educhigh1 enrollment3 enrolled hrslstwk employer formalreg businesstype1 businesstype2 numworkers jobstartyear jobstartmonth jobcontract publicemp jobsalary jobsalcat earncatmin earncatmax jobunion earnperiod empstat1 empstat2 jobindcode industry jobocccode occupation incpension incdisabgrnt inctstmaint incdepgrnt incfostcrgrnt hhpension hhdisablegrant hhchildsuppgrant hhcaredependgrant hhfostercaregrant dwelltype watersource toiletmaintype 
save "C:\Users\admin\Desktop\Andy\DataFirst\main project\LFSdata\LFSmerge\ohsconsistentlfs.dta", replace

