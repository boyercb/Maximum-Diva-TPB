 * ---------------------------------------- *
 * file:    2_impute.do               
 * author:  Christopher Boyer              
 * project: Maximum Diva Women's Condom    
 * date:    2019-01-23                     
 * ---------------------------------------- *
 * outputs: 
 *   @data/maximum_diva_imputed.dta

use "../1_data/maximum_diva_clean.dta", clear

/* ADD IMPUTATIONS */

local to_impute ///
	sexage ///
	sexpartnernum ///
	sexpartner1mo ///
	facility_km ///
	z_know ///
	z_beliefs ///
	z_control ///
	educ_secondary ///
	educ_higher ///
	children ///
	condiniciate ///
	continiciate ///
	contagree ///
	condspkpartnerrecent ///
	contspkpartnerrecent

recode `to_impute' (.d = .) (.r = .)

unab all : _all
local dont_impute : list all - to_impute

nois di "`dont_impute'"
mi set wide

mi register imputed ///
	`to_impute'

mi impute chained ///
	(regress) sexage sexpartnernum sexpartner1mo ///
		facility_km z_know z_beliefs z_control ///
	(logit) educ_secondary educ_higher children  ///
		condiniciate continiciate contagree ///
		condspkpartnerrecent contspkpartnerrecent /// 
	= `dont_impute', add(10) augment dots rseed(479223)

save "../1_data/maximum_diva_imputed.dta", replace
