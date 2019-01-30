 * ---------------------------------------- *
 * file:    5_intentions_and_behaviors.do               
 * author:  Christopher Boyer              
 * project: Maximum Diva Women's Condom    
 * date:    2019-01-23                    
 * ---------------------------------------- *
 * outputs: 
 *	 @Tables/t3_intentions_and_behaviors.dta
 
use "../1_data/maximum_diva_imputed.dta", clear


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

* --------------------------- Prepare output file --------------------------- */

mi estimate, saving(fucond_stage1, replace): logit fucond ${demo_vars} ${sex_vars} ${source_vars} ${sup_vars}, cluster(ward_pt)
mi estimate, saving(fucond_stage2, replace): logit fucond ${demo_vars} ${sex_vars} ${source_vars} ${sup_vars} z_know z_beliefs z_control , cluster(ward_pt)

* mi estimate: logit condspkpartnerrecent ${demo_vars} ${sex_vars} ${source_vars} ${sup_vars} z_know z_beliefs z_control  fucond, cluster(ward_pt)

mi estimate, saving(condlast_stage1, replace): logit condlast ${demo_vars} ${sex_vars} ${source_vars} ${sup_vars}, cluster(ward_pt)
mi estimate, saving(condlast_stage2, replace): logit condlast ${demo_vars} ${sex_vars} ${source_vars} ${sup_vars} z_know z_beliefs z_control , cluster(ward_pt)
mi estimate, saving(condlast_stage3, replace): logit condlast ${demo_vars} ${sex_vars} ${source_vars} ${sup_vars} z_know z_beliefs z_control  fucond, cluster(ward_pt)

foreach cov in $demo_vars $sex_vars $source_vars $sup_vars z_know z_beliefs z_control  fucond {

	foreach outcome in fucond condlast {
		if "`cov'" != "`outcome'" {
			mi estimate, post: reg `outcome' `cov', cluster(ward_pt)
			
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

			if !inlist("`cov'", "z_know", "z_control",  "z_beliefs",  "fucond") {
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

			if "`cov'" != "fucond" {
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

			if "`outcome'" != "fucond" {
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
		}

	}
	if "`cov'" == "gender" {
		post `pf' ("Socio-Demographics") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
	}

	if "`cov'" == "sexage" {
		post `pf' ("Sexual Health") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
	}

	if "`cov'" == "continfosource_fam_frnds" {
		post `pf' ("Source for Information about Contraception") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
	}

	if "`cov'" == "contsupport_a" {
		post `pf' ("Social Support") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
	}

	if "`cov'" == "z_know" {
		post `pf' ("Knowledge, Beliefs, Perceived Control") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
	}

	if "`cov'" == "fucond" {
		post `pf' ("Behavioral Intentions") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
	}	
	post `pf' ("  `: variable label `cov''") ("`fucond_crude'") ("`fucond_95_crude'") ("`fucond_stage1'") ("`fucond_95_stage1'") ///
		("`fucond_stage2'") ("`fucond_95_stage2'") ("`condlast_crude'") ("`condlast_95_crude'") ("`condlast_stage1'") ("`condlast_95_stage1'") ///
		("`condlast_stage2'") ("`condlast_95_stage2'") ("`condlast_stage3'") ("`condlast_95_stage3'")
}

postclose `pf'
use "`tmp'", clear
save "../4_tables/t3_intentions_and_behaviors.dta", replace
