version 1.0

import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/arraycheck_exact.wdl" as module1
import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/arraycheck_functequiv.wdl" as module2

workflow metamouse {
	input {
		File SB_nullmodel
		File SB_pheno
		File SB_report
		File SB_report_invnorm
		File local_nullmodel
		File local_pheno
		File local_report
		File local_report_invnorm
	}

	call module1.stuart_arraycheck_exact {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm]
	}

	call module2.stuart_arraycheck_functequiv {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm]
	}
}