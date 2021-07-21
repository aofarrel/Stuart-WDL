version 1.0

import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/arraycheck_exact.wdl" as module1
import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/arraycheck_functequiv.wdl" as module2

workflow metamouse {
	input {
		File cwl_nullmodel
		File cwl_pheno
		File cwl_report
		File cwl_report_invnorm
		File local_nullmodel
		File local_pheno
		File local_report
		File local_report_invnorm
	}

	call module1.stuart_arraycheck_exact {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [cwl_nullmodel, cwl_pheno, cwl_report, cwl_report_invnorm]
	}

	call module2.stuart_arraycheck_functequiv {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [cwl_nullmodel, cwl_pheno, cwl_report, cwl_report_invnorm]
	}
}