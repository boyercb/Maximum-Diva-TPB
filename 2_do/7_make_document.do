 * ---------------------------------------- *
 * file:    7_make_document.do               
 * author:  Christopher Boyer              
 * project: Maximum Diva Women's Condom    
 * date:    2019-01-23                   
 * ---------------------------------------- *
 * outputs: 
 *   @Documents/Maximum_Diva_TBP_Replication.docx
 
 
putdocx clear
putdocx begin, font("Calibri", 7) landscape
putdocx paragraph 
 
local i = 0
local tables : dir "../4_tables" files "t*.dta"
local tables : list sort tables

foreach table in `tables' {
	noi di "`table'"
	use "../4_tables/`table'", clear
	putdocx table t`++i' = data(_all), ///
		layout(autofitcontents) ///
		halign(center) ///
		cellmargin(left, 0.04 in) ///
		cellmargin(right, 0.04 in) ///
		border(insideH, nil) ///
		border(insideV, nil) ///
		border(start, nil) ///
		border(end, nil) 
	
	forval j = 2/`c(k)' {
		putdocx table t`i'(., `j'), halign(center)
	}
	
	putdocx table t`i'(1, .), bold
	
	local j = 0
	
	if inlist(`i', 4, 5) {
		local j = 1
	}
	

	if inlist(`i', 1, 2, 3, 4, 5) {
		putdocx table t`i'(2, .), bold border(bottom)
	 	putdocx table t`i'(3, .), italic
	 	putdocx table t`i'(`=15 - `j'', .), italic
	 	putdocx table t`i'(`=22 - `j'', .), italic
	 	putdocx table t`i'(`=26 - `j'', .), italic
		if inlist(`i', 3, 4, 5) {
		 	putdocx table t`i'(`=30 - `j'', .), italic
		 	putdocx table t`i'(`=34 - `j'', .), italic
		}
	}
	else {
		putdocx table t`i'(1, .), bold border(bottom)
	}
	
	putdocx pagebreak
}

putdocx save "../5_documents/Maximum_Diva_TPB_Replication.docx", replace
