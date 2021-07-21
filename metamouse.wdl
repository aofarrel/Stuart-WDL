version 1.0

import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/arraycheck_simple.wdl" as module1
import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/arraycheck_functequiv.wdl" as module2
import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/filechecker.wdl" as module3
import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/enumouse.wdl" as module4

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

	call module1.stuart_arraycheck_simple as ACS {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm]
	}

	call module1.stuart_arraycheck_simple as ACS_fastfail {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm],
			fastfail = true
	}

	call module2.stuart_arraycheck_functequiv as ACF {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm]
	}

	call module2.stuart_arraycheck_functequiv as ACF_exact {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm],
			exact = true
	}

	call module2.stuart_arraycheck_functequiv as ACF_fastfail {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm],
			fastfail = true
	}

	call module3.stuart_filechecker {
		input:
			test = SB_pheno,
			truth = local_pheno
	}

	call module4.stuart_enumouse {
		input:
			genome_build = "hg39"
	}
}