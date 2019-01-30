 * ---------------------------------------- *
 * file:    1_clean.do               
 * author:  Christopher Boyer              
 * project: Maximum Diva Women's Condom    
 * date:    2019-01-23                     
 * ---------------------------------------- *
 * outputs: 
 *   @data/maximum_diva_clean.dta

use "../1_data/maximum_diva_01_deidentified.dta", clear

/* =============================================================== 
   ================= BEHAVIORAL OUTCOME VARIABLES ================
   =============================================================== */

/* condlast - condom use at most recent sexual intercourse. In 
   the survey, we ask Y/N about condom use: (1) ever, (2) in the 
   last 6 months, and (3) at most recent sex; in the programming 
   condlast was skipped when (1) or (2) was zero to enforce logic 
   consistency; here we recode condlast to 0 if the respondent 
   reported never using condoms or not using them in last 6 months. */

replace condlast = 0 if condever == 0 | cond6mo == 0

/* fucond - intention to use condoms in the future. In the survey
   we ask Y/N about future contraceptive use and then which method
   so we need to collapse people who would use any contraception
   in future and those that would choose condoms */

g fucond = fupregprevent & fucont_g 
replace fucond = . if mi(fupregprevent)


/* =============================================================== 
   ================= SOCIO-DEMOGRAPHIC VARIABLES =================
   =============================================================== */

/* age - age of the respondent. Use the calculated final age based on
   DOB from the roster and correct for a few rounding errors */

recode age ///
	(25 = 24) ///
	(17 = 18) ///
	(1/17 = .)

/* educ - highest level of schooling attained. Collapse the 
   categories from the original survey question to just none/primary,
   secondary, and higher. */
   
ren edustatus in_school
recode eduattain ///
	(0 1 2 4 = 0 "No") ///
	(3 = 1 "Yes"), ///
	gen(educ_secondary) 

recode eduattain ///
	(0 1 2 3 = 0 "No") ///
	(4 = 1 "Yes"), ///
	gen(educ_higher)
	
/* married - indicator that respondent is married. Collapse 
   relationship status variable into a single dichotomous married vs.
   unmarried variable. */

recode relationship ///
	(1 = 1 "Married") ///
	(nonmissing = 0 "Unmarried") ///
	(missing = .), ///
	gen(married)

/* children - indicator whether respondent has children. Recode the  
   continuous survey question to binary and missing value codes as 
   Stata missing value codes. */

recode childnum ///
    (0 = 0 "None") ///
    (1/5 = 1 "1 or more") ///
    (999 = .) ///
    (998 = .), ///
    gen(children)

/* hhcomp - variable capturing living arrangements. */


/* poverty - ward level measure of percent living below the poverty
   line. Categorize into two levels. */

egen mode_poverty = mode(percpoor), by(ward)
replace percpoor = mode_poverty if mi(percpoor)

g pov_10 = .
replace pov_10 = 0 if percpoor >= 0 & percpoor < 0.1
replace pov_10 = 1 if percpoor >= 0.1 & percpoor < 0.2
replace pov_10 = 0 if percpoor >= 0.2 & percpoor < .

g pov_20 = .
replace pov_20 = 0 if percpoor >= 0 & percpoor < 0.2
replace pov_20 = 1 if percpoor >= 0.2 & percpoor < .


/* =============================================================== 
   ============== KNOWLEDGE, ATTITUDES, AND BELIEFS ==============
   =============================================================== */

/* fcident - can identify the female condom correctly using photo. */

g fcident = fcphoto == 2

/* z_know - knowledge index. Create a standardized index based on
   the */

mca contknow_a-contknow_i contknow_m condop_a condop_b condop_n-condop_q contobtain fcident
matrix wts = e(rSCW)
predict z_know
replace z_know = -z_know

tempname pf
tempfile tmp

* create post file
postfile `pf' str60(var response weight) using "`tmp'"
post `pf' ("Variable") ("Response") ("Weight")

local i = 0
foreach var of varlist contknow_a-contknow_i contknow_m condop_a condop_b condop_n-condop_q contobtain fcident {
	post `pf' ("`: variable label `var''") ("0") ("`=-wts[`=`++i'', 1]'")
	post `pf' ("") ("1") ("`=-wts[`=`++i'', 1]'")
}
postclose `pf'

preserve
use "`tmp'", clear
save "../4_tables/tx1_z_know.dta", replace
restore
/* z_beliefs - positive beliefs index. */

mca condop_e condop_h-condop_m
matrix wts = e(rSCW)
predict z_beliefs
* replace z_beliefs = -z_beliefs

tempname pf
tempfile tmp

* create post file
postfile `pf' str60(var response weight) using "`tmp'"
post `pf' ("Variable") ("Response") ("Weight")

local i = 0
foreach var of varlist condop_e condop_h-condop_m {
	post `pf' ("`: variable label `var''") ("0") ("`=wts[`=`++i'', 1]'")
	post `pf' ("") ("1") ("`=wts[`=`++i'', 1]'")
}
postclose `pf'

preserve
use "`tmp'", clear
save "../4_tables/tx2_z_beliefs.dta", replace
restore
*!!! create supplemental table HERE !!!

/* =============================================================== 
   ====================== PERCEIVED CONTROL ======================
   =============================================================== */

mca condop_c-condop_d condop_f-condop_g
matrix wts = e(rSCW)
predict z_control
replace z_control = -z_control

tempname pf
tempfile tmp

* create post file
postfile `pf' str60(var response weight) using "`tmp'"
post `pf' ("Variable") ("Response") ("Weight")

local i = 0
foreach var of varlist condop_c-condop_d condop_f-condop_g {
	post `pf' ("`: variable label `var''") ("0") ("`=-wts[`=`++i'', 1]'")
	post `pf' ("") ("1") ("`=-wts[`=`++i'', 1]'")
}
postclose `pf'

preserve
use "`tmp'", clear
save "../4_tables/tx3_z_control.dta", replace
restore

/* condspkpartnerrecent - spoke with most recent partner about 
   condom use. Originally this was asked only of those who've ever 
   used condoms but we'd like to recode to include entire sample */

replace condspkpartnerrecent = 2 if condever == 0
recode condspkpartnerrecent (2 = 0)

replace contspkpartnerrecent = 2 if contspkpartnerrecent == .
recode contspkpartnerrecent (2 = 0)

/* condiniciate - iniciated the discussion of condom use. Originally 
   this was asked only of those who've ever used condoms but we'd 
   like to recode to include entire sample. Also recode 'both'
   to 0. */
ren condiniciate old
recode old ///
	(2 . = 0 "Did not iniciate") ///
	(1 3 = 1 "Iniciated"), ///
	gen(condiniciate)
drop old

ren continiciate old
recode old ///
	(2 . = 0 "Did not iniciate") ///
	(1 3 = 1 "Iniciated"), ///
	gen(continiciate)
drop old

recode contagree (2 = 0)
	
	
/* =============================================================== 
   ==================== SEXUAL HEALTH HISTORY ====================
   =============================================================== */

/* sexpartnernum - number of lifetime sex partners. keep as a 
   continuous variable but recode the survey missing value codes as 
   Stata missing value codes (includes one miss entered value). */ 

recode sexpartnernum ///
	(999 = .) ///
	(998 = .) 

winsor2 sexpartnernum, replace cut(1 99)

/* sexpartner6mo - number of sex partners in last 6 months. keep as a 
   continuous variable but recode the survey missing value codes as 
   Stata missing value codes (includes one miss entered value). */ 

recode sexpartner6mo ///
	(999 = .) ///
	(998 = .) 

winsor2 sexpartner6mo, replace cut(1 99)

/* sexparnter1mo - frequency of sex in last month. keep as a 
   continuous variable but recode the survey missing value codes as
   Stata missing value codes. */

recode sexpartner1mo ///
	(999 = .) ///
	(998 = .) 

winsor2 sexpartner1mo, replace cut(1 99)


/* sexage - keep as a continuous variable but recode the survey 
   missing value codes as Stata missing value codes. */

replace sexage = .d if sexage == 999 
replace sexage = .r if sexage == 998

winsor2 sexage, replace cut(1 99)

/* sti - recode to binary variable */

g sti = 0
replace sti = 1 if stitestever == 1

/* contother - using other contraceptive method in last 6 months. 
   Here we are just including modern methods. */
   
g contother = 0
replace contother = 0 if ///
	inlist( ///
		1, ///
		contuse_j, ///
		contuse_k, ///
		contuse_l, ///
		contuse_n ///
	)
	
replace contother = 1 if ///
	inlist( ///
		1, ///
		contuse_afem, ///
		contuse_bfem, ///
		contuse_amale, ///
		contuse_bmale, ///
		contuse_c, ///
		contuse_d, ///
		contuse_e, ///
		contuse_f, ///
		contuse_h, ///
		contuse_i, ///
		contuse_m ///
	) 

/* condbroke - experienced a condom breakage during sex. Originally
   this was asked only of those who've ever used condoms but we'd
   like to recode to include entire sample */

replace condbroke = 0 if condever == 0
	
	
/* =============================================================== 
   ======================= SOCIAL SUPPORT ========================
   =============================================================== */

recode contsupport_a-contsupport_e (. = 0)


/* =============================================================== 
   ===================== INFORMATION SOURCE ======================
   =============================================================== */

g continfosource_fam_frnds = continfosource_a | continfosource_b
g continfosource_media = continfosource_c | continfosource_d | continfosource_e
g continfosource_others = continfosource_f | continfosource_g | continfosource_h 

/* =============================================================== 
   =================== CREATE CLUSTER VARIABLE ===================
   =============================================================== */

egen ward_pt = group(ward samplingpt)

/* =============================================================== 
   ====================== LABEL AND EXPORT =======================
   =============================================================== */
	
lab var gender        "Female"
lab var age           "Age"
lab var in_school     "Currently in school"
lab var educ_secondary"Secondary School"
lab var educ_higher    "Post-Secondary School"
lab var employmt      "Employed"
lab var married       "Married"
lab var sexage        "Age at first sexual intercourse"
lab var children      "Any children"
lab var sti           "Ever tested for an STI"
lab var facility_km   "Distance to nearest health facility (km)"
lab var contother     "Uses other contraceptives"
lab var z_beliefs     "Beliefs about condoms index"
lab var z_know        "Contraceptive knowledge index"
lab var z_control     "Perceived control of condom use index"
lab var pov_10        "Ward poverty rate, 10 - 20%"
lab var pov_20        "Ward poverty rate, above 20%"
lab var condspkpartnerrecent "Discussed condom use with most recent sexual partner"
lab var condiniciate  "Initiated discussion of condom use with most recent partner"
lab var condbroke     "Had a condom break"
lab var sexpartnernum "Lifetime sex partners (n)"
lab var sexpartner1mo "Frequency of sex in last month (n)"
lab var continfosource_fam_frnds "Friends or Family"
lab var continfosource_media "Media (radio/tv/internet)"
lab var continfosource_other "Healthcare providers, school, or NGOs"
lab var contsupport_a    "Friends support using contraception"
lab var contsupport_b    "Partner supports using contraception"
lab var contsupport_c    "Family supports using contraception"
lab var fucond           "Intends to use condoms in future"
lab var condlast         "Used a condom during last intercourse"

label define gender ///
	0 "Male" ///
	1 "Female"

label values gender gender

keep ${demo_vars} ///
	${ctrl_vars} ///
	${ctrl_vars2} ///
	${sex_vars} ///
	${kab_vars} ///
	${source_vars} ///
	${sup_vars} ///
	condlast ///
	fucond ///
	fupregprevent ///
	ward_pt

save "../1_data/maximum_diva_clean.dta", replace
