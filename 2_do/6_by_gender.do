 * ---------------------------------------- *
 * file:    5_intentions_and_behaviors.do               
 * author:  Christopher Boyer              
 * project: Maximum Diva Women's Condom    
 * date:    2019-01-23                    
 * ---------------------------------------- *
 * outputs: 
 *	 @Tables/t3_intentions_and_behaviors.dta
 
use "../1_data/maximum_diva_imputed.dta", clear

local remove gender
local demo_vars : list global(demo_vars) - remove

forval i = 0/1 {
	* --------------------------- Prepare output file --------------------------- */

	tempname pf
	tempfile tmp

	* create post file
	postfile `pf' str60(var m_crude4 m_95_crude4 m_stage1_4 m_95_stage1_4 m_stage2_4 m_95_stage2_4  ///
		m_crude5 m_95_crude5 m_stage1_5 m_95_stage1_5 m_stage2_5 m_95_stage2_5 m_stage3_5 m_95_stage3_5) using "`tmp'"
	post `pf' ("") ("Model IV") ("") ("") ("") ("") ("") ("Model V") ("") ("") ("") ("") ("") ("") ("")
	post `pf' ("Covariate") ("OR") ("95% CI") ///
		("Adj OR") ("95% CI") ("Adj OR") ("95% CI") ///
		("OR") ("95% CI") ("Adj OR") ("95% CI") ///
		("Adj OR") ("95% CI") ("Adj OR") ("95% CI")

	tempname pf2
	tempfile tmp2

	* create post file
	postfile `pf2' str60(var m_crude6 m_95_crude6 m_stage1_6 m_95_stage1_6 m_stage2_6 m_95_stage2_6  ///
		m_stage3_6 m_95_stage3_6 m_stage4_6 m_95_stage4_6) using "`tmp2'"
	post `pf2' ("") ("Model VI") ("") ("") ("") ("") ("") ("") ("") ("") ("") 
	post `pf2' ("Covariate") ("OR") ("95% CI") ///
		("Adj OR") ("95% CI") ("Adj OR") ("95% CI") ///
		("Adj OR") ("95% CI") ("Adj OR") ("95% CI") 

	* --------------------------- Prepare output file --------------------------- */

	mi estimate, saving(fucond_stage1, replace): logit fucond `demo_vars' ${sex_vars} ${source_vars} ${sup_vars} if gender == `i', cluster(ward_pt)
	mi estimate, saving(fucond_stage2, replace): logit fucond `demo_vars' ${sex_vars} ${source_vars} ${sup_vars} z_know z_beliefs z_control if gender == `i', cluster(ward_pt)

	mi estimate, saving(condspkpartnerrecent_stage1, replace): logit condspkpartnerrecent `demo_vars' ${sex_vars} ${source_vars} ${sup_vars} if gender == `i', cluster(ward_pt)
	mi estimate, saving(condspkpartnerrecent_stage2, replace): logit condspkpartnerrecent `demo_vars' ${sex_vars} ${source_vars} ${sup_vars} z_know z_beliefs z_control if gender == `i', cluster(ward_pt)
	mi estimate, saving(condspkpartnerrecent_stage3, replace): logit condspkpartnerrecent `demo_vars' ${sex_vars} ${source_vars} ${sup_vars} z_know z_beliefs z_control fucond if gender == `i', cluster(ward_pt)

	mi estimate, saving(condlast_stage1, replace): logit condlast `demo_vars' ${sex_vars} ${source_vars} ${sup_vars} if gender == `i', cluster(ward_pt)
	mi estimate, saving(condlast_stage2, replace): logit condlast `demo_vars' ${sex_vars} ${source_vars} ${sup_vars} z_know z_beliefs z_control if gender == `i', cluster(ward_pt)
	mi estimate, saving(condlast_stage3, replace): logit condlast `demo_vars' ${sex_vars} ${source_vars} ${sup_vars} z_know z_beliefs z_control fucond if gender == `i', cluster(ward_pt)
	mi estimate, saving(condlast_stage4, replace): logit condlast `demo_vars' ${sex_vars} ${source_vars} ${sup_vars} z_know z_beliefs z_control  fucond condspkpartnerrecent if gender == `i', cluster(ward_pt)

	local k = 0

	foreach cov in `demo_vars' $sex_vars $source_vars $sup_vars z_know z_beliefs z_control fucond condspkpartnerrecent {

		foreach outcome in fucond condspkpartnerrecent condlast {
			if "`cov'" != "`outcome'" {

				mi estimate, post: logit `outcome' `cov' if gender == `i', cluster(ward_pt)
				
				local est = trim("`: display %9.2f `=exp(_b[`cov'])''")
				local ci_low = trim("`: display %9.2f `=exp(_b[`cov'] - 1.96*_se[`cov'])''")
				local ci_high = trim("`: display %9.2f `=exp(_b[`cov'] + 1.96*_se[`cov'])''")

				qui mi test `cov'
				local p = `r(p)'

				local `outcome'_crude = cond(`p' > 0.05, "`est'", ///
						cond(`p' <= 0.05 & `p' > 0.01, "`est'*", ///
						cond(`p' <= 0.01 & `p' > 0.001, "`est'**", ///
						"`est'***")))

				local `outcome'_95_crude = "(`ci_low', `ci_high')"

				if !inlist("`cov'", "z_know", "z_control",  "z_beliefs",  "fucond", "condspkpartnerrecent") {
					mi estimate using `outcome'_stage1, post
					local est = trim("`: display %9.2f `=exp(_b[`cov'])''")
					local ci_low = trim("`: display %9.2f `=exp(_b[`cov'] - 1.96*_se[`cov'])''")
					local ci_high = trim("`: display %9.2f `=exp(_b[`cov'] + 1.96*_se[`cov'])''")

					qui mi test `cov'
					local p = `r(p)'

					local `outcome'_stage1 = cond(`p' > 0.05, "`est'", ///
							cond(`p' <= 0.05 & `p' > 0.01, "`est'*", ///
							cond(`p' <= 0.01 & `p' > 0.001, "`est'**", ///
							"`est'***")))

					local `outcome'_95_stage1 = "(`ci_low', `ci_high')"

				} 
				else {
					local `outcome'_stage1 = ""
					local `outcome'_95_stage1 = ""
				}

				if !inlist("`cov'", "fucond", "condspkpartnerrecent") {
					mi estimate using `outcome'_stage2, post
					local est = trim("`: display %9.2f `=exp(_b[`cov'])''")
					local ci_low = trim("`: display %9.2f `=exp(_b[`cov'] - 1.96*_se[`cov'])''")
					local ci_high = trim("`: display %9.2f `=exp(_b[`cov'] + 1.96*_se[`cov'])''")

					qui mi test `cov'
					local p = `r(p)'

					local `outcome'_stage2 = cond(`p' > 0.05, "`est'", ///
							cond(`p' <= 0.05 & `p' > 0.01, "`est'*", ///
							cond(`p' <= 0.01 & `p' > 0.001, "`est'**", ///
							"`est'***")))

					local `outcome'_95_stage2 = "(`ci_low', `ci_high')"

				}
				else {
					local `outcome'_stage2 = ""
					local `outcome'_95_stage2 = ""
				}

				if "`outcome'" != "fucond" & "`cov'" != "condspkpartnerrecent" {
					mi estimate using `outcome'_stage3, post
					local est = trim("`: display %9.2f `=exp(_b[`cov'])''")
					local ci_low = trim("`: display %9.2f `=exp(_b[`cov'] - 1.96*_se[`cov'])''")
					local ci_high = trim("`: display %9.2f `=exp(_b[`cov'] + 1.96*_se[`cov'])''")

					qui mi test `cov'
					local p = `r(p)'

					local `outcome'_stage3 = cond(`p' > 0.05, "`est'", ///
							cond(`p' <= 0.05 & `p' > 0.01, "`est'*", ///
							cond(`p' <= 0.01 & `p' > 0.001, "`est'**", ///
							"`est'***")))

					local `outcome'_95_stage3 = "(`ci_low', `ci_high')"

				}
				else {
					local `outcome'_stage3 = ""
					local `outcome'_95_stage3 = ""
				}

				if !inlist("`outcome'", "fucond", "condspkpartnerrecent") {
					mi estimate using `outcome'_stage4, post
					local est = trim("`: display %9.2f `=exp(_b[`cov'])''")
					local ci_low = trim("`: display %9.2f `=exp(_b[`cov'] - 1.96*_se[`cov'])''")
					local ci_high = trim("`: display %9.2f `=exp(_b[`cov'] + 1.96*_se[`cov'])''")

					qui mi test `cov'
					local p = `r(p)'

					local `outcome'_stage4 = cond(`p' > 0.05, "`est'", ///
							cond(`p' <= 0.05 & `p' > 0.01, "`est'*", ///
							cond(`p' <= 0.01 & `p' > 0.001, "`est'**", ///
							"`est'***")))

					local `outcome'_95_stage4 = "(`ci_low', `ci_high')"

				}
				else {
					local `outcome'_stage4 = ""
					local `outcome'_95_stage4 = ""
				}
			}
			else {
				local `outcome'_crude = ""
				local `outcome'_95_crude = ""			
			}

		}
		if "`cov'" == "age" {
			post `pf' ("Socio-Demographics") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
			post `pf2' ("Socio-Demographics") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") 
		}

		if "`cov'" == "sexage" {
			post `pf' ("Sexual Health") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
			post `pf2' ("Sexual Health") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") 
		}

		if "`cov'" == "continfosource_fam_frnds" {
			post `pf' ("Source for Information about Contraception") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
			post `pf2' ("Source for Information about Contraception") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") 
		}

		if "`cov'" == "contsupport_a" {
			post `pf' ("Social Support") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
			post `pf2' ("Social Support") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") 
		}

		if "`cov'" == "z_know" {
			post `pf' ("Knowledge, Beliefs, Perceived Control") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
			post `pf2' ("Knowledge, Beliefs, Perceived Control") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") 
		}

		if "`cov'" == "fucond" {
			post `pf' ("Behavioral Intentions") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
			post `pf2' ("Behavioral Intentions") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") 
		}	
		post `pf' ("  `: variable label `cov''") ("`fucond_crude'") ("`fucond_95_crude'") ("`fucond_stage1'") ("`fucond_95_stage1'") ///
			("`fucond_stage2'") ("`fucond_95_stage2'") ("`condspkpartnerrecent_crude'") ("`condspkpartnerrecent_95_crude'") ("`condspkpartnerrecent_stage1'") ("`condspkpartnerrecent_95_stage1'") ///
			("`condspkpartnerrecent_stage2'") ("`condspkpartnerrecent_95_stage2'") ("`condspkpartnerrecent_stage3'") ("`condspkpartnerrecent_95_stage3'")

		post `pf2' ("  `: variable label `cov''") ("`condlast_crude'") ("`condlast_95_crude'") ("`condlast_stage1'") ("`condlast_95_stage1'") ///
			("`condlast_stage2'") ("`condlast_95_stage2'") ("`condlast_stage3'") ("`condlast_95_stage3'") ("`condlast_stage4'") ("`condlast_95_stage4'")
	}
	local footer = cond(`i' == 0, "male", "female")

	preserve
	postclose `pf'
	use "`tmp'", clear
	save "../4_tables/t`=`++k' + 4'_intentions_`footer'.dta", replace
	restore

	preserve
	postclose `pf2'
	use "`tmp2'", clear
	save "../4_tables/t`=`++k' + 4'_behaviors_`footer'.dta", replace
	restore
}
