 * ---------------------------------------- *
 * file:    4_know_beliefs_control.do               
 * author:  Christopher Boyer              
 * project: Maximum Diva Women's Condom    
 * date:    2019-01-23                    
 * ---------------------------------------- *
 * outputs: 
 *   @Tables/t1_balance.xlsx
 *	 @Tables/t1_balance.dta
 
use "../1_data/maximum_diva_imputed.dta", clear


* --------------------------- Prepare output file --------------------------- */

tempname pf
tempfile tmp

* create post file
postfile `pf' str60(var m_crude1 m_95_crude1 m_adj1 m_95_adj1 m_crude2 m_95_crude2 ///
	m_adj2 m_95_adj2 m_crude3 m_95_crude3 m_adj3 m_95_adj3)  using "`tmp'"
post `pf' ("") ("Model I") ("") ("") ("") ("Model II") ("") ("") ("") ("Model III") ("") ("") ("")
post `pf' ("Covariate") ("β") ("95% CI") ("Adj β") ("95% CI") ("β") ("95% CI") ///
	("Adj β") ("95% CI") ("β") ("95% CI") ("Adj β") ("95% CI")

* --------------------------- Prepare output file --------------------------- */

mi estimate, saving(z_know_adj, replace): reg z_know ${demo_vars} ${sex_vars} ${source_vars} ${sup_vars}, cluster(ward_pt)
mi estimate, saving(z_beliefs_adj, replace): reg z_beliefs ${demo_vars} ${sex_vars} ${source_vars} ${sup_vars}, cluster(ward_pt)
mi estimate, saving(z_control_adj, replace): reg z_control ${demo_vars} ${sex_vars} ${source_vars} ${sup_vars}, cluster(ward_pt)


foreach cov in $demo_vars $sex_vars $source_vars $sup_vars {

	foreach outcome in z_know z_beliefs z_control {

		mi estimate, post: reg `outcome' `cov', cluster(ward_pt)
		
		local est = trim("`: display %9.2f `=_b[`cov']''")
		local ci_low = trim("`: display %9.2f `=_b[`cov'] - 1.96*_se[`cov']''")
		local ci_high = trim("`: display %9.2f `=_b[`cov'] + 1.96*_se[`cov']''")

		qui mi test `cov'
		local p = `r(p)'

		local `outcome'_crude = cond(`p' > 0.05, "`est'", ///
				cond(`p' <= 0.05 & `p' > 0.01, "`est'*", ///
				cond(`p' <= 0.01 & `p' > 0.001, "`est'**", ///
				"`est'***")))

		local `outcome'_95_crude = "(`ci_low', `ci_high')"

		mi estimate using `outcome'_adj, post
		local est = trim("`: display %9.2f `=_b[`cov']''")
		local ci_low = trim("`: display %9.2f `=_b[`cov'] - 1.96*_se[`cov']''")
		local ci_high = trim("`: display %9.2f `=_b[`cov'] + 1.96*_se[`cov']''")

		qui mi test `cov'
		local p = `r(p)'

		local `outcome'_adj = cond(`p' > 0.05, "`est'", ///
				cond(`p' <= 0.05 & `p' > 0.01, "`est'*", ///
				cond(`p' <= 0.01 & `p' > 0.001, "`est'**", ///
				"`est'***")))

		local `outcome'_95_adj = "(`ci_low', `ci_high')"

	}
	if "`cov'" == "gender" {
		post `pf' ("Socio-Demographics") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("")
	}

	if "`cov'" == "sexage" {
		post `pf' ("Sexual Health") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") 
	}

	if "`cov'" == "continfosource_fam_frnds" {
		post `pf' ("Source for Information about Contraception") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") 
	}

	if "`cov'" == "contsupport_a" {
		post `pf' ("Social Support") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") ("") 
	}

	post `pf' ("`: variable label `cov''") ("`z_know_crude'") ("`z_know_95_crude'") ("`z_know_adj'") ("`z_know_95_adj'")///
		("`z_beliefs_crude'") ("`z_beliefs_95_crude'") ("`z_beliefs_adj'") ("`z_beliefs_95_adj'") ///
		("`z_control_crude'") ("`z_control_95_crude'") ("`z_control_adj'") ("`z_control_95_adj'")
}

postclose `pf'
use "`tmp'", clear
save "../4_tables/t2_know_beliefs_control.dta", replace