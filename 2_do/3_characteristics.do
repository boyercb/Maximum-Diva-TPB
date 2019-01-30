 * ---------------------------------------- *
 * file:    3_characteristics.do               
 * author:  Christopher Boyer              
 * project: Maximum Diva Women's Condom    
 * date:    2019-01-23                    
 * ---------------------------------------- *
 * outputs: 
 *   @Tables/t1_balance.xlsx
 *	 @Tables/t1_balance.dta
 
use "../1_data/maximum_diva_clean.dta", clear

* --------------------- Check balance of randomization ---------------------- */

/* Create a table comparing baseline covariates of treatment and control 
   groups to assess whether randomization was successful and save  */

preserve 

local covariates ${demo_vars} ${sex_vars} ${source_vars} ${sup_vars} z_know z_beliefs z_control fucond condlast

local by_var gender 

local covariates : list covariates - by_var

** calculate clustered p-values
foreach var in `covariates' {
	local is_cont : list var in global(cont_vars)	
*	
	if `is_cont' {
*		qui reg $treatment `var', cluster(ward)
*		
*		local p = 2 * ttail(e(df_r), abs(_b[`var'] / _se[`var']))
*		local f_p = trim( ///
*			cond(`p' > 0.1, "`: display %4.3f `p''", ///
*			cond(`p' <= 0.1 & `p' > 0.05, "`: display %4.3f `p''+", ///
*			cond(`p' <= 0.05 & `p' > 0.01, "`: display %4.3f `p''*", ///
*			cond(`p' <= 0.01 & `p' > 0.001, "`: display %4.3f `p''**", ///
*				"`: display %4.3f `p''***")))))
*		
*		local p_str = "`p_str' `f_p'"
		local t1_str "`t1_str' `var' contn \"
	}
*	
	else {
*		qui logit $treatment `var', cluster(ward)
*		
*		local p = 2 * normal(-abs(_b[`var'] / _se[`var']))
*		local f_p = trim( ///
*			cond(`p' > 0.1, "`: display %4.3f `p''", ///
*			cond(`p' <= 0.1 & `p' > 0.05, "`: display %4.3f `p''+", ///
*			cond(`p' <= 0.05 & `p' > 0.01, "`: display %4.3f `p''*", ///
*			cond(`p' <= 0.01 & `p' > 0.001, "`: display %4.3f `p''**", ///
*				"`: display %4.3f `p''***")))))
*		
*		local p_str = "`p_str' `f_p'"
*		
*		qui summ `var'
*		if `r(max)' == 1 {
			local t1_str "`t1_str' `var' bin \"
*		}
*		else {
*			local t1_str "`t1_str' `var' cat \"
*		}
	}
}

* create table
table1, by(`by_var') vars(`t1_str') format(%4.2f) clear onecol

** adjust p-values for clustering
*forval i = 3/`=_N' {
*	if substr(factor[`i'], 1, 1) != " " {
*		gettoken p p_str : p_str
*		replace pvalue = "`p'" in `i'
*	}
*}

save "../4_tables/t1_characteristics.dta", replace

restore 


 /************
  MERGE AND FORMAT 
 *************/

*preserve
*use "`tmp1'", clear
*append using "`tmp2'"

*replace factor = "Baseline Individual Characteristics" in 2
*replace reverse_treatment0 = "Treatment" in 1
*replace reverse_treatment1 = "Control" in 1
*replace reverse_treatment0 = "N = " + reverse_treatment0 in 2
*replace reverse_treatment1 = "N = " + reverse_treatment1 in 2
*replace factor = "Ward-Level Characteristics" in 35
*replace reverse_treatment0 = "N = " + reverse_treatment0 in 35
*replace reverse_treatment1 = "N = " + reverse_treatment1 in 35

*save "`tmp1'", replace
*restore



