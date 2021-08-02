version 1.0

import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/arraycheck_simple.wdl" as module1
import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/arraycheck_rdata.wdl" as module2
import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/filechecker.wdl" as module3
import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/enumouse.wdl" as module4
import "https://raw.githubusercontent.com/aofarrel/Stuart-WDL/main/big_cheese.wdl" as module5

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

		Boolean run_failure_cases = false
	}

	###################### these tasks should PASS ######################

	call module1.stuart_arraycheck_simple as pass_ACS {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm]
	}

	call module2.stuart_arraycheck_rdata as pass_ACR {
		input:
			test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
			truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm]
	}

	call module3.stuart_filechecker as pass_FC {
		input:
			test = SB_pheno,
			truth = local_pheno
	}

	call module4.stuart_enumouse as pass_ENU {
		input:
			genome_build = "hg38"
	}

	call module5.stuart_bigcheese {
		input:
			some_file = local_nullmodel,
			some_group_of_files = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm]
	}

	if (run_failure_cases) {
		###################### these tasks should FAIL ######################

		call module1.stuart_arraycheck_simple as fail_ACS_fastfail {
			input:
				test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
				truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm],
				fastfail = true
		}

		call module2.stuart_arraycheck_rdata as fail_ACR_exact {
			input:
				test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
				truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm],
				exact = true
		}

		call module2.stuart_arraycheck_rdata as fail_ACR_fastfail {
			input:
				test = [local_nullmodel, local_pheno, local_report, local_report_invnorm],
				truth = [SB_nullmodel, SB_pheno, SB_report, SB_report_invnorm],
				tolerance = 0.000000000000000000000000000001,
				fastfail = true
		}

		call module4.stuart_enumouse as fail_ENU {
			input:
				genome_build = "hg39"
		}

		call module4.stuart_enumouse as fail_ENU_subset {
			input:
				genome_build = "38"
		}
	}
}