 * ---------------------------------------- *
 * file:    0_master.do               
 * author:  Christopher Boyer              
 * project: Maximum Diva Women's Condom    
 * date:    2019-01-23                     
 * ---------------------------------------- *

 clear all
 set more off
 macro drop _all
 version 15

 * -------------------------- Define variable lists ------------------------- */

global outcomes ///
	z_know ///
	z_beliefs ///
	z_control ///
	fucond ///
	condlast

global demo_vars ///
	gender ///
	age ///
	in_school ///
	educ_secondary ///
	educ_higher ///
	married ///
	employmt ///
	children ///
	pov_10 ///
	pov_20 ///
	facility_km

global sex_vars ///
	sexage ///
	sti ///
	condbroke ///
	contother ///
	sexpartnernum ///
	sexpartner1mo

global ctrl_vars ///
	condspkpartnerrecent ///
	condiniciate ///
	z_control

global ctrl_vars2 ///
	contspkpartnerrecent ///
	continiciate ///
	contagree

global kab_vars ///
	z_beliefs ///
	z_know ///
	z_control
	
global source_vars ///
	continfosource_fam_frnds ///
	continfosource_media ///
	continfosource_other

global sup_vars ///
	contsupport_a ///
	contsupport_b ///
	contsupport_c 

global cont_vars ///
	sexage ///
	age ///
	facility_km ///
	z_beliefs ///
	z_know ///
	z_control ///
	sexpartnernum ///
	sexpartner1mo

 * -------------------------- Run analysis code -------------------------- */

do "1_clean.do"                    // clean and prep data for analysis
do "2_impute.do"                   // impute missing values
do "3_characteristics.do"         // create table of summary characteristics
do "4_know_beliefs_control.do"     // run primary models
do "5_intentions_and_behaviors.do" //
do "6_by_gender.do"              // run models by gender
do "7_make_document.do"          // create document 
* do "7_make_appendix.do"          // create appendix
